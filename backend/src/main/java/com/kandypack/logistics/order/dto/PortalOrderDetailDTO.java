package com.kandypack.logistics.order.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public record PortalOrderDetailDTO(
    Integer orderID,
    Integer orderId,
    Integer customerID,
    Integer customerId,
    LocalDate orderDate,
    LocalDate requestedDeliveryDate,
    String status,
    BigDecimal totalAmount,
    String deliveryStatus,
    LocalDate deliveryDate,
    String routeName,
    String destinationCity,
    List<PortalOrderItemDTO> items,
    PortalDeliveryProgressDTO delivery
) {
    public record PortalOrderItemDTO(
        Integer orderDetailID,
        Integer orderDetailId,
        Integer productID,
        Integer productId,
        String productName,
        Integer quantity,
        BigDecimal unitPrice,
        BigDecimal lineTotal
    ) {}

    public record PortalDeliveryProgressDTO(
        Integer deliveryID,
        Integer deliveryId,
        String status,
        LocalDate deliveryDate,
        Integer tripID,
        Integer tripId,
        LocalTime dispatchTime,
        LocalTime returnTime,
        String driverName,
        String assistantName,
        String truckRegistration
    ) {}
}

