package com.j.joker.utils;

import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.constants.Constants;
import org.apache.commons.lang.StringUtils;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by ceeuoo on 3/31/2016.
 */
public class OldGameServerUtil {
    public static void main(String[] s) {
        try {
                invokeQuery(238L);
//            OldConnectionPool.init();
//            Thread.sleep(3000);
//            for (int i = 0; i < 10000; i++) {
//                final int temp = i;
//                new Thread(new Runnable() {
//                    @Override
//                    public void run() {
////							lock.modify();
//                        try {
//                            System.out.println(temp + ":  " +invokeQuery((long)temp));
//                        } catch (InfServerException e) {
//                            System.out.println(temp + "not exist");
////							continue;
//                        } catch (Exception e) {
//                            System.out.println(temp + ":  ");
//                            e.printStackTrace();
//                        }
//                    }
//                }).start();
//            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static final String GAME_SERVER_IP = ConfigUtil.get("oldgame.ip");

    /**
     * 查询用户房卡
     * @param userId
     * @return
     * @throws Exception
     */
    public static Integer queryJewelAmount(Long userId) throws Exception {
        int jewelAmountRemain = 0;
        String json = GameServerUtil.invokeQuery(userId);
        if (StringUtils.isEmpty(json)) {
            throw new InfServerException(
                    Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回为空");
        }

        JSONObject obj = JSONObject.parseObject(json);

        if (obj != null) {
            if (obj.containsKey("jewelAmount") && StringUtils
                    .isNotBlank(obj.getString("jewelAmount"))) {
                jewelAmountRemain = Integer
                        .parseInt(obj.getString("jewelAmount"));
            } else {
                throw new InfServerException(
                        Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回房卡为空");
            }
        }
        return jewelAmountRemain;
    }

    /**
     * 查询账户
     *
     * @param userId
     * @return
     * @throws Exception
     */
    public static String invokeQuery(Long userId) throws Exception {
        Socket socket = OldConnectionPool.getSocket(userId);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();
        try {
            byte[] packet = query(userId);
            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            String response = parseQueryResponse(b);
            JSONObject obj = parseUserDetial(response);
            return obj.toJSONString();
        } catch (Exception e) {
            throw e;
        } finally {
            OldConnectionPool.returnSocket(userId, socket);
        }

    }

    /**
     * 更新用户房卡，传入差值，如扣减50，传入-50
     *
     * @param userId
     * @param amount
     * @return
     * @throws Exception
     */
    public static boolean invokeUpdateCoin(Long userId, int amount)
            throws Exception {
        Socket socket = OldConnectionPool.getSocket(userId);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();
        try {
            byte[] packet = updateCoin(userId, amount);
            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            boolean result = false;
            result = isValidResponse(b);

            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            OldConnectionPool.returnSocket(userId, socket);
        }
    }

    /**
     * 更新用户房卡，传入差值，如扣减50，传入-50
     *
     * @param userId
     * @param amount
     * @return
     * @throws Exception
     */
    public static boolean invokeUpdateJewel(Long userId, int amount)
            throws Exception {
        Socket socket = OldConnectionPool.getSocket(userId);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();
        try {
            byte[] packet = updateJewel(userId, amount);
            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            boolean result = false;
            result = isValidRespWithId(b);

            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            OldConnectionPool.returnSocket(userId, socket);
        }

    }

    /**
     * 创建账户
     *
     * @param userId
     * @param coinAmount
     * @return
     * @throws Exception
     */
    public static boolean invokeCreate(Long userId, int coinAmount,
                                       Integer jewelAmount) throws Exception {
        Socket socket = OldConnectionPool.getSocket(userId);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();

        try {
            byte[] packet = create(userId, coinAmount, jewelAmount);
            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            boolean result = isValidResponse(b);

            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            OldConnectionPool.returnSocket(userId, socket);
        }
    }

    private static byte[] query(Long userId) {
        byte[] packet = new byte[19];
        initQueryPacketHead(packet);
        packet = initQueryPacketBody(packet, userId);
        return packet;
    }

    private static byte[] updateCoin(Long userId, int amount) {
        byte[] packet = new byte[37];
        initUpdateCoinPacketHead(packet);
        packet = initUpdateCoinPacketBody(packet, userId, amount);
        return packet;
    }

    private static byte[] updateJewel(Long userId, int jewelAmount) {
        List<Byte> list = initUpdateJewelPacketHead();
        initUpdateJewelPacketBody(list, userId, jewelAmount);
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

    private static byte[] create(Long userId, int coinAmount,
                                 Integer jewelAmount) {
        List<Byte> list = initCreateUserHead();
        initCreateUserBody(list, userId, coinAmount, jewelAmount);
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

    private static byte[] initQueryPacketHead(byte[] packet) {
        writeLength(packet, (byte) 0x0f);
        packet[4] = 'Q';
        packet[5] = 'E';
        packet[6] = 1;
        packet[10] = 0x10;
        packet[11] = 0x04;
        return packet;
    }

    private static byte[] initQueryPacketBody(byte[] content, Long userId) {
        writeUid(content, userId);
        return content;
    }

    private static byte[] initUpdateCoinPacketHead(byte[] packet) {
        writeLength(packet, (byte) 0x21);
        // QE
        packet[4] = 'Q';
        packet[5] = 'E';

        // version
        packet[6] = 1;

        // cmd
        packet[10] = 0x10;
        packet[11] = 0x12;
        return packet;
    }

    private static byte[] initUpdateCoinPacketBody(byte[] content, Long userId,
                                                   int amount) {
        // uid
        writeUid(content, userId);
        // bid
        writeString(content, "", 19);

        // nAttrSize
        content[24] = 0;

        // type
        content[28] = 1;

        // value
        byte[] b = intToBytes(amount);
        content[29] = b[0];
        content[30] = b[1];
        content[31] = b[2];
        content[32] = b[3];

        return content;
    }

    private static List<Byte> initUpdateJewelPacketHead() {
        List<Byte> list = new ArrayList<Byte>();
        addZeros(4, list);
        // QE
        list.add((byte) 'Q');
        list.add((byte) 'E');
        // version
        list.add((byte) 1);

        // extend
        addZeros(1, list);

        // Cmd
        addZeros(2, list);
        list.add((byte) 0x30);
        list.add((byte) 0x07);

        // gameid
        addZeros(2, list);

        // code
        addZeros(1, list);
        return list;
    }

    private static void initUpdateJewelPacketBody(List<Byte> list, Long userId,
                                                  int jewelAmount) {
        // uid
        writeUid(list, userId);
        // amount
        byte[] b = intToBytes(jewelAmount);
        for (byte c : b) {
            list.add(c);
        }
    }

    private static List<Byte> initCreateUserHead() {
        List<Byte> list = new ArrayList<Byte>();
        addZeros(4, list);
        // QE
        list.add((byte) 'Q');
        list.add((byte) 'E');
        // version
        list.add((byte) 1);

        // extend
        addZeros(1, list);

        // Cmd
        addZeros(2, list);
        list.add((byte) 0x10);
        list.add((byte) 0x11);

        // gameid
        addZeros(2, list);

        // code
        addZeros(1, list);
        return list;
    }

    private static void initCreateUserBody(List<Byte> list, Long userId,
                                           Integer coinAmount, Integer jewelAmount) {
        // uid
        writeUid(list, userId);

        // money
        writeString(list, coinAmount.toString());

        // safebox
        writeString(list, "0");

        // total
        writeString(list, coinAmount.toString());

        // exp
        addZeros(4, list);

        // level
        addZeros(4, list);

        // win
        addZeros(4, list);

        // lost
        addZeros(4, list);

        // diamond
        // addZeros(4, list);
        writeInt(list, jewelAmount);
//		writeString(list, jewelAmount.toString());
    }

    private static String parseQueryResponse(byte[] content) throws Exception {
        if (!isValidResponse(content)) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL, "查询账户失败！");
        }
        byte[] b = new byte[4];
        for (int i = 0; i < 4; i++) {
            b[i] = content[19 + i];
        }
        int length = bytesToInt(b);
        String response = "";
        for (int i = 0; i < length; i++) {
            response = response + (char) content[23 + i];
        }
        return response;
    }

    /**
     * 判断回显里无uid时的情况是否成功
     *
     * @param content
     * @return
     */
    private static boolean isValidResponse(byte[] content) {
        if (content[4] != 0x51) {
            return false;
        }
        if (content[15] != 0) {
            return false;
        }
        if (content[16] != 0) {
            return false;
        }
        if (content[17] != 0) {
            return false;
        }
        if (content[18] != 0) {
            return false;
        }
        return true;
    }

    /**
     * 判断回显里有uid时的情况是否成功
     *
     * @param content
     * @return
     */
    private static boolean isValidRespWithId(byte[] content) {
        if (content[4] != 0x51) {
            return false;
        }
        if (content[19] != 0) {
            return false;
        }
        if (content[20] != 0) {
            return false;
        }
        if (content[21] != 0) {
            return false;
        }
        if (content[22] != 0) {
            return false;
        }
        return true;
    }

    private static JSONObject parseUserDetial(String response) throws Exception {
        response = response.replaceAll("\u0000", "");
        JSONObject jsObj = new JSONObject();
        String[] strs = response.split(",");
        if (strs.length != 8) {
            throw new InfServerException(Constants.RETURN_CODE_FAIL,
                    "获取用户账户错误！");
        }
        jsObj.put("coinAmount", strs[0]);
        jsObj.put("jewelAmount", strs[7]);
        return jsObj;
    }

    private static void writeLength(byte[] packet, byte length) {
        packet[3] = length;
    }

    private static void writeUid(byte[] packet, Long userId) {
        int id = userId.intValue();
        byte[] b = intToBytes(id);
        packet[15] = b[0];
        packet[16] = b[1];
        packet[17] = b[2];
        packet[18] = b[3];
    }

    private static void writeUid(List<Byte> packet, Long userId) {
        int id = userId.intValue();
        byte[] b = intToBytes(id);
        for (byte c : b) {
            packet.add(c);
        }
    }

    private static void writeInt(List<Byte> packet, int value) {
        byte[] b = intToBytes(value);
        for (byte c : b) {
            packet.add(c);
        }
    }

    private static byte[] writeString(byte[] packet, String str, int pos) {
        byte[] intVal = intToBytes(1);
        for (int i = 0; i < intVal.length; i++) {
            packet[pos] = intVal[i];
            pos++;
        }

        if (StringUtils.isNotBlank(str)) {
            byte[] b = str.getBytes();
            for (int i = 0; i < b.length; i++) {
                packet[pos] = b[i];
                pos++;
            }
        } else {
            packet[pos] = 0;
        }
        return packet;
    }

    private static void writeString(List<Byte> packet, String str) {
        byte[] intVal = intToBytes(1 + str.length());
        for (byte b : intVal) {
            packet.add(b);
        }

        if (StringUtils.isNotBlank(str)) {
            byte[] b = str.getBytes();
            for (byte c : b) {
                packet.add(c);
            }
            addZeros(1, packet);
        } else {
            addZeros(1, packet);
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

    private static int bytesToInt(byte[] src) {
        int r = 0;
        for (int i = 0; i < 4; i++) {
            r <<= 8;
            r |= (src[i] & 0x000000ff);
        }
        return r;
    }

    private static void addZeros(int num, List<Byte> list) {
        for (int i = 0; i < num; i++) {
            list.add((byte) 0);
        }
    }

    private static List<Byte> initCreateTableHead() {
        List<Byte> list = new ArrayList<Byte>();
        addZeros(4, list);
        // QE
        list.add((byte) 'Q');
        list.add((byte) 'E');
        // version
        list.add((byte) 1);

        // extend
        addZeros(1, list);

        // Cmd
        addZeros(2, list);
        list.add((byte) 0x01);
        list.add((byte) 0x49);

        // gameid
        addZeros(2, list);

        // code
        addZeros(1, list);
        return list;
    }

    private static byte[] createTable(Long userId, int baseChip, int money,
                                      String roomName, String password, String inviteCode, String activityId, int seconds) {
        List<Byte> list = initCreateTableHead();
        initCreateTableBody(list, userId, baseChip, money, roomName, password, inviteCode, activityId, seconds);
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

    private static void initCreateTableBody(List<Byte> list, Long userId,
                                            int baseChip, int money, String roomName, String password, String inviteCode, String activityId, int seconds) {
        // uid
        writeUid(list, userId);

        if (baseChip <= 100) {
            writeInt(list, 20201);
            writeInt(list, 11);
        } else if (baseChip > 100 && baseChip <= 500) {
            writeInt(list, 20401);
            writeInt(list, 12);
        } else {
            writeInt(list, 20601);
            writeInt(list, 13);
        }

        writeInt(list, 2);

        if (baseChip <= 100) {
            writeInt(list, 100);
        } else if (baseChip > 100 && baseChip <= 500) {
            writeInt(list, 500);
        } else {
            writeInt(list, 1000);
        }
        // money
        writeInt(list, money);

        writeString(list, roomName);

        writeString(list, password);

        writeInt(list, 0);

        writeString(list, "");

        writeString(list, inviteCode);

        writeString(list, activityId);

        writeInt(list, seconds);
    }

    public static int invokeCreateTable(Long userId, int baseChip, int money,
                                        String roomName, String password, String inviteCode, String activityId, int seconds) throws Exception {
        int port;
        if (baseChip <= 100) {
            port = 13001;
        } else if (baseChip <= 500) {
            port = 13002;
        } else {
            port = 13003;
        }
        Socket socket = new Socket(GAME_SERVER_IP, port);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();

        try {
            byte[] packet = createTable(userId, baseChip, money, roomName, password, inviteCode, activityId, seconds);
            out.write(packet);
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            boolean result = isValidResponse(b);

            if (result) {
                byte[] t = Arrays.copyOfRange(b, 23, 27);
                int tid = 0;
                for (int i = 0; i < t.length; i++) {
                    tid += (int)(t[i] & 0xff) * Math.pow(256, t.length - 1 - i);
                }
                return tid;
            } else {
                return -1;
            }
        } catch (Exception e) {
            throw e;
        } finally {
            out.close();
            in.close();
            socket.close();
        }
    }
}
