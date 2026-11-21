package com.hbi.utils;

import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import com.alibaba.fastjson.JSONObject;
import com.core.util.ConfigUtil;
import com.hbi.constants.Constants;
import com.mongodb.BasicDBList;
import com.mongodb.BasicDBObject;
import com.mongodb.CommandResult;
import com.mongodb.DBCollection;
import com.mongodb.MongoClient;

public class MongoUtil {

    private static final Logger log = Logger.getLogger(MongoUtil.class);
    
    private static MongoClient mongoClient = null;
    private static String MONGODB_IP;
    private static int MONGODB_PORT;

    static {
        // 读取相关的配置
        MONGODB_IP = ConfigUtil.get("mongodb.ip");
        MONGODB_PORT = Integer.parseInt(ConfigUtil.get("mongodb.port"));
    }

    /**
     * 获取实例
     * @return
     * @throws UnknownHostException
     */
    public static MongoClient MongoInstance() {
        if (null == mongoClient) {
            mongoClient = new MongoClient(MONGODB_IP, MONGODB_PORT);
        }
        return mongoClient;
    }
    
    public static DBCollection getCollection() {
        return MongoInstance().getDB("douyoudb").getCollection("douyoudb");
    }
    
    public static void updateLocation(final double[] pLocation, long userid) {
        DBCollection dc = getCollection();
        final BasicDBObject loc = new BasicDBObject();
        JSONObject obj = new JSONObject();
        obj.put("coordinates", pLocation);
        obj.put("type", "Point");
        loc.put("loc", obj);
        loc.put("_id", userid);
        dc.update(new BasicDBObject("_id", userid), loc, true,
                false);
    }
    
    public static List<Long> queryUsersByLocation(double longitude, double latitude) throws Exception {
        double[] loc = { longitude, latitude };
        BasicDBObject myCmd = new BasicDBObject();
        myCmd.append("geoNear", "douyoudb");
        myCmd.append("near", loc);
        myCmd.append("num", 10);
        CommandResult myResults = MongoInstance().getDB("douyoudb").command(myCmd); 
        BasicDBList result = (BasicDBList) myResults.get("results");
        if(result == null) {
            throw new Exception(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR);
        }
        BasicDBList list = (BasicDBList) myResults.get("results");
        List<Long> resultList = new ArrayList<Long>();
        for(Object basicDBObject : list) {
            Object obj = ((BasicDBObject)basicDBObject).get("obj");
            obj = ((BasicDBObject)obj).get("_id");
            resultList.add((Long) obj);
        }
        return resultList;
    }
}
