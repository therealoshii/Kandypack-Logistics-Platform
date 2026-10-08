package com.kandypack.logistics.report.dto;

import java.math.BigDecimal;

public class QuarterlyReportDTO {
    private Integer year;
    private Integer quarter;
    private Long totalOrders;
    private Long totalUnitsSold;
    private BigDecimal totalVolumeSpace;
    private BigDecimal totalRevenue;

    public QuarterlyReportDTO() {}

    public QuarterlyReportDTO(Integer year, Integer quarter, Long totalOrders, Long totalUnitsSold, BigDecimal totalRevenue) {
        this.year = year;
        this.quarter = quarter;
        this.totalOrders = totalOrders;
        this.totalUnitsSold = totalUnitsSold;
        this.totalRevenue = totalRevenue;
    }

    public QuarterlyReportDTO(Integer year, Integer quarter, Long totalOrders, Long totalUnitsSold, BigDecimal totalVolumeSpace, BigDecimal totalRevenue) {
        this.year = year;
        this.quarter = quarter;
        this.totalOrders = totalOrders;
        this.totalUnitsSold = totalUnitsSold;
        this.totalVolumeSpace = totalVolumeSpace;
        this.totalRevenue = totalRevenue;
    }

    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }

    public Integer getQuarter() { return quarter; }
    public void setQuarter(Integer quarter) { this.quarter = quarter; }

    public Long getTotalOrders() { return totalOrders; }
    public void setTotalOrders(Long totalOrders) { this.totalOrders = totalOrders; }

    public Long getTotalUnitsSold() { return totalUnitsSold; }
    public void setTotalUnitsSold(Long totalUnitsSold) { this.totalUnitsSold = totalUnitsSold; }

    public BigDecimal getTotalVolumeSpace() { return totalVolumeSpace; }
    public void setTotalVolumeSpace(BigDecimal totalVolumeSpace) { this.totalVolumeSpace = totalVolumeSpace; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
}