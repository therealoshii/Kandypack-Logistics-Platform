-- Truck seed data

--Trucks assigned to the regional stores
--Two trucks are assigned to each store

INSERT INTO Truck
    (TruckID, RegistrationNumber, Capacity, StoreID)
VALUES
    (1, 'WP-CA-1001', 5000.00, 1),
    (2, 'WP-CA-1002', 5000.00, 1),

    (3, 'WP-CB-1003', 4000.00, 2),
    (4, 'WP-CB-1004', 4000.00, 2),

    (5, 'SP-CA-1005', 4500.00, 3),
    (6, 'SP-CA-1006', 4500.00, 3),

    (7, 'SP-CB-1007', 4000.00, 4),
    (8, 'SP-CB-1008', 4000.00, 4),

    (9, 'NP-CA-1009', 3500.00, 5),
    (10, 'NP-CA-1010', 3500.00, 5),

    (11, 'EP-CA-1011', 4000.00, 6),
    (12, 'EP-CA-1012', 4000.00, 6);