-- =========================================================================
-- Test File: database/tests/test_capacity_overflow.sql
-- Description: Integration test for Task W6 - Capacity Overflow & Rollover
-- =========================================================================
-- sp_schedule_shipment commits its own transaction, so this test cannot be wrapped in
-- START TRANSACTION / ROLLBACK. It uses its own IDs (9001) and cleans up with DELETE.
-- Monday 2026-12-07 is after all seed data, so both Colombo trains start empty:
--    schedule 1 (06:00) and schedule 2 (14:00), 150 space each = 300 units of product 1.

-- Cleanup any previous test artifacts for ID 9001
DELETE FROM Shipment WHERE OrderDetailID = 9001;
DELETE FROM OrderDetail WHERE OrderDetailID = 9001;
DELETE FROM Orders WHERE OrderID = 9001;

SELECT StockQuantity INTO @stock_before FROM Product WHERE ProductID = 1;

-- A Colombo order (customer 1, route 1) with one large line: 700 units x 0.5 = 350 space
INSERT INTO Orders (OrderID, OrderDate, RequestedDeliveryDate, CustomerID, RouteID, Status)
VALUES (9001, '2026-11-20', '2026-12-20', 1, 1, 'Placed');

INSERT INTO OrderDetail (OrderDetailID, OrderID, ProductID, Quantity, LineTotal)
VALUES (9001, 9001, 1, 700, 315000.00);

-- 1. Schedule the line on the first Monday train
CALL sp_schedule_shipment(9001, 1, '2026-12-07');

-- 2. EXPECTED: 3 rows
--      schedule 1, 300 units, 2026-12-07   (first train full)
--      schedule 2, 300 units, 2026-12-07   (same-day overflow)
--      schedule 1, 100 units, 2026-12-14   (rollover to the next Monday)
SELECT ShipmentID, ScheduleID, Quantity, ShipmentDate, DAYNAME(ShipmentDate) AS ShipmentDay
FROM Shipment
WHERE OrderDetailID = 9001
ORDER BY ShipmentID;

-- 3. EXPECTED: 0.00, 0.00, 100.00
SELECT fn_get_available_capacity(1, '2026-12-07') AS Train1Left,
       fn_get_available_capacity(2, '2026-12-07') AS Train2Left,
       fn_get_available_capacity(1, '2026-12-14') AS NextMondayLeft;

-- Cleanup, and give back the stock that the dispatch trigger deducted
DELETE FROM Shipment WHERE OrderDetailID = 9001;
DELETE FROM OrderDetail WHERE OrderDetailID = 9001;
DELETE FROM Orders WHERE OrderID = 9001;
UPDATE Product SET StockQuantity = @stock_before WHERE ProductID = 1;