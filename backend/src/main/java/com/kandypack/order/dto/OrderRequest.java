package com.kandypack.order.dto;

import java.time.LocalDate;
import java.util.List;

public class OrderRequest {
    private Long customerId;
    private LocalDate deliveryDate;
    private List<OrderItemDto> items;

    // Getters and Setters
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }

    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }

    public List<OrderItemDto> getItems() { return items; }
    public void setItems(List<OrderItemDto> items) { this.items = items; }
}