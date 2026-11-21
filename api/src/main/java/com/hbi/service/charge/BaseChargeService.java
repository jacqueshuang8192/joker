package com.hbi.service.charge;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.core.beanUtil.MapUtils;
import com.core.util.ConfigUtil;
import com.core.util.RedisUtil;
import com.core.util.StringUtil;
import com.hbi.cache.CacheManager;
import com.hbi.cache.ICache;
import com.hbi.cache.controller.BaseCacheController;
import com.hbi.constants.Constants;
import com.hbi.mapper.*;
import com.hbi.model.*;
import com.hbi.service.common.GoodsService;
import com.hbi.service.common.UserService;
import com.hbi.utils.GameServerUtil;
import com.hbi.utils.InfServerException;
import com.hbi.vo.request.common.CommissionVo;
import com.hbi.vo.response.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tk.mybatis.mapper.entity.Example;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Array;
import java.net.Socket;
import java.util.*;

/**
 * Created by dzesla on 2017/2/15.
 */
@Service
public class BaseChargeService {

    @Autowired
    private TAccountChargeMapper accountChargeMapper;
    @Autowired
    private TUserMapper userMapper;
    @Autowired
    private BaseCacheController baseCacheController;
    @Autowired
    private GoodsService goodsService;
    @Autowired
    private TSecUserMapper secUserMapper;
    @Autowired
    private TRechargeTiChengFlowMapper tichengFlowMapper;
    @Autowired
    private TChargePoolMapper poolMapper;
    @Autowired
    private ImsTpOrdersMapper imsTpOrdersMapper;

    private static final String GAME_SERVER_IP = ConfigUtil.get("game.ip");
    private static final String GAME_SERVER_port = ConfigUtil.get("game.port");

    private static final String USER_SERVER_IP = ConfigUtil.get("userServer.ip");

    public void payOrderCallbackTest(String orderId) throws Exception {
        ICache cache = null;
        try {
        	System.out.println("开始");
            cache = CacheManager.getCache();
            TAccountCharge accountCharge = new TAccountCharge();
            accountCharge.setChargeOrder(orderId);
            accountCharge = accountChargeMapper.selectOne(accountCharge);
            if (accountCharge == null || !accountCharge.getStatus().equalsIgnoreCase(Constants.PAY_TO_BE_CONFIRMED)) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "订单不存在");
            }
            TAccountCharge change = new TAccountCharge();
            change.setStatus(Constants.PAY_SUCCESS);
            change.setChargeDate(new Date());
            Example example = new Example(TAccountCharge.class);
            Example.Criteria criteria = example.createCriteria();
            System.out.println("criteria"+criteria);
            criteria.andEqualTo("chargeOrder", orderId);
            System.out.println("change"+change);
            System.out.println("example"+example);
            accountChargeMapper.updateByExampleSelective(change, example);

            //Double rate             = baseCacheController.getDoubleConfig("chargeSendPointRate", cache);
            ImsGoods goods            = goodsService.findImsGoodsById(accountCharge.getGoodsId());
            //Double point            = accountCharge.getRmbAmount() / 100 * rate;
            Integer count           = goods.getAmount();
            Long userId             = accountCharge.getUserId();
            //TUser user              = userMapper.selectByPrimaryKey(userId);
            //Long agentId            = user.getAgentId();
            //Integer chargeRmbAmount = accountCharge.getRmbAmount();
            //  充值的种类, 0:房卡  1:房卡
            //String type = goods.getCategoryType();
            //if ("0".equals(type)) {
            //    System.out.println("userId"+userId);
            //    System.out.println("roomCardCount"+count);
            //    userMapper.increaseRoomCard(userId, count);
            //    System.out.println("point"+point);
            //    poolMapper.increasePool(point);
            //    calcExtract(agentId, userId, 1, chargeRmbAmount, 1);
            //}
            ////如果是房卡场则去增加房卡
            //if ("1".equals(type)) {
                boolean flag = playerGoldRecharge(1, userId, count);
                //通知大厅服这个ID的人已经充值了
                try {
                    GameServerUtil.notice2GameServerGoldRec(userId,count);
                }catch (Exception e) {
                    System.out.println("发送刷新对面的玩家的房卡+"+e.getMessage());
                }
                System.out.println("房卡增加是否成功 : " + flag);

