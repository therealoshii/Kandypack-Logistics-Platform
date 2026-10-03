package com.kandypack.logistics.delivery.repository;

import com.kandypack.logistics.delivery.entity.Assistant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
// Spring Data JPA repository for Assistant entity. <entity, data_type of PK>
public interface AssistantRepository extends JpaRepository<Assistant, Integer> {

    List<Assistant> findByNameContainingIgnoreCase(String name);
    // Generates an SQL => 
    // SELECT * FROM Assistant WHERE UPPER(Name) LIKE UPPER(CONCAT('%', ?, '%'));
}
