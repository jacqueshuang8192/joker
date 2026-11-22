package com.j.joker.core.util;

import org.apache.commons.lang.StringUtils;

import com.j.joker.core.constants.YTConstants;

public class FileHelper {

	/**
	 * 根据base64字符/上传类型上传文件
	 * @param base64Str
	 * @param type
	 * @return
	 */
	public static String uploadFile(String base64Str,String type){
		String uploadSrc=ConfigUtil.get("upload.src");
		String suffix=ConfigUtil.get("upload.image.suffix", ".png");
		String name=RadomUtil.getCharAndNumr(10, YTConstants.RADOM_OUT_ALL);
		String filePrefix=YTConstants.TYPE_DEFAULT;
		if(StringUtils.isNotBlank(type)){
			filePrefix=type;
		}
		
		//文件名称
		String fileName=name+suffix;
		//文件路径
		String filePath=uploadSrc+filePrefix;
		//数据库路径
		String url=filePrefix+"/"+fileName;
		Boolean result= Base64Util.generateImage(base64Str, filePath,fileName);
		if(result){
			return url;
		}else{
			return "";
		}
	}
}
