-- RULE: Atomic train booking for all pending order lines (SRS 4.3.2)
-- Books every unassigned line for an order in one transaction; rolls back entirely if any line fails.
-- Lines start on the same train/date and roll over individually via sp_ship_order_line.
-- Iterates using MIN(ID) instead of a cursor to prevent handler conflicts.

DROP PROCEDURE IF EXISTS sp_schedule_order;

DELIMITER //

CREATE PROCEDURE sp_schedule_order(
    IN p_OrderID INT,
    IN p_TargetScheduleID INT,
    IN p_ShipmentDate DATE
)
BEGIN
    DECLARE v_Status VARCHAR(20) DEFAULT NULL;
    DECLARE v_LineID INT DEFAULT 0;
    DECLARE v_LinesBooked INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock the order, so two dispatchers cannot book the same order at the same time
    SELECT Status INTO v_Status
    FROM Orders
    WHERE OrderID = p_OrderID
    FOR UPDATE;

    IF v_Status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order does not exist.';
    END IF;

    IF v_Status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A cancelled order cannot be shipped.';
    END IF;

    -- First line that still has units waiting
    SELECT MIN(od.OrderDetailID) INTO v_LineID
    FROM OrderDetail od
    WHERE od.OrderID = p_OrderID
      AND od.Quantity > COALESCE((SELECT SUM(s.Quantity) FROM Shipment s WHERE s.OrderDetailID = od.OrderDetailID), 0);

    WHILE v_LineID IS NOT NULL DO
        CALL sp_ship_order_line(v_LineID, p_TargetScheduleID, p_ShipmentDate);
        SET v_LinesBooked = v_LinesBooked + 1;

        -- Next line after this one that still has units waiting
        SELECT MIN(od.OrderDetailID) INTO v_LineID
        FROM OrderDetail od
        WHERE od.OrderID = p_OrderID
          AND od.OrderDetailID > v_LineID
          AND od.Quantity > COALESCE((SELECT SUM(s.Quantity) FROM Shipment s WHERE s.OrderDetailID = od.OrderDetailID), 0);
    END WHILE;

    IF v_LinesBooked = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order is already fully shipped.';
    END IF;

    COMMIT;
END //

DELIMITER ;
