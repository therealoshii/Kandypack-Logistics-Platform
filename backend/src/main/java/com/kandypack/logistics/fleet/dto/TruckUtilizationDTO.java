package com.kandypack.logistics.fleet.dto;

public class TruckUtilizationDTO {

    private Integer truckID;
    private String registrationNumber;
    private Double cargoCapacity;
    private Integer storeID;
    private String storeName;
    private String stationCity;
    private Integer totalDispatchedTrips;
    private Double totalOperatingHours;
    private Integer totalDeliveriesCompleted;

    public TruckUtilizationDTO() {
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

    public Double getCargoCapacity() {
        return cargoCapacity;
    }

    public void setCargoCapacity(Double cargoCapacity) {
        this.cargoCapacity = cargoCapacity;
    }

    public Integer getStoreID() {
        return storeID;
    }

    public void setStoreID(Integer storeID) {
        this.storeID = storeID;
    }

    public String getStoreName() {
        return storeName;
    }

    public void setStoreName(String storeName) {
        this.storeName = storeName;
    }

    public String getStationCity() {
        return stationCity;
    }

    public void setStationCity(String stationCity) {
        this.stationCity = stationCity;
    }

    public Integer getTotalDispatchedTrips() {
        return totalDispatchedTrips;
    }

    public void setTotalDispatchedTrips(Integer totalDispatchedTrips) {
        this.totalDispatchedTrips = totalDispatchedTrips;
    }

    public Double getTotalOperatingHours() {
        return totalOperatingHours;
    }

    public void setTotalOperatingHours(Double totalOperatingHours) {
        this.totalOperatingHours = totalOperatingHours;
    }

    public Integer getTotalDeliveriesCompleted() {
        return totalDeliveriesCompleted;
    }

    public void setTotalDeliveriesCompleted(Integer totalDeliveriesCompleted) {
        this.totalDeliveriesCompleted = totalDeliveriesCompleted;
    }
}