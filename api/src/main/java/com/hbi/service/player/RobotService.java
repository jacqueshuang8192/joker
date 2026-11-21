//package com.hbi.service.player;
//
//import com.codeborne.geoip.Location;
//import com.codeborne.geoip.LookupService;
//import com.core.util.ConfigUtil;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.RobotMapper;
//import com.hbi.model.TRobotInfo;
//import com.hbi.utils.InfServerException;
//import com.hbi.utils.yeepay.HttpClient4Utils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import java.io.*;
//import java.util.List;
//
//@Service
//public class RobotService {
//    @Autowired
//    private RobotMapper robotMapper;
//
//    public void updateJWD() {
//
//
//        try {
//            LookupService cl = new LookupService("D:/project/GeoLiteCity.dat", LookupService.GEOIP_MEMORY_CACHE);
//
//            TRobotInfo tRobotInfo = new TRobotInfo();
//            List<TRobotInfo> select = robotMapper.select(tRobotInfo);
//            for (TRobotInfo info : select) {
//                Location location = cl.getLocation(info.getIp());
////                System.out.println(
////                        "countryCode: " + location.countryCode +"\n"+
////                                "countryName: " + location.countryName +"\n"+
////                                "region: " + location.region +"\n"+
////                                "city: " + location.city +"\n"+
////                                "latitude: " + location.latitude +"\n"+
////                                "longitude: " + location.longitude);
//                System.out.println(location.latitude +"xxxx");
//                info.setLatitude(location.latitude + "");
//                info.setLongitude(location.longitude +"");
//                robotMapper.updateByPrimaryKey(info);
//            }
//        } catch (Exception e) {
//            System.out.println(e.getMessage());
//            throw new InfServerException(Constants.RETURN_CODE_FAIL,"网络异常!!");
//        }finally {
//
//        }
//
//    }
//
//    public void verifyIp() throws IOException, InterruptedException {
//        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(new File("D:/ip.txt"))));
//
//        StringBuffer stringBuffer = new StringBuffer();
//        StringBuffer advices = new StringBuffer();
//        while (br.ready()) {
//            stringBuffer.append(br.readLine());
//        }
//        String[] ips = stringBuffer.toString().split(" ");
//
//        LookupService cl = new LookupService("D:/project/GeoLiteCity.dat", LookupService.GEOIP_MEMORY_CACHE);
//
//        TRobotInfo robotInfo = new TRobotInfo();
//        for (int i = 0; i <ips.length ; i++) {
//            String url = "http://www.ip138.com/ips138.asp?ip="+ips[i]+"&action=2";
//            String s = HttpClient4Utils.httpGet(url, null, "gbk", 100);
//            String sub = "</li><li>参考数据1：";
//            int b = s.indexOf(sub);
//            String substring = s.substring(b + sub.length());
//            advices.append(substring.substring(0,4)).append("   ").append(ips[i]).append("  ");
//            Location location = cl.getLocation(ips[1]);
//
//            robotInfo.setIp(ips[i]);
//            robotInfo.setLongitude(location.longitude + "");
//            robotInfo.setLatitude(location.latitude + "");
//
//            robotMapper.insert(robotInfo);
//        }
//
//
//        System.out.println(advices);
//
//    }
//
//    public void addRobotinfo() throws Exception{
//
//        //获取一批IP地址
//        String ipfile = ConfigUtil.get("IPFILE"); //ip地址为 .txt文件  以空格( )隔离各个IP地址
//        String jwdfile = ConfigUtil.get("JWDFILE"); //GeoLiteCity.dat  由geolite公司提供的一个旧的Ip地址对应的经纬度文件
//
//        LookupService cl = new LookupService(jwdfile, LookupService.GEOIP_MEMORY_CACHE);
//        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(new File(ipfile))));
//
//        StringBuffer stringBuffer = new StringBuffer();
//        StringBuffer advices = new StringBuffer();
//        while (br.ready()) {
//            stringBuffer.append(br.readLine());
//        }
//        String[] ips = stringBuffer.toString().split(" ");
//
//
//        TRobotInfo robotInfo = new TRobotInfo();
//
//        for (int i =0; i<ips.length ; i ++) {
//            //地址对象
//            Location location = cl.getLocation(ips[i]);
//            int rd = Math.random() > 0.5 ? 1 : 0;
//            robotInfo.setSex(rd);
//            robotInfo.setIp(ips[i]);
//            robotInfo.setLatitude(location.latitude + "");
//            robotInfo.setLongitude(location.longitude + "");
//            robotMapper.insert(robotInfo);
//        }
//
//    }
//}
