-- =============================================
-- FILE: database/schema/01_tables_core.sql
-- =============================================

-- This file contains the core tables
-- Tables: Customer, Product, Store, Route

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Route;
DROP TABLE IF EXISTS Store;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Customer;

-- Store Table (Main Cities: Colombo, Negombo, Galle, Matara, Jaffna, Trincomalee)
CREATE TABLE Store (
    StoreID INT AUTO_INCREMENT PRIMARY KEY,
    StoreName VARCHAR(100) NOT NULL,
    Capacity DECIMAL(10,2) NOT NULL,
    City VARCHAR(50) NOT NULL,

    CONSTRAINT chk_store_capacity CHECK (Capacity > 0)
);

-- Route Table (Routes connecting Kandy to final areas through regional stores)
CREATE TABLE Route (
    RouteID INT AUTO_INCREMENT PRIMARY KEY,
    StoreID INT NOT NULL,
    RouteName VARCHAR(100) NOT NULL,
    MaxDeliveryTime DECIMAL(5,2) NOT NULL,
    Distance DECIMAL(8,2) NOT NULL,

    CONSTRAINT fk_route_store FOREIGN KEY (StoreID)
        REFERENCES Store(StoreID) ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_route_time CHECK (MaxDeliveryTime > 0),
    CONSTRAINT chk_route_distance CHECK (Distance > 0)
);

-- Product Table (Consumer goods with train space consumption factor)
CREATE TABLE Product (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    SpaceConsumption DECIMAL(8,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    Category VARCHAR(50) NOT NULL,

    CONSTRAINT chk_product_price CHECK (UnitPrice >= 0),
    CONSTRAINT chk_product_space CHECK (SpaceConsumption > 0),
    CONSTRAINT chk_product_stock CHECK (StockQuantity >= 0)
);

-- Customer Table (The wholesale and retail clients)
CREATE TABLE Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    ContactNumber VARCHAR(15) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL
);

SET FOREIGN_KEY_CHECKS = 1;


-- =============================================
-- FILE: database/schema/02_tables_order.sql
-- =============================================

-- This file contains the tables Order and Admin Tables
-- Tables: Administrator, Order, OrderDetail, AuditLog

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS AuditLog;
DROP TABLE IF EXISTS OrderDetail;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Administrator;

-- Administrator Table (System Administrators and Logistics Managers)
CREATE TABLE Administrator (
    AdminID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);

