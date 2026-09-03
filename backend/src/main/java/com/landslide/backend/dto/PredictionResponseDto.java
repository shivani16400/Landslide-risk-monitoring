package com.landslide.backend.dto;

public class PredictionResponseDto {
    private int riskScore;
    private String riskLevel;
    private RiskFactorBreakdownDto factors;

    public PredictionResponseDto() {}

    public PredictionResponseDto(int riskScore, String riskLevel) {
        this.riskScore = riskScore;
        this.riskLevel = riskLevel;
    }

    public PredictionResponseDto(int riskScore, String riskLevel, RiskFactorBreakdownDto factors) {
        this.riskScore = riskScore;
        this.riskLevel = riskLevel;
        this.factors = factors;
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

    public RiskFactorBreakdownDto getFactors() {
        return factors;
    }

    public void setFactors(RiskFactorBreakdownDto factors) {
        this.factors = factors;
    }
}
