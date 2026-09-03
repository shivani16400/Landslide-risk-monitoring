package com.landslide.backend.service;

import com.landslide.backend.model.Alert;
import com.landslide.backend.repository.AlertRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
public class AlertService {

    private final AlertRepository alertRepository;

    public AlertService(AlertRepository alertRepository) {
        this.alertRepository = alertRepository;
    }

    @PostConstruct
    public void initDummyData() {
        if (alertRepository.count() == 0) {
            List<Alert> sampleAlerts = Arrays.asList(
                    new Alert(
                            1L,
                            "Severe Debris Flow Hazard",
                            "CRITICAL",
                            "NH-58 Km 42 (Rishikesh - Devprayag)",
                            "10 mins ago",
                            "High pore water pressure detected. Slope failure imminent along eastern embankment.",
                            false
                    ),
                    new Alert(
                            2L,
                            "High Pore Pressure Spike",
                            "HIGH",
                            "Sector 4 Badrinath Highway",
                            "25 mins ago",
                            "Piezometer P-102 reading 185 kPa exceeding safe operational threshold of 140 kPa.",
                            false
                    ),
                    new Alert(
                            3L,
                            "Moderate Slope Displacement",
                            "WARNING",
                            "Kedarnath Access Corridor Substation",
                            "1 hour ago",
                            "Inclinometer INC-04 detected 14mm displacement over last 6 hours following continuous heavy rain.",
                            true
                    ),
                    new Alert(
                            4L,
                            "Weather Warning & Rainfall Alert",
                            "INFO",
                            "Chamoli Regional Catchment Zone",
                            "3 hours ago",
                            "IMD forecast predicts 80mm heavy precipitation over next 12 hours.",
                            true
                    )
            );
            alertRepository.saveAll(sampleAlerts);
        }
    }

    public List<Alert> getAllAlerts() {
        return alertRepository.findAll();
    }
}
