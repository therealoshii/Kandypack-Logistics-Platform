
USE kandypack_db;

DELIMITER //

-- ============================================================
-- 1. Audit changes to Delivery.Status
-- ============================================================
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
            'UPDATE_STATUS',
            COALESCE(@audit_changed_by, 'SYSTEM'),
            CURRENT_TIMESTAMP,
            CONCAT(
                'Status changed from ',
                COALESCE(OLD.Status, 'NULL'),
                ' to ',
                COALESCE(NEW.Status, 'NULL')
            )
        );
    END IF;
END //


-- ============================================================
-- 2. Audit changes to Orders.Status
-- ============================================================
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
            'UPDATE_STATUS',
            COALESCE(
                @audit_changed_by,
                CONCAT('Admin#', NEW.AdminID),
                'SYSTEM'
            ),
            CURRENT_TIMESTAMP,
            CONCAT(
                'Order status changed from ',
                COALESCE(OLD.Status, 'NULL'),
                ' to ',
                COALESCE(NEW.Status, 'NULL')
            )
        );
    END IF;
END //


-- ============================================================
-- 3. Audit changes to TruckTrip assignments and timings
-- ============================================================
DROP TRIGGER IF EXISTS trg_audit_trucktrip_update //

CREATE TRIGGER trg_audit_trucktrip_update
AFTER UPDATE ON TruckTrip
FOR EACH ROW
BEGIN
    DECLARE change_details TEXT DEFAULT '';

    -- Build a description only for fields that actually changed.
    IF NOT (OLD.DriverID <=> NEW.DriverID) THEN
        SET change_details = CONCAT(
            change_details,
            'DriverID: ',
            COALESCE(CAST(OLD.DriverID AS CHAR), 'NULL'),
            ' -> ',
            COALESCE(CAST(NEW.DriverID AS CHAR), 'NULL'),
            '; '
        );
    END IF;

    IF NOT (OLD.AssistantID <=> NEW.AssistantID) THEN
        SET change_details = CONCAT(
            change_details,
            'AssistantID: ',
            COALESCE(CAST(OLD.AssistantID AS CHAR), 'NULL'),
            ' -> ',
            COALESCE(CAST(NEW.AssistantID AS CHAR), 'NULL'),
            '; '
        );
    END IF;

    IF NOT (OLD.TruckID <=> NEW.TruckID) THEN
        SET change_details = CONCAT(
            change_details,
            'TruckID: ',
            COALESCE(CAST(OLD.TruckID AS CHAR), 'NULL'),
            ' -> ',
            COALESCE(CAST(NEW.TruckID AS CHAR), 'NULL'),
            '; '
        );
    END IF;

    IF NOT (OLD.RouteID <=> NEW.RouteID) THEN
        SET change_details = CONCAT(
            change_details,
            'RouteID: ',
            COALESCE(CAST(OLD.RouteID AS CHAR), 'NULL'),
            ' -> ',
            COALESCE(CAST(NEW.RouteID AS CHAR), 'NULL'),
            '; '
        );
    END IF;

    IF NOT (OLD.TripDate <=> NEW.TripDate) THEN
        SET change_details = CONCAT(
            change_details,
            'TripDate: ',
            COALESCE(DATE_FORMAT(OLD.TripDate, '%Y-%m-%d'), 'NULL'),
            ' -> ',
            COALESCE(DATE_FORMAT(NEW.TripDate, '%Y-%m-%d'), 'NULL'),
            '; '
        );
    END IF;

    IF NOT (OLD.DispatchTime <=> NEW.DispatchTime) THEN
        SET change_details = CONCAT(
            change_details,
            'DispatchTime: ',
            COALESCE(TIME_FORMAT(OLD.DispatchTime, '%H:%i:%s'), 'NULL'),
            ' -> ',
            COALESCE(TIME_FORMAT(NEW.DispatchTime, '%H:%i:%s'), 'NULL'),
            '; '
        );
    END IF;

    IF NOT (OLD.ReturnTime <=> NEW.ReturnTime) THEN
        SET change_details = CONCAT(
            change_details,
            'ReturnTime: ',
            COALESCE(TIME_FORMAT(OLD.ReturnTime, '%H:%i:%s'), 'NULL'),
            ' -> ',
            COALESCE(TIME_FORMAT(NEW.ReturnTime, '%H:%i:%s'), 'NULL'),
            '; '
        );
    END IF;

    -- Insert an audit row only when a tracked field changed.
    IF change_details <> '' THEN
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
            'UPDATE_TRIP',
            'SYSTEM',
            CURRENT_TIMESTAMP,
            CONCAT('Truck trip updated: ', change_details)
        );
    END IF;
END //

DELIMITER ;
