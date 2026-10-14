package com.kandypack.logistics.rail.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

// Request to book every order line of an order onto trains at once (POST /api/shipments/schedule-order)
public class OrderShipmentDTO {

    @NotNull(message = "Order ID is required")
    private Integer orderId;

    @NotNull(message = "Schedule ID is required")
    private Integer scheduleId;

    @NotBlank(message = "Shipment date is required")
    private String shipmentDate;

    public OrderShipmentDTO() {}

    public OrderShipmentDTO(Integer orderId, Integer scheduleId, String shipmentDate) {
        this.orderId = orderId;
        this.scheduleId = scheduleId;
        this.shipmentDate = shipmentDate;
    }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public String getShipmentDate() { return shipmentDate; }
    public void setShipmentDate(String shipmentDate) { this.shipmentDate = shipmentDate; }
}
