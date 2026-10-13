package com.kandypack.logistics.rail.service;

import com.kandypack.logistics.rail.dto.ShipmentDTO;
import com.kandypack.logistics.rail.repository.ShipmentRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ShipmentService {

    private final ShipmentRepository shipmentRepository;

    public ShipmentService(ShipmentRepository shipmentRepository) {
        this.shipmentRepository = shipmentRepository;
    }

    public void processShipmentSchedule(ShipmentDTO shipmentDTO) {
        shipmentRepository.scheduleShipment(
            shipmentDTO.getOrderDetailId(),
            shipmentDTO.getScheduleId(),
            shipmentDTO.getShipmentDate()
            
        );
    }

    public List<Map<String, Object>> getPendingOrderLines() {
        return shipmentRepository.findPendingOrderLines();
    }
}