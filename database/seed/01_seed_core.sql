-- Added: Stores (6), Routes (12), Products (10), Customers (12)--

SET FOREIGN_KEY_CHECKS = 0;

-- Stores(Colombo,Negombo,Galle,Matara,Jaffna,Trincomalee)--
TRUNCATE TABLE Store;
INSERT INTO Store (StoreID, StoreName, Capacity, City) VALUES
(1, 'Colombo Central Warehouse', 5000.00, 'Colombo'),
(2, 'Negombo Regional Hub', 3500.00, 'Negombo'),
(3, 'Galle Distribution Center', 4000.00, 'Galle'),
(4, 'Matara Southern Depot', 3000.00, 'Matara'),
(5, 'Jaffna Northern Hub', 4500.00, 'Jaffna'),
(6, 'Trincomalee Eastern Center', 3200.00, 'Trincomalee');

-- Routes (12 routes connecting regional stores to delivery zones)
-- Distance is the estimated total round-trip road distance in kilometres.
TRUNCATE TABLE Route;

INSERT INTO Route (RouteID, StoreID, RouteName, MaxDeliveryTime, Distance) VALUES
(1, 1, 'Colombo Fort & Pettah Commercial Route', 3.50, 20.00),
(2, 1, 'Greater Colombo Suburban Route', 4.00, 40.00),
(3, 2, 'Negombo Town & Lagoon Route', 3.00, 20.00),
(4, 2, 'Kochchikade & Katunayake Logistics Route', 3.50, 35.00),
(5, 3, 'Galle Fort & Coastal District Route', 4.50, 25.00),
(6, 3, 'Hikkaduwa & Southern Corridor Route', 5.00, 50.00),
(7, 4, 'Matara City & Dondra Head Route', 5.50, 30.00),
(8, 4, 'Weligama Bay Distribution Route', 5.00, 40.00),
(9, 5, 'Jaffna City Center Route', 7.00, 20.00),
(10, 5, 'Chavakachcheri & Vadamarachchi Route', 7.50, 60.00),
(11, 6, 'Trincomalee Town & Harbor Route', 6.00, 25.00),
(12, 6, 'Kinniya & Nilaveli Coastal Route', 6.50, 50.00);

-- Delivery Areas (3 areas for each route)
TRUNCATE TABLE DeliveryArea;

INSERT INTO DeliveryArea (AreaID, AreaName, RouteID) VALUES
-- Route 1: Colombo Fort & Pettah
(1, 'Fort', 1),
(2, 'Pettah', 1),
(3, 'Colpetty', 1),

-- Route 2: Greater Colombo Suburban
(4, 'Nugegoda', 2),
(5, 'Dehiwala', 2),
(6, 'Maharagama', 2),

-- Route 3: Negombo Town & Lagoon
(7, 'Negombo Town', 3),
(8, 'Lagoon Side', 3),
(9, 'Periyamulla', 3),

-- Route 4: Kochchikade & Katunayake
(10, 'Kochchikade', 4),
(11, 'Katunayake', 4),
(12, 'Seeduwa', 4),

-- Route 5: Galle Fort & Coastal
(13, 'Galle Fort', 5),
(14, 'Galle Town', 5),
(15, 'Unawatuna', 5),

-- Route 6: Hikkaduwa & Southern Corridor
(16, 'Hikkaduwa', 6),
(17, 'Ambalangoda', 6),
(18, 'Baddegama', 6),

-- Route 7: Matara City & Dondra
(19, 'Matara Town', 7),
(20, 'Dondra', 7),
(21, 'Nupe', 7),

-- Route 8: Weligama Bay
(22, 'Weligama', 8),
(23, 'Mirissa', 8),
(24, 'Kamburugamuwa', 8),

-- Route 9: Jaffna City Center
(25, 'Jaffna Town', 9),
(26, 'Nallur', 9),
(27, 'Chundikuli', 9),

-- Route 10: Chavakachcheri & Vadamarachchi
(28, 'Point Pedro', 10),
(29, 'Chavakachcheri', 10),
(30, 'Nelliady', 10),

