package com.linkxin.douyouPlayer.vo;

import java.io.Serializable;

/**
 * 图片对象
 * @author lxy
 */
public class ImageItem implements Serializable
{
	private static final long serialVersionUID = -7188270558443739436L;
	public String imageId;
	public String thumbnailPath;
	public String sourcePath;
	public boolean isSelected = false;
	public boolean isupload =false;
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((imageId == null) ? 0 : imageId.hashCode());
		result = prime * result
				+ ((sourcePath == null) ? 0 : sourcePath.hashCode());
		result = prime * result
				+ ((thumbnailPath == null) ? 0 : thumbnailPath.hashCode());
		return result;
	}
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ImageItem other = (ImageItem) obj;
		if (imageId == null) {
			if (other.imageId != null)
				return false;
		} else if (!imageId.equals(other.imageId))
			return false;
		if (sourcePath == null) {
			if (other.sourcePath != null)
				return false;
		} else if (!sourcePath.equals(other.sourcePath))
			return false;
		if (thumbnailPath == null) {
			if (other.thumbnailPath != null)
				return false;
		} else if (!thumbnailPath.equals(other.thumbnailPath))
			return false;
		return true;
	}
	
	
}
