package com.kandypack.logistics.order;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import com.kandypack.logistics.order.dto.OrderItemDto;
import com.kandypack.logistics.order.dto.OrderRequest;
import com.kandypack.logistics.order.service.OrderService;

class OrderServiceValidationTest {

    private OrderService orderService;

    @BeforeEach
    void setUp() {
        orderService = new OrderService();
    }

    @Test
    void testNullDeliveryDateThrowsIllegalArgumentException() {
        OrderRequest request = new OrderRequest();
        request.setCustomerID(1);
        request.setDeliveryDate(null);

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.placeOrder(request);
        });
        assertEquals("Delivery date cannot be null.", ex.getMessage());
    }

    @Test
    void testEmptyItemsThrowsIllegalArgumentException() {
        OrderRequest request = new OrderRequest();
        request.setCustomerID(1);
        request.setDeliveryDate(LocalDate.now().plusDays(8));
        request.setItems(Collections.emptyList());

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.placeOrder(request);
        });
        assertEquals("Order must contain at least one product item.", ex.getMessage());
    }

    @Test
    void testNullItemFieldsThrowsIllegalArgumentExceptionReturning400InsteadOf500() {
        OrderRequest request = new OrderRequest();
        request.setCustomerID(1);
        request.setDeliveryDate(LocalDate.now().plusDays(8));

        // Simulated item with wrong field names (parsed as null productId and null quantity)
        OrderItemDto invalidItem = new OrderItemDto();
        invalidItem.setProductId(null);
        invalidItem.setQuantity(null);
        request.setItems(List.of(invalidItem));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.placeOrder(request);
        });
        assertEquals("Each order item must specify a valid productId and quantity.", ex.getMessage());
    }

    @Test
    void testInvalidQuantityThrowsIllegalArgumentException() {
        OrderRequest request = new OrderRequest();
        request.setCustomerID(1);
        request.setDeliveryDate(LocalDate.now().plusDays(8));

        OrderItemDto item = new OrderItemDto();
        item.setProductId(1);
        item.setQuantity(0);
        request.setItems(List.of(item));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.placeOrder(request);
        });
        assertEquals("Quantity must be greater than zero.", ex.getMessage());
    }
}

