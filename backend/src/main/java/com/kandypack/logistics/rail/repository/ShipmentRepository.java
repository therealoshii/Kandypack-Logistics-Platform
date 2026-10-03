package com.kandypack.logistics.rail.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ShipmentRepository {

    private final JdbcTemplate jdbcTemplate;

    public ShipmentRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void scheduleShipment(Integer orderDetailId, Integer scheduleId, String shipmentDate, Integer quantity) {
        String sql = "CALL sp_schedule_shipment(?, ?, ?, ?)";
        jdbcTemplate.update(sql, orderDetailId, scheduleId, shipmentDate, quantity);
    }
    
}
