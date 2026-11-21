package com.hbi.model;

import javax.persistence.Id;
import javax.persistence.Table;
import java.util.Date;

/**
 * Created by dzesla on 2017/2/16.
 */
@Table
public class TFeedback {
    @Id
    private Long id;

    private Long userId;

    private String content;

    private Date date;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}
