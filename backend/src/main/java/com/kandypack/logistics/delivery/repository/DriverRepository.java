package com.kandypack.logistics.delivery.repository;

import com.kandypack.logistics.delivery.entity.Driver;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
// Spring Data JPA repository for Driver entity. <entity, data_type of PK>
public interface DriverRepository extends JpaRepository<Driver, Integer> {

    Optional<Driver> findByLicenseNumber(String licenseNumber);
    // Generates an SQL =>
    // SELECT * FROM Driver WHERE LicenseNumber = ?;

    List<Driver> findByNameContainingIgnoreCase(String name);
    // Generates an SQL =>
    // SELECT * FROM Driver WHERE UPPER(Name) LIKE UPPER(CONCAT('%', ?, '%'));
}
