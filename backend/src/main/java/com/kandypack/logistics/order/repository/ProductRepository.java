package com.kandypack.logistics.order.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.kandypack.logistics.order.entity.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
}