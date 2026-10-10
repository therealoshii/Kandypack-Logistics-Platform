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
    DECLARE v_CurrDep TIME;
    DECLARE v_NextScheduleID INT;
    DECLARE v_NextDep TIME;
    
    -- Loop guard to prevent infinite loops
    DECLARE v_Guard INT DEFAULT 0;

    -- 1. Get order item details and space consumption rate
    SELECT od.ProductID, od.Quantity INTO v_ProductID, v_RemainingQty
    FROM OrderDetail od
    WHERE od.OrderDetailID = p_OrderDetailID;

    SELECT SpaceConsumption INTO v_SpaceRate
    FROM Product
    WHERE ProductID = v_ProductID;

    -- 2. Retrieve destination StoreID and initial departure time from target schedule
    SELECT StoreID, DepartureTime INTO v_DestStoreID, v_CurrDep
    FROM TrainSchedule
    WHERE ScheduleID = p_TargetScheduleID;

    SET v_CurrScheduleID = p_TargetScheduleID;
    SET v_CurrDate = p_ShipmentDate;

    -- 3. Validation: Prevent division by zero or impossible product sizes
    IF v_SpaceRate <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product space consumption rate must be greater than zero.';
    END IF;

    -- 4. Main scheduling and rollover loop
    WHILE v_RemainingQty > 0 DO
        -- Guardrail check to prevent server hangs / infinite loops
        SET v_Guard = v_Guard + 1;
        IF v_Guard > 200 OR v_CurrDate > DATE_ADD(p_ShipmentDate, INTERVAL 28 DAY) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No train capacity found within 4 weeks for this destination.';
        END IF;

        -- Get available capacity for the current schedule and date
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

        -- If quantity remains, find the next available train in chronological order for that weekday
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
                -- Move to the next train on the same day
                SET v_CurrScheduleID = v_NextScheduleID;
                SET v_CurrDep = v_NextDep;
            ELSE
                -- No more trains today; roll over to the next calendar day and reset departure clock
                SET v_CurrDate = DATE_ADD(v_CurrDate, INTERVAL 1 DAY);
                SET v_CurrDep = '-00:00:01'; -- Allows 00:00:00 departures on the next day

                -- Find the first train operating on this new weekday
                SELECT ScheduleID, DepartureTime INTO v_CurrScheduleID, v_NextDep
                FROM TrainSchedule
                WHERE StoreID = v_DestStoreID
                  AND DayOfWeek = DAYNAME(v_CurrDate)
                ORDER BY DepartureTime ASC
                LIMIT 1;

                -- If the next day doesn't have a scheduled train, loop will continue searching up to 28 days
                IF v_CurrScheduleID IS NOT NULL THEN
                    SET v_CurrDep = v_NextDep;
                END IF;
            END IF;
        END IF;
    END WHILE;
END //

DELIMITER ;