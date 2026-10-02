package com.kandypack.logistics.fleet.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.kandypack.logistics.fleet.entity.Truck;

public interface TruckRepository extends JpaRepository<Truck, Integer> {
}