package com.kandypack.logistics.report.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.fleet.dto.FleetUsageDTO;
import com.kandypack.logistics.report.dto.CustomerOrderHistoryDTO;
import com.kandypack.logistics.report.dto.GeographicSalesReportDTO;
import com.kandypack.logistics.report.dto.QuarterlyReportDTO;
import com.kandypack.logistics.report.dto.TopItemsDTO;
import com.kandypack.logistics.report.dto.WorkingHoursReportDTO;
import com.kandypack.logistics.report.service.ReportPdfService;
import com.kandypack.logistics.report.service.ReportService;

@RestController
@RequestMapping("/api/reports")
@CrossOrigin
public class ReportController {

    private final ReportService reportService;
    private final ReportPdfService reportPdfService;

    public ReportController(ReportService reportService, ReportPdfService reportPdfService) {
        this.reportService = reportService;
        this.reportPdfService = reportPdfService;
    }

    // -------------------------------------------------------------
    // 1. Quarterly Sales Report (Value & Volume)
    // -------------------------------------------------------------
    @GetMapping("/quarterly-sales")
    public ResponseEntity<List<QuarterlyReportDTO>> getQuarterlySalesReport(
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer quarter) {
        return ResponseEntity.ok(reportService.getQuarterlySalesReport(year, quarter));
    }

    @GetMapping(value = "/quarterly-sales/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> getQuarterlySalesPdf(
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer quarter) {
        List<QuarterlyReportDTO> data = reportService.getQuarterlySalesReport(year, quarter);
        byte[] pdf = reportPdfService.generateQuarterlySalesPdf(data, year, quarter);

        String filename = String.format("kandypack-quarterly-sales-%s-Q%s.pdf",
                year != null ? year : "all",
                quarter != null ? quarter : "all");

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    // -------------------------------------------------------------
    // 2. Most Ordered Items in a Given Quarter
    // -------------------------------------------------------------
    @GetMapping("/top-items")
    public ResponseEntity<List<TopItemsDTO>> getTopItemsReport(
            @RequestParam Integer year,
            @RequestParam Integer quarter,
            @RequestParam(required = false, defaultValue = "10") Integer limit) {
        return ResponseEntity.ok(reportService.getTopItemsReport(year, quarter, limit));
    }

    @GetMapping(value = "/top-items/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> getTopItemsPdf(
            @RequestParam Integer year,
            @RequestParam Integer quarter,
            @RequestParam(required = false, defaultValue = "10") Integer limit) {
        List<TopItemsDTO> data = reportService.getTopItemsReport(year, quarter, limit);
        byte[] pdf = reportPdfService.generateTopItemsPdf(data, year, quarter, limit);

        String filename = String.format("kandypack-top-items-%d-Q%d.pdf", year, quarter);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    // -------------------------------------------------------------
    // 3. City-wise and Route-wise Sales Breakdown
    // -------------------------------------------------------------
    @GetMapping("/geographic-sales")
    public ResponseEntity<List<GeographicSalesReportDTO>> getGeographicSalesReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getGeographicSalesReport(startDate, endDate));
    }

    @GetMapping(value = "/geographic-sales/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> getGeographicSalesPdf(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<GeographicSalesReportDTO> data = reportService.getGeographicSalesReport(startDate, endDate);
        byte[] pdf = reportPdfService.generateGeographicSalesPdf(data, startDate, endDate);

        String filename = "kandypack-geographic-sales.pdf";

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    // -------------------------------------------------------------
    // 4. Driver and Assistant Working Hours Report
    // -------------------------------------------------------------
    @GetMapping("/working-hours")
    public ResponseEntity<List<WorkingHoursReportDTO>> getWorkingHoursReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getWorkingHoursReport(startDate, endDate));
    }

    @GetMapping(value = "/working-hours/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> getWorkingHoursPdf(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<WorkingHoursReportDTO> data = reportService.getWorkingHoursReport(startDate, endDate);
        byte[] pdf = reportPdfService.generateWorkingHoursPdf(data, startDate, endDate);

        String filename = "kandypack-staff-working-hours.pdf";

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    // -------------------------------------------------------------
    // 5. Truck Usage Analysis Per Month (PDF export; JSON served by FleetController)
    // -------------------------------------------------------------
    @GetMapping(value = "/fleet-usage/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> getFleetUsagePdf(
            @RequestParam int year,
            @RequestParam int month) {
        List<FleetUsageDTO> data = reportService.getFleetUsageReport(year, month);
        byte[] pdf = reportPdfService.generateFleetUsagePdf(data, year, month);

        String filename = String.format("kandypack-fleet-usage-%d-%02d.pdf", year, month);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    // -------------------------------------------------------------
    // 6. Customer Order History with Delivery Details
    // -------------------------------------------------------------
    @GetMapping("/customer-order-history")
    public ResponseEntity<List<CustomerOrderHistoryDTO>> getCustomerOrderHistory(
            @RequestParam(required = false) Integer customerId) {
        return ResponseEntity.ok(reportService.getCustomerOrderHistory(customerId));
    }

    @GetMapping(value = "/customer-order-history/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> getCustomerOrderHistoryPdf(
            @RequestParam(required = false) Integer customerId) {
        List<CustomerOrderHistoryDTO> data = reportService.getCustomerOrderHistory(customerId);
        byte[] pdf = reportPdfService.generateCustomerOrderHistoryPdf(data, customerId);

        String filename = String.format("kandypack-customer-order-history-%s.pdf",
                (customerId != null && customerId > 0) ? "cust-" + customerId : "all");

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }
}