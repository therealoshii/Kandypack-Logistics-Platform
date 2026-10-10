package com.kandypack.logistics.order.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.kandypack.logistics.order.entity.Customer;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {
    Optional<Customer> findByUsernameIgnoreCase(String username);
    boolean existsByUsernameIgnoreCase(String username);
    boolean existsByEmailIgnoreCase(String email);
}