package com.hbi.model;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;

@Table("t_ad")
public class TAd {
    @Id
    private Long id;

    private String name;
    
    private String url;

    private String link;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }
}