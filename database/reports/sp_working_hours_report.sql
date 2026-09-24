-- Kandypack Logistics Platform - Driver & Assistant Working Hours Report

DROP PROCEDURE IF EXISTS sp_working_hours_report;

DELIMITER //

CREATE PROCEDURE sp_working_hours_report(
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
    -- 1. Driver Summary
    SELECT 
        'Driver' AS StaffRole,
        d.DriverID AS StaffID,
        d.Name AS StaffName,
        d.LicenceNumber AS ReferenceID,
        COUNT(tt.TripID) AS TotalTripsCompleted,
        COALESCE(ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2), 0.00) AS TotalHoursWorked,
        40.00 AS StandardWeeklyLimit
    FROM Driver d
    LEFT JOIN TruckTrip tt ON d.DriverID = tt.DriverID 
       AND (p_StartDate IS NULL OR tt.TripDate >= p_StartDate)
       AND (p_EndDate IS NULL OR tt.TripDate <= p_EndDate)
    GROUP BY d.DriverID, d.Name, d.LicenceNumber

    UNION ALL

    -- 2. Assistant Summary
    SELECT 
        'Assistant' AS StaffRole,
        a.AssistantID AS StaffID,
        a.Name AS StaffName,
        a.ContactNumber AS ReferenceID,
        COUNT(tt.TripID) AS TotalTripsCompleted,
        COALESCE(ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2), 0.00) AS TotalHoursWorked,
        60.00 AS StandardWeeklyLimit
    FROM Assistant a
    LEFT JOIN TruckTrip tt ON a.AssistantID = tt.AssistantID 
       AND (p_StartDate IS NULL OR tt.TripDate >= p_StartDate)
       AND (p_EndDate IS NULL OR tt.TripDate <= p_EndDate)
    GROUP BY a.AssistantID, a.Name, a.ContactNumber

    ORDER BY StaffRole ASC, TotalHoursWorked DESC;
END //

DELIMITER ;

