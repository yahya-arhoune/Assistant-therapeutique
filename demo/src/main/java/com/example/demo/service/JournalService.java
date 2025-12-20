package com.example.demo.service;

import com.example.demo.dto.journal.EmotionEntryRequest;
import com.example.demo.entity.EmotionEntry;
import com.example.demo.entity.User;
import com.example.demo.repository.EmotionEntryRepository;
import com.example.demo.repository.UserRepository;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class JournalService {

    private final EmotionEntryRepository entryRepository;
    private final UserRepository userRepository;

    public JournalService(EmotionEntryRepository entryRepository, UserRepository userRepository) {
        this.entryRepository = entryRepository;
        this.userRepository = userRepository;
    }

    public EmotionEntry createEntryByEmail(String email, EmotionEntryRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        EmotionEntry entry = new EmotionEntry();
        entry.setMood(request.getMood());
        entry.setIntensity(request.getIntensity());
        entry.setNote(request.getNote());
        entry.setUser(user);

        return entryRepository.save(entry);
    }

    public List<EmotionEntry> getUserJournalByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return entryRepository.findByUser(user);
    }
}
