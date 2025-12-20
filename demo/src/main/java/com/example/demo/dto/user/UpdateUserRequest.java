package com.example.demo.dto.user;

import lombok.Getter;
import lombok.Setter;

@Setter
public class UpdateUserRequest {

    private String username;
    @Getter
    private String email;

    public String getName() {
        return username;
    }

}
