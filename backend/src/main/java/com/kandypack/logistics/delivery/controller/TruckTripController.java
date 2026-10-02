// REST Controller for TruckTrip management endpoints

package com.kandypack.logistics.delivery.controller;

// Internal project imports
import com.kandypack.logistics.delivery.dto.TruckTripDTO;
import com.kandypack.logistics.delivery.service.TruckTripService;

import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;


// REST Controller for TruckTrip management endpoints.
// POST/PUT operations trigger MySQL trg_before_insert_trucktrip
// Roster and Schedule conflict validations.
@RestController
@RequestMapping("/api/truck-trips") // Base URL path for each method
@CrossOrigin
public class TruckTripController {

    private final TruckTripService truckTripService;

    public TruckTripController(TruckTripService truckTripService) {
        this.truckTripService = truckTripService;
    }

    // Get all truck trips
    @GetMapping
    public ResponseEntity<List<TruckTripDTO>> getAllTrips() {
        return ResponseEntity.ok(truckTripService.getAllTrips());
    }

    // Get a truck trip by ID
    @GetMapping("/{id}")
    public ResponseEntity<TruckTripDTO> getTripById(@PathVariable Integer id) {
        return ResponseEntity.ok(truckTripService.getTripById(id));
    }

    // Create a new truck trip
    @PostMapping(path = {"", "/assign"})
    public ResponseEntity<TruckTripDTO> createTrip(@Valid @RequestBody TruckTripDTO dto) {
        TruckTripDTO created = truckTripService.createTrip(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // Update an existing truck trip
    @PutMapping("/{id}")
    public ResponseEntity<TruckTripDTO> updateTrip(@PathVariable Integer id, @Valid @RequestBody TruckTripDTO dto) {
        return ResponseEntity.ok(truckTripService.updateTrip(id, dto));
    }

    // Delete a truck trip by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTrip(@PathVariable Integer id) {
        truckTripService.deleteTrip(id);
        return ResponseEntity.noContent().build();
    }

    // Search truck trips by date, driver, or date range
    @GetMapping("/by-date")
    public ResponseEntity<List<TruckTripDTO>> getTripsByDate(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(truckTripService.getTripsByDate(date));
    }

    // Get truck trips by driver ID
    @GetMapping("/by-driver/{driverId}")
    public ResponseEntity<List<TruckTripDTO>> getTripsByDriver(@PathVariable Integer driverId) {
        return ResponseEntity.ok(truckTripService.getTripsByDriver(driverId));
    }

    // Get truck trips by date range
    @GetMapping("/by-date-range")
    public ResponseEntity<List<TruckTripDTO>> getTripsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        return ResponseEntity.ok(truckTripService.getTripsByDateRange(start, end));
    }
}
