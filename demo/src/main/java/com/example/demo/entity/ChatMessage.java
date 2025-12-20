package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Setter
@Getter
@Entity
@Table(name = "chat_message")
public class ChatMessage {

    // Getters and Setters
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String sender; // "user" or "ai"

    @Lob
    private String message;

    private LocalDateTime timestamp;

    // Default constructor required by JPA
    public ChatMessage() {
        this.timestamp = LocalDateTime.now();
    }

    // Optional convenience constructor
    public ChatMessage(User user, String sender, String message) {
        this.user = user;
        this.sender = sender;
        this.message = message;
        this.timestamp = LocalDateTime.now();
    }

}
