package com.kandypack.logistics.security;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /*
     * Keep staff authentication separate from customer authentication.
     * AuthController should inject this bean using:
     * @Qualifier("staffAuthenticationManager")
     */
    @Bean
    public AuthenticationManager staffAuthenticationManager(
            StaffUserDetailsService staff,
            PasswordEncoder encoder) {

        DaoAuthenticationProvider provider =
                new DaoAuthenticationProvider(staff);

        provider.setPasswordEncoder(encoder);

        return new ProviderManager(provider);
    }

    /*
     * CustomerUserDetailsService must load customers by username
     * and return a CustomerPrincipal with ROLE_CUSTOMER.
     */
    @Bean
    public AuthenticationManager customerAuthenticationManager(
            CustomerUserDetailsService customers,
            PasswordEncoder encoder) {

        DaoAuthenticationProvider provider =
                new DaoAuthenticationProvider(customers);

        provider.setPasswordEncoder(encoder);

        return new ProviderManager(provider);
    }

    @Bean
    public SecurityContextRepository securityContextRepository() {
        return new HttpSessionSecurityContextRepository();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            SecurityContextRepository securityContextRepository)
            throws Exception {

        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))

            .csrf(csrf -> csrf
                .csrfTokenRepository(
                    CookieCsrfTokenRepository.withHttpOnlyFalse()
                )
                .csrfTokenRequestHandler(
                    new CsrfTokenRequestAttributeHandler()
                )
                .ignoringRequestMatchers(
                    "/api/auth/login"
                )
            )

            .securityContext(context -> context
                .securityContextRepository(securityContextRepository)
                .requireExplicitSave(true)
            )

            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                .sessionFixation(fixation -> fixation.changeSessionId())
            )

            .authorizeHttpRequests(auth -> auth

                // Public endpoints
                .requestMatchers(
                    HttpMethod.GET,
                    "/api/auth/csrf",
                    "/api/public/delivery-areas"
                ).permitAll()

                .requestMatchers(
                    HttpMethod.POST,
                    "/api/auth/login",
                    "/api/auth/customer/login",
                    "/api/customers"
                ).permitAll()

                // Customer-only authentication/profile endpoints
                .requestMatchers("/api/auth/customer/**")
                    .hasRole("CUSTOMER")

                // Staff authentication endpoints
                .requestMatchers("/api/auth/me", "/api/auth/password")
                    .hasAnyRole(
                        "ADMIN",
                        "ORDER_MANAGER",
                        "RAIL_DISPATCHER",
                        "FLEET_MANAGER",
                        "ROSTER_DISPATCHER",
                        "ANALYST"
                    )

                .requestMatchers("/api/auth/logout").authenticated()

                // No other authentication endpoints are public
                .requestMatchers("/api/auth/**").denyAll()

                // Admin-only APIs
                .requestMatchers("/api/admin/**")
                    .hasRole("ADMIN")

                // Staff-hours and roster reports
                .requestMatchers(
                    "/api/reports/staff-hours/**",
                    "/api/reports/working-hours/**",
                    "/api/staff/roster-quota/**"
                ).hasAnyRole(
                    "ADMIN",
                    "ANALYST",
                    "ROSTER_DISPATCHER"
                )

                // Fleet reports
                .requestMatchers("/api/reports/fleet-usage/**")
                    .hasAnyRole("ADMIN", "ANALYST", "FLEET_MANAGER")

                // Customer order history reports
                .requestMatchers("/api/reports/customer-order-history/**")
                    .hasAnyRole("ADMIN", "ANALYST", "ORDER_MANAGER")

                // General reports
                .requestMatchers("/api/reports/**")
                    .hasAnyRole("ADMIN", "ANALYST")

                // Orders, customers and products
                .requestMatchers(
                    "/api/orders/**",
                    "/api/customers/**",
                    "/api/products/**"
                ).hasAnyRole("ADMIN", "ORDER_MANAGER")

                // Allow customer registration before the staff-only rule
                .requestMatchers(
                    HttpMethod.POST,
                    "/api/customers"
                ).permitAll()

                // Rail operations
                .requestMatchers(
                    "/api/trains/**",
                    "/api/shipments/**"
                ).hasAnyRole("ADMIN", "RAIL_DISPATCHER")

                // Fleet operations
                .requestMatchers(
                    "/api/stores/**",
                    "/api/trucks/**"
                ).hasAnyRole("ADMIN", "FLEET_MANAGER")

                // Delivery and roster operations
                .requestMatchers(
                    "/api/truck-trips/**",
                    "/api/deliveries/**",
                    "/api/drivers/**",
                    "/api/assistants/**"
                ).hasAnyRole(
                    "ADMIN",
                    "ROSTER_DISPATCHER"
                )

                // Every other API is staff-only
                .requestMatchers("/api/**").hasAnyRole(
                    "ADMIN",
                    "ORDER_MANAGER",
                    "RAIL_DISPATCHER",
                    "FLEET_MANAGER",
                    "ROSTER_DISPATCHER",
                    "ANALYST"
                )

                .anyRequest().permitAll()
            );

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        configuration.setAllowedOriginPatterns(
            List.of(
                "http://localhost:*",
                "http://127.0.0.1:*"
            )
        );

        configuration.setAllowedMethods(
            List.of(
                "GET",
                "POST",
                "PUT",
                "PATCH",
                "DELETE",
                "OPTIONS"
            )
        );

        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source =
                new UrlBasedCorsConfigurationSource();

        source.registerCorsConfiguration("/**", configuration);

        return source;
    }
}