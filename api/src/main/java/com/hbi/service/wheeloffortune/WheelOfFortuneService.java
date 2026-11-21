package com.hbi.service.wheeloffortune;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.beanUtil.BeanMapUtils;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.cache.controller.WheelOfFortuneCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.TFortuneAddressMapper;
import com.hbi.mapper.TFortuneRecordMapper;
import com.hbi.mapper.TUserMapper;
import com.hbi.model.TFortuneAddress;
import com.hbi.model.TFortuneRecord;
import com.hbi.utils.InfServerException;
import com.hbi.vo.request.common.TAdvertVo;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

/**
 * Created by dzesla on 2017/2/17.
 */
@Service
public class WheelOfFortuneService {
    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private TFortuneRecordMapper fortuneRecordMapper;
    @Autowired
    private TFortuneAddressMapper fortuneAddressMapper;
    @Autowired
    private WheelOfFortuneCacheController fortuneCacheController;

    public String queryAwardList() throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String result = baseCacheController.queryConfig(Constants.WHEEL_OF_FORTUNE, cache);
            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }

    }

    public TFortuneRecord roll(Long userId) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            boolean canRoll = fortuneCacheController.checkAndSetRollTime(userId, cache);
            if (!canRoll) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "剩余次数不足，无法抽奖");
            }
            String jsonStr  = queryAwardList();
            JSONArray array = JSONArray.parseArray(jsonStr);
            int[] result    = getAwardPoint(array);
            if (result.length > 0) {
                int id = rollByArray(result);
                TFortuneRecord record = receiveAwardById(userId, id, array, cache);
                return record;
            } else {
                return null;
            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void bindAddress(Long userId, Long addressId, Long fortuneRecordId) {
        TFortuneRecord record = fortuneRecordMapper.selectByPrimaryKey(fortuneRecordId);
        if (record == null) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "奖品记录不存在");
        }
        if (!record.getUserId().equals(userId)) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "非获奖玩家");
        }
        TFortuneAddress address = fortuneAddressMapper.selectByPrimaryKey(addressId);
        if (address == null) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "地址信息不存在");
        }
        if (!address.getUserId().equals(userId)) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "地址信息与玩家信息不匹配");
        }
        record.setAddress(address.getAddress());
        record.setPhone(address.getPhone());
        fortuneRecordMapper.updateByPrimaryKey(record);
    }

    public void addAddress(Long userId, String userName, String phone, String address) {
        TFortuneAddress fortuneAddress = new TFortuneAddress();
        fortuneAddress.setUserId(userId);
        fortuneAddress.setAddress(address);
        fortuneAddress.setUserName(userName);
        fortuneAddress.setPhone(phone);
        fortuneAddressMapper.insert(fortuneAddress);
    }

    public void deleteAddress(Long userId, Long addressId) {
        TFortuneAddress address = new TFortuneAddress();
        address.setUserId(userId);
        address.setId(addressId);
        if (fortuneAddressMapper.selectCount(address) != 1) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "删除地址失败！");
        }
        fortuneAddressMapper.deleteByPrimaryKey(addressId);
    }

    public List<TFortuneAddress> queryAddress(Long userId) {
        TFortuneAddress fortuneAddress = new TFortuneAddress();
        fortuneAddress.setUserId(userId);
        return fortuneAddressMapper.select(fortuneAddress);
    }

    /**
     * 传入奖品的JSONArray，生成几率下标点。
     * 如传入的奖品概率是0.5,0.3,0.2，则返回值为[500,800,1000]
     * @param array
     * @return
     */
    private int[] getAwardPoint(JSONArray array) {
        int[] result = new int[array.size()];
        int sum = 0;
        for (int i = 0; i < array.size(); i++) {
            JSONObject json = (JSONObject)array.get(i);
            result[json.getInteger("id")] = (int)(sum + json.getFloat("rate") * 1000);
            sum = result[json.getInteger("id")];
        }
        return result;
    }

    private int rollByArray(int[] points) {
        int point = RandomUtils.nextInt(points[points.length - 1]);
        for (int i = 0; i < points.length; i++) {
            if (point > points[i]) {
                continue;
            }
            return i;
        }
        return 0;
    }

    private TFortuneRecord receiveAwardById(Long userId, int id, JSONArray array, ICache cache) {
        if (id == 0) {
            TFortuneRecord record = new TFortuneRecord();
            record.setFortuneId(new Long(id));
            return record;
        }
        JSONObject json  = getJsonById(id, array);
        String     type  = json.getString("type");
        Integer    count = json.getInteger("count");
        String     name  = json.getString("name");
        if (StringUtils.isNotBlank(type)) {
            TFortuneRecord record = new TFortuneRecord();
            record.setUserId(userId);
            record.setFortuneId(new Long(id));
            record.setType(type);
            record.setCount(count);
            record.setFortuneName(name);
            record.setDate(new Date());
            if (type.equalsIgnoreCase("card")) { //抽中房卡
                userMapper.increaseRoomCard(userId, count);
                record.setStatus(Constants.CONFIRMED);
            } else if (type.equalsIgnoreCase("object")) { //实物
                record.setStatus(Constants.NOT_SEND);
            } else if (type.equalsIgnoreCase("again")) { //再来一次，不写入中奖历史
                fortuneCacheController.cleanRollTime(userId, cache);
                record.setStatus(Constants.CONFIRMED);
                return record;
            }
            fortuneRecordMapper.insert(record);
            return record;
        }
        return null;
    }

    private JSONObject getJsonById(int id, JSONArray array) {
        for (int i = 0; i < array.size(); i++) {
            JSONObject json = (JSONObject)array.get(i);
            if (json.getInteger("id") == id) {
                return json;
            }
        }
        return null;
    }

    public List<TFortuneRecord> queryWinHistory(Long userId) {
        return fortuneRecordMapper.queryRecord(userId);
    }

    public String getAdvertList() throws Exception {
        String ad = "T_ADVERT_LUNBOTU";
        List<TAdvertVo> advertList = null;
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String s = cache.get(ad);
            if (StringUtils.isNotEmpty(s) ) {
                return s;
            }else {
                advertList = fortuneAddressMapper.getAdvertList();
                JSONObject object = new JSONObject();
                for (TAdvertVo list: advertList) {
                    object.put(list.getPhotoUrl(), StringUtils.isEmpty(list.getVisitUrl())? "":list.getVisitUrl());
                }
                cache.set(ad,object.toJSONString());
                return object.toJSONString();
            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }


    }
}
