package com.example.demo.service;

import com.example.demo.entity.EmotionEntry;
import com.example.demo.entity.User;
import com.example.demo.repository.EmotionEntryRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class DashboardService {

    private final EmotionEntryRepository emotionRepository;
    private final UserRepository userRepository;

    public DashboardService(EmotionEntryRepository emotionRepository, UserRepository userRepository) {
        this.emotionRepository = emotionRepository;
        this.userRepository = userRepository;
    }

    public Map<String, Object> getEmotionStats(Long userId) {
        // Fetch user first
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Fetch entries for this user, ordered by creation date descending
        List<EmotionEntry> entries = emotionRepository.findByUserOrderByCreatedAtDesc(user);

        // Count moods
        Map<String, Long> moodCount = entries.stream()
                .collect(Collectors.groupingBy(
                        EmotionEntry::getMood,
                        Collectors.counting()
                ));

        // Average intensity
        double avgIntensity = entries.stream()
                .mapToInt(EmotionEntry::getIntensity)
                .average()
                .orElse(0);

        // Build stats map
        Map<String, Object> stats = new HashMap<>();
        stats.put("moodDistribution", moodCount);
        stats.put("averageIntensity", avgIntensity);
        stats.put("totalEntries", entries.size());

        return stats;
    }
}
