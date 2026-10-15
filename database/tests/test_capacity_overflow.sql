-- Tests capacity overflow & rollover (sp_schedule_shipment).
-- Uses test IDs 9001/9002 and cleans up with DELETE. Test date: Monday 2026-12-07.

DELETE FROM Shipment WHERE OrderDetailID = 9001;
DELETE FROM OrderDetail WHERE OrderDetailID = 9001;
DELETE FROM Orders WHERE OrderID = 9001;

SELECT StockQuantity INTO @stock_before FROM Product WHERE ProductID = 1;

-- 700 units x 0.5 = 350 space, exceeds single train capacity (150)
INSERT INTO Orders (OrderID, OrderDate, RequestedDeliveryDate, CustomerID, RouteID, Status)
VALUES (9001, '2026-11-20', '2026-12-20', 1, 1, 'Placed');

INSERT INTO OrderDetail (OrderDetailID, OrderID, ProductID, Quantity, LineTotal)
VALUES (9001, 9001, 1, 700, 315000.00);

CALL sp_schedule_shipment(9001, 1, '2026-12-07');

-- Expect 3 rows: schedule 1 (300 units, 12-07), schedule 2 (300 units, 12-07), schedule 1 (100 units, 12-14)
SELECT ShipmentID, ScheduleID, Quantity, ShipmentDate, DAYNAME(ShipmentDate) AS ShipmentDay
FROM Shipment
WHERE OrderDetailID = 9001
ORDER BY ShipmentID;

-- Expect 0.00, 0.00, 100.00
SELECT fn_get_available_capacity(1, '2026-12-07') AS Train1Left,
       fn_get_available_capacity(2, '2026-12-07') AS Train2Left,
       fn_get_available_capacity(1, '2026-12-14') AS NextMondayLeft;

DELETE FROM Shipment WHERE OrderDetailID = 9001;
DELETE FROM OrderDetail WHERE OrderDetailID = 9001;
DELETE FROM Orders WHERE OrderID = 9001;
UPDATE Product SET StockQuantity = @stock_before WHERE ProductID = 1;

-- TEST 2: Insufficient stock – should fail and book nothing
-- INSERT INTO Orders (OrderID, OrderDate, RequestedDeliveryDate, CustomerID, RouteID, Status)
-- VALUES (9002, '2026-11-20', '2026-12-20', 1, 1, 'Placed');
-- INSERT INTO OrderDetail (OrderDetailID, OrderID, ProductID, Quantity, LineTotal)
-- SELECT 9002, 9002, 1, StockQuantity + 1, (StockQuantity + 1) * UnitPrice FROM Product WHERE ProductID = 1;
-- CALL sp_schedule_shipment(9002, 1, '2026-12-07');
-- Expected error: "Insufficient Stock: The warehouse does not have enough stock to ship this order line."
-- DELETE FROM OrderDetail WHERE OrderDetailID = 9002;
-- DELETE FROM Orders WHERE OrderID = 9002;