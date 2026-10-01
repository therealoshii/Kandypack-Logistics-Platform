package com.kandypack.logistics.rail.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trains")
@CrossOrigin(origins = "*")
public class TrainController {

    private final JdbcTemplate jdbcTemplate;

    public TrainController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/schedules")
    public List<Map<String, Object>> getTrainSchedules(@RequestParam("date") String shipmentDate) {
        String sql = """
            SELECT 
                ts.ScheduleID,
                ts.TrainName,
                ts.DepartureTime,
                ts.CargoCapacity AS maxCapacity,
                fn_get_available_capacity(ts.ScheduleID, ?) AS availableCapacity
            FROM TrainSchedule ts
            """;
        return jdbcTemplate.queryForList(sql, shipmentDate);
    }
}