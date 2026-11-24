package com.j.joker;

import com.j.joker.impl.groupgame.GroupGameImpl;

/** 在隔离测试环境中使用 API 的实际建桌和解散客户端。 */
public class NativeRoomCheck {
    public static void main(String[] args) throws Exception {
        int port = args.length == 0 ? 11603 : Integer.parseInt(args[1]);
        if (args.length > 0 && args[0].equals("close")) {
            var alloc = new GroupGameImpl("127.0.0.1", port, new byte[]{0x01, 0x55});
            int code = alloc.dissolveRoom(Long.parseLong(args[2]), Integer.parseInt(args[3]));
            System.out.println("ROOM_CLOSE=" + code);
            return;
        }
        long activity = args.length == 0 ? 851 : Long.parseLong(args[2]);
        int rounds = args.length < 4 ? 10 : Integer.parseInt(args[3]);
        var alloc = new GroupGameImpl("127.0.0.1", port, new byte[]{0x01, 0x60});
        int table = alloc.createRoom(851L, 302, 2, 10, "851001", activity, rounds,
                "{\"level\":302,\"gameId\":302,\"baseChip\":2,\"maxSeatCount\":6,\"round\":10,\"showCardNums\":3,\"subGameType\":1}",
                "ci", "ci", 0, 6, "fixture", "", "", 0, 0, 15, "ci");
        if (table <= 0) throw new AssertionError("alloc create returned " + table);
        System.out.println("Verified native alloc created table " + table);
        System.out.println("ROOM_TABLE=" + table);
    }
}