                //任务体系,统计玩家的充值房卡的数量
                userMapper.updateRecGoldCount(userId,count);
            //}






        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public void payOrderCallbackTest2(String orderId) throws Exception {
        ICache cache = null;
        try {
            System.out.println("开始");
            cache = CacheManager.getCache();
            ImsTpOrders imsTpOrders = new ImsTpOrders();
            imsTpOrders.setOrderNo(orderId);
            imsTpOrders = imsTpOrdersMapper.selectOne(imsTpOrders);
            if (imsTpOrders == null || !(imsTpOrders.getOrderstatus().intValue() == Integer.parseInt(Constants.PAY_CANCEL))) {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "订单不存在");
            }

            ImsTpOrders imsTpOrders1 = new ImsTpOrders();
            imsTpOrders1.setOrderstatus(Integer.parseInt(Constants.PAY_TO_BE_CONFIRMED));
            imsTpOrders1.setCallbackTime((System.currentTimeMillis()/1000)+"");

            //渠道费
            String commissiom = baseCacheController.queryConfig("commissiom", cache);
            if (StringUtil.isNotEmpty(commissiom)) {
                imsTpOrders1.setCommission(Integer.parseInt(commissiom));
                imsTpOrders1.setCommissionMoney((int) (imsTpOrders.getPrice()*Integer.parseInt(commissiom)));
            }
            Example example = new Example(ImsTpOrders.class);
            Example.Criteria criteria = example.createCriteria();
            System.out.println("criteria"+criteria);
            criteria.andEqualTo("orderNo", orderId);

            imsTpOrdersMapper.updateByExampleSelective(imsTpOrders1, example);

            ImsGoods goods            = goodsService.findImsGoodsById(Long.parseLong(imsTpOrders.getGoodsId().toString()));

            Integer count           = goods.getAmount();
            Long userId             = Long.parseLong(imsTpOrders.getPlayerId().toString());

            Integer goodType = imsTpOrders.getGoodType();
            //如果是房卡场则增加房卡
            if (goodType == 0 ) {
                String s = ConfigUtil.get("commission.type");
                if (StringUtil.isNotEmpty(s) && "1".equals(s)) {
                    //放入redis中,由后台小程序处理
                    lpupRedis(userId,imsTpOrders.getPrice()*100,count,orderId);
                    userMapper.updatePingTaiCard(count);
                    baseCacheController.updateRoomCard(userId,count);
                }else {
                    //查找三级代理
                    String agents = getSanJiAgent(userId);
                    baseCacheController.updateRoomCard(userId,count);
                    //插入记录
                    insertIntoImsTpCard(agents,imsTpOrders.getPrice()*100,userId);
                    userMapper.updatePingTaiCard(count);
                }

            }
            //如果是金币就去增加金币
            if(goodType == 1 ) {
                boolean flag = playerGoldRecharge(1, userId, count);
                //通知大厅服这个ID的人已经充值了
                try {
                    GameServerUtil.notice2GameServerGoldRec(userId,count);
                }catch (Exception e) {
                    System.out.println("发送刷新对面的玩家的房卡+"+e.getMessage());
                }
                System.out.println("房卡增加是否成功 : " + flag);

                //任务体系,统计玩家的充值房卡的数量
                userMapper.updateRecGoldCount(userId,count);
                userMapper.updatePingTaiGold(count);
            }

            //calcExtract(agentId, userId, 1, chargeRmbAmount, 1);

        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    private void lpupRedis(Long userId, double v, Integer count, String orderId) {
        try {
            JSONObject a = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            JSONObject jsonb = new JSONObject();
            jsonb.put("controlType","gold_bill");
            JSONObject jsonc = new JSONObject();
            jsonc.put("createTime",(System.currentTimeMillis()/1000)+"");
            jsonc.put("deskNo",orderId);
            jsonc.put("type",2);
            jsonc.put("dizhu",count);
            JSONArray jsonArray2 = new JSONArray();
            JSONObject jsond = new JSONObject();
            jsond.put("gold",(int)v);
            jsond.put("uid",userId);
            jsonArray2.add(jsond);
            jsonc.put("userIds",jsonArray2);
            jsonb.put("data",jsonc);
            jsonArray.add(jsonb);
            a.put("insertList",jsonArray);
            a.put("updateList",null);
            System.out.println(a.toJSONString() + "房卡的类型");
            RedisUtil.getRu().lpush("DB_QUEUE",a.toJSONString());
        }catch (Exception e ) {
            System.out.println("房卡订单:" + orderId + "分销失败");
        }finally {

        }

    }

    public void insertIntoImsTpCard(String agent, double v,Long userId) {
        ICache cache = null;
        int money = (int)v;
        try {
            cache = CacheManager.getCache();
                Map<String, String> map = cache.hgetAll(Constants.COMMISSIONS);
                if (map.isEmpty()) {
                    CommissionVo vo =  userMapper.selectImsCommission();
                    cache.hset(Constants.COMMISSIONS,Constants.COMMISSIONS1,vo.getCommission1().toString());
                    cache.hset(Constants.COMMISSIONS,Constants.COMMISSIONS2,vo.getCommission2().toString());
                    cache.hset(Constants.COMMISSIONS,Constants.COMMISSIONS3,vo.getCommission3().toString());
                    map = cache.hgetAll(Constants.COMMISSIONS);
                }
                ImsTpCard imsTpCard = new ImsTpCard();
                imsTpCard.setUserId(userId);
            String[] agents = agent.split(",");
            System.out.println(agents[0]);
            imsTpCard.setMoney(Long.parseLong(money+""));
                if ( agents.length < 0 || "1".equals(agents[0].trim())) {
                    imsTpCard.setAgentId(1);
                    imsTpCard.setAgentInCome(0);
                    imsTpCard.setParentId(1);
                    imsTpCard.setParentInCome(0);
                    imsTpCard.setGrandParentId(1);
                    imsTpCard.setGrandParentInCome(0);
                    imsTpCard.setSurplus(money);
                }else if ("1".equals(agents[1].trim()) ) {
                    imsTpCard.setAgentId(Integer.parseInt(agents[0].trim()));
                    int i = money * Integer.parseInt(map.get(Constants.COMMISSIONS1)) / 100;
                    userMapper.updateCommissionsCardA(Integer.parseInt(agents[0].trim()),i);
                    imsTpCard.setAgentInCome(i);
                    imsTpCard.setParentId(1);
                    imsTpCard.setParentInCome(0);
                    imsTpCard.setGrandParentId(1);
                    imsTpCard.setGrandParentInCome(0);
                    imsTpCard.setSurplus(money-i);
                }else if ("1".equals(agents[2].trim()) ) {
                    imsTpCard.setAgentId(Integer.parseInt(agents[0].trim()));
                    int a = money * Integer.parseInt(map.get(Constants.COMMISSIONS1)) / 100;
                    userMapper.updateCommissionsCardA(Integer.parseInt(agents[0].trim()),a);
                    imsTpCard.setAgentInCome(a);
                    imsTpCard.setParentId(Integer.parseInt(agents[1].trim()));
                    int b = money * Integer.parseInt(map.get(Constants.COMMISSIONS2)) / 100;
                    userMapper.updateCommissionsCardB(Integer.parseInt(agents[1].trim()),b);
                    imsTpCard.setParentInCome(b);
                    imsTpCard.setGrandParentId(1);
                    imsTpCard.setGrandParentInCome(0);
                    imsTpCard.setSurplus(money-a-b);
                }else {
                    imsTpCard.setAgentId(Integer.parseInt(agents[0].trim()));
                    int a = money * Integer.parseInt(map.get(Constants.COMMISSIONS1)) / 100;
                    userMapper.updateCommissionsCardA(Integer.parseInt(agents[0].trim()),a);
                    imsTpCard.setAgentInCome(a);
                    imsTpCard.setParentId(Integer.parseInt(agents[1].trim()));
                    int b = money * Integer.parseInt(map.get(Constants.COMMISSIONS2)) / 100;
                    userMapper.updateCommissionsCardB(Integer.parseInt(agents[1].trim()),b);
                    imsTpCard.setParentInCome(b);
                    imsTpCard.setGrandParentId(Integer.parseInt(agents[2].trim()));
                    int c = money * Integer.parseInt(map.get(Constants.COMMISSIONS3)) / 100;
                    userMapper.updateCommissionsCardC(Integer.parseInt(agents[2].trim()),c);
                    imsTpCard.setGrandParentInCome(c);
                    imsTpCard.setSurplus(money-a-b-c);
                }
                userMapper.insertIntoImsTpGold(imsTpCard);
        }catch (Exception e ) {

        }finally {
            CacheManager.releaseCache(cache);
        }

    }

    public String getSanJiAgent(Long userId) {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            String agents = cache.hget(Constants.SANJIFENXIAO, userId.toString());
            if(StringUtil.isEmpty(agents)) {
                TUser tUser = userMapper.selectByPrimaryKey(userId);
                if (null == tUser || StringUtil.isEmpty(tUser.getAgentId())) {
                    return "1,1,1";
                }else {
                    int x = Integer.parseInt(tUser.getAgentId()+"");
                    int y = userMapper.selectImsTpUserById(tUser.getAgentId());
                    int z = userMapper.selectImsTpUserById(Long.parseLong(y + ""));
                    String s =  x+","+y+","+z;
                    cache.hset(Constants.SANJIFENXIAO,userId.toString(),s);
                    return s;
                }
            }else {
                return agents;
            }

        }catch (Exception e ) {
            System.out.println(e.getMessage());
        }finally {
            CacheManager.releaseCache(cache);
        }
        return null;
    }

