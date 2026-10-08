-- Apply once to an existing Kandypack database before deploying staff authentication.
-- Back up the database first. Fresh databases get this structure from schema/02_tables_order.sql.

ALTER TABLE Administrator
    ADD COLUMN Enabled BOOLEAN NOT NULL DEFAULT TRUE;

CREATE TABLE StaffRole (
    RoleID INT AUTO_INCREMENT PRIMARY KEY,
    Code VARCHAR(40) NOT NULL UNIQUE,
    DisplayName VARCHAR(80) NOT NULL
);

CREATE TABLE AdministratorRole (
    AdminID INT NOT NULL,
    RoleID INT NOT NULL,
    PRIMARY KEY (AdminID, RoleID),
    CONSTRAINT fk_administrator_role_admin FOREIGN KEY (AdminID)
        REFERENCES Administrator(AdminID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_administrator_role_role FOREIGN KEY (RoleID)
        REFERENCES StaffRole(RoleID) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO StaffRole (Code, DisplayName) VALUES
('ADMIN', 'Administrator'),
('ORDER_MANAGER', 'Order manager'),
('RAIL_DISPATCHER', 'Rail dispatcher'),
('FLEET_MANAGER', 'Fleet manager'),
('ROSTER_DISPATCHER', 'Roster and delivery dispatcher'),
('ANALYST', 'Analytics viewer');

-- Preserve existing administrator/order relationships. Assign only the explicit admin account.
INSERT INTO AdministratorRole (AdminID, RoleID)
SELECT a.AdminID, r.RoleID
FROM Administrator a
JOIN StaffRole r ON r.Code = 'ADMIN'
WHERE a.Username = 'admin';
