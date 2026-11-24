package com.j.joker.game.niuniu.infrastructure;

import com.j.joker.game.niuniu.DouniuSettings;
import com.j.joker.game.niuniu.application.history.RoundRecord;
import com.j.joker.game.niuniu.domain.table.Settlement;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import org.springframework.core.env.Environment;

/** Java data 内部协议客户端，读取筹码并按整局提交余额。 */
public final class DataClient implements com.j.joker.game.niuniu.application.RoundAccounts {

    private final String host;
    private final int port;
    private final boolean enabled;

    public DataClient(Environment env) {
        host = env.getProperty("DATA_HOST", "data");
        port = env.getProperty("DATA_PORT", Integer.class, 6001);
        this.enabled = DouniuSettings.dataEnabled(env);
    }

    @Override public boolean enabled() {
        return enabled;
    }

    /** 取玩家筹码；数据不可用时返回 -1，调用方拒绝入房。 */
    @Override public long chips(int uid) {
        if (!enabled()) {
            return -1;
        }
        try (Socket socket = connect()) {
            write(socket, 0x1011, body -> {
                writeInt(body, 0);   // source
                writeInt(body, uid);
            });
            byte[] packet = read(socket);
            if (packet == null || cmd(packet) != 0x2011) {
                return -1;
            }
            ByteBuffer in = ByteBuffer.wrap(packet, 18, packet.length - 18);
            if (in.getInt() != uid || in.getInt() != 0) return -1;
            string(in);
            in.getInt();            // exp
            in.getInt();            // score
            in.getInt();            // wins
            in.getInt();            // losses
            return in.getInt();     // chips
        } catch (IOException | RuntimeException e) {
            return -1;
        }
    }

    /** 只有 data 确认同一整局回执后才能广播；超时继续使用原局号。 */
    @Override public boolean settle(java.util.UUID round, Settlement.Result result, RoundRecord record) {
        if (!enabled) return true;
        try (Socket socket = connect()) {
            write(socket, 0x1010, body -> {
                writeString(body, round.toString());
                writeInt(body, result.entries().size());
                for (var e : result.entries()) {
                    writeInt(body, Math.toIntExact(e.uid()));
                    writeInt(body, Math.toIntExact(e.before()));
                    writeInt(body, Math.toIntExact(e.before() + e.delta()));
                }
                body.write(record.json().getBytes(StandardCharsets.UTF_8));
            });
            byte[] packet = read(socket);
            return packet != null && packet.length == 22 && cmd(packet) == 0x2010
                    && ByteBuffer.wrap(packet).getInt(18) == 0;
        } catch (IOException | RuntimeException e) {
            return false;
        }
    }

    @Override public boolean isClubOwner(int club, long uid) {
        return clubAccess(0x1014, club, uid);
    }

    @Override public java.util.List<Integer> clubMembersAfter(int club, int after) {
        try (Socket socket = connect()) {
            write(socket, 0x1016, body -> { writeInt(body,club); writeInt(body,after); });
            byte[] packet = read(socket);
            if (packet == null || cmd(packet) != 0x2016 || packet.length < 22) throw new IOException("联盟成员响应无效");
            var in = ByteBuffer.wrap(packet,18,packet.length-18);
            int count = in.getInt();
            if (count < 0 || count > 256 || in.remaining() != count * 4) throw new IOException("联盟成员数量无效");
            var result = new java.util.ArrayList<Integer>(count);
            for (int i=0;i<count;i++) result.add(in.getInt());
            return result;
        } catch (IOException e) { throw new java.io.UncheckedIOException(e); }
    }

    @Override public boolean isClubMember(int club, long uid) {
        return clubAccess(0x1015, club, uid);
    }

    private boolean clubAccess(int command, int club, long uid) {
        if (!enabled) return true;
        try (Socket socket = connect()) {
            write(socket, command, body -> {
                writeInt(body, club);
                writeInt(body, Math.toIntExact(uid));
            });
            byte[] packet = read(socket);
            return packet != null && packet.length == 22 && cmd(packet) == command + 0x1000
                    && ByteBuffer.wrap(packet).getInt(18) == 1;
        } catch (IOException | RuntimeException unavailable) {
            return false;
        }
    }



