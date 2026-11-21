package com.hbi.model;

import com.mybatisflex.annotation.Table;

@Table("t_record")
public class TRecord {
	
	private String id;

	private String sequences;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getSequences() {
		return sequences;
	}

	public void setSequences(String sequences) {
		this.sequences = sequences;
	}

}
