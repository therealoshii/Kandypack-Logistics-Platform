package com.kandypack.logistics.order.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.kandypack.logistics.order.entity.DeliveryArea;

@Repository
public interface DeliveryAreaRepository extends JpaRepository<DeliveryArea, Integer> {

    @Query("SELECT s.city FROM DeliveryArea a JOIN Route r ON a.routeID = r.routeID JOIN Store s ON r.storeID = s.storeID WHERE a.areaID = :areaId")
    String findCityByAreaId(@Param("areaId") Integer areaId);

    // One row per delivery area, with the city of the store that serves it
    // (DeliveryArea -> Route -> Store). Used to fill the Area dropdown.
    @Query("SELECT a.areaID AS areaID, a.areaName AS areaName, a.routeID AS routeID, s.city AS city "
         + "FROM DeliveryArea a JOIN Route r ON a.routeID = r.routeID JOIN Store s ON r.storeID = s.storeID "
         + "ORDER BY s.city, a.areaName")
    List<AreaOption> findAllWithCity();

    // What /api/customers/areas returns for each area
    interface AreaOption {
        Integer getAreaID();
        String getAreaName();
        Integer getRouteID();
        String getCity();
    }
}