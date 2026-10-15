-- Concurrency test: two dispatchers booking the same driver simultaneously.
-- Needs TWO terminals. Run SETUP once, then SESSION A, then SESSION B within 10 seconds.
-- Test date: Monday 2026-11-16.

-- SETUP (either session)
DELETE FROM TruckTrip WHERE TripDate = '2026-11-16';

-- SESSION A: books Driver 9 for 08:00-11:00, holds transaction open 10s.
-- Run in first terminal:
-- START TRANSACTION;
-- CALL sp_lock_trip_resources(6, 9, 8);
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (6, 5, 9, 8, '2026-11-16', '08:00:00', '11:00:00');
-- SELECT SLEEP(10);
-- COMMIT;

-- SESSION B: books same driver, overlapping time. Should wait then fail with Schedule Conflict.
-- Run in second terminal while Session A sleeps:
-- CALL sp_assign_truck_trip(7, 6, 9, 7, '2026-11-16', '09:00:00', '12:00:00', 'tester', @trip_id);

-- CHECK (after both sessions finish) – expect one row: Driver 9 on 08:00-11:00
SELECT TripID, TruckID, DriverID, AssistantID, DispatchTime, ReturnTime
FROM TruckTrip
WHERE TripDate = '2026-11-16';

-- Variations (change Session B only):
--   same truck/assistant with other staff  : waits, then Schedule Conflict
--   same driver at 13:00-16:00 (no overlap): waits, then succeeds
--   different truck, driver, assistant     : does not wait, succeeds
--   Session A ROLLBACKs instead of COMMIT  : waits, then succeeds

-- DELETE FROM TruckTrip WHERE TripDate = '2026-11-16';
