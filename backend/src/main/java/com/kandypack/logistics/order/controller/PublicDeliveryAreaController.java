
package com.kandypack.logistics.order.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.kandypack.logistics.order.entity.DeliveryArea;
import com.kandypack.logistics.order.repository.DeliveryAreaRepository;

@RestController
@RequestMapping("/api/public/delivery-areas")
public class PublicDeliveryAreaController {

    private final DeliveryAreaRepository deliveryAreaRepository;

    public PublicDeliveryAreaController(
            DeliveryAreaRepository deliveryAreaRepository) {
        this.deliveryAreaRepository = deliveryAreaRepository;
    }

    @GetMapping
    public List<DeliveryArea> getDeliveryAreas() {
        return deliveryAreaRepository.findAll();
    }
}
