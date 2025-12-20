package com.example.demo.dto.user;

import com.example.demo.entity.Role;
import lombok.Getter;

public class UserResponse {

    @Getter
    private Long id;
    private String username;
    @Getter
    private String email;
    @Getter
    private Role role;

    public UserResponse(Long id, String username, String email, Role role) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.role = role;
    }

    public String getName() {
        return username;
    }

}

