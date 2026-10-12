-- For the checks that needs to be done before a Delivery is inserted OR updated
-- Requirement: SRS Section 4.3.3 / REQ-4

-- The rule itself lives in sp_check_delivery (procedures/sp_check_delivery.sql):
--   - the trip is on the same route as the order
--   - the delivery date is the trip's date
--   - the delivery is at least 7 days after the order date

-- The update trigger only runs the rule when the order, the trip or the date changes.
-- A status change (sp_update_delivery_status) does not touch those, so it is not checked again.

-- sp_check_delivery must be created before this file runs (see run_all.sql)

DROP TRIGGER IF EXISTS trg_before_insert_delivery;
DROP TRIGGER IF EXISTS trg_before_update_delivery;

DELIMITER //

CREATE TRIGGER trg_before_insert_delivery
BEFORE INSERT ON Delivery -- checking before we insert a record
FOR EACH ROW
BEGIN
    CALL sp_check_delivery(NEW.OrderID, NEW.TripID, NEW.DeliveryDate);
END //

CREATE TRIGGER trg_before_update_delivery
BEFORE UPDATE ON Delivery -- the same checks when an existing delivery is moved
FOR EACH ROW
BEGIN
    IF NEW.OrderID <> OLD.OrderID OR NEW.TripID <> OLD.TripID OR NEW.DeliveryDate <> OLD.DeliveryDate THEN
        CALL sp_check_delivery(NEW.OrderID, NEW.TripID, NEW.DeliveryDate);
    END IF;
END //

DELIMITER ;