package com.hbi.model;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

/**
 * Created by ceeuoo on 6/28/2016.
 */
@Table("t_default_photo")
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
