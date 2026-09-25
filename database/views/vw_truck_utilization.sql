--Truck utilization view
--Shows trip activity, operating hours and completed deliveries for each truck

DROP VIEW IF EXISTS vw_truck_utilization;

CREATE VIEW vw_truck_utilization AS
SELECT
    t.TruckID,
    t.RegistrationNumber,
    t.Capacity AS CargoCapacity,
    s.StoreID,
    s.StoreName,
    s.City AS StationCity,
    COUNT(tt.TripID) AS TotalDispatchedTrips,
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
    ) AS TotalOperatingHours,
    COUNT(DISTINCT d.DeliveryID) AS TotalDeliveriesCompleted
FROM Truck t
INNER JOIN Store s
    ON t.StoreID = s.StoreID
LEFT JOIN TruckTrip tt
    ON t.TruckID = tt.TruckID
LEFT JOIN Delivery d
    ON tt.TripID = d.TripID
GROUP BY
    t.TruckID,
    t.RegistrationNumber,
    t.Capacity,
    s.StoreID,
    s.StoreName,
    s.City;