package com.kandypack.logistics.rail.dto;

public class TrainScheduleDTO {
    private Integer scheduleId;
    private String trainName;
    private String departureTime;
    private Integer maxCapacity;
    private Integer availableCapacity;
    
    public TrainScheduleDTO() {}

    public TrainScheduleDTO(Integer scheduleId, String trainName, String departureTime, Integer maxCapacity, Integer AvailableCapacity) {
        this.scheduleId = scheduleId;
        this.trainName = trainName;
        this.departureTime = departureTime;
        this.maxCapacity = maxCapacity;
        this.availableCapacity = AvailableCapacity;
    }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public String getTrainName() { return trainName; }
    public void setTrainName(String trainName) { this.trainName = trainName; }

    public String getDepartureTime() { return departureTime; }
    public void setDepartureTime(String departureTime) { this.departureTime = departureTime; }

    public Integer getmaxCapacity() { return maxCapacity; }
    public void setmaxCapacity(Integer maxCapacity) { this.maxCapacity = maxCapacity; }
    
    public Integer getAvailableCapacity() { return availableCapacity; }
    public void setAvailableCapacity(Integer AvailableCapacity) { this.availableCapacity = AvailableCapacity; }
    
}
