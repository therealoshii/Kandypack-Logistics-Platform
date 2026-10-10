-- =========================================================================
-- Test File: database/tests/test_capacity_overflow.sql
-- Description: Integration test for Task W6 - Capacity Overflow & Rollover
-- =========================================================================

-- Ensure test runs safely within a transaction boundary
START TRANSACTION;

-- Cleanup any previous test artifacts
DELETE FROM Shipment WHERE OrderDetailID = 1;
DELETE FROM OrderDetail WHERE OrderDetailID = 1;

-- Ensure a test order and order line exist with a large quantity (e.g., 500 units to overflow a 150-capacity train)
INSERT INTO Orders (OrderID, OrderDate, CustomerID, RouteID, Status)
VALUES (1, '2026-10-01', 1, 1, 'PENDING')
ON DUPLICATE KEY UPDATE Status = 'PENDING';

INSERT INTO OrderDetail (OrderDetailID, OrderID, ProductID, Quantity)
VALUES (1, 1, 1, 500)
ON DUPLICATE KEY UPDATE Quantity = 500;

-- 1. Test Execution for Rollover Handling
-- Calls the stored procedure to schedule a large order quantity across available train slots
CALL sp_schedule_shipment(1, 1, '2026-10-01');

-- 2. Verify that order quantity was distributed across multiple shipments (Rollover check)
SELECT 
    ShipmentID, 
    ScheduleID, 
    Quantity, 
    ShipmentDate 
FROM Shipment 
WHERE OrderDetailID = 1;

-- Explicit cleanup for test data (since procedure commits internally)
DELETE FROM Shipment WHERE OrderDetailID = 1;
DELETE FROM OrderDetail WHERE OrderDetailID = 1;
DELETE FROM Orders WHERE OrderID = 1;

-- Roll back changes to keep the test environment clean
ROLLBACK;