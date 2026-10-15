-- Trigger: trg_shipment_weekday_check
-- Description: Task W4b - Prevent inserting or updating a shipment date 
-- that does not match the train schedule's operating day of week.

DROP TRIGGER IF EXISTS trg_shipment_weekday_check_insert;
DROP TRIGGER IF EXISTS trg_shipment_weekday_check_update;

DELIMITER //

CREATE TRIGGER trg_shipment_weekday_check_insert
BEFORE INSERT ON Shipment
FOR EACH ROW
BEGIN
    DECLARE v_ScheduleDay VARCHAR(20);

    SELECT DayOfWeek INTO v_ScheduleDay
    FROM TrainSchedule
    WHERE ScheduleID = NEW.ScheduleID;

    IF v_ScheduleDay != DAYNAME(NEW.ShipmentDate) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Shipment date weekday does not match the train schedule operating day.';
    END IF;
END //

CREATE TRIGGER trg_shipment_weekday_check_update
BEFORE UPDATE ON Shipment
FOR EACH ROW
BEGIN
    DECLARE v_ScheduleDay VARCHAR(20);

    SELECT DayOfWeek INTO v_ScheduleDay
    FROM TrainSchedule
    WHERE ScheduleID = NEW.ScheduleID;

    IF v_ScheduleDay != DAYNAME(NEW.ShipmentDate) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Shipment date weekday does not match the train schedule operating day.';
    END IF;
END //

DELIMITER ;