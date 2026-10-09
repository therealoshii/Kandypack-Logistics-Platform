package com.kandypack.logistics.report.service;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.kandypack.logistics.fleet.dto.FleetUsageDTO;
import com.kandypack.logistics.report.dto.CustomerOrderHistoryDTO;
import com.kandypack.logistics.report.dto.GeographicSalesReportDTO;
import com.kandypack.logistics.report.dto.QuarterlyReportDTO;
import com.kandypack.logistics.report.dto.TopItemsDTO;
import com.kandypack.logistics.report.dto.WorkingHoursReportDTO;

@Service
public class ReportService {

    private final JdbcTemplate jdbcTemplate;

    public ReportService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * 1. Quarterly sales report (value and volume)
     */
    public List<QuarterlyReportDTO> getQuarterlySalesReport(Integer year, Integer quarter) {
        String sql = "CALL sp_quarterly_sales_report(?, ?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new QuarterlyReportDTO(
                rs.getInt("OrderYear"),
                rs.getInt("OrderQuarter"),
                rs.getLong("TotalOrders"),
                rs.getLong("TotalUnitsSold"),
                rs.getBigDecimal("TotalVolumeSpace"),
                rs.getBigDecimal("TotalRevenueLKR")
        ), year, quarter);
    }

    /**
     * 2. Most ordered items in a given quarter
     */
    public List<TopItemsDTO> getTopItemsReport(Integer year, Integer quarter, Integer limit) {
        String sql = "CALL sp_top_items_report(?, ?, ?)";
        int effectiveLimit = (limit != null && limit > 0) ? limit : 10;
        return jdbcTemplate.query(sql, (rs, rowNum) -> new TopItemsDTO(
                rs.getInt("ProductID"),
                rs.getString("ProductName"),
                rs.getString("Category"),
                rs.getBigDecimal("UnitPrice"),
                rs.getLong("TotalQuantityOrdered"),
                rs.getBigDecimal("TotalRevenueGenerated"),
                rs.getLong("DistinctOrdersCount")
        ), year, quarter, effectiveLimit);
    }

    /**
     * 3. City-wise and route-wise sales breakdown
     */
    public List<GeographicSalesReportDTO> getGeographicSalesReport(LocalDate startDate, LocalDate endDate) {
        String sql = "CALL sp_geographic_sales_report(?, ?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new GeographicSalesReportDTO(
                rs.getString("City"),
                rs.getInt("RouteID"),
                rs.getString("RouteName"),
                rs.getLong("TotalOrders"),
                rs.getLong("TotalUnits"),
                rs.getBigDecimal("TotalSales")
        ), startDate != null ? Date.valueOf(startDate) : null,
           endDate != null ? Date.valueOf(endDate) : null);
    }

    /**
     * 4. Driver and assistant working hours report
     */
    public List<WorkingHoursReportDTO> getWorkingHoursReport(LocalDate startDate, LocalDate endDate) {
        String sql = "CALL sp_working_hours_report(?, ?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new WorkingHoursReportDTO(
                rs.getString("StaffRole"),
                rs.getInt("StaffID"),
                rs.getString("StaffName"),
                rs.getString("ReferenceID"),
                rs.getLong("TotalTripsCompleted"),
                rs.getBigDecimal("TotalHoursWorked"),
                rs.getBigDecimal("StandardWeeklyLimit")
        ), startDate != null ? Date.valueOf(startDate) : null,
           endDate != null ? Date.valueOf(endDate) : null);
    }

    /**
     * 5. Truck usage analysis per month
     */
    public List<FleetUsageDTO> getFleetUsageReport(Integer year, Integer month) {
        String sql = "CALL sp_fleet_usage_report(?, ?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            FleetUsageDTO dto = new FleetUsageDTO();
            dto.setTruckID(rs.getInt("TruckID"));
            dto.setRegistrationNumber(rs.getString("RegistrationNumber"));
            dto.setStoreName(rs.getString("StoreName"));
            dto.setCity(rs.getString("City"));
            dto.setTotalTrips(rs.getInt("TotalTrips"));
            dto.setOperatingHours(rs.getDouble("OperatingHours"));
            dto.setTotalMileage(rs.getDouble("TotalMileage"));
            return dto;
        }, year, month);
    }

    /**
     * 6. Customer order history with delivery details
     */
    public List<CustomerOrderHistoryDTO> getCustomerOrderHistory(Integer customerId) {
        String sql = "CALL sp_customer_order_history(?)";
        Integer paramId = (customerId != null && customerId > 0) ? customerId : null;
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Date orderDateSql = rs.getDate("OrderDate");
            Date deliveryDateSql = rs.getDate("DeliveryDate");
            return new CustomerOrderHistoryDTO(
                    rs.getInt("OrderID"),
                    rs.getInt("CustomerID"),
                    rs.getString("CustomerName"),
                    orderDateSql != null ? orderDateSql.toLocalDate() : null,
                    rs.getString("OrderStatus"),
                    rs.getBigDecimal("OrderTotalLKR"),
                    rs.getString("RouteName"),
                    rs.getString("DestinationCity"),
                    rs.getInt("DeliveryID"),
                    deliveryDateSql != null ? deliveryDateSql.toLocalDate() : null,
                    rs.getString("DeliveryStatus"),
                    rs.getInt("TripID"),
                    rs.getString("AssignedDriver"),
                    rs.getString("AssignedAssistant"),
                    rs.getString("AssignedTruck"),
                    rs.getLong("TotalItemLines"),
                    rs.getLong("TotalUnitsOrdered")
            );
        }, paramId);
    }
}