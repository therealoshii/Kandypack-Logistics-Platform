
DELIMITER //

DROP TRIGGER IF EXISTS trg_audit_delivery_status //

CREATE TRIGGER trg_audit_delivery_status
AFTER UPDATE ON Delivery
FOR EACH ROW
BEGIN
    IF NOT (OLD.Status <=> NEW.Status) THEN
        INSERT INTO AuditLog (
            TableName,
            RecordID,
            ActionType,
            ChangedBy,
            ChangeTimestamp,
            Details
        )
        VALUES (
            'Delivery',
            NEW.DeliveryID,
            'UPDATE',
            COALESCE(@audit_changed_by, 'SYSTEM'),
            CURRENT_TIMESTAMP,
            CONCAT(
                'Delivery status changed from ',
                OLD.Status,
                ' to ',
                NEW.Status
            )
        );
    END IF;
END //

DROP TRIGGER IF EXISTS trg_audit_order_status //

CREATE TRIGGER trg_audit_order_status
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NOT (OLD.Status <=> NEW.Status) THEN
        INSERT INTO AuditLog (
            TableName,
            RecordID,
            ActionType,
            ChangedBy,
            ChangeTimestamp,
            Details
        )
        VALUES (
            'Orders',
            NEW.OrderID,
            'UPDATE',
            COALESCE(
                @audit_changed_by,
                CONCAT('Admin#', COALESCE(NEW.AdminID, 0))
            ),
            CURRENT_TIMESTAMP,
            CONCAT(
                'Order status changed from ',
                OLD.Status,
                ' to ',
                NEW.Status
            )
        );
    END IF;
END //

DROP TRIGGER IF EXISTS trg_audit_trucktrip_update //

CREATE TRIGGER trg_audit_trucktrip_update
AFTER UPDATE ON TruckTrip
FOR EACH ROW
BEGIN
    IF NOT (
        OLD.DriverID <=> NEW.DriverID
        AND OLD.AssistantID <=> NEW.AssistantID
        AND OLD.TruckID <=> NEW.TruckID
        AND OLD.RouteID <=> NEW.RouteID
        AND OLD.TripDate <=> NEW.TripDate
        AND OLD.DispatchTime <=> NEW.DispatchTime
        AND OLD.ReturnTime <=> NEW.ReturnTime
    ) THEN
        INSERT INTO AuditLog (
            TableName,
            RecordID,
            ActionType,
            ChangedBy,
            ChangeTimestamp,
            Details
        )
        VALUES (
            'TruckTrip',
            NEW.TripID,
            'UPDATE',
            COALESCE(@audit_changed_by, 'SYSTEM'),
            CURRENT_TIMESTAMP,
            CONCAT(
                'Truck trip updated. Route: ',
                OLD.RouteID, ' -> ', NEW.RouteID,
                '; Truck: ', OLD.TruckID, ' -> ', NEW.TruckID,
                '; Driver: ', OLD.DriverID, ' -> ', NEW.DriverID,
                '; Assistant: ', OLD.AssistantID, ' -> ', NEW.AssistantID
            )
        );
    END IF;
END //

DELIMITER ;
