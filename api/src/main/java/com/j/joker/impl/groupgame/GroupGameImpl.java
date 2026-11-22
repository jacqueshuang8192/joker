package com.j.joker.impl.groupgame;

import com.j.joker.core.util.StringUtil;
import com.j.joker.impl.protocol.Protocol;
import com.j.joker.interfaces.IGroupGame;
import org.apache.log4j.Logger;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.Arrays;
import java.util.List;

/**
 * Created by ceeuoo on 8/24/2016.
 */
public class GroupGameImpl extends Protocol implements IGroupGame {
    private static final Logger logger = Logger.getLogger(GroupGameImpl.class);
    private final String ip;
    private final int port;
    private final byte[] protocolNo;

    public GroupGameImpl(String ip, int port, byte[] protocolNo) {
        this.ip = ip;
        this.port = port;
        this.protocolNo = protocolNo;
    }

    @Override
    public int createRoom(Long userId, int level, int baseChip, int needChip, String inviteCode,
                          Long activityId, int round, String json, String description, String discription2Server,
                          Integer minCoinsGold, Integer max_playerCount, String creatorNickname,
                          String creatorPortrait, String password, int groupId, Integer configId,
                          Integer gameType, String groupName) throws Exception {
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
            List<Byte> fields = createRoomFields(userId, level, baseChip, needChip, inviteCode,
                    activityId, round, json, discription2Server, minCoinsGold, max_playerCount,
                    creatorPortrait, password);
            writeInt(fields, groupId);
            writeInt(fields, configId);
            writeInt(fields, gameType);
            writeString(fields, groupName);
            out.write(finishPacket(fields));
            out.flush();
            return readCreatedTable(in, "创建组局回显：");
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            out.close();
            in.close();
            socket.close();
        }
    }

    @Override
    public int createRoomByPassword(Long userId, int level, int baseChip, int needChip, String inviteCode,
                                    Long activityId, int round, String json, String description,
                                    String discription2Server, Integer minCoinsGold, Integer max_playerCount,
                                    String creatorNickname, String creatorPortrait, String password) throws Exception {
        Socket socket = new Socket(ip, port);
        socket.setSoTimeout(10 * 1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();

        try {
            List<Byte> fields = createRoomFields(userId, level, baseChip, needChip, inviteCode,
                    activityId, round, json, discription2Server, minCoinsGold, max_playerCount,
                    creatorPortrait, password);
            out.write(finishPacket(fields));
            out.flush();
            System.out.println("yyy");
            return readCreatedTable(in, "创建密码房组局回显：");
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
            List<Byte> fields = super.initPacketHead(protocolNo);
            writeInt(fields, activityId.intValue());
            writeInt(fields, tid);
            out.write(finishPacket(fields));
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

    @Override
    public int exitFreeGameByDbDateAndGame(Integer table_id, String userId, String activityId) throws Exception {
        Socket socket = new Socket(ip, port);
        socket.setSoTimeout(10 * 1000);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();
        try {
            // The public API validates both IDs. Only user and table are sent on the wire.
            Long.parseLong(activityId);
            int playerId = (int) Long.parseLong(userId);
            List<Byte> fields = super.initPacketHead(protocolNo);
            writeInt(fields, playerId);
            writeInt(fields, table_id);
            out.write(finishPacket(fields));
            out.flush();

            byte[] b = new byte[1024];
            in.read(b);
            int returnCode = b[21] <= 0 ? b[21] : -99;

            logger.info("exitFreeGameByDbDateAndGame result" + returnCode);
            return returnCode;
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            out.close();
            in.close();
            socket.close();
        }
    }

    private List<Byte> createRoomFields(long userId, int level, int baseChip, int needChip,
                                        String inviteCode, long activityId, int round, String json,
                                        String serverDescription, int minCoinsGold, int maxPlayers,
                                        String creatorPortrait, String password) {
        List<Byte> fields = super.initPacketHead(protocolNo);
        writeUid(fields, userId);
        writeInt(fields, level);
        writeInt(fields, baseChip);
        writeInt(fields, needChip);
        writeString(fields, inviteCode);
        writeInt(fields, (int) activityId);
        writeInt(fields, round);
        writeString(fields, json);
        writeInt(fields, minCoinsGold);
        writeInt(fields, maxPlayers);
        writeString(fields, creatorPortrait);
        writeString(fields, serverDescription);
        writeString(fields, password);
        return fields;
    }

    private byte[] finishPacket(List<Byte> fields) {
        byte[] packet = new byte[fields.size()];
        for (int i = 0; i < packet.length; i++) {
            packet[i] = fields.get(i);
        }
        byte[] length = intToBytes(packet.length - 4);
        System.arraycopy(length, 0, packet, 0, length.length);
        return packet;
    }

    private int readCreatedTable(InputStream in, String logPrefix) throws java.io.IOException {
        byte[] response = new byte[1024];
        in.read(response);
        int returnCode = response[25] <= 0 ? response[25] : -99;
        logger.error("table returnCode" + returnCode);
        if (returnCode != 0) {
            return returnCode;
        }
        byte[] tableBytes = Arrays.copyOfRange(response, 30, 34);
        logger.info(logPrefix + tableBytes);
        int tableId = 0;
        for (int i = 0; i < tableBytes.length; i++) {
            tableId += (tableBytes[i] & 0xff) * Math.pow(256, tableBytes.length - 1 - i);
        }
        logger.error("table tid" + tableId);
        return tableId;
    }

    public static void main(String s[]) throws Exception {
        byte[] protocolNo = new byte[2];
        protocolNo[0] = (byte)0x01;
        protocolNo[1] = (byte)0x55;
        new GroupGameImpl("120.76.188.25", 11100, protocolNo).dissolveRoom(39535L, 12344535);
    }
}
