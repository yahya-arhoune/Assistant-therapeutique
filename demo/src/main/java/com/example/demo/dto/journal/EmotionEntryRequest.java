package com.example.demo.dto.journal;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class EmotionEntryRequest {

    // Getters and Setters
    private String mood;
    private int intensity;
    private String note;

}
