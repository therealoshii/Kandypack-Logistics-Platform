-- This function is used to find the correct route for the customer based on their DeliveryArea

-- if there is already a function in the same name then delete it
DROP FUNCTION IF EXISTS fn_get_route_for_address;

DELIMITER //

CREATE FUNCTION fn_get_route_for_address(p_CustomerID INT) 
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    -- create a variable as v_route_id for storing the route id and set it to null
    DECLARE v_route_id INT DEFAULT NULL;

    -- Match route directly through the customer's AreaID (D2 & H3)
    SELECT a.RouteID 
    INTO v_route_id
    FROM Customer c 
    JOIN DeliveryArea a ON a.AreaID = c.AreaID
    WHERE c.CustomerID = p_CustomerID;

    RETURN v_route_id;
END //

DELIMITER ;