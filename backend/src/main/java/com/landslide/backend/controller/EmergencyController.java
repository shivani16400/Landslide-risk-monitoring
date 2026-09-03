package com.landslide.backend.controller;

import com.landslide.backend.model.EmergencyReport;
import com.landslide.backend.service.EmergencyService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class EmergencyController {

    private final EmergencyService emergencyService;

    public EmergencyController(EmergencyService emergencyService) {
        this.emergencyService = emergencyService;
    }

    @GetMapping("/emergencies")
    public List<EmergencyReport> getEmergencies() {
        return emergencyService.getAllEmergencyReports();
    }

    @PostMapping("/emergency")
    public EmergencyReport createEmergency(@RequestBody EmergencyReport report) {
        return emergencyService.createEmergencyReport(report);
    }
}