/**
 * 
 */
package com.hbi.utils;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.URL;
import java.util.Date;
import com.aliyun.oss.OSSClient;
import com.aliyun.oss.model.ObjectMetadata;
import com.aliyun.oss.model.PutObjectResult;
import com.core.util.ConfigUtil;

/**
 * @author nate
 *
 */
public class OSSUtil {

	private static String endpoint = null;
	private static String accessKeyId = null;
	private static String accessKeySecret = null;
	private static String domain = null;
	static{
		endpoint = ConfigUtil.get("oss.endpoint");
		accessKeyId = ConfigUtil.get("oss.accessKeyId");
		accessKeySecret = ConfigUtil.get("oss.accessKeySecret");
		domain = ConfigUtil.get("oss.domain");
	}

	/**
	 * 简单的上传功能
	 * @param content 文件内容
	 * @param fileName 文件名，oss规则是无文件夹，全是object
	 * @param bucketName oss bucket
	 * @throws Exception
	 */
	public static void simpleUpload(String content, String fileName,String bucketName) throws Exception {
		OSSClient client = new OSSClient(endpoint, accessKeyId, accessKeySecret);
		try {
			client.putObject(bucketName, fileName, new ByteArrayInputStream(content.getBytes()));
		} catch (Exception e) {
			throw e;
		}finally{
			client.shutdown();
		}
		
	}

	public static String getSignedUrl(String bucketName,String fileName,Date expiration) throws Exception{
		OSSClient client = new OSSClient(endpoint, accessKeyId, accessKeySecret);
		URL url = null;
		try {
			url = client.generatePresignedUrl(bucketName, fileName, expiration);
		} catch (Exception e) {
//			OSSObject object = client.getObject(bucketName, fileName);
//			object.
			throw e;
		}finally{
			client.shutdown();
		}
		return url.toString();
	}
	
	public static String getFullyHttpUrl(String fileName){
		return OSSUtil.domain+fileName;
	}
	
	public static void main(String[] args) throws Exception {
		System.out.println(endpoint);
		System.out.println(accessKeyId);
		System.out.println(accessKeySecret);
		Date expiration = new Date(new Date().getTime() + 3600 * 1000);

		OSSClient client = new OSSClient(endpoint, accessKeyId, accessKeySecret);

		URL url = client.generatePresignedUrl("lepaihui", "filename", expiration);	
		System.out.println(url);
		System.out.println(getFullyHttpUrl("filename"));
		
		
//		OSSUtil.simpleUpload("123123", CommonUtil.dateFormat(new Date(), "yyyyMM") + "/" + "1",ConfigUtil.get("oss.bucketName.replay"));
		// /*
		// * Constructs a client instance with your account for accessing OSS
		// */

		// accessKeySecret);
		//
		// try {
		//
		// /**
		// * Note that there are two ways of uploading an object to your bucket,
		// the one
		// * by specifying an input stream as content source, the other by
		// specifying a file.
		// */
		//
		// /*
		// * Upload an object to your bucket from an input stream
		// */
		// System.out.println("Uploading a new object to OSS from an input
		// stream\n");
		// String content = "Thank you for using Aliyun Object Storage Service";
		// client.putObject(bucketName, key, new
		// ByteArrayInputStream(content.getBytes()));
		//
		// /*
		// * Upload an object to your bucket from a file
		// */
		// System.out.println("Uploading a new object to OSS from a file\n");
		// client.putObject(new PutObjectRequest(bucketName, key,
		// createSampleFile()));
		//
		// /*
		// * Download an object from your bucket
		// */
		// System.out.println("Downloading an object");
		// OSSObject object = client.getObject(new GetObjectRequest(bucketName,
		// key));
		// System.out.println("Content-Type: " +
		// object.getObjectMetadata().getContentType());
		// displayTextInputStream(object.getObjectContent());
		//
		// } catch (OSSException oe) {
		// System.out.println("Caught an OSSException, which means your request
		// made it to OSS, "
		// + "but was rejected with an error response for some reason.");
		// System.out.println("Error Message: " + oe.getErrorCode());
		// System.out.println("Error Code: " + oe.getErrorCode());
		// System.out.println("Request ID: " + oe.getRequestId());
		// System.out.println("Host ID: " + oe.getHostId());
		// } catch (ClientException ce) {
		// System.out.println("Caught an ClientException, which means the client
		// encountered "
		// + "a serious internal problem while trying to communicate with OSS, "
		// + "such as not being able to access the network.");
		// System.out.println("Error Message: " + ce.getMessage());
		// } finally {
		// /*
		// * Do not forget to shut down the client finally to release all
		// allocated resources.
		// */
		// client.shutdown();
		// }
	}

