package com.example.demo.dto.journal;

import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Setter
@Getter
public class JournalStatsResponse {

    private Map<String, Long> moodDistribution;
    private double averageIntensity;
    private int totalEntries;

    public JournalStatsResponse() {
    }

    public JournalStatsResponse(Map<String, Long> moodDistribution,
                                double averageIntensity,
                                int totalEntries) {
        this.moodDistribution = moodDistribution;
        this.averageIntensity = averageIntensity;
        this.totalEntries = totalEntries;
    }

}
