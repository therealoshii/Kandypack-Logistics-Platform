package com.kandypack.logistics.order.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.kandypack.logistics.order.entity.Order;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    List<Order> findByCustomerID(Integer customerID);
}