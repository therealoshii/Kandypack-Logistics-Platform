-- This stored procedure will generate a week-by-week report of the total hours worked by Drivers and Assistants
-- According to the SRS Section 4.5.3 / REQ-4

DROP PROCEDURE IF EXISTS sp_staff_weekly_hours_report;

DELIMITER //

CREATE PROCEDURE sp_staff_weekly_hours_report (IN p_StartDate DATE, IN p_EndDate DATE)
BEGIN
    -- Getting the Driver's weekly breakdown of hours worked
    SELECT
        'Driver' AS StaffRole,
        d.DriverID AS StaffID,
        d.Name AS StaffName,
        d.LicenceNumber AS ReferenceNumber,
        d.ContactNumber,
        DATE_SUB(tt.TripDate, INTERVAL(WEEKDAY(tt.TripDate)) DAY) AS WeekStartDate,
        YEARWEEK(tt.TripDate, 1) AS WeekNumber,
        COUNT(tt.TripID) AS TripsInWeek,
        ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2) AS TotalHoursWorked,
        40.00 AS WeeklyLimit,
        GREATEST(40.00 - ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2), 0.00) AS RemainingHours,

        CASE
            WHEN ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2) > 40.00 THEN 'Exceeded'
            ELSE 'Within Limit'
        END AS LimitStatus

    FROM Driver d
    INNER JOIN TruckTrip tt ON d.DriverID = tt.DriverID
    WHERE(p_StartDate IS NULL OR tt.TripDate >= p_StartDate)
      AND (p_EndDate IS NULL OR tt.TripDate <= p_EndDate)
    GROUP BY d.DriverID, d.Name, d.LicenceNumber, d.ContactNumber, YEARWEEK(tt.TripDate, 1), 
                DATE_SUB(tt.TripDate, INTERVAL(WEEKDAY(tt.TripDate)) DAY)

    UNION ALL

    -- Getting the Assistant's weekly breakdown of hours worked
    SELECT
        'Assistant' AS StaffRole,
        a.AssistantID AS StaffID,
        a.Name AS StaffName,
        'N/A' AS ReferenceNumber,
        a.ContactNumber,
        DATE_SUB(tt.TripDate, INTERVAL(WEEKDAY(tt.TripDate)) DAY) AS WeekStartDate,
        YEARWEEK(tt.TripDate, 1) AS WeekNumber,
        COUNT(tt.TripID) AS TripsInWeek,
        ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2) AS TotalHoursWorked,
        60.00 AS WeeklyLimit,
        GREATEST(60.00 - ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2), 0.00) AS RemainingHours,

        CASE
            WHEN ROUND(SUM(TIME_TO_SEC(TIMEDIFF(tt.ReturnTime, tt.DispatchTime)) / 3600.0), 2) > 60.00 THEN 'Exceeded'
            ELSE 'Within Limit'
        END AS LimitStatus

    FROM Assistant a
    INNER JOIN TruckTrip tt ON a.AssistantID = tt.AssistantID
    WHERE(p_StartDate IS NULL OR tt.TripDate >= p_StartDate)
      AND (p_EndDate IS NULL OR tt.TripDate <= p_EndDate)
    GROUP BY a.AssistantID, a.Name, a.ContactNumber, YEARWEEK(tt.TripDate, 1), 
                DATE_SUB(tt.TripDate, INTERVAL(WEEKDAY(tt.TripDate)) DAY)

    ORDER BY StaffRole ASC, WeekStartDate ASC, TotalHoursWorked DESC;
END //

DELIMITER ;