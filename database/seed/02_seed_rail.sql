-- =========================================================================
-- RAILWAY TIMETABLE SEED DATA (Task W1)
-- =========================================================================

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Shipment;
TRUNCATE TABLE TrainSchedule;
TRUNCATE TABLE Train;

-- Insert physical trains with maximum capacity limits
INSERT INTO Train (TrainID, TrainName, MaxCapacity) VALUES 
(1, 'Udarata Menike Express', 500.00),
(2, 'Yal Devi Northern Line', 750.00),
(3, 'Ruhunu Kumari Southern Line', 600.00);

-- Insert explicit TrainSchedules using StoreID FKs (Store IDs: Colombo=1, Negombo=2, Galle=3, Matara=4, Jaffna=5, Trincomalee=6)
INSERT INTO TrainSchedule (ScheduleID, TrainID, CargoCapacity, StoreID, DepartureTime, ArrivalTime, DayOfWeek) VALUES 
-- Colombo (StoreID: 1) - Has two departures on Monday for rollover testing
(1, 1, 150.00, 1, '06:00:00', '09:30:00', 'Monday'),
(2, 1, 150.00, 1, '14:00:00', '17:30:00', 'Monday'),

-- Negombo (StoreID: 2)
(3, 1, 120.00, 2, '07:00:00', '08:30:00', 'Tuesday'),
(4, 1, 120.00, 2, '07:00:00', '08:30:00', 'Thursday'),

-- Galle (StoreID: 3)
(5, 3, 100.00, 3, '06:30:00', '09:45:00', 'Wednesday'),
(6, 3, 100.00, 3, '06:30:00', '09:45:00', 'Saturday'),

-- Matara (StoreID: 4)
(7, 3, 100.00, 4, '06:00:00', '10:30:00', 'Thursday'),
(8, 3, 100.00, 4, '06:00:00', '10:30:00', 'Sunday'),

-- Jaffna (StoreID: 5)
(9, 2, 200.00, 5, '05:00:00', '12:00:00', 'Tuesday'),
(10, 2, 200.00, 5, '05:00:00', '12:00:00', 'Friday'),

-- Trincomalee (StoreID: 6)
(11, 2, 150.00, 6, '05:30:00', '12:30:00', 'Wednesday'),
(12, 2, 150.00, 6, '05:30:00', '12:30:00', 'Sunday');

SET FOREIGN_KEY_CHECKS = 1;