package com.kandypack.logistics.order.dto;

import java.math.BigDecimal;
import com.kandypack.logistics.order.entity.Product;

public record PortalProductDTO(
    Integer productID,
    Integer productId,
    String productName,
    BigDecimal unitPrice,
    BigDecimal spaceConsumption,
    Integer stockQuantity,
    String stockStatus,
    String category
) {
    public static PortalProductDTO from(Product product) {
        String status = (product.getStockQuantity() != null && product.getStockQuantity() > 0)
                ? "In Stock"
                : "Out of Stock";
        return new PortalProductDTO(
                product.getProductID(),
                product.getProductID(),
                product.getProductName(),
                product.getUnitPrice(),
                product.getSpaceConsumption(),
                product.getStockQuantity(),
                status,
                product.getCategory()
        );
    }
}

