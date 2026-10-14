// Database access for assigning orders to truck trips (the Assign delivery form on the Roster page)

package com.kandypack.logistics.delivery.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;
import java.util.List;
import java.util.Map;

@Repository
public class DeliveryAssignmentRepository {

    private final JdbcTemplate jdbcTemplate;

    public DeliveryAssignmentRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /*
     * Orders that do not have a delivery yet (cancelled and delivered orders are left out).
     * unitsWaiting is how many units are not yet booked on a train; an order is ready for a truck
     * when it is 0. lastArrival is when the last train carrying the order reaches the store, so
     * the page can offer only trips that leave after it (sp_check_delivery enforces the same rule).
     */
    public List<Map<String, Object>> findOrdersWithoutDelivery() {
        String sql = """
            SELECT
                o.OrderID AS orderId,
                c.FullName AS customerName,
                o.Status AS orderStatus,
                DATE_FORMAT(o.OrderDate, '%Y-%m-%d') AS orderDate,
                DATE_FORMAT(o.RequestedDeliveryDate, '%Y-%m-%d') AS requestedDeliveryDate,
                r.RouteID AS routeId,
                r.RouteName AS routeName,
                st.City AS city,
                COUNT(od.OrderDetailID) AS lineCount,
                CAST(SUM(od.Quantity - COALESCE(sh.ShippedQuantity, 0)) AS SIGNED) AS unitsWaiting,
                DATE_FORMAT(MAX(sh.LastArrival), '%Y-%m-%dT%H:%i:%s') AS lastArrival
            FROM Orders o
            INNER JOIN Customer c ON c.CustomerID = o.CustomerID
            INNER JOIN Route r ON r.RouteID = o.RouteID
            INNER JOIN Store st ON st.StoreID = r.StoreID
            INNER JOIN OrderDetail od ON od.OrderID = o.OrderID
            LEFT JOIN (
                SELECT s.OrderDetailID,
                       SUM(s.Quantity) AS ShippedQuantity,
                       MAX(TIMESTAMP(s.ShipmentDate, ts.ArrivalTime)) AS LastArrival
                FROM Shipment s
                INNER JOIN TrainSchedule ts ON ts.ScheduleID = s.ScheduleID
                GROUP BY s.OrderDetailID
            ) sh ON sh.OrderDetailID = od.OrderDetailID
            WHERE o.Status NOT IN ('Cancelled', 'Delivered')
              AND NOT EXISTS (SELECT 1 FROM Delivery d WHERE d.OrderID = o.OrderID)
            GROUP BY o.OrderID, c.FullName, o.Status, o.OrderDate, o.RequestedDeliveryDate,
                     r.RouteID, r.RouteName, st.City
            ORDER BY o.RequestedDeliveryDate, o.OrderID
            """;
        return jdbcTemplate.queryForList(sql);
    }

    // Calls sp_assign_delivery, which saves the delivery and its AuditLog record together.
    // A broken delivery rule comes back as an SQLException with SQLSTATE 45000 (shown as HTTP 400).
    public Integer assignDelivery(Integer orderId, Integer tripId, String changedBy) {
        return jdbcTemplate.execute((Connection conn) -> {
            try (CallableStatement cs = conn.prepareCall("{CALL sp_assign_delivery(?, ?, ?, ?)}")) {
                cs.setInt(1, orderId);
                cs.setInt(2, tripId);
                cs.setString(3, changedBy); // p_ChangedBy, recorded in the AuditLog
                cs.registerOutParameter(4, Types.INTEGER); // p_DeliveryID
                cs.execute();
                return cs.getInt(4);
            }
        });
    }
}
