package com.kandypack.logistics.order.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.kandypack.logistics.order.entity.Customer;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
}