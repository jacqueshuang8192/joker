package com.j.joker.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.j.joker.core.util.ConfigUtil;
import com.j.joker.core.util.StringUtil;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.BaseCacheController;
import com.j.joker.constants.Constants;
import com.j.joker.model.TGroupGame;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.*;

public class GameServerUtil {

	private static final Logger logger = LoggerFactory.getLogger(GameServerUtil.class);

	public static void main(String[] s) {

//		Long cur = System.currentTimeMillis();
		try {
//			SocketPool.initSockets();
//			System.out.println(invokeQuery(501L));
			System.out.println(invokeUpdateCoin(1570L, 1000000));
			System.out.println(invokeUpdateCoin(1571L, 1000000));
			System.out.println(invokeUpdateCoin(1572L, 1000000));
			System.out.println(invokeUpdateCoin(1573L, 1000000));
			System.out.println(invokeUpdateCoin(1574L, 1000000));
			System.out.println(invokeUpdateCoin(1575L, 1000000));
			System.out.println(invokeUpdateCoin(1576L, 1000000));
			System.out.println(invokeUpdateCoin(1577L, 1000000));
			System.out.println(invokeUpdateCoin(1578L, 1000000));
			System.out.println(invokeUpdateCoin(1579L, 1000000));
//			System.out.println(invokeUpdateJewel(506L, 300000000));
//			invokeUpdateCoin(286L, 50000000);
//			for (int i = 0; i < 1000; i++) {
//			System.out.println(invokeQuery(281L));
//				invokeUpdateCoin(201L, 210);
//			}
//			final Long id1 = 506L;
//			final Long id2 = 510L;
////
////
//			for (int i = 0; i < 5000; i++) {
//                new Thread(new Runnable() {
//                    @Override
//                    public void run() {
//                        try {
//                            System.out.println(id1 + ":  " +invokeQuery(id1));
//                            System.out.println(id2 + ":  " +invokeQuery(id2));
//                        } catch (InfServerException e) {
//                            System.out.println("not exist");
//                        } catch (Exception e) {
//                            System.out.println(":  ");
//                            e.printStackTrace();
//                        }
//                    }
//                }).start();
//            }
//			Long now = System.currentTimeMillis();
//			System.out.println("==============================================time：" + (now - cur));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static final String GAME_SERVER_IP = ConfigUtil.get("game.ip");
	private static final String PORT = ConfigUtil.get("game.port");

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

	public static Integer queryCoinAmount(Long userId) throws Exception {
		int coinAmountRemain = 0;
		String json = GameServerUtil.invokeQuery(userId);
		if (StringUtils.isEmpty(json)) {
			throw new InfServerException(
					Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回为空");
		}

		JSONObject obj = JSONObject.parseObject(json);

		if (obj != null) {
			if (obj.containsKey("coinAmount") && StringUtils
					.isNotBlank(obj.getString("coinAmount"))) {
				coinAmountRemain = Integer
						.parseInt(obj.getString("coinAmount"));
			} else {
				throw new InfServerException(
						Constants.RETURN_CODE_ACCOUNT_ERROR, "接口返回房卡为空");
			}
		}
		return coinAmountRemain;
	}

	/**
	 * 查询账户
	 * 
	 * @param userId
	 * @return
	 * @throws Exception
	 */
	public static String invokeQuery(Long userId) throws Exception {
//		logger.info("查询用户账户：" + userId);
		Socket socket = SocketPool.getSocket();
		OutputStream out = socket.getOutputStream();
		InputStream in = socket.getInputStream();
		try {
			byte[] packet = query(userId);
//			System.out.println(str2HexStr(packet));
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];
			in.read(b);
			JSONObject obj = parseQueryResponse(b);
			System.out.println(obj.toJSONString() + "xxxxxxx");
			return obj.toJSONString();
		} catch (Exception e) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
//			throw e;
	} finally {
		SocketPool.returnSocket(socket);
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
//		Socket socket = SocketPool.getSocket();
		Socket socket = new Socket(GAME_SERVER_IP, Integer.parseInt(PORT));
		OutputStream out = socket.getOutputStream();
		InputStream in = socket.getInputStream();
		try {
			byte[] packet = updateCoin(userId, amount);
//			System.out.println(str2HexStr(packet));
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];
			in.read(b);
			boolean result = false;
			result = isValidResponse(b);

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
		Socket socket = SocketPool.getSocket();
//		Socket socket = new Socket(GAME_SERVER_IP, Integer.parseInt(GAME_SERVER_PORT));
		OutputStream out = socket.getOutputStream();
		InputStream in = socket.getInputStream();
		try {
			byte[] packet = updateJewel(userId, amount);
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];
			in.read(b);
			boolean result = false;
			result = isValidResponse(b);

			return result;
		} catch (Exception e) {
//			throw e;
			throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
		} finally {
			SocketPool.returnSocket(socket);
		}

	}

	private static byte[] query(Long userId) {
		List<Byte> packet = initQueryPacketHead();
		initQueryPacketBody(packet, userId);
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

	private static byte[] updateCoin(Long userId, int amount) {
		List<Byte> packet = initUpdatePacketHead();
		initUpdateCoinPacketBody(packet, userId, amount);
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

	private static byte[] updateJewel(Long userId, int jewelAmount) {
		List<Byte> list = initUpdatePacketHead();
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

	private static List<Byte> initQueryPacketHead() {
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
		list.add((byte) 0x04);

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

	private static void initQueryPacketBody(List<Byte> content, Long userId) {
		writeRef(content);
		writeUid(content, userId);
	}

	private static List<Byte> initUpdatePacketHead() {
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
		list.add((byte) 0x02);

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

	private static void initUpdateCoinPacketBody(List<Byte> content, Long userId,
			int amount) {
		//ref
		writeRef(content);
		//desc
		writeString(content, "");
		//mid
		writeUid(content, userId);
		//money
		writeInt(content, amount);
		//exp
		writeInt(content, 0);
		//diamond
		writeInt(content, 0);
		//win
		writeInt(content, 0);
		//lose
		writeInt(content, 0);
		//clientInfo
		writeString(content, "");
		//chip
		writeInt(content, 0);
	}

	private static void initUpdateJewelPacketBody(List<Byte> content, Long userId,
			int jewelAmount) {
		//ref
		writeRef(content);
		//desc
		writeString(content, "");
		//mid
		writeUid(content, userId);
		//money
		writeInt(content, 0);
		//exp
		writeInt(content, 0);
		//diamond
		writeInt(content, jewelAmount);
		//win
		writeInt(content, 0);
		//lose
		writeInt(content, 0);
		//clientInfo
		writeString(content, "");
		//chip
		writeInt(content, 0);
	}

	private static JSONObject parseQueryResponse(byte[] content) throws Exception {
		if (!isValidResponse(content)) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL, "查询账户失败！");
		}
		JSONObject json = new JSONObject();
		byte[] b = new byte[4];
		for (int i = 0; i < 4; i++) {
			b[i] = content[26 + i];
		}
		int length = bytesToInt(b);
		String money = "";
		for (int i = 0; i < length; i++) {
			money = money + (char) content[30 + i];
		}
		money = money.replaceAll("\u0000", "");
		json.put("coinAmount", money);
		b = new byte[4];
		for (int i = 0; i < 4; i++) {
			b[i] = content[34 + length + i];
		}
		json.put("jewelAmount", bytesToInt(b));
		return json;
	}

	/**
	 * 判断回显里无uid时的情况是否成功
	 * 
	 * @param content
	 * @return
	 */
	private static boolean isValidResponse(byte[] content) {
		if (content[4] != 0x42) {
			return false;
		}
		if (content[22] != 0) {
			return false;
		}
		if (content[23] != 0) {
			return false;
		}
		if (content[24] != 0) {
			return false;
		}
		if (content[25] != 0) {
			return false;
		}
		return true;
	}

	private static void writeRef(List<Byte> packet) {
		byte[] b = intToBytes(2);
		for (byte c : b) {
			packet.add(c);
		}
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

	private static void writeString2(List<Byte> packet, String str) {
		byte[] intVal = intToBytes(1 + str.getBytes().length);
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
	
	private static List<Byte> initCloseFreeGameHead() {
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
		list.add((byte) 0x01);
		list.add((byte) 0x55);

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

	private static List<Byte> initCreateTableHead() {
		List<Byte> list = new ArrayList<Byte>();
		addZeros(4, list);
		// BY
//		list.add((byte) 'Q');
//		list.add((byte) 'E');
		list.add((byte) 'B');
		list.add((byte) 'Y');
		// version
		list.add((byte) 0);
		list.add((byte) 1);

		// Cmd
		addZeros(2, list);
		list.add((byte) 0x01);
		list.add((byte) 0x49);

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

	private static List<Byte> initCreateTableHeadGold() {
		List<Byte> list = new ArrayList<Byte>();
		addZeros(4, list);
		// BY
//		list.add((byte) 'Q');
//		list.add((byte) 'E');
		list.add((byte) 'B');
		list.add((byte) 'Y');
		// version
		list.add((byte) 0);
		list.add((byte) 1);

		// Cmd
		addZeros(2, list);
		list.add((byte) 0x01);
		list.add((byte) 0x71);

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

	private static byte[] closeFreeGame(Long activityId) {
		List<Byte> list = initCloseFreeGameHead();
		initCloseFreeGameBody(list, activityId);
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
	
	private static byte[] createTable(Long userId, int baseChip, int money,
			String roomName, String password, String inviteCode, String activityId, int seconds, int level, int server) {
		List<Byte> list = initCreateTableHead();
		initCreateTableBody(list, userId, baseChip, money, roomName, password, inviteCode, activityId, seconds, level, server);
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

	private static byte[] createTable(int level, int tid, int uid, Integer gold) {
		List<Byte> list = initCreateTableHeadGold();
		initCreateTableBody(list,level,tid,uid,gold);
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

	private static void initCloseFreeGameBody(List<Byte> list, Long activityId) {
		writeInt(list, activityId.intValue());
	}
	
	private static void initCreateTableBody(List<Byte> list, Long userId,
			int baseChip, int money, String roomName, String password, String inviteCode, String activityId, int seconds, int level, int server) {
		// uid
		writeUid(list, userId);
		
		writeInt(list, level);
		writeInt(list, server);
		
		writeInt(list, 2);
		
		writeInt(list, baseChip);
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

	private static void initCreateTableBody(List<Byte> list,int level,int tid,int uid,int gold) {
		// uid
		writeInt(list, level);
		writeInt(list, tid);
		writeInt(list, uid);
		writeInt(list, gold);

		System.out.println(level + "+++++" + tid + "+++++" + uid + "++++" + gold + "+++++");
	}
	
	public static int invokeCloseFreeGame(Long activityId, String ip, int port) throws Exception {
		Socket socket = new Socket(ip, port);
		socket.setSoTimeout(10 * 1000);
		
		OutputStream out = socket.getOutputStream();
		InputStream in = socket.getInputStream();

		try {
			byte[] packet = closeFreeGame(activityId);
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];
			in.read(b);
			
			int returnCode = b[25];

			return returnCode;
		} catch (Exception e) {
			throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
		} finally {
			out.close();
			in.close();
			socket.close();
		}
	}
	
	public static int invokeCreateTable(Long userId, int baseChip, int money,
			String roomName, String password, String inviteCode, String activityId, int seconds, String ip, int port, int level, int server) throws Exception {
		Socket socket = new Socket(ip, port);
		socket.setSoTimeout(10 * 1000);
		OutputStream out = socket.getOutputStream();
		InputStream in = socket.getInputStream();

		try {
			byte[] packet = createTable(userId, baseChip, money, roomName, password, inviteCode, activityId, seconds, level, server);
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];
			in.read(b);
			int returnCode = b[25] <= 0 ? b[25] : -99;
			logger.error("table returnCode" + returnCode + "");
			if (returnCode == 0) {
				byte[] t = Arrays.copyOfRange(b, 30, 34);
				int tid = 0;
				logger.debug("创建组局回显：" + t);
				for (int i = 0; i < t.length; i++) {
					tid += ((int)t[i] & 0x000000ff) * Math.pow(256, t.length - 1 - i);

				}
				logger.error("table tid" + tid + "");
				return tid;
			} else {
				return returnCode;
			}
		} catch (Exception e) {
//			throw e;
			throw new InfServerException(Constants.RETURN_CODE_FAIL, e.getMessage());
		} finally {
			out.close();
			in.close();
			socket.close();
		}
	}

	public static void notice2GameServerGoldRec(Long userId,Integer count) throws IOException {

		ICache cache = null;
		try {
			cache = CacheManager.getCache();

			String hget = cache.hget(Constants.USER_GAME_STATUS, userId.toString());
			//如果没有组局状态直接结束
			if (hget == null || "".equals(hget)) {
				//通知游戏服,固定格式
				JSONObject jsonObject = new JSONObject();
				jsonObject.put("type","exchangeGold");
				jsonObject.put("count",count);
				//通知游戏服
				GameServerUtil.notice2HallPublice(userId,jsonObject);
				return;
			}else {
				//房卡场的返回方式
				String[] sp = hget.split("_");

				Socket socket = null;
				OutputStream out = null;
				InputStream in = null;
				try {
					TGroupGame tGroupGame = new BaseCacheController().queryGroupGameByGameIdAndLevel(Long.parseLong(sp[0]), Integer.parseInt(sp[0]), cache);
					socket=new Socket(tGroupGame.getIp(),tGroupGame.getPort());
					socket.setSoTimeout(10 * 1000);
					out = socket.getOutputStream();
					in = socket.getInputStream();


					byte[] packet = createTable(Integer.parseInt(sp[0]),Integer.parseInt(sp[1]),Integer.parseInt(userId.toString()),count);
					out.write(packet);
					out.flush();

				} catch (Exception e) {
					System.out.println(e.getMessage());
				} finally {
					if (out != null) {
						out.close();
					}
					if (in != null ) {
						in.close();
					}
					if (socket != null) {
						socket.close();
					}
				}
			}
		}catch (Exception e ) {
			logger.error("发送玩家充值通知协议异常");
		}finally {
			if (null != cache) {
				CacheManager.releaseCache(cache);
			}
		}


	}

	//状态 0关闭 1释放 2登入失败 3登入成功
	public static void I2AReleaseRobot(Integer groupId,Integer level,Integer uid,Integer status) throws Exception {

		Socket socket = null;
		OutputStream out = null;
		InputStream in = null;

		try {
			socket = new Socket(ConfigUtil.get("hall.ip"),Integer.parseInt(ConfigUtil.get("hall.port")));
			socket.setSoTimeout(10 * 1000);
			out = socket.getOutputStream();
			in = socket.getInputStream();

			byte[] packet = notice2AllocRelease(groupId,level,uid,status);
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];

		}catch (Exception e) {

		} finally {
			if (out != null) {
				out.close();
			}
			if (in != null ) {
				in.close();
			}
			if (socket != null) {
				socket.close();
			}
		}

	}

	public static void notice2HallPublice(Long userId,JSONObject jsonObject) throws IOException {

		Socket socket = null;
		OutputStream out = null;
		InputStream in = null;

		try {
			socket = new Socket(ConfigUtil.get("hall.ip"),Integer.parseInt(ConfigUtil.get("hall.port")));
			socket.setSoTimeout(10 * 1000);
			out = socket.getOutputStream();
			in = socket.getInputStream();


			byte[] packet = notice2Hall(Integer.parseInt(userId.toString()), jsonObject.toJSONString());
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];
//			int read = in.read(b);
//			System.out.println(read + "socketread");

		}catch (Exception e) {

		} finally {
			if (out != null) {
				out.close();
			}
			if (in != null ) {
				in.close();
			}
			if (socket != null) {
				socket.close();
			}
		}

	}

	public static void notice2HallPubliceAllMember(Integer groupId,JSONObject jsonObject) throws IOException {

		Socket socket = null;
		OutputStream out = null;
		InputStream in = null;

		try {
			socket = new Socket(ConfigUtil.get("hall.ip"),Integer.parseInt(ConfigUtil.get("hall.port")));
			socket.setSoTimeout(10 * 1000);
			out = socket.getOutputStream();
			in = socket.getInputStream();


			byte[] packet = notice2HallAllMember(groupId, jsonObject.toJSONString());
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];
//			int read = in.read(b);
//			System.out.println(read + "socketread");

		}catch (Exception e) {

		} finally {
			if (out != null) {
				out.close();
			}
			if (in != null ) {
				in.close();
			}
			if (socket != null) {
				socket.close();
			}
		}

	}


	public static void notice2HallAboutClu(byte type,int cluId,int menberId) throws IOException {

		Socket socket = null;
		OutputStream out = null;
		InputStream in = null;

		try {
			socket = new Socket(ConfigUtil.get("hall.ip"),Integer.parseInt(ConfigUtil.get("hall.port")));
			socket.setSoTimeout(10 * 1000);
			out = socket.getOutputStream();
			in = socket.getInputStream();


			byte[] packet = notice2Hall(type,cluId,menberId);
			out.write(packet);
			out.flush();

			byte[] b = new byte[1024];
//			int read = in.read(b);
//			System.out.println(read + "socketread");

		}catch (Exception e) {

		} finally {
			if (out != null) {
				out.close();
			}
			if (in != null ) {
				in.close();
			}
			if (socket != null) {
				socket.close();
			}
		}

	}

	public static void notice2HallAboutCluConfig(Integer groupId, Integer configId,Integer gameType, String gameConfig,Byte type, String name) throws IOException {

		Socket socket = null;
		OutputStream out = null;
		InputStream in = null;

		try {
			socket = new Socket(ConfigUtil.get("hall.ip"),Integer.parseInt(ConfigUtil.get("hall.port")));
			socket.setSoTimeout(10 * 1000);
			out = socket.getOutputStream();
			in = socket.getInputStream();


			byte[] packet = notice2HallConfig(groupId,configId, gameType, gameConfig,type,name);
			out.write(packet);
			out.flush();

		}catch (Exception e) {

		} finally {
			if (out != null) {
				out.close();
			}
			if (in != null ) {
				in.close();
			}
			if (socket != null) {
				socket.close();
			}
		}

	}

	private static byte[] notice2HallConfig(Integer groupId, Integer configId,Integer gameType, String gameConfig, Byte type, String name) {

		List<Byte> list = initExchangeGold(0x05,0x87);

//		list.add(type);
		writeInt(list,type);
		writeInt(list, groupId);
		writeInt(list,configId);
		writeInt(list,gameType);
		writeString2(list, name);
		writeString2(list,gameConfig);


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

	public static void notice2HallAllPublice(int owerId, JSONArray jsonObject, String s) throws IOException {

		Socket socket = null;
		OutputStream out = null;
		InputStream in = null;

		try {
			socket = new Socket(ConfigUtil.get("hall.ip"),Integer.parseInt(ConfigUtil.get("hall.port")));
			socket.setSoTimeout(2 * 1000);
			out = socket.getOutputStream();
			in = socket.getInputStream();
			byte[] packet = notice2HallAllPeople(owerId, jsonObject,s);
			out.write(packet);
			out.flush();
			System.out.println("创建房间socked发送成功!!");
			byte[] b = new byte[1024];
//			int read = in.read(b);
//			System.out.println(read);

		}catch (Exception e) {

		} finally {
			if (out != null) {
				out.close();
			}
			if (in != null ) {
				in.close();
			}
			if (socket != null) {
				socket.close();
			}
		}

	}

	private static byte[] notice2Hall(int c, String s) {

		List<Byte> list = initExchangeGold();
		initCreateTableBody(list,c,s);
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

	private static byte[] notice2HallAllMember(int c, String s) {

		List<Byte> list = initExchangeGoldAllMember();
		initCreateTableBodyAllMember(list,c,s);
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

	private static byte[] notice2AllocRelease(Integer clubId, Integer level, Integer uid,Integer status) {

		List<Byte> list = new ArrayList<Byte>();
		addZeros(4, list);
		list.add((byte) 'B');
		list.add((byte) 'Y');
		list.add((byte) 0);
		list.add((byte) 1);

		addZeros(2, list);
		list.add((byte) 0x00);
		list.add((byte) 0x40);
		addZeros(2, list);
		addZeros(2, list);
		addZeros(1, list);
		addZeros(1, list);

		writeInt(list,clubId);
		writeInt(list,level);
		writeInt(list,uid);
		writeInt(list,status);

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

	private static byte[] notice2Hall(byte type,int cluId,int menberId) {

		List<Byte> list = initExchangeGold(0x01,0x65);
		initCreateTableBody(list,type,cluId,menberId);
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

	private static byte[] notice2HallAllPeople(int a, JSONArray n2p , String s) {

		List<Byte> list = initExchangeGold();
		initCreateTableBodyNotie(list,a,n2p,s);
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

	private static void initCreateTableBodyNotie(List<Byte> list, int userI,JSONArray ary, String s) {
		// uid
		writeInt(list,ary.size());
		for (int i =0 ; i<ary.size() ; i++) {
			String userId = ary.getJSONObject(i).getString("userId");
//			System.out.println(userId + "userId");
			if (StringUtil.isNotEmpty(userId)) {
				writeInt(list,Integer.parseInt(userId));
			}
		}
		writeString(list,s);
	}


	private static void initCreateTableBody(List<Byte> list, int userId,String s) {
		// uid
		writeInt(list,1);
		writeInt(list,userId);
//		writeInt(list,s.getBytes().length+1);
		writeString(list,s);
	}

	private static void initCreateTableBodyAllMember(List<Byte> list, int userId,String s) {
		// uid
		writeInt(list,userId);
//		writeInt(list,s.getBytes().length+1);
		writeString(list,s);
	}

	private static void initCreateTableBody(List<Byte> list, byte type,int cluId,int menberId) {

		list.add(type);
		writeInt(list,cluId);
		writeInt(list,menberId);
	}

	private static List<Byte> initExchangeGold() {
		List<Byte> list = new ArrayList<Byte>();
		addZeros(4, list);
		// BY
//		list.add((byte) 'Q');
//		list.add((byte) 'E');
		list.add((byte) 'B');
		list.add((byte) 'Y');
		// version
		list.add((byte) 0);
		list.add((byte) 1);

		// Cmd
		addZeros(2, list);
		list.add((byte) 0x01);
		list.add((byte) 0x68);

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

	private static List<Byte> initExchangeGoldAllMember() {
		List<Byte> list = new ArrayList<Byte>();
		addZeros(4, list);
		// BY
//		list.add((byte) 'Q');
//		list.add((byte) 'E');
		list.add((byte) 'B');
		list.add((byte) 'Y');
		// version
		list.add((byte) 0);
		list.add((byte) 1);

		// Cmd
		addZeros(2, list);
		list.add((byte) 0x01);
		list.add((byte) 0x69);

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
	private static List<Byte> initExchangeGold(int a,int b) {
		List<Byte> list = new ArrayList<Byte>();
		addZeros(4, list);
		// BY
//		list.add((byte) 'Q');
//		list.add((byte) 'E');
		list.add((byte) 'B');
		list.add((byte) 'Y');
		// version
		list.add((byte) 0);
		list.add((byte) 1);

		// Cmd
		addZeros(2, list);
		list.add((byte) a);
		list.add((byte) b);

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

//	private static String str2HexStr(byte[] bs) {
//		char[] chars = "0123456789ABCDEF".toCharArray();
//		StringBuilder sb = new StringBuilder("");
//		int bit;
//		for (int i = 0; i < bs.length; i++) {
//			bit = (bs[i] & 0x0f0) >> 4;
//			sb.append(chars[bit]);
//			bit = bs[i] & 0x0f;
//			sb.append(chars[bit]);
//		}
//		return sb.toString();
//	}
}
