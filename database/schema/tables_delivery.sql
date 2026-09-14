-- Driver Table
CREATE TABLE Driver (
    DriverID INT AUTO_INCREMENT PRIMARY KEY, -- Auto increment so we don't have to generate them manually
    Name VARCHAR(100) NOT NULL,
    LicenseNumber VARCHAR(20) UNIQUE NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL
);

-- Assistant Table
CREATE TABLE Assistant (
    AssistantID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL
);

-- Truck_Trip Table
CREATE TABLE Truck_Trip (
    TripID INT AUTO_INCREMENT PRIMARY KEY,
    TruckID INT NOT NULL,
    RouteID INT NOT NULL,

    DriverID INT NOT NULL,
    AssistantID INT NOT NULL,
    -- There has to be a driver and an assistant definitely for each trip

    TripDate DATE NOT NULL,
    DispatchTime TIME NOT NULL,
    ReturnTime TIME NOT NULL,

    FOREIGN KEY (TruckID) REFERENCES Truck(TruckID), -- Shameera
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID), -- Shameera
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    FOREIGN KEY (AssistantID) REFERENCES Assistant(AssistantID)
);

-- Delivery Table
CREATE TABLE Delivery (
    DeliveryID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    TripID INT NOT NULL,
    DeliveryDate DATE NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Scheduled', -- can be set to 'Scheduled', 'In Transit' or 'Delivered'

    FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID), -- Haneef
    FOREIGN KEY (TripID) REFERENCES Truck_Trip(TripID)
);
