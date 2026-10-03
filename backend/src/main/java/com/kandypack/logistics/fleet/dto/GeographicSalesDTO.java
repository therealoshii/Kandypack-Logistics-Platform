package com.kandypack.logistics.fleet.dto;

public class GeographicSalesDTO {

    private String city;
    private Integer routeID;
    private String routeName;
    private Integer totalOrders;
    private Integer totalUnits;
    private Double totalSales;

    public GeographicSalesDTO() {
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public Integer getRouteID() {
        return routeID;
    }

    public void setRouteID(Integer routeID) {
        this.routeID = routeID;
    }

    public String getRouteName() {
        return routeName;
    }

    public void setRouteName(String routeName) {
        this.routeName = routeName;
    }

    public Integer getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(Integer totalOrders) {
        this.totalOrders = totalOrders;
    }

    public Integer getTotalUnits() {
        return totalUnits;
    }

    public void setTotalUnits(Integer totalUnits) {
        this.totalUnits = totalUnits;
    }

    public Double getTotalSales() {
        return totalSales;
    }

    public void setTotalSales(Double totalSales) {
        this.totalSales = totalSales;
    }
}