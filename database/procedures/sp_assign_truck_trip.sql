-- Dispatch Controller (SRS 4.4 / REQ-6)
-- Assigns trips to driver/assistant and logs audit. 
-- Validates weekly caps (Driver 40h, Assistant 60h) and conflicts via triggers; rolls back on error.

DROP PROCEDURE IF EXISTS sp_assign_truck_trip;

DELIMITER //

-- The "p_" means parameter
CREATE PROCEDURE sp_assign_truck_trip(IN p_TruckID INT, IN p_RouteID INT, IN p_DriverID INT, IN p_AssistantID INT, -- IN attributes
                                      IN p_TripDate DATE, IN p_DispatchTime TIME, IN p_ReturnTime TIME,
                                      IN p_ChangedBy VARCHAR(50), -- username of the staff member creating the trip
                                      OUT p_TripID INT) -- OUT attribute
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION -- If something fails during execution (including a roster rule)
        BEGIN
            ROLLBACK; -- Undo the changes that has been done
            RESIGNAL; -- Sends the error to the caller
        END;

    -- Insert new truck trip inside transaction
    START TRANSACTION;

    -- Lock the truck, driver and assistant first, so a second transaction booking any of them
    -- waits until this one commits and its rules then see this trip (isolation)
    CALL sp_lock_trip_resources(p_TruckID, p_DriverID, p_AssistantID);

    -- Adds the new scheduled trip to the TruckTrip (the trigger validates it first)
    INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
    VALUES (p_TruckID, p_RouteID, p_DriverID, p_AssistantID, p_TripDate, p_DispatchTime, p_ReturnTime);

    SET p_TripID = LAST_INSERT_ID(); -- Backend application or caller knows the ID of the created trip

    -- Creates an immutable trail in the AuditLog table
    INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
    VALUES ('TruckTrip', 'INSERT', p_TripID, COALESCE(p_ChangedBy, 'SYSTEM'),
            CONCAT('TruckTrip #', p_TripID, ' created with Truck #', p_TruckID, ', Driver #', p_DriverID, ', Assistant #', p_AssistantID));

    COMMIT; -- Permanently writes both inserts (TruckTrip and AuditLog)
END //

DELIMITER ;