package com.kandypack.logistics.rail.controller;

import com.kandypack.logistics.rail.dto.ShipmentDTO;
import com.kandypack.logistics.rail.service.ShipmentService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/shipments")
@CrossOrigin(origins = "*")
public class ShipmentController {

    private final ShipmentService shipmentService;

    public ShipmentController(ShipmentService shipmentService) {
        this.shipmentService = shipmentService;
    }

    @PostMapping("/schedule")
    public ResponseEntity<?> scheduleShipment(@Valid @RequestBody ShipmentDTO shipmentDTO) {
        shipmentService.processShipmentSchedule(shipmentDTO);
        return ResponseEntity.ok(Map.of("message", "Shipment scheduled successfully!"));
    }
}