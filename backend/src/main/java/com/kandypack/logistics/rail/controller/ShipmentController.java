package com.kandypack.logistics.rail.controller;

import com.kandypack.logistics.rail.dto.OrderShipmentDTO;
import com.kandypack.logistics.rail.dto.ShipmentDTO;
import com.kandypack.logistics.rail.service.ShipmentService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/shipments")
@CrossOrigin
public class ShipmentController {

    private final ShipmentService shipmentService;

    public ShipmentController(ShipmentService shipmentService) {
        this.shipmentService = shipmentService;
    }

    /**
     * Order lines that still have units waiting for a train, with the customer, product,
     * remaining quantity and destination city. The Train Cargo page lists them so the
     * dispatcher can pick a line instead of typing its ID.
     */
    @GetMapping("/pending-lines")
    public List<Map<String, Object>> getPendingOrderLines() {
        return shipmentService.getPendingOrderLines();
    }

    @PostMapping("/schedule")
    public ResponseEntity<?> scheduleShipment(@Valid @RequestBody ShipmentDTO shipmentDTO) {
        shipmentService.processShipmentSchedule(shipmentDTO);
        return ResponseEntity.ok(Map.of("message", "Shipment scheduled successfully!"));
    }

    /**
     * Books every order line of an order that is still waiting for a train, starting from the
     * chosen run and date. Each line's overflow rolls over to the next run. All or nothing:
     * if one line cannot be booked, no line of the order is.
     */
    @PostMapping("/schedule-order")
    public ResponseEntity<?> scheduleOrder(@Valid @RequestBody OrderShipmentDTO orderShipmentDTO) {
        shipmentService.processOrderSchedule(orderShipmentDTO);
        return ResponseEntity.ok(Map.of("message", "Order #" + orderShipmentDTO.getOrderId() + " is booked onto trains."));
    }
}