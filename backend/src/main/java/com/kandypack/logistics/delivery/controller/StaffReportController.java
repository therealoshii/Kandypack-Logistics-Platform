// REST Controller for staff working hours
// - /api/reports/staff-hours  : week-by-week history (sp_staff_weekly_hours_report)
// - /api/staff/roster-quota   : this week's quota for every driver and assistant (vw_staff_weekly_hours)

package com.kandypack.logistics.delivery.controller;

// Internal project imports
import com.kandypack.logistics.delivery.dto.StaffWeeklyHoursDTO;
import com.kandypack.logistics.delivery.service.StaffReportService;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api") // Base URL path for each method
@CrossOrigin
public class StaffReportController {

    private final StaffReportService staffReportService;

    public StaffReportController(StaffReportService staffReportService) {
        this.staffReportService = staffReportService;
    }

    // Get week-by-week working hours report for all drivers and assistants.
    // eg: GET /api/reports/staff-hours?startDate=2026-08-01&endDate=2026-08-31
    @GetMapping("/reports/staff-hours")
    public ResponseEntity<List<StaffWeeklyHoursDTO>> getStaffWeeklyHoursReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(staffReportService.getStaffWeeklyHoursReport(startDate, endDate));
    }

    // Get the current week's hours and remaining quota for every driver and assistant.
    // Used by the Roster page before assigning a trip.
    // eg: GET /api/staff/roster-quota
    @GetMapping("/staff/roster-quota")
    public ResponseEntity<List<StaffWeeklyHoursDTO>> getCurrentWeekQuota() {
        return ResponseEntity.ok(staffReportService.getCurrentWeekQuota());
    }
}
