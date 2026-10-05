package com.kandypack.logistics.order.dto;

import java.time.LocalDate;
import java.util.List;

public class OrderRequest {
    private Integer customerId;
    private LocalDate deliveryDate;
    private List<OrderItemDto> items;

    public OrderRequest() {}

    public Integer getCustomerID() { return customerId; }
    public void setCustomerID(Integer customerId) { this.customerId = customerId; }

    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }

    public List<OrderItemDto> getItems() { return items; }
    public void setItems(List<OrderItemDto> items) { this.items = items; }
}