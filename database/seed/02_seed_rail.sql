INSERT INTO Train (TrainName, MaxCapacity) VALUES 
('Kandy Express 01', 500.00),
('Northern Line Express', 750.00);

INSERT INTO TrainSchedule (TrainID, CargoCapacity, Destination, DepartureTime, ArrivalTime, DayOfWeek) VALUES 
(1, 100.00, 'Colombo', '06:00:00', '09:30:00', 'Monday'),
(1, 100.00, 'Colombo', '14:00:00', '17:30:00', 'Monday'),
(2, 200.00, 'Jaffna', '05:00:00', '12:00:00', 'Tuesday');