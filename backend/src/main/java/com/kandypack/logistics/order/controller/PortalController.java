package com.kandypack.logistics.order.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.order.dto.OrderRequest;
import com.kandypack.logistics.order.repository.OrderRepository;
import com.kandypack.logistics.order.service.OrderService;
import com.kandypack.logistics.security.CustomerPrincipal;

// SecurityConfig only lets ROLE_CUSTOMER reach /api/portal/**, so every request here
// has a logged-in customer. The customer ID always comes from that login, never from
// the URL or the request body.
@RestController
@RequestMapping("/api/portal")
@CrossOrigin
public class PortalController {

    @Autowired
    private OrderService orderService;

    // 1. Get logged-in customer's orders
    @GetMapping("/orders")
    public ResponseEntity<List<OrderRepository.OrderHistoryRow>> getPortalOrders(Authentication authentication) {
        Integer customerId = currentCustomerId(authentication);
        List<OrderRepository.OrderHistoryRow> orders = orderService.getOrdersByCustomerId(customerId);
        return ResponseEntity.ok(orders);
    }

    // 2. Place order from portal
    @PostMapping("/orders")
    public ResponseEntity<?> placePortalOrder(@RequestBody OrderRequest request, Authentication authentication) throws Exception {
        // Force the customer ID to be the logged-in user
        request.setCustomerID(currentCustomerId(authentication));
        Long orderId = orderService.placeOrder(request);
        return ResponseEntity.ok(Map.of("success", true, "orderId", orderId, "message", "Portal order placed successfully!"));
    }

    private Integer currentCustomerId(Authentication authentication) {
        CustomerPrincipal principal = (CustomerPrincipal) authentication.getPrincipal();
        return principal.getId();
    }
}
