-- Rule: weekly working-hour limits, 40 hours for Drivers and 60 hours for Assistants
-- Requirement: SRS Section 4.4 / REQ-4 & REQ-5

-- Called by trg_before_insert_trucktrip and trg_before_update_trucktrip
-- p_SelfID is NULL on insert and the trip's own TripID on update

-- The hours are calculated here instead of with GetDriverWeeklyHours / GetAssistantWeeklyHours,
-- because on an update those functions would count the trip's old row as well as the new one

DROP PROCEDURE IF EXISTS sp_check_weekly_hours;

DELIMITER //

CREATE PROCEDURE sp_check_weekly_hours(IN p_SelfID INT, IN p_TruckID INT, IN p_RouteID INT,
                                       IN p_DriverID INT, IN p_AssistantID INT,
                                       IN p_Date DATE, IN p_Dispatch TIME, IN p_Return TIME)
BEGIN
    DECLARE trip_duration DECIMAL(6,2);
    DECLARE driver_hours DECIMAL(6,2) DEFAULT 0.00;
    DECLARE assistant_hours DECIMAL(6,2) DEFAULT 0.00;

    -- Duration of the trip being saved, in decimal hours
    SET trip_duration = TIME_TO_SEC(TIMEDIFF(p_Return, p_Dispatch)) / 3600.0;

    -- Driver's other trips in the same week (Monday to Sunday)
    SELECT COALESCE(SUM(TIME_TO_SEC(TIMEDIFF(ReturnTime, DispatchTime))), 0) / 3600.0
    INTO driver_hours
    FROM TruckTrip
    WHERE DriverID = p_DriverID
      AND YEARWEEK(TripDate, 1) = YEARWEEK(p_Date, 1)
      AND TripID <> COALESCE(p_SelfID, 0);

    IF (driver_hours + trip_duration) > 40.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver exceeds weekly limit of 40 working hours.';
    END IF;

    -- Assistant's other trips in the same week
    IF p_AssistantID IS NOT NULL THEN -- assistant is mandatory, but just in case, we check for NULL
        SELECT COALESCE(SUM(TIME_TO_SEC(TIMEDIFF(ReturnTime, DispatchTime))), 0) / 3600.0
        INTO assistant_hours
        FROM TruckTrip
        WHERE AssistantID = p_AssistantID
          AND YEARWEEK(TripDate, 1) = YEARWEEK(p_Date, 1)
          AND TripID <> COALESCE(p_SelfID, 0);

        IF (assistant_hours + trip_duration) > 60.00 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Assistant exceeds weekly limit of 60 working hours.';
        END IF;
    END IF;
END //

DELIMITER ;