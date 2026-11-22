package com.j.joker.core.util;

import com.j.joker.core.constants.ErrorConstants;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.*;

public class Base64Util {
    // The original encoder terminates each full 57-byte input line, including the last.
    static String encodeLines(byte[] data) {
        String result = java.util.Base64.getMimeEncoder(76, new byte[] {10}).encodeToString(data);
        return data.length > 0 && data.length % 57 == 0 ? result + "\n" : result;
    }

	private static Logger logger = Logger.getLogger(Base64Util.class);
	
    //图片转化成base64字符串
    public static String getImageStr(String imgFile)
    {
        InputStream in = null;
        byte[] data = null;
        //读取图片字节数组
        try 
        {
            in = new FileInputStream(imgFile);        
            data = new byte[in.available()];
            in.read(data);
            in.close();
        } 
        catch (IOException e) 
        {
        	logger.error(e.getMessage());
        	return "";
        }
        //对字节数组Base64编码
        return Base64Util.encodeLines(data);//返回Base64编码过的字节数组字符串
    }
    
	/**
	 * base64字符串转换InputStream
	 * @param base64Str
	 * @return
	 * @throws Exception
	 */
	public static ByteArrayInputStream base642InputStream(String base64Str)
			throws Exception {
		if (StringUtils.isBlank(base64Str)) {
			throw new Exception(ErrorConstants.BASE64_IS_EMPTY_ERROR);
		}
		base64Str = base64Str.replaceAll(" ", "\\+");
		// input byte base64
		java.util.Base64.Decoder decoder = java.util.Base64.getMimeDecoder();
		byte[] cb = decoder.decode(base64Str);
		ByteArrayInputStream in = new ByteArrayInputStream(cb);
		return in;
	}
	/**
	 * base64再生成图片
	 * @param base64Str
	 * @param fileName
	 * @return
	 */
	  public static boolean generateImage(String base64Str,String filePath,String fileName)
	    {   //对字节数组字符串进行Base64解码并生成图片
	        if (StringUtils.isBlank(base64Str)) //图像数据为空
	            return false;
	        java.util.Base64.Decoder decoder = java.util.Base64.getMimeDecoder();
	        try 
	        {
	        	base64Str = base64Str.replaceAll(" ", "\\+");
	            //Base64解码
	            byte[] b = decoder.decode(base64Str);
	           /* //生成图片
	            //String imgFilePath = "C://Users//apple//Desktop//222.png";
	            OutputStream out = new FileOutputStream(fileName);    
	            out.write(b);
	            out.flush();
	            out.close();*/
                File dir = new File(filePath);  
                if(!dir.exists()){//判断文件目录是否存在  
                    dir.mkdirs();  
                }  
                logger.warn("文件路径:"+filePath+"/"+fileName);
                OutputStream out = new FileOutputStream(filePath+"/"+fileName);    
	            out.write(b);
	            out.flush();
	            out.close();
	            
              /*  file = new File(filePath+"\\"+fileName);  
                logger.warn("文件名称:"+filePath+"\\"+fileName);
                fos = new FileOutputStream(file);  
                bos = new BufferedOutputStream(fos);  
                bos.write(b);  */
	                
	            return true;
	        } 
	        catch (Exception e) 
	        {
	        	logger.error(e.getMessage());
	            return false;
	        }
	    }
}
