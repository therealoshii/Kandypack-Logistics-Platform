package com.kandypack.logistics.rail.dto;

public class ShipmentDTO {
    private Integer orderDetailId;
    private Integer scheduleId;
    private String shipmentDate;
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
