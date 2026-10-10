
package com.kandypack.logistics.order.controller;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/public/delivery-areas")
public class PublicDeliveryAreaController {

    private final JdbcTemplate jdbcTemplate;

    public PublicDeliveryAreaController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public List<DeliveryAreaOption> getDeliveryAreas() {
        String sql = """
                SELECT AreaID, AreaName
                FROM DeliveryArea
                ORDER BY AreaName
                """;

        return jdbcTemplate.query(
                sql,
                (rs, rowNum) -> new DeliveryAreaOption(
                        rs.getInt("AreaID"),
                        rs.getString("AreaName")));
    }

    public record DeliveryAreaOption(
            Integer areaId,
            String areaName) {
    }
}