-- Route 11: Trincomalee Town & Harbor
(31, 'Trincomalee Town', 11),
(32, 'Uppuveli', 11),
(33, 'China Bay', 11),

-- Route 12: Kinniya & Nilaveli
(34, 'Nilaveli', 12),
(35, 'Kinniya', 12),
(36, 'Kuchchaveli', 12);

-- Products--
TRUNCATE TABLE Product;
INSERT INTO Product (ProductID, ProductName, UnitPrice, SpaceConsumption, StockQuantity, Category) VALUES
(1, 'Kandypack Detergent Powder 1kg', 450.00, 0.50, 8000, 'Cleaning'),
(2, 'Kandypack Ceylon Premium Tea 500g', 380.00, 0.20, 12000, 'Beverages'),
(3, 'Kandypack Pure Coconut Cooking Oil 1L', 680.00, 0.40, 5000, 'Groceries'),
(4, 'Kandypack Butter Biscuits 200g', 180.00, 0.15, 15000, 'Snacks'),
(5, 'Kandypack Cream Crackers 400g', 240.00, 0.25, 10000, 'Snacks'),
(6, 'Kandypack Herbal Bath Soap 100g', 120.00, 0.10, 20000, 'Personal Care'),
(7, 'Kandypack Dishwash Liquid 500ml', 290.00, 0.30, 7500, 'Cleaning'),
(8, 'Kandypack Coconut Milk Powder 300g', 390.00, 0.18, 9000, 'Groceries'),
(9, 'Kandypack Hand Sanitizer 250ml', 220.00, 0.12, 11000, 'Personal Care'),
(10, 'Kandypack Herbal Toothpaste 120g', 160.00, 0.08, 18000, 'Personal Care');

-- Customers--
TRUNCATE TABLE Customer;
INSERT INTO Customer (CustomerID, FullName, Email, ContactNumber, Address, AreaID, Username, Password) VALUES
(1, 'Lanka Super Center Colombo', 'orders@lankasuper.lk', '0112345678', 'No. 45 Galle Road, Colpetty', 3, 'lankasuper_col', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(2, 'Cargills Express Negombo', 'negombo@cargills.lk', '0312233445', 'No. 12 Main Street', 7, 'cargills_neg', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(3, 'Keells Super Galle', 'galle@keells.lk', '0912244556', 'No. 88 Matara Road', 13, 'keells_gal', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(4, 'Arpico Supercentre Matara', 'matara@arpico.com', '0412223344', 'No. 15 Hakmana Road', 19, 'arpico_mat', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(5, 'Northern Wholesale Mart Jaffna', 'contact@northernmart.lk', '0212224455', 'No. 200 Hospital Road', 25, 'northmart_jaf', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(6, 'Eastern Traders Trincomalee', 'info@easterntraders.lk', '0262223311', 'No. 34 Dockyard Road', 31, 'eastern_trinco', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(7, 'Sunil Grocery Stores', 'sunil.stores@gmail.com', '0114567890', 'No. 102 High Level Road, Nugegoda', 4, 'sunilstores', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(8, 'Silva & Sons Wholesale', 'silva.sons@gmail.com', '0317894561', 'No. 54 Sea Street', 10, 'silvasons', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(9, 'Southern Distributors Galle', 'info@southerndist.lk', '0917418520', 'No. 19 Fort Street', 16, 'southerndist', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(10, 'Ruhunu Food City Matara', 'ruhunu.food@gmail.com', '0419638520', 'No. 77 Beach Road', 22, 'ruhunufood', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(11, 'Nallur Retailers Jaffna', 'nallur.retail@gmail.com', '0218529630', 'No. 14 Point Pedro Road', 28, 'nallurretail', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash'),
(12, 'Harbor View Mart Trincomalee', 'harborview@yahoo.com', '0263692580', 'No. 6 Inner Harbor Road', 34, 'harborview', '$2a$12$e8YkYx9p8vJqWvLqUq7Wre...hash');

SET FOREIGN_KEY_CHECKS = 1;