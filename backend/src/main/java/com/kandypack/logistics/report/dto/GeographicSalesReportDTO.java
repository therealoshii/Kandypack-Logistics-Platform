package com.kandypack.logistics.report.dto;

import java.math.BigDecimal;

public class GeographicSalesReportDTO {
    private String city;
    private Integer routeId;
    private String routeName;
    private Long totalOrders;
    private Long totalUnits;
    private BigDecimal totalSales;

    public GeographicSalesReportDTO() {}

    public GeographicSalesReportDTO(String city, Long totalOrders, BigDecimal totalSales) {
        this.city = city;
        this.totalOrders = totalOrders;
        this.totalSales = totalSales;
    }

    public GeographicSalesReportDTO(String city, Integer routeId, String routeName, Long totalOrders, Long totalUnits, BigDecimal totalSales) {
        this.city = city;
        this.routeId = routeId;
        this.routeName = routeName;
        this.totalOrders = totalOrders;
        this.totalUnits = totalUnits;
        this.totalSales = totalSales;
    }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public Integer getRouteId() { return routeId; }
    public void setRouteId(Integer routeId) { this.routeId = routeId; }

    public String getRouteName() { return routeName; }
    public void setRouteName(String routeName) { this.routeName = routeName; }

    public Long getTotalOrders() { return totalOrders; }
    public void setTotalOrders(Long totalOrders) { this.totalOrders = totalOrders; }

    public Long getTotalUnits() { return totalUnits; }
    public void setTotalUnits(Long totalUnits) { this.totalUnits = totalUnits; }

    public BigDecimal getTotalSales() { return totalSales; }
    public void setTotalSales(BigDecimal totalSales) { this.totalSales = totalSales; }
}