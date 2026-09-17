DELIMITER //

CREATE FUNCTION fn_calculate_total_space(
    p_ProductID INT,
    p_Quantity INT
) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_SpaceRate DECIMAL(8, 2);
    DECLARE v_TotalSpace DECIMAL(10, 2);

    SELECT SpaceConsumption INTO v_SpaceRate
    FROM Product
    WHERE ProductID = p_ProductID;

    SET v_TotalSpace = p_Quantity * IFNULL(v_SpaceRate, 0.00);
    RETURN v_TotalSpace;
END //

DELIMITER ;