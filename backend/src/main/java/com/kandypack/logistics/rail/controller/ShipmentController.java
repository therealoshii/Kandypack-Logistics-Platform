package com.kandypack.logistics.rail.controller;

import com.kandypack.logistics.rail.dto.ShipmentDTO;
import com.kandypack.logistics.rail.service.ShipmentService;
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
    public ResponseEntity<?> scheduleShipment(@RequestBody ShipmentDTO shipmentDTO) {
        try {
            shipmentService.processShipmentSchedule(shipmentDTO);
            return ResponseEntity.ok(Map.of("message", "Shipment scheduled successfully!"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}