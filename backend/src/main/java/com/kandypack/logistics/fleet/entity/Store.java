package com.kandypack.logistics.fleet.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

// Represents a regional store/warehouse in the logistics system
@Entity
@Table(name = "Store")
public class Store {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "StoreID")
    private Integer storeID;

    @Column(name = "StoreName", nullable = false)
    private String storeName;

    @Column(name = "Capacity", nullable = false)
    private Double capacity;

    @Column(name = "City", nullable = false)
    private String city;

    public Store() {}

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

    public Double getCapacity() {
        return capacity;
    }

    public void setCapacity(Double capacity) {
        this.capacity = capacity;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }
}