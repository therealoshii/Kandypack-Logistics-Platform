//Data transfer object for delivery route details

package com.kandypack.logistics.fleet.dto;

public class RouteDTO {

    private Integer routeID;
    private Integer storeID;
    private String routeName;
    private Double maxDeliveryTime;
    private Double distance;

    public RouteDTO() {
    }

    public Integer getRouteID() {
        return routeID;
    }

    public void setRouteID(Integer routeID) {
        this.routeID = routeID;
    }

    public Integer getStoreID() {
        return storeID;
    }

    public void setStoreID(Integer storeID) {
        this.storeID = storeID;
    }

    public String getRouteName() {
        return routeName;
    }

    public void setRouteName(String routeName) {
        this.routeName = routeName;
    }

    public Double getMaxDeliveryTime() {
        return maxDeliveryTime;
    }

    public void setMaxDeliveryTime(Double maxDeliveryTime) {
        this.maxDeliveryTime = maxDeliveryTime;
    }

    public Double getDistance() {
        return distance;
    }

    public void setDistance(Double distance) {
        this.distance = distance;
    }
}