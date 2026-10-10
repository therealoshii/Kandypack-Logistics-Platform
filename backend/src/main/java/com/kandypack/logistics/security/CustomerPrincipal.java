
package com.kandypack.logistics.security;

import java.util.Collection;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import com.kandypack.logistics.order.entity.Customer;

public final class CustomerPrincipal implements UserDetails {

    private final Integer id;
    private final String fullName;
    private final String username;
    private final String email;
    private final String passwordHash;

    public CustomerPrincipal(Customer customer) {
        this.id = customer.getCustomerID();
        this.fullName = customer.getFullName();
        this.username = customer.getUsername();
        this.email = customer.getEmail();
        this.passwordHash = customer.getPassword();
    }

    public Integer getId() {
        return id;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public String getPassword() {
        return passwordHash;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_CUSTOMER"));
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }
}
