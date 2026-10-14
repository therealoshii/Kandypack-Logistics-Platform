// Request to assign a whole order to a truck trip (POST /api/deliveries/assign)
// The delivery date is not sent: it is always the trip's date

package com.kandypack.logistics.delivery.dto;

import jakarta.validation.constraints.NotNull;

public class DeliveryAssignmentDTO {

    @NotNull(message = "Order ID is required")
    private Integer orderId;

    @NotNull(message = "Trip ID is required")
    private Integer tripId;

    public DeliveryAssignmentDTO() {}

    public DeliveryAssignmentDTO(Integer orderId, Integer tripId) {
        this.orderId = orderId;
        this.tripId = tripId;
    }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public Integer getTripId() { return tripId; }
    public void setTripId(Integer tripId) { this.tripId = tripId; }
}
