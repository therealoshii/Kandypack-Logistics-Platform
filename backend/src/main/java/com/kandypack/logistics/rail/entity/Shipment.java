package com.kandypack.logistics.rail.entity;

public class Shipment {
    private Integer shipmentId;
    private Integer orderDetailId;
    private Integer scheduleId;
    private String shipmentDate;
    private Integer quantity;

    public Shipment() {}

    public Shipment(Integer shipmentId, Integer orderDetailId, Integer scheduleId, String shipmentDate, Integer quantity) {
        this.shipmentId = shipmentId;
        this.orderDetailId = orderDetailId;
        this.scheduleId = scheduleId;
        this.shipmentDate = shipmentDate;
        this.quantity = quantity;
    }

    public Integer getShipmentId() { return shipmentId; }
    public void setShipmentId(Integer shipmentId) { this.shipmentId = shipmentId; }

    public Integer getOrderDetailId() { return orderDetailId; }
    public void setOrderDetailId(Integer orderDetailId) { this.orderDetailId = orderDetailId; }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public String getShipmentDate() { return shipmentDate; }
    public void setShipmentDate(String shipmentDate) { this.shipmentDate = shipmentDate; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
}