    public boolean playerGoldRecharge(int i, Long userId, Integer count) throws IOException {
        //		Socket socket = SocketPool.getSocket();
        Socket socket = new Socket(GAME_SERVER_IP, Integer.parseInt(GAME_SERVER_port));
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();
        try {
            byte[] packet = updateCoin(i,Integer.parseInt(userId.toString()), count);
//			System.out.println(str2HexStr(packet));
            System.out.println(Arrays.toString(packet));
            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            //boolean result = false;
            //result = isValidResponse(b);
            Boolean result = b[21] <= 0 ? true : false;

            return result;
        } catch (Exception e) {
//			throw e;
            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
        } finally {
//			SocketPool.returnSocket(socket);
            out.close();
            in.close();
            socket.close();
        }

    }

    private static byte[] updateCoin(int count,int uid, int amount) {
        List<Byte> packet = initUpdatePacketHeadByPlayers();
        initUpdateCoinPacketBodyByPlayers(packet, count,uid, amount);
        Integer length = packet.size();
        byte[] array = new byte[length];
        for (int i = 0; i < length; i++) {
            array[i] = packet.get(i);
        }
        byte[] b = intToBytes(length - 4);
        for (int i = 0; i < b.length; i++) {
            array[i] = b[i];
        }
        return array;
    }

