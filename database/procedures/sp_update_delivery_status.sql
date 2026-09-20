-- This procedure manages the process of the final delivery 
-- It keeps the main customer order in sync


DROP PROCEDURE IF EXISTS sp_update_delivery_status;

DELIMITER //

CREATE PROCEDURE sp_update_delivery_status(IN p_DeliveryID INT, IN p_NewStatus VARCHAR(30), 
                                            IN p_ChangedBy VARCHAR(50))
BEGIN
    DECLARE order_id INT;
    DECLARE current_status VARCHAR(30);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- If something fails during execution
    BEGIN
        ROLLBACK; -- Undo the changes that has been done
        RESIGNAL; -- Sends the error to the caller
    END;

    -- Validate status input
    IF p_NewStatus NOT IN ('Scheduled', 'In Transit', 'Delivered', 'Cancelled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Invalid delivery status value.';
    END IF;

    -- Select current order_id and current_status
    SELECT OrderID, Status
    INTO order_id, current_status
    FROM Delivery
    WHERE DeliveryID = p_DeliveryID;

    -- If order_id is NULL
    IF order_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Delivery record not found.';
    END IF;

    -- Cannot change status after 'Delivered'
    IF current_status = 'Delivered' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'State Error: Cannot change status — delivery is already completed.';
    END IF;

    -- Cannot change status after 'Cancelled'
    IF current_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'State Error: Cannot change status — delivery has been cancelled.';
    END IF;

    -- Cannot change from 'In Transit' to 'Scheduled'
    IF current_status = 'In Transit' AND p_NewStatus = 'Scheduled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'State Error: Cannot revert from In Transit to Scheduled.';
    END IF;

END //

DELIMITER ;