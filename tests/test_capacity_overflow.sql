-- Test Execution for Rollover Handling
CALL sp_schedule_shipment(1, 1, '2026-10-01');

-- Verify that order quantity was distributed across shipments
SELECT ShipmentID, ScheduleID, Quantity, ShipmentDate 
FROM Shipment 
WHERE OrderDetailID = 1;