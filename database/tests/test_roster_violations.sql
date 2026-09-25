-- This file is purely for the purpose of testing the roster violations and constraints.
-- This is not included in actual implementation of the system

-- Before running this file, these should be run:
-- All 4 schemas -> all functions -> all procedures -> all views/indexes -> all triggers

-- Requirements:
--   - SRS Section 4.4 / REQ-2: Driver no two consecutive trips (30-min rest)
--   - SRS Section 4.4 / REQ-3: Assistant max two consecutive trips
--   - SRS Section 4.4 / REQ-4: Driver max 40 weekly hours
--   - SRS Section 4.4 / REQ-5: Assistant max 60 weekly hours
--   - SRS Section 4.4 / REQ-6: No schedule conflicts
-- Each negative scenario is commented out. Uncomment ONE AT A TIME to test.

-- Clean up any previous test runs
DELETE FROM TruckTrip WHERE TripDate BETWEEN '2026-10-05' AND '2026-10-10';

-- SETUP: Create base trips for testing

-- Base trip on 2026-10-05 (Monday) for Driver 1 & Assistant 1
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (1, 1, 1, 1, '2026-10-05', '08:00:00', '12:00:00');

-- Additional trips to push Driver 1 near 40-hour cap in the same week
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (2, 2, 1, 2, '2026-10-06', '08:00:00', '18:00:00');
-- Driver 1 now: 4h + 10h = 14h

INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (3, 1, 1, 3, '2026-10-07', '08:00:00', '18:00:00');
-- Driver 1 now: 14h + 10h = 24h

INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (1, 2, 1, 4, '2026-10-08', '08:00:00', '22:00:00');
-- Driver 1 now: 24h + 14h = 38h

-- =============================================================================
-- TEST CASE 1: Schedule Conflict (Overlapping time slots for Driver)
-- EXPECTED: Error 45000 - Schedule Conflict (SRS REQ-6)
-- Uncomment the line below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 2, 1, 2, '2026-10-05', '09:00:00', '14:00:00');

-- =============================================================================
-- TEST CASE 2: Driver Consecutive Trips Without Rest (back-to-back, < 30m rest)
-- EXPECTED: Error 45000 - Driver Roster Violation (SRS REQ-2)
-- Trip 1 ends at 12:00, next starts at 12:00 (zero gap)
-- Uncomment the line below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 2, 1, 2, '2026-10-05', '12:00:00', '16:00:00');

-- =============================================================================
-- TEST CASE 3: Driver Exceeding 40 Working Hours in a Week
-- EXPECTED: Error 45000 - Driver exceeds 40h weekly limit (SRS REQ-4)
-- Driver 1 has 38h. Adding 5h pushes to 43h (> 40h).
-- Uncomment the line below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 1, 1, 5, '2026-10-09', '07:00:00', '12:00:00');

-- =============================================================================
-- TEST CASE 4: Assistant Max 2 Consecutive Trips Violation
-- EXPECTED: Error 45000 - Assistant Roster Violation: Cannot schedule > 2 consecutive trips (SRS REQ-3)
-- Assistant 6 completes Trip A (08:00-11:00) and Trip B (11:00-14:00).
-- 3rd consecutive trip (14:00-17:00) must be blocked.
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (4, 3, 2, 6, '2026-10-09', '08:00:00', '11:00:00');
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (5, 4, 3, 6, '2026-10-09', '11:00:00', '14:00:00');
-- -- This 3rd consecutive trip will trigger error:
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (4, 3, 4, 6, '2026-10-09', '14:00:00', '17:00:00');

-- =============================================================================
-- TEST CASE 5: Valid Trip Assignment (Within all limits)
-- EXPECTED: SUCCESS (1 row inserted)
-- =============================================================================
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (2, 2, 2, 5, '2026-10-06', '08:00:00', '11:00:00');

-- Verify inserted test records
SELECT * FROM TruckTrip WHERE TripDate >= '2026-10-05' ORDER BY TripDate, DispatchTime;
