package com.kandypack.logistics.rail.entity;

public class Train {
    private Integer trainId;
    private String trainName;
    private Integer totalCapacity;

    public Train() {}

    public Train(Integer trainId, String trainName, Integer totalCapacity) {
        this.trainId = trainId;
        this.trainName = trainName;
        this.totalCapacity = totalCapacity;
    }

    public Integer getTrainId() { return trainId; }
    public void setTrainId(Integer trainId) { this.trainId = trainId; }

    public String getTrainName() { return trainName; }
    public void setTrainName(String trainName) { this.trainName = trainName; }

    public Integer getTotalCapacity() { return totalCapacity; }
    public void setTotalCapacity(Integer totalCapacity) { this.totalCapacity = totalCapacity; }
}