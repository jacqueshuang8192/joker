package com.j.joker.game.niuniu.interfaces.tcp;

import com.j.joker.game.niuniu.application.DouniuService;
import com.j.joker.game.niuniu.proto.*;
import com.j.joker.game.niuniu.util.Json;
import com.j.joker.game.rooms.application.Lobby;
import com.j.joker.game.hundred.interfaces.HundredHall;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;

/** 纯 Java 大厅复用房间协议会话，同一连接从选桌进入牌局。 */
public final class HallProtocol extends DouniuProtocol implements Lobby.Connection {
    private final DouniuService rooms;
    private final Lobby lobby;
    private final String address;
    private final int port, level;
    private final HundredHall hundred;
    private int uid, selected, subscribedClub;
    private String key;
    private ChannelHandlerContext channel;

    public HallProtocol(DouniuService service, Lobby lobby, String address, int port, int level,HundredHall hundred) {
        super(service);
        this.hundred = hundred;
        this.rooms = service;
        this.lobby = lobby;
        this.address = address;
        this.port = port;
        this.level = level;
    }

    @Override public void channelActive(ChannelHandlerContext ctx) {
        super.channelActive(ctx);
        channel = ctx;
    }

    @Override public void channelInactive(ChannelHandlerContext ctx) {
        hundred.disconnect(selected,uid,this);
        lobby.logout(uid, this);
        super.channelInactive(ctx);
    }

    @Override public void disconnect() { channel.close(); }

    @Override public void membershipChanged(int club) {
        if (subscribedClub==club) reply(0x178,new BinaryWriter().i32(club).i32(rooms.clubRoomCount(uid,club)));
    }

    private void selectedRoom(com.j.joker.game.rooms.domain.RoomRoute route,int mode) {
        selected=route.tid();
        reply(0x210,new BinaryWriter().i32(selected).u16(selected >>> 16).string(address).i32(port)
                .i32(1).u16(level).u8(route.seats()).i32(route.activity()).string(route.rules()).string("").u8(mode));
    }

    private void publicTables(int requested) {
        var rows = new BinaryWriter();
        int count = 0;
        if (requested == level) {
            for (var table : rooms.publicTables()) {
                var route = table.route();
                var row = new BinaryWriter().i32(route.tid()).i32(route.activity()).string(route.invite()).string(table.name())
                        .u8(table.seats().size()).i32(table.minimum()).i32(route.base()).u8(route.seats())
                        .i32(route.owner()).string(table.ownerName()).string(table.portrait()).i32(0).u8(table.seats().size());
                table.seats().forEach(row::i32);
                // 老客户端只接受单帧列表。为每行预留空密码字段与整帧头部。
                if (rows.size() + row.size() + (count + 1) * 5 + 32 > 10240) break;
                rows.bytes(row.toByteArray());
                count++;
            }
        }
        boolean hundredLevel = requested==101 || requested==102;
        if (hundredLevel) {
            for (int i=1;i<=2;i++) {
                int tid=requested*65536+i;
                rows.i32(tid).i32(tid).string(Integer.toString(tid)).string(i==1?"经典桌":"拼庄桌")
                        .u8(0).i32(0).i32(1).u8(100).i32(0).string("").string("").i32(0).u8(0);
                count++;
            }
        }
        var body = new BinaryWriter().u8(requested == level || hundredLevel ? 0 : 1).u16(count).bytes(rows.toByteArray());
        for (int i = 0; i < count; i++) body.string("");
        reply(0x151, body);
    }

    private void reply(int cmd, BinaryWriter body) { notice(cmd, body.toByteArray()); }

    @Override public void notice(int cmd, byte[] payload) {
        channel.writeAndFlush(Unpooled.wrappedBuffer(PacketCodec.encode(cmd, 1, 0, 0, 0, payload)));
    }

