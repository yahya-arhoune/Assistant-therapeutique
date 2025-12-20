package com.example.demo.dto.chat;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class ChatRequest {

    private String message;

    public ChatRequest() {
    }

    public ChatRequest(String message) {
        this.message = message;
    }

}