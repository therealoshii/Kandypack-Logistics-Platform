-- This function calculates total working hours for drivers and assistants (Per week)
-- It is based on the route maximum delivery times 

DROP FUNCTION IF EXISTS fn_calculate_weekly_hours;
DROP FUNCTION IF EXISTS GetDriverWeeklyHours;
DROP FUNCTION IF EXISTS GetAssistantWeeklyHours;

DELIMITER //

CREATE FUNCTION fn_calculate_weekly_hours (PersonType VARCHAR(20), PersonID INT, WeekDate Date)
    RETURNS DECIMAL(5,2)
    
    NOT DETERMINISTIC
    READS SQL DATA

    BEGIN
        DECLARE total_hours DECIMAL(5,2) DEFAULT 0.00;
        
        IF UPPER(PersonType) = 'DRIVER' THEN
            SELECT COALESCE(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 0.00) INTO total_hours
            FROM TruckTrip tt
            WHERE tt.DriverID = PersonID
                AND YEARWEEK(tt.TripDate, 1) = YEARWEEK(WeekDate, 1);

        ELSEIF UPPER(PersonType) = 'ASSISTANT' THEN
            SELECT COALESCE(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 0.00) INTO total_hours
            FROM TruckTrip tt
            WHERE tt.AssistantID = PersonID
                AND YEARWEEK(tt.TripDate, 1) = YEARWEEK(WeekDate, 1);

        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Invalid PersonType. Must be DRIVER or ASSISTANT.';

        END IF;
        
        RETURN total_hours;
    END //


CREATE FUNCTION GetDriverWeeklyHours (DriverID INT, WeekDate Date)
    RETURNS DECIMAL(5,2)
    
    NOT DETERMINISTIC
    READS SQL DATA

    BEGIN
        RETURN fn_calculate_weekly_hours('DRIVER', DriverID, WeekDate);
    END //


CREATE FUNCTION GetAssistantWeeklyHours (AssistantID INT, WeekDate Date)
    RETURNS DECIMAL(5,2)

    NOT DETERMINISTIC
    READS SQL DATA

    BEGIN
        RETURN fn_calculate_weekly_hours('ASSISTANT', AssistantID, WeekDate);
    END //

DELIMITER ;