DELIMITER //

-- Fix 1: Use COALESCE(@audit_changed_by, 'SYSTEM') so the real username is captured
DROP TRIGGER IF EXISTS trg_audit_delivery_status //
CREATE TRIGGER trg_audit_delivery_status
AFTER UPDATE ON Delivery
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        INSERT INTO AuditLog (TableName, RecordID, Action, ChangedBy, Timestamp, Details)
        VALUES (
            'Delivery',
            NEW.DeliveryID,
            'UPDATE_STATUS',
            COALESCE(@audit_changed_by, 'SYSTEM'),
            NOW(),
            CONCAT('Status updated from ', OLD.Status, ' to ', NEW.Status)
        );
    END IF;
END //

-- Fix 2: Audit log for Order Status changes
DROP TRIGGER IF EXISTS trg_audit_order_status //
CREATE TRIGGER trg_audit_order_status
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        INSERT INTO AuditLog (TableName, RecordID, Action, ChangedBy, Timestamp, Details)
        VALUES (
            'Orders',
            NEW.OrderID,
            'UPDATE_STATUS',
            COALESCE(@audit_changed_by, CONCAT('Admin#', NEW.AdminID), 'SYSTEM'),
            NOW(),
            CONCAT('Order status updated from ', OLD.Status, ' to ', NEW.Status)
        );
    END IF;
END //

-- Fix 3: Audit log for TruckTrip updates (Driver, Assistant, Truck, Date, or Dispatch/Return times)
DROP TRIGGER IF EXISTS trg_audit_trucktrip_update //
CREATE TRIGGER trg_audit_trucktrip_update
AFTER UPDATE ON TruckTrip
FOR EACH ROW
BEGIN
    IF NOT (OLD.DriverID <=> NEW.DriverID AND 
            OLD.AssistantID <=> NEW.AssistantID AND 
            OLD.TruckID <=> NEW.TruckID AND 
            OLD.TripDate <=> NEW.TripDate AND 
            OLD.DispatchTime <=> NEW.DispatchTime AND 
            OLD.ReturnTime <=> NEW.ReturnTime) THEN
            
        INSERT INTO AuditLog (TableName, RecordID, Action, ChangedBy, Timestamp, Details)
        VALUES (
            'TruckTrip',
            NEW.TripID,
            'UPDATE_TRIP',
            COALESCE(@audit_changed_by, 'SYSTEM'),
            NOW(),
            CONCAT('Trip updated: Driver (', IFNULL(OLD.DriverID, 0), '->', IFNULL(NEW.DriverID, 0), 
                   '), Assistant (', IFNULL(OLD.AssistantID, 0), '->', IFNULL(NEW.AssistantID, 0), ')')
        );
    END IF;
END //

DELIMITER ;