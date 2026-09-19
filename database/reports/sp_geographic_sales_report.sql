DROP PROCEDURE IF EXISTS sp_geographic_sales_report;

DELIMITER //

CREATE PROCEDURE sp_geographic_sales_report(
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
    SELECT
        s.City,
        r.RouteID,
        r.RouteName,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        COALESCE(SUM(od.Quantity), 0) AS TotalUnits,
        COALESCE(SUM(od.LineTotal), 0.00) AS TotalSales

    FROM Orders o
    INNER JOIN Route r
        ON o.RouteID = r.RouteID
    INNER JOIN Store s
        ON r.StoreID = s.StoreID
    INNER JOIN OrderDetail od
        ON o.OrderID = od.OrderID

    WHERE o.OrderDate BETWEEN p_StartDate AND p_EndDate

    GROUP BY
        s.City,
        r.RouteID,
        r.RouteName

    ORDER BY
        s.City,
        r.RouteID;
END //

DELIMITER ;