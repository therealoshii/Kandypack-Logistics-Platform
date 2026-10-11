
package com.kandypack.logistics.security;

import java.util.List;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.config.Customizer;
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
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

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

    @Bean(name = "staffAuthenticationManager")
    @Primary
    AuthenticationManager staffAuthenticationManager(
            StaffUserDetailsService staffUserDetailsService,
            PasswordEncoder passwordEncoder) {

        DaoAuthenticationProvider provider =
                new DaoAuthenticationProvider(staffUserDetailsService);
        provider.setPasswordEncoder(passwordEncoder);

        return new ProviderManager(provider);
    }

    @Bean(name = "customerAuthenticationManager")
    AuthenticationManager customerAuthenticationManager(
            CustomerUserDetailsService customerUserDetailsService,
            PasswordEncoder passwordEncoder) {

        DaoAuthenticationProvider provider =
                new DaoAuthenticationProvider(customerUserDetailsService);
        provider.setPasswordEncoder(passwordEncoder);

        return new ProviderManager(provider);
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        configuration.setAllowedOriginPatterns(
                List.of("http://localhost:*", "http://127.0.0.1:*"));
        configuration.setAllowedMethods(
                List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source =
                new UrlBasedCorsConfigurationSource();
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
                        .ignoringRequestMatchers(
                                "/api/auth/login",
                                "/api/auth/csrf"
                        )
                )

                .securityContext(context -> context
                        .securityContextRepository(contextRepository)
                        .requireExplicitSave(true)
                )

                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                        .sessionFixation(fixation -> fixation.changeSessionId())
                )

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

                        // Public GET endpoints
                        .requestMatchers(
                                HttpMethod.GET,
                                "/api/auth/csrf",
                                "/api/public/delivery-areas"
                        ).permitAll()

                        // Public POST endpoints
                        .requestMatchers(
                                HttpMethod.POST,
                                "/api/auth/login",
                                "/api/auth/customer/login",
                                "/api/customers"
                        ).permitAll()

                        // Customer-only authentication endpoints
                        .requestMatchers("/api/auth/customer/**")
                        .hasRole("CUSTOMER")

                        // Staff-only authentication endpoints
                        .requestMatchers(
                                "/api/auth/me",
                                "/api/auth/password",
                                "/api/auth/logout"
                        ).hasAnyRole(
                                "ADMIN",
                                "ORDER_MANAGER",
                                "RAIL_DISPATCHER",
                                "FLEET_MANAGER",
                                "ROSTER_DISPATCHER",
                                "ANALYST"
                        )

                        // Do not expose any other authentication endpoint
                        .requestMatchers("/api/auth/**").denyAll()

                        .requestMatchers("/api/admin/**")
                        .hasRole("ADMIN")

                        .requestMatchers(
                                "/api/reports/staff-hours/**",
                                "/api/reports/working-hours/**",
                                "/api/staff/roster-quota/**"
                        ).hasAnyRole(
                                "ADMIN", "ANALYST", "ROSTER_DISPATCHER"
                        )

                        .requestMatchers("/api/reports/fleet-usage/**")
                        .hasAnyRole("ADMIN", "ANALYST", "FLEET_MANAGER")

                        .requestMatchers("/api/reports/customer-order-history/**")
                        .hasAnyRole("ADMIN", "ANALYST", "ORDER_MANAGER")

                        .requestMatchers("/api/reports/**")
                        .hasAnyRole("ADMIN", "ANALYST")

                        .requestMatchers(
                                "/api/orders/**",
                                "/api/customers/**",
                                "/api/products/**"
                        ).hasAnyRole("ADMIN", "ORDER_MANAGER")

                        .requestMatchers(
                                "/api/trains/**",
                                "/api/shipments/**"
                        ).hasAnyRole("ADMIN", "RAIL_DISPATCHER")

                        // Preserve O8's GET authorization rule
                        .requestMatchers(
                                HttpMethod.GET,
                                "/api/stores/**",
                                "/api/trucks/**"
                        ).hasAnyRole(
                                "ADMIN",
                                "FLEET_MANAGER",
                                "ROSTER_DISPATCHER"
                        )

                        .requestMatchers(
                                "/api/stores/**",
                                "/api/trucks/**"
                        ).hasAnyRole("ADMIN", "FLEET_MANAGER")

                        .requestMatchers(
                                "/api/truck-trips/**",
                                "/api/deliveries/**",
                                "/api/drivers/**",
                                "/api/assistants/**"
                        ).hasAnyRole("ADMIN", "ROSTER_DISPATCHER")

                        // Other API routes require an authenticated user.
                        .requestMatchers("/api/**").authenticated()

                        .anyRequest().permitAll()
                );

        return http.build();
    }
}
