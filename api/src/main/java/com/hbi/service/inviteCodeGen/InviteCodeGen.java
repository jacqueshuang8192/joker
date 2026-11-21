package com.hbi.service.inviteCodeGen;

import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.redis.RedisLock;
import com.hbi.constants.Constants;
import com.hbi.mapper.TConfigMapper;
import com.hbi.model.TConfig;
import com.hbi.utils.InfServerException;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by ceeuoo on 6/14/2016.
 */
@Service
public class InviteCodeGen {
//    public int generateCode(){
//        return RandomUtils.nextInt(9999);
//    }
    private static final String INVITE_CODE_KEY = "INVITE_CODE";

    @Autowired
    private TConfigMapper configMapper;

    public String getCode() throws Exception{
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String key = INVITE_CODE_KEY;
            if (lock()) {
                try {
                    if (cache.llen(key) < 1000) {
                        generateCode(cache);
                    }
                    
                    return cache.lpop(key);
                } catch (Exception e) {
                    throw e;
                } finally {
                    unlock();
                }
            }
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "获取邀请码失败！");
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    private void generateCode(ICache cache){
        String index = "100";
        TConfig config = new TConfig();
        config.setK("inviteCodeIndex");
        List<TConfig> list = configMapper.select(config);
        if (CollectionUtils.isNotEmpty(list)) {
            config = list.get(0);
            index = config.getV();
            Integer next = Integer.parseInt(index) + 1;
            config.setV(next.toString());
            configMapper.updateByPrimaryKeySelective(config);
        }
        for (int i = 0; i < 9999; i++) {
            String str = String.format("%0"+4+"d", i);
            str = index + str;
            
                cache.rpush(INVITE_CODE_KEY, str);
            
        }
    }

    private boolean filter(String code) {
        int[] result = parse(code);
        if (result[0] >= 1) {
            return false;
        } else if (result[1] >= 1) {
            return false;
        }
        return true;
    }

    private int[] parse(String code) {
        List<Integer> list = new ArrayList<Integer>();
        for (int i = 0; i < code.length(); i++) {
            String s = code.substring(i, i+1);
            Integer it = Integer.parseInt(s);
            list.add(it);
        }
        return parse(list);
    }

    private int[] parse(List<Integer> list) {
        int[] strs = new int[2];
        int same = 0;
        int consecutive = 0; //连号
        for (int i = 1; i < list.size(); i++) { //对比相邻两个数字
            if (list.get(i - 1).equals(list.get(i))) {
                same ++;
            }
        }

        for (int i = 2; i < list.size(); i++) { //对比相邻两个数字
            if(list.get(i - 1) - list.get(i - 2) == list.get(i) - list.get(i - 1)) {
                consecutive++;
            }
        }
        strs[0] = same;
        strs[1] = consecutive;
        return strs;
    }

    public static void main(String[] s) {
//        InviteCodeGen gen = new InviteCodeGen();
//        int count = 0;
//        for (int i = 0; i < 9999; i++) {
//            String str = String.format("%0"+4+"d", i);
//            str = 1 + str;
//            if (gen.filter(str)) {
//                count++;
//                System.out.println(str);
//            }
//        }
//        System.out.println(count);
    }

    private boolean lock() {
        String key = INVITE_CODE_KEY;
        RedisLock lock = new RedisLock(key);
        return lock.lock(1000 * 5); // 等待超时时间5秒
    }

    private void unlock() {
        String key = INVITE_CODE_KEY;
        RedisLock lock = new RedisLock(key);
        lock.unlock();
    }
}
