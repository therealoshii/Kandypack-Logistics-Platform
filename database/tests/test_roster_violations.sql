-- This file is purely for the purpose of testing the roster violations and constraints.
-- This is not included in actual implementation of the system

-- Before running this file, the whole database should be deployed (run_all.sql)
-- The file runs from top to bottom without errors: the setup trips and the VALID cases are real inserts
-- Each negative scenario is commented out. Uncomment ONE AT A TIME to test, and check the error message.

-- Requirements:
--   - SRS Section 4.3.3 / REQ-1: Truck must be based at the route's store
--   - SRS Section 4.3.3 / REQ-2: Trip within the route's maximum delivery time
--   - SRS Section 4.3.3 / REQ-4: Delivery on the order's route and on the trip's date
--   - SRS Section 4.4 / REQ-2: Driver no two consecutive trips (30-min rest)
--   - SRS Section 4.4 / REQ-3: Assistant max two consecutive trips
--   - SRS Section 4.4 / REQ-4: Driver max 40 weekly hours
--   - SRS Section 4.4 / REQ-5: Assistant max 60 weekly hours
--   - SRS Section 4.4 / REQ-6: No schedule conflicts
--   - SRS Section 4.4 / REQ-7: The same rules when a trip is updated

-- All test trips are in the week of Monday 2026-11-02 to Sunday 2026-11-08, after the seed data.
-- Every setup trip obeys the rules: the truck is from the route's store and the trip is
-- within the route's MaxDeliveryTime
--   Colombo (store 1): trucks 1, 2, 3   | route 1 (3.5h), route 2 (4h)
--   Galle   (store 3): trucks 6, 7      | route 5 (4.5h), route 6 (5h)
--   Jaffna  (store 5): trucks 10, 11    | route 9 (7h),   route 10 (7.5h)

-- Clean up any previous test runs (deliveries first, because they reference the trips)
DELETE FROM Delivery
WHERE TripID IN (SELECT TripID FROM TruckTrip WHERE TripDate BETWEEN '2026-11-02' AND '2026-11-08');
DELETE FROM TruckTrip WHERE TripDate BETWEEN '2026-11-02' AND '2026-11-08';

-- =============================================================================
-- SETUP: Create base trips for testing
-- =============================================================================

-- Base trip on Monday for Driver 1 & Assistant 1
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (1, 1, 1, 1, '2026-11-02', '08:00:00', '11:30:00');

-- Driver 2 near the 40-hour cap: the long Jaffna route (7.5h) on Monday to Friday
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(10, 10, 2, 2, '2026-11-02', '08:00:00', '15:30:00'),
(10, 10, 2, 2, '2026-11-03', '08:00:00', '15:30:00'),
(10, 10, 2, 2, '2026-11-04', '08:00:00', '15:30:00'),
(10, 10, 2, 2, '2026-11-05', '08:00:00', '15:30:00'),
(10, 10, 2, 2, '2026-11-06', '08:00:00', '15:30:00');
-- Driver 2 now: 5 x 7.5h = 37.5h

-- Assistant 3 at the 60-hour cap: two Jaffna trips a day on Monday to Thursday
-- The two trips of a day are exactly 30 minutes apart, which counts as rested (not consecutive)
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(11, 10, 3, 3, '2026-11-02', '06:00:00', '13:30:00'),
(11, 10, 4, 3, '2026-11-02', '14:00:00', '21:30:00'),
(11, 10, 3, 3, '2026-11-03', '06:00:00', '13:30:00'),
(11, 10, 4, 3, '2026-11-03', '14:00:00', '21:30:00'),
(11, 10, 3, 3, '2026-11-04', '06:00:00', '13:30:00'),
(11, 10, 4, 3, '2026-11-04', '14:00:00', '21:30:00'),
(11, 10, 3, 3, '2026-11-05', '06:00:00', '13:30:00'),
(11, 10, 4, 3, '2026-11-05', '14:00:00', '21:30:00');
-- Assistant 3 now: 8 x 7.5h = 60h (Drivers 3 and 4: 30h each)

-- Assistant 9 on Tuesday: two trips in a row, 15 minutes apart (allowed, the limit is two)
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(1, 1, 6, 9, '2026-11-03', '06:00:00', '09:30:00'),
(2, 1, 7, 9, '2026-11-03', '09:45:00', '13:15:00');

