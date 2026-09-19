DROP PROCEDURE IF EXISTS sp_fleet_usage_report;

DELIMITER //

CREATE PROCEDURE sp_fleet_usage_report(
    IN p_Year INT,
    IN p_Month INT
)
BEGIN
    SELECT
        t.TruckID,
        t.RegistrationNumber,
        s.StoreName,
        s.City,
        COUNT(tt.TripID) AS TotalTrips,

        COALESCE(
            ROUND(
                SUM(
                    TIME_TO_SEC(
                        TIMEDIFF(tt.ReturnTime, tt.DispatchTime)
                    ) / 3600.0
                ),
                2
            ),
            0.00
        ) AS OperatingHours,

        COALESCE(
            ROUND(SUM(r.Distance), 2),
            0.00
        ) AS TotalMileage

    FROM Truck t
    INNER JOIN Store s
        ON t.StoreID = s.StoreID

    LEFT JOIN TruckTrip tt
        ON t.TruckID = tt.TruckID
        AND YEAR(tt.TripDate) = p_Year
        AND MONTH(tt.TripDate) = p_Month

    LEFT JOIN Route r
        ON tt.RouteID = r.RouteID

    GROUP BY
        t.TruckID,
        t.RegistrationNumber,
        s.StoreName,
        s.City

    ORDER BY
        t.TruckID;
END //

DELIMITER ;