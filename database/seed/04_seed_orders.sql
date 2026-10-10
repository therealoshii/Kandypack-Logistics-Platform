-- ============================================================================
-- Kandypack Order & Logistics Seed Data (Task A5 Rebuild)
-- Includes real TrainSchedule mapping from Task W1
-- ============================================================================

USE kandypack_db;

-- Temporarily disable FK checks to clear existing order tables cleanly
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE AuditLog;
TRUNCATE TABLE Delivery;
TRUNCATE TABLE Shipment;
TRUNCATE TABLE TruckTrip;
TRUNCATE TABLE OrderDetail;
TRUNCATE TABLE Orders;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. SEED ORDERS (Q2, Q3, and Q4 2026)
-- ----------------------------------------------------------------------------
-- RouteID is dynamically populated based on Customer.AreaID lookup

INSERT INTO Orders (OrderID, CustomerID, RouteID, AdminID, OrderDate, RequestedDeliveryDate, Status, TotalAmount)
SELECT v.OrderID, c.CustomerID, fn_get_route_for_address(c.CustomerID), v.AdminID, v.OrderDate, v.RequestedDeliveryDate, v.Status, 0
FROM (
    -- Q2 Delivered Orders (Apr 2026 - Jun 2026) - 22 Orders
    SELECT 1 AS OrderID, 1 AS CustomerID, 1 AS AdminID, DATE '2026-04-01' AS OrderDate, DATE '2026-04-09' AS RequestedDeliveryDate, 'Delivered' AS Status UNION ALL
    SELECT 2, 2, 1, DATE '2026-04-03', DATE '2026-04-11', 'Delivered' UNION ALL
    SELECT 3, 3, 1, DATE '2026-04-05', DATE '2026-04-14', 'Delivered' UNION ALL
    SELECT 4, 4, 1, DATE '2026-04-08', DATE '2026-04-16', 'Delivered' UNION ALL
    SELECT 5, 5, 1, DATE '2026-04-12', DATE '2026-04-20', 'Delivered' UNION ALL
    SELECT 6, 6, 1, DATE '2026-04-15', DATE '2026-04-23', 'Delivered' UNION ALL
    SELECT 7, 7, 1, DATE '2026-04-18', DATE '2026-04-27', 'Delivered' UNION ALL
    SELECT 8, 8, 1, DATE '2026-04-22', DATE '2026-04-30', 'Delivered' UNION ALL
    SELECT 9, 9, 1, DATE '2026-05-02', DATE '2026-05-10', 'Delivered' UNION ALL
    SELECT 10, 10, 1, DATE '2026-05-05', DATE '2026-05-13', 'Delivered' UNION ALL
    SELECT 11, 11, 1, DATE '2026-05-09', DATE '2026-05-17', 'Delivered' UNION ALL
    SELECT 12, 12, 1, DATE '2026-05-12', DATE '2026-05-20', 'Delivered' UNION ALL
    SELECT 13, 1, 1, DATE '2026-05-16', DATE '2026-05-24', 'Delivered' UNION ALL
    SELECT 14, 2, 1, DATE '2026-05-20', DATE '2026-05-28', 'Delivered' UNION ALL
    SELECT 15, 3, 1, DATE '2026-05-24', DATE '2026-06-01', 'Delivered' UNION ALL
    SELECT 16, 4, 1, DATE '2026-05-28', DATE '2026-06-05', 'Delivered' UNION ALL
    SELECT 17, 5, 1, DATE '2026-06-02', DATE '2026-06-10', 'Delivered' UNION ALL
    SELECT 18, 6, 1, DATE '2026-06-06', DATE '2026-06-14', 'Delivered' UNION ALL
    SELECT 19, 7, 1, DATE '2026-06-10', DATE '2026-06-18', 'Delivered' UNION ALL
    SELECT 20, 8, 1, DATE '2026-06-14', DATE '2026-06-22', 'Delivered' UNION ALL
    SELECT 21, 9, 1, DATE '2026-06-18', DATE '2026-06-26', 'Delivered' UNION ALL
    SELECT 22, 10, 1, DATE '2026-06-22', DATE '2026-06-30', 'Delivered' UNION ALL

    -- Q3 Delivered Orders (Jul 2026 - Sep 2026) - 26 Orders (Demonstrates quarterly growth)
    SELECT 23, 11, 1, DATE '2026-07-01', DATE '2026-07-09', 'Delivered' UNION ALL
    SELECT 24, 12, 1, DATE '2026-07-04', DATE '2026-07-12', 'Delivered' UNION ALL
    SELECT 25, 1, 1, DATE '2026-07-07', DATE '2026-07-15', 'Delivered' UNION ALL
    SELECT 26, 2, 1, DATE '2026-07-10', DATE '2026-07-18', 'Delivered' UNION ALL
    SELECT 27, 3, 1, DATE '2026-07-14', DATE '2026-07-22', 'Delivered' UNION ALL
    SELECT 28, 4, 1, DATE '2026-07-18', DATE '2026-07-26', 'Delivered' UNION ALL
    SELECT 29, 5, 1, DATE '2026-07-21', DATE '2026-07-29', 'Delivered' UNION ALL
    SELECT 30, 6, 1, DATE '2026-07-25', DATE '2026-08-02', 'Delivered' UNION ALL
    SELECT 31, 7, 1, DATE '2026-07-28', DATE '2026-08-05', 'Delivered' UNION ALL
    SELECT 32, 8, 1, DATE '2026-08-01', DATE '2026-08-09', 'Delivered' UNION ALL
    SELECT 33, 9, 1, DATE '2026-08-04', DATE '2026-08-12', 'Delivered' UNION ALL
    SELECT 34, 10, 1, DATE '2026-08-08', DATE '2026-08-16', 'Delivered' UNION ALL
    SELECT 35, 11, 1, DATE '2026-08-11', DATE '2026-08-19', 'Delivered' UNION ALL
    SELECT 36, 12, 1, DATE '2026-08-15', DATE '2026-08-23', 'Delivered' UNION ALL
    SELECT 37, 1, 1, DATE '2026-08-18', DATE '2026-08-26', 'Delivered' UNION ALL
    SELECT 38, 2, 1, DATE '2026-08-22', DATE '2026-08-30', 'Delivered' UNION ALL
    SELECT 39, 3, 1, DATE '2026-08-25', DATE '2026-09-02', 'Delivered' UNION ALL
    SELECT 40, 4, 1, DATE '2026-08-29', DATE '2026-09-06', 'Delivered' UNION ALL
    SELECT 41, 5, 1, DATE '2026-09-02', DATE '2026-09-10', 'Delivered' UNION ALL
    SELECT 42, 6, 1, DATE '2026-09-05', DATE '2026-09-13', 'Delivered' UNION ALL
    SELECT 43, 7, 1, DATE '2026-09-09', DATE '2026-09-17', 'Delivered' UNION ALL
    SELECT 44, 8, 1, DATE '2026-09-12', DATE '2026-09-20', 'Delivered' UNION ALL
    SELECT 45, 9, 1, DATE '2026-09-16', DATE '2026-09-24', 'Delivered' UNION ALL
    SELECT 46, 10, 1, DATE '2026-09-19', DATE '2026-09-27', 'Delivered' UNION ALL
    SELECT 47, 11, 1, DATE '2026-09-22', DATE '2026-09-30', 'Delivered' UNION ALL
    SELECT 48, 12, 1, DATE '2026-09-25', DATE '2026-10-03', 'Delivered' UNION ALL

    -- Q4 October 2026 Open Orders - 6 Orders
    SELECT 49, 1, 1, DATE '2026-10-01', DATE '2026-10-10', 'Processing' UNION ALL
    SELECT 50, 2, 1, DATE '2026-10-02', DATE '2026-10-11', 'Processing' UNION ALL
    SELECT 51, 3, 1, DATE '2026-10-03', DATE '2026-10-12', 'Placed' UNION ALL
    SELECT 52, 4, 1, DATE '2026-10-04', DATE '2026-10-13', 'Placed' UNION ALL
    SELECT 53, 5, 1, DATE '2026-10-05', DATE '2026-10-14', 'Placed' UNION ALL
    SELECT 54, 6, 1, DATE '2026-10-06', DATE '2026-10-15', 'Placed'
) v
JOIN Customer c ON c.CustomerID = v.CustomerID;

