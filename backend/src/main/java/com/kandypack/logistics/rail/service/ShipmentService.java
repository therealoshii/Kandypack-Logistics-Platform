package com.kandypack.logistics.rail.service;

import com.kandypack.logistics.rail.dto.ShipmentDTO;
import com.kandypack.logistics.rail.repository.ShipmentRepository;
import org.springframework.stereotype.Service;

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
            shipmentDTO.getShipmentDate(),
            shipmentDTO.getQuantity()
        );
    }
}