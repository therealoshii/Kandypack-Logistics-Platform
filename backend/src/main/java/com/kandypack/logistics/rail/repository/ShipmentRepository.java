package com.kandypack.logistics.rail.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class ShipmentRepository {

    private final JdbcTemplate jdbcTemplate;

    public ShipmentRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void scheduleShipment(Integer orderDetailId, Integer scheduleId, String shipmentDate) {
        String sql = "CALL sp_schedule_shipment(?, ?, ?)";
        jdbcTemplate.update(sql, orderDetailId, scheduleId, shipmentDate);
    }

    /**
     * Order lines that still have units waiting for a train, oldest order first.
     * The remaining quantity is calculated the same way as in sp_schedule_shipment:
     * ordered quantity minus everything already booked onto a train run.
     * Cancelled orders are left out. trainDays lists the weekdays on which a train
     * runs to the order's destination store.
     */
    public List<Map<String, Object>> findPendingOrderLines() {
        String sql = """
            SELECT
                od.OrderDetailID AS orderDetailId,
                o.OrderID AS orderId,
                DATE_FORMAT(o.OrderDate, '%Y-%m-%d') AS orderDate,
                DATE_FORMAT(o.RequestedDeliveryDate, '%Y-%m-%d') AS requestedDeliveryDate,
                o.Status AS orderStatus,
                c.FullName AS customerName,
                p.ProductName AS productName,
                od.Quantity AS orderedQuantity,
                CAST(od.Quantity - COALESCE(sh.ShippedQuantity, 0) AS SIGNED) AS remainingQuantity,
                fn_calculate_total_space(od.ProductID, od.Quantity - COALESCE(sh.ShippedQuantity, 0)) AS spaceRequired,
                st.StoreID AS storeId,
                st.City AS destination,
                (SELECT GROUP_CONCAT(DISTINCT ts.DayOfWeek ORDER BY ts.DayOfWeek SEPARATOR ', ')
                 FROM TrainSchedule ts
                 WHERE ts.StoreID = st.StoreID) AS trainDays
            FROM OrderDetail od
            INNER JOIN Orders o ON od.OrderID = o.OrderID
            INNER JOIN Customer c ON o.CustomerID = c.CustomerID
            INNER JOIN Product p ON od.ProductID = p.ProductID
            INNER JOIN Route r ON o.RouteID = r.RouteID
            INNER JOIN Store st ON r.StoreID = st.StoreID
            LEFT JOIN (
                SELECT OrderDetailID, SUM(Quantity) AS ShippedQuantity
                FROM Shipment
                GROUP BY OrderDetailID
            ) sh ON sh.OrderDetailID = od.OrderDetailID
            WHERE o.Status <> 'Cancelled'
              AND od.Quantity - COALESCE(sh.ShippedQuantity, 0) > 0
            ORDER BY o.OrderDate, o.OrderID, od.OrderDetailID
            """;
        return jdbcTemplate.queryForList(sql);
    }
}