    private static void initUpdateCoinPacketBodyByPlayers(List<Byte> content,int count, int userId, int amount) {

        content.add((byte)count);
        //mid
        writeInt(content,userId);
        //money
        writeInt(content, amount);
    }

    private static void writeInt(List<Byte> packet, int value) {
        byte[] b = intToBytes(value);
        for (byte c : b) {
            packet.add(c);
        }
    }
    private static void writeShort(List<Byte> packet, int value) {
        byte[] b = intToBytes(value);
        int i = 0;
        for (byte c : b) {
            if (i > 1) {
                break;
            }
            packet.add(c);
            i++;
        }
    }

    private static byte[] intToBytes(int value) {
        byte[] src = new byte[4];
        src[0] = (byte) ((value >> 24) & 0xFF);
        src[1] = (byte) ((value >> 16) & 0xFF);
        src[2] = (byte) ((value >> 8) & 0xFF);
        src[3] = (byte) (value & 0xFF);
        return src;
    }

    private static List<Byte> initUpdatePacketHeadByPlayers() {
        List<Byte> list = new ArrayList<Byte>();
        addZeros(4, list);
        // BY
        list.add((byte) 'B');
        list.add((byte) 'Y');
        // version
        list.add((byte) 0);
        list.add((byte) 1);

        // Cmd
        addZeros(2, list);
        list.add((byte) 0x10);
        list.add((byte) 0x0B);

        // gameid
        addZeros(2, list);

        // regionid
        addZeros(2, list);

        // deviceid
        addZeros(1, list);

        // code
        addZeros(1, list);
        return list;
    }

