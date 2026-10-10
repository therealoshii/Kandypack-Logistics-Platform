
package com.kandypack.logistics.security;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;

import jakarta.servlet.http.HttpServletResponse;

@Configuration
public class SecurityConfig {

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    SecurityContextRepository securityContextRepository() {
        return new HttpSessionSecurityContextRepository();
    }

    @Bean
    AuthenticationManager authenticationManager(
            AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager();
    }

    @Bean
    org.springframework.web.cors.CorsConfigurationSource
    corsConfigurationSource() {

        org.springframework.web.cors.CorsConfiguration configuration =
                new org.springframework.web.cors.CorsConfiguration();

        configuration.setAllowedOriginPatterns(
                List.of("http://localhost:*", "http://127.0.0.1:*"));

        configuration.setAllowedMethods(
                List.of("GET", "POST", "PUT", "PATCH",
                        "DELETE", "OPTIONS"));

        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);

        org.springframework.web.cors.UrlBasedCorsConfigurationSource source =
                new org.springframework.web.cors.UrlBasedCorsConfigurationSource();

        source.registerCorsConfiguration("/**", configuration);

        return source;
    }

    @Bean
    SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            SecurityContextRepository contextRepository) throws Exception {

        CookieCsrfTokenRepository csrfRepository =
                CookieCsrfTokenRepository.withHttpOnlyFalse();

        CsrfTokenRequestAttributeHandler csrfHandler =
                new CsrfTokenRequestAttributeHandler();

        csrfHandler.setCsrfRequestAttributeName(null);

        http
            .cors(Customizer.withDefaults())

            .csrf(csrf -> csrf
                .csrfTokenRepository(csrfRepository)
                .csrfTokenRequestHandler(csrfHandler)
                // The existing staff login client does not send a CSRF token.
                // Customer login continues to use the CSRF token endpoint.
                .ignoringRequestMatchers("/api/auth/login")
            )

            .securityContext(context ->
                context.securityContextRepository(contextRepository))

            .sessionManagement(session ->
                session.sessionCreationPolicy(
                        SessionCreationPolicy.IF_REQUIRED))

            .httpBasic(AbstractHttpConfigurer::disable)
            .formLogin(AbstractHttpConfigurer::disable)
            .logout(AbstractHttpConfigurer::disable)
            .requestCache(AbstractHttpConfigurer::disable)

            .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint((request, response, exception) ->
                    response.sendError(
                            HttpServletResponse.SC_UNAUTHORIZED))
                .accessDeniedHandler((request, response, exception) ->
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN))
            )

            .authorizeHttpRequests(authorize -> authorize

                // Public CSRF token and delivery-area lookup.
                .requestMatchers(HttpMethod.GET,
                        "/api/auth/csrf",
                        "/api/public/delivery-areas")
                    .permitAll()

                // Public sign-in and customer registration.
                .requestMatchers(HttpMethod.POST,
                        "/api/auth/login",
                        "/api/auth/customer/login",
                        "/api/customers")
                    .permitAll()

                // Customer-only profile and future customer auth routes.
                .requestMatchers("/api/auth/customer/**")
                    .hasRole("CUSTOMER")

                // Staff profile and password-change routes.
                .requestMatchers(
                        "/api/auth/me",
                        "/api/auth/password")
                    .hasAnyRole(
                        "ADMIN",
                        "ANALYST",
                        "ORDER_MANAGER",
                        "RAIL_DISPATCHER",
                        "FLEET_MANAGER",
                        "ROSTER_DISPATCHER")

                // Shared logout endpoint: either authenticated role can log out.
                .requestMatchers("/api/auth/logout")
                    .authenticated()

                // Do not allow other authentication routes by default.
                .requestMatchers("/api/auth/**")
                    .denyAll()

                // Administrator management.
                .requestMatchers("/api/admin/**")
                    .hasRole("ADMIN")

                // Staff scheduling and working-hours reports.
                .requestMatchers(
                        "/api/reports/staff-hours/**",
                        "/api/reports/working-hours/**",
                        "/api/staff/roster-quota/**")
                    .hasAnyRole(
                        "ADMIN", "ANALYST", "ROSTER_DISPATCHER")

                // Fleet reports.
                .requestMatchers("/api/reports/fleet-usage/**")
                    .hasAnyRole(
                        "ADMIN", "ANALYST", "FLEET_MANAGER")

                // Customer order history report for authorized staff.
                .requestMatchers(
                        "/api/reports/customer-order-history/**")
                    .hasAnyRole(
                        "ADMIN", "ANALYST", "ORDER_MANAGER")

                .requestMatchers("/api/reports/**")
                    .hasAnyRole("ADMIN", "ANALYST")

                // Staff order, customer and product management.
                // The public POST /api/customers rule above takes precedence.
                .requestMatchers(
                        "/api/orders/**",
                        "/api/customers/**",
                        "/api/products/**")
                    .hasAnyRole("ADMIN", "ORDER_MANAGER")

                // Rail operations.
                .requestMatchers(
                        "/api/trains/**",
                        "/api/shipments/**")
                    .hasAnyRole("ADMIN", "RAIL_DISPATCHER")

                // Fleet operations.
                .requestMatchers(
                        "/api/stores/**",
                        "/api/trucks/**")
                    .hasAnyRole("ADMIN", "FLEET_MANAGER")

                // Delivery and roster operations.
                .requestMatchers(
                        "/api/truck-trips/**",
                        "/api/deliveries/**",
                        "/api/drivers/**",
                        "/api/assistants/**")
                    .hasAnyRole("ADMIN", "ROSTER_DISPATCHER")

                // Any other API must at least be authenticated.
                .requestMatchers("/api/**")
                    .authenticated()

                .anyRequest().permitAll()
            );

        return http.build();
    }
}
