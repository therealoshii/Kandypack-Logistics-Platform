package com.kandypack.logistics.security;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface StaffRoleRepository extends JpaRepository<StaffRole, Integer> {
    Optional<StaffRole> findByCode(String code);
    List<StaffRole> findAllByCodeIn(Collection<String> codes);
}
