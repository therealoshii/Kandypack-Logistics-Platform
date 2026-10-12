package com.kandypack.logistics.order.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CustomerUpdateRequest(
    @NotBlank(message = "Full name is required")
    @Size(max = 100, message = "Full name must not exceed 100 characters")
    String fullName,

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    @Size(max = 100, message = "Email must not exceed 100 characters")
    String email,

    @Size(max = 15, message = "Contact number must not exceed 15 characters")
    String contactNumber,

    @Size(max = 200, message = "Address must not exceed 200 characters")
    String address,

    Integer areaId
) {}

