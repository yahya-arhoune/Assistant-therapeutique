package com.example.demo.dto.journal;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Setter
@Getter
public class EmotionEntryResponse {

    private Long id;
    private String mood;
    private int intensity;
    private String note;
    private LocalDateTime createdAt;

    public EmotionEntryResponse() {
    }

    public EmotionEntryResponse(Long id, String mood, int intensity,
                                String note, LocalDateTime createdAt) {
        this.id = id;
        this.mood = mood;
        this.intensity = intensity;
        this.note = note;
        this.createdAt = createdAt;
    }

}
