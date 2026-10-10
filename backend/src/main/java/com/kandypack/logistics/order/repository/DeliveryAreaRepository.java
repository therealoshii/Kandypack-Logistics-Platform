package com.kandypack.logistics.order.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.kandypack.logistics.order.entity.DeliveryArea;

@Repository
public interface DeliveryAreaRepository extends JpaRepository<DeliveryArea, Integer> {

    @Query("SELECT s.city FROM DeliveryArea a JOIN Route r ON a.routeID = r.routeID JOIN Store s ON r.storeID = s.storeID WHERE a.areaID = :areaId")
    String findCityByAreaId(@Param("areaId") Integer areaId);
}