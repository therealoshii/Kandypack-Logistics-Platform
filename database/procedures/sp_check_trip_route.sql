-- RULE: Trip must match its route constraints (SRS 4.3.3 / REQ-1, REQ-2)
-- Validates:
-- 1. ReturnTime > DispatchTime.
-- 2. Truck and Route exist.
-- 3. Truck belongs to the route's store.
-- 4. Trip duration <= route's MaxDeliveryTime.
-- Called first by trg_before_insert/update_trucktrip.

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
