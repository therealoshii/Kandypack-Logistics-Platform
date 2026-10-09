package com.kandypack.logistics.security;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;

class StaffPrincipalTest {
    @Test
    void mapsAssignedStaffRolesToSpringAuthorities() {
        StaffAccount account = new StaffAccount("Rail Operator", "rail-op", "{bcrypt}hash", "rail@example.com");
        account.setRoles(Set.of(new StaffRole("RAIL_DISPATCHER", "Rail dispatcher"),
                new StaffRole("ANALYST", "Analytics viewer")));

        StaffPrincipal principal = new StaffPrincipal(account);

        assertEquals(Set.of("RAIL_DISPATCHER", "ANALYST"), Set.copyOf(principal.getRoleCodes()));
        assertTrue(principal.getAuthorities().stream().anyMatch(authority -> authority.getAuthority().equals("ROLE_RAIL_DISPATCHER")));
    }
}
