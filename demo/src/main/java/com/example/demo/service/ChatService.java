package com.example.demo.service;

import com.example.demo.entity.ChatMessage;
import com.example.demo.entity.User;
import com.example.demo.repository.ChatMessageRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class ChatService {

    private final ChatMessageRepository chatRepository;
    private final UserRepository userRepository;
    private final AiService aiService;

    public ChatService(ChatMessageRepository chatRepository,
                       UserRepository userRepository,
                       AiService aiService) {
        this.chatRepository = chatRepository;
        this.userRepository = userRepository;
        this.aiService = aiService;
    }

    public ChatMessage processUserMessage(Long userId, String message) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Save user message
        ChatMessage userMsg = new ChatMessage();
        userMsg.setUser(user);
        userMsg.setSender("user");
        userMsg.setMessage(message);
        chatRepository.save(userMsg);

        // AI response
        String aiReply = aiService.getTherapeuticResponse(message);

        // Save AI message
        ChatMessage aiMsg = new ChatMessage();
        aiMsg.setUser(user);
        aiMsg.setSender("ai");
        aiMsg.setMessage(aiReply);
        chatRepository.save(aiMsg);

        return aiMsg;
    }
}