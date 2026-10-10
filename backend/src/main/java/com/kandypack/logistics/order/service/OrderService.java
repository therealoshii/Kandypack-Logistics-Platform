package com.kandypack.logistics.order.service;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kandypack.logistics.order.dto.OrderRequest;
import com.kandypack.logistics.order.entity.Order;
import com.kandypack.logistics.order.repository.OrderRepository;

@Service
public class OrderService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private OrderRepository orderRepository;

    @Transactional
    public Long placeOrder(OrderRequest request) throws Exception {
        // Convert items list to JSON string for stored procedure
        ObjectMapper objectMapper = new ObjectMapper();
        String itemsJson = objectMapper.writeValueAsString(request.getItems());

        // Call stored procedure sp_place_order
        Long orderId = jdbcTemplate.execute((Connection conn) -> {
            try (CallableStatement stmt = conn.prepareCall("{CALL sp_place_order(?, ?, ?, ?)}")) {
                stmt.setInt(1, request.getCustomerID());
                stmt.setDate(2, java.sql.Date.valueOf(request.getDeliveryDate()));
                stmt.setString(3, itemsJson);
                stmt.registerOutParameter(4, Types.BIGINT);

                stmt.execute();
                return stmt.getLong(4);
            }
        });

        return orderId;
    }

    // to get order history by customer ID
    public List<Order> getOrdersByCustomerId(Integer customerId) {
        return orderRepository.findByCustomerID(customerId);
    }
}