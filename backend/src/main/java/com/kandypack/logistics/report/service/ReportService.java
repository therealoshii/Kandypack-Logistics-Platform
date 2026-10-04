package com.kandypack.logistics.report.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.kandypack.logistics.report.dto.GeographicSalesReportDTO;
import com.kandypack.logistics.report.dto.QuarterlyReportDTO;
import com.kandypack.logistics.report.dto.TopItemsDTO;

@Service
public class ReportService {

    private final JdbcTemplate jdbcTemplate;

    public ReportService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<QuarterlyReportDTO> getQuarterlySalesReport(Integer year, Integer quarter) {
        String sql = "CALL sp_quarterly_sales_report(?, ?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new QuarterlyReportDTO(
                rs.getInt("OrderYear"),
                rs.getInt("OrderQuarter"),
                rs.getLong("TotalOrders"),
                rs.getLong("TotalUnitsSold"),
                rs.getBigDecimal("TotalRevenueLKR")
        ), year, quarter);
    }

    public List<TopItemsDTO> getTopItemsReport(Integer year, Integer quarter, Integer limit) {
        String sql = "CALL sp_top_items_report(?, ?, ?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new TopItemsDTO(
                rs.getInt("ProductID"),
                rs.getString("ProductName"),
                rs.getLong("TotalQuantityOrdered"),
                rs.getBigDecimal("TotalRevenueGenerated")
        ), year, quarter, limit != null ? limit : 10);
    }

    public List<GeographicSalesReportDTO> getGeographicSalesReport(LocalDate startDate, LocalDate endDate) {
        String sql = "CALL sp_geographic_sales_report(?, ?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new GeographicSalesReportDTO(
                rs.getString("City"),
                rs.getLong("TotalOrders"),
                rs.getBigDecimal("TotalSales")
        ), startDate, endDate);
    }
}