-- Assistant 10 on Wednesday: a first and a third trip, with room for one in the middle
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(1, 1, 6, 10, '2026-11-04', '06:00:00', '09:30:00'),
(3, 1, 8, 10, '2026-11-04', '13:30:00', '17:00:00');

-- Driver 10 on Friday: a morning and an afternoon trip in Galle (used by the UPDATE and Delivery tests)
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(6, 5, 10, 6, '2026-11-06', '08:00:00', '12:00:00'),
(7, 6, 10, 7, '2026-11-06', '13:00:00', '17:00:00');

-- =============================================================================
-- TEST CASE 1: Schedule Conflict (Overlapping time slots for Driver)
-- EXPECTED: Error 45000 - Schedule Conflict: The Truck, Driver, or Assistant is already booked
--           for an overlapping time window. (SRS REQ-6)
-- Driver 1 is on a trip 08:00-11:30 on Monday. This one is 09:00-12:00.
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 2, 1, 4, '2026-11-02', '09:00:00', '12:00:00');

-- =============================================================================
-- TEST CASE 2: Driver Consecutive Trips Without Rest (< 30m rest)
-- EXPECTED: Error 45000 - Consecutive Trip Violation: The Driver must have at least 30 minutes
--           of rest between trips. (SRS REQ-2)
-- Driver 1's trip ends at 11:30, this one starts at 11:45 (15-minute gap)
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 1, 1, 4, '2026-11-02', '11:45:00', '15:15:00');

-- VALID: the same trip starting at 12:00, exactly 30 minutes after the previous one ends
-- EXPECTED: SUCCESS (1 row inserted)
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (2, 1, 1, 4, '2026-11-02', '12:00:00', '15:30:00');

-- =============================================================================
-- TEST CASE 3: Driver Exceeding 40 Working Hours in a Week
-- EXPECTED: Error 45000 - Driver exceeds weekly limit of 40 working hours. (SRS REQ-4)
-- Driver 2 has 37.5h. Adding 3h pushes to 40.5h (> 40h).
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (10, 9, 2, 5, '2026-11-07', '08:00:00', '11:00:00');

-- VALID: a 2.5h trip brings Driver 2 to exactly 40h, which is still within the limit
-- EXPECTED: SUCCESS (1 row inserted)
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (10, 9, 2, 5, '2026-11-07', '08:00:00', '10:30:00');

-- =============================================================================
-- TEST CASE 4: Assistant Exceeding 60 Working Hours in a Week
-- EXPECTED: Error 45000 - Assistant exceeds weekly limit of 60 working hours. (SRS REQ-5)
-- Assistant 3 has 60h. Adding 2h pushes to 62h (> 60h).
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (11, 9, 5, 3, '2026-11-06', '08:00:00', '10:00:00');

-- =============================================================================
-- TEST CASE 5: Assistant Max 2 Consecutive Trips Violation (new trip is the 3rd in a row)
-- EXPECTED: Error 45000 - Consecutive Trip Violation: The Assistant cannot work more than
--           2 consecutive trips without a 30-minute rest. (SRS REQ-3)
-- Assistant 9 has 06:00-09:30 and 09:45-13:15 on Tuesday. A 3rd trip at 13:30 (15-minute gap) must be blocked.
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (3, 1, 8, 9, '2026-11-03', '13:30:00', '17:00:00');

-- =============================================================================
-- TEST CASE 6: Assistant Max 2 Consecutive Trips Violation (new trip joins two trips into a run of 3)
-- EXPECTED: Error 45000 - Consecutive Trip Violation: The Assistant cannot work more than
--           2 consecutive trips without a 30-minute rest. (SRS REQ-3)
-- Assistant 10 has 06:00-09:30 and 13:30-17:00 on Wednesday. A trip 09:45-13:15 in the middle must be blocked.
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 1, 7, 10, '2026-11-04', '09:45:00', '13:15:00');

