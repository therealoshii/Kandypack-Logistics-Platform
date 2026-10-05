package com.kandypack.logistics.order.entity;

import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "OrderDetail")
public class OrderDetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "OrderDetailID")
    private Integer orderDetailID;

    @Column(name = "OrderID")
    private Integer orderID;

    @Column(name = "ProductID")
    private Integer productID;

    @Column(name = "Quantity")
    private Integer quantity;

    @Column(name = "LineTotal")
    private BigDecimal lineTotal;

    public OrderDetail() {}

    public Integer getOrderDetailID() { return orderDetailID; }
    public void setOrderDetailID(Integer orderDetailID) { this.orderDetailID = orderDetailID; }

    public Integer getOrderID() { return orderID; }
    public void setOrderID(Integer orderID) { this.orderID = orderID; }

    public Integer getProductID() { return productID; }
    public void setProductID(Integer productID) { this.productID = productID; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public BigDecimal getLineTotal() { return lineTotal; }
    public void setLineTotal(BigDecimal lineTotal) { this.lineTotal = lineTotal; }
}