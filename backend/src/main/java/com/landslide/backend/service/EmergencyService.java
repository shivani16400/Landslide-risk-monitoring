package com.landslide.backend.service;

import com.landslide.backend.model.EmergencyReport;
import com.landslide.backend.repository.EmergencyReportRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
public class EmergencyService {

    private final EmergencyReportRepository emergencyReportRepository;

    public EmergencyService(EmergencyReportRepository emergencyReportRepository) {
        this.emergencyReportRepository = emergencyReportRepository;
    }

    @PostConstruct
    public void initDummyData() {

        if (emergencyReportRepository.count() == 0) {

            List<EmergencyReport> sampleReports = Arrays.asList(

                    new EmergencyReport(
                            "REP-401",
                            "NH-58 Km 44 Landslide Area",
                            "Extreme / Total Blockage",
                            "Massive rockfall blocking both lanes. 3 vehicles stranded safely behind debris.",
                            "Inspector A. Sharma",
                            "15 mins ago",
                            "Team Dispatched"
                    ),

                    new EmergencyReport(
                            "REP-400",
                            "Slope Cut near Govindghat",
                            "Critical / High",
                            "Minor mudslide encroaching single lane, soil erosion rapidly progressing with rain.",
                            "Patrol Officer R. Singh",
                            "45 mins ago",
                            "Verified"
                    ),

                    new EmergencyReport(
                            "REP-399",
                            "Joshimath Bypass Bend 3",
                            "Moderate",
                            "Fissures observed on road shoulder. Retaining wall showing tilt.",
                            "SDRF Field Unit 2",
                            "2 hours ago",
                            "Under Monitoring"
                    )
            );

            emergencyReportRepository.saveAll(sampleReports);
        }
    }

    public List<EmergencyReport> getAllEmergencyReports() {
        return emergencyReportRepository.findAll();
    }

    public EmergencyReport createEmergencyReport(EmergencyReport report) {
        return emergencyReportRepository.save(report);
    }
}