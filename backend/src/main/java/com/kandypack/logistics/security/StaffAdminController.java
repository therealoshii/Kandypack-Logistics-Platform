package com.kandypack.logistics.security;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/admin/staff")
public class StaffAdminController {
    private final StaffAccountService staffAccounts;

    public StaffAdminController(StaffAccountService staffAccounts) {
        this.staffAccounts = staffAccounts;
    }

    @GetMapping
    public java.util.List<StaffAccountService.StaffSummary> list() {
        return staffAccounts.list();
    }

    @PostMapping
    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.CREATED)
    public StaffAccountService.StaffSummary create(@Valid @RequestBody CreateStaffRequest request) {
        return staffAccounts.create(new StaffAccountService.CreateStaffRequest(request.name(), request.username(),
                request.email(), request.password(), request.roles()));
    }

    @PatchMapping("/{id}/enabled")
    public StaffAccountService.StaffSummary setEnabled(@PathVariable Integer id,
                                                        @Valid @RequestBody EnabledRequest request,
                                                        Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof StaffPrincipal principal)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }
        return staffAccounts.setEnabled(id, request.enabled(), principal.getId());
    }

    @PatchMapping("/{id}/roles")
    public StaffAccountService.StaffSummary updateRoles(@PathVariable Integer id,
                                                        @Valid @RequestBody RolesRequest request,
                                                        Authentication authentication) {
        if (!(authentication.getPrincipal() instanceof StaffPrincipal principal)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }
        return staffAccounts.updateRoles(id, request.roles(), principal.getId());
    }

    public record CreateStaffRequest(
            @NotBlank @Size(max = 100) String name,
            @NotBlank @Size(max = 50) String username,
            @NotBlank @Email @Size(max = 100) String email,
            @NotBlank @Size(min = 12, max = 72) String password,
            @NotEmpty Set<@NotBlank String> roles) {}

    public record EnabledRequest(boolean enabled) {}
    public record RolesRequest(@NotEmpty Set<@NotBlank String> roles) {}
}
