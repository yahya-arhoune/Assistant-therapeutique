package com.example.demo.repository;

import com.example.demo.entity.EmotionEntry;
import com.example.demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EmotionEntryRepository extends JpaRepository<EmotionEntry, Long> {

    List<EmotionEntry> findByUser(User user);

    List<EmotionEntry> findByUserOrderByCreatedAtDesc(User user);
}
