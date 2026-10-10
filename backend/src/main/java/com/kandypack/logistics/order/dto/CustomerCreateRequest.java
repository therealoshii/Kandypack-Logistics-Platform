package com.kandypack.logistics.order.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CustomerCreateRequest(
    @NotBlank(message = "Full name is required")
    String fullName,

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    String email,

    @Size(max = 15, message = "Contact number must not exceed 15 characters")
    String contactNumber,

    @Size(max = 200, message = "Address must not exceed 200 characters")
    String address,

    @NotNull(message = "Area ID is required")
    Integer areaId,

    @NotBlank(message = "Username is required")
    String username,

    @NotBlank(message = "Password is required")
    String password
) {}