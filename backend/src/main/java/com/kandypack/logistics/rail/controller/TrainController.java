package com.kandypack.logistics.rail.controller;

import com.kandypack.logistics.rail.service.TrainService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trains")
@CrossOrigin(origins = "*")
public class TrainController {

    private final TrainService trainService;

    public TrainController(TrainService trainService) {
        this.trainService = trainService;
    }

    @GetMapping("/schedules")
    public List<Map<String, Object>> getTrainSchedules(@RequestParam("date") String shipmentDate) {
        return trainService.getTrainSchedules(shipmentDate);
    }
}