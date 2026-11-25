package com.j.joker.game;

import io.netty.channel.Channel;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.handler.codec.haproxy.*;
import io.netty.util.AttributeKey;
import io.netty.util.NetUtil;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

/** 仅对明确配置的 TCP 对端启用 PROXY 协议。普通游戏连接仍以 BY 帧开头。 */
public final class ProxyPeer {
    private static final AttributeKey<String> PLAYER_IP = AttributeKey.valueOf("joker.player.ip");

    static Set<String> trusted(String config) {
        if (config == null || config.isBlank()) return Set.of();
        return Arrays.stream(config.split(",", -1)).map(String::trim).map(ProxyPeer::literal)
                .collect(Collectors.toUnmodifiableSet());
    }

    static String literal(String value) {
        if (value == null || !NetUtil.isValidIpV4Address(value) && !NetUtil.isValidIpV6Address(value)
                || value.contains("%") || value.startsWith("[")) throw new IllegalArgumentException("需要 IP 地址");
        try {
            return InetAddress.getByAddress(NetUtil.createByteArrayFromIpAddressString(value)).getHostAddress();
        } catch (UnknownHostException invalid) { throw new IllegalArgumentException("IP 地址无效", invalid); }
    }

    public static String observed(Channel channel) {
        String forwarded = channel.attr(PLAYER_IP).get();
        if (forwarded != null) return forwarded;
        if (channel.remoteAddress() instanceof InetSocketAddress addr && addr.getAddress()!=null)
            return addr.getAddress().getHostAddress();
        return null;
    }

    static void install(Channel channel, Set<String> gateways) {
        if (gateways.isEmpty() || !gateways.contains(observed(channel))) return;
        channel.pipeline().addLast(new HAProxyMessageDecoder(), new SimpleChannelInboundHandler<HAProxyMessage>() {
            @Override protected void channelRead0(ChannelHandlerContext ctx, HAProxyMessage message) {
                if (message.protocolVersion() != HAProxyProtocolVersion.V1 || message.command() != HAProxyCommand.PROXY
                        || (message.proxiedProtocol() != HAProxyProxiedProtocol.TCP4 && message.proxiedProtocol() != HAProxyProxiedProtocol.TCP6)) {
                    ctx.close();
                    return;
                }
                channel.attr(PLAYER_IP).set(literal(message.sourceAddress()));
                ctx.pipeline().remove(this);
            }
            @Override public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) { ctx.close(); }
        });
    }
}
