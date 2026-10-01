// Data Transfer Object for Driver entity

package com.kandypack.logistics.delivery.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class DriverDTO {

    private Integer driverId;

    @NotBlank(message = "Driver name is required") // If the name is blank
    @Size(max = 100, message = "Name cannot exceed 100 characters")
    private String name;

    @NotBlank(message = "Licence number is required") // If the licence number is blank
    @Size(max = 30, message = "Licence number cannot exceed 30 characters")
    private String licenceNumber;

    @NotBlank(message = "Contact number is required") // If the contact number is blank
    @Size(max = 15, message = "Contact number cannot exceed 15 characters")
    private String contactNumber;

    public DriverDTO() {}

    public DriverDTO(Integer driverId, String name, String licenceNumber, String contactNumber) {
        this.driverId = driverId;
        this.name = name;
        this.licenceNumber = licenceNumber;
        this.contactNumber = contactNumber;
    }

    // Getters and Setters
    public Integer getDriverId() { return driverId; }
    public void setDriverId(Integer driverId) { this.driverId = driverId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getLicenceNumber() { return licenceNumber; }
    public void setLicenceNumber(String licenceNumber) { this.licenceNumber = licenceNumber; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }
}