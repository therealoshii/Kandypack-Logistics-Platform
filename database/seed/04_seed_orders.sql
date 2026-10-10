
-- ============================================================================
-- Kandypack Order & Logistics Seed Data
-- ============================================================================

USE kandypack_db;

-- 1. ADMINISTRATOR AND STAFF ROLES
-- Run before inserting orders that reference AdminID = 1.

INSERT IGNORE INTO Administrator
    (AdminID, Name, Username, Password, Email, Enabled)
VALUES
    (1, 'System Administrator', 'admin',
     '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash',
     'admin@kandypack.lk', TRUE);

INSERT IGNORE INTO StaffRole (Code, DisplayName) VALUES
    ('ADMIN', 'Administrator'),
    ('ORDER_MANAGER', 'Order manager'),
    ('RAIL_DISPATCHER', 'Rail dispatcher'),
    ('FLEET_MANAGER', 'Fleet manager'),
    ('ROSTER_DISPATCHER', 'Roster and delivery dispatcher'),
    ('ANALYST', 'Analytics viewer');

INSERT IGNORE INTO AdministratorRole (AdminID, RoleID)
SELECT a.AdminID, r.RoleID
FROM Administrator a
JOIN StaffRole r ON r.Code = 'ADMIN'
WHERE a.AdminID = 1;

-- 2. CLEAR TRANSACTIONAL SEED DATA

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE AuditLog;
TRUNCATE TABLE Delivery;
TRUNCATE TABLE Shipment;
TRUNCATE TABLE TruckTrip;
TRUNCATE TABLE OrderDetail;
TRUNCATE TABLE Orders;
SET FOREIGN_KEY_CHECKS = 1;

-- 3. SEED ORDERS
-- Q2, Q3 and Q4 2026.
-- RouteID is calculated from the customer's delivery area.

INSERT INTO Orders
    (OrderID, CustomerID, RouteID, AdminID,
     OrderDate, RequestedDeliveryDate, Status, TotalAmount)
SELECT
    v.OrderID,
    c.CustomerID,
    fn_get_route_for_address(c.CustomerID),
    v.AdminID,
    v.OrderDate,
    v.RequestedDeliveryDate,
    v.Status,
    0
