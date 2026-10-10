// Handles all business logic and CRUD operations for staff weekly hours report
// Executing analytical reporting for driver and assistant working quotas

package com.kandypack.logistics.delivery.service;

// Internal project imports
import com.kandypack.logistics.delivery.dto.StaffWeeklyHoursDTO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true) // does not modify database
public class StaffReportService {

    @PersistenceContext
    private EntityManager entityManager;

    // Call sp_staff_weekly_hours_report and map results to DTOs.
    /*
     * @param startDate Start of date range (nullable for all-time)
     * @param endDate End of date range (nullable for all-time)
     * @return List of StaffWeeklyHoursDTO with week-by-week breakdown
    */
    @SuppressWarnings("unchecked")
    public List<StaffWeeklyHoursDTO> getStaffWeeklyHoursReport(LocalDate startDate, LocalDate endDate) {
        List<Object[]> results = entityManager // This list will return Database rows as Object arrays
                .createNativeQuery("CALL sp_staff_weekly_hours_report(:startDate, :endDate)")
                .setParameter("startDate", startDate)
                .setParameter("endDate", endDate)
                .getResultList();

        return toDTOs(results);
    }

    // Current-week quota for EVERY driver and assistant, read from vw_staff_weekly_hours.
    // Staff with no trips this week are included with 0 hours, so the Roster page can show
    // who still has hours left before assigning a trip.
    // The columns are returned in the same order as sp_staff_weekly_hours_report.
    @SuppressWarnings("unchecked")
    public List<StaffWeeklyHoursDTO> getCurrentWeekQuota() {
        List<Object[]> results = entityManager.createNativeQuery("""
            SELECT v.StaffRole, v.StaffID, v.StaffName,
                v.ReferenceNumber, v.ContactNumber,
                DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) AS WeekStartDate,
                YEARWEEK(CURDATE(), 1) AS WeekNumber,
                    (SELECT COUNT(*)
                    FROM TruckTrip t
                    WHERE YEARWEEK(t.TripDate, 1) = YEARWEEK(CURDATE(), 1)
                        AND ((v.StaffRole = 'Driver' AND t.DriverID = v.StaffID)
                        OR (v.StaffRole = 'Assistant' AND t.AssistantID = v.StaffID))) AS TripsInWeek,
                            v.CurrentWeekHoursWorked, v.MaxWeeklyAllowance, v.RemainingHoursQuota,
                        CASE WHEN v.CurrentWeekHoursWorked > v.MaxWeeklyAllowance
                        THEN 'Exceeded' ELSE 'Within Limit' END AS LimitStatus
            FROM vw_staff_weekly_hours v
            ORDER BY v.StaffRole DESC, v.StaffName
            """).getResultList();
            
        return toDTOs(results);
    }

    // Mapping the Object[] results to StaffWeeklyHoursDTO
    private List<StaffWeeklyHoursDTO> toDTOs(List<Object[]> results) {
        List<StaffWeeklyHoursDTO> report = new ArrayList<>();
        for (Object[] row : results) {
            StaffWeeklyHoursDTO dto = new StaffWeeklyHoursDTO();
            dto.setStaffRole((String) row[0]);
            dto.setStaffId(((Number) row[1]).intValue());
            dto.setStaffName((String) row[2]);
            dto.setReferenceNumber((String) row[3]);
            dto.setContactNumber((String) row[4]);
            dto.setWeekStartDate(row[5] != null ? row[5].toString() : null);
            dto.setWeekNumber(((Number) row[6]).intValue());
            dto.setTripsInWeek(((Number) row[7]).intValue());
            dto.setTotalHoursWorked(((Number) row[8]).doubleValue());
            dto.setWeeklyLimit(((Number) row[9]).doubleValue());
            dto.setRemainingHours(((Number) row[10]).doubleValue());
            dto.setLimitStatus((String) row[11]);
            report.add(dto);
        }
        return report;
    }
}
