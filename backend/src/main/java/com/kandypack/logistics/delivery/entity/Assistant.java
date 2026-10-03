// Bridges Java application with the Assistant table in MySQL

package com.kandypack.logistics.delivery.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "Assistant")
public class Assistant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "AssistantID")
    private Integer assistantId;

    @Column(name = "Name", nullable = false, length = 100)
    private String name;

    @Column(name = "ContactNumber", nullable = false, length = 15)
    private String contactNumber;

    // Default constructor
    public Assistant() {}

    // Getters and Setters
    public Integer getAssistantId() { return assistantId; }
    public void setAssistantId(Integer assistantId) { this.assistantId = assistantId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }
}

