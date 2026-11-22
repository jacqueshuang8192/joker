package com.j.joker.schedule.utils;

import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.constants.Constants;
import com.j.joker.schedule.model.ScheduleJob;
import com.j.joker.utils.InfServerException;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by ceeuoo on 4/13/2016.
 */
public class ScheduleUtil {
    private static final String ENABLE_SCHEDULE_KEY = "ENABLE_SCHEDULE";

    private static final String DISABLE_SCHEDULE_KEY = "DISABLE_SCHEDULE";

    public static void invokeEnableScheduleServlet(ScheduleJob job) throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            cache.rpush(ENABLE_SCHEDULE_KEY, JSON.toJSONString(job));
//        } catch (Exception e) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "添加动态定时任务失败！");
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }

        try {
            String addr = ConfigUtil.get("schedule.ip");
            URL url = new URL("http://" + addr + "/quartz/schedule/updateDynamicSchedule");
            HttpPost post = new HttpPost();
            List<NameValuePair> params = new ArrayList<NameValuePair>();
            params.add(new BasicNameValuePair("job", JSONObject.toJSONString(job)));
            params.add(new BasicNameValuePair("type", "enable"));
            post.setURI(url.toURI());
            post.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));
            HttpClient httpClient = new DefaultHttpClient();
            HttpResponse tokenResponse = httpClient.execute(post);
            String result = EntityUtils.toString(tokenResponse.getEntity(), "UTF-8");
            if (result.indexOf("true") == -1) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "添加动态定时任务失败！");
            }
        } catch (Exception e) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getLocalizedMessage());
        }
    }

    public static void invokeRemoveScheduleServlet(String jobId, String jobGroup) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            ScheduleJob job = new ScheduleJob();
//            job.setJobId(jobId);
//            job.setJobGroup(jobGroup);
//            cache.rpush(DISABLE_SCHEDULE_KEY, JSON.toJSONString(job));
//        } catch (Exception e) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, "移除动态定时任务失败！");
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }

        ScheduleJob job = new ScheduleJob();
        job.setJobId(jobId);
        job.setJobGroup(jobGroup);
        String addr = ConfigUtil.get("schedule.ip");
        URL url = new URL("http://" + addr + "/quartz/schedule/updateDynamicSchedule");
        HttpPost post = new HttpPost();
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("job", JSONObject.toJSONString(job)));
        params.add(new BasicNameValuePair("type", "remove"));
        post.setURI(url.toURI());
        post.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));
        HttpClient httpClient = new DefaultHttpClient();
        HttpResponse tokenResponse = httpClient.execute(post);
        String result = EntityUtils.toString(tokenResponse.getEntity(), "UTF-8");
        if (result.indexOf("true") == -1) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "移除动态定时任务失败！");
        }
    }
}
