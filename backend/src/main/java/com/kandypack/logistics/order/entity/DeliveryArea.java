package com.kandypack.logistics.order.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "DeliveryArea")
public class DeliveryArea {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "AreaID")
    private Integer areaID;

    @Column(name = "AreaName", nullable = false)
    private String areaName;

    @Column(name = "RouteID", nullable = false)
    private Integer routeID;

    // ஒருவேளை நீங்கள் சிட்டியை நேరుவாகப் பயன்படுத்த விரும்பினால் அல்லது தற்காலிகமாக:
    private String city;

    // Getters and Setters
    public Integer getAreaID() { return areaID; }
    public void setAreaID(Integer areaID) { this.areaID = areaID; }

    public String getAreaName() { return areaName; }
    public void setAreaName(String areaName) { this.areaName = areaName; }

    public Integer getRouteID() { return routeID; }
    public void setRouteID(Integer routeID) { this.routeID = routeID; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
}