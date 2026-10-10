-- Rule: an Assistant can be scheduled for a maximum of two consecutive trips
-- Requirement: SRS Section 4.4 / REQ-3

-- NOTE: this is the original check, moved here unchanged (apart from the TripID filter) in task O2.
-- It only detects two trips that end and start at exactly the same minute.
-- Task O4 rewrites it to use the D1 definition (less than 30 minutes between trips).

-- Called by trg_before_insert_trucktrip and trg_before_update_trucktrip
-- p_SelfID is NULL on insert and the trip's own TripID on update

DROP PROCEDURE IF EXISTS sp_check_assistant_consecutive;

DELIMITER //

CREATE PROCEDURE sp_check_assistant_consecutive(IN p_SelfID INT, IN p_TruckID INT, IN p_RouteID INT,
                                                IN p_DriverID INT, IN p_AssistantID INT,
                                                IN p_Date DATE, IN p_Dispatch TIME, IN p_Return TIME)
BEGIN
    DECLARE assistant_consecutive INT DEFAULT 0;

    SELECT COUNT(*) INTO assistant_consecutive
    FROM TruckTrip t1
    INNER JOIN TruckTrip t2 ON t1.AssistantID = t2.AssistantID
                           AND t1.TripDate = t2.TripDate
                           AND t1.ReturnTime = t2.DispatchTime
    WHERE t1.AssistantID = p_AssistantID
      AND t1.TripDate = p_Date
      AND t1.TripID <> COALESCE(p_SelfID, 0)
      AND t2.TripID <> COALESCE(p_SelfID, 0)
      AND (t2.ReturnTime <= p_Dispatch AND TIMEDIFF(p_Dispatch, t2.ReturnTime) < '00:30:00');

    IF assistant_consecutive > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Consecutive Trip Violation: The Assistant must have at least 30 minutes of rest between trips.';
    END IF;
END //

DELIMITER ;