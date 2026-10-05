package com.kandypack.logistics.order.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.kandypack.logistics.order.entity.Order;

@Repository
public interface OrderRepository extends JpaRepository<Order, Integer> {
}