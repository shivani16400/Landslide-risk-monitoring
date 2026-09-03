package com.landslide.backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class PredictionRequestDto {

    @NotNull(message = "Rainfall is required")
    @Min(value = 0, message = "Rainfall cannot be negative")
    @Max(value = 1000, message = "Rainfall exceeds realistic threshold (max 1000 mm)")
    private Double rainfall;

    @NotNull(message = "Soil moisture is required")
    @Min(value = 0, message = "Soil moisture cannot be negative")
    @Max(value = 100, message = "Soil moisture cannot exceed 100%")
    private Double soilMoisture;

    @NotNull(message = "Slope is required")
    @Min(value = 0, message = "Slope angle cannot be negative")
    @Max(value = 90, message = "Slope angle cannot exceed 90 degrees")
    private Double slope;

    @NotNull(message = "Vegetation is required")
    @Min(value = 0, message = "Vegetation cover cannot be negative")
    @Max(value = 100, message = "Vegetation cover cannot exceed 100%")
    private Double vegetation;

    public PredictionRequestDto() {}

    public PredictionRequestDto(Double rainfall, Double soilMoisture, Double slope, Double vegetation) {
        this.rainfall = rainfall;
        this.soilMoisture = soilMoisture;
        this.slope = slope;
        this.vegetation = vegetation;
    }

    public Double getRainfall() {
        return rainfall;
    }

    public void setRainfall(Double rainfall) {
        this.rainfall = rainfall;
    }

    public Double getSoilMoisture() {
        return soilMoisture;
    }

    public void setSoilMoisture(Double soilMoisture) {
        this.soilMoisture = soilMoisture;
    }

    public Double getSlope() {
        return slope;
    }

    public void setSlope(Double slope) {
        this.slope = slope;
    }

    public Double getVegetation() {
        return vegetation;
    }

    public void setVegetation(Double vegetation) {
        this.vegetation = vegetation;
    }
}
