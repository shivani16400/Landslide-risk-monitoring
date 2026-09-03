package com.landslide.backend.service;

import com.landslide.backend.dto.PredictionRequestDto;
import com.landslide.backend.dto.PredictionResponseDto;
import com.landslide.backend.dto.RiskTelemetryDto;
import org.springframework.stereotype.Service;

@Service
public class RiskService {

    private final RiskPredictionService riskPredictionService;

    public RiskService(RiskPredictionService riskPredictionService) {
        this.riskPredictionService = riskPredictionService;
    }

    public RiskTelemetryDto getCurrentRiskTelemetry() {
        return new RiskTelemetryDto(
                82,
                "CRITICAL",
                142.8,
                88.4,
                42.5
        );
    }

    public PredictionResponseDto predictRisk(PredictionRequestDto request) {
        return riskPredictionService.calculateRisk(request);
    }
}
