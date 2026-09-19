
-- Kandypack Logistics Platform - Security & Action Audit Log Triggers
-- Requirement:  Security Requirements


DROP TRIGGER IF EXISTS trg_audit_order_status;
DROP TRIGGER IF EXISTS trg_audit_delivery_status;

DELIMITER //

-- 1. Audit status modifications on Orders
CREATE TRIGGER trg_audit_order_status
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
        VALUES ('Orders', 'UPDATE', NEW.OrderID, 
                COALESCE(CONCAT('Admin#', NEW.AdminID), 'SYSTEM'),
                CONCAT('Order status changed from ', OLD.Status, ' to ', NEW.Status));
    END IF;
END //

-- 2. Audit status modifications on Deliveries
CREATE TRIGGER trg_audit_delivery_status
AFTER UPDATE ON Delivery
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
        VALUES ('Delivery', 'UPDATE', NEW.DeliveryID, 'DISPATCH_COORDINATOR',
                CONCAT('Delivery status changed from ', OLD.Status, ' to ', NEW.Status, ' for Order #', NEW.OrderID));
    END IF;
END //

DELIMITER ;