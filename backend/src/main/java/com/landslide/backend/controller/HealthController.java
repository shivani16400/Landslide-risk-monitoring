package com.landslide.backend.controller;

import com.landslide.backend.dto.HealthResponseDto;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public HealthResponseDto getHealthStatus() {
        return new HealthResponseDto("Backend is running");
    }
}
