package com.hbi.model;

import javax.persistence.*;

@Table(name = "t_service_information")
public class TServiceInformation {
    @Id
    @Column(name = "id")
    private Long id;

    @Id
    @Column(name = "content")
    private String content;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

    
}