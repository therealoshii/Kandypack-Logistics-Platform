package com.kandypack.logistics.delivery.repository;

import com.kandypack.logistics.delivery.entity.Delivery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
// Spring Data JPA repository for Delivery entity. <entity, data_type of PK>
public interface DeliveryRepository extends JpaRepository<Delivery, Integer> {

    Optional<Delivery> findByOrderId(Integer orderId);
    // Generates an SQL =>
    // SELECT * FROM Delivery WHERE OrderId = ?;

    List<Delivery> findByStatus(String status);
    // Generates an SQL =>
    // SELECT * FROM Delivery WHERE Status = ?;

    List<Delivery> findByDeliveryDateBetween(LocalDate startDate, LocalDate endDate);
    // Generates an SQL =>
    // SELECT * FROM Delivery WHERE DeliveryDate BETWEEN ? AND ?;
}
