package com.kandypack.logistics.rail.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public class ShipmentDTO {

    @NotNull(message = "Order detail ID is required")
    private Integer orderDetailId;

    @NotNull(message = "Schedule ID is required")
    private Integer scheduleId;

    @NotBlank(message = "Shipment date is required")
    private String shipmentDate;

    @NotNull(message = "Quantity is required")
    @Positive(message = "Quantity must be greater than zero")
    private Integer quantity;

    public ShipmentDTO() {}

    public ShipmentDTO(Integer orderDetailId, Integer scheduleId, String shipmentDate, Integer quantity) {
        this.orderDetailId = orderDetailId;
        this.scheduleId = scheduleId;
        this.shipmentDate = shipmentDate;
        this.quantity = quantity;
    }

    public Integer getOrderDetailId() { return orderDetailId; }
    public void setOrderDetailId(Integer orderDetailId) { this.orderDetailId = orderDetailId; }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public String getShipmentDate() { return shipmentDate; }
    public void setShipmentDate(String shipmentDate) { this.shipmentDate = shipmentDate; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
}