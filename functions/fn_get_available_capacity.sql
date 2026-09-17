DELIMITER //

CREATE FUNCTION fn_get_available_capacity(
    p_ScheduleID INT,
    p_ShipmentDate DATE
) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_MaxCapacity DECIMAL(10, 2);
    DECLARE v_UsedSpace DECIMAL(10, 2);

    SELECT CargoCapacity INTO v_MaxCapacity
    FROM TrainSchedule
    WHERE ScheduleID = p_ScheduleID;

    SELECT IFNULL(SUM(s.Quantity * p.SpaceConsumption), 0.00)
    INTO v_UsedSpace
    FROM Shipment s
    JOIN OrderDetail od ON s.OrderDetailID = od.OrderDetailID
    JOIN Product p ON od.ProductID = p.ProductID
    WHERE s.ScheduleID = p_ScheduleID 
      AND s.ShipmentDate = p_ShipmentDate;

    RETURN (v_MaxCapacity - v_UsedSpace);
END //

DELIMITER ;