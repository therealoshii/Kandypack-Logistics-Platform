//Service for retrieving store information and connected routes

package com.kandypack.logistics.fleet.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.kandypack.logistics.fleet.dto.RouteDTO;
import com.kandypack.logistics.fleet.dto.StoreDTO;
import com.kandypack.logistics.fleet.entity.Route;
import com.kandypack.logistics.fleet.entity.Store;
import com.kandypack.logistics.fleet.repository.RouteRepository;
import com.kandypack.logistics.fleet.repository.StoreRepository;

@Service
public class StoreService {

    private final StoreRepository storeRepository;
    private final RouteRepository routeRepository;

    public StoreService(StoreRepository storeRepository, RouteRepository routeRepository) {
        this.storeRepository = storeRepository;
        this.routeRepository = routeRepository;
    }

    public List<StoreDTO> getAllStores() {
        return storeRepository.findAll()
                .stream()
                .map(this::toDTO)
                .toList();
    }

    public StoreDTO createStore(Store store) {
        if (store.getStoreName() == null || store.getStoreName().isBlank()) {
            throw new IllegalArgumentException("Store name is required.");
        }

        if (store.getCity() == null || store.getCity().isBlank()) {
            throw new IllegalArgumentException("City is required.");
        }

        
        if (store.getCapacity() == null || store.getCapacity() <= 0) {
            throw new IllegalArgumentException("Capacity must be greater than zero.");
        }

        store.setStoreName(store.getStoreName().trim());
        store.setCity(store.getCity().trim());
        store.setStoreID(null);


        Store savedStore = storeRepository.save(store);
        return toDTO(savedStore);}

    private StoreDTO toDTO(Store store) {
        StoreDTO dto = new StoreDTO();

        dto.setStoreID(store.getStoreID());
        dto.setStoreName(store.getStoreName());
        dto.setCapacity(store.getCapacity());
        dto.setCity(store.getCity());

        List<RouteDTO> routes = routeRepository.findByStoreID(store.getStoreID())
                .stream()
                .map(this::toRouteDTO)
                .toList();

        dto.setRoutes(routes);

        return dto;
    }

    private RouteDTO toRouteDTO(Route route) {
        RouteDTO dto = new RouteDTO();

        dto.setRouteID(route.getRouteID());
        dto.setStoreID(route.getStoreID());
        dto.setRouteName(route.getRouteName());
        dto.setMaxDeliveryTime(route.getMaxDeliveryTime());
        dto.setDistance(route.getDistance());

        return dto;
    }
}