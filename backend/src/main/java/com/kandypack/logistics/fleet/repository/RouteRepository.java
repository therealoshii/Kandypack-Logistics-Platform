package com.kandypack.logistics.fleet.repository;

import com.kandypack.logistics.fleet.entity.Route;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RouteRepository extends JpaRepository<Route, Integer> {

    List<Route> findByStoreID(Integer storeID);
}