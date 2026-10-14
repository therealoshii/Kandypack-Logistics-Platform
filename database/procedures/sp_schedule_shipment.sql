-- Books ONE order line onto train runs, in its own transaction.
-- The booking itself (capacity, splitting, rollover, order status) is done by sp_ship_order_line.
-- To book every line of an order at once, use sp_schedule_order.
-- Requirement: SRS Section 4.3.2

DROP PROCEDURE IF EXISTS sp_schedule_shipment;

DELIMITER //

CREATE PROCEDURE sp_schedule_shipment(
    IN p_OrderDetailID INT,
    IN p_TargetScheduleID INT,
    IN p_ShipmentDate DATE
)
BEGIN
    -- Exit handler for transaction safety (Rollback on error)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    CALL sp_ship_order_line(p_OrderDetailID, p_TargetScheduleID, p_ShipmentDate);

    COMMIT;
END //

DELIMITER ;
