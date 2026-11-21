package com.hbi.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Table;

/**
 * Created by ceeuoo on 8/13/2016.
 */
@Table("landlord_score_section")
public class LandlordScoreSection {
    @Column("section_info")
    private String sectionInfo;

    public String getSectionInfo() {
        return sectionInfo;
    }

    public void setSectionInfo(String sectionInfo) {
        this.sectionInfo = sectionInfo;
    }
}