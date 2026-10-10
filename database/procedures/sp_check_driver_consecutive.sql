-- Rule: a Driver must not be scheduled for two consecutive truck trips
-- Requirement: SRS Section 4.4 / REQ-2

-- Decision D1: two trips are consecutive if the next one starts less than 30 minutes
-- after the previous one returns (exactly 30 minutes counts as rested)

-- Called by trg_before_insert_trucktrip and trg_before_update_trucktrip
-- p_SelfID is NULL on insert and the trip's own TripID on update

DROP PROCEDURE IF EXISTS sp_check_driver_consecutive;

DELIMITER //

CREATE PROCEDURE sp_check_driver_consecutive(IN p_SelfID INT, IN p_TruckID INT, IN p_RouteID INT,
                                             IN p_DriverID INT, IN p_AssistantID INT,
                                             IN p_Date DATE, IN p_Dispatch TIME, IN p_Return TIME)
BEGIN
    DECLARE v_rest_gap TIME DEFAULT '00:30:00';
    DECLARE driver_consecutive INT DEFAULT 0;

    SELECT COUNT(*) INTO driver_consecutive
    FROM TruckTrip
    WHERE DriverID = p_DriverID
      AND TripDate = p_Date
      AND TripID <> COALESCE(p_SelfID, 0)
      AND (
          -- An existing trip ends less than 30 min before the new trip starts
          (ReturnTime <= p_Dispatch AND TIMEDIFF(p_Dispatch, ReturnTime) < v_rest_gap)
          OR
          -- The new trip ends less than 30 min before an existing trip starts
          (p_Return <= DispatchTime AND TIMEDIFF(DispatchTime, p_Return) < v_rest_gap)
      );

    IF driver_consecutive > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Consecutive Trip Violation: The Driver must have at least 30 minutes of rest between trips.';
    END IF;
END //

DELIMITER ;