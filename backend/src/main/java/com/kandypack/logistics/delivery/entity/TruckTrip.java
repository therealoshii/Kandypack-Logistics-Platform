// Bridges Java application with the TruckTrip table in MySQL

package com.kandypack.logistics.delivery.entity;

import jakarta.persistence.*;
import java.time.LocalDate; // For date in the TripDate field
import java.time.LocalTime; // For time in the DispatchTime and ReturnTime fields

@Entity
@Table(name = "TruckTrip")
public class TruckTrip {

    @Id // PK is TripID
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "TripID")
    private Integer tripId;

    // Mapping these by ID for now since Truck and Route belong to Shameera's module
    // Instead of doing @ManyToOne mappling (because Vertical Slice Architecture)
    @Column(name = "TruckID", nullable = false)
    private Integer truckId;

    @Column(name = "RouteID", nullable = false)
    private Integer routeId;

    // Foreign Keys to module's tables (My module)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "DriverID", nullable = false)
    private Driver driver;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "AssistantID")
    private Assistant assistant;

    @Column(name = "TripDate", nullable = false)
    private LocalDate tripDate;

    @Column(name = "DispatchTime", nullable = false)
    private LocalTime dispatchTime;

    @Column(name = "ReturnTime", nullable = false)
    private LocalTime returnTime;

    // Default constructor
    public TruckTrip() {}

    // Getters and Setters
    public Integer getTripId() { return tripId; }
    public void setTripId(Integer tripId) { this.tripId = tripId; }

    public Integer getTruckId() { return truckId; }
    public void setTruckId(Integer truckId) { this.truckId = truckId; }

    public Integer getRouteId() { return routeId; }
    public void setRouteId(Integer routeId) { this.routeId = routeId; }

    public Driver getDriver() { return driver; }
    public void setDriver(Driver driver) { this.driver = driver; }

    public Assistant getAssistant() { return assistant; }
    public void setAssistant(Assistant assistant) { this.assistant = assistant; }

    public LocalDate getTripDate() { return tripDate; }
    public void setTripDate(LocalDate tripDate) { this.tripDate = tripDate; }

    public LocalTime getDispatchTime() { return dispatchTime; }
    public void setDispatchTime(LocalTime dispatchTime) { this.dispatchTime = dispatchTime; }

    public LocalTime getReturnTime() { return returnTime; }
    public void setReturnTime(LocalTime returnTime) { this.returnTime = returnTime; }
}
