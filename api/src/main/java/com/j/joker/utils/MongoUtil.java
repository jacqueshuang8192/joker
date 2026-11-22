package com.j.joker.utils;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.constants.Constants;
import com.mongodb.BasicDBList;
import com.mongodb.BasicDBObject;
import com.mongodb.CommandResult;
import com.mongodb.DBCollection;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;

public class MongoUtil {

    private static final Logger log = Logger.getLogger(MongoUtil.class);
    
    private static class ClientHolder {
        private static final MongoClient CLIENT = createClient();

        private static MongoClient createClient() {
            String uri = ConfigUtil.get("mongodb.uri");
            if (uri != null && !uri.isBlank()) {
                return new MongoClient(new MongoClientURI(uri));
            }
            return new MongoClient(ConfigUtil.get("mongodb.ip"), Integer.parseInt(ConfigUtil.get("mongodb.port")));
        }
    }

    public static MongoClient MongoInstance() {
        return ClientHolder.CLIENT;
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
