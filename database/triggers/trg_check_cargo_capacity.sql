DROP TRIGGER IF EXISTS trg_check_cargo_capacity;

DELIMITER //

CREATE TRIGGER trg_check_cargo_capacity
BEFORE INSERT ON Shipment
FOR EACH ROW
BEGIN
    DECLARE v_ProductID INT;
    DECLARE v_RequiredSpace DECIMAL(10, 2);
    DECLARE v_AvailableSpace DECIMAL(10, 2);

    SELECT ProductID INTO v_ProductID
    FROM OrderDetail
    WHERE OrderDetailID = NEW.OrderDetailID;

    SET v_RequiredSpace = fn_calculate_total_space(v_ProductID, NEW.Quantity);
    SET v_AvailableSpace = fn_get_available_capacity(NEW.ScheduleID, NEW.ShipmentDate);

    IF v_RequiredSpace > v_AvailableSpace THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capacity Exceeded: Train cargo limit reached for this run.';
    END IF;
END //

DELIMITER ;