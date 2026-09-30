package com.kandypack.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/shipments")
@CrossOrigin(origins = "*")
public class ShipmentController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @PostMapping("/schedule")
    public ResponseEntity<?> scheduleShipment(@RequestBody Map<String, Object> request) {
        try {
            Integer orderDetailId = (Integer) request.get("orderDetailId");
            Integer scheduleId = (Integer) request.get("scheduleId");
            String shipmentDate = (String) request.get("shipmentDate");
            Integer quantity = (Integer) request.get("quantity");

            String sql = "CALL sp_schedule_shipment(?, ?, ?, ?)";
            jdbcTemplate.update(sql, orderDetailId, scheduleId, shipmentDate, quantity);

            return ResponseEntity.ok(Map.of("message", "Shipment scheduled successfully!"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}