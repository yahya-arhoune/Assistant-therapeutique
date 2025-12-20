package com.example.demo.service;

import com.example.demo.dto.journal.EmotionEntryRequest;
import com.example.demo.entity.EmotionEntry;
import com.example.demo.entity.User;
import com.example.demo.repository.EmotionEntryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EmotionEntryService {

    private final EmotionEntryRepository repository;

    public EmotionEntryService(EmotionEntryRepository repository) {
        this.repository = repository;
    }

    // CREATE
    public EmotionEntry create(EmotionEntry entry) {
        return repository.save(entry);
    }

    // READ
    public List<EmotionEntry> getAll(User user) {
        return repository.findByUser(user);
    }

    // UPDATE
    public EmotionEntry update(Long id, EmotionEntryRequest request, User user) {

        EmotionEntry entry = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Entry not found"));

        // Security: user owns the entry
        if (!entry.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        entry.setMood(request.getMood());
        entry.setIntensity(request.getIntensity());
        entry.setNote(request.getNote());

        return repository.save(entry);
    }

    // DELETE
    public void delete(Long id, User user) {

        EmotionEntry entry = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Entry not found"));

        if (!entry.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        repository.delete(entry);
    }
}

