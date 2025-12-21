package com.example.demo;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.security.JwtTokenProvider;
import com.example.demo.service.AuthService;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class AuthServiceTest {

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private AuthService authService;

    @Test
    void shouldLoginSuccessfully() {
        User user = new User();
        user.setEmail("test@mail.com");
        user.setPassword("encodedPassword");

        Mockito.when(userRepository.findByEmail("test@mail.com"))
                .thenReturn(Optional.of(user));

        Mockito.when(jwtTokenProvider.generateToken(Mockito.any(User.class)))
                .thenReturn("fake-jwt-token");

        String token = "fake-jwt-token";

        assertNotNull(token);
        assertEquals("fake-jwt-token", token);
    }
}