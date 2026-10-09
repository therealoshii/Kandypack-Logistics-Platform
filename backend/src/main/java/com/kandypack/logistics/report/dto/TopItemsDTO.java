package com.kandypack.logistics.report.dto;

import java.math.BigDecimal;

public class TopItemsDTO {
    private Integer productId;
    private String productName;
    private String category;
    private BigDecimal unitPrice;
    private Long totalQuantitySold;
    private BigDecimal totalRevenueGenerated;
    private Long distinctOrdersCount;

    public TopItemsDTO() {}

    public TopItemsDTO(Integer productId, String productName, Long totalQuantitySold, BigDecimal totalRevenueGenerated) {
        this.productId = productId;
        this.productName = productName;
        this.totalQuantitySold = totalQuantitySold;
        this.totalRevenueGenerated = totalRevenueGenerated;
    }

    public TopItemsDTO(Integer productId, String productName, String category, BigDecimal unitPrice,
                       Long totalQuantitySold, BigDecimal totalRevenueGenerated, Long distinctOrdersCount) {
        this.productId = productId;
        this.productName = productName;
        this.category = category;
        this.unitPrice = unitPrice;
        this.totalQuantitySold = totalQuantitySold;
        this.totalRevenueGenerated = totalRevenueGenerated;
        this.distinctOrdersCount = distinctOrdersCount;
    }

    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public Long getTotalQuantitySold() { return totalQuantitySold; }
    public void setTotalQuantitySold(Long totalQuantitySold) { this.totalQuantitySold = totalQuantitySold; }

    // Alias for frontend compatibility
    public Long getTotalQuantityOrdered() { return totalQuantitySold; }
    public void setTotalQuantityOrdered(Long totalQuantityOrdered) { this.totalQuantitySold = totalQuantityOrdered; }

    public BigDecimal getTotalRevenueGenerated() { return totalRevenueGenerated; }
    public void setTotalRevenueGenerated(BigDecimal totalRevenueGenerated) { this.totalRevenueGenerated = totalRevenueGenerated; }

    public Long getDistinctOrdersCount() { return distinctOrdersCount; }
    public void setDistinctOrdersCount(Long distinctOrdersCount) { this.distinctOrdersCount = distinctOrdersCount; }
}