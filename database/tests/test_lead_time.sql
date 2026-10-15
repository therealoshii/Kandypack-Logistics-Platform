-- Tests sp_place_order: lead time validation, product checks, route resolution, and stock limits.

-- TEST 1: Invalid lead time – should fail (3 days is too short)
-- CALL sp_place_order(
--     1,
--     DATE_ADD(CURDATE(), INTERVAL 3 DAY),
--     '[{"productId": 1, "quantity": 10}]',
--     @v_order_id
-- );

-- TEST 2: Valid lead time – should succeed
CALL sp_place_order(
    1,
    DATE_ADD(CURDATE(), INTERVAL 8 DAY),
    '[{"productId": 1, "quantity": 15}, {"productId": 2, "quantity": 10}]',
    @v_order_id
);

SELECT
    o.OrderID, o.CustomerID, c.FullName, da.AreaName,
    o.RouteID, r.RouteName, o.OrderDate, o.RequestedDeliveryDate, o.Status, o.TotalAmount
FROM Orders o
INNER JOIN Customer c ON o.CustomerID = c.CustomerID
INNER JOIN DeliveryArea da ON c.AreaID = da.AreaID
INNER JOIN Route r ON o.RouteID = r.RouteID
WHERE o.OrderID = @v_order_id;

SELECT
    od.OrderDetailID, od.OrderID, p.ProductName,
    od.Quantity, p.UnitPrice, od.LineTotal
FROM OrderDetail od
INNER JOIN Product p ON od.ProductID = p.ProductID
WHERE od.OrderID = @v_order_id;

-- TEST 3: Unknown product in list – should fail and roll back
-- CALL sp_place_order(
--     1,
--     DATE_ADD(CURDATE(), INTERVAL 8 DAY),
--     '[{"productId": 1, "quantity": 5}, {"productId": 999, "quantity": 1}]',
--     @v_order_id_3
-- );
-- Expected error: "Validation Error: Product does not exist."

-- TEST 4: Customer route resolution (Nugegoda -> Route 2, Colpetty -> Route 1)
SELECT
    c.CustomerID,
    c.FullName,
    da.AreaName,
    fn_get_route_for_address(c.CustomerID) AS ResolvedRouteID
FROM Customer c
INNER JOIN DeliveryArea da ON c.AreaID = da.AreaID
WHERE c.CustomerID IN (1, 7);

-- TEST 5: Insufficient stock – should fail with no partial rows
-- CALL sp_place_order(
--     1,
--     DATE_ADD(CURDATE(), INTERVAL 8 DAY),
--     '[{"productId": 1, "quantity": 999999}]',
--     @v_order_id_5
-- );
-- Expected error: "Insufficient Stock: Requested quantity exceeds available inventory."