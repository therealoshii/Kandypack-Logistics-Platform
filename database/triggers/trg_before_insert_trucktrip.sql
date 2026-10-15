-- Before-insert/update triggers for TruckTrip: delegates validation to five check procedures.
-- Insert passes NULL (no ID yet); update passes TripID so procedures skip its own row.

DROP TRIGGER IF EXISTS trg_before_insert_trucktrip;
DROP TRIGGER IF EXISTS trg_before_update_trucktrip;

DELIMITER //

CREATE TRIGGER trg_before_insert_trucktrip
BEFORE INSERT ON TruckTrip
FOR EACH ROW
BEGIN
    CALL sp_check_trip_route           (NULL, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_schedule_conflict    (NULL,NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_driver_consecutive   (NULL, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_assistant_consecutive(NULL, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_weekly_hours         (NULL, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
END //

CREATE TRIGGER trg_before_update_trucktrip
BEFORE UPDATE ON TruckTrip
FOR EACH ROW
BEGIN
    CALL sp_check_trip_route           (NEW.TripID, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_schedule_conflict    (NEW.TripID,NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_driver_consecutive   (NEW.TripID, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_assistant_consecutive(NEW.TripID, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_weekly_hours         (NEW.TripID, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
END //

DELIMITER ;