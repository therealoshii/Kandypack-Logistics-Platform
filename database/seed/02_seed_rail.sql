-- Seed data for railway timetable: Trains (3) and TrainSchedules (12).

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Shipment;
TRUNCATE TABLE TrainSchedule;
TRUNCATE TABLE Train;

INSERT INTO Train (TrainID, TrainName, MaxCapacity) VALUES 
(1, 'Udarata Menike Express', 500.00),
(2, 'Yal Devi Northern Line', 750.00),
(3, 'Ruhunu Kumari Southern Line', 600.00);

INSERT INTO TrainSchedule (ScheduleID, TrainID, CargoCapacity, StoreID, DepartureTime, ArrivalTime, DayOfWeek) VALUES 
-- Colombo (Store 1) — two Monday departures for rollover testing
(1, 1, 150.00, 1, '06:00:00', '09:30:00', 'Monday'),
(2, 1, 150.00, 1, '14:00:00', '17:30:00', 'Monday'),
-- Negombo (Store 2)
(3, 1, 120.00, 2, '07:00:00', '08:30:00', 'Tuesday'),
(4, 1, 120.00, 2, '07:00:00', '08:30:00', 'Thursday'),
-- Galle (Store 3)
(5, 3, 100.00, 3, '06:30:00', '09:45:00', 'Wednesday'),
(6, 3, 100.00, 3, '06:30:00', '09:45:00', 'Saturday'),
-- Matara (Store 4)
(7, 3, 100.00, 4, '06:00:00', '10:30:00', 'Thursday'),
(8, 3, 100.00, 4, '06:00:00', '10:30:00', 'Sunday'),
-- Jaffna (Store 5)
(9, 2, 200.00, 5, '05:00:00', '12:00:00', 'Tuesday'),
(10, 2, 200.00, 5, '05:00:00', '12:00:00', 'Friday'),
-- Trincomalee (Store 6)
(11, 2, 150.00, 6, '05:30:00', '12:30:00', 'Wednesday'),
(12, 2, 150.00, 6, '05:30:00', '12:30:00', 'Sunday');

SET FOREIGN_KEY_CHECKS = 1;