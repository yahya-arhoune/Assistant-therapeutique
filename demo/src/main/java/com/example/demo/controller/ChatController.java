package com.example.demo.controller;

import com.example.demo.dto.chat.ChatRequest;
import com.example.demo.entity.ChatMessage;
import com.example.demo.service.ChatService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*")
public class ChatController {

    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @PostMapping("/send/{userId}")
    public ResponseEntity<ChatMessage> sendMessage(
            @PathVariable Long userId,
            @RequestBody ChatRequest request) {

        ChatMessage response = chatService.processUserMessage(
                userId,
                request.getMessage()
        );

        return ResponseEntity.ok(response);
    }
}