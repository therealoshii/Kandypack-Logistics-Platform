// REST Controller for Assistant management endpoints

package com.kandypack.logistics.delivery.controller;

// Internal project imports
import com.kandypack.logistics.delivery.dto.AssistantDTO;
import com.kandypack.logistics.delivery.service.AssistantService;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/assistants") // Base URL path for each method
@CrossOrigin
public class AssistantController {

    private final AssistantService assistantService;

    public AssistantController(AssistantService assistantService) {
        this.assistantService = assistantService;
    }

    // Get all assistants by findAll()
    @GetMapping
    public ResponseEntity<List<AssistantDTO>> getAllAssistants() {
        return ResponseEntity.ok(assistantService.getAllAssistants());
    }

    // Get an assistant by ID
    @GetMapping("/{id}")
    public ResponseEntity<AssistantDTO> getAssistantById(@PathVariable Integer id) {
        return ResponseEntity.ok(assistantService.getAssistantById(id));
    }

    // Create a new assistant
    @PostMapping
    public ResponseEntity<AssistantDTO> createAssistant(@Valid @RequestBody AssistantDTO dto) {
        AssistantDTO created = assistantService.createAssistant(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // Update an existing assistant
    @PutMapping("/{id}")
    public ResponseEntity<AssistantDTO> updateAssistant(@PathVariable Integer id,
                                                         @Valid @RequestBody AssistantDTO dto) {
        return ResponseEntity.ok(assistantService.updateAssistant(id, dto));
    }

    // Delete an assistant by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAssistant(@PathVariable Integer id) {
        assistantService.deleteAssistant(id);
        return ResponseEntity.noContent().build();
    }

    // Search assistants by name
    @GetMapping("/search")
    public ResponseEntity<List<AssistantDTO>> searchAssistantsByName(@RequestParam String name) {
        return ResponseEntity.ok(assistantService.searchAssistantsByName(name));
    }
}
