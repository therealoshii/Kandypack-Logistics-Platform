// Bridges Java application with the Delivery table in MySQL

package com.kandypack.logistics.delivery.entity;

import jakarta.persistence.*;
import java.time.LocalDate; // For date in DeliveryDate field

@Entity
@Table(name = "Delivery")
public class Delivery {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "DeliveryID")
    private Integer deliveryId;

    // Mapping by ID since Order belongs to Haneef's module
    @Column(name = "OrderID", nullable = false)
    private Integer orderId;

    @ManyToOne(fetch = FetchType.LAZY) // Multiple deliveries can belong to a single truck trip
    @JoinColumn(name = "TripID", nullable = false)
    private TruckTrip truckTrip;

    @Column(name = "DeliveryDate", nullable = false)
    private LocalDate deliveryDate;

    @Column(name = "Status", nullable = false, length = 20)
    private String status; // Scheduled, In Transit, Delivered

    // Default constructor
    public Delivery() {}

    // Getters and Setters
    public Integer getDeliveryId() { return deliveryId; }
    public void setDeliveryId(Integer deliveryId) { this.deliveryId = deliveryId; }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public TruckTrip getTruckTrip() { return truckTrip; }
    public void setTruckTrip(TruckTrip truckTrip) { this.truckTrip = truckTrip; }

    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}

