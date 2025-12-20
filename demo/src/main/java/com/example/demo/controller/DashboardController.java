package com.example.demo.controller;

import com.example.demo.service.DashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/stats/{userId}")
    public ResponseEntity<Map<String, Object>> getStats(@PathVariable Long userId) {
        return ResponseEntity.ok(dashboardService.getEmotionStats(userId));
    }
}
