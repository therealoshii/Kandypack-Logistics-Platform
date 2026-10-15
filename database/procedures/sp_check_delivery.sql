-- RULE: Delivery must match its Order and TruckTrip (SRS 4.3.3 / REQ-4)
-- Validates:
-- 1. Order and Trip exist.
-- 2. Trip is on the order's route on the same date.
-- 3. Delivery date is >= OrderDate + 7 days.
-- 4. All lines arrived by rail before truck departs.
-- Called by trg_before_insert/update_delivery.

DROP PROCEDURE IF EXISTS sp_check_delivery;

DELIMITER //

CREATE PROCEDURE sp_check_delivery(IN p_OrderID INT, IN p_TripID INT, IN p_DeliveryDate DATE)
BEGIN
    DECLARE order_route INT DEFAULT NULL;
    DECLARE order_date DATE DEFAULT NULL;
    DECLARE trip_route INT DEFAULT NULL;
    DECLARE trip_date DATE DEFAULT NULL;
    DECLARE trip_start DATETIME DEFAULT NULL;
    DECLARE units_waiting INT DEFAULT 0;
    DECLARE last_arrival DATETIME DEFAULT NULL;

    -- 1.
    SELECT RouteID, OrderDate INTO order_route, order_date
    FROM Orders
    WHERE OrderID = p_OrderID;

    SELECT RouteID, TripDate, TIMESTAMP(TripDate, DispatchTime) INTO trip_route, trip_date, trip_start
    FROM TruckTrip
    WHERE TripID = p_TripID;

    IF order_route IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Order does not exist.';
    END IF;

    IF trip_route IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Truck trip does not exist.';
    END IF;

    -- 2.
    IF trip_route <> order_route THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivery Violation: The truck trip is on a different route from the order.';
    END IF;

    -- 3.
    IF p_DeliveryDate <> trip_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivery Violation: The delivery date must match the truck trip date.';
    END IF;

    -- 4.
    IF DATEDIFF(p_DeliveryDate, order_date) < 7 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivery Violation: The delivery must be at least 7 days after the order date.';
    END IF;

    -- 5.
    SELECT CAST(COALESCE(SUM(od.Quantity - COALESCE(
               (SELECT SUM(s.Quantity) FROM Shipment s WHERE s.OrderDetailID = od.OrderDetailID), 0)), 0) AS SIGNED)
    INTO units_waiting
    FROM OrderDetail od
    WHERE od.OrderID = p_OrderID;

    IF units_waiting > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivery Violation: Part of the order is still waiting for a train.';
    END IF;

    SELECT MAX(TIMESTAMP(s.ShipmentDate, ts.ArrivalTime)) INTO last_arrival
    FROM Shipment s
    JOIN OrderDetail od ON od.OrderDetailID = s.OrderDetailID
    JOIN TrainSchedule ts ON ts.ScheduleID = s.ScheduleID
    WHERE od.OrderID = p_OrderID;

    IF last_arrival > trip_start THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivery Violation: The truck trip leaves before the order arrives at the store by train.';
    END IF;
END //

DELIMITER ;