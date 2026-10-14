package com.kandypack.logistics.fleet.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.fleet.dto.TruckDTO;
import com.kandypack.logistics.fleet.service.TruckService;

@RestController
@RequestMapping("/api/trucks")
public class TruckController {

    private final TruckService truckService;

    public TruckController(TruckService truckService) {
        this.truckService = truckService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public TruckDTO createTruck(@RequestBody TruckDTO request) {
        return truckService.createTruck(request);
    }
}