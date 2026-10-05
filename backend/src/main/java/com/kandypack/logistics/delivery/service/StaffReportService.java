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

        // Mapping the Object[] results to StaffWeeklyHoursDTO
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