    private static List<Byte> initHeader(int A, int B) {
        List<Byte> list = new ArrayList<Byte>();
        addZeros(4, list);
        // BY
        list.add((byte) 'B');
        list.add((byte) 'Y');
        // version
        list.add((byte) 0);
        list.add((byte) 1);

        // Cmd
        addZeros(2, list);
        list.add((byte) A);
        list.add((byte) B);

        // gameid
        addZeros(2, list);

        // regionid
        addZeros(2, list);

        // deviceid
        addZeros(1, list);

        // code
        addZeros(1, list);
        return list;
    }

    private static void addZeros(int num, List<Byte> list) {
        for (int i = 0; i < num; i++) {
            list.add((byte) 0);
        }
    }

    /**
     * 递归计算代理分成
     * @param agentId         代理ID
     * @param userId          玩家ID
     * @param isBindAgent     是否是玩家绑定的代理
     * @param chargeRmbAmount 充值金额rmb，单位分
     * @param curRound        当前算了第几轮
     * @throws Exception
     */
    private void calcExtract(Long agentId, Long userId, int isBindAgent, Integer chargeRmbAmount, Integer curRound) throws Exception {
        if (agentId == null) {
            return;
        }
        Long parentAgentId = secUserMapper.queryParentIdByUserId(agentId);
        Integer agentLevel = secUserMapper.queryAgentLevelByAgentId(agentId);
        int totalLayer = 100;
        int curLayer   = 0;
        while (agentLevel > 1 && curRound >= 4) {
            if (curLayer < totalLayer) {
                agentId        = parentAgentId;
                agentLevel     = secUserMapper.queryAgentLevelByAgentId(agentId);
                parentAgentId  = secUserMapper.queryParentIdByUserId(agentId);
            } else {
                throw new InfServerException(Constants.RETURN_CODE_FAIL, "代理层级关系过长！");
            }
        }
        Double rate        = queryRateByRound(curRound, agentLevel);
        Double ticheng    = chargeRmbAmount * rate;
        TRechargeTiChengFlow rechargeTichengFlow = new TRechargeTiChengFlow();
        rechargeTichengFlow.setAgentId(agentId);
        rechargeTichengFlow.setPlayerId(userId);
        rechargeTichengFlow.setIsBinding(isBindAgent);
        rechargeTichengFlow.setRechargeNumber(chargeRmbAmount);
        rechargeTichengFlow.setTicheng(ticheng);
        rechargeTichengFlow.setDate(new Date());
        tichengFlowMapper.insert(rechargeTichengFlow);
        if (agentLevel > 1) {
            calcExtract(parentAgentId, userId, 0, chargeRmbAmount, curRound + 1);
        }
    }

