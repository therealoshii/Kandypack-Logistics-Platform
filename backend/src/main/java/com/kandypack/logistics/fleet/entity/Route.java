package com.kandypack.logistics.fleet.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

//Represents a delivery route connected to a regional store

@Entity
@Table(name = "Route")
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RouteID")
    private Integer routeID;

    @Column(name = "StoreID", nullable = false)
    private Integer storeID;

    @Column(name = "RouteName", nullable = false)
    private String routeName;

    @Column(name = "MaxDeliveryTime", nullable = false)
    private Double maxDeliveryTime;

    @Column(name = "Distance", nullable = false)
    private Double distance;

    public Route() {
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