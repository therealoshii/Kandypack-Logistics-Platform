package com.kandypack.logistics.order.dto;

public class CustomerDTO {
    private Integer customerID;
    private String fullName;
    private String email;
    private String contactNumber;
    private String address;
    private String city;
    private String username;

    public CustomerDTO() {}

    public Integer getCustomerID() { return customerID; }
    public void setCustomerID(Integer customerID) { this.customerID = customerID; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}