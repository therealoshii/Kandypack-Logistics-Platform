package com.kandypack.logistics.rail.service;

import com.kandypack.logistics.rail.repository.TrainRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class TrainService {

    private final TrainRepository trainRepository;

    public TrainService(TrainRepository trainRepository) {
        this.trainRepository = trainRepository;
    }

    public List<Map<String, Object>> getTrainSchedules(String shipmentDate) {
        return trainRepository.findAvailableSchedulesByDate(shipmentDate);
    }
}