    @Override public History history(int activity, int level, int index) {
        try (Socket socket = connect()) {
            write(socket, 0x1012, body -> {
                writeInt(body, activity);
                writeInt(body, level);
                writeInt(body, index);
            });
            byte[] packet = read(socket);
            if (packet == null || cmd(packet) != 0x2012 || packet.length < 22) return null;
            int latest = ByteBuffer.wrap(packet).getInt(18);
            var record = packet.length == 22 ? null : RoundRecord.parse(new String(packet, 22, packet.length - 22, StandardCharsets.UTF_8));
            return new History(latest, record);
        } catch (IOException | RuntimeException e) {
            return null;
        }
    }

    @Override public java.util.Map<String,Object> billboard(int activity, int level, int rounds) {
        try (Socket socket = connect()) {
            write(socket, 0x1013, body -> {
                writeInt(body, activity);
                writeInt(body, level);
                writeInt(body, rounds);
            });
            byte[] packet = read(socket);
            if (packet == null || cmd(packet) != 0x2013 || packet.length == 18) return null;
            return com.j.joker.game.niuniu.util.Json.parseObject(new String(packet, 18, packet.length - 18, StandardCharsets.UTF_8));
        } catch (IOException | RuntimeException unavailable) {
            return null;
        }
    }

    private Socket connect() throws IOException {
        Socket socket = new Socket();
        try {
            socket.connect(new InetSocketAddress(host, port), 1500);
            socket.setTcpNoDelay(true);
            socket.setSoTimeout(1500);
            return socket;
        } catch (IOException e) {
            socket.close();
            throw e;
        }
    }

    private interface Body {
        void write(ByteArrayOutputStream out) throws IOException;
    }

    private static void write(Socket socket, int command, Body body) throws IOException {
        ByteArrayOutputStream payload = new ByteArrayOutputStream();
        body.write(payload);
        byte[] bytes = payload.toByteArray();
        ByteBuffer header = ByteBuffer.allocate(18 + bytes.length);
        header.putInt(14 + bytes.length).putShort((short) 0x4259).putShort((short) 0)
                .putInt(command).putInt(0).putShort((short) 0).put(bytes);
        socket.getOutputStream().write(header.array());
        socket.getOutputStream().flush();
    }

    private static byte[] read(Socket socket) throws IOException {
        DataInputStream in = new DataInputStream(socket.getInputStream());
        byte[] head = new byte[4];
        in.readFully(head);
        int length = ByteBuffer.wrap(head).getInt();
        int total = length + 4;
        if (total < 18 || total > 65536) {
            return null;
        }
        byte[] packet = new byte[total];
        System.arraycopy(head, 0, packet, 0, 4);
        in.readFully(packet, 4, total - 4);
        return packet;
    }

    private static int cmd(byte[] packet) {
        ByteBuffer header = ByteBuffer.wrap(packet);
        return header.getShort(4) == 0x4259 ? header.getInt(8) : -1;
    }

    private static String string(ByteBuffer in) {
        int size = in.getInt();
        if (size < 1 || size > in.remaining()) throw new IllegalArgumentException("错误的数据长度");
        byte[] bytes = new byte[size - 1];
        in.get(bytes);
        in.get(); // trailing NUL
        return new String(bytes, StandardCharsets.ISO_8859_1);
    }

    private static void writeInt(ByteArrayOutputStream out, int value) throws IOException {
        out.write(ByteBuffer.allocate(4).putInt(value).array());
    }

    private static void writeString(ByteArrayOutputStream out, String value) throws IOException {
        byte[] bytes = value.getBytes(StandardCharsets.ISO_8859_1);
        out.write(ByteBuffer.allocate(4).putInt(bytes.length + 1).array());
        out.write(bytes);
        out.write(0);
    }
}
