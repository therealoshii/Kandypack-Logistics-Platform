-- For the checks that needs to be done before a TruckTrip is inserted OR updated

-- Each rule lives in its own procedure (decision D6), so the logic exists in one place:
--   1 - sp_check_trip_route             : ReturnTime > DispatchTime, truck from the route's store,
--                                         trip within the route's MaxDeliveryTime (SRS 4.3.3 / REQ-1 & REQ-2)
--   2 - sp_check_schedule_conflict      : no overlapping Truck / Driver / Assistant bookings (SRS 4.4 / REQ-6)
--   3 - sp_check_driver_consecutive     : Driver needs 30 min rest between trips (SRS 4.4 / REQ-2)
--   4 - sp_check_assistant_consecutive  : Assistant max 2 consecutive trips (SRS 4.4 / REQ-3)
--   5 - sp_check_weekly_hours           : Driver 40h and Assistant 60h weekly caps (SRS 4.4 / REQ-4 & REQ-5)

-- The insert trigger passes NULL as the first argument (the trip has no ID yet).
-- The update trigger passes the trip's own TripID, so the procedures skip its old row.
-- Before, the rules only ran on INSERT, so an UPDATE could move a trip into an overlap.

-- The procedures must be created before this file runs (see run_all.sql)

DROP TRIGGER IF EXISTS trg_before_insert_trucktrip;
DROP TRIGGER IF EXISTS trg_before_update_trucktrip;

DELIMITER //

CREATE TRIGGER trg_before_insert_trucktrip
BEFORE INSERT ON TruckTrip -- checking before we insert a record
FOR EACH ROW
BEGIN
    CALL sp_check_trip_route           (NULL, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_schedule_conflict    (NULL,NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_driver_consecutive   (NULL, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_assistant_consecutive(NULL, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_weekly_hours         (NULL, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
END //

CREATE TRIGGER trg_before_update_trucktrip
BEFORE UPDATE ON TruckTrip -- the same checks when an existing trip is changed
FOR EACH ROW
BEGIN
    CALL sp_check_trip_route           (NEW.TripID, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_schedule_conflict    (NEW.TripID,NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_driver_consecutive   (NEW.TripID, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_assistant_consecutive(NEW.TripID, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
    CALL sp_check_weekly_hours         (NEW.TripID, NEW.TruckID, NEW.RouteID, NEW.DriverID, NEW.AssistantID, NEW.TripDate, NEW.DispatchTime, NEW.ReturnTime);
END //

DELIMITER ;