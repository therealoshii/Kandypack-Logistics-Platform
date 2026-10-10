
USE kandypack_db;

-- ============================================================================
-- A6: Seed integrity checks
-- Expected result: 17 rows, with bad = 0 for every check.
-- ============================================================================

SELECT '01 - shipments without a valid train schedule' AS check_name,
       COUNT(*) AS bad
FROM Shipment s
LEFT JOIN TrainSchedule ts ON ts.ScheduleID = s.ScheduleID
WHERE ts.ScheduleID IS NULL

UNION ALL

SELECT '02 - shipments on a day the train does not run',
       COUNT(*)
FROM Shipment s
JOIN TrainSchedule ts ON ts.ScheduleID = s.ScheduleID
WHERE DAYNAME(s.ShipmentDate) <> ts.DayOfWeek

UNION ALL

SELECT '03 - orders with less than 7 days lead time',
       COUNT(*)
FROM Orders o
WHERE DATEDIFF(o.RequestedDeliveryDate, o.OrderDate) < 7

UNION ALL

SELECT '04 - deliveries less than 7 days after order date',
       COUNT(*)
FROM Delivery d
JOIN Orders o ON o.OrderID = d.OrderID
WHERE DATEDIFF(d.DeliveryDate, o.OrderDate) < 7

UNION ALL

SELECT '05 - order line totals do not equal quantity times unit price',
       COUNT(*)
FROM OrderDetail od
JOIN Product p ON p.ProductID = od.ProductID
WHERE od.LineTotal <> od.Quantity * p.UnitPrice

UNION ALL

SELECT '06 - order totals do not equal sum of order lines',
       COUNT(*)
FROM Orders o
JOIN (
    SELECT OrderID, SUM(LineTotal) AS calculated_total
    FROM OrderDetail
    GROUP BY OrderID
) totals ON totals.OrderID = o.OrderID
WHERE o.TotalAmount <> totals.calculated_total

UNION ALL

SELECT '07 - orders use the wrong route for the customer address',
       COUNT(*)
FROM Orders o
JOIN Customer c ON c.CustomerID = o.CustomerID
WHERE o.RouteID <> fn_get_route_for_address(c.CustomerID)

UNION ALL

SELECT '08 - deliveries are assigned to a trip on another route',
       COUNT(*)
FROM Delivery d
JOIN Orders o ON o.OrderID = d.OrderID
JOIN TruckTrip tt ON tt.TripID = d.TripID
WHERE tt.RouteID <> o.RouteID

UNION ALL

SELECT '09 - delivery date differs from its truck trip date',
       COUNT(*)
FROM Delivery d
JOIN TruckTrip tt ON tt.TripID = d.TripID
WHERE d.DeliveryDate <> tt.TripDate

UNION ALL

SELECT '10 - truck belongs to a different store from the route',
       COUNT(*)
FROM TruckTrip tt
JOIN Truck t ON t.TruckID = tt.TruckID
JOIN Route r ON r.RouteID = tt.RouteID
WHERE t.StoreID <> r.StoreID

UNION ALL

SELECT '11 - truck trip exceeds the route maximum delivery time',
       COUNT(*)
FROM TruckTrip tt
JOIN Route r ON r.RouteID = tt.RouteID
WHERE TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600
      > r.MaxDeliveryTime

UNION ALL

SELECT '12 - Placed orders have shipments',
       COUNT(*)
FROM Shipment s
JOIN OrderDetail od ON od.OrderDetailID = s.OrderDetailID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE o.Status = 'Placed'

UNION ALL

SELECT '13 - Placed orders have truck trips',
       COUNT(*)
FROM TruckTrip tt
JOIN Orders o ON o.OrderID = tt.OrderID
WHERE o.Status = 'Placed'

UNION ALL

SELECT '14 - delivery status does not match order status',
       COUNT(*)
FROM Delivery d
JOIN Orders o ON o.OrderID = d.OrderID
WHERE NOT (
       (o.Status = 'Delivered' AND d.Status = 'Delivered')
    OR (o.Status = 'In Transit' AND d.Status = 'In Transit')
    OR (o.Status = 'Processing' AND d.Status = 'Scheduled')
)

UNION ALL

SELECT '15 - fewer than 40 orders',
       IF(COUNT(*) >= 40, 0, 1)
FROM Orders

UNION ALL

SELECT '16 - fewer than 10 distinct routes used by orders',
       IF(COUNT(DISTINCT RouteID) >= 10, 0, 1)
FROM Orders

UNION ALL

SELECT '17 - train schedules cover fewer than 6 cities',
       IF(COUNT(DISTINCT st.City) >= 6, 0, 1)
FROM TrainSchedule ts
JOIN Store st ON st.StoreID = ts.StoreID;
