-- This file contains the core tables
-- Tables: Customer, Product, Store, Route

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS DeliveryArea;
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

-- DeliveryArea Table (Areas covered by each last-mile route)
CREATE TABLE DeliveryArea (
    AreaID INT AUTO_INCREMENT PRIMARY KEY,
    AreaName VARCHAR(60) NOT NULL,
    RouteID INT NOT NULL,

    CONSTRAINT uq_area_per_route UNIQUE (RouteID, AreaName),
    CONSTRAINT fk_area_route FOREIGN KEY (RouteID)
        REFERENCES Route(RouteID) ON DELETE RESTRICT ON UPDATE CASCADE
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
    AreaID INT NOT NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,

    CONSTRAINT fk_customer_area FOREIGN KEY (AreaID)
        REFERENCES DeliveryArea(AreaID) ON DELETE RESTRICT ON UPDATE CASCADE
);

SET FOREIGN_KEY_CHECKS = 1;