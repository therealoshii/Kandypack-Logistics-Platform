package com.kandypack.logistics.rail.service;

import com.kandypack.logistics.rail.dto.ShipmentDTO;
import com.kandypack.logistics.rail.repository.ShipmentRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ShipmentServiceTest {

    @Mock
    private ShipmentRepository shipmentRepository;

    @InjectMocks
    private ShipmentService shipmentService;

    @Test
    void testProcessShipmentSchedule() {
        ShipmentDTO dto = new ShipmentDTO(101, 202, "2026-10-15", 50);

        shipmentService.processShipmentSchedule(dto);

        verify(shipmentRepository).scheduleShipment(101, 202, "2026-10-15", 50);
    }
}