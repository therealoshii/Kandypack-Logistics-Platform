-- Kandypack Logistics Platform - Order Summary View


DROP VIEW IF EXISTS vw_order_summary;

CREATE VIEW vw_order_summary AS
SELECT 
    o.OrderID,
    o.OrderDate,
    o.Status AS OrderStatus,
    o.TotalAmount AS OrderTotalLKR,
    c.CustomerID,
    c.FullName AS CustomerName,
    c.City AS CustomerCity,
    c.ContactNumber AS CustomerContact,
    r.RouteID,
    r.RouteName,
    s.StoreID,
    s.StoreName,
    COUNT(od.OrderDetailID) AS TotalLineItems,
    COALESCE(SUM(od.Quantity), 0) AS TotalUnitsOrdered,
    COALESCE(SUM(od.Quantity * p.SpaceConsumption), 0.00) AS TotalSpaceRequired,
    d.DeliveryID,
    d.DeliveryDate,
    COALESCE(d.Status, 'Unscheduled') AS DeliveryStatus
FROM Orders o
INNER JOIN Customer c ON o.CustomerID = c.CustomerID
INNER JOIN Route r ON o.RouteID = r.RouteID
INNER JOIN Store s ON r.StoreID = s.StoreID
LEFT JOIN OrderDetail od ON o.OrderID = od.OrderID
LEFT JOIN Product p ON od.ProductID = p.ProductID
LEFT JOIN Delivery d ON o.OrderID = d.OrderID
GROUP BY 
    o.OrderID, o.OrderDate, o.Status, o.TotalAmount,
    c.CustomerID, c.FullName, c.City, c.ContactNumber,
    r.RouteID, r.RouteName, s.StoreID, s.StoreName,
    d.DeliveryID, d.DeliveryDate, d.Status;

