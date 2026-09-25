-- For the checks that needs to be done before a TruckTrip is inserted

-- Things checked:
--   1 - ReturnTime > DispatchTime (basic time sanity)
--   2 - Schedule conflict prevention (SRS 4.4 / REQ-6)
--   3 - Driver consecutive trip rule with 30-min rest buffer (SRS 4.4 / REQ-2)
--   4 - Assistant max 2 consecutive trips (SRS 4.4 / REQ-3)
--   5 - Driver 40h and Assistant 60h weekly caps (SRS 4.4 / REQ-4 & REQ-5)

DROP TRIGGER IF EXISTS trg_before_insert_trucktrip;

DELIMITER //

CREATE TRIGGER trg_before_insert_trucktrip
BEFORE INSERT ON TruckTrip -- checking before we insert a record
FOR EACH ROW

BEGIN
    -- declaring the variables
    DECLARE conflict_count INT DEFAULT 0;
    DECLARE driver_consecutive INT DEFAULT 0;
    DECLARE assistant_consecutive INT DEFAULT 0;
    DECLARE trip_duration DECIMAL(5,2);
    DECLARE driver_hours DECIMAL(5,2);
    DECLARE assistant_hours DECIMAL(5,2);

    -- 1.
    IF NEW.ReturnTime <= NEW.DispatchTime THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: ReturnTime must be strictly later than DispatchTime.';
    END IF;

    -- Calculate trip duration in decimal hours
    SET trip_duration = TIME_TO_SEC(TIMEDIFF(NEW.ReturnTime, NEW.DispatchTime)) / 3600.0;

    SELECT COUNT(*) INTO conflict_count
    FROM TruckTrip
    WHERE TripDate = NEW.TripDate
      -- check for overlapping trips for the same Truck, Driver, or Assistant
      AND (TruckID = NEW.TruckID OR DriverID = NEW.DriverID OR AssistantID = NEW.AssistantID)
      AND (NEW.DispatchTime < ReturnTime AND NEW.ReturnTime > DispatchTime);

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Schedule Conflict: The Truck, Driver, or Assistant is already booked for an overlapping time window.';
    END IF;

    -- 3.
    SELECT COUNT(*) INTO driver_consecutive
    FROM TruckTrip
    WHERE DriverID = NEW.DriverID
      AND TripDate = NEW.TripDate
      AND (
          -- Existing trip ends within 30 min before new trip starts
          (ReturnTime <= NEW.DispatchTime AND TIMEDIFF(NEW.DispatchTime, ReturnTime) < '00:30:00')
          OR
          -- New trip ends within 30 min before existing trip starts
          (NEW.ReturnTime <= DispatchTime AND TIMEDIFF(DispatchTime, NEW.ReturnTime) < '00:30:00')
      );
    
    IF driver_consecutive > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Consecutive Trip Violation: The Driver must have at least 30 minutes of rest between trips.';
    END IF;

    -- 4.
    SELECT COUNT(*) INTO assistant_consecutive
    FROM TruckTrip t1
    INNER JOIN TruckTrip t2 ON t1.AssistantID = t2.AssistantID
                           AND t1.TripDate = t2.TripDate
                           AND t1.ReturnTime = t2.DispatchTime
    WHERE t1.AssistantID = NEW.AssistantID
      AND t1.TripDate = NEW.TripDate
      AND (t2.ReturnTime <= NEW.DispatchTime AND TIMEDIFF(NEW.DispatchTime, t2.ReturnTime) < '00:30:00');

    IF assistant_consecutive > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Consecutive Trip Violation: The Assistant must have at least 30 minutes of rest between trips.';
    END IF;

    -- 5.1 for Driver's 40-hour weekly cap
    SET driver_hours = GetDriverWeeklyHours(NEW.DriverID, NEW.TripDate);
    IF (driver_hours + trip_duration) > 40.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver exceeds weekly limit of 40 working hours.';
    END IF;

    -- 5.2 for Assistant's 60-hour cap
    IF NEW.AssistantID IS NOT NULL THEN -- assistant is mandatory, but just in case, we check for NULL
        SET assistant_hours = GetAssistantWeeklyHours(NEW.AssistantID, NEW.TripDate);
        IF (assistant_hours + trip_duration) > 60.00 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Assistant exceeds weekly limit of 60 working hours.';
        END IF;
    END IF;
END //

DELIMITER ;