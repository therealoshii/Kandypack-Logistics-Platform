package com.kandypack.logistics.order.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.kandypack.logistics.order.dto.CustomerCreateRequest;
import com.kandypack.logistics.order.dto.CustomerDTO;
import com.kandypack.logistics.order.dto.CustomerPasswordChangeRequest;
import com.kandypack.logistics.order.dto.CustomerUpdateRequest;
import com.kandypack.logistics.order.entity.Customer;
import com.kandypack.logistics.order.entity.DeliveryArea;
import com.kandypack.logistics.order.repository.CustomerRepository;
import com.kandypack.logistics.order.repository.DeliveryAreaRepository;

@Service
public class CustomerService {

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private DeliveryAreaRepository deliveryAreaRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public List<CustomerDTO> getAllCustomers() {
        return customerRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public Optional<CustomerDTO> getCustomerById(Integer id) {
        return customerRepository.findById(id).map(this::convertToDTO);
    }

    public CustomerDTO createCustomer(CustomerCreateRequest request) {
        if (customerRepository.existsByUsernameIgnoreCase(request.username())) {
            throw new IllegalArgumentException("That username is already taken.");
        }
        if (customerRepository.existsByEmailIgnoreCase(request.email())) {
            throw new IllegalArgumentException("An account already uses that email.");
        }

        Customer customer = new Customer();
        customer.setFullName(request.fullName());
        customer.setEmail(request.email());
        customer.setContactNumber(request.contactNumber());
        customer.setAddress(request.address());
        customer.setAreaID(request.areaId());
        customer.setUsername(request.username());
        // encrypt the password by bcrypt
        customer.setPassword(passwordEncoder.encode(request.password()));

        Customer savedCustomer = customerRepository.save(customer);
        return convertToDTO(savedCustomer);
    }

    public void deleteCustomer(Integer id) {
        customerRepository.deleteById(id);
    }

    public CustomerDTO updateCustomer(Integer customerId, CustomerUpdateRequest request) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new com.kandypack.logistics.exception.ResourceNotFoundException("Customer not found with id: " + customerId));

        if (customerRepository.existsByEmailIgnoreCaseAndCustomerIDNot(request.email(), customerId)) {
            throw new com.kandypack.logistics.exception.DuplicateEmailException("An account already uses that email.");
        }

        customer.setFullName(request.fullName());
        customer.setEmail(request.email());
        customer.setContactNumber(request.contactNumber());
        customer.setAddress(request.address());
        if (request.areaId() != null) {
            customer.setAreaID(request.areaId());
        }

        Customer savedCustomer = customerRepository.save(customer);
        return convertToDTO(savedCustomer);
    }

    public void changePassword(Integer customerId, CustomerPasswordChangeRequest request) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new com.kandypack.logistics.exception.ResourceNotFoundException("Customer not found with id: " + customerId));

        if (!passwordEncoder.matches(request.currentPassword(), customer.getPassword())) {
            throw new IllegalArgumentException("Current password is incorrect.");
        }

        if (request.newPassword() == null || request.newPassword().length() < 12 || request.newPassword().length() > 72) {
            throw new IllegalArgumentException("New password must be between 12 and 72 characters.");
        }

        customer.setPassword(passwordEncoder.encode(request.newPassword()));
        customerRepository.save(customer);
    }

    // Helper conversion methods
    private CustomerDTO convertToDTO(Customer customer) {
        CustomerDTO dto = new CustomerDTO();
        dto.setCustomerID(customer.getCustomerID());
        dto.setFullName(customer.getFullName());
        dto.setEmail(customer.getEmail());
        dto.setContactNumber(customer.getContactNumber());
        dto.setAddress(customer.getAddress());
        dto.setAreaId(customer.getAreaID());
        dto.setUsername(customer.getUsername());

        // Fetch and fill areaName and city via DeliveryArea -> Route -> Store join query
        if (customer.getAreaID() != null) {
            Optional<DeliveryArea> areaOpt = deliveryAreaRepository.findById(customer.getAreaID());
            if (areaOpt.isPresent()) {
                DeliveryArea area = areaOpt.get();
                dto.setAreaName(area.getAreaName());
                
                // Fetch city using the repository join query
                String city = deliveryAreaRepository.findCityByAreaId(customer.getAreaID());
                dto.setCity(city);
            }
        }

        return dto;
    }
}