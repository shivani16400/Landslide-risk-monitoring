package com.landslide.backend.dto;

public class RiskTelemetryDto {
    private int riskScore;
    private String riskLevel;
    private double rainfall;
    private double soilMoisture;
    private double slope;

    public RiskTelemetryDto() {}

    public RiskTelemetryDto(int riskScore, String riskLevel, double rainfall, double soilMoisture, double slope) {
        this.riskScore = riskScore;
        this.riskLevel = riskLevel;
        this.rainfall = rainfall;
        this.soilMoisture = soilMoisture;
        this.slope = slope;
    }

    public int getRiskScore() {
        return riskScore;
    }

    public void setRiskScore(int riskScore) {
        this.riskScore = riskScore;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public double getRainfall() {
        return rainfall;
    }

    public void setRainfall(double rainfall) {
        this.rainfall = rainfall;
    }

    public double getSoilMoisture() {
        return soilMoisture;
    }

    public void setSoilMoisture(double soilMoisture) {
        this.soilMoisture = soilMoisture;
    }

    public double getSlope() {
        return slope;
    }

    public void setSlope(double slope) {
        this.slope = slope;
    }
}
