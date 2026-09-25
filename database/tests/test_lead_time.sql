-- TEST CASE 1: Invalid Lead Time
 
-- CALL sp_place_order(
--     1,
--     DATE_ADD(CURDATE(), INTERVAL 3 DAY),
--     '[{"productId": 1, "quantity": 10}]',
--     @v_order_id
-- );
 
-- TEST CASE 2: Valid Lead Time
CALL sp_place_order(
    1,
    DATE_ADD(CURDATE(), INTERVAL 8 DAY),
    '[{"productId": 1, "quantity": 15}, {"productId": 2, "quantity": 10}]',
    @v_order_id
);

-- verify created order
SELECT 
    o.OrderID, o.CustomerID, c.FullName, c.City,
    o.RouteID, r.RouteName, o.OrderDate, o.Status, o.TotalAmount
FROM Orders o
INNER JOIN Customer c ON o.CustomerID = c.CustomerID
INNER JOIN Route r ON o.RouteID = r.RouteID
WHERE o.OrderID = @v_order_id;

-- verify line items
SELECT 
    od.OrderDetailID, od.OrderID, p.ProductName,
    od.Quantity, p.UnitPrice, od.LineTotal
FROM OrderDetail od
INNER JOIN Product p ON od.ProductID = p.ProductID
WHERE od.OrderID = @v_order_id;
