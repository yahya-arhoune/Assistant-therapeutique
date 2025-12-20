package com.example.demo.dto.chat;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Setter
@Getter
public class ChatResponse {

    private String sender;          // "user" or "ai"
    private String message;
    private LocalDateTime timestamp;

    public ChatResponse() {
    }

    public ChatResponse(String sender, String message, LocalDateTime timestamp) {
        this.sender = sender;
        this.message = message;
        this.timestamp = timestamp;
    }

}