package com.kandypack.logistics.security;

import java.util.HashSet;
import java.util.Set;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.env.Environment;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class BootstrapAdministrator implements ApplicationRunner {
    private static final Logger logger = LoggerFactory.getLogger(BootstrapAdministrator.class);

    private final Environment environment;
    private final StaffAccountRepository accounts;
    private final StaffRoleRepository roles;
    private final PasswordEncoder passwordEncoder;

    public BootstrapAdministrator(Environment environment, StaffAccountRepository accounts,
                                  StaffRoleRepository roles, PasswordEncoder passwordEncoder) {
        this.environment = environment;
        this.accounts = accounts;
        this.roles = roles;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        StaffRole adminRole = roles.findByCode(StaffRoleCode.ADMIN.name()).orElse(null);
        if (adminRole == null) {
            logger.warn("Staff roles are not yet seeded in database; cannot initialize administrator accounts.");
            return;
        }

        // 1. Process environment variables if specified
        String envUser = environment.getProperty("BOOTSTRAP_ADMIN_USERNAME");
        String envPass = environment.getProperty("BOOTSTRAP_ADMIN_PASSWORD");
        String envEmail = environment.getProperty("BOOTSTRAP_ADMIN_EMAIL");
        String envName = environment.getProperty("BOOTSTRAP_ADMIN_NAME");

        if (envUser != null && !envUser.isBlank() && envPass != null && envPass.length() >= 8) {
            provisionAdmin(envUser, envPass,
                    envEmail != null ? envEmail : "admin@kandypack.lk",
                    envName != null ? envName : "Kandypack Administrator",
                    adminRole);
        }

        // 2. Ensure default "admin" account has a working valid BCrypt password
        provisionAdmin("admin", "Admin@12345678", "admin@kandypack.lk", "Kandypack Administrator", adminRole);

        // 3. Ensure "kandy-admin" account also exists with a working valid BCrypt password
        provisionAdmin("kandy-admin", "Admin@12345678", "kandy-admin@kandypack.lk", "Kandypack Administrator", adminRole);
    }

    private void provisionAdmin(String username, String rawPassword, String email, String name, StaffRole adminRole) {
        StaffAccount account = accounts.findByUsernameIgnoreCase(username).orElse(null);
        if (account == null) {
            account = new StaffAccount(name, username, passwordEncoder.encode(rawPassword), email);
            account.setEnabled(true);
            Set<StaffRole> roleSet = new HashSet<>();
            roleSet.add(adminRole);
            account.setRoles(roleSet);
            accounts.save(account);
            logger.info("Created default administrator account '{}'.", username);
        } else {
            // If the account exists with placeholder dummy hash from seed data (e.g. "...hash"), replace with valid hash
            String currentHash = account.getPasswordHash();
            if (currentHash == null || currentHash.contains("...hash")) {
                account.setPasswordHash(passwordEncoder.encode(rawPassword));
                account.setEnabled(true);
                if (account.getRoles() == null) {
                    account.setRoles(new HashSet<>());
                }
                account.getRoles().add(adminRole);
                accounts.save(account);
                logger.info("Updated administrator '{}' placeholder password with valid BCrypt hash.", username);
            }
        }
    }
}
