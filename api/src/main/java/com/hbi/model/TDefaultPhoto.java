package com.hbi.model;

import javax.persistence.Id;
import javax.persistence.Table;

/**
 * Created by ceeuoo on 6/28/2016.
 */
@Table(name = "t_default_photo")
public class TDefaultPhoto {
    @Id
    private Long id;

    private String photo;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }
}
