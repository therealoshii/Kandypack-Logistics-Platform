package com.kandypack.logistics.order.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.order.dto.OrderRequest;
import com.kandypack.logistics.order.repository.OrderRepository;
import com.kandypack.logistics.order.service.OrderService;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping
    public ResponseEntity<?> placeOrder(@RequestBody OrderRequest request) throws Exception {
        Long orderId = orderService.placeOrder(request);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Order placed successfully!");
        response.put("orderId", orderId);

        return ResponseEntity.ok(response);
    }

    // Get orders history filtered by customerId
    @GetMapping
    public ResponseEntity<List<OrderRepository.OrderHistoryRow>> getOrdersByCustomer(@RequestParam Integer customerId) {
        List<OrderRepository.OrderHistoryRow> orders = orderService.getOrdersByCustomerId(customerId);
        return ResponseEntity.ok(orders);
    }
}