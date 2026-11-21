package com.hbi.utils;

import java.net.SocketTimeoutException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.constants.Constants;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import com.alibaba.fastjson.JSONObject;
import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class EaseMobUtil {
    private static final String EASEMOB_TIME_OUT_QUEUE_KEY = "EASEMOB_TIME_OUT_QUEUE";

    public static JsonNode getResponse(String path, JSONObject objectNode, List<NameValuePair> headers) throws Exception{
        if(headers == null) {
            headers = new ArrayList<NameValuePair>();
        }
        headers.add(new BasicNameValuePair("Content-Type", "application/json"));
        HttpPost httpPost = new HttpPost();
        URL url = new URL("http", "a1.easemob.com", path);
        httpPost.setURI(url.toURI());
        
        for (NameValuePair nameValuePair : headers) {
            httpPost.addHeader(nameValuePair.getName(), nameValuePair.getValue());
        }
        httpPost.setEntity(new StringEntity(objectNode.toString(), "UTF-8"));
        RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(8000).setConnectTimeout(8000).build();
        httpPost.setConfig(requestConfig);
        HttpClient httpClient = new DefaultHttpClient();
        ICache cache = null;
        try {
            HttpResponse tokenResponse = httpClient.execute(httpPost);
            HttpEntity entity = tokenResponse.getEntity();

            String results = EntityUtils.toString(entity, "UTF-8");

            ObjectMapper mapper = new ObjectMapper();

            JsonFactory factory2 = mapper.getJsonFactory();
            JsonParser jp = factory2.createJsonParser(results);
            JsonNode json = mapper.readTree(jp);

            return json;
        } catch (SocketTimeoutException se) {
            cache = CacheManager.getCache();
            if(cache != null) {
                JSONObject json = new JSONObject();
                json.put("time", new Date());
                json.put("exception", "SocketTimeoutException");
                json.put("type", "easemob");
                json.put("message", "环信消息发送超时");
                cache.rpush(EASEMOB_TIME_OUT_QUEUE_KEY, json.toJSONString());
            }
            se.printStackTrace();
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "环信消息发送超时");
        } catch (Exception e) {
            cache = CacheManager.getCache();
            if(cache != null) {
                JSONObject json = new JSONObject();
                json.put("time", new Date());
                json.put("exception", "Exception");
                json.put("type", "easemob");
                json.put("message", "环信消息发送失败");
                cache.rpush(EASEMOB_TIME_OUT_QUEUE_KEY, json.toJSONString());
            }
            e.printStackTrace();
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "环信消息发送失败");
        } finally {
            if(cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }
    
    public static JsonNode getPutResponse(String path, JSONObject objectNode, List<NameValuePair> headers) throws Exception{
        if(headers == null) {
            headers = new ArrayList<NameValuePair>();
        }
        headers.add(new BasicNameValuePair("Content-Type", "application/json"));
        HttpPut httpPut = new HttpPut();
        URL url = new URL("http", "a1.easemob.com", path);
        httpPut.setURI(url.toURI());
        
        for (NameValuePair nameValuePair : headers) {
            httpPut.addHeader(nameValuePair.getName(), nameValuePair.getValue());
        }
        httpPut.setEntity(new StringEntity(objectNode.toString(), "UTF-8"));
        
        HttpClient httpClient = new DefaultHttpClient();
        HttpResponse tokenResponse = httpClient.execute(httpPut);
        HttpEntity entity = tokenResponse.getEntity();

        String results = EntityUtils.toString(entity, "UTF-8");
        
        ObjectMapper mapper = new ObjectMapper();

        JsonFactory factory2 = mapper.getJsonFactory();
        JsonParser jp = factory2.createJsonParser(results);
        JsonNode json = mapper.readTree(jp);

        return json;
    }
    
    public static JsonNode getDeleteResponse(String path, JSONObject objectNode, List<NameValuePair> headers) throws Exception{
        if(headers == null) {
            headers = new ArrayList<NameValuePair>();
        }
        headers.add(new BasicNameValuePair("Content-Type", "application/json"));
        HttpDelete  httpDelete = new HttpDelete ();
        URL url = new URL("http", "a1.easemob.com", path);
        httpDelete.setURI(url.toURI());
        
        for (NameValuePair nameValuePair : headers) {
            httpDelete.addHeader(nameValuePair.getName(), nameValuePair.getValue());
        }
        
        HttpClient httpClient = new DefaultHttpClient();
        HttpResponse tokenResponse = httpClient.execute(httpDelete);
        HttpEntity entity = tokenResponse.getEntity();

        String results = EntityUtils.toString(entity, "UTF-8");
        
        ObjectMapper mapper = new ObjectMapper();

        JsonFactory factory2 = mapper.getJsonFactory();
        JsonParser jp = factory2.createJsonParser(results);
        JsonNode json = mapper.readTree(jp);

        return json;
    }
}
