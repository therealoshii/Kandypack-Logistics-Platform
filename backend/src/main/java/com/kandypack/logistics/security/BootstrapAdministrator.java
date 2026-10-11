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

        // The administrator password is never stored in the source code. It is read from the
        // environment (BOOTSTRAP_ADMIN_PASSWORD), which docker-compose.yml takes from the
        // git-ignored .env file. BOOTSTRAP_ADMIN_USERNAME defaults to "admin", the account the
        // seed creates with a placeholder hash that cannot be used to log in.
        String username = environment.getProperty("BOOTSTRAP_ADMIN_USERNAME", "admin");
        String password = environment.getProperty("BOOTSTRAP_ADMIN_PASSWORD");
        String email = environment.getProperty("BOOTSTRAP_ADMIN_EMAIL", "admin@kandypack.lk");
        String name = environment.getProperty("BOOTSTRAP_ADMIN_NAME", "Kandypack Administrator");

        if (username.isBlank() || password == null || password.length() < 12 || password.length() > 72) {
            logger.warn("BOOTSTRAP_ADMIN_PASSWORD is not set, or is not 12 to 72 characters long. "
                    + "No administrator account was provisioned; set it in the environment and restart.");
            return;
        }

        provisionAdmin(username.trim(), password, email, name, adminRole);
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
            logger.info("Created administrator account '{}'.", username);
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
