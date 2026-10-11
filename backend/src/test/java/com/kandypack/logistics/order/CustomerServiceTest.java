package com.kandypack.logistics.order;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.kandypack.logistics.exception.DuplicateEmailException;
import com.kandypack.logistics.order.dto.CustomerDTO;
import com.kandypack.logistics.order.dto.CustomerPasswordChangeRequest;
import com.kandypack.logistics.order.dto.CustomerUpdateRequest;
import com.kandypack.logistics.order.entity.Customer;
import com.kandypack.logistics.order.repository.CustomerRepository;
import com.kandypack.logistics.order.repository.DeliveryAreaRepository;
import com.kandypack.logistics.order.service.CustomerService;

class CustomerServiceTest {

    private CustomerRepository customerRepository;
    private DeliveryAreaRepository deliveryAreaRepository;
    private PasswordEncoder passwordEncoder;
    private CustomerService customerService;

    @BeforeEach
    void setUp() {
        customerRepository = mock(CustomerRepository.class);
        deliveryAreaRepository = mock(DeliveryAreaRepository.class);
        passwordEncoder = mock(PasswordEncoder.class);

        customerService = new CustomerService();
        injectField(customerService, "customerRepository", customerRepository);
        injectField(customerService, "deliveryAreaRepository", deliveryAreaRepository);
        injectField(customerService, "passwordEncoder", passwordEncoder);
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
    void testUpdateCustomerSuccess() {
        Customer existing = new Customer();
        existing.setCustomerID(1);
        existing.setFullName("Old Name");
        existing.setEmail("old@example.com");
        existing.setUsername("testuser");

        when(customerRepository.findById(1)).thenReturn(Optional.of(existing));
        when(customerRepository.existsByEmailIgnoreCaseAndCustomerIDNot("new@example.com", 1)).thenReturn(false);
        when(customerRepository.save(any(Customer.class))).thenAnswer(invocation -> invocation.getArgument(0));

        CustomerUpdateRequest request = new CustomerUpdateRequest("New Name", "new@example.com", "0771234567", "Address", 1);
        CustomerDTO result = customerService.updateCustomer(1, request);

        assertEquals("New Name", result.getFullName());
        assertEquals("new@example.com", result.getEmail());
        assertEquals("testuser", result.getUsername()); // Username unchanged
    }

    @Test
    void testUpdateCustomerDuplicateEmailThrowsException() {
        Customer existing = new Customer();
        existing.setCustomerID(1);
        existing.setEmail("old@example.com");

        when(customerRepository.findById(1)).thenReturn(Optional.of(existing));
        when(customerRepository.existsByEmailIgnoreCaseAndCustomerIDNot("taken@example.com", 1)).thenReturn(true);

        CustomerUpdateRequest request = new CustomerUpdateRequest("Name", "taken@example.com", "0771234567", "Address", 1);
        assertThrows(DuplicateEmailException.class, () -> {
            customerService.updateCustomer(1, request);
        });
    }

    @Test
    void testChangePasswordSuccess() {
        Customer customer = new Customer();
        customer.setCustomerID(1);
        customer.setPassword("$2a$10$hashedOld");

        when(customerRepository.findById(1)).thenReturn(Optional.of(customer));
        when(passwordEncoder.matches("oldPassword123", "$2a$10$hashedOld")).thenReturn(true);
        when(passwordEncoder.encode("newPassword123")).thenReturn("$2a$10$hashedNew");

        CustomerPasswordChangeRequest request = new CustomerPasswordChangeRequest("oldPassword123", "newPassword123");
        customerService.changePassword(1, request);

        assertEquals("$2a$10$hashedNew", customer.getPassword());
        verify(customerRepository).save(customer);
    }

    @Test
    void testChangePasswordIncorrectOldPasswordThrowsException() {
        Customer customer = new Customer();
        customer.setCustomerID(1);
        customer.setPassword("$2a$10$hashedOld");

        when(customerRepository.findById(1)).thenReturn(Optional.of(customer));
        when(passwordEncoder.matches("wrongOldPassword", "$2a$10$hashedOld")).thenReturn(false);

        CustomerPasswordChangeRequest request = new CustomerPasswordChangeRequest("wrongOldPassword", "newPassword123");
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            customerService.changePassword(1, request);
        });
        assertEquals("Current password is incorrect.", ex.getMessage());
    }

    @Test
    void testChangePasswordTooShortThrowsException() {
        Customer customer = new Customer();
        customer.setCustomerID(1);
        customer.setPassword("$2a$10$hashedOld");

        when(customerRepository.findById(1)).thenReturn(Optional.of(customer));
        when(passwordEncoder.matches("oldPassword123", "$2a$10$hashedOld")).thenReturn(true);

        CustomerPasswordChangeRequest request = new CustomerPasswordChangeRequest("oldPassword123", "short"); // < 12 chars
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            customerService.changePassword(1, request);
        });
        assertEquals("New password must be between 12 and 72 characters.", ex.getMessage());
    }
}

