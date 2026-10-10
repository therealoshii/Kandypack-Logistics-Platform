
-- ============================================================================
-- Kandypack Seed Integrity Verification (Task A6)
-- MySQL 8.0
--
-- Every integrity check must report 0 violations.
-- Minimum-data checks must also report 0 (meaning the minimum is satisfied).
-- ============================================================================

USE kandypack_db;

-- 1. Shipments must reference an existing train schedule.
SELECT
    '1. Shipments without a valid train schedule' AS check_name,
    COUNT(*) AS violations
FROM Shipment s
LEFT JOIN TrainSchedule ts ON ts.ScheduleID = s.ScheduleID
WHERE ts.ScheduleID IS NULL

UNION ALL

-- 2. The train must actually operate on the shipment weekday.
SELECT
    '2. Shipments on a day the train does not run',
    COUNT(*)
FROM Shipment s
JOIN TrainSchedule ts ON ts.ScheduleID = s.ScheduleID
WHERE DAYNAME(s.ShipmentDate) <> ts.DayOfWeek

UNION ALL

-- 3. Orders with a requested delivery date must have at least 7 days' lead time.
SELECT
    '3. Orders with less than 7 days lead time',
    COUNT(*)
FROM Orders
WHERE RequestedDeliveryDate IS NOT NULL
  AND DATEDIFF(RequestedDeliveryDate, OrderDate) < 7

UNION ALL

-- 4. Deliveries must not occur before the order date and must respect lead time.
SELECT
    '4. Deliveries before order date or with less than 7 days lead time',
    COUNT(*)
FROM Delivery d
JOIN Orders o ON o.OrderID = d.OrderID
WHERE d.DeliveryDate < o.OrderDate
   OR DATEDIFF(d.DeliveryDate, o.OrderDate) < 7

UNION ALL

-- 5. Each delivery trip must be on the same route as its order.
SELECT
    '5. Deliveries assigned to a trip on a different route',
    COUNT(*)
FROM Delivery d
JOIN Orders o ON o.OrderID = d.OrderID
JOIN TruckTrip tt ON tt.TripID = d.TripID
WHERE tt.RouteID <> o.RouteID

UNION ALL

-- 6. Delivery date must match the assigned truck trip date.
SELECT
    '6. Delivery date does not match truck trip date',
    COUNT(*)
FROM Delivery d
JOIN TruckTrip tt ON tt.TripID = d.TripID
WHERE d.DeliveryDate <> tt.TripDate

UNION ALL

-- 7. Order-detail line total must equal quantity multiplied by unit price.
SELECT
    '7. Order detail line totals are incorrect',
    COUNT(*)
FROM OrderDetail od
JOIN Product p ON p.ProductID = od.ProductID
WHERE ABS(od.LineTotal - (od.Quantity * p.UnitPrice)) > 0.01

UNION ALL

-- 8. Order total must equal the sum of its order-detail lines.
SELECT
    '8. Order totals do not match order detail totals',
    COUNT(*)
FROM Orders o
JOIN (
    SELECT OrderID, SUM(LineTotal) AS ActualTotal
    FROM OrderDetail
    GROUP BY OrderID
) x ON x.OrderID = o.OrderID
WHERE ABS(o.TotalAmount - x.ActualTotal) > 0.01

UNION ALL

-- 9. An order's route must match its customer's delivery area route.
SELECT
    '9. Orders assigned to the wrong customer delivery-area route',
    COUNT(*)
FROM Orders o
JOIN Customer c ON c.CustomerID = o.CustomerID
JOIN DeliveryArea da ON da.AreaID = c.AreaID
WHERE o.RouteID <> da.RouteID

UNION ALL

-- 10. A truck must belong to the store serving its route.
SELECT
    '10. Truck trips using a truck from the wrong store',
    COUNT(*)
FROM TruckTrip tt
JOIN Truck t ON t.TruckID = tt.TruckID
JOIN Route r ON r.RouteID = tt.RouteID
WHERE t.StoreID <> r.StoreID

UNION ALL

-- 11. Trip duration must not exceed the route maximum.
-- TIME_TO_SEC handles the duration in seconds.
SELECT
    '11. Truck trips longer than route maximum delivery time',
    COUNT(*)
FROM TruckTrip tt
JOIN Route r ON r.RouteID = tt.RouteID
WHERE TIME_TO_SEC(
          TIMEDIFF(tt.ReturnTime, tt.DispatchTime)
      ) / 3600 > r.MaxDeliveryTime

UNION ALL

-- 12. Every non-Placed, non-Cancelled order should have a delivery.
SELECT
    '12. Processing-or-later orders without a delivery',
    COUNT(*)
FROM Orders o
LEFT JOIN Delivery d ON d.OrderID = o.OrderID
WHERE o.Status IN ('Processing', 'Shipped', 'In Transit', 'Delivered')
  AND d.DeliveryID IS NULL

UNION ALL

-- 13. Placed orders must not already have deliveries.
SELECT
    '13. Placed orders with deliveries',
    COUNT(*)
FROM Orders o
JOIN Delivery d ON d.OrderID = o.OrderID
WHERE o.Status = 'Placed'

UNION ALL

-- 14. Placed orders must not already have truck trips assigned through deliveries.
SELECT
    '14. Placed orders with assigned truck trips',
    COUNT(*)
FROM Orders o
JOIN Delivery d ON d.OrderID = o.OrderID
JOIN TruckTrip tt ON tt.TripID = d.TripID
WHERE o.Status = 'Placed'

UNION ALL

-- 15. Seed must contain at least 40 orders.
SELECT
    '15. Minimum order count of 40 not met',
    GREATEST(40 - COUNT(*), 0)
FROM Orders

UNION ALL

-- 16. Seed must use at least 10 distinct routes.
SELECT
    '16. Minimum of 10 distinct order routes not met',
    GREATEST(10 - COUNT(DISTINCT RouteID), 0)
FROM Orders

UNION ALL

-- 17. Train schedules must cover at least 6 destination cities.
SELECT
    '17. Train schedules cover fewer than 6 cities',
    GREATEST(
        6 - (
            SELECT COUNT(DISTINCT st.City)
            FROM TrainSchedule ts
            JOIN Store st ON st.StoreID = ts.StoreID
        ),
        0
    )
FROM TrainSchedule
LIMIT 1;
