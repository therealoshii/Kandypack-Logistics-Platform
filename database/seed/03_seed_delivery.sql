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

