package com.kandypack.logistics.report.dto;

import java.math.BigDecimal;

public class TopItemsDTO {
    private Integer productId;
    private String productName;
    private Long totalQuantitySold;
    private BigDecimal totalRevenueGenerated;

    public TopItemsDTO() {}

    public TopItemsDTO(Integer productId, String productName, Long totalQuantitySold, BigDecimal totalRevenueGenerated) {
        this.productId = productId;
        this.productName = productName;
        this.totalQuantitySold = totalQuantitySold;
        this.totalRevenueGenerated = totalRevenueGenerated;
    }

    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public Long getTotalQuantitySold() { return totalQuantitySold; }
    public void setTotalQuantitySold(Long totalQuantitySold) { this.totalQuantitySold = totalQuantitySold; }

    public BigDecimal getTotalRevenueGenerated() { return totalRevenueGenerated; }
    public void setTotalRevenueGenerated(BigDecimal totalRevenueGenerated) { this.totalRevenueGenerated = totalRevenueGenerated; }
}