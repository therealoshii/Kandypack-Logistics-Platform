-- Assistant Trip Limit (SRS 4.4 / REQ-3)
-- Max 2 consecutive trips (trips with <30 min gap are linked; >=30 min = rested).
-- Rejects runs of 3: (prev2 + prev1), (prev1 + next1), or (next1 + next2).
-- Pass p_SelfID = NULL on INSERT, or TripID on UPDATE to ignore current row.

DROP PROCEDURE IF EXISTS sp_check_assistant_consecutive;

DELIMITER //

CREATE PROCEDURE sp_check_assistant_consecutive(IN p_SelfID INT, IN p_TruckID INT, IN p_RouteID INT,
                                                IN p_DriverID INT, IN p_AssistantID INT,
                                                IN p_Date DATE, IN p_Dispatch TIME, IN p_Return TIME)
BEGIN
    DECLARE v_rest_gap TIME DEFAULT '00:30:00';
    DECLARE v_self INT;
    DECLARE v_prev1 INT DEFAULT NULL;
    DECLARE v_prev1_start TIME DEFAULT NULL;
    DECLARE v_prev2 INT DEFAULT NULL;
    DECLARE v_next1 INT DEFAULT NULL;
    DECLARE v_next1_end TIME DEFAULT NULL;
    DECLARE v_next2 INT DEFAULT NULL;

    SET v_self = COALESCE(p_SelfID, 0);

    -- prev1: the assistant's trip that returns less than 30 min before the new trip is dispatched
    SELECT TripID, DispatchTime INTO v_prev1, v_prev1_start
    FROM TruckTrip
    WHERE AssistantID = p_AssistantID
      AND TripDate = p_Date
      AND TripID <> v_self
      AND ReturnTime <= p_Dispatch
      AND TIMEDIFF(p_Dispatch, ReturnTime) < v_rest_gap
    ORDER BY ReturnTime DESC
    LIMIT 1;

    -- prev2: the trip that returns less than 30 min before prev1 is dispatched
    IF v_prev1 IS NOT NULL THEN
        SELECT TripID INTO v_prev2
        FROM TruckTrip
        WHERE AssistantID = p_AssistantID
          AND TripDate = p_Date
          AND TripID NOT IN (v_self, v_prev1)
          AND ReturnTime <= v_prev1_start
          AND TIMEDIFF(v_prev1_start, ReturnTime) < v_rest_gap
        ORDER BY ReturnTime DESC
        LIMIT 1;
    END IF;

    -- next1: the trip dispatched less than 30 min after the new trip returns
    SELECT TripID, ReturnTime INTO v_next1, v_next1_end
    FROM TruckTrip
    WHERE AssistantID = p_AssistantID
      AND TripDate = p_Date
      AND TripID <> v_self
      AND DispatchTime >= p_Return
      AND TIMEDIFF(DispatchTime, p_Return) < v_rest_gap
    ORDER BY DispatchTime ASC
    LIMIT 1;

    -- next2: the trip dispatched less than 30 min after next1 returns
    IF v_next1 IS NOT NULL THEN
        SELECT TripID INTO v_next2
        FROM TruckTrip
        WHERE AssistantID = p_AssistantID
          AND TripDate = p_Date
          AND TripID NOT IN (v_self, v_next1)
          AND DispatchTime >= v_next1_end
          AND TIMEDIFF(DispatchTime, v_next1_end) < v_rest_gap
        ORDER BY DispatchTime ASC
        LIMIT 1;
    END IF;

    IF (v_prev1 IS NOT NULL AND v_prev2 IS NOT NULL)      -- new trip would be the 3rd in a row
       OR (v_prev1 IS NOT NULL AND v_next1 IS NOT NULL)   -- new trip would join two trips into a run of 3
       OR (v_next1 IS NOT NULL AND v_next2 IS NOT NULL)   -- new trip would be the 1st of 3
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Consecutive Trip Violation: The Assistant cannot work more than 2 consecutive trips without a 30-minute rest.';
    END IF;
END //

DELIMITER ;