// Handles all business logic and CRUD operations for assistants

package com.kandypack.logistics.delivery.service;

// Internal project imports
import com.kandypack.logistics.delivery.dto.AssistantDTO;
import com.kandypack.logistics.delivery.entity.Assistant;
import com.kandypack.logistics.delivery.repository.AssistantRepository;

// Exception handling imports
import com.kandypack.logistics.exception.ResourceNotFoundException;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class AssistantService {

    private final AssistantRepository assistantRepository;

    public AssistantService(AssistantRepository assistantRepository) {
        this.assistantRepository = assistantRepository;
    }

    // Get all assistants
    @Transactional(readOnly = true)
    public List<AssistantDTO> getAllAssistants() {
        return assistantRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Get an assistant by ID
    @Transactional(readOnly = true)
    public AssistantDTO getAssistantById(Integer id) {
        Assistant assistant = assistantRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Assistant not found with ID: " + id));
        return toDTO(assistant);
    }

    // Create a new assistant
    public AssistantDTO createAssistant(AssistantDTO dto) {
        Assistant assistant = toEntity(dto);
        Assistant saved = assistantRepository.save(assistant);
        return toDTO(saved);
    }

    // Update an existing assistant
    public AssistantDTO updateAssistant(Integer id, AssistantDTO dto) {
        Assistant assistant = assistantRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Assistant not found with ID: " + id));
        assistant.setName(dto.getName());
        assistant.setContactNumber(dto.getContactNumber());
        Assistant updated = assistantRepository.save(assistant);
        return toDTO(updated);
    }

    // Delete an assistant
    public void deleteAssistant(Integer id) {
        if (!assistantRepository.existsById(id)) {
            throw new ResourceNotFoundException("Assistant not found with ID: " + id);
        }
        assistantRepository.deleteById(id);
    }

    // Search assistants by name
    @Transactional(readOnly = true)
    public List<AssistantDTO> searchAssistantsByName(String name) {
        return assistantRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // (Entity -> DTO)
    private AssistantDTO toDTO(Assistant assistant) {
        return new AssistantDTO(
                assistant.getAssistantId(),
                assistant.getName(),
                assistant.getContactNumber()
        );
    }

    // (DTO -> Entity)
    private Assistant toEntity(AssistantDTO dto) {
        Assistant assistant = new Assistant();
        assistant.setName(dto.getName());
        assistant.setContactNumber(dto.getContactNumber());
        return assistant;
    }
}
