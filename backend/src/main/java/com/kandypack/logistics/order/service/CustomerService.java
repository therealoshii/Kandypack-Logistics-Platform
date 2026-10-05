package com.kandypack.logistics.order.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.kandypack.logistics.order.dto.CustomerDTO;
import com.kandypack.logistics.order.entity.Customer;
import com.kandypack.logistics.order.repository.CustomerRepository;

@Service
public class CustomerService {

    @Autowired
    private CustomerRepository customerRepository;

    public List<CustomerDTO> getAllCustomers() {
        return customerRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public Optional<CustomerDTO> getCustomerById(Integer id) {
        return customerRepository.findById(id).map(this::convertToDTO);
    }

    public CustomerDTO saveCustomer(CustomerDTO customerDTO) {
        Customer customer = convertToEntity(customerDTO);
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
        dto.setPassword(customer.getPassword());
        return dto;
    }

    private Customer convertToEntity(CustomerDTO dto) {
        Customer customer = new Customer();
        customer.setCustomerID(dto.getCustomerID());
        customer.setFullName(dto.getFullName());
        customer.setEmail(dto.getEmail());
        customer.setContactNumber(dto.getContactNumber());
        customer.setAddress(dto.getAddress());
        customer.setCity(dto.getCity());
        customer.setUsername(dto.getUsername());
        customer.setPassword(dto.getPassword());
        return customer;
    }
}