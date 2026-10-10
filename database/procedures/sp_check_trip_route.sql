-- Rule: a truck trip must make sense for its route
-- Requirements: SRS Section 4.3.3 / REQ-1 (trucks dispatch only from the store the route belongs to)
--               SRS Section 4.3.3 / REQ-2 (a trip must stay within the route's maximum delivery time)

-- Checks, in order:
--   1 - ReturnTime > DispatchTime (basic time sanity)
--   2 - The truck and the route both exist (clear message instead of a foreign key error)
--   3 - The truck is based at the same store as the route
--   4 - The trip is no longer than the route's MaxDeliveryTime (in hours)

-- Called first by trg_before_insert_trucktrip and trg_before_update_trucktrip, so these
-- clear errors appear before overlap and weekly-hours errors
-- p_SelfID is not needed here (no other trips are read), but every rule takes the same parameters

DROP PROCEDURE IF EXISTS sp_check_trip_route;

DELIMITER //

CREATE PROCEDURE sp_check_trip_route(IN p_SelfID INT, IN p_TruckID INT, IN p_RouteID INT,
                                     IN p_DriverID INT, IN p_AssistantID INT,
                                     IN p_Date DATE, IN p_Dispatch TIME, IN p_Return TIME)
BEGIN
    DECLARE truck_store INT DEFAULT NULL;
    DECLARE route_store INT DEFAULT NULL;
    DECLARE route_max_hours DECIMAL(5,2) DEFAULT NULL;

    -- 1.
    IF p_Return <= p_Dispatch THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: ReturnTime must be strictly later than DispatchTime.';
    END IF;

    -- 2.
    SELECT StoreID INTO truck_store
    FROM Truck
    WHERE TruckID = p_TruckID;

    SELECT StoreID, MaxDeliveryTime INTO route_store, route_max_hours
    FROM Route
    WHERE RouteID = p_RouteID;

    IF truck_store IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Truck does not exist.';
    END IF;

    IF route_store IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Route does not exist.';
    END IF;

    -- 3.
    IF truck_store <> route_store THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Route Violation: The Truck is based at a different store from this route.';
    END IF;

    -- 4.
    IF TIME_TO_SEC(TIMEDIFF(p_Return, p_Dispatch)) / 3600.0 > route_max_hours THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Route Violation: The trip is longer than the route''s maximum delivery time.';
    END IF;
END //

DELIMITER ;
