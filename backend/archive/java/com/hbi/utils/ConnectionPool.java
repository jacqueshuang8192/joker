//package com.hbi.utils;
//
//import com.core.util.ConfigUtil;
//
//import java.net.Socket;
//import java.util.Hashtable;
//
///**
// * Created by ceeuoo on 3/25/2016.
// */
//public class ConnectionPool {
//    private static final String GAME_SERVER_IP = ConfigUtil.get("game.ip");
//    private static ConnectionPool self = null;
//    private static final int BASE_PORT = 6001;                                     //基础端口号
//    private static Hashtable<Integer, SocketPool> socketPoolTable = null;          //连接池
//    private static final int CONNECTION_POOL_SIZE = 1;                            //总共1个Socket池，按端口号划分
//
//    public static synchronized void init() {
//        self = new ConnectionPool();
//        self.socketPoolTable = new Hashtable<Integer, SocketPool>();
//        buildConnection();
//    }
//
//    public static void buildConnection() {
//        if (self.socketPoolTable == null) {
//            init();
//        }
//        for(int i = 0; i< CONNECTION_POOL_SIZE; i++) {
//            socketPoolTable.put(BASE_PORT + i, new SocketPool(GAME_SERVER_IP, BASE_PORT));
//        }
//    }
//
//    public static Socket getSocket() throws Exception{
//        if (self == null) {
//            init();
//        }
//        SocketPool socketPool = socketPoolTable.get(BASE_PORT);
//        return socketPool.getSocket();
//    }
//
//    public static void returnSocket(Socket socket) {
//        if (self == null) {
//            init();
//        }
//        SocketPool socketPool = socketPoolTable.get(BASE_PORT);
//        socketPool.returnSocket(socket);
//    }
//
//}
