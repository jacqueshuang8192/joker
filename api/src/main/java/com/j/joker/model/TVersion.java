package com.j.joker.model;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_version")
public class TVersion {
    @Id
    private Long id;
    @Column("type")
    private String type;
    @Column("application_type")
    private String applicationType;
    @Column("game_id")
    private Long gameId;
    @Column("version")
    private String version;
    @Column("change_content")
    private String changeContent;
    @Column("update_url")
    private String updateUrl;
    @Column("is_manual")
    private Integer isManual;
    @Column("status")
    private String status;
    @Column("mani_url")
    private String maniUrl;
    @Column(ignore = true)
    private String code;

    @Column(ignore = true)
    private boolean isTreasureEnabled;

    public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getApplicationType() {
        return applicationType;
    }

    public void setApplicationType(String applicationType) {
        this.applicationType = applicationType;
    }

    public Long getGameId() {
        return gameId;
    }

    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getChangeContent() {
        return changeContent;
    }

    public void setChangeContent(String changeContent) {
        this.changeContent = changeContent;
    }

    public String getUpdateUrl() {
        return updateUrl;
    }

    public void setUpdateUrl(String updateUrl) {
        this.updateUrl = updateUrl;
    }

    public Integer getIsManual() {
        return isManual;
    }

    public void setIsManual(Integer isManual) {
        this.isManual = isManual;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean getIsTreasureEnabled() {
        return isTreasureEnabled;
    }

    public void setIsTreasureEnabled(boolean isTreasureEnabled) {
        this.isTreasureEnabled = isTreasureEnabled;
    }

    public String getManiUrl() {
        return maniUrl;
    }

    public void setManiUrl(String maniUrl) {
        this.maniUrl = maniUrl;
    }
}
