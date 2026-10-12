-- Isolation for the truck trip rules (SRS Section 4.6.3 / REQ-1, ACID)
-- The sp_check_* rules read the other trips of a truck, driver and assistant and then let the
-- new trip in. Without a lock, two dispatchers saving at the same moment could each read
-- "no conflict" and both be saved: the same driver on two overlapping trips.
-- This procedure locks the Truck, Driver and Assistant rows of the trip being saved. A second
-- transaction that wants any of the same three waits here until the first one commits, and its
-- rules then see the first trip.
-- The locks are always taken in the same order (truck, driver, assistant), so two transactions
-- can never wait for each other in a circle. They are released at COMMIT or ROLLBACK.
-- Called inside the transaction, BEFORE the trip is written:
--   - by sp_assign_truck_trip, before its INSERT (creating a trip)
--   - by the backend (TruckTripService.updateTrip), before its UPDATE (changing a trip)
-- It is a separate statement and not part of the TruckTrip triggers, because MySQL does not
-- allow a trigger to lock a table that the statement which fired it also reads (error 1442),
-- and the seed inserts trips with a statement that reads Truck.
-- A truck, driver or assistant that does not exist locks nothing; sp_check_trip_route and the
-- foreign keys report that.

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
