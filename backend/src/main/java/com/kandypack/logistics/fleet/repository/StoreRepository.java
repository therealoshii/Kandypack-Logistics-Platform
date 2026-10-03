//Repository for accessing store records

package com.kandypack.logistics.fleet.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.kandypack.logistics.fleet.entity.Store;

public interface StoreRepository extends JpaRepository<Store, Integer> {
}