-- ----------------------------------------------------------------------------
-- 2. SEED ORDER DETAILS
-- ----------------------------------------------------------------------------
INSERT INTO OrderDetail (OrderDetailID, OrderID, ProductID, Quantity, LineTotal)
SELECT 
    row_number() OVER (ORDER BY o.OrderID, p.ProductID) AS OrderDetailID,
    o.OrderID,
    p.ProductID,
    (o.OrderID % 5 + 1) * 10 AS Quantity,
    0 AS LineTotal
FROM Orders o
CROSS JOIN Product p
WHERE p.ProductID IN (1, 2);

-- Dynamically calculate exact LineTotal and TotalAmount
UPDATE OrderDetail od 
JOIN Product p ON p.ProductID = od.ProductID
SET od.LineTotal = od.Quantity * p.UnitPrice;

UPDATE Orders o
JOIN (
    SELECT OrderID, SUM(LineTotal) AS CalculatedTotal 
    FROM OrderDetail 
    GROUP BY OrderID
) summary ON summary.OrderID = o.OrderID
SET o.TotalAmount = summary.CalculatedTotal;

-- ----------------------------------------------------------------------------
-- 3. SEED TRUCK TRIPS
-- ----------------------------------------------------------------------------
INSERT INTO TruckTrip (TripID, TruckID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(1, 1, 1, 1, '2026-04-09', '08:00:00', '12:00:00'),
(2, 2, 2, 2, '2026-04-11', '08:00:00', '12:00:00'),
(3, 3, 3, 3, '2026-04-14', '08:00:00', '12:00:00'),
(4, 4, 4, 4, '2026-04-16', '08:00:00', '12:00:00'),
(5, 5, 5, 5, '2026-04-20', '08:00:00', '12:00:00'),
(6, 6, 6, 6, '2026-04-23', '08:00:00', '12:00:00'),
(7, 1, 1, 1, '2026-04-27', '08:00:00', '12:00:00'),
(8, 2, 2, 2, '2026-04-30', '08:00:00', '12:00:00'),
(9, 3, 3, 3, '2026-05-10', '08:00:00', '12:00:00'),
(10, 4, 4, 4, '2026-05-13', '08:00:00', '12:00:00'),
(11, 5, 5, 5, '2026-07-09', '08:00:00', '12:00:00'),
(12, 6, 6, 6, '2026-07-12', '08:00:00', '12:00:00'),
(13, 1, 1, 1, '2026-07-15', '08:00:00', '12:00:00'),
(14, 2, 2, 2, '2026-07-18', '08:00:00', '12:00:00'),
(15, 3, 3, 3, '2026-10-10', '08:00:00', '12:00:00'),
(16, 4, 4, 4, '2026-10-11', '08:00:00', '12:00:00');

-- ----------------------------------------------------------------------------
-- 4. SEED SHIPMENTS (Mapped to Task W1 ScheduleIDs)
-- ----------------------------------------------------------------------------
-- ScheduleID Mapping:
-- 1-2: Colombo | 3-4: Negombo | 5-6: Galle
-- 7-8: Matara  | 9-10: Jaffna | 11-12: Trincomalee

INSERT INTO Shipment (ShipmentID, OrderDetailID, ScheduleID, ShipmentDate, Status)
SELECT 
    od.OrderDetailID AS ShipmentID,
    od.OrderDetailID,
    CASE 
        WHEN (o.CustomerID % 6) = 1 THEN 1  -- Colombo (ScheduleID 1)
        WHEN (o.CustomerID % 6) = 2 THEN 3  -- Negombo (ScheduleID 3)
        WHEN (o.CustomerID % 6) = 3 THEN 5  -- Galle (ScheduleID 5)
        WHEN (o.CustomerID % 6) = 4 THEN 7  -- Matara (ScheduleID 7)
        WHEN (o.CustomerID % 6) = 5 THEN 9  -- Jaffna (ScheduleID 9)
        ELSE 11                             -- Trincomalee (ScheduleID 11)
    END AS ScheduleID,
    o.OrderDate + INTERVAL 2 DAY AS ShipmentDate,
    IF(o.Status = 'Delivered', 'Completed', 'Scheduled') AS Status
FROM OrderDetail od
JOIN Orders o ON od.OrderID = o.OrderID;

-- ----------------------------------------------------------------------------
-- 5. SEED DELIVERIES
-- ----------------------------------------------------------------------------
INSERT INTO Delivery (DeliveryID, OrderID, TripID, DeliveryDate, Status)
SELECT 
    o.OrderID AS DeliveryID,
    o.OrderID,
    ((o.OrderID - 1) % 16) + 1 AS TripID,
    o.RequestedDeliveryDate AS DeliveryDate,
    o.Status
FROM Orders o;