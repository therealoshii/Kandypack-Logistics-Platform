
package com.kandypack.logistics.fleet.service;

import org.springframework.stereotype.Service;

import com.kandypack.logistics.fleet.entity.Route;
import com.kandypack.logistics.fleet.repository.RouteRepository;
import com.kandypack.logistics.fleet.repository.StoreRepository;

@Service
public class RouteService {

    private final RouteRepository routeRepository;
    private final StoreRepository storeRepository;

    public RouteService(
            RouteRepository routeRepository,
            StoreRepository storeRepository) {
        this.routeRepository = routeRepository;
        this.storeRepository = storeRepository;
    }

    public Route createRoute(Route route) {
        if (route.getStoreID() == null
                || !storeRepository.existsById(route.getStoreID())) {
            throw new IllegalArgumentException(
                    "Please select an existing store.");
        }

        if (route.getRouteName() == null
                || route.getRouteName().isBlank()) {
            throw new IllegalArgumentException(
                    "Route name is required.");
        }

        if (route.getMaxDeliveryTime() == null
                || route.getMaxDeliveryTime() <= 0) {
            throw new IllegalArgumentException(
                    "Maximum delivery time must be greater than zero.");
        }

        if (route.getDistance() == null
                || route.getDistance() <= 0) {
            throw new IllegalArgumentException(
                    "Route distance must be greater than zero.");
        }

        route.setRouteID(null);
        route.setRouteName(route.getRouteName().trim());

        return routeRepository.save(route);
    }
}
