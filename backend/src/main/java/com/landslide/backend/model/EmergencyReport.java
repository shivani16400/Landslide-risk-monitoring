package com.landslide.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "emergency_reports")
public class EmergencyReport {

    @Id
    private String id;

    private String location;
    private String severity;

    @Column(length = 1000)
    private String description;

    private String reporterName;
    private String timestamp;
    private String status;

    public EmergencyReport() {}

    public EmergencyReport(String id, String location, String severity, String description, String reporterName, String timestamp, String status) {
        this.id = id;
        this.location = location;
        this.severity = severity;
        this.description = description;
        this.reporterName = reporterName;
        this.timestamp = timestamp;
        this.status = status;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getReporterName() {
        return reporterName;
    }

    public void setReporterName(String reporterName) {
        this.reporterName = reporterName;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
