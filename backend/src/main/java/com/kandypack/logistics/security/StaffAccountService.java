package com.kandypack.logistics.security;

import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class StaffAccountService {
    private final StaffAccountRepository accounts;
    private final StaffRoleRepository roles;
    private final PasswordEncoder passwordEncoder;

    public StaffAccountService(StaffAccountRepository accounts, StaffRoleRepository roles,
                               PasswordEncoder passwordEncoder) {
        this.accounts = accounts;
        this.roles = roles;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public List<StaffSummary> list() {
        return accounts.findAllByOrderByNameAsc().stream().map(StaffSummary::from).toList();
    }

    @Transactional
    public StaffSummary create(CreateStaffRequest request) {
        String username = request.username().trim();
        String email = request.email().trim();
        if (accounts.existsByUsernameIgnoreCase(username)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username is already in use.");
        }
        if (accounts.existsByEmailIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already in use.");
        }

        Set<StaffRole> assignedRoles = resolveRoles(request.roles());
        StaffAccount account = new StaffAccount(request.name().trim(), username,
                passwordEncoder.encode(request.password()), email);
        account.setRoles(assignedRoles);
        return StaffSummary.from(accounts.save(account));
    }

    @Transactional
    public StaffSummary setEnabled(Integer id, boolean enabled, Integer actorId) {
        StaffAccount account = accounts.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Staff account not found."));
        if (!enabled && id.equals(actorId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You cannot disable your own account.");
        }
        account.setEnabled(enabled);
        return StaffSummary.from(account);
    }

    @Transactional
    public StaffSummary updateRoles(Integer id, Set<String> roleCodes, Integer actorId) {
        StaffAccount account = accounts.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Staff account not found."));
        Set<StaffRole> assignedRoles = resolveRoles(roleCodes);
        boolean keepsAdmin = assignedRoles.stream().anyMatch(role -> role.getCode().equals(StaffRoleCode.ADMIN.name()));
        if (id.equals(actorId) && account.getRoles().stream()
                .anyMatch(role -> role.getCode().equals(StaffRoleCode.ADMIN.name())) && !keepsAdmin) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You cannot remove your own administrator role.");
        }
        account.setRoles(assignedRoles);
        return StaffSummary.from(account);
    }

    private Set<StaffRole> resolveRoles(Set<String> requestedCodes) {
        if (requestedCodes == null || requestedCodes.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Assign at least one role.");
        }
        Set<String> codes = requestedCodes.stream()
                .map(code -> code.trim().toUpperCase(Locale.ROOT)).collect(Collectors.toSet());
        Set<String> allowed = java.util.Arrays.stream(StaffRoleCode.values())
                .map(Enum::name).collect(Collectors.toSet());
        if (!allowed.containsAll(codes)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "One or more role codes are invalid.");
        }
        List<StaffRole> found = roles.findAllByCodeIn(codes);
        if (found.size() != codes.size()) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Staff roles are not fully seeded.");
        }
        return new HashSet<>(found);
    }

    public record CreateStaffRequest(String name, String username, String email, String password, Set<String> roles) {}
    public record StaffSummary(Integer id, String name, String username, String email,
                               boolean enabled, Set<String> roles) {
        static StaffSummary from(StaffAccount account) {
            return new StaffSummary(account.getId(), account.getName(), account.getUsername(), account.getEmail(),
                    account.isEnabled(), account.getRoles().stream().map(StaffRole::getCode).collect(Collectors.toSet()));
        }
    }
}
