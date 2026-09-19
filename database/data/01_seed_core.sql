-- store data

-- Stores
-- 6 regional stores

INSERT INTO Store (StoreID, StoreName, Capacity, City)
VALUES
    (1, 'Colombo Regional Store', 50000.00, 'Colombo'),
    (2, 'Negombo Regional Store', 30000.00, 'Negombo'),
    (3, 'Galle Regional Store', 35000.00, 'Galle'),
    (4, 'Matara Regional Store', 30000.00, 'Matara'),
    (5, 'Jaffna Regional Store', 25000.00, 'Jaffna'),
    (6, 'Trincomalee Regional Store', 28000.00, 'Trincomalee');


-- Routes
-- 12 predefined routes
-- 2 routes for each regional store

INSERT INTO Route
    (RouteID, StoreID, RouteName, MaxDeliveryTime, Distance)
VALUES
    -- Colombo
    (1, 1, 'Kandy - Colombo Central', 4.00, 115.00),
    (2, 1, 'Kandy - Colombo North',   4.50, 125.00),

    -- Negombo
    (3, 2, 'Kandy - Negombo Central',  4.50, 130.00),
    (4, 2, 'Kandy - Negombo North',    5.00, 140.00),

    -- Galle
    (5, 3, 'Kandy - Galle Central',    5.50, 225.00),
    (6, 3, 'Kandy - Galle South',      6.00, 240.00),

    -- Matara
    (7, 4, 'Kandy - Matara Central',   6.00, 255.00),
    (8, 4, 'Kandy - Matara South',     6.50, 270.00),

    -- Jaffna
    (9, 5, 'Kandy - Jaffna Central',   8.00, 400.00),
    (10, 5, 'Kandy - Jaffna North',    8.50, 420.00),

    -- Trincomalee
    (11, 6, 'Kandy - Trincomalee Central', 6.00, 250.00),
    (12, 6, 'Kandy - Trincomalee East',    6.50, 270.00);