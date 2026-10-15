-- RULE: Drivers cannot take consecutive trips (SRS 4.4 / REQ-2)
-- Trips are consecutive if the gap is < 30 mins (>= 30 mins counts as rested).
-- Called by trg_before_insert/update_trucktrip (pass p_SelfID to ignore self on update).

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