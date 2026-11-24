package com.j.joker.game.rooms.interfaces.tcp;

import com.j.joker.game.rooms.application.Lobby;
import com.j.joker.game.niuniu.application.RoundAccounts;
import com.j.joker.game.niuniu.proto.BinaryReader;
import com.j.joker.game.niuniu.proto.BinaryWriter;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import java.util.function.Consumer;

/** API 推送走独立的回环监听器。联盟订阅接收者以业务库成员关系为准。 */
public final class LobbyNoticeProtocol extends SimpleChannelInboundHandler<ByteBuf> {
    private final Lobby lobby;
    private final RoundAccounts accounts;
    public LobbyNoticeProtocol(Lobby lobby, RoundAccounts accounts) { this.lobby = lobby; this.accounts = accounts; }

    private void members(int club, Consumer<Lobby.Connection> deliver) {
        int after = 0;
        while (club > 0) {
            var members = accounts.clubMembersAfter(club, after);
            if (members.isEmpty()) return;
            for (int uid : members) {
                if (uid <= after) throw new IllegalStateException("联盟成员列表顺序无效");
                lobby.deliver(uid, deliver);
                after = uid;
            }
            if (members.size() < 256) return;
        }
    }

    @Override protected void channelRead0(ChannelHandlerContext ctx, ByteBuf frame) {
        if (frame.readableBytes() < 18 || frame.getShort(4) != 0x4259) { ctx.close(); return; }
        int cmd = frame.getInt(8);
        frame.skipBytes(18);
        byte[] body = new byte[frame.readableBytes()];
        frame.readBytes(body);
        var in = new BinaryReader(body);
        switch (cmd) {
            case 0x168 -> {
                int n = in.i32();
                if (n < 1 || (long)n * 4 > in.remaining() - 4) { ctx.close(); return; }
                int[] recipients = new int[n];
                for (int i=0; i<n; i++) recipients[i]=in.i32();
                String message = in.string();
                for (int uid : recipients) lobby.deliver(uid, c -> c.notice(cmd,new BinaryWriter().i32(uid).string(message).toByteArray()));
            }
            case 0x169 -> {
                int club = in.i32();
                String message = in.string();
                byte[] packet = new BinaryWriter().i32(club).string(message).toByteArray();
                members(club, c -> c.notice(cmd,packet));
            }
            case 0x587 -> {
                int action = in.i32(), club = in.i32(), template = in.i32(), game = in.i32();
                String name = in.string(), rules = in.string();
                var packet = new BinaryWriter().i32(club).i32(template).i32(game).string(rules).u8(action).string(name);
                members(club, c -> c.notice(cmd,packet.toByteArray()));
            }
            default -> ctx.close();
        }
    }
    @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) { ctx.close(); }
}
