package com.kandypack.logistics.report.dto;

import java.math.BigDecimal;

public class GeographicSalesReportDTO {
    private String city;
    private Long totalOrders;
    private BigDecimal totalSales;

    public GeographicSalesReportDTO() {}

    public GeographicSalesReportDTO(String city, Long totalOrders, BigDecimal totalSales) {
        this.city = city;
        this.totalOrders = totalOrders;
        this.totalSales = totalSales;
    }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public Long getTotalOrders() { return totalOrders; }
    public void setTotalOrders(Long totalOrders) { this.totalOrders = totalOrders; }

    public BigDecimal getTotalSales() { return totalSales; }
    public void setTotalSales(BigDecimal totalSales) { this.totalSales = totalSales; }
}