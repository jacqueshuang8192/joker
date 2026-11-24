package com.j.joker.game.niuniu.config;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * 对应 Douniu/bin/server.xml 的运行配置。
 *
 * <pre>
 * &lt;SYSTEM&gt;
 *   &lt;GameServer ip="127.0.0.1" nEnableLogUserOp="1" logdir="../log/" nSameIPLimit="0"/&gt;
 *   &lt;RedisList&gt;&lt;Redis redisId="0" ip="127.0.0.1" port="6379"/&gt;...&lt;/RedisList&gt;
 *   &lt;BCastServer ip=".." port="9002"/&gt;
 *   &lt;CMDataServer ip=".." port="6001"/&gt;
 *   &lt;CPropServer ip=".." port="6101"/&gt;
 *   &lt;LogServer ip=".." port="6101"/&gt;
 *   &lt;DB ip=".." port="3306" user=".." pwd=".." tableName=".." dbName=".." dbNum="1" tableNum="10"/&gt;
 *   &lt;PROTO RegionID="0"/&gt;
 *   &lt;ROOM&gt;&lt;Level value="302"/&gt;&lt;AllocServer ip=".." port="11603"/&gt;&lt;/ROOM&gt;
 *   &lt;MaxPlayerCount value="3"/&gt;
 * &lt;/SYSTEM&gt;
 * </pre>
 */
public final class RoomConfig {

    public record Endpoint(String ip, int port) {
    }

    public record RedisConf(int id, String ip, int port) {
    }

    public record DbConf(String ip, int port, String user, String pwd, String dbName, String tableName,
                         int dbNum, int tableNum) {
    }

    private String gameServerIp = "127.0.0.1";
    private boolean logUserOp;
    private String logDir = "../log/";
    private int sameIpLimit;
    private final List<RedisConf> redisList = new ArrayList<>();
    private Endpoint bcastServer = new Endpoint("127.0.0.1", 9002);
    private Endpoint cmDataServer = new Endpoint("127.0.0.1", 6001);
    private Endpoint propServer = new Endpoint("127.0.0.1", 6101);
    private Endpoint logServer = new Endpoint("127.0.0.1", 6101);
    private DbConf db;
    private int regionId;
    private int level = 302;
    private Endpoint allocServer = new Endpoint("127.0.0.1", 11603);
    private int maxPlayerCount = 3;

    public static RoomConfig load(Path xml) throws Exception {
        DocumentBuilderFactory f = DocumentBuilderFactory.newInstance();
        DocumentBuilder b = f.newDocumentBuilder();
        Document doc = b.parse(xml.toFile());
        doc.getDocumentElement().normalize();
        RoomConfig c = new RoomConfig();
        Element root = doc.getDocumentElement();

        Element gs = first(root, "GameServer");
        if (gs != null) {
            c.gameServerIp = attr(gs, "ip", c.gameServerIp);
            c.logUserOp = "1".equals(attr(gs, "nEnableLogUserOp", "0"));
            c.logDir = attr(gs, "logdir", c.logDir);
            c.sameIpLimit = Integer.parseInt(attr(gs, "nSameIPLimit", "0"));
        }
        for (Element r : all(root, "Redis")) {
            c.redisList.add(new RedisConf(
                    Integer.parseInt(attr(r, "redisId", "0")),
                    attr(r, "ip", "127.0.0.1"),
                    Integer.parseInt(attr(r, "port", "6379"))));
        }
        Element bc = first(root, "BCastServer");
        if (bc != null) {
            c.bcastServer = new Endpoint(attr(bc, "ip", "127.0.0.1"), Integer.parseInt(attr(bc, "port", "9002")));
        }
        Element cm = first(root, "CMDataServer");
        if (cm != null) {
            c.cmDataServer = new Endpoint(attr(cm, "ip", "127.0.0.1"), Integer.parseInt(attr(cm, "port", "6001")));
        }
        Element pp = first(root, "CPropServer");
        if (pp != null) {
            c.propServer = new Endpoint(attr(pp, "ip", "127.0.0.1"), Integer.parseInt(attr(pp, "port", "6101")));
        }
        Element lg = first(root, "LogServer");
        if (lg != null) {
            c.logServer = new Endpoint(attr(lg, "ip", "127.0.0.1"), Integer.parseInt(attr(lg, "port", "6101")));
        }
        Element dbEl = first(root, "DB");
        if (dbEl != null) {
            c.db = new DbConf(
                    attr(dbEl, "ip", "127.0.0.1"),
                    Integer.parseInt(attr(dbEl, "port", "3306")),
                    attr(dbEl, "user", ""),
                    attr(dbEl, "pwd", ""),
                    attr(dbEl, "dbName", ""),
                    attr(dbEl, "tableName", ""),
                    Integer.parseInt(attr(dbEl, "dbNum", "1")),
                    Integer.parseInt(attr(dbEl, "tableNum", "10")));
        }
        Element proto = first(root, "PROTO");
        if (proto != null) {
            c.regionId = Integer.parseInt(attr(proto, "RegionID", "0"));
        }
        Element room = first(root, "ROOM");
        if (room != null) {
            Element lv = first(room, "Level");
            if (lv != null) {
                c.level = Integer.parseInt(attr(lv, "value", "302"));
            }
            Element alloc = first(room, "AllocServer");
            if (alloc != null) {
                c.allocServer = new Endpoint(attr(alloc, "ip", "127.0.0.1"), Integer.parseInt(attr(alloc, "port", "11603")));
            }
        }
        Element mpc = first(root, "MaxPlayerCount");
        if (mpc != null) {
            c.maxPlayerCount = Integer.parseInt(attr(mpc, "value", "3"));
        }
        return c;
    }

    private static Element first(Element parent, String tag) {
        NodeList list = parent.getElementsByTagName(tag);
        return list.getLength() == 0 ? null : (Element) list.item(0);
    }

    private static List<Element> all(Element parent, String tag) {
        List<Element> out = new ArrayList<>();
        NodeList list = parent.getElementsByTagName(tag);
        for (int i = 0; i < list.getLength(); i++) {
            Node n = list.item(i);
            if (n instanceof Element e) {
                out.add(e);
            }
        }
        return out;
    }

    private static String attr(Element e, String name, String def) {
        String v = e.getAttribute(name);
        return v == null || v.isEmpty() ? def : v;
    }

    public String gameServerIp() { return gameServerIp; }
    public boolean logUserOp() { return logUserOp; }
    public String logDir() { return logDir; }
    public int sameIpLimit() { return sameIpLimit; }
    public List<RedisConf> redisList() { return redisList; }
    public Endpoint bcastServer() { return bcastServer; }
    public Endpoint cmDataServer() { return cmDataServer; }
    public Endpoint propServer() { return propServer; }
    public Endpoint logServer() { return logServer; }
    public DbConf db() { return db; }
    public int regionId() { return regionId; }
    public int level() { return level; }
    public Endpoint allocServer() { return allocServer; }
    public int maxPlayerCount() { return maxPlayerCount; }
}
