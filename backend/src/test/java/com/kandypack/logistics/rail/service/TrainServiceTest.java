package com.kandypack.logistics.rail.service;

import com.kandypack.logistics.rail.repository.TrainRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TrainServiceTest {

    @Mock
    private TrainRepository trainRepository;

    @InjectMocks
    private TrainService trainService;

    @Test
    void testGetTrainSchedules() {
        String date = "2026-10-15";
        List<Map<String, Object>> mockSchedules = List.of(Map.of("ScheduleID", 1, "TrainName", "Kandy Express"));
        
        when(trainRepository.findAvailableSchedulesByDate(date)).thenReturn(mockSchedules);

        List<Map<String, Object>> result = trainService.getTrainSchedules(date);

        assertEquals(1, result.size());
        assertEquals("Kandy Express", result.get(0).get("TrainName"));
    }
}