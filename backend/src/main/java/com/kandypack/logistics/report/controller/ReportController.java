package com.kandypack.logistics.report.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.report.dto.GeographicSalesReportDTO;
import com.kandypack.logistics.report.dto.QuarterlyReportDTO;
import com.kandypack.logistics.report.dto.TopItemsDTO;
import com.kandypack.logistics.report.service.ReportService;

@RestController
@RequestMapping("/api/reports")
@CrossOrigin
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/quarterly-sales")
    public ResponseEntity<List<QuarterlyReportDTO>> getQuarterlySalesReport(
            @RequestParam Integer year,
            @RequestParam Integer quarter) {
        return ResponseEntity.ok(reportService.getQuarterlySalesReport(year, quarter));
    }

    @GetMapping("/top-items")
    public ResponseEntity<List<TopItemsDTO>> getTopItemsReport(
            @RequestParam Integer year,
            @RequestParam Integer quarter,
            @RequestParam(required = false, defaultValue = "10") Integer limit) {
        return ResponseEntity.ok(reportService.getTopItemsReport(year, quarter, limit));
    }

    @GetMapping("/geographic-sales")
    public ResponseEntity<List<GeographicSalesReportDTO>> getGeographicSalesReport() {
        return ResponseEntity.ok(reportService.getGeographicSalesReport());
    }
}