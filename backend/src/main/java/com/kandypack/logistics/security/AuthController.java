
package com.kandypack.logistics.security;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.order.entity.Customer;
import com.kandypack.logistics.order.repository.CustomerRepository;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final SecurityContextRepository contextRepository;
    private final StaffAccountRepository accounts;
    private final PasswordEncoder passwordEncoder;
    private final CustomerRepository customerRepository;

    public AuthController(
            AuthenticationManager authenticationManager,
            SecurityContextRepository contextRepository,
            StaffAccountRepository accounts,
            PasswordEncoder passwordEncoder,
            CustomerRepository customerRepository) {
        this.authenticationManager = authenticationManager;
        this.contextRepository = contextRepository;
        this.accounts = accounts;
        this.passwordEncoder = passwordEncoder;
        this.customerRepository = customerRepository;
    }

    @GetMapping("/csrf")
    public CsrfResponse csrf(CsrfToken csrfToken) {
        return new CsrfResponse(csrfToken.getToken());
    }

    // ---------------------------------------------------------
    // STAFF AUTHENTICATION - preserve existing behavior
    // ---------------------------------------------------------

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest,
            HttpServletResponse servletResponse) {

        try {
            Authentication authentication =
                    authenticationManager.authenticate(
                            UsernamePasswordAuthenticationToken.unauthenticated(
                                    request.username().trim(),
                                    request.password()));

            rotateSessionId(servletRequest);

            SecurityContext context =
                    SecurityContextHolder.createEmptyContext();

            context.setAuthentication(authentication);
            SecurityContextHolder.setContext(context);

            contextRepository.saveContext(
                    context, servletRequest, servletResponse);

            if (!(authentication.getPrincipal()
                    instanceof StaffPrincipal principal)) {
                SecurityContextHolder.clearContext();

                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ErrorResponse(
                                "Invalid staff authentication."));
            }

            return ResponseEntity.ok(StaffProfile.from(principal));

        } catch (AuthenticationException exception) {
            SecurityContextHolder.clearContext();

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse(
                            "Invalid username or password."));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<?> currentUser(
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()
                || !(authentication.getPrincipal()
                        instanceof StaffPrincipal principal)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse("Staff login required."));
        }

        return ResponseEntity.ok(StaffProfile.from(principal));
    }

    @PostMapping("/password")
    public ResponseEntity<?> changePassword(
            @Valid @RequestBody PasswordChangeRequest request,
            Authentication authentication) {

        if (authentication == null
                || !(authentication.getPrincipal()
                        instanceof StaffPrincipal principal)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(new ErrorResponse("Staff login required."));
        }

        if (!passwordEncoder.matches(
                request.currentPassword(), principal.getPassword())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(
                            "Current password is incorrect."));
        }

        StaffAccount account = accounts.findById(principal.getId())
                .orElseThrow(() -> new BadCredentialsException(
                        "Staff account no longer exists."));

        account.setPasswordHash(
                passwordEncoder.encode(request.newPassword()));

        accounts.save(account);

        return ResponseEntity.noContent().build();
    }

    // ---------------------------------------------------------
    // CUSTOMER AUTHENTICATION
    // ---------------------------------------------------------

    @PostMapping("/customer/login")
    public ResponseEntity<?> customerLogin(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest,
            HttpServletResponse servletResponse) {

        Customer customer = customerRepository
                .findByUsernameIgnoreCase(request.username().trim())
                .orElse(null);

        // Do not reveal whether a username exists.
        if (customer == null
                || customer.getPassword() == null
                || !passwordEncoder.matches(
                        request.password(), customer.getPassword())) {

            SecurityContextHolder.clearContext();

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse(
                            "Invalid username or password."));
        }

        CustomerPrincipal principal = new CustomerPrincipal(customer);

        Authentication authentication =
                UsernamePasswordAuthenticationToken.authenticated(
                        principal,
                        null,
                        principal.getAuthorities());

        rotateSessionId(servletRequest);

        SecurityContext context =
                SecurityContextHolder.createEmptyContext();

        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);

        contextRepository.saveContext(
                context, servletRequest, servletResponse);

        return ResponseEntity.ok(CustomerProfile.from(principal));
    }

    @GetMapping("/customer/me")
    public ResponseEntity<?> currentCustomer(
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()
                || !(authentication.getPrincipal()
                        instanceof CustomerPrincipal principal)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse(
                            "Customer login required."));
        }

        return ResponseEntity.ok(CustomerProfile.from(principal));
    }

    // ---------------------------------------------------------
    // LOGOUT
    // ---------------------------------------------------------

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication) {

        new SecurityContextLogoutHandler()
                .logout(request, response, authentication);

        return ResponseEntity.noContent().build();
    }

    private void rotateSessionId(HttpServletRequest request) {
        if (request.getSession(false) != null) {
            request.changeSessionId();
        } else {
            request.getSession(true);
        }
    }

    // ---------------------------------------------------------
    // REQUEST AND RESPONSE TYPES
    // ---------------------------------------------------------

    public record LoginRequest(
            @NotBlank @Size(max = 50) String username,
            @NotBlank String password) {
    }

    public record PasswordChangeRequest(
            @NotBlank String currentPassword,
            @NotBlank @Size(min = 12, max = 72) String newPassword) {
    }

    public record CsrfResponse(String token) {
    }

    public record ErrorResponse(String message) {
    }

    public record StaffProfile(
            Integer id,
            String name,
            String username,
            String email,
            List<String> roles) {

        static StaffProfile from(StaffPrincipal principal) {
            return new StaffProfile(
                    principal.getId(),
                    principal.getName(),
                    principal.getUsername(),
                    principal.getEmail(),
                    principal.getRoleCodes());
        }
    }

    public record CustomerProfile(
            Integer customerId,
            String fullName,
            String username,
            String email,
            String role) {

        static CustomerProfile from(CustomerPrincipal principal) {
            return new CustomerProfile(
                    principal.getId(),
                    principal.getFullName(),
                    principal.getUsername(),
                    principal.getEmail(),
                    "CUSTOMER");
        }
    }
}
