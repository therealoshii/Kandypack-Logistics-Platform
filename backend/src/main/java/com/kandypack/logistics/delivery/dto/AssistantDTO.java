// Data Transfer Object for Assistant entity

package com.kandypack.logistics.delivery.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AssistantDTO {

    private Integer assistantId;

    @NotBlank(message = "Assistant name is required") // If the name is blank
    @Size(max = 100, message = "Name cannot exceed 100 characters")
    private String name;

    @NotBlank(message = "Contact number is required") // If the contact number is blank
    @Size(max = 15, message = "Contact number cannot exceed 15 characters")
    private String contactNumber;

    public AssistantDTO() {}

    public AssistantDTO(Integer assistantId, String name, String contactNumber) {
        this.assistantId = assistantId;
        this.name = name;
        this.contactNumber = contactNumber;
    }

    // Getters and Setters
    public Integer getAssistantId() { return assistantId; }
    public void setAssistantId(Integer assistantId) { this.assistantId = assistantId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }
}
