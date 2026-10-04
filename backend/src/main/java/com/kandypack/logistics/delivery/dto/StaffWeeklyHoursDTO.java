// Data Transfer Object for Staff Weekly Hours

package com.kandypack.logistics.delivery.dto;

public class StaffWeeklyHoursDTO {

    private String staffRole;
    private Integer staffId;
    private String staffName;
    private String referenceNumber;
    private String contactNumber;
    private String weekStartDate;
    private Integer weekNumber;
    private Integer tripsInWeek;
    private Double totalHoursWorked;
    private Double weeklyLimit;
    private Double remainingHours;
    private String limitStatus;

    public StaffWeeklyHoursDTO() {}

    // Getters and Setters
    public String getStaffRole() { return staffRole; }
    public void setStaffRole(String staffRole) { this.staffRole = staffRole; }

    public Integer getStaffId() { return staffId; }
    public void setStaffId(Integer staffId) { this.staffId = staffId; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public String getReferenceNumber() { return referenceNumber; }
    public void setReferenceNumber(String referenceNumber) { this.referenceNumber = referenceNumber; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getWeekStartDate() { return weekStartDate; }
    public void setWeekStartDate(String weekStartDate) { this.weekStartDate = weekStartDate; }

    public Integer getWeekNumber() { return weekNumber; }
    public void setWeekNumber(Integer weekNumber) { this.weekNumber = weekNumber; }

    public Integer getTripsInWeek() { return tripsInWeek; }
    public void setTripsInWeek(Integer tripsInWeek) { this.tripsInWeek = tripsInWeek; }

    public Double getTotalHoursWorked() { return totalHoursWorked; }
    public void setTotalHoursWorked(Double totalHoursWorked) { this.totalHoursWorked = totalHoursWorked; }

    public Double getWeeklyLimit() { return weeklyLimit; }
    public void setWeeklyLimit(Double weeklyLimit) { this.weeklyLimit = weeklyLimit; }

    public Double getRemainingHours() { return remainingHours; }
    public void setRemainingHours(Double remainingHours) { this.remainingHours = remainingHours; }

    public String getLimitStatus() { return limitStatus; }
    public void setLimitStatus(String limitStatus) { this.limitStatus = limitStatus; }
}
