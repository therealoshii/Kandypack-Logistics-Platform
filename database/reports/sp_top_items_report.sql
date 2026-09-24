-- Kandypack Logistics Platform - Most Ordered Products Report


DROP PROCEDURE IF EXISTS sp_top_items_report;

DELIMITER //

CREATE PROCEDURE sp_top_items_report(
    IN p_Year INT,
    IN p_Quarter INT,
    IN p_Limit INT
)
BEGIN
    DECLARE v_limit INT;
    SET v_limit = COALESCE(p_Limit, 10);

    SELECT 
        p.ProductID,
        p.ProductName,
        p.Category,
        p.UnitPrice,
        SUM(od.Quantity) AS TotalQuantityOrdered,
        SUM(od.LineTotal) AS TotalRevenueGenerated,
        COUNT(DISTINCT o.OrderID) AS DistinctOrdersCount
    FROM OrderDetail od
    INNER JOIN Product p ON od.ProductID = p.ProductID
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate) = p_Year
      AND QUARTER(o.OrderDate) = p_Quarter
      AND o.Status <> 'Cancelled'
    GROUP BY p.ProductID, p.ProductName, p.Category, p.UnitPrice
    ORDER BY TotalQuantityOrdered DESC
    LIMIT v_limit;
END //

DELIMITER ;