-- =============================================================================
-- TEST CASE 7: Truck From Another Store
-- EXPECTED: Error 45000 - Route Violation: The Truck is based at a different store from this route.
--           (SRS 4.3.3 REQ-1)
-- Truck 10 is based in Jaffna, route 1 starts from Colombo
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (10, 1, 9, 5, '2026-11-05', '08:00:00', '11:00:00');

-- =============================================================================
-- TEST CASE 8: Trip Longer Than the Route's Maximum Delivery Time
-- EXPECTED: Error 45000 - Route Violation: The trip is longer than the route's maximum delivery time.
--           (SRS 4.3.3 REQ-2)
-- Route 1 allows 3.5h, this trip is 12h
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (1, 1, 9, 5, '2026-11-05', '06:00:00', '18:00:00');

-- =============================================================================
-- TEST CASE 9: UPDATE of a Valid Trip Into an Overlap
-- EXPECTED: Error 45000 - Schedule Conflict: The Truck, Driver, or Assistant is already booked
--           for an overlapping time window. (SRS REQ-7)
-- Driver 10 has 08:00-12:00 and 13:00-17:00 on Friday. Moving the afternoon trip to 11:00-15:00 overlaps the morning one.
-- Uncomment the lines below to test:
-- =============================================================================
-- UPDATE TruckTrip SET DispatchTime = '11:00:00', ReturnTime = '15:00:00'
-- WHERE DriverID = 10 AND TripDate = '2026-11-06' AND DispatchTime = '13:00:00';

-- VALID: the afternoon trip returns 5 minutes later. No other trip is affected,
-- and the trip is not compared against its own old row
-- EXPECTED: SUCCESS (1 row changed)
UPDATE TruckTrip SET ReturnTime = '17:05:00'
WHERE DriverID = 10 AND TripDate = '2026-11-06' AND DispatchTime = '13:00:00';

-- =============================================================================
-- DELIVERY TESTS (need triggers/trg_validate_delivery.sql to be loaded)
-- The trip used here is Driver 10's Friday morning trip on route 5 (Galle)
-- =============================================================================
SET @trip_route5  = (SELECT TripID FROM TruckTrip
                     WHERE DriverID = 10 AND TripDate = '2026-11-06' AND DispatchTime = '08:00:00');
SET @order_other  = (SELECT MIN(OrderID) FROM Orders WHERE RouteID <> 5); -- an order on another route
SET @order_route5 = (SELECT MIN(OrderID) FROM Orders WHERE RouteID = 5);  -- an order on route 5

-- =============================================================================
-- TEST CASE 10: Delivery on a Trip for a Different Route
-- EXPECTED: Error 45000 - Delivery Violation: The truck trip is on a different route from the order.
--           (SRS 4.3.3 REQ-4)
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO Delivery (OrderID, TripID, DeliveryDate, Status)
-- VALUES (@order_other, @trip_route5, '2026-11-06', 'Scheduled');

-- =============================================================================
-- TEST CASE 11: Delivery Dated Differently From Its Trip
-- EXPECTED: Error 45000 - Delivery Violation: The delivery date must match the truck trip date.
--           (SRS 4.3.3 REQ-4)
-- The trip is on 2026-11-06, the delivery says 2026-11-07
-- Uncomment the lines below to test:
-- =============================================================================
-- INSERT INTO Delivery (OrderID, TripID, DeliveryDate, Status)
-- VALUES (@order_route5, @trip_route5, '2026-11-07', 'Scheduled');

-- Verify inserted test records
SELECT * FROM TruckTrip WHERE TripDate BETWEEN '2026-11-02' AND '2026-11-08' ORDER BY TripDate, DispatchTime;

-- Weekly hours of the staff used in the limit tests (Driver 2: 40.00, Assistant 3: 60.00)
SELECT 'Driver 2' AS Staff, SUM(TIME_TO_SEC(TIMEDIFF(ReturnTime, DispatchTime))) / 3600 AS WeeklyHours
FROM TruckTrip WHERE DriverID = 2 AND TripDate BETWEEN '2026-11-02' AND '2026-11-08'
UNION ALL
SELECT 'Assistant 3', SUM(TIME_TO_SEC(TIMEDIFF(ReturnTime, DispatchTime))) / 3600
FROM TruckTrip WHERE AssistantID = 3 AND TripDate BETWEEN '2026-11-02' AND '2026-11-08';