FROM (
    SELECT 1 AS OrderID, 1 AS CustomerID, 1 AS AdminID,
        DATE '2026-04-01' AS OrderDate,
        DATE '2026-04-09' AS RequestedDeliveryDate,
        'Delivered' AS Status
    UNION ALL SELECT 2, 2, 1, DATE '2026-04-03', DATE '2026-04-11', 'Delivered'
    UNION ALL SELECT 3, 3, 1, DATE '2026-04-05', DATE '2026-04-14', 'Delivered'
    UNION ALL SELECT 4, 4, 1, DATE '2026-04-08', DATE '2026-04-16', 'Delivered'
    UNION ALL SELECT 5, 5, 1, DATE '2026-04-12', DATE '2026-04-20', 'Delivered'
    UNION ALL SELECT 6, 6, 1, DATE '2026-04-15', DATE '2026-04-23', 'Delivered'
    UNION ALL SELECT 7, 7, 1, DATE '2026-04-18', DATE '2026-04-27', 'Delivered'
    UNION ALL SELECT 8, 8, 1, DATE '2026-04-22', DATE '2026-04-30', 'Delivered'
    UNION ALL SELECT 9, 9, 1, DATE '2026-05-02', DATE '2026-05-10', 'Delivered'
    UNION ALL SELECT 10, 10, 1, DATE '2026-05-05', DATE '2026-05-13', 'Delivered'
    UNION ALL SELECT 11, 11, 1, DATE '2026-05-09', DATE '2026-05-17', 'Delivered'
    UNION ALL SELECT 12, 12, 1, DATE '2026-05-12', DATE '2026-05-20', 'Delivered'
    UNION ALL SELECT 13, 1, 1, DATE '2026-05-16', DATE '2026-05-24', 'Delivered'
    UNION ALL SELECT 14, 2, 1, DATE '2026-05-20', DATE '2026-05-28', 'Delivered'
    UNION ALL SELECT 15, 3, 1, DATE '2026-05-24', DATE '2026-06-01', 'Delivered'
    UNION ALL SELECT 16, 4, 1, DATE '2026-05-28', DATE '2026-06-05', 'Delivered'
    UNION ALL SELECT 17, 5, 1, DATE '2026-06-02', DATE '2026-06-10', 'Delivered'
    UNION ALL SELECT 18, 6, 1, DATE '2026-06-06', DATE '2026-06-14', 'Delivered'
    UNION ALL SELECT 19, 7, 1, DATE '2026-06-10', DATE '2026-06-18', 'Delivered'
    UNION ALL SELECT 20, 8, 1, DATE '2026-06-14', DATE '2026-06-22', 'Delivered'
    UNION ALL SELECT 21, 9, 1, DATE '2026-06-18', DATE '2026-06-26', 'Delivered'
    UNION ALL SELECT 22, 10, 1, DATE '2026-06-22', DATE '2026-06-30', 'Delivered'

    UNION ALL SELECT 23, 11, 1, DATE '2026-07-01', DATE '2026-07-09', 'Delivered'
    UNION ALL SELECT 24, 12, 1, DATE '2026-07-04', DATE '2026-07-12', 'Delivered'
    UNION ALL SELECT 25, 1, 1, DATE '2026-07-07', DATE '2026-07-15', 'Delivered'
    UNION ALL SELECT 26, 2, 1, DATE '2026-07-10', DATE '2026-07-18', 'Delivered'
    UNION ALL SELECT 27, 3, 1, DATE '2026-07-14', DATE '2026-07-22', 'Delivered'
    UNION ALL SELECT 28, 4, 1, DATE '2026-07-18', DATE '2026-07-26', 'Delivered'
    UNION ALL SELECT 29, 5, 1, DATE '2026-07-21', DATE '2026-07-29', 'Delivered'
    UNION ALL SELECT 30, 6, 1, DATE '2026-07-25', DATE '2026-08-02', 'Delivered'
    UNION ALL SELECT 31, 7, 1, DATE '2026-07-28', DATE '2026-08-05', 'Delivered'
    UNION ALL SELECT 32, 8, 1, DATE '2026-08-01', DATE '2026-08-09', 'Delivered'
    UNION ALL SELECT 33, 9, 1, DATE '2026-08-04', DATE '2026-08-12', 'Delivered'
    UNION ALL SELECT 34, 10, 1, DATE '2026-08-08', DATE '2026-08-16', 'Delivered'
    UNION ALL SELECT 35, 11, 1, DATE '2026-08-11', DATE '2026-08-19', 'Delivered'
    UNION ALL SELECT 36, 12, 1, DATE '2026-08-15', DATE '2026-08-23', 'Delivered'
    UNION ALL SELECT 37, 1, 1, DATE '2026-08-18', DATE '2026-08-26', 'Delivered'
    UNION ALL SELECT 38, 2, 1, DATE '2026-08-22', DATE '2026-08-30', 'Delivered'
    UNION ALL SELECT 39, 3, 1, DATE '2026-08-25', DATE '2026-09-02', 'Delivered'
    UNION ALL SELECT 40, 4, 1, DATE '2026-08-29', DATE '2026-09-06', 'Delivered'
    UNION ALL SELECT 41, 5, 1, DATE '2026-09-02', DATE '2026-09-10', 'Delivered'
    UNION ALL SELECT 42, 6, 1, DATE '2026-09-05', DATE '2026-09-13', 'Delivered'
    UNION ALL SELECT 43, 7, 1, DATE '2026-09-09', DATE '2026-09-17', 'Delivered'
    UNION ALL SELECT 44, 8, 1, DATE '2026-09-12', DATE '2026-09-20', 'Delivered'
    UNION ALL SELECT 45, 9, 1, DATE '2026-09-16', DATE '2026-09-24', 'Delivered'
    UNION ALL SELECT 46, 10, 1, DATE '2026-09-19', DATE '2026-09-27', 'Delivered'
    UNION ALL SELECT 47, 11, 1, DATE '2026-09-22', DATE '2026-09-30', 'Delivered'
    UNION ALL SELECT 48, 12, 1, DATE '2026-09-25', DATE '2026-10-03', 'Delivered'

    UNION ALL SELECT 49, 1, 1, DATE '2026-10-01', DATE '2026-10-10', 'Processing'
    UNION ALL SELECT 50, 2, 1, DATE '2026-10-02', DATE '2026-10-11', 'Processing'
    UNION ALL SELECT 51, 3, 1, DATE '2026-10-03', DATE '2026-10-12', 'Placed'
    UNION ALL SELECT 52, 4, 1, DATE '2026-10-04', DATE '2026-10-13', 'Placed'
    UNION ALL SELECT 53, 5, 1, DATE '2026-10-05', DATE '2026-10-14', 'Placed'
    UNION ALL SELECT 54, 6, 1, DATE '2026-10-06', DATE '2026-10-15', 'Placed'
) v
JOIN Customer c ON c.CustomerID = v.CustomerID;

-- 4. SEED ORDER DETAILS
-- Q2 and Q3 deliberately use different product mixes.

INSERT INTO OrderDetail
    (OrderDetailID, OrderID, ProductID, Quantity, LineTotal)
SELECT
    ROW_NUMBER() OVER (ORDER BY o.OrderID, p.ProductID),
    o.OrderID,
    p.ProductID,
    (MOD(o.OrderID, 5) + 1) * 10,
    ((MOD(o.OrderID, 5) + 1) * 10) * p.UnitPrice
