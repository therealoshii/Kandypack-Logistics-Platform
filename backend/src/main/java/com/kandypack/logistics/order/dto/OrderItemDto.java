package com.kandypack.logistics.order.dto;

public class OrderItemDto {
    private Integer productId;
    private Integer quantity;

    public OrderItemDto() {}

    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
}