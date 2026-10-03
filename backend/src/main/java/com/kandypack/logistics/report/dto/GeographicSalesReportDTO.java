package com.kandypack.logistics.report.dto;

import java.math.BigDecimal;

public class GeographicSalesReportDTO {
    private String city;
    private Long totalOrdersDelivered;
    private BigDecimal totalSalesValue;

    public GeographicSalesReportDTO() {}

    public GeographicSalesReportDTO(String city, Long totalOrdersDelivered, BigDecimal totalSalesValue) {
        this.city = city;
        this.totalOrdersDelivered = totalOrdersDelivered;
        this.totalSalesValue = totalSalesValue;
    }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public Long getTotalOrdersDelivered() { return totalOrdersDelivered; }
    public void setTotalOrdersDelivered(Long totalOrdersDelivered) { this.totalOrdersDelivered = totalOrdersDelivered; }

    public BigDecimal getTotalSalesValue() { return totalSalesValue; }
    public void setTotalSalesValue(BigDecimal totalSalesValue) { this.totalSalesValue = totalSalesValue; }
}