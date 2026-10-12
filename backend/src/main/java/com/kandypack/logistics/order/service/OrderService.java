package com.kandypack.logistics.order.service;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kandypack.logistics.delivery.entity.Delivery;
import com.kandypack.logistics.delivery.entity.TruckTrip;
import com.kandypack.logistics.delivery.repository.DeliveryRepository;
import com.kandypack.logistics.fleet.entity.Route;
import com.kandypack.logistics.fleet.repository.RouteRepository;
import com.kandypack.logistics.fleet.repository.StoreRepository;
import com.kandypack.logistics.fleet.repository.TruckRepository;
import com.kandypack.logistics.order.dto.OrderItemDto;
import com.kandypack.logistics.order.dto.OrderRequest;
import com.kandypack.logistics.order.dto.PortalOrderDetailDTO;
import com.kandypack.logistics.order.entity.Order;
import com.kandypack.logistics.order.entity.OrderDetail;
import com.kandypack.logistics.order.entity.Product;
import com.kandypack.logistics.order.repository.OrderRepository;
import com.kandypack.logistics.order.repository.ProductRepository;

@Service
public class OrderService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private DeliveryRepository deliveryRepository;

    @Autowired
    private RouteRepository routeRepository;

    @Autowired
    private StoreRepository storeRepository;

    @Autowired
    private TruckRepository truckRepository;

    @Transactional
    public Long placeOrder(OrderRequest request) throws Exception {
        if (request.getDeliveryDate() == null) {
            throw new IllegalArgumentException("Delivery date cannot be null.");
        }
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new IllegalArgumentException("Order must contain at least one product item.");
        }
        for (OrderItemDto item : request.getItems()) {
            if (item == null || item.getProductId() == null || item.getQuantity() == null) {
                throw new IllegalArgumentException("Each order item must specify a valid productId and quantity.");
            }
            if (item.getQuantity() <= 0) {
                throw new IllegalArgumentException("Quantity must be greater than zero.");
            }
        }

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

    // to get order history by customer ID, with each order's delivery status
    public List<OrderRepository.OrderHistoryRow> getOrdersByCustomerId(Integer customerId) {
        return orderRepository.findHistoryByCustomerId(customerId);
    }

    // Get complete details for a single customer order
    public Optional<PortalOrderDetailDTO> getPortalOrderDetails(Integer orderId, Integer customerId) {
        Optional<Order> orderOpt = orderRepository.findById(orderId);
        if (orderOpt.isEmpty()) {
            return Optional.empty();
        }

        Order order = orderOpt.get();
        // If order belongs to another customer, return empty (404)
        if (!order.getCustomerID().equals(customerId)) {
            return Optional.empty();
        }

        String routeName = null;
        String destinationCity = null;
        if (order.getRouteID() != null) {
            Optional<Route> routeOpt = routeRepository.findById(order.getRouteID());
            if (routeOpt.isPresent()) {
                Route r = routeOpt.get();
                routeName = r.getRouteName();
                if (r.getStoreID() != null) {
                    destinationCity = storeRepository.findById(r.getStoreID())
                            .map(com.kandypack.logistics.fleet.entity.Store::getCity)
                            .orElse(null);
                }
            }
        }

        List<PortalOrderDetailDTO.PortalOrderItemDTO> items = new ArrayList<>();
        if (order.getOrderDetails() != null) {
            for (OrderDetail od : order.getOrderDetails()) {
                String productName = "Product #" + od.getProductID();
                BigDecimal unitPrice = BigDecimal.ZERO;
                Optional<Product> prodOpt = productRepository.findById(od.getProductID());
                if (prodOpt.isPresent()) {
                    Product p = prodOpt.get();
                    productName = p.getProductName();
                    unitPrice = p.getUnitPrice();
                } else if (od.getQuantity() != null && od.getQuantity() > 0 && od.getLineTotal() != null) {
                    unitPrice = od.getLineTotal().divide(BigDecimal.valueOf(od.getQuantity()), 2, java.math.RoundingMode.HALF_UP);
                }

                items.add(new PortalOrderDetailDTO.PortalOrderItemDTO(
                        od.getOrderDetailID(),
                        od.getOrderDetailID(),
                        od.getProductID(),
                        od.getProductID(),
                        productName,
                        od.getQuantity(),
                        unitPrice,
                        od.getLineTotal()
                ));
            }
        }

        Optional<Delivery> deliveryOpt = deliveryRepository.findByOrderId(orderId);
        String deliveryStatus = "Unscheduled";
        LocalDate deliveryDate = null;
        PortalOrderDetailDTO.PortalDeliveryProgressDTO deliveryProgress = null;

        if (deliveryOpt.isPresent()) {
            Delivery d = deliveryOpt.get();
            deliveryStatus = d.getStatus();
            deliveryDate = d.getDeliveryDate();

            Integer tripId = null;
            LocalTime dispatchTime = null;
            LocalTime returnTime = null;
            String driverName = null;
            String assistantName = null;
            String truckReg = null;

            TruckTrip trip = d.getTruckTrip();
            if (trip != null) {
                tripId = trip.getTripId();
                dispatchTime = trip.getDispatchTime();
                returnTime = trip.getReturnTime();
                if (trip.getDriver() != null) {
                    driverName = trip.getDriver().getName();
                }
                if (trip.getAssistant() != null) {
                    assistantName = trip.getAssistant().getName();
                }
                if (trip.getTruckId() != null) {
                    truckReg = truckRepository.findById(trip.getTruckId())
                            .map(com.kandypack.logistics.fleet.entity.Truck::getRegistrationNumber)
                            .orElse(null);
                }
            }

            deliveryProgress = new PortalOrderDetailDTO.PortalDeliveryProgressDTO(
                    d.getDeliveryId(),
                    d.getDeliveryId(),
                    d.getStatus(),
                    d.getDeliveryDate(),
                    tripId,
                    tripId,
                    dispatchTime,
                    returnTime,
                    driverName,
                    assistantName,
                    truckReg
            );
        }

        PortalOrderDetailDTO dto = new PortalOrderDetailDTO(
                order.getOrderID(),
                order.getOrderID(),
                order.getCustomerID(),
                order.getCustomerID(),
                order.getOrderDate(),
                order.getRequestedDeliveryDate(),
                order.getStatus(),
                order.getTotalAmount(),
                deliveryStatus,
                deliveryDate,
                routeName,
                destinationCity,
                items,
                deliveryProgress
        );

        return Optional.of(dto);
    }
}