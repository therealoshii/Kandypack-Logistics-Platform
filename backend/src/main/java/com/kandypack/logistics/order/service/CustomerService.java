package com.kandypack.logistics.order.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.kandypack.logistics.order.dto.CustomerCreateRequest;
import com.kandypack.logistics.order.dto.CustomerDTO;
import com.kandypack.logistics.order.entity.Customer;
import com.kandypack.logistics.order.repository.CustomerRepository;

@Service
public class CustomerService {

    @Autowired
    private CustomerRepository customerRepository;

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
        customer.setUsername(request.username());
        //encrypt the password by bcrypt
        customer.setPassword(passwordEncoder.encode(request.password()));

        Customer savedCustomer = customerRepository.save(customer);
        return convertToDTO(savedCustomer);
    }

    public void deleteCustomer(Integer id) {
        customerRepository.deleteById(id);
    }

    // Helper conversion methods
    private CustomerDTO convertToDTO(Customer customer) {
        CustomerDTO dto = new CustomerDTO();
        dto.setCustomerID(customer.getCustomerID());
        dto.setFullName(customer.getFullName());
        dto.setEmail(customer.getEmail());
        dto.setContactNumber(customer.getContactNumber());
        dto.setAddress(customer.getAddress());
        dto.setCity(customer.getCity());
        dto.setUsername(customer.getUsername());
        return dto;
    }
}