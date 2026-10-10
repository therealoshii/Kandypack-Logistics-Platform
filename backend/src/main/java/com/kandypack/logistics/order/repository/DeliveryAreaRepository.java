package com.kandypack.logistics.order.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.kandypack.logistics.order.entity.DeliveryArea;

@Repository
public interface DeliveryAreaRepository extends JpaRepository<DeliveryArea, Integer> {

    // Join with Route and Store to get Area details along with City
    @Query("SELECT da FROM DeliveryArea da JOIN Route r ON da.routeID = r.routeID JOIN Store s ON r.storeID = s.storeID")
    List<DeliveryArea> findAllWithCity();
}