	private static File createSampleFile() throws IOException {
		File file = File.createTempFile("oss-java-sdk-", ".txt");
		file.deleteOnExit();

		Writer writer = new OutputStreamWriter(new FileOutputStream(file));
		writer.write("abcdefghijklmnopqrstuvwxyz\n");
		writer.write("0123456789011234567890\n");
		writer.close();

		return file;
	}

	public static String uploadObject2OSS(InputStream is,String fileName,Long fileSize,String bucketName,String folder) throws Exception {
		OSSClient client = new OSSClient(endpoint, accessKeyId, accessKeySecret);
		String resultStr = null;
		try {
			ObjectMetadata metadata = new ObjectMetadata();
			//上传的文件的长度
			metadata.setContentLength(is.available());
			//指定该Object被下载时的网页的缓存行为  
			metadata.setCacheControl("no-cache");
			//指定该Object下设置Header  
			metadata.setHeader("Pragma", "no-cache");
			//指定该Object被下载时的内容编码格式
			metadata.setContentEncoding("utf-8");
			//文件的MIME，定义文件的类型及网页编码，决定浏览器将以什么形式、什么编码读取文件。如果用户没有指定则根据Key或文件名的扩展名生成，  
			//如果没有扩展名则填默认值application/octet-stream  
			metadata.setContentType(getContentType(fileName));
			//指定该Object被下载时的名称（指示MINME用户代理如何显示附加的文件，打开或下载，及文件名称）  
			metadata.setContentDisposition("filename/filesize=" + fileName + "/" + fileSize + "Byte.");
			//上传文件   (上传文件流的形式)  
			PutObjectResult putResult = client.putObject(bucketName, folder + fileName, is, metadata);
			//解析结果  
			resultStr = putResult.getETag();
		}catch (Exception e ) {
			throw e;
		}finally {
			client.shutdown();
		}
		return resultStr;

	}

	/**
	      * 通过文件名判断并获取OSS服务文件上传时文件的contentType
	      * @param fileName 文件名
	      * @return 文件的contentType
	      */
	public static String getContentType(String fileName){
		//文件的后缀名  
		String fileExtension = fileName.substring(fileName.lastIndexOf("."));
		if(".bmp".equalsIgnoreCase(fileExtension)) {
			return "image/bmp";
		}
		if(".gif".equalsIgnoreCase(fileExtension)) {
			return "image/gif";
		}
		if(".jpeg".equalsIgnoreCase(fileExtension) || ".jpg".equalsIgnoreCase(fileExtension) || ".png".equalsIgnoreCase(fileExtension)){
			return "image/jpeg";
		}
		if(".html".equalsIgnoreCase(fileExtension)) {
			return "text/html";
		}
		if(".txt".equalsIgnoreCase(fileExtension)) {
			return "text/plain";
		}
		if(".vsd".equalsIgnoreCase(fileExtension)) {
			return "application/vnd.visio";
		}
		if(".ppt".equalsIgnoreCase(fileExtension) || "pptx".equalsIgnoreCase(fileExtension)) {
			return "application/vnd.ms-powerpoint";
		}
		if(".doc".equalsIgnoreCase(fileExtension) || "docx".equalsIgnoreCase(fileExtension)) {
			return "application/msword";
		}
		if(".xml".equalsIgnoreCase(fileExtension)) {
			return "text/xml";
		}
		//默认返回类型  
		return "image/jpeg";
	}


	private static void displayTextInputStream(InputStream input) throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(input));
		while (true) {
			String line = reader.readLine();
			if (line == null)
				break;

			System.out.println("\t" + line);
		}
		System.out.println();

		reader.close();
	}

}
