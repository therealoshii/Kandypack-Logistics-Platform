-- Concurrency test for truck trips: two dispatchers booking the same driver at the same moment
-- Requirement: SRS Section 4.6.3 / REQ-1 (isolation) and Section 4.4 / REQ-6 (no overlapping bookings)
-- This is not part of the implementation. It shows that sp_lock_trip_resources makes the second
-- booking wait for the first, so the roster rules always see the other trip.
--
-- It needs TWO database sessions (two terminals), so it cannot run as one script.
-- Run the SETUP once, then start SESSION A and, within 10 seconds, run SESSION B.
-- The test date is Monday 2026-11-16, after the seed data.

-- =============================================================================
-- SETUP (either session)
-- =============================================================================
DELETE FROM TruckTrip WHERE TripDate = '2026-11-16';

-- =============================================================================
-- SESSION A: books Driver 9 for 08:00-11:00 and keeps its transaction open for 10 seconds.
-- These are the same steps sp_assign_truck_trip performs (lock, then insert).
-- Uncomment and run in the first terminal:
-- =============================================================================
-- START TRANSACTION;
-- CALL sp_lock_trip_resources(6, 9, 8);
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (6, 5, 9, 8, '2026-11-16', '08:00:00', '11:00:00');
-- SELECT SLEEP(10);
-- COMMIT;

-- =============================================================================
-- SESSION B: books the SAME driver for 09:00-12:00, with another truck and assistant.
-- EXPECTED: the call waits until Session A commits, then fails with
--           Error 45000 - Schedule Conflict: The Truck, Driver, or Assistant is already booked
--           for an overlapping time window.
-- Without the lock it would return at once and both trips would be saved.
-- Uncomment and run in the second terminal while Session A is sleeping:
-- =============================================================================
-- CALL sp_assign_truck_trip(7, 6, 9, 7, '2026-11-16', '09:00:00', '12:00:00', 'tester', @trip_id);

-- =============================================================================
-- CHECK (either session, after both have finished)
-- EXPECTED: one row, Driver 9 on 08:00-11:00
-- =============================================================================
SELECT TripID, TruckID, DriverID, AssistantID, DispatchTime, ReturnTime
FROM TruckTrip
WHERE TripDate = '2026-11-16';

-- Variations (change Session B only):
--   same truck (6) or same assistant (8) with other staff : waits, then Schedule Conflict
--   same driver at 13:00-16:00 (no overlap)               : waits, then succeeds
--   another truck, driver and assistant                    : does not wait, succeeds
--   Session A ends with ROLLBACK instead of COMMIT         : waits, then succeeds

-- Clean up
-- DELETE FROM TruckTrip WHERE TripDate = '2026-11-16';
