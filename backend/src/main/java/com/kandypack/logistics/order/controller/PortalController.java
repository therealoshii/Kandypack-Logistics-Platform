package com.kandypack.logistics.order.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.order.dto.OrderRequest;
import com.kandypack.logistics.order.entity.Order;
import com.kandypack.logistics.order.service.OrderService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/portal")
@CrossOrigin
public class PortalController {

    @Autowired
    private OrderService orderService;

    // 1. Get logged-in customer's orders
    @GetMapping("/orders")
    public ResponseEntity<List<Order>> getPortalOrders(HttpSession session) {
        Integer customerId = (Integer) session.getAttribute("customerId");
        if (customerId == null) {
            return ResponseEntity.status(401).build(); // Unauthorized if not logged in
        }
        List<Order> orders = orderService.getOrdersByCustomerId(customerId);
        return ResponseEntity.ok(orders);
    }

    // 2. Place order from portal
    @PostMapping("/orders")
    public ResponseEntity<?> placePortalOrder(@RequestBody OrderRequest request, HttpSession session) throws Exception {
        Integer customerId = (Integer) session.getAttribute("customerId");
        if (customerId == null) {
            return ResponseEntity.status(401).build();
        }
        // Force the customer ID to be the logged-in user
        request.setCustomerID(customerId);
        Long orderId = orderService.placeOrder(request);
        return ResponseEntity.ok(Map.of("success", true, "orderId", orderId, "message", "Portal order placed successfully!"));
    }
}