package com.hbi.model;

import jakarta.persistence.Column;
import jakarta.persistence.Table;

/**
 * Created by ceeuoo on 8/13/2016.
 */
@Table(name = "landlord_score_section")
public class LandlordScoreSection {
    @Column(name = "section_info")
    private String sectionInfo;

    public String getSectionInfo() {
        return sectionInfo;
    }

    public void setSectionInfo(String sectionInfo) {
        this.sectionInfo = sectionInfo;
    }
}