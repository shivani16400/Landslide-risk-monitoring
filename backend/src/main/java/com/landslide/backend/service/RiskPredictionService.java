package com.landslide.backend.service;

import com.landslide.backend.dto.PredictionRequestDto;
import com.landslide.backend.dto.PredictionResponseDto;
import com.landslide.backend.dto.RiskFactorBreakdownDto;
import org.springframework.stereotype.Service;

@Service
public class RiskPredictionService {

    /**
     * Calculates an explainable landslide risk score based on normalized weighted parameters:
     * - Rainfall (max 40%): normalized against 250 mm
     * - Soil Moisture (max 25%): normalized against 100% saturation
     * - Slope Angle (max 25%): normalized against 60 degrees
     * - Vegetation Factor (max 10%): inverse protection (100% cover = 0 risk, 0% cover = 10 risk)
     */
    public PredictionResponseDto calculateRisk(PredictionRequestDto request) {
        validateRequest(request);

        double rainfall = request.getRainfall();
        double soilMoisture = request.getSoilMoisture();
        double slope = request.getSlope();
        double vegetation = request.getVegetation();

        // 1. Rainfall Contribution (Max 40 points)
        double rainNorm = Math.min(1.0, Math.max(0.0, rainfall / 250.0));
        int rainContrib = (int) Math.round(rainNorm * 40.0);

        // 2. Soil Moisture Contribution (Max 25 points)
        double moistureNorm = Math.min(1.0, Math.max(0.0, soilMoisture / 100.0));
        int moistureContrib = (int) Math.round(moistureNorm * 25.0);

        // 3. Slope Angle Contribution (Max 25 points)
        double slopeNorm = Math.min(1.0, Math.max(0.0, slope / 60.0));
        int slopeContrib = (int) Math.round(slopeNorm * 25.0);

        // 4. Vegetation Protection Mitigation (Max 10 points)
        double vegNorm = Math.min(1.0, Math.max(0.0, vegetation / 100.0));
        int vegContrib = (int) Math.round((1.0 - vegNorm) * 10.0);

        int totalScore = Math.min(100, Math.max(0, rainContrib + moistureContrib + slopeContrib + vegContrib));
        String riskLevel = determineRiskLevel(totalScore);

        RiskFactorBreakdownDto factors = new RiskFactorBreakdownDto(
                rainContrib,
                moistureContrib,
                slopeContrib,
                vegContrib
        );

        return new PredictionResponseDto(totalScore, riskLevel, factors);
    }

    public String determineRiskLevel(int score) {
        if (score <= 25) {
            return "LOW";
        } else if (score <= 50) {
            return "MODERATE";
        } else if (score <= 75) {
            return "HIGH";
        } else {
            return "CRITICAL";
        }
    }

    private void validateRequest(PredictionRequestDto request) {
        if (request == null) {
            throw new IllegalArgumentException("Prediction request payload cannot be null");
        }
        if (request.getRainfall() == null || request.getRainfall() < 0 || request.getRainfall() > 1000) {
            throw new IllegalArgumentException("Rainfall must be between 0 and 1000 mm");
        }
        if (request.getSoilMoisture() == null || request.getSoilMoisture() < 0 || request.getSoilMoisture() > 100) {
            throw new IllegalArgumentException("Soil moisture must be between 0% and 100%");
        }
        if (request.getSlope() == null || request.getSlope() < 0 || request.getSlope() > 90) {
            throw new IllegalArgumentException("Slope angle must be between 0 and 90 degrees");
        }
        if (request.getVegetation() == null || request.getVegetation() < 0 || request.getVegetation() > 100) {
            throw new IllegalArgumentException("Vegetation cover must be between 0% and 100%");
        }
    }
}