    @Override void handleFrame(ChannelHandlerContext ctx, PacketCodec.Frame frame, byte[] wire) {
        int cmd = frame.cmd();
        var in = new BinaryReader(frame.body());
        if (cmd == 0x110 && (in.remaining() == 4 || in.remaining() == 0)) {
            ctx.writeAndFlush(Unpooled.wrappedBuffer(wire));
        } else if (cmd == 0x116) {
            int account = in.i32();
            in.i32(); in.u8();
            String proof = (String)Json.parseObject(in.string()).get("roomKey");
            if (in.remaining() != 0 || uid != 0 || !lobby.login(account, proof, this)) { ctx.close(); return; }
            uid = account;
            key = proof;
            var route = lobby.current(uid);
            var result = new BinaryWriter().i32(1).i32(0).i32(0).i32(route == null ? 0 : route.tid());
            if (route == null) result.string("").i32(0).i16(-1);
            reply(0x201, result.i32(0).i32(0).u8(0));
            String ip = com.j.joker.game.ProxyPeer.observed(ctx.channel());
            if (ip != null) {
                lobby.peer(uid, ip, this);
                reply(0x202, new BinaryWriter().string(ip));
            }
        } else if (uid == 0) {
            ctx.close();
        } else if (cmd == 0x668) {
            var route = lobby.current(uid);
            var result = new BinaryWriter();
            if (route == null) result.u16(0).i32(0).i32(0).i32(0).u8(0);
            else result.u16(level).i32(route.tid()).i32(route.activity()).i32(route.base()).u8(lobby.mode(uid, route));
            reply(cmd, result);
        } else if (cmd == 0x106 || cmd == 0x107) {
            // 旧用户服对这两种场景切换均无回包，实际入座与退座由牌桌确认。
            if (cmd==0x107) subscribedClub=0;
        } else if (cmd == 0x311 && in.remaining()==0) {
            int count=rooms.occupancy().values().stream().mapToInt(Integer::intValue).sum();
            var online=new BinaryWriter().u8(3).i32(level).i32(count);
            for(int hundredLevel:new int[]{101,102}) online.i32(hundredLevel).i32(hundred.count(hundredLevel));
            reply(cmd,online);
        } else if (cmd == 0x1188) {
            String latitude=in.string(), longitude=in.string();
            in.string();
            if (in.remaining()==0) lobby.location(uid,key,this,latitude,longitude);
        } else if (cmd == 0x1189 && in.remaining()==4) {
            if (subscribedClub==in.i32()) subscribedClub=0;
        } else if (cmd == 0x177 && in.remaining()==12) {
            int club=in.i32(),target=in.i32(),status=in.i32();
            boolean changed=lobby.currentSession(uid,key,this) && rooms.disableClubPlayer(uid,club,target,status);
            reply(cmd,new BinaryWriter().i32(changed ? 1 : 0));
        } else if (cmd == 0x179 && in.remaining()==10) {
            int requested=in.u16(),club=in.i32(),template=in.i32();
            var route=requested==level && lobby.currentSession(uid,key,this) ? rooms.quickJoin(uid,club,template, r -> lobby.requestInvitation(uid,key,this,r)) : null;
            if (route==null) reply(cmd,new BinaryWriter().u16(requested).i32(club).i32(template));
            else selectedRoom(route,1);
        } else if (cmd == 0x188 && in.remaining()==12) {
            int club=in.i32(), page=in.i32(), size=in.i32();
            if (lobby.currentSession(uid,key,this)) {
                for (var member : rooms.onlineClubMembers(uid,club,page,size,lobby::online)) {
                    reply(cmd,new BinaryWriter().i32(club).i32(member.uid()).i32(lobby.current(member.uid())==null ? 0 : 1)
                            .string(member.name()).string(member.portrait()));
                }
            }
            reply(0x189,new BinaryWriter().i32(uid));
        } else if (cmd == 0x190) {
            int target=in.i32(), club=in.i32(), tid=in.i32(), activity=in.i32(), requested=in.i32();
            in.string(); in.string(); in.string();
            if (requested!=level || in.remaining()!=0 || !lobby.currentSession(uid,key,this)
                    || !lobby.online(target) || lobby.current(target)!=null) return;
            var invitation=rooms.invitation(uid,target,club,tid,activity);
            if (invitation!=null) {
                var message=new BinaryWriter().i32(uid).i32(club).i32(tid).i32(activity).i32(level)
                        .string(invitation.sender().name()).string(invitation.sender().portrait()).string(invitation.config());
                lobby.deliver(target,connection -> connection.notice(cmd,message.toByteArray()));
            }
        } else if (cmd == 0x155 && in.remaining()==4) {
            int tid=in.i32();
            int result=lobby.currentSession(uid,key,this) ? rooms.dissolveFromHall(uid,tid) : -1;
            if (channel.channel().isActive()) reply(0x361,new BinaryWriter().i32(0).i32(result));
        } else if (cmd == 0x172) {
            int club = in.i32(), type = in.i32(), page = in.i32(), size = in.i32();
            int game = in.i32(), config = in.i32();
            in.string(); in.string();
            subscribedClub=club;
            for (var table : rooms.clubTables(uid, club, type, page, size, game, config)) {
                var row = new BinaryWriter().i32(club).i32(table.full() ? 1 : 0).i32(table.tid()).i32(level).i32(table.configId())
                        .i32(table.gameType()).i32(table.round()).u8(table.users().size());
                table.users().forEach(row::string);
                reply(0x175, row.string(table.name()).string(table.invite()));
            }
            reply(0x174, new BinaryWriter().u8(1).u8(0));
        } else if (cmd == 0x113) {
            int requestedLevel = in.u16();
            in.i32(); in.i32();
            int tid = in.i32(), activity = in.i32();
            in.i32();
            int mode = in.u8();
            in.i32(); // 距离阈值取自建桌模板。
            String latitude = in.string(), longitude = in.string();
            if (HundredHall.supports(tid) && tid>>>16==requestedLevel && in.remaining()==0 && (activity==0 || activity==tid)
                    && mode<=1 && session.uid()==0 && lobby.current(uid)==null && lobby.currentSession(uid,key,this)) {
                if (selected!=tid) hundred.disconnect(selected,uid,this);
                selected=tid;
                reply(0x210,new BinaryWriter().i32(tid).u16(requestedLevel).string(address).i32(4700)
                        .i32(1).u16(requestedLevel).u8(100).i32(tid).string("{}").string("").u8(mode));
                return;
            }
            if (in.remaining() == 0 && requestedLevel == level && mode == 1 && lobby.canCheckSeat(uid,key,tid,activity,this)) {
                lobby.location(uid,key,this,latitude,longitude);
                int refused = rooms.seatRefusal(uid, tid);
                if (refused != 0) { reply(0x212, new BinaryWriter().u16(0).u16(refused)); return; }
            }
            var route = mode <= 1 && in.remaining() == 0
                    ? lobby.select(uid, key, requestedLevel, tid, activity, this) : null;
            if (route == null) { reply(0x212, new BinaryWriter().u16(0).u16(1)); return; }
            hundred.disconnect(selected,uid,this);
            selectedRoom(route,mode);
        } else if (cmd == 0x1001) {
            if (in.i32() != selected || in.i32() != uid) { ctx.close(); return; }
            if (HundredHall.supports(selected)) {
                if (!lobby.currentSession(uid,key,this)) {ctx.close(); return;}
                try { hundred.join(selected,uid,in,this); }
                catch(java.io.IOException | IllegalArgumentException failed) { ctx.close(); }
            } else super.handleFrame(ctx, frame, wire);
        } else if (cmd == 0x151 && in.remaining() == 2 && lobby.currentSession(uid,key,this)) {
            publicTables(in.u16());
        } else if (cmd == 0x153) {
            reply(cmd, new BinaryWriter());
        } else if (HundredHall.supports(selected)) {
            if (!lobby.currentSession(uid,key,this)) {ctx.close(); return;}
            try {
                hundred.handle(selected,uid,this,cmd,in);
                if (cmd==0x1033) selected=0;
            } catch(java.io.IOException unavailable) { ctx.close(); }
        } else if (session.uid() > 0) {
            super.handleFrame(ctx, frame, wire);
        }
    }
}
