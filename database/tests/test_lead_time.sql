-- TEST CASE 1: Invalid Lead Time (Should fail with advance order rule violation)
-- CALL sp_place_order(
--     1,
--     DATE_ADD(CURDATE(), INTERVAL 3 DAY),
--     '[{"productId": 1, "quantity": 10}]',
--     @v_order_id
-- );

-- TEST CASE 2: Valid Lead Time (Should succeed)
CALL sp_place_order(
    1,
    DATE_ADD(CURDATE(), INTERVAL 8 DAY),
    '[{"productId": 1, "quantity": 15}, {"productId": 2, "quantity": 10}]',
    @v_order_id
);

-- verify created order (Updated to use DeliveryArea instead of removed Customer.City)
SELECT 
    o.OrderID, o.CustomerID, c.FullName, da.AreaName,
    o.RouteID, r.RouteName, o.OrderDate, o.RequestedDeliveryDate, o.Status, o.TotalAmount
FROM Orders o
INNER JOIN Customer c ON o.CustomerID = c.CustomerID
INNER JOIN DeliveryArea da ON c.AreaID = da.AreaID
INNER JOIN Route r ON o.RouteID = r.RouteID
WHERE o.OrderID = @v_order_id;

-- verify line items
SELECT 
    od.OrderDetailID, od.OrderID, p.ProductName,
    od.Quantity, p.UnitPrice, od.LineTotal
FROM OrderDetail od
INNER JOIN Product p ON od.ProductID = p.ProductID
WHERE od.OrderID = @v_order_id;


-- =========================================================================
-- TEST CASE 3: Unknown product as a later item (Should fail and roll back)
-- =========================================================================
-- CALL sp_place_order(
--     1,
--     DATE_ADD(CURDATE(), INTERVAL 8 DAY),
--     '[{"productId": 1, "quantity": 5}, {"productId": 999, "quantity": 1}]',
--     @v_order_id_3
-- );
-- Expected error: "Validation Error: Product does not exist."


-- =========================================================================
-- TEST CASE 4: Customer route verification (Nugegoda -> Route 2, Colpetty -> Route 1)
-- =========================================================================
SELECT 
    c.CustomerID, 
    c.FullName, 
    da.AreaName, 
    fn_get_route_for_address(c.CustomerID) AS ResolvedRouteID
FROM Customer c
INNER JOIN DeliveryArea da ON c.AreaID = da.AreaID
WHERE c.CustomerID IN (1, 7);


-- =========================================================================
-- TEST CASE 5: Insufficient stock (Should fail and leave no partial rows)
-- =========================================================================
-- CALL sp_place_order(
--     1,
--     DATE_ADD(CURDATE(), INTERVAL 8 DAY),
--     '[{"productId": 1, "quantity": 999999}]',
--     @v_order_id_5
-- );
-- Expected error: "Insufficient Stock: Requested quantity exceeds available inventory."