-- Order Assignment (SRS 4.3.3 / REQ-4)
-- Links an order to a trip and writes Delivery/AuditLog records (1 order : 1 delivery).
-- Validations run via trg_validate_delivery; rolls back on failure.

DROP PROCEDURE IF EXISTS sp_assign_delivery;

DELIMITER //

CREATE PROCEDURE sp_assign_delivery(
    IN p_OrderID INT,
    IN p_TripID INT,
    IN p_ChangedBy VARCHAR(50), -- username of the staff member, recorded in the AuditLog
    OUT p_DeliveryID INT
)
BEGIN
    DECLARE v_Status VARCHAR(20) DEFAULT NULL;
    DECLARE v_Existing INT DEFAULT NULL;
    DECLARE v_TripDate DATE DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock the order, so two dispatchers cannot assign it to two trips at the same moment
    SELECT Status INTO v_Status
    FROM Orders
    WHERE OrderID = p_OrderID
    FOR UPDATE;

    IF v_Status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Order does not exist.';
    END IF;

    IF v_Status IN ('Cancelled', 'Delivered') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Delivery Violation: A cancelled or delivered order cannot be assigned to a trip.';
    END IF;

    SELECT MAX(DeliveryID) INTO v_Existing
    FROM Delivery
    WHERE OrderID = p_OrderID;

    IF v_Existing IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Delivery Violation: This order is already assigned to a truck trip.';
    END IF;

    SELECT TripDate INTO v_TripDate
    FROM TruckTrip
    WHERE TripID = p_TripID;

    IF v_TripDate IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Truck trip does not exist.';
    END IF;

    -- The trigger validates this row before it is saved
    INSERT INTO Delivery (OrderID, TripID, DeliveryDate, Status)
    VALUES (p_OrderID, p_TripID, v_TripDate, 'Scheduled');

    SET p_DeliveryID = LAST_INSERT_ID();

    INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
    VALUES ('Delivery', 'INSERT', p_DeliveryID, COALESCE(p_ChangedBy, 'SYSTEM'),
            CONCAT('Order #', p_OrderID, ' assigned to truck trip #', p_TripID, ' for ', v_TripDate));

    COMMIT;
END //

DELIMITER ;
