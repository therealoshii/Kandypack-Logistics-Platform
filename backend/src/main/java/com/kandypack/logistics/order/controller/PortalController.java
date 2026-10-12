package com.kandypack.logistics.order.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.exception.DuplicateEmailException;
import com.kandypack.logistics.order.dto.CustomerDTO;
import com.kandypack.logistics.order.dto.CustomerPasswordChangeRequest;
import com.kandypack.logistics.order.dto.CustomerUpdateRequest;
import com.kandypack.logistics.order.dto.OrderRequest;
import com.kandypack.logistics.order.dto.PortalOrderDetailDTO;
import com.kandypack.logistics.order.dto.PortalProductDTO;
import com.kandypack.logistics.order.repository.OrderRepository;
import com.kandypack.logistics.order.service.CustomerService;
import com.kandypack.logistics.order.service.OrderService;
import com.kandypack.logistics.order.service.ProductService;
import com.kandypack.logistics.security.CustomerPrincipal;

import jakarta.validation.Valid;

// SecurityConfig only lets ROLE_CUSTOMER reach /api/portal/**, so every request here
// has a logged-in customer. The customer ID always comes from that login, never from
// the URL or the request body.
@RestController
@RequestMapping("/api/portal")
@CrossOrigin
public class PortalController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private CustomerService customerService;

    @Autowired
    private ProductService productService;

    // 1. Get logged-in customer's own profile (no password)
    @GetMapping("/me")
    public ResponseEntity<CustomerDTO> getProfile(Authentication authentication) {
        Integer customerId = currentCustomerId(authentication);
        return customerService.getCustomerById(customerId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 2. Update logged-in customer's profile (name, email, phone, address, area - not username)
    // 409 on duplicate email
    @PutMapping("/me")
    public ResponseEntity<?> updateProfile(
            @Valid @RequestBody CustomerUpdateRequest request,
            Authentication authentication) {
        Integer customerId = currentCustomerId(authentication);
        try {
            CustomerDTO updated = customerService.updateCustomer(customerId, request);
            return ResponseEntity.ok(updated);
        } catch (DuplicateEmailException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    // 3. Change password: check current password, enforce 12-72 characters, save new hash
    @PostMapping("/me/password")
    public ResponseEntity<?> changePassword(
            @Valid @RequestBody CustomerPasswordChangeRequest request,
            Authentication authentication) {
        Integer customerId = currentCustomerId(authentication);
        try {
            customerService.changePassword(customerId, request);
            return ResponseEntity.ok(Map.of("message", "Password changed successfully."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));
        }
    }

    // 4. Read-only product catalog (name, price, stock status)
    @GetMapping("/products")
    public ResponseEntity<List<PortalProductDTO>> getPortalProducts() {
        List<PortalProductDTO> products = productService.getAllProducts().stream()
                .map(PortalProductDTO::from)
                .toList();
        return ResponseEntity.ok(products);
    }

    // 5. Get logged-in customer's orders history
    @GetMapping("/orders")
    public ResponseEntity<List<OrderRepository.OrderHistoryRow>> getPortalOrders(Authentication authentication) {
        Integer customerId = currentCustomerId(authentication);
        List<OrderRepository.OrderHistoryRow> orders = orderService.getOrdersByCustomerId(customerId);
        return ResponseEntity.ok(orders);
    }

    // 6. Get one order with its lines and delivery status; 404 if it belongs to another customer
    @GetMapping("/orders/{id}")
    public ResponseEntity<PortalOrderDetailDTO> getPortalOrder(
            @PathVariable Integer id,
            Authentication authentication) {
        Integer customerId = currentCustomerId(authentication);
        return orderService.getPortalOrderDetails(id, customerId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 7. Place order from portal
    @PostMapping("/orders")
    public ResponseEntity<?> placePortalOrder(
            @RequestBody OrderRequest request,
            Authentication authentication) throws Exception {
        // Force the customer ID to be the logged-in user
        request.setCustomerID(currentCustomerId(authentication));
        Long orderId = orderService.placeOrder(request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "orderId", orderId,
                "message", "Portal order placed successfully!"
        ));
    }

    private Integer currentCustomerId(Authentication authentication) {
        CustomerPrincipal principal = (CustomerPrincipal) authentication.getPrincipal();
        return principal.getId();
    }
}
