// REST Controller for staff working hours report
// Calls sp_staff_weekly_hours_report stored procedure

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
@RequestMapping(path = {"/api/reports/staff-hours", "/api/staff/roster-quota"}) // Base URL path for each method
@CrossOrigin
public class StaffReportController {

    private final StaffReportService staffReportService;

    public StaffReportController(StaffReportService staffReportService) {
        this.staffReportService = staffReportService;
    }

    // Get week-by-week working hours report for all drivers and assistants.
    // eg: GET /api/reports/staff-hours?startDate=2026-08-01&endDate=2026-08-31
    @GetMapping
    public ResponseEntity<List<StaffWeeklyHoursDTO>> getStaffWeeklyHoursReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(staffReportService.getStaffWeeklyHoursReport(startDate, endDate));
    }
}
