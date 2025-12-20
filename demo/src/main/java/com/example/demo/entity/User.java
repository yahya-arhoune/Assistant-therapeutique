package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@Entity
@Table(name = "users")
public class User {

    // Getters and Setters
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password; // hashed

    @Enumerated(EnumType.STRING)
    private Role role;

    // Default constructor required by JPA
    public User() {
    }

    // Convenience constructor
    public User(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
    }

}
