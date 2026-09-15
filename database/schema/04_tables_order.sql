-- ==========================================================
-- Kandypack Logistics Platform - Order & Admin Tables
-- File: 04_tables_order.sql
-- Entities: Administrator, Order, OrderDetail, AuditLog
-- ==========================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS AuditLog;
DROP TABLE IF EXISTS OrderDetail;
DROP TABLE IF EXISTS `Order`;
DROP TABLE IF EXISTS Administrator;

-- 1. Administrator Table (System Administrators and Logistics Managers)
CREATE TABLE Administrator (
    AdminID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Order Table (Customer purchase orders placed with 7+ day lead time)
CREATE TABLE `Order` (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    RouteID INT NOT NULL,
    AdminID INT NULL, -- Assigned/updated when processed by administrative staff
    OrderDate DATE NOT NULL,
    Status VARCHAR(30) NOT NULL DEFAULT 'Placed', -- 'Placed', 'Processing', 'Shipped', 'In Transit', 'Delivered', 'Cancelled'
    TotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_order_customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_route FOREIGN KEY (RouteID)
        REFERENCES Route(RouteID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_admin FOREIGN KEY (AdminID)
        REFERENCES Administrator(AdminID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 3. OrderDetail Table (Product line items within an order)
CREATE TABLE OrderDetail (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    LineTotal DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_orderdetail_order FOREIGN KEY (OrderID)
        REFERENCES `Order`(OrderID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orderdetail_product FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 4. AuditLog Table (Security & ACID Auditing per SRS Section 5.3)
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
