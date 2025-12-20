package com.example.demo.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.*;

@Service
public class AiService {

    private final WebClient webClient;

    public AiService(@Value("${openai.api.key}") String apiKey) {
        this.webClient = WebClient.builder()
                .baseUrl("https://api.openai.com/v1")
                .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();
    }

    public String getTherapeuticResponse(String userMessage) {

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", "gpt-4o-mini");

        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of(
                "role", "system",
                "content", "You are a safe, empathetic therapeutic assistant. Do not give medical diagnoses."
        ));
        messages.add(Map.of(
                "role", "user",
                "content", userMessage
        ));

        requestBody.put("messages", messages);

        Map response = webClient.post()
                .uri("/chat/completions")
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        List choices = (List) response.get("choices");
        Map firstChoice = (Map) choices.get(0);
        Map message = (Map) firstChoice.get("message");

        return message.get("content").toString();
    }
}
