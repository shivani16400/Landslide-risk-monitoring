package com.landslide.backend.repository;

import com.landslide.backend.model.EmergencyReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmergencyReportRepository extends JpaRepository<EmergencyReport, String> {
}
