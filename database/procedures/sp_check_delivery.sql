-- Rule: a Delivery must fit the Order it delivers and the TruckTrip that carries it
-- Requirement: SRS Section 4.3.3 / REQ-4

-- Checks, in order:
--   1 - The order and the trip both exist (clear message instead of a foreign key error)
--   2 - The trip is on the same route as the order
--   3 - The delivery date is the trip's date
--   4 - The delivery is at least 7 days after the order was placed (SRS Section 4.2.3 / REQ-1)
--   5 - Every order line is booked on a train, and the truck trip leaves after the last train
--       carrying the order arrives at the store (SRS Section 4.3.2 to 4.3.3: rail first, then road)

-- Called by trg_before_insert_delivery and trg_before_update_delivery (see triggers/trg_validate_delivery.sql),
-- so the rule exists in one place, the same way as the sp_check_* truck trip rules (decision D6)

-- Check 4 uses OrderDate + 7 days. RequestedDeliveryDate is already checked against OrderDate
-- when the order is placed, so this rule does not depend on that column

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