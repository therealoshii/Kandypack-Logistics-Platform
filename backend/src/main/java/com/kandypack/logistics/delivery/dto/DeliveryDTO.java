// Data Transfer Object for Delivery entity

package com.kandypack.logistics.delivery.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public class DeliveryDTO {

    private Integer deliveryId;

    @NotNull(message = "Order ID is required")
    private Integer orderId;

    @NotNull(message = "Trip ID is required")
    private Integer tripId;

    @NotNull(message = "Delivery date is required")
    private LocalDate deliveryDate;

    private String status;

    public DeliveryDTO() {}

    public DeliveryDTO(Integer deliveryId, Integer orderId, Integer tripId,
                       LocalDate deliveryDate, String status) {
        this.deliveryId = deliveryId;
        this.orderId = orderId;
        this.tripId = tripId;
        this.deliveryDate = deliveryDate;
        this.status = status;
    }

    // Getters and Setters
    public Integer getDeliveryId() { return deliveryId; }
    public void setDeliveryId(Integer deliveryId) { this.deliveryId = deliveryId; }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public Integer getTripId() { return tripId; }
    public void setTripId(Integer tripId) { this.tripId = tripId; }

    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
