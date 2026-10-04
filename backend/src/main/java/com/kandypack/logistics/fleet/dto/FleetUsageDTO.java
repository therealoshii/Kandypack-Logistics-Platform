package com.kandypack.logistics.fleet.dto;

public class FleetUsageDTO {

    private Integer truckID;
    private String registrationNumber;
    private String storeName;
    private String city;
    private Integer totalTrips;
    private Double operatingHours;
    private Double totalMileage;

    public FleetUsageDTO() {
    }

    public Integer getTruckID() {
        return truckID;
    }

    public void setTruckID(Integer truckID) {
        this.truckID = truckID;
    }

    public String getRegistrationNumber() {
        return registrationNumber;
    }

    public void setRegistrationNumber(String registrationNumber) {
        this.registrationNumber = registrationNumber;
    }

    public String getStoreName() {
        return storeName;
    }

    public void setStoreName(String storeName) {
        this.storeName = storeName;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public Integer getTotalTrips() {
        return totalTrips;
    }

    public void setTotalTrips(Integer totalTrips) {
        this.totalTrips = totalTrips;
    }

    public Double getOperatingHours() {
        return operatingHours;
    }

    public void setOperatingHours(Double operatingHours) {
        this.operatingHours = operatingHours;
    }

    public Double getTotalMileage() {
        return totalMileage;
    }

    public void setTotalMileage(Double totalMileage) {
        this.totalMileage = totalMileage;
    }
}