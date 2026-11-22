package com.j.joker.utils;

import com.j.joker.core.util.ApplicationContextHelper;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.ICache;
import com.j.joker.cache.controller.GameCacheController;
import com.j.joker.model.TMemdataServer;
import org.apache.log4j.Logger;

import java.net.Socket;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Created by ceeuoo on 3/24/2016.
 */
public class SocketPool {
    private static Logger LOG = Logger.getLogger(SocketPool.class);
    private static String ip;
    //private static String hallip;
    private static List<Socket> socketList = null;
    //private static List<Socket> hallSocketList = null;
    private static final int SOCKET_POOL_SIZE = 30;                              //每个池总共10个连接
    private static String port;                    //端口
    //private static String hallport;                    //端口

    static {
        ICache cache = null;
        try {
            cache = CacheManager.getCache();
            GameCacheController gameCacheController = (GameCacheController) ApplicationContextHelper.getBean("gameCacheController");
            TMemdataServer server = gameCacheController.queryMemdataServer(cache);
            ip = server.getMemdataServerIp();
            port = server.getPort().toString();

            //hallip = ConfigUtil.get("hall.ip");
            //hallport = ConfigUtil.get("hall.port");
        } catch (Exception e) {
            LOG.error(e);
        } finally {
            if (cache != null) {
                CacheManager.releaseCache(cache);
            }
        }
    }

    public static void initSockets() {
        if(socketList != null) {
            return;
        }
        socketList = new ArrayList<Socket>();
//        socketList = Collections.synchronizedList(new ArrayList());
        try {
            for(int i=0; i < SOCKET_POOL_SIZE; i++){
                Socket socket = new Socket(ip, Integer.parseInt(port));
                socket.setSoTimeout(10 * 1000);
                socketList.add(socket);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);  //抛出
        }
    }


//    public static void initHallSockets() {
//        if(hallSocketList != null) {
//            return;
//        }
//        hallSocketList = new ArrayList<Socket>();
////        socketList = Collections.synchronizedList(new ArrayList());
//        try {
//            for(int i=0; i < SOCKET_POOL_SIZE; i++){
//                Socket socket = new Socket(hallip, Integer.parseInt(hallport));
//                socket.setSoTimeout(10 * 1000);
//                hallSocketList.add(socket);
//            }
//        } catch (Exception e) {
//            throw new RuntimeException(e);  //抛出
//        }
//    }

    public static Socket getSocket() throws Exception{
        if(socketList == null) {
            initSockets();
        }
        synchronized (socketList) {
            while(socketList.isEmpty()) {
                Thread.sleep(3, new Random().nextInt(500));
            }
            Socket socket = socketList.get(0);
            socketList.remove(0);
            if (socket.isClosed()) {
                socket = new Socket(ip, Integer.parseInt(port));
                socket.setSoTimeout(10 * 1000);
            }
            return socket;
        }
    }

    //public static Socket getHallSocket() throws Exception{
    //    if(hallSocketList == null) {
    //        initHallSockets();
    //    }
    //    synchronized (hallSocketList) {
    //        while(hallSocketList.isEmpty()) {
    //            Thread.sleep(3, new Random().nextInt(500));
    //        }
    //        Socket socket = hallSocketList.get(0);
    //        hallSocketList.remove(0);
    //        if (socket.isClosed()) {
    //            socket = new Socket(hallip, Integer.parseInt(hallport));
    //            socket.setSoTimeout(10 * 1000);
    //        }
    //        return socket;
    //    }
    //}

    public static void returnSocket(Socket socket) {
        socketList.add(socket);
    }
    //public static void returnHallSocket(Socket socket) {
    //    hallSocketList.add(socket);
    //}
}
