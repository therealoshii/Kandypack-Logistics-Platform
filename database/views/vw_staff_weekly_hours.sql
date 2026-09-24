-- This view is to view the hours worked by Drivers and Assistants real time
-- Tracks how many hours they have remaining based on their weekly quotas
-- Drivers: 40 hours per week, Assistants: 60 hours per week

-- CURDATE() gives the current date => used to determine current week

DROP VIEW IF EXISTS vw_staff_weekly_hours;

CREATE VIEW vw_staff_weekly_hours AS
SELECT
    'Driver' AS StaffRole,
    d.DriverID AS StaffID,
    d.Name AS StaffName,
    d.LicenceNumber AS ReferenceNumber,
    d.ContactNumber,
    GetDriverWeeklyHours(d.DriverID, CURDATE()) AS CurrentWeekHoursWorked,
    40.00 AS MaxWeeklyAllowance,
    GREATEST(40.00 - GetDriverWeeklyHours(d.DriverID, CURDATE()), 0.00) AS RemainingHoursQuota
FROM Driver d

UNION ALL -- concatinates all the results from the Driver and Assistant queries to one

SELECT
    'Assistant' AS StaffRole,
    a.AssistantID AS StaffID,
    a.Name AS StaffName,
    'N/A' AS ReferenceNumber,
    a.ContactNumber,
    GetAssistantWeeklyHours(a.AssistantID, CURDATE()) AS CurrentWeekHoursWorked,
    60.00 AS MaxWeeklyAllowance,
    GREATEST(60.00 - GetAssistantWeeklyHours(a.AssistantID, CURDATE()), 0.00) AS RemainingHoursQuota
FROM Assistant a;