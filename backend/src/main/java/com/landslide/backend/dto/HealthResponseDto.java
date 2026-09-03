package com.landslide.backend.dto;

public class HealthResponseDto {
    private String status;

    public HealthResponseDto() {}

    public HealthResponseDto(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
