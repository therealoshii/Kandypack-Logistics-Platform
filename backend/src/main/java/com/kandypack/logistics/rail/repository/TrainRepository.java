package com.kandypack.logistics.rail.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Map;

@Repository
public class TrainRepository {

    private final JdbcTemplate jdbcTemplate;

    public TrainRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Map<String, Object>> findAvailableSchedulesByDate(String shipmentDate) {
        String sql = """
            SELECT 
                ts.ScheduleID,
                t.TrainName,
                ts.DepartureTime,
                ts.CargoCapacity AS maxCapacity,
                fn_get_available_capacity(ts.ScheduleID, ?) AS availableCapacity
            FROM TrainSchedule ts
            INNER JOIN Train t ON ts.TrainID = t.TrainID
            """;
        return jdbcTemplate.queryForList(sql, shipmentDate);
    }
}