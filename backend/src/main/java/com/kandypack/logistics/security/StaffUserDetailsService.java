package com.kandypack.logistics.security;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class StaffUserDetailsService implements UserDetailsService {
    private final StaffAccountRepository accounts;

    public StaffUserDetailsService(StaffAccountRepository accounts) {
        this.accounts = accounts;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return accounts.findByUsernameIgnoreCase(username)
                .map(StaffPrincipal::new)
                .orElseThrow(() -> new UsernameNotFoundException("Invalid username or password."));
    }
}
