//Controller for fleet utilization and report endpoints

package com.kandypack.logistics.fleet.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.fleet.dto.FleetUsageDTO;
import com.kandypack.logistics.fleet.dto.TruckUtilizationDTO;
import com.kandypack.logistics.fleet.service.FleetService;

@RestController
@RequestMapping("/api")
public class FleetController {

    private final FleetService fleetService;

    public FleetController(FleetService fleetService) {
        this.fleetService = fleetService;
    }

    @GetMapping("/trucks/utilization")
    public List<TruckUtilizationDTO> getTruckUtilization() {
        return fleetService.getTruckUtilization();
    }

    @GetMapping("/reports/fleet-usage")
    public List<FleetUsageDTO> getFleetUsage(
            @RequestParam int year,
            @RequestParam int month) {

        return fleetService.getFleetUsage(year, month);
    }
}