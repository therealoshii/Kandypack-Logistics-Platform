-- =========================================================================
-- Test File: database/tests/test_capacity_overflow.sql
-- Description: Integration test for Task W6 - Capacity Overflow & Rollover
-- =========================================================================

-- Ensure test runs safely within a transaction boundary
START TRANSACTION;

-- Cleanup any previous test artifacts for ID 9001
DELETE FROM Shipment WHERE OrderDetailID = 9001;
DELETE FROM OrderDetail WHERE OrderDetailID = 9001;
DELETE FROM Orders WHERE OrderID = 9001;

-- Ensure a test order and order line exist with a valid status ('CONFIRMED'), LineTotal, and Monday date (2026-10-05)
INSERT INTO Orders (OrderID, OrderDate, CustomerID, RouteID, Status)
VALUES (9001, '2026-10-05', 1, 1, 'CONFIRMED');

INSERT INTO OrderDetail (OrderDetailID, OrderID, ProductID, Quantity, LineTotal)
VALUES (9001, 9001, 1, 500, 50000.00);

-- 1. Test Execution for Rollover Handling
-- Calls the stored procedure to schedule a large order quantity across available train slots
CALL sp_schedule_shipment(9001, 1, '2026-10-05');

-- 2. Verify that order quantity was distributed across multiple shipments (Rollover check)
SELECT 
    ShipmentID, 
    ScheduleID, 
    Quantity, 
    ShipmentDate 
FROM Shipment 
WHERE OrderDetailID = 9001;

-- Explicit cleanup for test data (since procedure commits internally)
DELETE FROM Shipment WHERE OrderDetailID = 9001;
DELETE FROM OrderDetail WHERE OrderDetailID = 9001;
DELETE FROM Orders WHERE OrderID = 9001;

-- Roll back changes to keep the test environment clean
ROLLBACK;