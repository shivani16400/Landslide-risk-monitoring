package com.landslide.backend.controller;

import com.landslide.backend.dto.PredictionRequestDto;
import com.landslide.backend.dto.PredictionResponseDto;
import com.landslide.backend.dto.RiskTelemetryDto;
import com.landslide.backend.service.RiskService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class RiskController {

    private final RiskService riskService;

    public RiskController(RiskService riskService) {
        this.riskService = riskService;
    }

    @GetMapping("/risk")
    public RiskTelemetryDto getRiskTelemetry() {
        return riskService.getCurrentRiskTelemetry();
    }

    @PostMapping("/prediction")
    public PredictionResponseDto predictRisk(@Valid @RequestBody PredictionRequestDto request) {
        return riskService.predictRisk(request);
    }
}
