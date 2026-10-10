package com.kandypack.logistics.security;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.context.SecurityContextRepository;
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
@RequestMapping("/api/auth/customer")
public class CustomerAuthController {

    private final CustomerRepository customerRepository;
    private final PasswordEncoder passwordEncoder;
    private final SecurityContextRepository contextRepository;

    public CustomerAuthController(
            CustomerRepository customerRepository,
            PasswordEncoder passwordEncoder,
            SecurityContextRepository contextRepository) {
        this.customerRepository = customerRepository;
        this.passwordEncoder = passwordEncoder;
        this.contextRepository = contextRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @Valid @RequestBody CustomerLoginRequest request,
            HttpServletRequest servletRequest,
            HttpServletResponse servletResponse) {

        Customer customer = customerRepository
                .findByUsernameIgnoreCase(request.username().trim())
                .orElse(null);

        if (customer == null
                || !passwordEncoder.matches(
                        request.password(), customer.getPassword())) {
            SecurityContextHolder.clearContext();

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new MessageResponse(
                            "Invalid username or password."));
        }

        CustomerPrincipal principal = new CustomerPrincipal(customer);

        Authentication authentication =
                UsernamePasswordAuthenticationToken.authenticated(
                        principal,
                        null,
                        principal.getAuthorities());

        // Rotate the session ID to prevent session-fixation attacks.
        if (servletRequest.getSession(false) != null) {
            servletRequest.changeSessionId();
        } else {
            servletRequest.getSession(true);
        }

        SecurityContext context =
                SecurityContextHolder.createEmptyContext();

        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);

        contextRepository.saveContext(
                context, servletRequest, servletResponse);

        return ResponseEntity.ok(CustomerProfile.from(principal));
    }

    @GetMapping("/me")
    public ResponseEntity<?> currentCustomer(Authentication authentication) {
        if (authentication == null
                || !(authentication.getPrincipal()
                        instanceof CustomerPrincipal principal)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new MessageResponse("Customer login required."));
        }

        return ResponseEntity.ok(CustomerProfile.from(principal));
    }

    public record CustomerLoginRequest(
            @NotBlank
            @Size(max = 50)
            String username,

            @NotBlank
            String password) {
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

    public record MessageResponse(String message) {
    }
}