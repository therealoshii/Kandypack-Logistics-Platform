package com.kandypack.logistics.fleet.service;

import org.springframework.stereotype.Service;

import com.kandypack.logistics.fleet.dto.TruckDTO;
import com.kandypack.logistics.fleet.entity.Store;
import com.kandypack.logistics.fleet.entity.Truck;
import com.kandypack.logistics.fleet.repository.StoreRepository;
import com.kandypack.logistics.fleet.repository.TruckRepository;

@Service
public class TruckService {

    private final TruckRepository truckRepository;
    private final StoreRepository storeRepository;

    public TruckService(
            TruckRepository truckRepository,
            StoreRepository storeRepository) {
        this.truckRepository = truckRepository;
        this.storeRepository = storeRepository;
    }

    public TruckDTO createTruck(TruckDTO request) {
        if (request.getRegistrationNumber() == null
                || request.getRegistrationNumber().isBlank()) {
            throw new IllegalArgumentException(
                    "Registration number is required.");
        }

        String registrationNumber =
                request.getRegistrationNumber().trim();

        if (request.getCapacity() == null
                || request.getCapacity() <= 0) {
            throw new IllegalArgumentException(
                    "Capacity must be greater than zero.");
        }

        if (request.getStoreID() == null
                || !storeRepository.existsById(request.getStoreID())) {
            throw new IllegalArgumentException(
                    "Please select an existing store.");
        }

        if (truckRepository.existsByRegistrationNumber(registrationNumber)) {
            throw new IllegalArgumentException(
                    "A truck with this registration number already exists.");
        }

        Truck truck = new Truck();
        truck.setRegistrationNumber(registrationNumber);
        truck.setCapacity(request.getCapacity());
        truck.setStoreID(request.getStoreID());

        Truck savedTruck = truckRepository.save(truck);

        TruckDTO response = new TruckDTO();
        response.setTruckID(savedTruck.getTruckID());
        response.setRegistrationNumber(savedTruck.getRegistrationNumber());
        response.setCapacity(savedTruck.getCapacity());
        response.setStoreID(savedTruck.getStoreID());

        return response;
    }
}