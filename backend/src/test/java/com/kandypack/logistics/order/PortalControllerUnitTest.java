package com.kandypack.logistics.order;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;

import com.kandypack.logistics.exception.DuplicateEmailException;
import com.kandypack.logistics.order.controller.PortalController;
import com.kandypack.logistics.order.dto.CustomerDTO;
import com.kandypack.logistics.order.dto.CustomerPasswordChangeRequest;
import com.kandypack.logistics.order.dto.CustomerUpdateRequest;
import com.kandypack.logistics.order.dto.OrderRequest;
import com.kandypack.logistics.order.dto.PortalOrderDetailDTO;
import com.kandypack.logistics.order.dto.PortalProductDTO;
import com.kandypack.logistics.order.entity.Customer;
import com.kandypack.logistics.order.entity.Product;
import com.kandypack.logistics.order.repository.OrderRepository;
import com.kandypack.logistics.order.service.CustomerService;
import com.kandypack.logistics.order.service.OrderService;
import com.kandypack.logistics.order.service.ProductService;
import com.kandypack.logistics.security.CustomerPrincipal;

class PortalControllerUnitTest {

    private OrderService orderService;
    private CustomerService customerService;
    private ProductService productService;
    private PortalController portalController;
    private Authentication customer1Auth;

    @BeforeEach
    void setUp() {
        orderService = mock(OrderService.class);
        customerService = mock(CustomerService.class);
        productService = mock(ProductService.class);

        portalController = new PortalController();
        // Inject mocks via reflection or fields
        injectField(portalController, "orderService", orderService);
        injectField(portalController, "customerService", customerService);
        injectField(portalController, "productService", productService);

        Customer c1 = new Customer();
        c1.setCustomerID(1);
        c1.setUsername("cust1");
        c1.setFullName("Customer One");
        c1.setEmail("cust1@example.com");
        c1.setPassword("$2a$10$xyz");
        CustomerPrincipal p1 = new CustomerPrincipal(c1);

        customer1Auth = mock(Authentication.class);
        when(customer1Auth.getPrincipal()).thenReturn(p1);
    }

