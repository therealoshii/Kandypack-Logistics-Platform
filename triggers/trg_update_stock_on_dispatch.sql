DELIMITER //

CREATE TRIGGER trg_update_stock_on_dispatch
AFTER INSERT ON Shipment
FOR EACH ROW
BEGIN
    DECLARE v_ProductID INT;

    SELECT ProductID INTO v_ProductID
    FROM OrderDetail
    WHERE OrderDetailID = NEW.OrderDetailID;

    UPDATE Product
    SET StockQuantity = StockQuantity - NEW.Quantity
    WHERE ProductID = v_ProductID;
END //

DELIMITER ;