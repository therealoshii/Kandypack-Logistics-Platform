package com.kandypack.logistics.rail.entity;

public class TrainSchedule {
    private Integer scheduleId;
    private Integer trainId;
    private String departureTime;
    private Integer cargoCapacity;

    public TrainSchedule() {}

    public TrainSchedule(Integer scheduleId, Integer trainId, String departureTime, Integer cargoCapacity) {
        this.scheduleId = scheduleId;
        this.trainId = trainId;
        this.departureTime = departureTime;
        this.cargoCapacity = cargoCapacity;
    }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public Integer getTrainId() { return trainId; }
    public void setTrainId(Integer trainId) { this.trainId = trainId; }

    public String getDepartureTime() { return departureTime; }
    public void setDepartureTime(String departureTime) { this.departureTime = departureTime; }

    public Integer getCargoCapacity() { return cargoCapacity; }
    public void setCargoCapacity(Integer cargoCapacity) { this.cargoCapacity = cargoCapacity; }
}