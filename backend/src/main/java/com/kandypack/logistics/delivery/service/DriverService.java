// Handles all business logic and CRUD operations for drivers

package com.kandypack.logistics.delivery.service;

// Internal project imports
import com.kandypack.logistics.delivery.dto.DriverDTO;
import com.kandypack.logistics.delivery.entity.Driver;
import com.kandypack.logistics.delivery.repository.DriverRepository;

// Exception handling imports
import com.kandypack.logistics.exception.ResourceNotFoundException;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional // Just like how SQL transactions work
public class DriverService {

    private final DriverRepository driverRepository;

    public DriverService(DriverRepository driverRepository) {
        this.driverRepository = driverRepository;
    }

    // Get all drivers
    @Transactional(readOnly = true)
    public List<DriverDTO> getAllDrivers() {
        return driverRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Get a driver by ID
    @Transactional(readOnly = true)
    public DriverDTO getDriverById(Integer id) {
        Driver driver = driverRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Driver not found with ID: " + id));
        return toDTO(driver);
    }

    // Create a new driver
    public DriverDTO createDriver(DriverDTO dto) {
        Driver driver = toEntity(dto);
        Driver saved = driverRepository.save(driver);
        return toDTO(saved);
    }

    // Update an existing driver
    public DriverDTO updateDriver(Integer id, DriverDTO dto) {
        Driver driver = driverRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Driver not found with ID: " + id));
        driver.setName(dto.getName());
        driver.setLicenseNumber(dto.getLicenceNumber());
        driver.setContactNumber(dto.getContactNumber());
        Driver updated = driverRepository.save(driver);
        return toDTO(updated);
    }

    // Delete a driver
    public void deleteDriver(Integer id) {
        if (!driverRepository.existsById(id)) {
            throw new ResourceNotFoundException("Driver not found with ID: " + id);
        }
        driverRepository.deleteById(id);
    }

    // Search drivers by name
    @Transactional(readOnly = true)
    public List<DriverDTO> searchDriversByName(String name) {
        return driverRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // (Entity -> DTO): Unpacks database records into safe data containers before returning them over the network
    private DriverDTO toDTO(Driver driver) {
        return new DriverDTO(
                driver.getDriverId(),
                driver.getName(),
                driver.getLicenseNumber(),
                driver.getContactNumber()
        );
    }

    // (DTO -> Entity): Packs data containers into database records before saving them to the database
    private Driver toEntity(DriverDTO dto) {
        Driver driver = new Driver();
        driver.setName(dto.getName());
        driver.setLicenseNumber(dto.getLicenceNumber());
        driver.setContactNumber(dto.getContactNumber());
        return driver;
    }
}
