-- ============================================================================
-- Kandypack Database Seed Integrity Verification Script (Task A6)
-- Every query in this file MUST return 0 for the test to pass.
-- ============================================================================

USE kandypack_db;

SELECT '1. Shipments pointing to non-existent train schedules' AS check_name, COUNT(*) AS violations
FROM Shipment s 
LEFT JOIN TrainSchedule ts USING (ScheduleID)
WHERE ts.ScheduleID IS NULL

UNION ALL

SELECT '2. Deliveries dated before their corresponding order date' AS check_name, COUNT(*) AS violations
FROM Delivery d 
JOIN Orders o USING (OrderID)
WHERE d.DeliveryDate < o.OrderDate

UNION ALL

SELECT '3. Delivered orders with less than 7 days lead time' AS check_name, COUNT(*) AS violations
FROM Orders
WHERE Status = 'Delivered' 
  AND DATEDIFF(RequestedDeliveryDate, OrderDate) < 7

UNION ALL

SELECT '4. Order detail lines with incorrect total calculations' AS check_name, COUNT(*) AS violations
FROM OrderDetail od 
JOIN Product p USING (ProductID)
WHERE ABS(od.LineTotal - (od.Quantity * p.UnitPrice)) > 0.01

UNION ALL

SELECT '5. Deliveries assigned to a trip on a different route' AS check_name, COUNT(*) AS violations
FROM Delivery d
JOIN Orders o USING (OrderID)
JOIN TruckTrip tt ON d.TripID = tt.TripID
JOIN Truck t ON tt.TruckID = t.TruckID
JOIN Store s ON t.StoreID = s.StoreID
WHERE o.RouteID NOT IN (SELECT RouteID FROM Route WHERE StoreID = s.StoreID)

UNION ALL

SELECT '6. Deliveries whose delivery date does not match their trip date' AS check_name, COUNT(*) AS violations
FROM Delivery d
JOIN TruckTrip tt ON d.TripID = tt.TripID
WHERE d.DeliveryDate <> tt.TripDate

UNION ALL

SELECT '7. Orders with incorrect TotalAmount sum' AS check_name, COUNT(*) AS violations
FROM Orders o
JOIN (
    SELECT OrderID, SUM(LineTotal) AS ActualTotal 
    FROM OrderDetail 
    GROUP BY OrderID
) details ON o.OrderID = details.OrderID
WHERE ABS(o.TotalAmount - details.ActualTotal) > 0.01;