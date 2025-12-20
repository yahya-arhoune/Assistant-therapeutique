package com.example.demo;

import com.example.demo.controller.ChatController;
import com.example.demo.entity.ChatMessage;
import com.example.demo.entity.User;
import com.example.demo.service.ChatService;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ChatController.class)
class ChatControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ChatService chatService;

    @Test
    void shouldSendChatMessage() throws Exception {
        ChatMessage aiMsg = new ChatMessage();
        aiMsg.setMessage("AI response");
        aiMsg.setSender("ai");
        aiMsg.setUser(new User()); // optional mock user

        Mockito.when(chatService.processUserMessage(Mockito.any(Long.class), Mockito.anyString()))
                .thenReturn(aiMsg);

        mockMvc.perform(post("/api/chat/send/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"I feel anxious\"}"))
                .andExpect(status().isOk());
    }
}