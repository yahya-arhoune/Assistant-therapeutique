package com.example.demo.controller;

import com.example.demo.dto.user.UpdateUserRequest;
import com.example.demo.dto.user.UserResponse;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // READ — current user profile
    @GetMapping("/me")
    public UserResponse getProfile(
            @AuthenticationPrincipal User user) {

        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole()
        );
    }

    // UPDATE — current user profile
    @PutMapping("/me")
    public UserResponse updateProfile(
            @AuthenticationPrincipal User user,
            @RequestBody UpdateUserRequest request) {

        user.setUsername(request.getName());
        user.setEmail(request.getEmail());

        userRepository.save(user);

        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole()
        );
    }

    // DELETE — current user
    @DeleteMapping("/me")
    public ResponseEntity<String> deleteAccount(
            @AuthenticationPrincipal User user) {

        userRepository.delete(user);
        return ResponseEntity.ok("Account deleted");
    }
}

