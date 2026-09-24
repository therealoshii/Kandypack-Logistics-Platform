-- Kandypack Logistics Platform - Quarterly Sales Report
DROP PROCEDURE IF EXISTS sp_quarterly_sales_report;

DELIMITER //

CREATE PROCEDURE sp_quarterly_sales_report(
    IN p_Year INT,
    IN p_Quarter INT -- 1, 2, 3, 4 (or NULL for all quarters)
)
BEGIN
    SELECT 
        YEAR(o.OrderDate) AS OrderYear,
        QUARTER(o.OrderDate) AS OrderQuarter,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        COALESCE(SUM(od.Quantity), 0) AS TotalUnitsSold,
        COALESCE(SUM(od.Quantity * p.SpaceConsumption), 0) AS TotalVolumeSpace,
        COALESCE(SUM(o.TotalAmount), 0.00) AS TotalRevenueLKR
    FROM Orders o
    INNER JOIN OrderDetail od ON o.OrderID = od.OrderID
    INNER JOIN Product p ON od.ProductID = p.ProductID
    WHERE YEAR(o.OrderDate) = p_Year
      AND (p_Quarter IS NULL OR QUARTER(o.OrderDate) = p_Quarter)
      AND o.Status <> 'Cancelled'
    GROUP BY YEAR(o.OrderDate), QUARTER(o.OrderDate)
    ORDER BY OrderQuarter ASC;
END //

DELIMITER ;

