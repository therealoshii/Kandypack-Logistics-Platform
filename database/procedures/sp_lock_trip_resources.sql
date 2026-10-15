-- RULE: Resource isolation & locking for truck trips (SRS 4.6.3 / REQ-1)
-- Acquires row locks in order (Truck -> Driver -> Assistant) to prevent race conditions and deadlocks.
-- Called before trip INSERT (sp_assign_truck_trip) or UPDATE (TruckTripService).
-- Kept outside triggers to prevent MySQL Error 1442; locks release on COMMIT/ROLLBACK.

DROP PROCEDURE IF EXISTS sp_lock_trip_resources;

DELIMITER //

CREATE PROCEDURE sp_lock_trip_resources(IN p_TruckID INT, IN p_DriverID INT, IN p_AssistantID INT)
BEGIN
    DECLARE v_locked INT;

    SELECT TruckID INTO v_locked
    FROM Truck
    WHERE TruckID = p_TruckID
    FOR UPDATE;

    SELECT DriverID INTO v_locked
    FROM Driver
    WHERE DriverID = p_DriverID
    FOR UPDATE;

    SELECT AssistantID INTO v_locked
    FROM Assistant
    WHERE AssistantID = p_AssistantID
    FOR UPDATE;
END //

DELIMITER ;
