-- Rule: the same Truck, Driver or Assistant cannot be booked on two trips with overlapping times
-- (runs after sp_check_trip_route, which has already checked ReturnTime > DispatchTime)
-- Requirement: SRS Section 4.4 / REQ-6

-- Called by trg_before_insert_trucktrip and trg_before_update_trucktrip (see triggers/trg_before_insert_trucktrip.sql)
-- p_SelfID is NULL on insert and the trip's own TripID on update,
-- so an updated trip is not compared against its own old row

DROP PROCEDURE IF EXISTS sp_check_schedule_conflict;

DELIMITER //

CREATE PROCEDURE sp_check_schedule_conflict(IN p_SelfID INT, IN p_TruckID INT, IN p_RouteID INT,
                                            IN p_DriverID INT, IN p_AssistantID INT,
                                            IN p_Date DATE, IN p_Dispatch TIME, IN p_Return TIME)
BEGIN
    DECLARE conflict_count INT DEFAULT 0;

    -- ReturnTime > DispatchTime is checked first, in sp_check_trip_route

    -- Any other trip on the same day that shares the truck, driver or assistant and overlaps in time
    SELECT COUNT(*) INTO conflict_count
    FROM TruckTrip
    WHERE TripDate = p_Date
      AND TripID <> COALESCE(p_SelfID, 0)
      AND (TruckID = p_TruckID OR DriverID = p_DriverID OR AssistantID = p_AssistantID)
      AND (p_Dispatch < ReturnTime AND p_Return > DispatchTime);

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Schedule Conflict: The Truck, Driver, or Assistant is already booked for an overlapping time window.';
    END IF;
END //

DELIMITER ;