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
        REFERENCES Store(StoreID) ON DELETE RESTRICT ON UPDATE CASCADE
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
    Status VARCHAR(30) NOT NULL DEFAULT 'Scheduled', -- Can be 'Scheduled', 'In Transit', 'Delivered'
    CONSTRAINT fk_delivery_order FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_delivery_trip FOREIGN KEY (TripID)
        REFERENCES TruckTrip(TripID) ON DELETE RESTRICT ON UPDATE CASCADE
);

SET FOREIGN_KEY_CHECKS = 1;