    private void injectField(Object target, String fieldName, Object value) {
        try {
            java.lang.reflect.Field field = target.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(target, value);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test
    void testCustomerPrincipalHasRoleCustomer() {
        Customer c = new Customer();
        c.setCustomerID(1);
        c.setUsername("cust1");
        c.setPassword("hashed");
        CustomerPrincipal principal = new CustomerPrincipal(c);

        assertEquals(1, principal.getId());
        assertEquals("cust1", principal.getUsername());
        assertTrue(principal.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_CUSTOMER")));
    }

    @Test
    void testGetProfileReturnsOwnProfileWithoutPassword() {
        CustomerDTO dto = new CustomerDTO();
        dto.setCustomerID(1);
        dto.setFullName("Customer One");
        dto.setEmail("cust1@example.com");
        dto.setUsername("cust1");

        when(customerService.getCustomerById(1)).thenReturn(Optional.of(dto));

        ResponseEntity<CustomerDTO> response = portalController.getProfile(customer1Auth);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(1, response.getBody().getCustomerID());
        assertEquals("Customer One", response.getBody().getFullName());
    }

    @Test
    void testUpdateProfileSuccess() {
        CustomerUpdateRequest request = new CustomerUpdateRequest(
                "Updated Name", "updated@example.com", "0771234567", "123 Main St", 2
        );

        CustomerDTO updatedDto = new CustomerDTO();
        updatedDto.setCustomerID(1);
        updatedDto.setFullName("Updated Name");
        updatedDto.setEmail("updated@example.com");

        when(customerService.updateCustomer(eq(1), any(CustomerUpdateRequest.class))).thenReturn(updatedDto);

        ResponseEntity<?> response = portalController.updateProfile(request, customer1Auth);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(updatedDto, response.getBody());
    }

    @Test
    void testUpdateProfileDuplicateEmailReturns409() {
        CustomerUpdateRequest request = new CustomerUpdateRequest(
                "Updated Name", "duplicate@example.com", "0771234567", "123 Main St", 2
        );

        when(customerService.updateCustomer(eq(1), any(CustomerUpdateRequest.class)))
                .thenThrow(new DuplicateEmailException("An account already uses that email."));

        ResponseEntity<?> response = portalController.updateProfile(request, customer1Auth);
        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
    }

    @Test
    void testChangePasswordSuccess() {
        CustomerPasswordChangeRequest request = new CustomerPasswordChangeRequest("oldPassword123", "newPassword123");

        doNothing().when(customerService).changePassword(eq(1), any(CustomerPasswordChangeRequest.class));

        ResponseEntity<?> response = portalController.changePassword(request, customer1Auth);
        assertEquals(HttpStatus.OK, response.getStatusCode());
    }

    @Test
    void testChangePasswordWrongCurrentPasswordReturns400() {
        CustomerPasswordChangeRequest request = new CustomerPasswordChangeRequest("wrongPassword", "newPassword123");

        doThrow(new IllegalArgumentException("Current password is incorrect."))
                .when(customerService).changePassword(eq(1), any(CustomerPasswordChangeRequest.class));

        ResponseEntity<?> response = portalController.changePassword(request, customer1Auth);
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
    }

    @Test
    void testGetProductsReturnsCatalogWithNamePriceAndStockStatus() {
        Product p1 = new Product();
        p1.setProductID(10);
        p1.setProductName("Corrugated Box Small");
        p1.setUnitPrice(new BigDecimal("150.00"));
        p1.setStockQuantity(50);

        Product p2 = new Product();
        p2.setProductID(11);
        p2.setProductName("Bubble Wrap Roll");
        p2.setUnitPrice(new BigDecimal("450.00"));
        p2.setStockQuantity(0);

        when(productService.getAllProducts()).thenReturn(List.of(p1, p2));

        ResponseEntity<List<PortalProductDTO>> response = portalController.getPortalProducts();
        assertEquals(HttpStatus.OK, response.getStatusCode());
        List<PortalProductDTO> products = response.getBody();
        assertNotNull(products);
        assertEquals(2, products.size());

        assertEquals("In Stock", products.get(0).stockStatus());
        assertEquals("Out of Stock", products.get(1).stockStatus());
        assertEquals("Corrugated Box Small", products.get(0).productName());
        assertEquals(new BigDecimal("150.00"), products.get(0).unitPrice());
    }

    @Test
    void testCustomer1CannotSeeCustomer7OrderReturns404() {
        // Customer 1 querying order 7 (belongs to customer 7) -> OrderService returns empty
        when(orderService.getPortalOrderDetails(7, 1)).thenReturn(Optional.empty());

        ResponseEntity<PortalOrderDetailDTO> response = portalController.getPortalOrder(7, customer1Auth);
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }

    @Test
    void testCustomer1CanSeeCustomer1Order() {
        PortalOrderDetailDTO orderDto = new PortalOrderDetailDTO(
                101, 101, 1, 1,
                LocalDate.now(), LocalDate.now().plusDays(8),
                "Placed", new BigDecimal("1200.00"), "Unscheduled", null,
                "Route 1", "Colombo", List.of(), null
        );

        when(orderService.getPortalOrderDetails(101, 1)).thenReturn(Optional.of(orderDto));

        ResponseEntity<PortalOrderDetailDTO> response = portalController.getPortalOrder(101, customer1Auth);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(101, response.getBody().orderID());
        assertEquals("Placed", response.getBody().status());
    }

    @Test
    void testPlaceOrderEnforcesAuthenticatedCustomerId() throws Exception {
        OrderRequest request = new OrderRequest();
        request.setCustomerID(999); // Attacker tries to impersonate customer 999
        request.setDeliveryDate(LocalDate.now().plusDays(8));

        when(orderService.placeOrder(any(OrderRequest.class))).thenReturn(555L);

        ResponseEntity<?> response = portalController.placePortalOrder(request, customer1Auth);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        // Verify that the customer ID passed to orderService was forced to 1 (the authenticated customer)
        assertEquals(1, request.getCustomerID());
        verify(orderService).placeOrder(request);
    }
}

