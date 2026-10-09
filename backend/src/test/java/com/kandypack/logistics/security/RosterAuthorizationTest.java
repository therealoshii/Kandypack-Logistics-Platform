package com.kandypack.logistics.security;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class RosterAuthorizationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void unauthenticatedUserCannotAccessRosterApis() throws Exception {
        mockMvc.perform(get("/api/drivers"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void rosterDispatcherCanAccessRosterApis() throws Exception {
        mockMvc.perform(get("/api/drivers").with(user("dispatcher").roles("ROSTER_DISPATCHER")))
                .andExpect(status().isOk());
    }

    @Test
    void unrelatedRoleCannotAccessRosterApis() throws Exception {
        mockMvc.perform(get("/api/drivers").with(user("orderMgr").roles("ORDER_MANAGER")))
                .andExpect(status().isForbidden());
    }
}

