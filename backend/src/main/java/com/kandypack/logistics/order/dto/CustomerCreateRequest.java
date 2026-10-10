package com.kandypack.logistics.order.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CustomerCreateRequest(
    @NotBlank @Size(max = 100) String fullName,
    @NotBlank @Email @Size(max = 100) String email,
    @NotBlank @Size(max = 20) String contactNumber,
    @NotBlank @Size(max = 255) String address,
    @NotBlank @Size(max = 50) String username,
    @NotBlank @Size(min = 12, max = 72) String password,
    Integer areaId
) {}