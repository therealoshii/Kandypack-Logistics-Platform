package com.kandypack.logistics.order.repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.kandypack.logistics.order.entity.Order;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    List<Order> findByCustomerID(Integer customerID);

    // One row per order of a customer, newest first, with the status of its delivery.
    // Delivery.OrderID is UNIQUE, so the join cannot duplicate an order.
    // An order with no delivery row yet is shown as 'Unscheduled'.
    @Query(value = "SELECT o.OrderID AS orderID, o.OrderDate AS orderDate, "
         + "o.RequestedDeliveryDate AS requestedDeliveryDate, o.Status AS status, "
         + "COALESCE(d.Status, 'Unscheduled') AS deliveryStatus, o.TotalAmount AS totalAmount "
         + "FROM Orders o LEFT JOIN Delivery d ON d.OrderID = o.OrderID "
         + "WHERE o.CustomerID = :customerId "
         + "ORDER BY o.OrderDate DESC, o.OrderID DESC", nativeQuery = true)
    List<OrderHistoryRow> findHistoryByCustomerId(@Param("customerId") Integer customerId);

    // What the order history endpoints return for each order
    interface OrderHistoryRow {
        Integer getOrderID();
        LocalDate getOrderDate();
        LocalDate getRequestedDeliveryDate();
        String getStatus();
        String getDeliveryStatus();
        BigDecimal getTotalAmount();
    }
}
