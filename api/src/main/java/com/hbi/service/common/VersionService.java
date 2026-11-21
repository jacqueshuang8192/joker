package com.hbi.service.common;

//import com.hbi.model.TDataVersion;
import org.apache.commons.lang.StringUtils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.TFreeGameRoundMapper;
import com.hbi.model.TFreeGameRound;
import com.hbi.model.TVersion;
import com.hbi.utils.InfServerException;

import java.applet.AppletContext;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

@Service
public class VersionService {

    @Autowired
    private BaseCacheController baseCacheController;
    
    @Autowired
    private TFreeGameRoundMapper freeGameRoundMapper;
    
    public TVersion queryNewestVersion(String type, String applicationType, String gameId) throws Exception {
        TVersion version = null;
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            if(Constants.VERSION_TYPE_APPLICATION.equals(type)) {
                if (StringUtils.isNotBlank(applicationType)) {
                    version = baseCacheController.queryNewestApplicationVersionByApplicationType(applicationType, cache);
                } else {
                    throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "应用类型不能为空");
                }
            } else if(Constants.VERSION_TYPE_GAME_HALL.equals(type)) {
                version = baseCacheController.queryNewestGameHallVersion(cache);
            } else if (Constants.VERSION_TYPE_GAME.equals(type)) {
                if (StringUtils.isNotBlank(gameId)) {
                    version = baseCacheController.queryNewestGameVersionByGameId(Long.parseLong(gameId), cache);
                } else {
                    throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "游戏ID不能为空");
                }
            } else {
                throw new InfServerException(Constants.RETURN_CODE_PARAM_ERROR, "类型错误");
            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
        
        return version;
    }

    public void downloadRecordsByLevel(int level) throws Exception {
        TVersion version = null;
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            
            List<TFreeGameRound> list = freeGameRoundMapper.queryUrlsByLevel(level);
            
            for (TFreeGameRound t : list) {
            	URL url = new URL("http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/" + t.getReplayUrl());    
                HttpURLConnection conn = (HttpURLConnection)url.openConnection();    
                        //设置超时间为3秒  
                conn.setConnectTimeout(3*1000);  
                //防止屏蔽程序抓取而返回403错误  
                conn.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 5.0; Windows NT; DigExt)");  
          
                //得到输入流  
                InputStream inputStream = conn.getInputStream();    
                //获取自己数组  
                byte[] getData = readInputStream(inputStream);      
          
                String[] strs = t.getReplayUrl().split("/");
                //文件保存位置  
                File saveDir = new File("E://" + level + File.separator + strs[0]);  
                if(!saveDir.exists()){  
                    saveDir.mkdir();  
                }  
                File file = new File(saveDir + File.separator + strs[1]);  
                
                if (!file.exists()) {
                	file.createNewFile();
                	
                	FileOutputStream fos = new FileOutputStream(file);       
                    fos.write(getData);   
                    if(fos!=null){  
                        fos.close();    
                    }  
                }
                
                
                if(inputStream!=null){  
                    inputStream.close();  
                }
            }
            
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
        
    }
    
    public static  byte[] readInputStream(InputStream inputStream) throws IOException {    
        byte[] buffer = new byte[1024];    
        int len = 0;    
        ByteArrayOutputStream bos = new ByteArrayOutputStream();    
        while((len = inputStream.read(buffer)) != -1) {    
            bos.write(buffer, 0, len);    
        }    
        bos.close();    
        return bos.toByteArray();    
    }
//    public TDataVersion queryDataVersion(String type) throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TDataVersion version = baseCacheController.queryDataVersion(type, cache);
//            return version;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<TDataVersion> queryAllDataVersion() throws Exception{
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<TDataVersion>  version = baseCacheController.queryDataVersions(cache);
//            return version;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if(cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
}
