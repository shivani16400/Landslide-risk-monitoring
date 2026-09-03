package com.landslide.backend.dto;

public class RiskFactorBreakdownDto {
    private int rainfallContribution;
    private int soilMoistureContribution;
    private int slopeContribution;
    private int vegetationContribution;

    public RiskFactorBreakdownDto() {}

    public RiskFactorBreakdownDto(int rainfallContribution, int soilMoistureContribution, int slopeContribution, int vegetationContribution) {
        this.rainfallContribution = rainfallContribution;
        this.soilMoistureContribution = soilMoistureContribution;
        this.slopeContribution = slopeContribution;
        this.vegetationContribution = vegetationContribution;
    }

    public int getRainfallContribution() {
        return rainfallContribution;
    }

    public void setRainfallContribution(int rainfallContribution) {
        this.rainfallContribution = rainfallContribution;
    }

    public int getSoilMoistureContribution() {
        return soilMoistureContribution;
    }

    public void setSoilMoistureContribution(int soilMoistureContribution) {
        this.soilMoistureContribution = soilMoistureContribution;
    }

    public int getSlopeContribution() {
        return slopeContribution;
    }

    public void setSlopeContribution(int slopeContribution) {
        this.slopeContribution = slopeContribution;
    }

    public int getVegetationContribution() {
        return vegetationContribution;
    }

    public void setVegetationContribution(int vegetationContribution) {
        this.vegetationContribution = vegetationContribution;
    }
}
