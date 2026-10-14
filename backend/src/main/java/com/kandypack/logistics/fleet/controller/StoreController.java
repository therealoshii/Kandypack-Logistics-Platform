// Controller for store and route information
package com.kandypack.logistics.fleet.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.ResponseStatus;

import com.kandypack.logistics.fleet.dto.StoreDTO;
import com.kandypack.logistics.fleet.entity.Store;
import com.kandypack.logistics.fleet.service.StoreService;

@RestController
@RequestMapping("/api/stores")
public class StoreController {

    private final StoreService storeService;

    public StoreController(StoreService storeService) {
        this.storeService = storeService;
    }

    @GetMapping
    public List<StoreDTO> getAllStores() {
        return storeService.getAllStores();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public StoreDTO createStore(@RequestBody Store store) {
        return storeService.createStore(store);
    }
}