package com.kandypack.logistics.delivery.repository;

import com.kandypack.logistics.delivery.entity.TruckTrip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
// Spring Data JPA repository for TruckTrip entity. <entity, data_type of PK>
public interface TruckTripRepository extends JpaRepository<TruckTrip, Integer> {

    List<TruckTrip> findByTripDate(LocalDate tripDate);
    // Generates an SQL =>
    // SELECT * FROM TruckTrip WHERE TripDate = ?;

    List<TruckTrip> findByDriver_DriverId(Integer driverId);
    // Generates an SQL =>
    // SELECT * FROM TruckTrip WHERE DriverId = ?;

    List<TruckTrip> findByAssistant_AssistantId(Integer assistantId);
    // Generates an SQL =>
    // SELECT * FROM TruckTrip WHERE AssistantId = ?;

    List<TruckTrip> findByTripDateBetween(LocalDate startDate, LocalDate endDate);
    // Generates an SQL =>
    // SELECT * FROM TruckTrip WHERE TripDate BETWEEN ? AND ?;
}
