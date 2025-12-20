package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Setter
@Getter
@Entity
@Table(name = "emotion_entry")
public class EmotionEntry {

    // Getters and Setters
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String mood; // e.g., "sad", "happy"

    private int intensity; // 1..5

    @Lob
    private String note;

    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Default constructor required by JPA
    public EmotionEntry() {
        this.createdAt = LocalDateTime.now();
    }

    // Optional convenience constructor
    public EmotionEntry(User user, String mood, int intensity, String note) {
        this.user = user;
        this.mood = mood;
        this.intensity = intensity;
        this.note = note;
        this.createdAt = LocalDateTime.now();
    }

}
