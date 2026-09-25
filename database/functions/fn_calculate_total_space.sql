DROP FUNCTION IF EXISTS fn_calculate_total_space;

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
    

    IF v_SpaceRate IS NULL THEN
        SET v_SpaceRate = 0.00; -- Default to 0 if no space rate is found
    END IF;
    SET v_TotalSpace = p_Quantity * v_SpaceRate;
    RETURN v_TotalSpace;
END //

DELIMITER ;