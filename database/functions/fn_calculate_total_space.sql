DROP FUNCTION IF EXISTS fn_calculate_total_space;

DELIMITER //

CREATE FUNCTION fn_calculate_total_space(
    p_ProductID INT,
    p_Quantity INT
) 
RETURNS DECIMAL(10, 2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_SpaceRate DECIMAL(8, 2);
    DECLARE v_TotalSpace DECIMAL(10, 2);

    -- Retrieve the space consumption rate for the product
    SELECT SpaceConsumption INTO v_SpaceRate
    FROM Product
    WHERE ProductID = p_ProductID;
    
    -- If the product does not exist, raise an error instead of defaulting to 0
    IF v_SpaceRate IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product does not exist or has no defined space consumption rate.';
    END IF;

    SET v_TotalSpace = p_Quantity * v_SpaceRate;
    RETURN v_TotalSpace;
END //

DELIMITER ;