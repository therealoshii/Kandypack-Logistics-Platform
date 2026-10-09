package com.kandypack.logistics.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@Validated
public class AuthController {
    private final AuthenticationManager authenticationManager;
    private final SecurityContextRepository contextRepository;
    private final StaffAccountRepository accounts;
    private final PasswordEncoder passwordEncoder;

    public AuthController(AuthenticationManager authenticationManager, SecurityContextRepository contextRepository,
                          StaffAccountRepository accounts, PasswordEncoder passwordEncoder) {
        this.authenticationManager = authenticationManager;
        this.contextRepository = contextRepository;
        this.accounts = accounts;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/csrf")
    public CsrfResponse csrf(CsrfToken csrfToken) {
        return new CsrfResponse(csrfToken.getToken());
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request,
                                   HttpServletRequest servletRequest,
                                   HttpServletResponse servletResponse) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    UsernamePasswordAuthenticationToken.unauthenticated(request.username(), request.password()));
            SecurityContext context = SecurityContextHolder.createEmptyContext();
            context.setAuthentication(authentication);
            SecurityContextHolder.setContext(context);
            contextRepository.saveContext(context, servletRequest, servletResponse);
            return ResponseEntity.ok(StaffProfile.from((StaffPrincipal) authentication.getPrincipal()));
        } catch (AuthenticationException exception) {
            SecurityContextHolder.clearContext();
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse("Invalid username or password."));
        }
    }

    @GetMapping("/me")
    public StaffProfile currentUser(Authentication authentication) {
        return StaffProfile.from((StaffPrincipal) authentication.getPrincipal());
    }

    @PostMapping("/password")
    public ResponseEntity<ErrorResponse> changePassword(@Valid @RequestBody PasswordChangeRequest request,
                                                        Authentication authentication) {
        StaffPrincipal principal = (StaffPrincipal) authentication.getPrincipal();
        if (!passwordEncoder.matches(request.currentPassword(), principal.getPassword())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("Current password is incorrect."));
        }
        StaffAccount account = accounts.findById(principal.getId())
                .orElseThrow(() -> new BadCredentialsException("Staff account no longer exists."));
        account.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        accounts.save(account);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(HttpServletRequest request, HttpServletResponse response,
                                       Authentication authentication) {
        new SecurityContextLogoutHandler().logout(request, response, authentication);
        return ResponseEntity.noContent().build();
    }

    public record LoginRequest(@NotBlank String username, @NotBlank String password) {}
    public record PasswordChangeRequest(@NotBlank String currentPassword,
                                        @NotBlank @jakarta.validation.constraints.Size(min = 12, max = 72) String newPassword) {}
    public record CsrfResponse(String token) {}
    public record ErrorResponse(String message) {}
    public record StaffProfile(Integer id, String name, String username, String email, List<String> roles) {
        static StaffProfile from(StaffPrincipal principal) {
            return new StaffProfile(principal.getId(), principal.getName(), principal.getUsername(),
                    principal.getEmail(), principal.getRoleCodes());
        }
    }
}
