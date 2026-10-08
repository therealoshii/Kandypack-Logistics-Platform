package com.kandypack.logistics.security;

public package com.kandypack.logistics.security;

import java.util.Collection;
import java.util.List;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

public final class StaffPrincipal implements UserDetails {
    private final Integer id;
    private final String name;
    private final String username;
    private final String email;
    private final String passwordHash;
    private final boolean enabled;
    private final List<GrantedAuthority> authorities;

    public StaffPrincipal(StaffAccount account) {
        this.id = account.getId();
        this.name = account.getName();
        this.username = account.getUsername();
        this.email = account.getEmail();
        this.passwordHash = account.getPasswordHash();
        this.enabled = account.isEnabled();
        this.authorities = account.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getCode()))
                .map(GrantedAuthority.class::cast)
                .toList();
    }

    public Integer getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public List<String> getRoleCodes() {
        return authorities.stream().map(GrantedAuthority::getAuthority)
                .map(authority -> authority.substring("ROLE_".length())).toList();
    }

    @Override public Collection<? extends GrantedAuthority> getAuthorities() { return authorities; }
    @Override public String getPassword() { return passwordHash; }
    @Override public String getUsername() { return username; }
    @Override public boolean isEnabled() { return enabled; }
    @Override public boolean isAccountNonExpired() { return true; }
    @Override public boolean isAccountNonLocked() { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
}
 {
    
}
