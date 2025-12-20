package com.example.demo.controller;

import com.example.demo.dto.journal.EmotionEntryRequest;
import com.example.demo.dto.journal.EmotionEntryResponse;
import com.example.demo.entity.EmotionEntry;
import com.example.demo.entity.User;
import com.example.demo.service.EmotionEntryService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/journal")
@CrossOrigin(origins = "*")
public class EmotionEntryController {

    private final EmotionEntryService service;

    public EmotionEntryController(EmotionEntryService service) {
        this.service = service;
    }

    // CREATE
    @PostMapping("/create")
    public EmotionEntryResponse create(
            @RequestBody EmotionEntryRequest request,
            @AuthenticationPrincipal User user) {

        EmotionEntry entry = new EmotionEntry();
        entry.setMood(request.getMood());
        entry.setIntensity(request.getIntensity());
        entry.setNote(request.getNote());
        entry.setUser(user);

        EmotionEntry saved = service.create(entry);

        return mapToResponse(saved);
    }

    // READ
    @GetMapping("/all")
    public List<EmotionEntryResponse> getAll(
            @AuthenticationPrincipal User user) {

        return service.getAll(user)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    // UPDATE
    @PutMapping("/{id}")
    public EmotionEntryResponse update(
            @PathVariable Long id,
            @RequestBody EmotionEntryRequest request,
            @AuthenticationPrincipal User user) {

        EmotionEntry updated = service.update(id, request, user);
        return mapToResponse(updated);
    }

    // DELETE
    @DeleteMapping("/{id}")
    public void delete(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {

        service.delete(id, user);
    }

    // Mapper
    private EmotionEntryResponse mapToResponse(EmotionEntry e) {
        return new EmotionEntryResponse(
                e.getId(),
                e.getMood(),
                e.getIntensity(),
                e.getNote(),
                e.getCreatedAt()
        );
    }
}

