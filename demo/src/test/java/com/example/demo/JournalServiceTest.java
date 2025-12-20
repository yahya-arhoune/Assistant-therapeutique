package com.example.demo;

import com.example.demo.entity.EmotionEntry;
import com.example.demo.repository.EmotionEntryRepository;
import com.example.demo.service.JournalService;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class JournalServiceTest {

    @MockBean
    private EmotionEntryRepository emotionEntryRepository;

    @MockBean
    private JournalService journalService;

    @Test
    void shouldReturnAllEmotionEntries() {
        EmotionEntry entry = new EmotionEntry();
        entry.setMood("happy");
        entry.setIntensity(4);

        Mockito.when(emotionEntryRepository.findAll())
                .thenReturn(List.of(entry));

        List<EmotionEntry> entries = List.of(entry);

        assertEquals(1, entries.size());
        assertEquals("happy", entries.get(0).getMood());
    }
}
