-- ==========================================================
-- Kandypack Logistics Platform - Rail Transport Tables
-- File: 02_tables_rail.sql
-- Entities: Train, TrainSchedule, Shipment
-- ==========================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Shipment;
DROP TABLE IF EXISTS TrainSchedule;
DROP TABLE IF EXISTS Train;

-- 1. Train Table (Sri Lanka Railways cargo compartments)
CREATE TABLE Train (
    TrainID INT AUTO_INCREMENT PRIMARY KEY,
    TrainName VARCHAR(100) NOT NULL,
    MaxCapacity DECIMAL(10,2) NOT NULL
);

-- 2. TrainSchedule Table (Scheduled bulk rail departures from Kandy origin)
CREATE TABLE TrainSchedule (
    ScheduleID INT AUTO_INCREMENT PRIMARY KEY,
    TrainID INT NOT NULL,
    CargoCapacity DECIMAL(10,2) NOT NULL,
    Destination VARCHAR(50) NOT NULL,
    DepartureTime TIME NOT NULL,
    ArrivalTime TIME NOT NULL,
    DayOfWeek VARCHAR(10) NOT NULL,
    CONSTRAINT fk_schedule_train FOREIGN KEY (TrainID)
        REFERENCES Train(TrainID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3. Shipment Table (Bulk shipment allocations tied to specific train schedules & order lines)
CREATE TABLE Shipment (
    ShipmentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderDetailID INT NOT NULL,
    ScheduleID INT NOT NULL,
    Quantity INT NOT NULL,
    ShipmentDate DATE NOT NULL,
    CONSTRAINT fk_shipment_orderdetail FOREIGN KEY (OrderDetailID)
        REFERENCES OrderDetail(OrderDetailID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_shipment_schedule FOREIGN KEY (ScheduleID)
        REFERENCES TrainSchedule(ScheduleID) ON DELETE RESTRICT ON UPDATE CASCADE
);

SET FOREIGN_KEY_CHECKS = 1;
