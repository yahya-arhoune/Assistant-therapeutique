package com.example.demo.controller;

import com.example.demo.dto.user.UserResponse;
import com.example.demo.entity.Role;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UserRepository userRepository;

    public AdminController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // READ ALL USERS
    @GetMapping("/users")
    public List<UserResponse> getAllUsers() {

        return userRepository.findAll()
                .stream()
                .map(u -> new UserResponse(
                        u.getId(),
                        u.getUsername(),
                        u.getEmail(),
                        u.getRole()
                ))
                .toList();
    }

    // CHANGE ROLE
    @PutMapping("/users/{id}/role")
    public void changeRole(
            @PathVariable Long id,
            @RequestParam Role role) {

        User user = userRepository.findById(id)
                .orElseThrow();

        user.setRole(role);
        userRepository.save(user);
    }
}
