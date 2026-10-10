// Handles all business logic and CRUD operations for truck trips

package com.kandypack.logistics.delivery.service;

// Internal project imports
import com.kandypack.logistics.delivery.dto.TruckTripDTO;
import com.kandypack.logistics.delivery.entity.Assistant;
import com.kandypack.logistics.delivery.entity.Driver;
import com.kandypack.logistics.delivery.entity.TruckTrip;
import com.kandypack.logistics.delivery.repository.AssistantRepository;
import com.kandypack.logistics.delivery.repository.DriverRepository;
import com.kandypack.logistics.delivery.repository.TruckTripRepository;

// Exception handling imports
import com.kandypack.logistics.exception.ResourceNotFoundException;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class TruckTripService {

    private final TruckTripRepository truckTripRepository;
    private final DriverRepository driverRepository;
    private final AssistantRepository assistantRepository;
    private final JdbcTemplate jdbcTemplate; // For calling the sp_assign_truck_trip stored procedure

    // A truck trip be isolated it needs driver, assistant, truck, route
    public TruckTripService(TruckTripRepository truckTripRepository, DriverRepository driverRepository,
                            AssistantRepository assistantRepository, JdbcTemplate jdbcTemplate) {
        this.truckTripRepository = truckTripRepository;
        this.driverRepository = driverRepository;
        this.assistantRepository = assistantRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    // Get all truck trips  
    @Transactional(readOnly = true)
    public List<TruckTripDTO> getAllTrips() {
        return truckTripRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Get a trip by ID
    @Transactional(readOnly = true)
    public TruckTripDTO getTripById(Integer id) {
        TruckTrip trip = truckTripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("TruckTrip not found with ID: " + id));
        return toDTO(trip);
    }

    
    // Create a new truck trip
    /* Goes through the sp_assign_truck_trip stored procedure, which saves the trip and its
     * AuditLog record in one transaction. Its INSERT fires trg_before_insert_trucktrip, which runs:
     *   - sp_check_trip_route            (ReturnTime > DispatchTime, truck from the route's store, max delivery time)
     *   - sp_check_schedule_conflict     (no overlapping truck, driver or assistant)
     *   - sp_check_driver_consecutive    (driver 30-min rest between trips)
     *   - sp_check_assistant_consecutive (assistant max 2 consecutive trips)
     *   - sp_check_weekly_hours          (driver 40h and assistant 60h weekly max)
     * A broken rule comes back as an SQLException with SQLSTATE 45000. It is not caught here,
     * so the exception handler can still find it and return the rule's message.
     */
    public TruckTripDTO createTrip(TruckTripDTO dto) {
        // Validate driver and assistant existence
        if (!driverRepository.existsById(dto.getDriverId())) {
            throw new ResourceNotFoundException("Driver not found with ID: " + dto.getDriverId());
        }
        if (!assistantRepository.existsById(dto.getAssistantId())) {
            throw new ResourceNotFoundException("Assistant not found with ID: " + dto.getAssistantId());
        }

        Integer tripId = jdbcTemplate.execute((Connection conn) -> {
            try (CallableStatement cs = conn.prepareCall("{CALL sp_assign_truck_trip(?, ?, ?, ?, ?, ?, ?, ?)}")) {
                cs.setInt(1, dto.getTruckId());
                cs.setInt(2, dto.getRouteId());
                cs.setInt(3, dto.getDriverId());
                cs.setInt(4, dto.getAssistantId());
                cs.setDate(5, java.sql.Date.valueOf(dto.getTripDate()));
                cs.setTime(6, java.sql.Time.valueOf(dto.getDispatchTime()));
                cs.setTime(7, java.sql.Time.valueOf(dto.getReturnTime()));
                cs.registerOutParameter(8, Types.INTEGER); // p_TripID
                cs.execute();
                return cs.getInt(8);
            }
        });

        // Read the saved row back so the response has the driver and assistant names
        return getTripById(tripId);
    }

    // Update an existing truck trip
    public TruckTripDTO updateTrip(Integer id, TruckTripDTO dto) {
        TruckTrip trip = truckTripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("TruckTrip not found with ID: " + id));

        Driver driver = driverRepository.findById(dto.getDriverId())
                .orElseThrow(() -> new ResourceNotFoundException("Driver not found with ID: " + dto.getDriverId()));
        Assistant assistant = assistantRepository.findById(dto.getAssistantId())
                .orElseThrow(() -> new ResourceNotFoundException("Assistant not found with ID: " + dto.getAssistantId()));

        trip.setTruckId(dto.getTruckId());
        trip.setRouteId(dto.getRouteId());
        trip.setDriver(driver);
        trip.setAssistant(assistant);
        trip.setTripDate(dto.getTripDate());
        trip.setDispatchTime(dto.getDispatchTime());
        trip.setReturnTime(dto.getReturnTime());

        TruckTrip updated = truckTripRepository.save(trip);
        return toDTO(updated);
    }

    // Delete a truck trip
    public void deleteTrip(Integer id) {
        if (!truckTripRepository.existsById(id)) {
            throw new ResourceNotFoundException("TruckTrip not found with ID: " + id);
        }
        truckTripRepository.deleteById(id);
    }

    // Get trips by a specific date
    @Transactional(readOnly = true)
    public List<TruckTripDTO> getTripsByDate(LocalDate date) {
        return truckTripRepository.findByTripDate(date).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Get trips by driver
    @Transactional(readOnly = true)
    public List<TruckTripDTO> getTripsByDriver(Integer driverId) {
        return truckTripRepository.findByDriver_DriverId(driverId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Get trips by date range
    @Transactional(readOnly = true)
    public List<TruckTripDTO> getTripsByDateRange(LocalDate start, LocalDate end) {
        return truckTripRepository.findByTripDateBetween(start, end).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // (Entity -> DTO): Unpacks database records into safe data containers before returning them over the network
    private TruckTripDTO toDTO(TruckTrip trip) {
        TruckTripDTO dto = new TruckTripDTO();
        dto.setTripId(trip.getTripId());
        dto.setTruckId(trip.getTruckId());
        dto.setRouteId(trip.getRouteId());
        dto.setDriverId(trip.getDriver().getDriverId());
        dto.setAssistantId(trip.getAssistant() != null ? trip.getAssistant().getAssistantId() : null);
        dto.setTripDate(trip.getTripDate());
        dto.setDispatchTime(trip.getDispatchTime());
        dto.setReturnTime(trip.getReturnTime());
        dto.setDriverName(trip.getDriver().getName());
        dto.setAssistantName(trip.getAssistant() != null ? trip.getAssistant().getName() : null);
        return dto;
    }
}