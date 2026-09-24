--This function is used to find the correct route for the address given by customer--

--if there is already a function in the same name then delete it--
DROP FUNCTION IF EXISTS fn_get_route_for_address;

DELIMITER //
--create a funtion as fn_get_route_for_address--
--this gets p_City as input  and return an integer output--
CREATE FUNCTION fn_get_route_for_address(p_City VARCHAR(50)) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    --create a variable as v_route_id for storing the route id and set it to null--
    DECLARE v_route_id INT DEFAULT NULL;

    -- 1.match route through the regional store located in that destination city--
    SELECT r.RouteID
    INTO v_route_id
    FROM Route r
    INNER JOIN Store s ON r.StoreID = s.StoreID
    WHERE LOWER(TRIM(s.City)) = LOWER(TRIM(p_City))
    ORDER BY r.RouteID ASC
    LIMIT 1;

    -- 2.match by RouteName if city name is in RouteName--
    IF v_route_id IS NULL THEN
        SELECT RouteID
        INTO v_route_id
        FROM Route
        WHERE LOWER(RouteName) LIKE CONCAT('%', LOWER(TRIM(p_City)), '%')
        ORDER BY RouteID ASC
        LIMIT 1;
    END IF;

    -- 3.default fallback if no match found
    IF v_route_id IS NULL THEN
        SELECT RouteID INTO v_route_id FROM Route ORDER BY RouteID ASC LIMIT 1;
    END IF;

    RETURN v_route_id;
END //

DELIMITER ;