    /**
     * 根据当前第几轮返回当前分成比例
     * @param curRound
     * @return
     * @throws Exception
     */
    private Double queryRateByRound(Integer curRound, Integer agentLevel) throws Exception {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            Double vLevel1 = baseCacheController.getDoubleConfig("agentExtractLevelOne", cache);
            Double vLevel2 = baseCacheController.getDoubleConfig("agentExtractLevelTwo", cache);
            Double vLevel3 = baseCacheController.getDoubleConfig("agentExtractLevelThree", cache);
            Double vLevel4 = baseCacheController.getDoubleConfig("agentExtractLevelFour", cache);
            Double rate    = 0.0;
            switch (curRound) {
                case 1:
                    if (agentLevel == 1) {
                        rate = vLevel4 + vLevel3 + vLevel2 + vLevel1;
                    } else if (agentLevel == 2) {
                        rate = vLevel4 + vLevel3 + vLevel2;
                    } else if (agentLevel == 3) {
                        rate = vLevel4 + vLevel3;
                    } else if (agentLevel >= 4) {
                        rate = vLevel4;
                    }
                    break;
                case 2:
                case 3:
                case 4:
                    if (agentLevel == 1) {
                        rate = vLevel1;
                    } else if (agentLevel == 2) {
                        rate = vLevel2;
                    } else if (agentLevel == 3) {
                        rate = vLevel3;
                    }
                    break;
            }
            return rate;
        } catch (Exception e) {
            throw e;
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public boolean setPlayerGameStatus(Integer playerId1) throws IOException {
        String port = ConfigUtil.get("userServer.port" + playerId1%10);
        Socket socket = new Socket(GAME_SERVER_IP, Integer.parseInt(port));
        socket.setSoTimeout(10*1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();
        try {
            List<Byte> bytes = initHeader(0x01, 0x13);
            byte[] packet = initPlayerStatusBoby(bytes,playerId1);

            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            System.out.println(Arrays.toString(b));
            Boolean result = b[21] <= 0 ? true : false;

            return result;
        } catch (Exception e) {
//			throw e;
            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
        } finally {
//			SocketPool.returnSocket(socket);
            out.close();
            in.close();
            socket.close();
        }
    }

    public void changePlayerGameStatus(Integer playerId1) throws IOException {
        String port = ConfigUtil.get("userServer.port" + playerId1%10);
        Socket socket = new Socket(GAME_SERVER_IP, Integer.parseInt(port));
        socket.setSoTimeout(10*1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();
        try {
            List<Byte> bytes = initHeader(0x01, 0x99);
            byte[] packet = initChangePlayerStatusBoby(bytes,playerId1);

            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
//            in.read(b);
//            System.out.println(Arrays.toString(b));
//            Boolean result = b[21] <= 0 ? true : false;

//            return result;
        } catch (Exception e) {
//			throw e;
            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
        } finally {
//			SocketPool.returnSocket(socket);
            out.close();
            in.close();
            socket.close();
        }
    }

    private byte[] initPlayerStatusBoby(List<Byte> bytes, int playerId1) {

        writeInt(bytes,10);
        writeShort(bytes,1000);
        writeInt(bytes,10);
        writeInt(bytes,playerId1);

        Integer length = bytes.size();
        byte[] array = new byte[length];
        for (int i = 0; i < length; i++) {
            array[i] = bytes.get(i);
        }
        byte[] b = intToBytes(length - 4);
        for (int i = 0; i < b.length; i++) {
            array[i] = b[i];
        }
        return array;
    }
    private byte[] initChangePlayerStatusBoby(List<Byte> bytes, int playerId1) {

        writeShort(bytes,1000);
        writeInt(bytes,-1);
        writeInt(bytes,playerId1);

        Integer length = bytes.size();
        byte[] array = new byte[length];
        for (int i = 0; i < length; i++) {
            array[i] = bytes.get(i);
        }
        byte[] b = intToBytes(length - 4);
        for (int i = 0; i < b.length; i++) {
            array[i] = b[i];
        }
        return array;
    }
}
