-- This procedure assigns truck trips to Drivers and Assistants
-- Automated dispatch controller before a tip is saved in the database

-- Requirements:
--   - SRS Section 4.4: Driver 40h & Assistant 60h caps, consecutive trip rules
--   - SRS Section 4.4 / REQ-6: Schedule conflict validation

DROP PROCEDURE IF EXISTS sp_assign_truck_trip;

DELIMITER //

-- The "p_" means parameter
CREATE PROCEDURE sp_assign_truck_trip(IN p_TruckID INT, IN p_RouteID INT, IN p_DriverID INT, IN p_AssistantID INT, -- IN attributes
                                      IN p_TripDate DATE, IN p_DispatchTime TIME, IN p_ReturnTime TIME, 
                                      OUT p_TripID INT) -- OUT attribute
    BEGIN
        -- Declare the needed variables
        DECLARE trip_duration DECIMAL(5,2);
        DECLARE driver_current_hours DECIMAL(5,2);
        DECLARE assistant_current_hours DECIMAL(5,2);
        DECLARE conflict_count INT DEFAULT 0;
        DECLARE consecutive_trips INT DEFAULT 0; 

        DECLARE EXIT HANDLER FOR SQLEXCEPTION -- If something fails during execution
        BEGIN
            ROLLBACK; -- Undo the changes that has been done
            RESIGNAL; -- Sends the error to the caller
        END;

    -- SIGNAL SQLSTATE '45000' => throws a custom error
    -- Validate that Dispatch time >= Return Time (Truck cannot return before it departs)
    IF p_ReturnTime <= p_DispatchTime THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Return time must be after dispatch time.';
    END IF;

    -- Total duration of the trip in decimal hours
    SET trip_duration = TIME_TO_SEC(TIMEDIFF(p_ReturnTime, p_DispatchTime)) / 3600.0;

    -- Validate Driver has no more than 40 hours weekly
    SET driver_current_hours = fn_calculate_weekly_hours('DRIVER', p_DriverID, p_TripDate);
    IF (driver_current_hours + trip_duration) > 40.0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Roster Constraint Violation: Driver exceeds weekly limit of 40 hours.';
    END IF;

    -- Validate Assistant has no more than 60 hours weekly
    SET assistant_current_hours = fn_calculate_weekly_hours('ASSISTANT', p_AssistantID, p_TripDate);
    IF (assistant_current_hours + trip_duration) > 60.0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Roster Constraint Violation: Assistant exceeds weekly limit of 60 hours.';
    END IF;

DELIMITER ;

