// REST Controller for Delivery management endpoints

package com.kandypack.logistics.delivery.controller;

// Internal project imports
import com.kandypack.logistics.delivery.dto.DeliveryAssignmentDTO;
import com.kandypack.logistics.delivery.dto.DeliveryDTO;
import com.kandypack.logistics.delivery.service.DeliveryService;

import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;


// REST Controller for Delivery management endpoints.
// Status updates call sp_update_delivery_status for ACID compliance.
@RestController
@RequestMapping("/api/deliveries") // Base path for all delivery-related endpoints
@CrossOrigin
public class DeliveryController {

    private final DeliveryService deliveryService;

    public DeliveryController(DeliveryService deliveryService) {
        this.deliveryService = deliveryService;
    }

    // Get all deliveries by findAll()
    @GetMapping
    public ResponseEntity<List<DeliveryDTO>> getAllDeliveries() {
        return ResponseEntity.ok(deliveryService.getAllDeliveries());
    }

    // Get a delivery by ID
    @GetMapping("/{id}")
    public ResponseEntity<DeliveryDTO> getDeliveryById(@PathVariable Integer id) {
        return ResponseEntity.ok(deliveryService.getDeliveryById(id));
    }

    // Orders that have no delivery yet, with how much is still waiting for a train
    // eg: GET /api/deliveries/unassigned-orders
    @GetMapping("/unassigned-orders")
    public ResponseEntity<List<Map<String, Object>>> getOrdersWithoutDelivery() {
        return ResponseEntity.ok(deliveryService.getOrdersWithoutDelivery());
    }

    // Assign a whole order to a truck trip. Body: {"orderId": 58, "tripId": 61}
    // The delivery date is the trip's date; the database rules decide whether the pair is allowed
    @PostMapping("/assign")
    public ResponseEntity<DeliveryDTO> assignDelivery(@Valid @RequestBody DeliveryAssignmentDTO dto) {
        DeliveryDTO created = deliveryService.assignDelivery(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // Create a new delivery
    @PostMapping
    public ResponseEntity<DeliveryDTO> createDelivery(@Valid @RequestBody DeliveryDTO dto) {
        DeliveryDTO created = deliveryService.createDelivery(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // Update delivery status via stored procedure
    // Request body: {"status": "In Transit"} or {"status": "Delivered"}
    // Supports both PUT and PATCH /api/deliveries/{id}/status per assignment specs
     @RequestMapping(value = "/{id}/status", method = {RequestMethod.PUT, RequestMethod.PATCH})
    public ResponseEntity<DeliveryDTO> updateDeliveryStatus(
            @PathVariable Integer id,
            @RequestBody Map<String, String> body) {
        String newStatus = body.get("status");
        return ResponseEntity.ok(deliveryService.updateDeliveryStatus(id, newStatus));
    }

    // Delete a delivery by ID
    @GetMapping("/by-order/{orderId}")
    public ResponseEntity<DeliveryDTO> getDeliveryByOrderId(@PathVariable Integer orderId) {
        return ResponseEntity.ok(deliveryService.getDeliveryByOrderId(orderId));
    }

    // Get deliveries by status
    @GetMapping("/by-status")
    public ResponseEntity<List<DeliveryDTO>> getDeliveriesByStatus(@RequestParam String status) {
        return ResponseEntity.ok(deliveryService.getDeliveriesByStatus(status));
    }

    // Get deliveries by date range
    @GetMapping("/by-date-range")
    public ResponseEntity<List<DeliveryDTO>> getDeliveriesByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        return ResponseEntity.ok(deliveryService.getDeliveriesByDateRange(start, end));
    }
}
