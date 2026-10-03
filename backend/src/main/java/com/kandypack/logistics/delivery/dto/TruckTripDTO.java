// Data Transfer Object for TruckTrip entity

package com.kandypack.logistics.delivery.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalTime;

public class TruckTripDTO {

    private Integer tripId;

    @NotNull(message = "Truck ID is required")
    private Integer truckId;

    @NotNull(message = "Route ID is required")
    private Integer routeId;

    @NotNull(message = "Driver ID is required")
    private Integer driverId;

    @NotNull(message = "Assistant ID is required")
    private Integer assistantId;

    @NotNull(message = "Trip date is required")
    private LocalDate tripDate;

    @NotNull(message = "Dispatch time is required")
    private LocalTime dispatchTime;

    @NotNull(message = "Return time is required")
    private LocalTime returnTime;

    // Read-only fields populated in responses
    private String driverName;
    private String assistantName;

    public TruckTripDTO() {}

    // Getters and Setters
    public Integer getTripId() { return tripId; }
    public void setTripId(Integer tripId) { this.tripId = tripId; }

    public Integer getTruckId() { return truckId; }
    public void setTruckId(Integer truckId) { this.truckId = truckId; }

    public Integer getRouteId() { return routeId; }
    public void setRouteId(Integer routeId) { this.routeId = routeId; }

    public Integer getDriverId() { return driverId; }
    public void setDriverId(Integer driverId) { this.driverId = driverId; }

    public Integer getAssistantId() { return assistantId; }
    public void setAssistantId(Integer assistantId) { this.assistantId = assistantId; }

    public LocalDate getTripDate() { return tripDate; }
    public void setTripDate(LocalDate tripDate) { this.tripDate = tripDate; }

    public LocalTime getDispatchTime() { return dispatchTime; }
    public void setDispatchTime(LocalTime dispatchTime) { this.dispatchTime = dispatchTime; }

    public LocalTime getReturnTime() { return returnTime; }
    public void setReturnTime(LocalTime returnTime) { this.returnTime = returnTime; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public String getAssistantName() { return assistantName; }
    public void setAssistantName(String assistantName) { this.assistantName = assistantName; }
}
