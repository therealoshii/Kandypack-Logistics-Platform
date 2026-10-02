// REST Controller for Driver management endpoints

package com.kandypack.logistics.delivery.controller;

// Internal project imports
import com.kandypack.logistics.delivery.dto.DriverDTO;
import com.kandypack.logistics.delivery.service.DriverService;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/drivers") // Base URL path for each method
@CrossOrigin
public class DriverController {

    private final DriverService driverService;

    public DriverController(DriverService driverService) {
        this.driverService = driverService;
    }

    // Get all drivers by findAll()
    @GetMapping
    public ResponseEntity<List<DriverDTO>> getAllDrivers() {
        return ResponseEntity.ok(driverService.getAllDrivers());
    }

    // Get a driver by ID
    @GetMapping("/{id}")
    public ResponseEntity<DriverDTO> getDriverById(@PathVariable Integer id) {
        return ResponseEntity.ok(driverService.getDriverById(id));
    }

    // Create a new driver
    @PostMapping
    public ResponseEntity<DriverDTO> createDriver(@Valid @RequestBody DriverDTO dto) {
        DriverDTO created = driverService.createDriver(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // Update an existing driver
    @PutMapping("/{id}")
    public ResponseEntity<DriverDTO> updateDriver(@PathVariable Integer id, @Valid @RequestBody DriverDTO dto) {
        return ResponseEntity.ok(driverService.updateDriver(id, dto));
    }

    // Delete a driver by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDriver(@PathVariable Integer id) {
        driverService.deleteDriver(id);
        return ResponseEntity.noContent().build();
    }

    // Search drivers by name
    @GetMapping("/search")
    public ResponseEntity<List<DriverDTO>> searchDriversByName(@RequestParam String name) {
        return ResponseEntity.ok(driverService.searchDriversByName(name));
    }
}
