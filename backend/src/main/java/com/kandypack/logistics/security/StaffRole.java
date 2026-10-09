package com.kandypack.logistics.security;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "StaffRole")
public class StaffRole {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RoleID")
    private Integer roleId;

    @Column(name = "Code", nullable = false, unique = true, length = 40)
    private String code;

    @Column(name = "DisplayName", nullable = false, length = 80)
    private String displayName;

    protected StaffRole() {}

    public StaffRole(String code, String displayName) {
        this.code = code;
        this.displayName = displayName;
    }

    public Integer getRoleId() { return roleId; }
    public String getCode() { return code; }
    public String getDisplayName() { return displayName; }
}