FROM Orders o
JOIN Product p
  ON (
       (MONTH(o.OrderDate) BETWEEN 4 AND 6
        AND p.ProductID BETWEEN 1 AND 6
        AND MOD(o.OrderID + p.ProductID, 3) <> 0)
    OR (MONTH(o.OrderDate) BETWEEN 7 AND 9
        AND p.ProductID BETWEEN 3 AND 10
        AND MOD(o.OrderID + p.ProductID, 3) <> 0)
    OR (MONTH(o.OrderDate) NOT BETWEEN 4 AND 9
        AND p.ProductID BETWEEN 1 AND 5
        AND MOD(o.OrderID + p.ProductID, 2) = 0)
  );

UPDATE Orders o
JOIN (
    SELECT OrderID, SUM(LineTotal) AS CalculatedTotal
    FROM OrderDetail
    GROUP BY OrderID
) totals ON totals.OrderID = o.OrderID
SET o.TotalAmount = totals.CalculatedTotal;

-- 5. SEED TRUCK TRIPS
-- Each trip uses a truck belonging to the route's store.
-- The 2-hour duration is within every route's maximum delivery time.
-- TripID is kept equal to OrderID for straightforward delivery matching.

INSERT INTO TruckTrip
    (TripID, TruckID, RouteID, DriverID, AssistantID,
     TripDate, DispatchTime, ReturnTime)
SELECT
    o.OrderID,
    (
        SELECT MIN(t.TruckID)
        FROM Truck t
        JOIN Route r2 ON r2.StoreID = t.StoreID
        WHERE r2.RouteID = o.RouteID
    ),
    o.RouteID,
    1 + MOD(o.OrderID - 1, 10),
    1 + MOD(o.OrderID - 1, 10),
    o.RequestedDeliveryDate,
    '08:00:00',
    '10:00:00'
FROM Orders o
WHERE o.RequestedDeliveryDate IS NOT NULL
  AND o.Status <> 'Cancelled';

-- 6. SEED SHIPMENTS
-- Shipment has no Status column. Quantity is mandatory.
-- Find the first train-operating date from OrderDate + 2 through +8 days.

INSERT INTO Shipment
    (ShipmentID, OrderDetailID, ScheduleID, Quantity, ShipmentDate)
SELECT
    od.OrderDetailID,
    od.OrderDetailID,
    (
        SELECT MIN(ts.ScheduleID)
        FROM TrainSchedule ts
        WHERE ts.StoreID = r.StoreID
          AND ts.DayOfWeek = DAYNAME(
              (
                  SELECT MIN(DATE_ADD(o.OrderDate, INTERVAL n.n DAY))
                  FROM (
                      SELECT 2 AS n UNION ALL SELECT 3
                      UNION ALL SELECT 4 UNION ALL SELECT 5
                      UNION ALL SELECT 6 UNION ALL SELECT 7
                      UNION ALL SELECT 8
                  ) n
                  WHERE EXISTS (
                      SELECT 1
                      FROM TrainSchedule ts2
                      WHERE ts2.StoreID = r.StoreID
                        AND ts2.DayOfWeek =
                            DAYNAME(DATE_ADD(o.OrderDate, INTERVAL n.n DAY))
                  )
              )
          )
    ),
    od.Quantity,
    (
        SELECT MIN(DATE_ADD(o.OrderDate, INTERVAL n.n DAY))
        FROM (
            SELECT 2 AS n UNION ALL SELECT 3
            UNION ALL SELECT 4 UNION ALL SELECT 5
            UNION ALL SELECT 6 UNION ALL SELECT 7
            UNION ALL SELECT 8
        ) n
        WHERE EXISTS (
            SELECT 1
            FROM TrainSchedule ts2
            WHERE ts2.StoreID = r.StoreID
              AND ts2.DayOfWeek =
                  DAYNAME(DATE_ADD(o.OrderDate, INTERVAL n.n DAY))
        )
    )
FROM OrderDetail od
JOIN Orders o ON o.OrderID = od.OrderID
JOIN Route r ON r.RouteID = o.RouteID
WHERE o.Status <> 'Cancelled';

-- 7. SEED DELIVERIES
-- No deliveries for Placed or Cancelled orders.
-- Delivery date, trip date, and order route must match.

INSERT INTO Delivery
    (DeliveryID, OrderID, TripID, DeliveryDate, Status)
SELECT
    o.OrderID,
    o.OrderID,
    tt.TripID,
    o.RequestedDeliveryDate,
    CASE
        WHEN o.Status = 'Delivered' THEN 'Delivered'
        WHEN o.Status IN ('Shipped', 'In Transit') THEN 'In Transit'
        ELSE 'Scheduled'
    END
FROM Orders o
JOIN TruckTrip tt
    ON tt.TripID = o.OrderID
   AND tt.RouteID = o.RouteID
   AND tt.TripDate = o.RequestedDeliveryDate
WHERE o.Status NOT IN ('Placed', 'Cancelled')
  AND o.RequestedDeliveryDate IS NOT NULL;
