package com.landslide.backend.service;

import com.landslide.backend.dto.PredictionRequestDto;
import com.landslide.backend.dto.PredictionResponseDto;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class RiskPredictionServiceTest {

    private RiskPredictionService predictionService;

    @BeforeEach
    void setUp() {
        predictionService = new RiskPredictionService();
    }

    @Test
    @DisplayName("Should return LOW risk (0-25) for mild environmental parameters")
    void testLowRiskCondition() {
        PredictionRequestDto request = new PredictionRequestDto(10.0, 15.0, 10.0, 90.0);
        PredictionResponseDto response = predictionService.calculateRisk(request);

        assertNotNull(response);
        assertTrue(response.getRiskScore() <= 25, "Low risk score should be <= 25");
        assertEquals("LOW", response.getRiskLevel());
        assertNotNull(response.getFactors());
    }

    @Test
    @DisplayName("Should return MODERATE risk (26-50) for average environmental parameters")
    void testModerateRiskCondition() {
        PredictionRequestDto request = new PredictionRequestDto(80.0, 40.0, 25.0, 60.0);
        PredictionResponseDto response = predictionService.calculateRisk(request);

        assertNotNull(response);
        assertTrue(response.getRiskScore() >= 26 && response.getRiskScore() <= 50,
                "Moderate risk score should be between 26 and 50");
        assertEquals("MODERATE", response.getRiskLevel());
        assertNotNull(response.getFactors());
    }

    @Test
    @DisplayName("Should return HIGH risk (51-75) for elevated rainfall and slope")
    void testHighRiskCondition() {
        PredictionRequestDto request = new PredictionRequestDto(150.0, 70.0, 40.0, 30.0);
        PredictionResponseDto response = predictionService.calculateRisk(request);

        assertNotNull(response);
        assertTrue(response.getRiskScore() >= 51 && response.getRiskScore() <= 75,
                "High risk score should be between 51 and 75");
        assertEquals("HIGH", response.getRiskLevel());
        assertNotNull(response.getFactors());
    }

    @Test
    @DisplayName("Should return CRITICAL risk (76-100) for extreme monsoon and steep terrain")
    void testCriticalRiskCondition() {
        PredictionRequestDto request = new PredictionRequestDto(220.0, 90.0, 55.0, 10.0);
        PredictionResponseDto response = predictionService.calculateRisk(request);

        assertNotNull(response);
        assertTrue(response.getRiskScore() >= 76, "Critical risk score should be >= 76");
        assertEquals("CRITICAL", response.getRiskLevel());
        assertNotNull(response.getFactors());
        assertTrue(response.getFactors().getRainfallContribution() > 0);
    }

    @Test
    @DisplayName("Should throw IllegalArgumentException when input parameters are out of range")
    void testInvalidInput() {
        // Negative rainfall
        PredictionRequestDto invalidRainfall = new PredictionRequestDto(-10.0, 50.0, 30.0, 50.0);
        assertThrows(IllegalArgumentException.class, () -> predictionService.calculateRisk(invalidRainfall));

        // Slope exceeding 90 degrees
        PredictionRequestDto invalidSlope = new PredictionRequestDto(50.0, 50.0, 120.0, 50.0);
        assertThrows(IllegalArgumentException.class, () -> predictionService.calculateRisk(invalidSlope));

        // Soil moisture exceeding 100%
        PredictionRequestDto invalidMoisture = new PredictionRequestDto(50.0, 150.0, 30.0, 50.0);
        assertThrows(IllegalArgumentException.class, () -> predictionService.calculateRisk(invalidMoisture));

        // Null request
        assertThrows(IllegalArgumentException.class, () -> predictionService.calculateRisk(null));
    }
}
