package com.kandypack.logistics.order.entity;

import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Product")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ProductID")
    private Integer productID;

    @Column(name = "ProductName")
    private String productName;

    @Column(name = "UnitPrice")
    private BigDecimal unitPrice;

    @Column(name = "SpaceConsumption")
    private BigDecimal spaceConsumption;

    @Column(name = "StockQuantity")
    private Integer stockQuantity;

    @Column(name = "Category")
    private String category;

    public Product() {}

    public Integer getProductID() { return productID; }
    public void setProductID(Integer productID) { this.productID = productID; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public BigDecimal getSpaceConsumption() { return spaceConsumption; }
    public void setSpaceConsumption(BigDecimal spaceConsumption) { this.spaceConsumption = spaceConsumption; }

    public Integer getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(Integer stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
}