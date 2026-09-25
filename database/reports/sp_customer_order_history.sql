-- Kandypack Logistics Platform - Customer Order History Report


DROP PROCEDURE IF EXISTS sp_customer_order_history;

DELIMITER //

CREATE PROCEDURE sp_customer_order_history(
    IN p_CustomerID INT
)
BEGIN
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.Status AS OrderStatus,
        o.TotalAmount AS OrderTotalLKR,
        r.RouteName,
        s.City AS DestinationCity,
        d.DeliveryID,
        d.DeliveryDate,
        COALESCE(d.Status, 'Pending Assignment') AS DeliveryStatus,
        tt.TripID,
        drv.Name AS AssignedDriver,
        ast.Name AS AssignedAssistant,
        t.RegistrationNumber AS AssignedTruck,
        COUNT(od.OrderDetailID) AS TotalItemLines,
        COALESCE(SUM(od.Quantity), 0) AS TotalUnitsOrdered
    FROM Orders o
    INNER JOIN Customer c ON o.CustomerID = c.CustomerID
    INNER JOIN Route r ON o.RouteID = r.RouteID
    INNER JOIN Store s ON r.StoreID = s.StoreID
    LEFT JOIN OrderDetail od ON o.OrderID = od.OrderID
    LEFT JOIN Delivery d ON o.OrderID = d.OrderID
    LEFT JOIN TruckTrip tt ON d.TripID = tt.TripID
    LEFT JOIN Driver drv ON tt.DriverID = drv.DriverID
    LEFT JOIN Assistant ast ON tt.AssistantID = ast.AssistantID
    LEFT JOIN Truck t ON tt.TruckID = t.TruckID
    WHERE o.CustomerID = p_CustomerID
    GROUP BY o.OrderID, o.OrderDate, o.Status, o.TotalAmount, r.RouteName, s.City, 
             d.DeliveryID, d.DeliveryDate, d.Status, tt.TripID, drv.Name, ast.Name, t.RegistrationNumber
    ORDER BY o.OrderDate DESC, o.OrderID DESC;
END //

DELIMITER ;

