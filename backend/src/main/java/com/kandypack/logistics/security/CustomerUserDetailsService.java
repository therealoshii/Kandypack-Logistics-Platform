
package com.kandypack.logistics.security;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.kandypack.logistics.order.entity.Customer;
import com.kandypack.logistics.order.repository.CustomerRepository;

@Service
public class CustomerUserDetailsService implements UserDetailsService {

    private final CustomerRepository customerRepository;

    public CustomerUserDetailsService(
            CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username)
            throws UsernameNotFoundException {

        Customer customer = customerRepository
                .findByUsernameIgnoreCase(username)
                .orElseThrow(() ->
                    new UsernameNotFoundException(
                        "Invalid username or password."
                    )
                );

        return new CustomerPrincipal(customer);
    }
}
