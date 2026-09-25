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

