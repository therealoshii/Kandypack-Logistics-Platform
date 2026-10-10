-- =========================================================================
-- Test File: database/tests/test_capacity_overflow.sql
-- Description: Integration test for Task W6 - Capacity Overflow & Rollover
-- =========================================================================

-- Ensure test runs safely within a transaction boundary
START TRANSACTION;

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

-- Roll back changes to keep the test environment clean
ROLLBACK;