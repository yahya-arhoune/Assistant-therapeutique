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

    public AiService(
            @Value("${openai.api.key}") String apiKey,
            @Value("${openai.api.url}") String apiUrl
    ) {
        this.webClient = WebClient.builder()
                .baseUrl(apiUrl)
                .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();
    }

    public String getTherapeuticResponse(String userMessage) {

        Map<String, Object> requestBody = new HashMap<>();

        // ✅ Groq model
        requestBody.put("model", "llama-3.3-70b-versatile");

        List<Map<String, String>> messages = new ArrayList<>();

        messages.add(Map.of(
                "role", "system",
                "content", "Tu es un assistant thérapeutique empathique. Réponds en français. Ne donne pas de diagnostics médicaux."
        ));

        messages.add(Map.of(
                "role", "user",
                "content", userMessage
        ));

        requestBody.put("messages", messages);
        requestBody.put("temperature", 0.6);
        requestBody.put("max_tokens", 1024);

        Map response = webClient.post()
                .uri("/chat/completions")
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        if (response == null || !response.containsKey("choices")) {
            throw new RuntimeException("Réponse IA invalide");
        }

        List<?> choices = (List<?>) response.get("choices");
        Map<?, ?> firstChoice = (Map<?, ?>) choices.get(0);
        Map<?, ?> message = (Map<?, ?>) firstChoice.get("message");

        return message.get("content").toString();
    }
}
