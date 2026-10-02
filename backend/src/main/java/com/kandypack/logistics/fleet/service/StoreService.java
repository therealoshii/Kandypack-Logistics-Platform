package com.kandypack.logistics.fleet.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.kandypack.logistics.fleet.dto.StoreDTO;
import com.kandypack.logistics.fleet.entity.Store;
import com.kandypack.logistics.fleet.repository.StoreRepository;

@Service
public class StoreService {

    private final StoreRepository storeRepository;

    public StoreService(StoreRepository storeRepository) {
        this.storeRepository = storeRepository;
    }

    public List<StoreDTO> getAllStores() {
        return storeRepository.findAll()
                .stream()
                .map(this::toDTO)
                .toList();
    }

    private StoreDTO toDTO(Store store) {
        StoreDTO dto = new StoreDTO();

        dto.setStoreID(store.getStoreID());
        dto.setStoreName(store.getStoreName());
        dto.setCapacity(store.getCapacity());
        dto.setCity(store.getCity());

        return dto;
    }
}