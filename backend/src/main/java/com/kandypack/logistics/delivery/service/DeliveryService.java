// Handles all business logic and CRUD operations for deliveries

package com.kandypack.logistics.delivery.service;

// Internal project imports
import com.kandypack.logistics.delivery.dto.DeliveryDTO;
import com.kandypack.logistics.delivery.entity.Delivery;
import com.kandypack.logistics.delivery.entity.TruckTrip;
import com.kandypack.logistics.delivery.repository.DeliveryRepository;
import com.kandypack.logistics.delivery.repository.TruckTripRepository;

// Exception handling imports
import com.kandypack.logistics.exception.ResourceNotFoundException;

// JPA imports
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class DeliveryService {

    private final DeliveryRepository deliveryRepository;
    private final TruckTripRepository truckTripRepository;

    @PersistenceContext
    private EntityManager entityManager;
    // The low-level interface behind Hibernate and Spring Data JPA
    // Direct interactions with stored procedures require injecting the EntityManager

    public DeliveryService(DeliveryRepository deliveryRepository, TruckTripRepository truckTripRepository) {
        this.deliveryRepository = deliveryRepository;
        this.truckTripRepository = truckTripRepository;
    }

    // Get all deliveries
    @Transactional(readOnly = true)
    public List<DeliveryDTO> getAllDeliveries() {
        return deliveryRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Get a delivery by ID
    @Transactional(readOnly = true)
    public DeliveryDTO getDeliveryById(Integer id) {
        Delivery delivery = deliveryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Delivery not found with ID: " + id));
        return toDTO(delivery);
    }

    // Create a new delivery
    public DeliveryDTO createDelivery(DeliveryDTO dto) {
        TruckTrip trip = truckTripRepository.findById(dto.getTripId())
                .orElseThrow(() -> new ResourceNotFoundException("TruckTrip not found with ID: " + dto.getTripId()));

        Delivery delivery = new Delivery();
        delivery.setOrderId(dto.getOrderId());
        delivery.setTruckTrip(trip);
        delivery.setDeliveryDate(dto.getDeliveryDate());
        delivery.setStatus(dto.getStatus() != null ? dto.getStatus() : "Scheduled");

        Delivery saved = deliveryRepository.save(delivery);
        return toDTO(saved);
    }

    /**
     * Update delivery status using the sp_update_delivery_status stored procedure.
     * This ensures the Order status is also cascaded atomically (ACID).
     * Valid transitions: Scheduled -> In Transit -> Delivered
     */
    public DeliveryDTO updateDeliveryStatus(Integer id, String newStatus) {
        Delivery delivery = deliveryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Delivery not found with ID: " + id));

        // Call stored procedure for ACID-compliant status update
        entityManager.createNativeQuery("CALL sp_update_delivery_status(:deliveryId, :newStatus)")
                .setParameter("deliveryId", id)
                .setParameter("newStatus", newStatus)
                .executeUpdate();

        // Refresh entity to reflect the stored procedure's changes
        // re-fetch the fresh row from MySQL
        entityManager.refresh(delivery);
        return toDTO(delivery);
    }

    // Get delivery by order ID
    @Transactional(readOnly = true)
    public DeliveryDTO getDeliveryByOrderId(Integer orderId) {
        Delivery delivery = deliveryRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Delivery not found for Order ID: " + orderId));
        return toDTO(delivery);
    }

    // Get deliveries by status
    @Transactional(readOnly = true)
    public List<DeliveryDTO> getDeliveriesByStatus(String status) {
        return deliveryRepository.findByStatus(status).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Get deliveries by date range
    @Transactional(readOnly = true)
    public List<DeliveryDTO> getDeliveriesByDateRange(LocalDate start, LocalDate end) {
        return deliveryRepository.findByDeliveryDateBetween(start, end).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // (Entity -> DTO): Unpacks database records into safe data containers before returning them over the network
    private DeliveryDTO toDTO(Delivery delivery) {
        return new DeliveryDTO(
                delivery.getDeliveryId(),
                delivery.getOrderId(),
                delivery.getTruckTrip().getTripId(),
                delivery.getDeliveryDate(),
                delivery.getStatus()
        );
    }
}
