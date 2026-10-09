package com.kandypack.logistics.report.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public class CustomerOrderHistoryDTO {
    private Integer orderId;
    private Integer customerId;
    private String customerName;
    private LocalDate orderDate;
    private String orderStatus;
    private BigDecimal orderTotalLKR;
    private String routeName;
    private String destinationCity;
    private Integer deliveryId;
    private LocalDate deliveryDate;
    private String deliveryStatus;
    private Integer tripId;
    private String assignedDriver;
    private String assignedAssistant;
    private String assignedTruck;
    private Long totalItemLines;
    private Long totalUnitsOrdered;

    public CustomerOrderHistoryDTO() {}

    public CustomerOrderHistoryDTO(Integer orderId, Integer customerId, String customerName, LocalDate orderDate,
                                  String orderStatus, BigDecimal orderTotalLKR, String routeName, String destinationCity,
                                  Integer deliveryId, LocalDate deliveryDate, String deliveryStatus, Integer tripId,
                                  String assignedDriver, String assignedAssistant, String assignedTruck,
                                  Long totalItemLines, Long totalUnitsOrdered) {
        this.orderId = orderId;
        this.customerId = customerId;
        this.customerName = customerName;
        this.orderDate = orderDate;
        this.orderStatus = orderStatus;
        this.orderTotalLKR = orderTotalLKR;
        this.routeName = routeName;
        this.destinationCity = destinationCity;
        this.deliveryId = deliveryId;
        this.deliveryDate = deliveryDate;
        this.deliveryStatus = deliveryStatus;
        this.tripId = tripId;
        this.assignedDriver = assignedDriver;
        this.assignedAssistant = assignedAssistant;
        this.assignedTruck = assignedTruck;
        this.totalItemLines = totalItemLines;
        this.totalUnitsOrdered = totalUnitsOrdered;
    }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public Integer getCustomerId() { return customerId; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public LocalDate getOrderDate() { return orderDate; }
    public void setOrderDate(LocalDate orderDate) { this.orderDate = orderDate; }

    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }

    public BigDecimal getOrderTotalLKR() { return orderTotalLKR; }
    public void setOrderTotalLKR(BigDecimal orderTotalLKR) { this.orderTotalLKR = orderTotalLKR; }

    public String getRouteName() { return routeName; }
    public void setRouteName(String routeName) { this.routeName = routeName; }

    public String getDestinationCity() { return destinationCity; }
    public void setDestinationCity(String destinationCity) { this.destinationCity = destinationCity; }

    public Integer getDeliveryId() { return deliveryId; }
    public void setDeliveryId(Integer deliveryId) { this.deliveryId = deliveryId; }

    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }

    public String getDeliveryStatus() { return deliveryStatus; }
    public void setDeliveryStatus(String deliveryStatus) { this.deliveryStatus = deliveryStatus; }

    public Integer getTripId() { return tripId; }
    public void setTripId(Integer tripId) { this.tripId = tripId; }

    public String getAssignedDriver() { return assignedDriver; }
    public void setAssignedDriver(String assignedDriver) { this.assignedDriver = assignedDriver; }

    public String getAssignedAssistant() { return assignedAssistant; }
    public void setAssignedAssistant(String assignedAssistant) { this.assignedAssistant = assignedAssistant; }

    public String getAssignedTruck() { return assignedTruck; }
    public void setAssignedTruck(String assignedTruck) { this.assignedTruck = assignedTruck; }

    public Long getTotalItemLines() { return totalItemLines; }
    public void setTotalItemLines(Long totalItemLines) { this.totalItemLines = totalItemLines; }

    public Long getTotalUnitsOrdered() { return totalUnitsOrdered; }
    public void setTotalUnitsOrdered(Long totalUnitsOrdered) { this.totalUnitsOrdered = totalUnitsOrdered; }
}
