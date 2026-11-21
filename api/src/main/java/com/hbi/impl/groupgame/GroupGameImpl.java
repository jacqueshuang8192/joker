package com.hbi.impl.groupgame;

import com.core.util.StringUtil;
import com.hbi.impl.protocol.Protocol;
import com.hbi.interfaces.IGroupGame;
import org.apache.log4j.Logger;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by ceeuoo on 8/24/2016.
 */
public class GroupGameImpl extends Protocol implements IGroupGame {
    private Logger logger = Logger.getLogger(GroupGameImpl.class);
    private String ip;
    private int port;
    private byte[] protocolNo;

    public GroupGameImpl(String ip, int port, byte[] protocolNo) {
        this.ip = ip;
//        this.ip = "127.0.0.1";
        this.port = port;
        this.protocolNo = protocolNo;
    }

    @Override
    public int createRoom(Long userId, int level, int baseChip, int needChip, String inviteCode, Long activityId,
                          int round, String json, String description,String discription2Server,Integer minCoinsGold,Integer max_playerCount,String creatorNickname,String creatorPortrait,String password,int groupId,
                          Integer configId, Integer gameType, String groupName) throws Exception {
        Socket socket = new Socket(ip, port);
        socket.setSoTimeout(10 * 1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();

        if (StringUtil.isEmpty(configId)) {
            configId = 0;
        }
        StringBuilder stringBuilder = new StringBuilder("userId:");
        stringBuilder.append(userId).append("level:").append(level)
                .append("baseChip:").append(baseChip)
                .append("needChip:").append(needChip)
                .append("inviteCode:").append(inviteCode)
                .append("activityId:").append(activityId)
                .append("round:").append(round)
                .append("json:").append(json)
                .append("configId:").append(configId)
                .append("gameType:").append(gameType)
                .append("groupName:").append(groupName);
        logger.info(stringBuilder.toString());

        try {
//            System.out.println(userId + "..."+level + "..."+ baseChip + "..."+ needChip + "..."+ inviteCode + "..."+ activityId + "..."+ round + "..."+ json + "..."+
//                    discription2Server + "..."+ minCoinsGold + "..."+max_playerCount + "..."+creatorNickname + "..."+creatorPortrait+"..." +password + "..." +groupId );
            byte[] packet = buildPacket(userId, level, baseChip, needChip, inviteCode, activityId, round, json,discription2Server,
                    minCoinsGold,max_playerCount,creatorNickname,creatorPortrait,password,groupId,configId,gameType,groupName);
            out.write(packet);
            out.flush();
            byte[] b = new byte[1024];
            in.read(b);
            int returnCode = b[25] <= 0 ? b[25] : -99;
            logger.error("table returnCode" + returnCode + "");
            if (returnCode == 0) {
                byte[] t = Arrays.copyOfRange(b, 30, 34);
                int tid = 0;
                logger.info("创建组局回显：" + t);
                for (int i = 0; i < t.length; i++) {
                    tid += ((int)t[i] & 0x000000ff) * Math.pow(256, t.length - 1 - i);
                }
                logger.error("table tid" + tid + "");
                return tid;
            } else {
                return returnCode;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            out.close();
            in.close();
            socket.close();
        }
    }

    @Override
    public int createRoomByPassword(Long userId, int level, int baseChip, int needChip, String inviteCode, Long activityId,
                          int round, String json, String description,String discription2Server,Integer minCoinsGold,Integer max_playerCount,String creatorNickname,String creatorPortrait,String password) throws Exception {
        Socket socket = new Socket(ip, port);
        socket.setSoTimeout(10 * 1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();

//        StringBuilder stringBuilder = new StringBuilder("userId:");
//        stringBuilder.append(userId).append("level:").append(level).append("baseChip:").append(baseChip)
//                .append("needChip:").append(needChip).append("inviteCode:").append(inviteCode)
//                .append("activityId:").append(activityId).append("round:").append(round).append("json:").append(json);
//        logger.info(stringBuilder.toString());

        try {
//            System.out.println(userId + "..."+level + "..."+ baseChip + "..."+ needChip + "..."+ inviteCode + "..."+ activityId + "..."+ round + "..."+ json + "..."+discription2Server + "..."+ minCoinsGold + "..."+max_playerCount + "..."+creatorNickname + "..."+creatorPortrait );
            byte[] packet = buildPacket(userId, level, baseChip, needChip, inviteCode, activityId, round, json,discription2Server,
                    minCoinsGold,max_playerCount,creatorNickname,creatorPortrait,password);
            out.write(packet);
            out.flush();
            System.out.println("yyy");
            byte[] b = new byte[1024];
            in.read(b);
            int returnCode = b[25] <= 0 ? b[25] : -99;
            logger.error("table returnCode" + returnCode + "");
            if (returnCode == 0) {
                byte[] t = Arrays.copyOfRange(b, 30, 34);
                int tid = 0;
                logger.info("创建密码房组局回显：" + t);
                for (int i = 0; i < t.length; i++) {
                    tid += ((int)t[i] & 0x000000ff) * Math.pow(256, t.length - 1 - i);
                }
                logger.error("table tid" + tid + "");
                return tid;
            } else {
                return returnCode;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            out.close();
            in.close();
            socket.close();
        }
    }


    @Override
    public int dissolveRoom(Long activityId, int tid) throws Exception {
        Socket socket = new Socket(ip, port);
        socket.setSoTimeout(10 * 1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();

        try {
            byte[] packet = closeFreeGame(activityId, tid);
            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            int returnCode = b[25];
            logger.info("dissolve result" + returnCode);
            return returnCode;
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            out.close();
            in.close();
            socket.close();
        }
    }

    private byte[] buildPacket(long userId, int level, int baseChip, int needChip, String inviteCode, long activityId,
                               int round, String json,String discription2Server,int minCoinsGold,int max_playerCount,String creatorNickname,String creatorPortrait,String password,int groupId,
                               Integer configId, Integer gameType,String groupName) {
        List<Byte> list = initCreateTableHead();
        initCreateTableBody(list, userId, baseChip, needChip, inviteCode, activityId, level, round, json, discription2Server,minCoinsGold,max_playerCount,creatorNickname,creatorPortrait,password,groupId,
                    configId,gameType,groupName);
        Integer length = list.size();
        byte[] array = new byte[length];
        for (int i = 0; i < length; i++) {
            array[i] = list.get(i);
        }
        byte[] b = intToBytes(length - 4);
        for (int i = 0; i < b.length; i++) {
            array[i] = b[i];
        }
        return array;
    }

    private byte[] buildPacket(long userId, int level, int baseChip, int needChip, String inviteCode, long activityId,
                               int round, String json,String discription2Server,int minCoinsGold,int max_playerCount,String creatorNickname,String creatorPortrait,String password) {
        List<Byte> list = initCreateTableHead();
        initCreateTableBody(list, userId, baseChip, needChip, inviteCode, activityId, level, round, json, discription2Server,minCoinsGold,max_playerCount,creatorNickname,creatorPortrait,password);
        Integer length = list.size();
        byte[] array = new byte[length];
        for (int i = 0; i < length; i++) {
            array[i] = list.get(i);
        }
        byte[] b = intToBytes(length - 4);
        for (int i = 0; i < b.length; i++) {
            array[i] = b[i];
        }
        return array;
    }

    @Override
    public int  exitFreeGameByDbDateAndGame(Integer table_id,String userId, String activityId) throws Exception {
        Socket socket = new Socket(ip, port);
        socket.setSoTimeout(10 * 1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();
        //状态标识我,1代表游戏用户退出,0代表登录
        int flag = 1;
        //StringBuilder stringBuilder = new StringBuilder("userId:");
        //stringBuilder.append(userId).append("inviteCode:").append(activityId).append("flag:").append(flag);
        //logger.info(stringBuilder.toString());
        try {
            //byte[] packet = buildPacket(Long.parseLong(userId),activityId,flag);
            byte[] packet = closeFreeGame(table_id,Long.parseLong(activityId),Long.parseLong(userId),flag);
            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            int returnCode = b[21] <= 0 ? b[21] : -99;

            logger.info("exitFreeGameByDbDateAndGame result" + returnCode);
            return returnCode;
        }catch (Exception e) {
            throw new RuntimeException(e);
        }finally {
            out.close();
            in.close();
            socket.close();
        }
    }

    private List<Byte> initCreateTableHead() {
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
        list.add(protocolNo[0]);
        list.add((protocolNo[1]));

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

    private void initCreateTableBody(List<Byte> list, Long userId, int baseChip, int needChip, String inviteCode,
                                     Long activityId, int level, int round, String json,String discription2Server,int minCoinsGold,int max_playerCount,String creatorNickname,String creatorPortrait,String password,int groupId,
                                     Integer configId, Integer gameType,String groupName) {
        // uid
        writeUid(list, userId);

        writeInt(list, level);

        writeInt(list, baseChip);

        writeInt(list, needChip);

        writeString(list, inviteCode);

        writeInt(list, activityId.intValue());

        writeInt(list, round);

        writeString(list, json);


        writeInt(list,minCoinsGold);

        writeInt(list,max_playerCount);

        writeString(list,creatorPortrait);

        writeString(list,discription2Server);

        writeString(list,password);

        writeInt(list,groupId);

        writeInt(list, configId);

        writeInt(list, gameType);

        writeString(list,groupName);
    }

    private void initCreateTableBody(List<Byte> list, Long userId, int baseChip, int needChip, String inviteCode,
                                     Long activityId, int level, int round, String json,String discription2Server,int minCoinsGold,int max_playerCount,String creatorNickname,String creatorPortrait,String password) {
        // uid
        writeUid(list, userId);

        writeInt(list, level);

        writeInt(list, baseChip);

        writeInt(list, needChip);

        writeString(list, inviteCode);

        writeInt(list, activityId.intValue());

        writeInt(list, round);

        writeString(list, json);


        writeInt(list,minCoinsGold);

        writeInt(list,max_playerCount);

        writeString(list,creatorPortrait);

        writeString(list,discription2Server);

        writeString(list,password);

    }


    private List<Byte> initCloseFreeGameHead() {
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
        list.add(protocolNo[0]);
        list.add(protocolNo[1]);

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

    private void initCloseFreeGameBody(List<Byte> list, Long activityId, int tid) {
        writeInt(list, activityId.intValue());
        writeInt(list, tid);
    }

    private byte[] closeFreeGame(Long activityId, int tid) {
        List<Byte> list = initCloseFreeGameHead();
        initCloseFreeGameBody(list, activityId, tid);
        Integer length = list.size();
        byte[] array = new byte[length];
        for (int i = 0; i < length; i++) {
            array[i] = list.get(i);
        }
        byte[] b = intToBytes(length - 4);
        for (int i = 0; i < b.length; i++) {
            array[i] = b[i];
        }
        return array;
    }

    private byte[] closeFreeGame(Integer table_id,Long activityId,Long userId,int flag) {
        List<Byte> list = initCloseFreeGameHead();
        writeInt(list,userId.intValue());
        writeInt(list,table_id);
        Integer length = list.size();
        byte[] array = new byte[length];
        for (int i = 0; i < length; i++) {
            array[i] = list.get(i);
        }
        byte[] b = intToBytes(length - 4);
        for (int i = 0; i < b.length; i++) {
            array[i] = b[i];
        }
        return array;
    }


    public static void main(String s[]) throws Exception {
        byte[] protocolNo = new byte[2];
        protocolNo[0] = (byte)0x01;
        protocolNo[1] = (byte)0x55;
        new GroupGameImpl("120.76.188.25", 11100, protocolNo).dissolveRoom(39535L, 12344535);
    }
}