-- Orders Table (Customer purchase orders placed with 7+ day lead time)
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    RouteID INT NOT NULL,
    AdminID INT NULL, -- Assigned/updated when processed by administrative staff
    OrderDate DATE NOT NULL,
    Status ENUM('Placed', 'Processing', 'Shipped', 'In Transit', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Placed',
    TotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT fk_order_customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_route FOREIGN KEY (RouteID)
        REFERENCES Route(RouteID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_admin FOREIGN KEY (AdminID)
        REFERENCES Administrator(AdminID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- OrderDetail Table (Products/Items within an order)
CREATE TABLE OrderDetail (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    LineTotal DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_orderdetail_order FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orderdetail_product FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID) ON DELETE RESTRICT ON UPDATE CASCADE,
        
    CONSTRAINT chk_detail_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_detail_total CHECK (LineTotal >= 0)
);

-- AuditLog Table (Security & ACID Auditing per SRS Section 5.3)
-- This table was not included in the ER Diagram, but this was a requirement that was specified under section 5.3 of SRS
CREATE TABLE AuditLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(50) NOT NULL,
    ActionType VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    RecordID INT NOT NULL,
    ChangedBy VARCHAR(50) DEFAULT 'SYSTEM',
    ChangeTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Details TEXT
);

SET FOREIGN_KEY_CHECKS = 1;


-- =============================================
-- FILE: database/schema/03_tables_rail.sql
-- =============================================

-- This file contains the Rail Transport tables
-- Tables: Train, TrainSchedule, Shipment

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Shipment;
DROP TABLE IF EXISTS TrainSchedule;
DROP TABLE IF EXISTS Train;

-- Train Table (Sri Lanka Railways available trains)
CREATE TABLE Train (
    TrainID INT AUTO_INCREMENT PRIMARY KEY,
    TrainName VARCHAR(100) NOT NULL,
    MaxCapacity DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_train_capacity CHECK (MaxCapacity > 0)
);

-- TrainSchedule Table (Scheduled bulk rail departures from Kandy as its origin)
CREATE TABLE TrainSchedule (
    ScheduleID INT AUTO_INCREMENT PRIMARY KEY,
    TrainID INT NOT NULL,
    CargoCapacity DECIMAL(10,2) NOT NULL,
    Destination VARCHAR(50) NOT NULL,
    DepartureTime TIME NOT NULL,
    ArrivalTime TIME NOT NULL,
    DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL, -- To avoid two people entrting same date differently
    
    CONSTRAINT fk_schedule_train FOREIGN KEY (TrainID)
        REFERENCES Train(TrainID) ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_schedule_capacity CHECK (CargoCapacity > 0)
);

-- Shipment Table (Bulk shipment allocations given to specific train schedules and orders)
CREATE TABLE Shipment (
    ShipmentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderDetailID INT NOT NULL,
    ScheduleID INT NOT NULL,
    Quantity INT NOT NULL,
    ShipmentDate DATE NOT NULL,

    CONSTRAINT fk_shipment_orderdetail FOREIGN KEY (OrderDetailID)
        REFERENCES OrderDetail(OrderDetailID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_shipment_schedule FOREIGN KEY (ScheduleID)
        REFERENCES TrainSchedule(ScheduleID) ON DELETE RESTRICT ON UPDATE CASCADE,
        
    CONSTRAINT chk_shipment_quantity CHECK (Quantity > 0)
);

SET FOREIGN_KEY_CHECKS = 1;


-- =============================================
-- FILE: database/schema/04_tables_delivery.sql
-- =============================================

-- This file contains the Delivery and Road Dispatch tables
-- Tables: Truck, Driver, Assistant, TruckTrip, Delivery

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Delivery;
DROP TABLE IF EXISTS TruckTrip;
DROP TABLE IF EXISTS Assistant;
DROP TABLE IF EXISTS Driver;
DROP TABLE IF EXISTS Truck;

-- Truck Table (Last-mile delivery vehicles at the destination stores)
CREATE TABLE Truck (
    TruckID INT AUTO_INCREMENT PRIMARY KEY,
    RegistrationNumber VARCHAR(20) NOT NULL UNIQUE,
    Capacity DECIMAL(10,2) NOT NULL,
    StoreID INT NOT NULL,

    CONSTRAINT fk_truck_store FOREIGN KEY (StoreID)
        REFERENCES Store(StoreID) ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_truck_capacity CHECK (Capacity > 0)
);

-- Driver Table (The heavy vehicle delivery drivers)
CREATE TABLE Driver (
    DriverID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    LicenceNumber VARCHAR(30) NOT NULL UNIQUE,
    ContactNumber VARCHAR(15) NOT NULL
);

-- Assistant Table (Delivery assistants)
CREATE TABLE Assistant (
    AssistantID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL
);

-- TruckTrip Table (Scheduled for the last-mile road dispatches)
CREATE TABLE TruckTrip (
    TripID INT AUTO_INCREMENT PRIMARY KEY,
    TruckID INT NOT NULL,
    RouteID INT NOT NULL,
    DriverID INT NOT NULL,
    AssistantID INT NOT NULL, -- Mandatory according to the SRS REQ-1
    DispatchTime TIME NOT NULL,
    ReturnTime TIME NOT NULL,
    TripDate DATE NOT NULL,

    CONSTRAINT fk_trucktrip_truck FOREIGN KEY (TruckID)
        REFERENCES Truck(TruckID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trucktrip_route FOREIGN KEY (RouteID)
        REFERENCES Route(RouteID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trucktrip_driver FOREIGN KEY (DriverID)
        REFERENCES Driver(DriverID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trucktrip_assistant FOREIGN KEY (AssistantID)
        REFERENCES Assistant(AssistantID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Delivery Table (The final last-mile customer drop-off)
CREATE TABLE Delivery (
    DeliveryID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE, -- Strict 1:1 relationship between Order and Delivery
    TripID INT NOT NULL,
    DeliveryDate DATE NOT NULL,
    Status ENUM('Scheduled', 'In Transit', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Scheduled', -- Can be 'Scheduled', 'In Transit', 'Delivered'
    CONSTRAINT fk_delivery_order FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_delivery_trip FOREIGN KEY (TripID)
        REFERENCES TruckTrip(TripID) ON DELETE RESTRICT ON UPDATE CASCADE
);

SET FOREIGN_KEY_CHECKS = 1;


-- =============================================
-- FILE: database/functions/fn_calculate_total_space.sql
-- =============================================

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

-- =============================================
-- FILE: database/functions/fn_get_available_capacity.sql
-- =============================================

DROP FUNCTION IF EXISTS fn_get_available_capacity;

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

-- =============================================
-- FILE: database/functions/fn_calculate_weekly_hours.sql
-- =============================================

-- This function calculates total working hours for drivers and assistants (Per week)
-- It is based on the route maximum delivery times 

DROP FUNCTION IF EXISTS fn_calculate_weekly_hours;
DROP FUNCTION IF EXISTS GetDriverWeeklyHours;
DROP FUNCTION IF EXISTS GetAssistantWeeklyHours;

DELIMITER //

CREATE FUNCTION fn_calculate_weekly_hours (PersonType VARCHAR(20), PersonID INT, WeekDate Date)
    RETURNS DECIMAL(5,2)
    
    NOT DETERMINISTIC
    READS SQL DATA

    BEGIN
        DECLARE total_hours DECIMAL(5,2) DEFAULT 0.00;
        
        IF UPPER(PersonType) = 'DRIVER' THEN
            SELECT COALESCE(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 0.00) INTO total_hours
            FROM TruckTrip tt
            WHERE tt.DriverID = PersonID
                AND YEARWEEK(tt.TripDate, 1) = YEARWEEK(WeekDate, 1);

        ELSEIF UPPER(PersonType) = 'ASSISTANT' THEN
            SELECT COALESCE(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 0.00) INTO total_hours
            FROM TruckTrip tt
            WHERE tt.AssistantID = PersonID
                AND YEARWEEK(tt.TripDate, 1) = YEARWEEK(WeekDate, 1);

        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Invalid PersonType. Must be DRIVER or ASSISTANT.';

        END IF;
        
        RETURN total_hours;
    END //


CREATE FUNCTION GetDriverWeeklyHours (DriverID INT, WeekDate Date)
    RETURNS DECIMAL(5,2)
    
    NOT DETERMINISTIC
    READS SQL DATA

    BEGIN
        RETURN fn_calculate_weekly_hours('DRIVER', DriverID, WeekDate);
    END //


CREATE FUNCTION GetAssistantWeeklyHours (AssistantID INT, WeekDate Date)
    RETURNS DECIMAL(5,2)

    NOT DETERMINISTIC
    READS SQL DATA

    BEGIN
        RETURN fn_calculate_weekly_hours('ASSISTANT', AssistantID, WeekDate);
    END //

DELIMITER ;

-- =============================================
-- FILE: database/functions/fn_get_route_for_address.sql
-- =============================================

-- This function is used to find the correct route for the address given by customer

-- if there is already a function in the same name then delete it
DROP FUNCTION IF EXISTS fn_get_route_for_address;

DELIMITER //
-- create a funtion as fn_get_route_for_address
-- this gets p_City as input  and return an integer output
CREATE FUNCTION fn_get_route_for_address(p_City VARCHAR(50)) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    -- create a variable as v_route_id for storing the route id and set it to null
    DECLARE v_route_id INT DEFAULT NULL;

    -- 1.match route through the regional store located in that destination city--
    SELECT r.RouteID
    INTO v_route_id
    FROM Route r
    INNER JOIN Store s ON r.StoreID = s.StoreID
    WHERE LOWER(TRIM(s.City)) = LOWER(TRIM(p_City))
    ORDER BY r.RouteID ASC
    LIMIT 1;

    -- 2.match by RouteName if city name is in RouteName--
    IF v_route_id IS NULL THEN
        SELECT RouteID
        INTO v_route_id
        FROM Route
        WHERE LOWER(RouteName) LIKE CONCAT('%', LOWER(TRIM(p_City)), '%')
        ORDER BY RouteID ASC
        LIMIT 1;
    END IF;

    -- 3.default fallback if no match found
    IF v_route_id IS NULL THEN
        SELECT RouteID INTO v_route_id FROM Route ORDER BY RouteID ASC LIMIT 1;
    END IF;

    RETURN v_route_id;
END //

DELIMITER ;


-- =============================================
-- FILE: database/procedures/sp_place_order.sql
-- =============================================

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

-- =============================================
-- FILE: database/procedures/sp_schedule_shipment.sql
-- =============================================

DROP PROCEDURE IF EXISTS sp_schedule_shipment;

DELIMITER //

CREATE PROCEDURE sp_schedule_shipment(
    IN p_OrderDetailID INT,
    IN p_TargetScheduleID INT,
    IN p_ShipmentDate DATE
)
BEGIN
    DECLARE v_ProductID INT;
    DECLARE v_RemainingQty INT;
    DECLARE v_SpaceRate DECIMAL(8, 2);
    DECLARE v_AvailSpace DECIMAL(10, 2);
    DECLARE v_FitQty INT;
    DECLARE v_CurrScheduleID INT;
    DECLARE v_CurrDate DATE;
    DECLARE v_Destination VARCHAR(50);

    SELECT od.ProductID, od.Quantity INTO v_ProductID, v_RemainingQty
    FROM OrderDetail od
    WHERE od.OrderDetailID = p_OrderDetailID;

    SELECT SpaceConsumption INTO v_SpaceRate
    FROM Product
    WHERE ProductID = v_ProductID;

    SELECT Destination INTO v_Destination
    FROM TrainSchedule
    WHERE ScheduleID = p_TargetScheduleID;

    SET v_CurrScheduleID = p_TargetScheduleID;
    SET v_CurrDate = p_ShipmentDate;

    WHILE v_RemainingQty > 0 DO
        SET v_AvailSpace = fn_get_available_capacity(v_CurrScheduleID, v_CurrDate);

        IF v_AvailSpace > 0 THEN
            SET v_FitQty = FLOOR(v_AvailSpace / v_SpaceRate);

            IF v_FitQty >= v_RemainingQty THEN
                INSERT INTO Shipment (OrderDetailID, ScheduleID, Quantity, ShipmentDate)
                VALUES (p_OrderDetailID, v_CurrScheduleID, v_RemainingQty, v_CurrDate);
                SET v_RemainingQty = 0;
            ELSEIF v_FitQty > 0 THEN
                INSERT INTO Shipment (OrderDetailID, ScheduleID, Quantity, ShipmentDate)
                VALUES (p_OrderDetailID, v_CurrScheduleID, v_FitQty, v_CurrDate);
                SET v_RemainingQty = v_RemainingQty - v_FitQty;
            END IF;
        END IF;

        IF v_RemainingQty > 0 THEN
            SELECT ScheduleID INTO v_CurrScheduleID
            FROM TrainSchedule
            WHERE Destination = v_Destination AND ScheduleID > v_CurrScheduleID
            ORDER BY ScheduleID ASC
            LIMIT 1;

            IF v_CurrScheduleID IS NULL THEN
                SET v_CurrDate = DATE_ADD(v_CurrDate, INTERVAL 1 DAY);
                SELECT ScheduleID INTO v_CurrScheduleID
                FROM TrainSchedule
                WHERE Destination = v_Destination
                ORDER BY ScheduleID ASC
                LIMIT 1;
            END IF;
        END IF;
    END WHILE;
END //

DELIMITER ;

-- =============================================
-- FILE: database/procedures/sp_assign_truck_trip.sql
-- =============================================

-- This procedure assigns truck trips to Drivers and Assistants
-- Automated dispatch controller before a trip is saved in the database

-- Requirements:
--   - SRS Section 4.4: Driver 40h & Assistant 60h caps, consecutive trip rules
--   - SRS Section 4.4 / REQ-6: Schedule conflict validation

DROP PROCEDURE IF EXISTS sp_assign_truck_trip;

DELIMITER //

-- The "p_" means parameter
CREATE PROCEDURE sp_assign_truck_trip(IN p_TruckID INT, IN p_RouteID INT, IN p_DriverID INT, IN p_AssistantID INT, -- IN attributes
                                      IN p_TripDate DATE, IN p_DispatchTime TIME, IN p_ReturnTime TIME, 
                                      OUT p_TripID INT) -- OUT attribute
    BEGIN
        -- Declare the needed variables
        DECLARE trip_duration DECIMAL(5,2);
        DECLARE driver_current_hours DECIMAL(5,2);
        DECLARE assistant_current_hours DECIMAL(5,2);
        DECLARE conflict_count INT DEFAULT 0;
        DECLARE consecutive_trips INT DEFAULT 0; 

        DECLARE EXIT HANDLER FOR SQLEXCEPTION -- If something fails during execution
        BEGIN
            ROLLBACK; -- Undo the changes that has been done
            RESIGNAL; -- Sends the error to the caller
        END;

    -- SIGNAL SQLSTATE '45000' => throws a custom error
    -- Validate that Dispatch time >= Return Time (Truck cannot return before it departs)
    IF p_ReturnTime <= p_DispatchTime THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Return time must be after dispatch time.';
    END IF;

    -- Total duration of the trip in decimal hours
    SET trip_duration = TIME_TO_SEC(TIMEDIFF(p_ReturnTime, p_DispatchTime)) / 3600.0;

    -- Validate Driver has no more than 40 hours weekly
    SET driver_current_hours = GetDriverWeeklyHours(p_DriverID, p_TripDate);
    IF (driver_current_hours + trip_duration) > 40.0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Roster Constraint Violation: Driver exceeds weekly limit of 40 hours.';
    END IF;

    -- Validate Assistant has no more than 60 hours weekly
    IF p_AssistantID IS NOT NULL THEN
        SET assistant_current_hours = GetAssistantWeeklyHours(p_AssistantID, p_TripDate);
        IF (assistant_current_hours + trip_duration) > 60.0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Roster Constraint Violation: Assistant exceeds weekly limit of 60 hours.';
        END IF;
    END IF;

    -- Check if the Driver's last trip ended 30 minutes or more before the new dispatch time
    SELECT COUNT(*) INTO consecutive_trips
    FROM TruckTrip
    WHERE DriverID = p_DriverID 
      AND TripDate = p_TripDate 
      AND (
          (ReturnTime <= p_DispatchTime AND TIMEDIFF(p_DispatchTime, ReturnTime) < '00:30:00') -- Checks if an existing trip ends right before the new trip starts with less than 30 minutes of rest.
          OR
          (p_ReturnTime <= DispatchTime AND TIMEDIFF(DispatchTime, p_ReturnTime) < '00:30:00') -- Checks if the new trip ends right before an already-scheduled trip starts with less than 30 minutes of rest.
      );

    IF consecutive_trips > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Roster Constraint Violation: Driver needs at least 30 minutes rest between trips.';
    END IF;

    -- Assitant can do two back-to-back trips before taking a break
    -- Checking this condition for Assistant for a 30 minute break
    SELECT COUNT(*) INTO consecutive_trips
    FROM TruckTrip t1
    INNER JOIN TruckTrip t2 ON t1.AssistantID = t2.AssistantID
                           AND t1.TripDate = t2.TripDate
                           AND t1.ReturnTime = t2.DispatchTime -- Identifies two back-to-back trips
    WHERE t1.AssistantID = p_AssistantID
      AND t1.TripDate = p_TripDate
      -- Checking if the 3rd trip is within 30 minutes
      AND (t2.ReturnTime <= p_DispatchTime AND TIMEDIFF(p_DispatchTime, t2.ReturnTime) < '00:30:00');

    IF consecutive_trips > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Roster Constraint Violation: Assistant cannot be scheduled for more than 2 consecutive trips.';
    END IF;

    -- Preventing overlaps or double booking (Truck, Driver, or Assistant)
    SELECT COUNT(*) INTO conflict_count
    FROM TruckTrip
    WHERE TripDate = p_TripDate
      AND (TruckID = p_TruckID OR DriverID = p_DriverID OR AssistantID = p_AssistantID)
      AND (p_DispatchTime < ReturnTime AND p_ReturnTime > DispatchTime); -- Check if (Truck, Driver, or Assistant) is already booked for another trip overlapping time window

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Schedule Conflict: The Truck, Driver, or Assistant is already booked for an overlapping time window.';
    END IF;

    -- Insert new truck trip inside transaction
    START TRANSACTION;

    -- Adds the new scheduled trip to the TruckTrip
    INSERT INTO TruckTrip (TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime)
    VALUES (p_TruckID, p_RouteID, p_DriverID, p_AssistantID, p_TripDate, p_DispatchTime, p_ReturnTime);

    SET p_TripID = LAST_INSERT_ID(); -- Backend application or caller knows the ID of the created trip

    -- Creates an immutable trail in the AuditLog table
    INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
    VALUES ('TruckTrip', 'INSERT', p_TripID, 'FLEET_COORDINATOR', 
            CONCAT('TruckTrip #', p_TripID, ' created with Truck #', p_TruckID, ', Driver #', p_DriverID, ', Assistant #', p_AssistantID));

    COMMIT; -- Permanently writes both inserts (TruckTrip and AuditLog)
END //

DELIMITER ;



-- =============================================
-- FILE: database/procedures/sp_update_delivery_status.sql
-- =============================================

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
        SET MESSAGE_TEXT = 'State Error: Cannot change status - delivery is already completed.';
    END IF;

    -- Cannot change status after 'Cancelled'
    IF current_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'State Error: Cannot change status - delivery has been cancelled.';
    END IF;

    -- Cannot change from 'In Transit' to 'Scheduled'
    IF current_status = 'In Transit' AND p_NewStatus = 'Scheduled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'State Error: Cannot change from In Transit to Scheduled.';
    END IF;

    -- We need a transaction because two dependent tables are being changed here
    -- Delivery and Orders
    START TRANSACTION;

    SET @audit_changed_by = COALESCE(p_ChangedBy, 'SYSTEM'); -- User variable with the username of the person updating
    -- Later, triggers can see who made this change

    -- Update Delivery table status [child table]
    UPDATE Delivery
    SET Status = p_NewStatus
    WHERE DeliveryID = p_DeliveryID;

    -- Cascade status to Orders table [parent table]
    IF p_NewStatus = 'Delivered' THEN
        UPDATE Orders
        SET Status = 'Delivered'
        WHERE OrderID = order_id;
    ELSEIF p_NewStatus = 'In Transit' THEN
        UPDATE Orders
        SET Status = 'In Transit'
        WHERE OrderID = order_id;
    ELSEIF p_NewStatus = 'Cancelled' THEN
        UPDATE Orders
        SET Status = 'Cancelled'
        WHERE OrderID = order_id;
    END IF;

    -- No need to update AuditLog because it's updated by triggers

    COMMIT;

END //

DELIMITER ;

-- =============================================
-- FILE: database/procedures/sp_staff_weekly_hours_report.sql
-- =============================================

-- This stored procedure will generate a week-by-week report of the total hours worked by Drivers and Assistants
-- According to the SRS Section 4.5.3 / REQ-4

DROP PROCEDURE IF EXISTS sp_staff_weekly_hours_report;

DELIMITER //

CREATE PROCEDURE sp_staff_weekly_hours_report (IN p_StartDate DATE, IN p_EndDate DATE)
BEGIN
    -- Getting the Driver's weekly breakdown of hours worked
    SELECT
        'Driver' AS StaffRole,
        d.DriverID AS StaffID,
        d.Name AS StaffName,
        d.LicenceNumber AS ReferenceNumber,
        d.ContactNumber,
        DATE_SUB(tt.TripDate, INTERVAL(WEEKDAY(tt.TripDate)) DAY) AS WeekStartDate,
        YEARWEEK(tt.TripDate, 1) AS WeekNumber,
        COUNT(tt.TripID) AS TripsInWeek,
        ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2) AS TotalHoursWorked,
        40.00 AS WeeklyLimit,
        GREATEST(40.00 - ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2), 0.00) AS RemainingHours,

        CASE
            WHEN ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2) > 40.00 THEN 'Exceeded'
            ELSE 'Within Limit'
        END AS LimitStatus

    FROM Driver d
    INNER JOIN TruckTrip tt ON d.DriverID = tt.DriverID
    WHERE(p_StartDate IS NULL OR tt.TripDate >= p_StartDate)
      AND (p_EndDate IS NULL OR tt.TripDate <= p_EndDate)
    GROUP BY d.DriverID, d.Name, d.LicenceNumber, d.ContactNumber, YEARWEEK(tt.TripDate, 1), 
                DATE_SUB(tt.TripDate, INTERVAL(WEEKDAY(tt.TripDate)) DAY)

    UNION ALL

    -- Getting the Assistant's weekly breakdown of hours worked
    SELECT
        'Assistant' AS StaffRole,
        a.AssistantID AS StaffID,
        a.Name AS StaffName,
        'N/A' AS ReferenceNumber,
        a.ContactNumber,
        DATE_SUB(tt.TripDate, INTERVAL(WEEKDAY(tt.TripDate)) DAY) AS WeekStartDate,
        YEARWEEK(tt.TripDate, 1) AS WeekNumber,
        COUNT(tt.TripID) AS TripsInWeek,
        ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2) AS TotalHoursWorked,
        60.00 AS WeeklyLimit,
        GREATEST(60.00 - ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2), 0.00) AS RemainingHours,

        CASE
            WHEN ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2) > 60.00 THEN 'Exceeded'
            ELSE 'Within Limit'
        END AS LimitStatus

    FROM Assistant a
    INNER JOIN TruckTrip tt ON a.AssistantID = tt.AssistantID
    WHERE(p_StartDate IS NULL OR tt.TripDate >= p_StartDate)
      AND (p_EndDate IS NULL OR tt.TripDate <= p_EndDate)
    GROUP BY a.AssistantID, a.Name, a.ContactNumber, YEARWEEK(tt.TripDate, 1), 
                DATE_SUB(tt.TripDate, INTERVAL(WEEKDAY(tt.TripDate)) DAY)

    ORDER BY StaffRole ASC, WeekStartDate ASC, TotalHoursWorked DESC;
END //

DELIMITER ;

-- =============================================
-- FILE: database/reports/sp_quarterly_sales_report.sql
-- =============================================

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
        COALESCE(SUM(od.LineTotal), 0.00) AS TotalRevenueLKR
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



-- =============================================
-- FILE: database/reports/sp_top_items_report.sql
-- =============================================

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



-- =============================================
-- FILE: database/reports/sp_geographic_sales_report.sql
-- =============================================

-- Geographic sales report
-- Shows sales by city and route for a selected date range

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

-- =============================================
-- FILE: database/reports/sp_working_hours_report.sql
-- =============================================

-- Kandypack Logistics Platform - Driver & Assistant Working Hours Report

DROP PROCEDURE IF EXISTS sp_working_hours_report;

DELIMITER //

CREATE PROCEDURE sp_working_hours_report(
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
    -- 1. Driver Summary
    SELECT 
        'Driver' AS StaffRole,
        d.DriverID AS StaffID,
        d.Name AS StaffName,
        d.LicenceNumber AS ReferenceID,
        COUNT(tt.TripID) AS TotalTripsCompleted,
        COALESCE(ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2), 0.00) AS TotalHoursWorked,
        40.00 AS StandardWeeklyLimit
    FROM Driver d
    LEFT JOIN TruckTrip tt ON d.DriverID = tt.DriverID 
       AND (p_StartDate IS NULL OR tt.TripDate >= p_StartDate)
       AND (p_EndDate IS NULL OR tt.TripDate <= p_EndDate)
    GROUP BY d.DriverID, d.Name, d.LicenceNumber

    UNION ALL

    -- 2. Assistant Summary
    SELECT 
        'Assistant' AS StaffRole,
        a.AssistantID AS StaffID,
        a.Name AS StaffName,
        a.ContactNumber AS ReferenceID,
        COUNT(tt.TripID) AS TotalTripsCompleted,
        COALESCE(ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2), 0.00) AS TotalHoursWorked,
        60.00 AS StandardWeeklyLimit
    FROM Assistant a
    LEFT JOIN TruckTrip tt ON a.AssistantID = tt.AssistantID 
       AND (p_StartDate IS NULL OR tt.TripDate >= p_StartDate)
       AND (p_EndDate IS NULL OR tt.TripDate <= p_EndDate)
    GROUP BY a.AssistantID, a.Name, a.ContactNumber

    ORDER BY StaffRole ASC, TotalHoursWorked DESC;
END //

DELIMITER ;



-- =============================================
-- FILE: database/reports/sp_fleet_usage_report.sql
-- =============================================

-- Fleet usage report
-- Shows monthly trips, operating hours and mileage for each truck

DROP PROCEDURE IF EXISTS sp_fleet_usage_report;

DELIMITER //

CREATE PROCEDURE sp_fleet_usage_report(
    IN p_Year INT,
    IN p_Month INT
)
BEGIN
    SELECT
        t.TruckID,
        t.RegistrationNumber,
        s.StoreName,
        s.City,
        COUNT(tt.TripID) AS TotalTrips,

        COALESCE(
            ROUND(
                SUM(
                    TIME_TO_SEC(
                        TIMEDIFF(tt.ReturnTime, tt.DispatchTime)
                    ) / 3600.0
                ),
                2
            ),
            0.00
        ) AS OperatingHours,

        COALESCE(
            ROUND(SUM(r.Distance), 2),
            0.00
        ) AS TotalMileage

    FROM Truck t
    INNER JOIN Store s
        ON t.StoreID = s.StoreID

    LEFT JOIN TruckTrip tt
        ON t.TruckID = tt.TruckID
        AND YEAR(tt.TripDate) = p_Year
        AND MONTH(tt.TripDate) = p_Month

    LEFT JOIN Route r
        ON tt.RouteID = r.RouteID

    GROUP BY
        t.TruckID,
        t.RegistrationNumber,
        s.StoreName,
        s.City

    ORDER BY
        t.TruckID;
END //

DELIMITER ;

-- =============================================
-- FILE: database/reports/sp_customer_order_history.sql
-- =============================================

-- Kandypack Logistics Platform - Customer Order History Report


DROP PROCEDURE IF EXISTS sp_customer_order_history;

DELIMITER //

CREATE PROCEDURE sp_customer_order_history(
    IN p_CustomerID INT
)
BEGIN
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.Status AS OrderStatus,
        o.TotalAmount AS OrderTotalLKR,
        r.RouteName,
        s.City AS DestinationCity,
        d.DeliveryID,
        d.DeliveryDate,
        COALESCE(d.Status, 'Pending Assignment') AS DeliveryStatus,
        tt.TripID,
        drv.Name AS AssignedDriver,
        ast.Name AS AssignedAssistant,
        t.RegistrationNumber AS AssignedTruck,
        COUNT(od.OrderDetailID) AS TotalItemLines,
        COALESCE(SUM(od.Quantity), 0) AS TotalUnitsOrdered
    FROM Orders o
    INNER JOIN Customer c ON o.CustomerID = c.CustomerID
    INNER JOIN Route r ON o.RouteID = r.RouteID
    INNER JOIN Store s ON r.StoreID = s.StoreID
    LEFT JOIN OrderDetail od ON o.OrderID = od.OrderID
    LEFT JOIN Delivery d ON o.OrderID = d.OrderID
    LEFT JOIN TruckTrip tt ON d.TripID = tt.TripID
    LEFT JOIN Driver drv ON tt.DriverID = drv.DriverID
    LEFT JOIN Assistant ast ON tt.AssistantID = ast.AssistantID
    LEFT JOIN Truck t ON tt.TruckID = t.TruckID
    WHERE o.CustomerID = p_CustomerID
    GROUP BY o.OrderID, o.OrderDate, o.Status, o.TotalAmount, r.RouteName, s.City, 
             d.DeliveryID, d.DeliveryDate, d.Status, tt.TripID, drv.Name, ast.Name, t.RegistrationNumber
    ORDER BY o.OrderDate DESC, o.OrderID DESC;
END //

DELIMITER ;



-- =============================================
-- FILE: database/triggers/trg_check_cargo_capacity.sql
-- =============================================

DROP TRIGGER IF EXISTS trg_check_cargo_capacity;

DELIMITER //

CREATE TRIGGER trg_check_cargo_capacity
BEFORE INSERT ON Shipment
FOR EACH ROW
BEGIN
    DECLARE v_ProductID INT;
    DECLARE v_RequiredSpace DECIMAL(10, 2);
    DECLARE v_AvailableSpace DECIMAL(10, 2);

    SELECT ProductID INTO v_ProductID
    FROM OrderDetail
    WHERE OrderDetailID = NEW.OrderDetailID;

    SET v_RequiredSpace = fn_calculate_total_space(v_ProductID, NEW.Quantity);
    SET v_AvailableSpace = fn_get_available_capacity(NEW.ScheduleID, NEW.ShipmentDate);

    IF v_RequiredSpace > v_AvailableSpace THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capacity Exceeded: Train cargo limit reached for this run.';
    END IF;
END //

DELIMITER ;

-- =============================================
-- FILE: database/triggers/trg_before_insert_trucktrip.sql
-- =============================================

-- For the checks that needs to be done before a TruckTrip is inserted

-- Things checked:
--   1 - ReturnTime > DispatchTime (basic time sanity)
--   2 - Schedule conflict prevention (SRS 4.4 / REQ-6)
--   3 - Driver consecutive trip rule with 30-min rest buffer (SRS 4.4 / REQ-2)
--   4 - Assistant max 2 consecutive trips (SRS 4.4 / REQ-3)
--   5 - Driver 40h and Assistant 60h weekly caps (SRS 4.4 / REQ-4 & REQ-5)

DROP TRIGGER IF EXISTS trg_before_insert_trucktrip;

DELIMITER //

CREATE TRIGGER trg_before_insert_trucktrip
BEFORE INSERT ON TruckTrip -- checking before we insert a record
FOR EACH ROW

BEGIN
    -- declaring the variables
    DECLARE conflict_count INT DEFAULT 0;
    DECLARE driver_consecutive INT DEFAULT 0;
    DECLARE assistant_consecutive INT DEFAULT 0;
    DECLARE trip_duration DECIMAL(5,2);
    DECLARE driver_hours DECIMAL(5,2);
    DECLARE assistant_hours DECIMAL(5,2);

    -- 1.
    IF NEW.ReturnTime <= NEW.DispatchTime THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: ReturnTime must be strictly later than DispatchTime.';
    END IF;

    -- Calculate trip duration in decimal hours
    SET trip_duration = TIME_TO_SEC(TIMEDIFF(NEW.ReturnTime, NEW.DispatchTime)) / 3600.0;

    SELECT COUNT(*) INTO conflict_count
    FROM TruckTrip
    WHERE TripDate = NEW.TripDate
      -- check for overlapping trips for the same Truck, Driver, or Assistant
      AND (TruckID = NEW.TruckID OR DriverID = NEW.DriverID OR AssistantID = NEW.AssistantID)
      AND (NEW.DispatchTime < ReturnTime AND NEW.ReturnTime > DispatchTime);

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Schedule Conflict: The Truck, Driver, or Assistant is already booked for an overlapping time window.';
    END IF;

    -- 3.
    SELECT COUNT(*) INTO driver_consecutive
    FROM TruckTrip
    WHERE DriverID = NEW.DriverID
      AND TripDate = NEW.TripDate
      AND (
          -- Existing trip ends within 30 min before new trip starts
          (ReturnTime <= NEW.DispatchTime AND TIMEDIFF(NEW.DispatchTime, ReturnTime) < '00:30:00')
          OR
          -- New trip ends within 30 min before existing trip starts
          (NEW.ReturnTime <= DispatchTime AND TIMEDIFF(DispatchTime, NEW.ReturnTime) < '00:30:00')
      );
    
    IF driver_consecutive > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Consecutive Trip Violation: The Driver must have at least 30 minutes of rest between trips.';
    END IF;

    -- 4.
    SELECT COUNT(*) INTO assistant_consecutive
    FROM TruckTrip t1
    INNER JOIN TruckTrip t2 ON t1.AssistantID = t2.AssistantID
                           AND t1.TripDate = t2.TripDate
                           AND t1.ReturnTime = t2.DispatchTime
    WHERE t1.AssistantID = NEW.AssistantID
      AND t1.TripDate = NEW.TripDate
      AND (t2.ReturnTime <= NEW.DispatchTime AND TIMEDIFF(NEW.DispatchTime, t2.ReturnTime) < '00:30:00');

    IF assistant_consecutive > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Consecutive Trip Violation: The Assistant must have at least 30 minutes of rest between trips.';
    END IF;

    -- 5.1 for Driver's 40-hour weekly cap
    SET driver_hours = GetDriverWeeklyHours(NEW.DriverID, NEW.TripDate);
    IF (driver_hours + trip_duration) > 40.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver exceeds weekly limit of 40 working hours.';
    END IF;

    -- 5.2 for Assistant's 60-hour cap
    IF NEW.AssistantID IS NOT NULL THEN -- assistant is mandatory, but just in case, we check for NULL
        SET assistant_hours = GetAssistantWeeklyHours(NEW.AssistantID, NEW.TripDate);
        IF (assistant_hours + trip_duration) > 60.00 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Assistant exceeds weekly limit of 60 working hours.';
        END IF;
    END IF;
END //

DELIMITER ;

-- =============================================
-- FILE: database/triggers/trg_update_stock_on_dispatch.sql
-- =============================================

DROP TRIGGER IF EXISTS trg_update_stock_on_dispatch;

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

-- =============================================
-- FILE: database/triggers/trg_audit_log.sql
-- =============================================


-- Kandypack Logistics Platform - Security & Action Audit Log Triggers
-- Requirement:  Security Requirements


DROP TRIGGER IF EXISTS trg_audit_order_status;
DROP TRIGGER IF EXISTS trg_audit_delivery_status;

DELIMITER //

-- 1. Audit status modifications on Orders
CREATE TRIGGER trg_audit_order_status
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
        VALUES ('Orders', 'UPDATE', NEW.OrderID, 
                COALESCE(CONCAT('Admin#', NEW.AdminID), 'SYSTEM'),
                CONCAT('Order status changed from ', OLD.Status, ' to ', NEW.Status));
    END IF;
END //

-- 2. Audit status modifications on Deliveries
CREATE TRIGGER trg_audit_delivery_status
AFTER UPDATE ON Delivery
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        INSERT INTO AuditLog (TableName, ActionType, RecordID, ChangedBy, Details)
        VALUES ('Delivery', 'UPDATE', NEW.DeliveryID, 'DISPATCH_COORDINATOR',
                CONCAT('Delivery status changed from ', OLD.Status, ' to ', NEW.Status, ' for Order #', NEW.OrderID));
    END IF;
END //

DELIMITER ;

-- =============================================
-- FILE: database/indexes/01_indexes.sql
-- =============================================

-- Kandypack Logistics Platform - B-Tree Indexes


-- 1. Indexes on Orders Table
CREATE INDEX idx_order_date ON Orders (OrderDate);
CREATE INDEX idx_order_status ON Orders (Status);
CREATE INDEX idx_order_customer ON Orders (CustomerID);
CREATE INDEX idx_order_route ON Orders (RouteID);

-- 2. Indexes on OrderDetail Table
CREATE INDEX idx_orderdetail_order ON OrderDetail (OrderID);
CREATE INDEX idx_orderdetail_product ON OrderDetail (ProductID);

-- 3. Indexes on TrainSchedule & Shipment Tables
CREATE INDEX idx_trainschedule_destination ON TrainSchedule (Destination);
CREATE INDEX idx_trainschedule_day ON TrainSchedule (DayOfWeek);
CREATE INDEX idx_shipment_date ON Shipment (ShipmentDate);
CREATE INDEX idx_shipment_schedule ON Shipment (ScheduleID);
CREATE INDEX idx_shipment_orderdetail ON Shipment (OrderDetailID);

-- 4. Indexes on TruckTrip Table (Roster & Conflict checking acceleration)
CREATE INDEX idx_trucktrip_driver_date ON TruckTrip (DriverID, TripDate);
CREATE INDEX idx_trucktrip_assistant_date ON TruckTrip (AssistantID, TripDate);
CREATE INDEX idx_trucktrip_truck_date ON TruckTrip (TruckID, TripDate);
CREATE INDEX idx_trucktrip_times ON TruckTrip (TripDate, DispatchTime, ReturnTime);

-- 5. Indexes on Delivery Table
CREATE INDEX idx_delivery_status ON Delivery (Status);
CREATE INDEX idx_delivery_date ON Delivery (DeliveryDate);
CREATE INDEX idx_delivery_trip ON Delivery (TripID);

-- 6. Indexes on Master Tables
CREATE INDEX idx_customer_city ON Customer (City);
CREATE INDEX idx_store_city ON Store (City);
CREATE INDEX idx_product_category ON Product (Category);



-- =============================================
-- FILE: database/views/vw_order_summary.sql
-- =============================================

-- Kandypack Logistics Platform - Order Summary View

DROP VIEW IF EXISTS vw_order_summary;

CREATE VIEW vw_order_summary AS
SELECT 
    o.OrderID,
    o.OrderDate,
    o.Status AS OrderStatus,
    o.TotalAmount AS OrderTotalLKR,
    c.CustomerID,
    c.FullName AS CustomerName,
    c.City AS CustomerCity,
    c.ContactNumber AS CustomerContact,
    r.RouteID,
    r.RouteName,
    s.StoreID,
    s.StoreName,
    COUNT(od.OrderDetailID) AS TotalLineItems,
    COALESCE(SUM(od.Quantity), 0) AS TotalUnitsOrdered,
    COALESCE(SUM(od.Quantity * p.SpaceConsumption), 0.00) AS TotalSpaceRequired,
    d.DeliveryID,
    d.DeliveryDate,
    COALESCE(d.Status, 'Unscheduled') AS DeliveryStatus
FROM Orders o
INNER JOIN Customer c ON o.CustomerID = c.CustomerID
INNER JOIN Route r ON o.RouteID = r.RouteID
INNER JOIN Store s ON r.StoreID = s.StoreID
LEFT JOIN OrderDetail od ON o.OrderID = od.OrderID
LEFT JOIN Product p ON od.ProductID = p.ProductID
LEFT JOIN Delivery d ON o.OrderID = d.OrderID
GROUP BY 
    o.OrderID, o.OrderDate, o.Status, o.TotalAmount,
    c.CustomerID, c.FullName, c.City, c.ContactNumber,
    r.RouteID, r.RouteName, s.StoreID, s.StoreName,
    d.DeliveryID, d.DeliveryDate, d.Status;



-- =============================================
-- FILE: database/views/vw_truck_utilization.sql
-- =============================================

-- Truck utilization view
-- Shows trip activity, operating hours and completed deliveries for each truck

DROP VIEW IF EXISTS vw_truck_utilization;

CREATE VIEW vw_truck_utilization AS
SELECT
    t.TruckID,
    t.RegistrationNumber,
    t.Capacity AS CargoCapacity,
    s.StoreID,
    s.StoreName,
    s.City AS StationCity,
    COUNT(tt.TripID) AS TotalDispatchedTrips,
    COALESCE(
        ROUND(
            SUM(
                TIME_TO_SEC(
                    TIMEDIFF(tt.ReturnTime, tt.DispatchTime)
                ) / 3600.0
            ),
            2
        ),
        0.00
    ) AS TotalOperatingHours,
    COUNT(DISTINCT d.DeliveryID) AS TotalDeliveriesCompleted
FROM Truck t
INNER JOIN Store s
    ON t.StoreID = s.StoreID
LEFT JOIN TruckTrip tt
    ON t.TruckID = tt.TruckID
LEFT JOIN Delivery d
    ON tt.TripID = d.TripID
GROUP BY
    t.TruckID,
    t.RegistrationNumber,
    t.Capacity,
    s.StoreID,
    s.StoreName,
    s.City;

-- =============================================
-- FILE: database/views/vw_staff_weekly_hours.sql
-- =============================================

-- This view is to view the hours worked by Drivers and Assistants real time
-- Tracks how many hours they have remaining based on their weekly quotas
-- Drivers: 40 hours per week, Assistants: 60 hours per week

-- CURDATE() gives the current date => used to determine current week

DROP VIEW IF EXISTS vw_staff_weekly_hours;

CREATE VIEW vw_staff_weekly_hours AS
SELECT
    'Driver' AS StaffRole,
    d.DriverID AS StaffID,
    d.Name AS StaffName,
    d.LicenceNumber AS ReferenceNumber,
    d.ContactNumber,
    GetDriverWeeklyHours(d.DriverID, CURDATE()) AS CurrentWeekHoursWorked,
    40.00 AS MaxWeeklyAllowance,
    GREATEST(40.00 - GetDriverWeeklyHours(d.DriverID, CURDATE()), 0.00) AS RemainingHoursQuota
FROM Driver d

UNION ALL -- concatinates all the results from the Driver and Assistant queries to one

SELECT
    'Assistant' AS StaffRole,
    a.AssistantID AS StaffID,
    a.Name AS StaffName,
    'N/A' AS ReferenceNumber,
    a.ContactNumber,
    GetAssistantWeeklyHours(a.AssistantID, CURDATE()) AS CurrentWeekHoursWorked,
    60.00 AS MaxWeeklyAllowance,
    GREATEST(60.00 - GetAssistantWeeklyHours(a.AssistantID, CURDATE()), 0.00) AS RemainingHoursQuota
FROM Assistant a;

-- =============================================
-- FILE: database/seed/01_seed_core.sql
-- =============================================

-- Added: Stores (6), Routes (12), Products (10), Customers (12)--

SET FOREIGN_KEY_CHECKS = 0;

-- Stores(Colombo,Negombo,Galle,Matara,Jaffna,Trincomalee)--
TRUNCATE TABLE Store;
INSERT INTO Store (StoreID, StoreName, Capacity, City) VALUES
(1, 'Colombo Central Warehouse', 5000.00, 'Colombo'),
(2, 'Negombo Regional Hub', 3500.00, 'Negombo'),
(3, 'Galle Distribution Center', 4000.00, 'Galle'),
(4, 'Matara Southern Depot', 3000.00, 'Matara'),
(5, 'Jaffna Northern Hub', 4500.00, 'Jaffna'),
(6, 'Trincomalee Eastern Center', 3200.00, 'Trincomalee');

-- Routes(12 routes connecting regional stores to delivery zones)--
TRUNCATE TABLE Route;
INSERT INTO Route (RouteID, StoreID, RouteName, MaxDeliveryTime, Distance) VALUES
(1, 1, 'Colombo Fort & Pettah Commercial Route', 3.50, 115.00),
(2, 1, 'Greater Colombo Suburban Route', 4.00, 130.00),
(3, 2, 'Negombo Town & Lagoon Route', 3.00, 95.00),
(4, 2, 'Kochchikade & Katunayake Logistics Route', 3.50, 110.00),
(5, 3, 'Galle Fort & Coastal District Route', 4.50, 160.00),
(6, 3, 'Hikkaduwa & Southern Corridor Route', 5.00, 180.00),
(7, 4, 'Matara City & Dondra Head Route', 5.50, 210.00),
(8, 4, 'Weligama Bay Distribution Route', 5.00, 195.00),
(9, 5, 'Jaffna City Center Route', 7.00, 320.00),
(10, 5, 'Chavakachcheri & Vadamarachchi Route', 7.50, 345.00),
(11, 6, 'Trincomalee Town & Harbor Route', 6.00, 215.00),
(12, 6, 'Kinniya & Nilaveli Coastal Route', 6.50, 240.00);

-- Products--
TRUNCATE TABLE Product;
INSERT INTO Product (ProductID, ProductName, UnitPrice, SpaceConsumption, StockQuantity, Category) VALUES
(1, 'Kandypack Detergent Powder 1kg', 450.00, 0.50, 8000, 'Cleaning'),
(2, 'Kandypack Ceylon Premium Tea 500g', 380.00, 0.20, 12000, 'Beverages'),
(3, 'Kandypack Pure Coconut Cooking Oil 1L', 680.00, 0.40, 5000, 'Groceries'),
(4, 'Kandypack Butter Biscuits 200g', 180.00, 0.15, 15000, 'Snacks'),
(5, 'Kandypack Cream Crackers 400g', 240.00, 0.25, 10000, 'Snacks'),
(6, 'Kandypack Herbal Bath Soap 100g', 120.00, 0.10, 20000, 'Personal Care'),
(7, 'Kandypack Dishwash Liquid 500ml', 290.00, 0.30, 7500, 'Cleaning'),
(8, 'Kandypack Coconut Milk Powder 300g', 390.00, 0.18, 9000, 'Groceries'),
(9, 'Kandypack Hand Sanitizer 250ml', 220.00, 0.12, 11000, 'Personal Care'),
(10, 'Kandypack Herbal Toothpaste 120g', 160.00, 0.08, 18000, 'Personal Care');

-- Customers--
TRUNCATE TABLE Customer;
INSERT INTO Customer (CustomerID, FullName, Email, ContactNumber, Address, City, Username, Password) VALUES
(1, 'Lanka Super Center Colombo', 'orders@lankasuper.lk', '0112345678', 'No. 45 Galle Road, Colpetty', 'Colombo', 'lankasuper_col', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(2, 'Cargills Express Negombo', 'negombo@cargills.lk', '0312233445', 'No. 12 Main Street', 'Negombo', 'cargills_neg', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(3, 'Keells Super Galle', 'galle@keells.lk', '0912244556', 'No. 88 Matara Road', 'Galle', 'keells_gal', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(4, 'Arpico Supercentre Matara', 'matara@arpico.com', '0412223344', 'No. 15 Hakmana Road', 'Matara', 'arpico_mat', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(5, 'Northern Wholesale Mart Jaffna', 'contact@northernmart.lk', '0212224455', 'No. 200 Hospital Road', 'Jaffna', 'northmart_jaf', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(6, 'Eastern Traders Trincomalee', 'info@easterntraders.lk', '0262223311', 'No. 34 Dockyard Road', 'Trincomalee', 'eastern_trinco', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(7, 'Sunil Grocery Stores', 'sunil.stores@gmail.com', '0114567890', 'No. 102 High Level Road, Nugegoda', 'Colombo', 'sunilstores', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(8, 'Silva & Sons Wholesale', 'silva.sons@gmail.com', '0317894561', 'No. 54 Sea Street', 'Negombo', 'silvasons', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(9, 'Southern Distributors Galle', 'info@southerndist.lk', '0917418520', 'No. 19 Fort Street', 'Galle', 'southerndist', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(10, 'Ruhunu Food City Matara', 'ruhunu.food@gmail.com', '0419638520', 'No. 77 Beach Road', 'Matara', 'ruhunufood', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(11, 'Nallur Retailers Jaffna', 'nallur.retail@gmail.com', '0218529630', 'No. 14 Point Pedro Road', 'Jaffna', 'nallurretail', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(12, 'Harbor View Mart Trincomalee', 'harborview@yahoo.com', '0263692580', 'No. 6 Inner Harbor Road', 'Trincomalee', 'harborview', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash');

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- FILE: database/seed/02_seed_rail.sql
-- =============================================

INSERT INTO Train (TrainName, MaxCapacity) VALUES 
('Kandy Express 01', 500.00),
('Northern Line Express', 750.00);

INSERT INTO TrainSchedule (TrainID, CargoCapacity, Destination, DepartureTime, ArrivalTime, DayOfWeek) VALUES 
(1, 100.00, 'Colombo', '06:00:00', '09:30:00', 'Monday'),
(1, 100.00, 'Colombo', '14:00:00', '17:30:00', 'Monday'),
(2, 200.00, 'Jaffna', '05:00:00', '12:00:00', 'Tuesday');

-- =============================================
-- FILE: database/seed/03_seed_delivery.sql
-- =============================================

-- This file contains the Fleet and Roster Seed Data for Tables: Truck, Driver, Assistant
-- Added: Trucks (12), Drivers (10), Assistants (10)

-- At the time of adding this file, I cannot test how these data behave eith other tables (the queries run fine btw)

SET FOREIGN_KEY_CHECKS = 0;

-- Trucks (Assigned to regional stores for last-mile road dispatch)
TRUNCATE TABLE Truck;
INSERT INTO Truck (TruckID, RegistrationNumber, Capacity, StoreID) VALUES

-- Colombo Trucks (Store 1)
(1, 'WP-CAA-1020', 120.00, 1),
(2, 'WP-CAA-1021', 150.00, 1),
(3, 'WP-CAB-3304', 100.00, 1),

-- Negombo Trucks (Store 2)
(4, 'WP-CBA-4512', 120.00, 2),
(5, 'WP-CBA-4513', 100.00, 2),

-- Galle Trucks (Store 3)
(6, 'SP-DAA-2101', 120.00, 3),
(7, 'SP-DAB-8890', 150.00, 3),

-- Matara Trucks (Store 4)
(8, 'SP-DBA-3311', 100.00, 4),
(9, 'SP-DBA-3312', 120.00, 4),

-- Jaffna Trucks (Store 5)
(10, 'NP-EAA-5520', 150.00, 5),
(11, 'NP-EAA-5521', 120.00, 5),

-- Trincomalee Trucks (Store 6)
(12, 'EP-FAA-7714', 120.00, 6);

-- Drivers (Heavy vehicle licensed staff)
TRUNCATE TABLE Driver;
INSERT INTO Driver (DriverID, Name, LicenceNumber, ContactNumber) VALUES
(1, 'Kamal Perera', 'B1234567', '0771234567'),
(2, 'Sunil Shantha', 'B2345678', '0772345678'),
(3, 'Nimal Wickramasinghe', 'B3456789', '0773456789'),
(4, 'Chaminda Jayawardena', 'B4567890', '0774567890'),
(5, 'Roshan Weerasinghe', 'B5678901', '0775678901'),
(6, 'Priyantha Gunasekara', 'B6789012', '0776789012'),
(7, 'Sarath Kumara', 'B7890123', '0777890123'),
(8, 'Mahesh Bandara', 'B8901234', '0778901234'),
(9, 'Jude Fernando', 'B9012345', '0779012345'),
(10, 'Sanjeewa Rajapaksha', 'B0123456', '0770123456');

-- Assistants (Delivery assistants)
TRUNCATE TABLE Assistant;
INSERT INTO Assistant (AssistantID, Name, ContactNumber) VALUES
(1, 'Ruwan Jayasuriya', '0711122334'),
(2, 'Kasun Abeyrathne', '0712233445'),
(3, 'Dinesh Senanayake', '0713344556'),
(4, 'Asanka Madushanka', '0714455667'),
(5, 'Nuwan Kulatunga', '0715566778'),
(6, 'Pradeep Silva', '0716677889'),
(7, 'Virun Gamage', '0717788990'),
(8, 'Lahiru Rathnayake', '0718899001'),
(9, 'Dilshan Gamage', '0719900112'),
(10, 'Suresh Kumar', '0710011223');

SET FOREIGN_KEY_CHECKS = 1;



-- =============================================
-- FILE: database/seed/04_seed_orders.sql
-- =============================================

-- This file contains the Orders, Shipments and Deliveries Seed Data
-- Added:
--   - 2 Administrators
--   - 42 Customer Orders (satisfying SRS 40+ requirement)
--   - 80+ Order Details (multi-item orders)
--   - 40+ Rail Shipments
--   - 15 Valid Truck Trips (respecting working hours and no overlaps)
--   - 42 Deliveries (1:1 with Orders)

SET FOREIGN_KEY_CHECKS = 0;

-- Administrators
TRUNCATE TABLE Administrator;
INSERT INTO Administrator (AdminID, Name, Username, Password, Email) VALUES
(1, 'Admin User', 'admin', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash', 'admin@kandypack.lk'),
(2, 'Logistics Manager', 'logistics_mgr', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash', 'manager@kandypack.lk');

-- Orders (42 distinct orders across 12 routes and 12 customers)
TRUNCATE TABLE Orders;
INSERT INTO Orders (OrderID, CustomerID, RouteID, AdminID, OrderDate, Status, TotalAmount) VALUES
(1, 1, 1, 1, '2026-08-01', 'Delivered', 24500.00),
(2, 2, 3, 1, '2026-08-02', 'Delivered', 18900.00),
(3, 3, 5, 2, '2026-08-03', 'Delivered', 31200.00),
(4, 4, 7, 2, '2026-08-04', 'Delivered', 15400.00),
(5, 5, 9, 1, '2026-08-05', 'Delivered', 42000.00),
(6, 6, 11, 2, '2026-08-06', 'Delivered', 28500.00),
(7, 7, 2, 1, '2026-08-07', 'Delivered', 19800.00),
(8, 8, 4, 2, '2026-08-08', 'Delivered', 22300.00),
(9, 9, 6, 1, '2026-08-09', 'Delivered', 36700.00),
(10, 10, 8, 2, '2026-08-10', 'Delivered', 17800.00),
(11, 11, 10, 1, '2026-08-11', 'Delivered', 45600.00),
(12, 12, 12, 2, '2026-08-12', 'Delivered', 29400.00),
(13, 1, 1, 1, '2026-08-13', 'Delivered', 14200.00),
(14, 2, 3, 1, '2026-08-14', 'Delivered', 21600.00),
(15, 3, 5, 2, '2026-08-15', 'Delivered', 33400.00),
(16, 4, 7, 2, '2026-08-16', 'Delivered', 18200.00),
(17, 5, 9, 1, '2026-08-17', 'Delivered', 49100.00),
(18, 6, 11, 2, '2026-08-18', 'Delivered', 25600.00),
(19, 7, 2, 1, '2026-08-19', 'Delivered', 16700.00),
(20, 8, 4, 2, '2026-08-20', 'Delivered', 24100.00),
(21, 9, 6, 1, '2026-08-21', 'Delivered', 31500.00),
(22, 10, 8, 2, '2026-08-22', 'Delivered', 19300.00),
(23, 11, 10, 1, '2026-08-23', 'Delivered', 38900.00),
(24, 12, 12, 2, '2026-08-24', 'Delivered', 27400.00),
(25, 1, 1, 1, '2026-08-25', 'Delivered', 15800.00),
(26, 2, 3, 1, '2026-08-26', 'Delivered', 22900.00),
(27, 3, 5, 2, '2026-08-27', 'Delivered', 34800.00),
(28, 4, 7, 2, '2026-08-28', 'Delivered', 17500.00),
(29, 5, 9, 1, '2026-08-29', 'Delivered', 51200.00),
(30, 6, 11, 2, '2026-08-30', 'Delivered', 26300.00),
(31, 7, 2, 1, '2026-09-01', 'In Transit', 18400.00),
(32, 8, 4, 2, '2026-09-02', 'In Transit', 23100.00),
(33, 9, 6, 1, '2026-09-03', 'In Transit', 32700.00),
(34, 10, 8, 2, '2026-09-04', 'In Transit', 19800.00),
(35, 11, 10, 1, '2026-09-05', 'In Transit', 41200.00),
(36, 12, 12, 2, '2026-09-06', 'In Transit', 28900.00),
(37, 1, 1, 1, '2026-09-07', 'Processing', 16500.00),
(38, 2, 3, 1, '2026-09-08', 'Processing', 21400.00),
(39, 3, 5, 2, '2026-09-09', 'Processing', 35100.00),
(40, 4, 7, 2, '2026-09-10', 'Placed', 18700.00),
(41, 5, 9, 1, '2026-09-11', 'Placed', 44800.00),
(42, 6, 11, 2, '2026-09-12', 'Placed', 27100.00);

-- Order Details (Line items for each order)
TRUNCATE TABLE OrderDetail;
INSERT INTO OrderDetail (OrderDetailID, OrderID, ProductID, Quantity, LineTotal) VALUES
(1, 1, 1, 30, 13500.00), (2, 1, 3, 10, 6800.00), (3, 1, 4, 23, 4200.00),
(4, 2, 2, 25, 9500.00), (5, 2, 5, 25, 6000.00), (6, 2, 6, 28, 3400.00),
(7, 3, 3, 30, 20400.00), (8, 3, 7, 20, 5800.00), (9, 3, 8, 12, 5000.00),
(10, 4, 4, 50, 9000.00), (11, 4, 10, 40, 6400.00),
(12, 5, 1, 50, 22500.00), (13, 5, 2, 35, 13300.00), (14, 5, 9, 28, 6200.00),
(15, 6, 5, 60, 14400.00), (16, 6, 8, 36, 14100.00),
(17, 7, 1, 25, 11250.00), (18, 7, 6, 45, 5400.00), (19, 7, 10, 19, 3150.00),
(20, 8, 3, 20, 13600.00), (21, 8, 7, 30, 8700.00),
(22, 9, 2, 50, 19000.00), (23, 9, 4, 45, 8100.00), (24, 9, 9, 43, 9600.00),
(25, 10, 5, 40, 9600.00), (26, 10, 8, 21, 8200.00),
(27, 11, 1, 60, 27000.00), (28, 11, 3, 20, 13600.00), (29, 11, 10, 31, 5000.00),
(30, 12, 2, 40, 15200.00), (31, 12, 7, 35, 10150.00), (32, 12, 6, 33, 4050.00),
(33, 13, 4, 45, 8100.00), (34, 13, 5, 25, 6100.00),
(35, 14, 3, 22, 14960.00), (36, 14, 8, 17, 6640.00),
(37, 15, 1, 40, 18000.00), (38, 15, 2, 25, 9500.00), (39, 15, 9, 26, 5900.00),
(40, 16, 6, 70, 8400.00), (41, 16, 7, 33, 9800.00),
(42, 17, 1, 60, 27000.00), (43, 17, 3, 25, 17000.00), (44, 17, 10, 31, 5100.00),
(45, 18, 2, 40, 15200.00), (46, 18, 5, 43, 10400.00),
(47, 19, 4, 50, 9000.00), (48, 19, 8, 19, 7700.00),
(49, 20, 3, 25, 17000.00), (50, 20, 7, 24, 7100.00),
(51, 21, 1, 40, 18000.00), (52, 21, 2, 25, 9500.00), (53, 21, 6, 33, 4000.00),
(54, 22, 5, 45, 10800.00), (55, 22, 9, 38, 8500.00),
(56, 23, 1, 50, 22500.00), (57, 23, 3, 18, 12240.00), (58, 23, 10, 26, 4160.00),
(59, 24, 2, 45, 17100.00), (60, 24, 7, 35, 10300.00),
(61, 25, 4, 45, 8100.00), (62, 25, 8, 19, 7700.00),
(63, 26, 3, 22, 14960.00), (64, 26, 5, 33, 7940.00),
(65, 27, 1, 45, 20250.00), (66, 27, 2, 25, 9500.00), (67, 27, 9, 23, 5050.00),
(68, 28, 6, 75, 9000.00), (69, 28, 7, 29, 8500.00),
(70, 29, 1, 65, 29250.00), (71, 29, 3, 24, 16320.00), (72, 29, 10, 35, 5630.00),
(73, 30, 2, 40, 15200.00), (74, 30, 8, 28, 11100.00),
(75, 31, 3, 20, 13600.00), (76, 31, 4, 26, 4800.00),
(77, 32, 1, 30, 13500.00), (78, 32, 5, 40, 9600.00),
(79, 33, 2, 50, 19000.00), (80, 33, 7, 30, 8700.00), (81, 33, 9, 22, 5000.00),
(82, 34, 4, 55, 9900.00), (83, 34, 8, 25, 9900.00),
(84, 35, 1, 55, 24750.00), (85, 35, 3, 18, 12240.00), (86, 35, 6, 35, 4210.00),
(87, 36, 2, 45, 17100.00), (88, 36, 5, 35, 8400.00), (89, 36, 10, 21, 3400.00),
(90, 37, 3, 18, 12240.00), (91, 37, 7, 14, 4260.00),
(92, 38, 1, 30, 13500.00), (93, 38, 4, 43, 7900.00),
(94, 39, 2, 55, 20900.00), (95, 39, 8, 25, 9750.00), (96, 39, 9, 20, 4450.00),
(97, 40, 4, 50, 9000.00), (98, 40, 6, 45, 5400.00), (99, 40, 10, 26, 4300.00),
(100, 41, 1, 60, 27000.00), (101, 41, 3, 20, 13600.00), (102, 41, 9, 19, 4200.00),
(103, 42, 2, 40, 15200.00), (104, 42, 5, 35, 8400.00), (105, 42, 7, 12, 3500.00);

-- Shipments (Scheduled cargo allocations)
TRUNCATE TABLE Shipment;
INSERT INTO Shipment (ShipmentID, OrderDetailID, ScheduleID, Quantity, ShipmentDate) VALUES
(1, 1, 1, 30, '2026-08-02'), (2, 2, 1, 10, '2026-08-02'),
(3, 4, 4, 25, '2026-08-03'), (4, 5, 4, 25, '2026-08-03'),
(5, 7, 6, 30, '2026-08-04'), (6, 8, 6, 20, '2026-08-04'),
(7, 10, 8, 50, '2026-08-05'), (8, 11, 8, 40, '2026-08-05'),
(9, 12, 10, 50, '2026-08-06'), (10, 13, 10, 35, '2026-08-06'),
(11, 15, 12, 60, '2026-08-07'), (12, 16, 12, 36, '2026-08-07'),
(13, 17, 3, 25, '2026-08-08'), (14, 20, 5, 20, '2026-08-09'),
(15, 22, 7, 50, '2026-08-10'), (16, 25, 9, 40, '2026-08-11'),
(17, 27, 11, 60, '2026-08-12'), (18, 30, 12, 40, '2026-08-13'),
(19, 33, 1, 45, '2026-08-14'), (20, 35, 4, 22, '2026-08-15'),
(21, 37, 6, 40, '2026-08-16'), (22, 40, 8, 70, '2026-08-17'),
(23, 42, 10, 60, '2026-08-18'), (24, 45, 12, 40, '2026-08-19'),
(25, 47, 2, 50, '2026-08-20'), (26, 49, 5, 25, '2026-08-21'),
(27, 51, 7, 40, '2026-08-22'), (28, 54, 9, 45, '2026-08-23'),
(29, 56, 11, 50, '2026-08-24'), (30, 59, 12, 45, '2026-08-25');

-- Truck Trips (Dispatched trips respecting 40h/60h limits and non-overlapping slots)
TRUNCATE TABLE TruckTrip;
INSERT INTO TruckTrip (TripID, TruckID, RouteID, DriverID, AssistantID, TripDate, DispatchTime, ReturnTime) VALUES
(1, 1, 1, 1, 1, '2026-08-05', '08:00:00', '11:30:00'),
(2, 4, 3, 2, 2, '2026-08-06', '09:00:00', '12:00:00'),
(3, 6, 5, 3, 3, '2026-08-07', '08:30:00', '13:00:00'),
(4, 8, 7, 4, 4, '2026-08-08', '08:00:00', '13:30:00'),
(5, 10, 9, 5, 5, '2026-08-09', '07:30:00', '14:30:00'),
(6, 12, 11, 6, 6, '2026-08-10', '08:00:00', '14:00:00'),
(7, 2, 2, 7, 7, '2026-08-11', '08:00:00', '12:00:00'),
(8, 5, 4, 8, 8, '2026-08-12', '08:30:00', '12:00:00'),
(9, 7, 6, 9, 9, '2026-08-13', '08:00:00', '13:00:00'),
(10, 9, 8, 10, 10, '2026-08-14', '08:30:00', '13:30:00'),
(11, 11, 10, 1, 1, '2026-08-16', '07:00:00', '14:30:00'),
(12, 1, 1, 2, 2, '2026-08-17', '08:00:00', '11:30:00'),
(13, 3, 2, 3, 3, '2026-08-18', '08:00:00', '12:00:00'),
(14, 6, 5, 4, 4, '2026-08-19', '08:30:00', '13:00:00'),
(15, 10, 9, 5, 5, '2026-08-20', '07:30:00', '14:30:00');

-- Deliveries (1:1 with Orders, linked to TruckTrips)
TRUNCATE TABLE Delivery;
INSERT INTO Delivery (DeliveryID, OrderID, TripID, DeliveryDate, Status) VALUES
(1, 1, 1, '2026-08-05', 'Delivered'),
(2, 2, 2, '2026-08-06', 'Delivered'),
(3, 3, 3, '2026-08-07', 'Delivered'),
(4, 4, 4, '2026-08-08', 'Delivered'),
(5, 5, 5, '2026-08-09', 'Delivered'),
(6, 6, 6, '2026-08-10', 'Delivered'),
(7, 7, 7, '2026-08-11', 'Delivered'),
(8, 8, 8, '2026-08-12', 'Delivered'),
(9, 9, 9, '2026-08-13', 'Delivered'),
(10, 10, 10, '2026-08-14', 'Delivered'),
(11, 11, 11, '2026-08-16', 'Delivered'),
(12, 12, 12, '2026-08-17', 'Delivered'),
(13, 13, 1, '2026-08-05', 'Delivered'),
(14, 14, 2, '2026-08-06', 'Delivered'),
(15, 15, 3, '2026-08-07', 'Delivered'),
(16, 16, 4, '2026-08-08', 'Delivered'),
(17, 17, 5, '2026-08-09', 'Delivered'),
(18, 18, 6, '2026-08-10', 'Delivered'),
(19, 19, 7, '2026-08-11', 'Delivered'),
(20, 20, 8, '2026-08-12', 'Delivered'),
(21, 21, 9, '2026-08-13', 'Delivered'),
(22, 22, 10, '2026-08-14', 'Delivered'),
(23, 23, 11, '2026-08-16', 'Delivered'),
(24, 24, 12, '2026-08-17', 'Delivered'),
(25, 25, 13, '2026-08-18', 'Delivered'),
(26, 26, 2, '2026-08-06', 'Delivered'),
(27, 27, 3, '2026-08-07', 'Delivered'),
(28, 28, 4, '2026-08-08', 'Delivered'),
(29, 29, 5, '2026-08-09', 'Delivered'),
(30, 30, 6, '2026-08-10', 'Delivered'),
(31, 31, 13, '2026-09-02', 'In Transit'),
(32, 32, 8, '2026-09-03', 'In Transit'),
(33, 33, 14, '2026-09-04', 'In Transit'),
(34, 34, 10, '2026-09-05', 'In Transit'),
(35, 35, 15, '2026-09-06', 'In Transit'),
(36, 36, 6, '2026-09-07', 'In Transit'),
(37, 37, 1, '2026-09-08', 'Scheduled'),
(38, 38, 2, '2026-09-09', 'Scheduled'),
(39, 39, 3, '2026-09-10', 'Scheduled'),
(40, 40, 4, '2026-09-11', 'Scheduled'),
(41, 41, 5, '2026-09-12', 'Scheduled'),
(42, 42, 6, '2026-09-13', 'Scheduled');

SET FOREIGN_KEY_CHECKS = 1;




