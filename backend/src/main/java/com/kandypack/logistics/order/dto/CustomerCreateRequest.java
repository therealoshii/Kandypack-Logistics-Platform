package com.kandypack.logistics.order.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CustomerCreateRequest(
    @NotBlank(message = "Full name is required")
    @Size(max = 100, message = "Full name must not exceed 100 characters")
    String fullName,

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    @Size(max = 100, message = "Email must not exceed 100 characters")
    String email,

    @NotBlank(message = "Contact number is required")
    @Size(max = 15, message = "Contact number must not exceed 15 characters")
    String contactNumber,

    @NotBlank(message = "Address is required")
    @Size(max = 200, message = "Address must not exceed 200 characters")
    String address,

    @NotNull(message = "Area ID is required")
    Integer areaId,

    @NotBlank(message = "Username is required")
    @Size(max = 50, message = "Username must not exceed 50 characters")
    String username,

    @NotBlank(message = "Password is required")
    @Size(min = 12, max = 72, message = "Password must be between 12 and 72 characters")
    String password
) {}