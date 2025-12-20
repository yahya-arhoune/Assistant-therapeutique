package com.example.demo.controller;

import com.example.demo.dto.journal.EmotionEntryRequest;
import com.example.demo.entity.EmotionEntry;
import com.example.demo.entity.User;
import com.example.demo.service.JournalService;
import com.example.demo.security.JwtTokenProvider;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/journal")
@CrossOrigin(origins = "*")
public class JournalController {

    private final JournalService journalService;
    private final JwtTokenProvider jwtTokenProvider;

    public JournalController(JournalService journalService, JwtTokenProvider jwtTokenProvider) {
        this.journalService = journalService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    // Add a new emotion entry (logged-in user)
    @PostMapping("/add")
    public ResponseEntity<EmotionEntry> addEntry(
            @RequestBody EmotionEntryRequest request,
            HttpServletRequest httpRequest) {

        // Extract JWT from Authorization header
        String token = httpRequest.getHeader("Authorization")
                .replace("Bearer ", "");

        String email = jwtTokenProvider.getEmailFromToken(token);

        return ResponseEntity.ok(journalService.createEntryByEmail(email, request));
    }

    // Get all entries for logged-in user
    @GetMapping("/list")
    public ResponseEntity<List<EmotionEntry>> getJournal(HttpServletRequest httpRequest) {

        String token = httpRequest.getHeader("Authorization")
                .replace("Bearer ", "");

        String email = jwtTokenProvider.getEmailFromToken(token);

        return ResponseEntity.ok(journalService.getUserJournalByEmail(email));
    }
}
