
-- Truck utilization view
-- Shows trip activity, operating hours and completed deliveries for each truck

DROP VIEW IF EXISTS vw_truck_utilization;

CREATE VIEW vw_truck_utilization AS
SELECT
    t.TruckID,
    t.RegistrationNumber,
    t.Capacity AS CargoCapacity,
    s.StoreID,
    s.StoreName,
    s.City AS StationCity,
    COALESCE(trip_stats.TotalDispatchedTrips, 0) AS TotalDispatchedTrips,
    COALESCE(trip_stats.TotalOperatingHours, 0.00) AS TotalOperatingHours,
    COALESCE(delivery_stats.TotalDeliveriesCompleted, 0) AS TotalDeliveriesCompleted
FROM Truck t
INNER JOIN Store s
    ON t.StoreID = s.StoreID
LEFT JOIN (
    SELECT
        TruckID,
        COUNT(TripID) AS TotalDispatchedTrips,
        ROUND(
            SUM(
                TIME_TO_SEC(TIMEDIFF(ReturnTime, DispatchTime)) / 3600.0
            ),
            2
        ) AS TotalOperatingHours
    FROM TruckTrip
    GROUP BY TruckID
) trip_stats
    ON t.TruckID = trip_stats.TruckID
LEFT JOIN (
    SELECT
        tt.TruckID,
        COUNT(DISTINCT d.DeliveryID) AS TotalDeliveriesCompleted
    FROM TruckTrip tt
    LEFT JOIN Delivery d
        ON d.TripID = tt.TripID
        AND d.Status = 'Delivered'
    GROUP BY tt.TruckID
) delivery_stats
    ON t.TruckID = delivery_stats.TruckID;
