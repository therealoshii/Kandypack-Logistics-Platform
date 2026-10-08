package com.kandypack.logistics.report.dto;

import java.math.BigDecimal;

public class WorkingHoursReportDTO {
    private String staffRole;
    private Integer staffId;
    private String staffName;
    private String referenceId;
    private Long totalTripsCompleted;
    private BigDecimal totalHoursWorked;
    private BigDecimal standardWeeklyLimit;

    public WorkingHoursReportDTO() {}

    public WorkingHoursReportDTO(String staffRole, Integer staffId, String staffName, String referenceId,
                                 Long totalTripsCompleted, BigDecimal totalHoursWorked, BigDecimal standardWeeklyLimit) {
        this.staffRole = staffRole;
        this.staffId = staffId;
        this.staffName = staffName;
        this.referenceId = referenceId;
        this.totalTripsCompleted = totalTripsCompleted;
        this.totalHoursWorked = totalHoursWorked;
        this.standardWeeklyLimit = standardWeeklyLimit;
    }

    public String getStaffRole() { return staffRole; }
    public void setStaffRole(String staffRole) { this.staffRole = staffRole; }

    public Integer getStaffId() { return staffId; }
    public void setStaffId(Integer staffId) { this.staffId = staffId; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public String getReferenceId() { return referenceId; }
    public void setReferenceId(String referenceId) { this.referenceId = referenceId; }

    public Long getTotalTripsCompleted() { return totalTripsCompleted; }
    public void setTotalTripsCompleted(Long totalTripsCompleted) { this.totalTripsCompleted = totalTripsCompleted; }

    public BigDecimal getTotalHoursWorked() { return totalHoursWorked; }
    public void setTotalHoursWorked(BigDecimal totalHoursWorked) { this.totalHoursWorked = totalHoursWorked; }

    public BigDecimal getStandardWeeklyLimit() { return standardWeeklyLimit; }
    public void setStandardWeeklyLimit(BigDecimal standardWeeklyLimit) { this.standardWeeklyLimit = standardWeeklyLimit; }
}
