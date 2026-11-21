package com.hbi.utils;

import com.core.util.ConfigUtil;

import java.net.Socket;
import java.util.Hashtable;

/**
 * Created by ceeuoo on 3/25/2016.
 */
public class OldConnectionPool {
    private static final String GAME_SERVER_IP = ConfigUtil.get("oldgame.ip");
    private static OldConnectionPool self = null;
    private static final int BASE_PORT = 3201;                         //基础端口号
    private static Hashtable<Integer, SocketPool> socketPoolTable = null;          //连接池
    private static final int CONNECTION_POOL_SIZE = 10;                //总共10个Socket池，按端口号划分

    public static synchronized void init() {
        self = new OldConnectionPool();
        self.socketPoolTable = new Hashtable<Integer, SocketPool>();
        buildConnection();
    }

    public static void buildConnection() {
        if (self.socketPoolTable == null) {
            init();
        }
        for(int i = 0; i< CONNECTION_POOL_SIZE; i++) {
//            socketPoolTable.put(i, new SocketPool(GAME_SERVER_IP, BASE_PORT + i));
        }
    }

    public static Socket getSocket(Long userId) throws Exception{
        if (self.socketPoolTable == null) {
            init();
        }
        int port = userId.intValue() % 10;
        SocketPool socketPool = socketPoolTable.get(port);
        return socketPool.getSocket();
    }

    public static void returnSocket(Long userId, Socket socket) {
        if (self.socketPoolTable == null) {
            init();
        }
        int port = userId.intValue() % 10;
        SocketPool socketPool = socketPoolTable.get(port);
        socketPool.returnSocket(socket);
    }

}
