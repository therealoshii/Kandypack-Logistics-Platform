package com.kandypack.logistics.rail.service;

import com.kandypack.logistics.rail.dto.OrderShipmentDTO;
import com.kandypack.logistics.rail.dto.ShipmentDTO;
import com.kandypack.logistics.rail.repository.ShipmentRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class ShipmentService {

    private final ShipmentRepository shipmentRepository;

    public ShipmentService(ShipmentRepository shipmentRepository) {
        this.shipmentRepository = shipmentRepository;
    }

    // Books one order line (sp_schedule_shipment)
    @Transactional
    public void processShipmentSchedule(ShipmentDTO shipmentDTO) {
        runAsCurrentUser(() -> shipmentRepository.scheduleShipment(
            shipmentDTO.getOrderDetailId(),
            shipmentDTO.getScheduleId(),
            shipmentDTO.getShipmentDate()
        ));
    }

    // Books every line of an order that is still waiting for a train (sp_schedule_order)
    @Transactional
    public void processOrderSchedule(OrderShipmentDTO orderShipmentDTO) {
        runAsCurrentUser(() -> shipmentRepository.scheduleOrder(
            orderShipmentDTO.getOrderId(),
            orderShipmentDTO.getScheduleId(),
            orderShipmentDTO.getShipmentDate()
        ));
    }

    public List<Map<String, Object>> getPendingOrderLines() {
        return shipmentRepository.findPendingOrderLines();
    }

    // Runs a booking with the logged-in staff member recorded as the person who changed the order status
    private void runAsCurrentUser(Runnable booking) {
        shipmentRepository.setAuditUser(currentUsername());
        try {
            booking.run();
        } finally {
            shipmentRepository.clearAuditUser();
        }
    }

    // Username of the logged-in staff member, or SYSTEM when there is no login (e.g. tests)
    private String currentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null ? authentication.getName() : "SYSTEM";
    }
}