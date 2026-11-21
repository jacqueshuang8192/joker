package com.hbi.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;

import com.core.util.ConfigUtil;

public class SendSmsUtil {
    private static String x_id = ConfigUtil.get("sms.id");
    private static String x_pwd = ConfigUtil.get("sms.pwd");
    
    public static String sendSms(String mobile, String content)
            throws UnsupportedEncodingException {
        HttpURLConnection httpconn = null;
        String result = "-20";
        StringBuilder sb = new StringBuilder();
        sb.append("http://service.winic.org/sys_port/gateway/?");
        sb.append("id=").append(x_id);
        sb.append("&pwd=").append(x_pwd);
        sb.append("&to=").append(mobile);
        content += "（兜游手机动态码，请完成验证），如非本人操作，请忽略本短信。";
        sb.append("&content=").append(URLEncoder.encode(content, "gb2312"));
        try {
            URL url = new URL(sb.toString());
            httpconn = (HttpURLConnection) url.openConnection();
            BufferedReader rd = new BufferedReader(new InputStreamReader(
                    httpconn.getInputStream()));
            result = rd.readLine();
            rd.close();
        } catch (MalformedURLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } finally {
            if (httpconn != null) {
                httpconn.disconnect();
                httpconn = null;
            }

        }
        return result;
    }
}
