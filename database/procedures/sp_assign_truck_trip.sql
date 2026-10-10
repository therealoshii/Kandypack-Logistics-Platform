-- This procedure assigns truck trips to Drivers and Assistants
-- Automated dispatch controller that saves a trip and its audit record together

-- Requirements:
--   - SRS Section 4.4: Driver 40h & Assistant 60h caps, consecutive trip rules
--   - SRS Section 4.4 / REQ-6: Schedule conflict validation

-- The roster rules are NOT repeated here. The BEFORE INSERT trigger on TruckTrip
-- (triggers/trg_before_insert_trucktrip.sql) runs every sp_check_* rule on the INSERT below.
-- If a rule fails, its error reaches the EXIT HANDLER, everything is rolled back,
-- and the rule's message is sent to the caller.

DROP PROCEDURE IF EXISTS sp_assign_truck_trip;

DELIMITER //

-- The "p_" means parameter
CREATE PROCEDURE sp_assign_truck_trip(IN p_TruckID INT, IN p_RouteID INT, IN p_DriverID INT, IN p_AssistantID INT, -- IN attributes
                                      IN p_TripDate DATE, IN p_DispatchTime TIME, IN p_ReturnTime TIME,
                                      OUT p_TripID INT) -- OUT attribute
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION -- If something fails during execution (including a roster rule)
        BEGIN
            ROLLBACK; -- Undo the changes that has been done
            RESIGNAL; -- Sends the error to the caller
        END;

    -- Insert new truck trip inside transaction
    START TRANSACTION;

    -- Adds the new scheduled trip to the TruckTrip (the trigger validates it first)
    INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
    VALUES (p_TruckID, p_RouteID, p_DriverID, p_AssistantID, p_TripDate, p_DispatchTime, p_ReturnTime);

    SET p_TripID = LAST_INSERT_ID(); -- Backend application or caller knows the ID of the created trip

    -- Creates an immutable trail in the AuditLog table
    INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
    VALUES ('TruckTrip', 'INSERT', p_TripID, 'FLEET_COORDINATOR',
            CONCAT('TruckTrip #', p_TripID, ' created with Truck #', p_TruckID, ', Driver #', p_DriverID, ', Assistant #', p_AssistantID));

    COMMIT; -- Permanently writes both inserts (TruckTrip and AuditLog)
END //

DELIMITER ;