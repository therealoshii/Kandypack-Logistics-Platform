-- Tests roster/scheduling constraints. Uncomment negative cases one at a time to verify errors.
-- Requires run_all.sql first. Test week: 2026-11-02 to 2026-11-08.

DELETE FROM Delivery
WHERE TripID IN (SELECT TripID FROM TruckTrip WHERE TripDate BETWEEN '2026-11-02' AND '2026-11-08');
DELETE FROM TruckTrip WHERE TripDate BETWEEN '2026-11-02' AND '2026-11-08';

-- SETUP: base trips

-- Driver 1 & Assistant 1, Monday morning
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (1, 1, 1, 1, '2026-11-02', '08:00:00', '11:30:00');

-- Driver 2: 5 x 7.5h = 37.5h (near 40h cap)
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(10, 10, 2, 2, '2026-11-02', '08:00:00', '15:30:00'),
(10, 10, 2, 2, '2026-11-03', '08:00:00', '15:30:00'),
(10, 10, 2, 2, '2026-11-04', '08:00:00', '15:30:00'),
(10, 10, 2, 2, '2026-11-05', '08:00:00', '15:30:00'),
(10, 10, 2, 2, '2026-11-06', '08:00:00', '15:30:00');

-- Assistant 3: 8 x 7.5h = 60h (at 60h cap). 30-min gaps between daily pairs = not consecutive.
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(11, 10, 3, 3, '2026-11-02', '06:00:00', '13:30:00'),
(11, 10, 4, 3, '2026-11-02', '14:00:00', '21:30:00'),
(11, 10, 3, 3, '2026-11-03', '06:00:00', '13:30:00'),
(11, 10, 4, 3, '2026-11-03', '14:00:00', '21:30:00'),
(11, 10, 3, 3, '2026-11-04', '06:00:00', '13:30:00'),
(11, 10, 4, 3, '2026-11-04', '14:00:00', '21:30:00'),
(11, 10, 3, 3, '2026-11-05', '06:00:00', '13:30:00'),
(11, 10, 4, 3, '2026-11-05', '14:00:00', '21:30:00');

-- Assistant 9, Tuesday: two back-to-back trips (15-min gap, allowed max is 2)
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(1, 1, 6, 9, '2026-11-03', '06:00:00', '09:30:00'),
(2, 1, 7, 9, '2026-11-03', '09:45:00', '13:15:00');

-- Assistant 10, Wednesday: first and third trip with a gap for a middle one
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(1, 1, 6, 10, '2026-11-04', '06:00:00', '09:30:00'),
(3, 1, 8, 10, '2026-11-04', '13:30:00', '17:00:00');

-- Driver 10, Friday: morning and afternoon in Galle (used by UPDATE and Delivery tests)
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(6, 5, 10, 6, '2026-11-06', '08:00:00', '12:00:00'),
(7, 6, 10, 7, '2026-11-06', '13:00:00', '17:00:00');

-- TEST 1: Schedule conflict – Driver 1 overlaps 08:00-11:30 (REQ-6)
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 2, 1, 4, '2026-11-02', '09:00:00', '12:00:00');

-- TEST 2: Driver consecutive trips without 30-min rest – 15-min gap after 11:30 (REQ-2)
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 1, 1, 4, '2026-11-02', '11:45:00', '15:15:00');

-- VALID: exactly 30-min gap after 11:30
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (2, 1, 1, 4, '2026-11-02', '12:00:00', '15:30:00');

-- TEST 3: Driver exceeds 40h weekly – 37.5h + 3h = 40.5h (REQ-4)
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (10, 9, 2, 5, '2026-11-07', '08:00:00', '11:00:00');

-- VALID: 2.5h brings Driver 2 to exactly 40h
INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
VALUES (10, 9, 2, 5, '2026-11-07', '08:00:00', '10:30:00');

-- TEST 4: Assistant exceeds 60h weekly – Assistant 3 already at 60h (REQ-5)
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (11, 9, 5, 3, '2026-11-06', '08:00:00', '10:00:00');

-- TEST 5: Assistant 3rd consecutive trip – Assistant 9 already has 2 back-to-back (REQ-3)
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (3, 1, 8, 9, '2026-11-03', '13:30:00', '17:00:00');

-- TEST 6: Middle trip joins two into a run of 3 – Assistant 10 (REQ-3)
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (2, 1, 7, 10, '2026-11-04', '09:45:00', '13:15:00');

-- TEST 7: Truck from wrong store – Truck 10 (Jaffna) on route 1 (Colombo) (REQ-1)
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (10, 1, 9, 5, '2026-11-05', '08:00:00', '11:00:00');

-- TEST 8: Trip exceeds route max delivery time – route 1 allows 3.5h, trip is 12h (REQ-2)
-- INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
-- VALUES (1, 1, 9, 5, '2026-11-05', '06:00:00', '18:00:00');

-- TEST 9: UPDATE creates overlap – move afternoon to overlap morning (REQ-7)
-- UPDATE TruckTrip SET DispatchTime = '11:00:00', ReturnTime = '15:00:00'
-- WHERE DriverID = 10 AND TripDate = '2026-11-06' AND DispatchTime = '13:00:00';

-- VALID: extend afternoon return by 5 min, no conflict
UPDATE TruckTrip SET ReturnTime = '17:05:00'
WHERE DriverID = 10 AND TripDate = '2026-11-06' AND DispatchTime = '13:00:00';

-- DELIVERY TESTS (require trg_validate_delivery.sql)
SET @trip_route5  = (SELECT TripID FROM TruckTrip
                     WHERE DriverID = 10 AND TripDate = '2026-11-06' AND DispatchTime = '08:00:00');
SET @order_other  = (SELECT MIN(OrderID) FROM Orders WHERE RouteID <> 5);
SET @order_route5 = (SELECT MIN(OrderID) FROM Orders WHERE RouteID = 5);

-- TEST 10: Delivery on wrong route (REQ-4)
-- INSERT INTO Delivery (OrderID, TripID, DeliveryDate, Status)
-- VALUES (@order_other, @trip_route5, '2026-11-06', 'Scheduled');

-- TEST 11: Delivery date doesn't match trip date (REQ-4)
-- INSERT INTO Delivery (OrderID, TripID, DeliveryDate, Status)
-- VALUES (@order_route5, @trip_route5, '2026-11-07', 'Scheduled');

SELECT * FROM TruckTrip WHERE TripDate BETWEEN '2026-11-02' AND '2026-11-08' ORDER BY TripDate, DispatchTime;

SELECT 'Driver 2' AS Staff, SUM(TIME_TO_SEC(TIMEDIFF(ReturnTime, DispatchTime))) / 3600 AS WeeklyHours
FROM TruckTrip WHERE DriverID = 2 AND TripDate BETWEEN '2026-11-02' AND '2026-11-08'
UNION ALL
SELECT 'Assistant 3', SUM(TIME_TO_SEC(TIMEDIFF(ReturnTime, DispatchTime))) / 3600
FROM TruckTrip WHERE AssistantID = 3 AND TripDate BETWEEN '2026-11-02' AND '2026-11-08';