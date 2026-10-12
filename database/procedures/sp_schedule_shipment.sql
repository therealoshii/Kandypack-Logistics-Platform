DROP PROCEDURE IF EXISTS sp_schedule_shipment;

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
    
    -- Position tracking variables
    DECLARE v_CurrScheduleID INT;
    DECLARE v_CurrDate DATE;
    DECLARE v_DestStoreID INT;
    DECLARE v_OrderStoreID INT;
    DECLARE v_CurrDep TIME;
    DECLARE v_ScheduleDay VARCHAR(20);
    DECLARE v_NextScheduleID INT;
    DECLARE v_NextDep TIME;
    
    -- Loop guard to prevent infinite loops
    DECLARE v_Guard INT DEFAULT 0;

    -- Exit handler for transaction safety (Rollback on error)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Start explicit transaction
    START TRANSACTION;

    -- 1. Validate order line existence, calculate remaining quantity, and get route StoreID
    SELECT 
        od.ProductID, 
        od.Quantity - COALESCE((SELECT SUM(s.Quantity) FROM Shipment s WHERE s.OrderDetailID = od.OrderDetailID), 0),
        r.StoreID 
    INTO v_ProductID, v_RemainingQty, v_OrderStoreID
    FROM OrderDetail od
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Route r ON o.RouteID = r.RouteID
    WHERE od.OrderDetailID = p_OrderDetailID;

    IF v_ProductID IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order line does not exist.';
    END IF;

    IF v_RemainingQty <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order line is already fully shipped.';
    END IF;

    -- 2. Retrieve destination StoreID, departure time, and operating day from target schedule
    SELECT StoreID, DepartureTime, DayOfWeek INTO v_DestStoreID, v_CurrDep, v_ScheduleDay
    FROM TrainSchedule
    WHERE ScheduleID = p_TargetScheduleID;

    IF v_DestStoreID IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Target train schedule does not exist.';
    END IF;

    -- 3. Destination check: Compare schedule's StoreID with order route's StoreID
    IF v_DestStoreID != v_OrderStoreID THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Train schedule destination does not match order route destination.';
    END IF;

    -- 4. Validate that the requested date matches the train's operating day
    IF v_ScheduleDay != DAYNAME(p_ShipmentDate) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Requested shipment date does not match the operating day of the target train schedule.';
    END IF;

    SELECT SpaceConsumption INTO v_SpaceRate
    FROM Product
    WHERE ProductID = v_ProductID;

    -- 5. Validation: Prevent division by zero
    IF v_SpaceRate <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product space consumption rate must be greater than zero.';
    END IF;

    SET v_CurrScheduleID = p_TargetScheduleID;
    SET v_CurrDate = p_ShipmentDate;

    -- 6. Main scheduling and rollover loop
    WHILE v_RemainingQty > 0 DO
        -- Guardrail check
        SET v_Guard = v_Guard + 1;
        IF v_Guard > 200 OR v_CurrDate > DATE_ADD(p_ShipmentDate, INTERVAL 28 DAY) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No train capacity found within 4 weeks for this destination.';
        END IF;

        -- Lock schedule row using FOR UPDATE
        SELECT ScheduleID INTO v_CurrScheduleID 
        FROM TrainSchedule 
        WHERE ScheduleID = v_CurrScheduleID 
        FOR UPDATE;

        -- Get available capacity
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

        -- If quantity remains, rollover to next available train slot
        IF v_RemainingQty > 0 THEN
            SET v_NextScheduleID = NULL;
            SET v_NextDep = NULL;

            -- Look for later trains on the *same day* matching the weekday
            SELECT ScheduleID, DepartureTime INTO v_NextScheduleID, v_NextDep
            FROM TrainSchedule
            WHERE StoreID = v_DestStoreID
              AND DayOfWeek = DAYNAME(v_CurrDate)
              AND DepartureTime > v_CurrDep
            ORDER BY DepartureTime ASC
            LIMIT 1;

            IF v_NextScheduleID IS NOT NULL THEN
                SET v_CurrScheduleID = v_NextScheduleID;
                SET v_CurrDep = v_NextDep;
            ELSE
                -- Roll over to the next calendar day and reset v_CurrScheduleID to NULL
                SET v_CurrDate = DATE_ADD(v_CurrDate, INTERVAL 1 DAY);
                SET v_CurrDep = '-00:00:01';
                SET v_CurrScheduleID = NULL;

                -- Keep moving forward day by day until a day with a train is found
                WHILE v_CurrScheduleID IS NULL AND v_Guard < 200 DO
                    SET v_Guard = v_Guard + 1;
                    
                    SELECT ScheduleID, DepartureTime INTO v_CurrScheduleID, v_NextDep
                    FROM TrainSchedule
                    WHERE StoreID = v_DestStoreID
                      AND DayOfWeek = DAYNAME(v_CurrDate)
                    ORDER BY DepartureTime ASC
                    LIMIT 1;

                    IF v_CurrScheduleID IS NULL THEN
                        SET v_CurrDate = DATE_ADD(v_CurrDate, INTERVAL 1 DAY);
                    END IF;
                END WHILE;

                IF v_CurrScheduleID IS NOT NULL THEN
                    SET v_CurrDep = v_NextDep;
                END IF;
            END IF;
        END IF;
    END WHILE;

    COMMIT;
END //

DELIMITER ;