DELIMITER //

CREATE PROCEDURE sp_schedule_shipment(
    IN p_OrderDetailID INT,
    IN p_TargetScheduleID INT,
    IN p_ShipmentDate DATE
)
BEGIN
    DECLARE v_ProductID INT;
    DECLARE v_RemainingQty INT;
    DECLARE v_SpaceRate DECIMAL(8, 2);
    DECLARE v_AvailSpace DECIMAL(10, 2);
    DECLARE v_FitQty INT;
    DECLARE v_CurrScheduleID INT;
    DECLARE v_CurrDate DATE;
    DECLARE v_Destination VARCHAR(50);

    SELECT od.ProductID, od.Quantity INTO v_ProductID, v_RemainingQty
    FROM OrderDetail od
    WHERE od.OrderDetailID = p_OrderDetailID;

    SELECT SpaceConsumption INTO v_SpaceRate
    FROM Product
    WHERE ProductID = v_ProductID;

    SELECT Destination INTO v_Destination
    FROM TrainSchedule
    WHERE ScheduleID = p_TargetScheduleID;

    SET v_CurrScheduleID = p_TargetScheduleID;
    SET v_CurrDate = p_ShipmentDate;

    WHILE v_RemainingQty > 0 DO
        SET v_AvailSpace = fn_get_available_capacity(v_CurrScheduleID, v_CurrDate);

        IF v_AvailSpace > 0 THEN
            SET v_FitQty = FLOOR(v_AvailSpace / v_SpaceRate);

            IF v_FitQty >= v_RemainingQty THEN
                INSERT INTO Shipment (OrderDetailID, ScheduleID, Quantity, ShipmentDate)
                VALUES (p_OrderDetailID, v_CurrScheduleID, v_RemainingQty, v_CurrDate);
                SET v_RemainingQty = 0;
            ELSEIF v_FitQty > 0 THEN
                INSERT INTO Shipment (OrderDetailID, ScheduleID, Quantity, ShipmentDate)
                VALUES (p_OrderDetailID, v_CurrScheduleID, v_FitQty, v_CurrDate);
                SET v_RemainingQty = v_RemainingQty - v_FitQty;
            END IF;
        END IF;

        IF v_RemainingQty > 0 THEN
            SELECT ScheduleID INTO v_CurrScheduleID
            FROM TrainSchedule
            WHERE Destination = v_Destination AND ScheduleID > v_CurrScheduleID
            ORDER BY ScheduleID ASC
            LIMIT 1;

            IF v_CurrScheduleID IS NULL THEN
                SET v_CurrDate = DATE_ADD(v_CurrDate, INTERVAL 1 DAY);
                SELECT ScheduleID INTO v_CurrScheduleID
                FROM TrainSchedule
                WHERE Destination = v_Destination
                ORDER BY ScheduleID ASC
                LIMIT 1;
            END IF;
        END IF;
    END WHILE;
END //

DELIMITER ;