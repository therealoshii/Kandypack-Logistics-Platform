//Service for retrieving fleet utilization and report data

package com.kandypack.logistics.fleet.service;

import java.sql.Date;
import java.util.List;

import org.springframework.stereotype.Service;

import com.kandypack.logistics.fleet.dto.FleetUsageDTO;
import com.kandypack.logistics.fleet.dto.GeographicSalesDTO;
import com.kandypack.logistics.fleet.dto.TruckUtilizationDTO;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Service
public class FleetService {

    @PersistenceContext
    private EntityManager entityManager;

    @SuppressWarnings("unchecked")
    public List<TruckUtilizationDTO> getTruckUtilization() {
        List<Object[]> results = entityManager
                .createNativeQuery("SELECT * FROM vw_truck_utilization")
                .getResultList();

        return results.stream()
                .map(row -> {
                    TruckUtilizationDTO dto = new TruckUtilizationDTO();

                    dto.setTruckID(((Number) row[0]).intValue());
                    dto.setRegistrationNumber((String) row[1]);
                    dto.setCargoCapacity(((Number) row[2]).doubleValue());
                    dto.setStoreID(((Number) row[3]).intValue());
                    dto.setStoreName((String) row[4]);
                    dto.setStationCity((String) row[5]);
                    dto.setTotalDispatchedTrips(((Number) row[6]).intValue());
                    dto.setTotalOperatingHours(((Number) row[7]).doubleValue());
                    dto.setTotalDeliveriesCompleted(((Number) row[8]).intValue());

                    return dto;
                })
                .toList();
    }

    @SuppressWarnings("unchecked")
    public List<FleetUsageDTO> getFleetUsage(int year, int month) {
        List<Object[]> results = entityManager
                .createNativeQuery("CALL sp_fleet_usage_report(:year, :month)")
                .setParameter("year", year)
                .setParameter("month", month)
                .getResultList();

        return results.stream()
                .map(row -> {
                    FleetUsageDTO dto = new FleetUsageDTO();

                    dto.setTruckID(((Number) row[0]).intValue());
                    dto.setRegistrationNumber((String) row[1]);
                    dto.setStoreName((String) row[2]);
                    dto.setCity((String) row[3]);
                    dto.setTotalTrips(((Number) row[4]).intValue());
                    dto.setOperatingHours(((Number) row[5]).doubleValue());
                    dto.setTotalMileage(((Number) row[6]).doubleValue());

                    return dto;
                })
                .toList();
    }

    @SuppressWarnings("unchecked")
    public List<GeographicSalesDTO> getGeographicSales(Date startDate, Date endDate) {
        List<Object[]> results = entityManager
                .createNativeQuery(
                        "CALL sp_geographic_sales_report(:startDate, :endDate)")
                .setParameter("startDate", startDate)
                .setParameter("endDate", endDate)
                .getResultList();

        return results.stream()
                .map(row -> {
                    GeographicSalesDTO dto = new GeographicSalesDTO();

                    dto.setCity((String) row[0]);
                    dto.setRouteID(((Number) row[1]).intValue());
                    dto.setRouteName((String) row[2]);
                    dto.setTotalOrders(((Number) row[3]).intValue());
                    dto.setTotalUnits(((Number) row[4]).intValue());
                    dto.setTotalSales(((Number) row[5]).doubleValue());

                    return dto;
                })
                .toList();
    }
}