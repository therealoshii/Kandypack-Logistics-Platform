-- if there is any procedure in same name then delete it
DROP PROCEDURE IF EXISTS sp_place_order;

DELIMITER //

CREATE PROCEDURE sp_place_order(
    IN p_CustomerID INT,
    IN p_DeliveryDate DATE,
    IN p_Items JSON,
    OUT p_OrderID INT
)
proc_label: BEGIN
    -- declare variables
    DECLARE v_lead_time_days INT;
    DECLARE v_customer_city VARCHAR(50);
    DECLARE v_route_id INT;
    DECLARE v_total_amount DECIMAL(12,2) DEFAULT 0.00;
    DECLARE v_item_count INT;
    DECLARE i INT DEFAULT 0;
    
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_unit_price DECIMAL(12,2);
    DECLARE v_line_total DECIMAL(12,2);
    DECLARE v_stock INT;

    -- Error handler for transaction rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. validate 7 day advance lead time rule
    SET v_lead_time_days = DATEDIFF(p_DeliveryDate, CURDATE());
    IF v_lead_time_days < 7 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Advance Order Placement Rule Violation: Orders must be placed at least 7 days before expected delivery date.';
    END IF;

    -- 2.validate customer existence and get destination city--
    SELECT City INTO v_customer_city
    FROM Customer
    WHERE CustomerID = p_CustomerID;

    IF v_customer_city IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Customer does not exist.';
    END IF;

    -- 3.automatically match route for destination address--
    SET v_route_id = fn_get_route_for_address(v_customer_city);

    -- 4. ACID Transaction
    START TRANSACTION;

    -- insert order master record
    INSERT INTO Orders (CustomerID, RouteID, AdminID, OrderDate, Status, TotalAmount)
    VALUES (p_CustomerID, v_route_id, NULL, CURDATE(), 'Placed', 0.00);

    SET p_OrderID = LAST_INSERT_ID();

    -- 5. process JSON items array
    SET v_item_count = JSON_LENGTH(p_Items);
    IF v_item_count IS NULL OR v_item_count = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Order must contain at least one product item.';
    END IF;

    WHILE i < v_item_count DO
        SET v_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_Items, CONCAT('$[', i, '].productId')));
        SET v_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_Items, CONCAT('$[', i, '].quantity')));

        IF v_quantity <= 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Quantity must be greater than zero.';
        END IF;

        -- retrieve price and stock
        SELECT UnitPrice, StockQuantity
        INTO v_unit_price, v_stock
        FROM Product
        WHERE ProductID = v_product_id;

        IF v_unit_price IS NULL THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Product does not exist.';
        END IF;

        -- validate sufficient stock
        IF v_stock < v_quantity THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient Stock: Requested quantity exceeds available inventory.';
        END IF;

        SET v_line_total = v_quantity * v_unit_price;
        SET v_total_amount = v_total_amount + v_line_total;

        -- insert order detail
        INSERT INTO OrderDetail (OrderID, ProductID, Quantity, LineTotal)
        VALUES (p_OrderID, v_product_id, v_quantity, v_line_total);

        SET i = i + 1;
    END WHILE;

    -- order total Amount
    UPDATE Orders
    SET TotalAmount = v_total_amount
    WHERE OrderID = p_OrderID;

    -- log transaction in AuditLog
    INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
    VALUES ('Orders', 'INSERT', p_OrderID, 'CUSTOMER', CONCAT('Order placed with ', v_item_count, ' items. Total: LKR ', v_total_amount));

    COMMIT;
END //

DELIMITER ;