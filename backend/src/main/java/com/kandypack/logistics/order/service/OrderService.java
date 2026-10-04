package com.kandypack.logistics.order.service;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kandypack.logistics.order.dto.OrderRequest;

@Service
public class OrderService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional
    public Long placeOrder(OrderRequest request) {
        try {
            // Convert items list to JSON string for stored procedure
            ObjectMapper objectMapper = new ObjectMapper();
            String itemsJson = objectMapper.writeValueAsString(request.getItems());

            // Call stored procedure sp_place_order
            Long orderId = jdbcTemplate.execute((Connection conn) -> {
                try (CallableStatement stmt = conn.prepareCall("{CALL sp_place_order(?, ?, ?, ?)}")) {
                    stmt.setLong(1, request.getCustomerId());
                    stmt.setDate(2, java.sql.Date.valueOf(request.getDeliveryDate()));
                    stmt.setString(3, itemsJson);
                    stmt.registerOutParameter(4, Types.BIGINT);

                    stmt.execute();
                    return stmt.getLong(4);
                }
            });

            return orderId;
        } catch (Exception e) {
            throw new RuntimeException("Error placing order: " + e.getMessage(), e);
        }
    }
}