import java.io.ByteArrayOutputStream;
import java.net.*;
import java.net.http.*;
import java.nio.file.Path;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.*;
import static java.util.concurrent.TimeUnit.SECONDS;

/** JDK-only integration check of the real packaged gateway and two independent TCP listeners. */
class GatewayCheck {
    static final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(3)).build();
    static final InetAddress loopback;
    static { try { loopback = InetAddress.getByName("127.0.0.1"); } catch (Exception ex) { throw new AssertionError(ex); } }

    static final class Listener implements WebSocket.Listener {
        final BlockingQueue<byte[]> data = new LinkedBlockingQueue<>();
        final CompletableFuture<Integer> end = new CompletableFuture<>();
        final StringBuilder partial = new StringBuilder();
        public CompletionStage<?> onText(WebSocket ws, CharSequence text, boolean last) {
            partial.append(text);
            if (last) { data.add(Base64.getDecoder().decode(partial.toString())); partial.setLength(0); }
            ws.request(1);
            return null;
        }
        public CompletionStage<?> onClose(WebSocket ws, int status, String reason) { end.complete(status); return null; }
        public void onError(WebSocket ws, Throwable error) { end.completeExceptionally(error); }
    }

    static void check(boolean ok) { if (!ok) throw new AssertionError(); }

    static void route(int port, String path, ServerSocket target) throws Exception {
        byte[] payload = new byte[24000];
        new Random(target.getLocalPort()).nextBytes(payload);
        var ack = CompletableFuture.runAsync(() -> {
            try (var socket = target.accept()) {
                socket.setSoTimeout(8000);
                check(Arrays.equals(socket.getInputStream().readNBytes(payload.length), payload));
                socket.getOutputStream().write(payload, 0, 9);
                socket.getOutputStream().write(payload, 9, payload.length - 9);
                check(socket.getInputStream().read() == -1);
            } catch (Exception ex) { throw new CompletionException(ex); }
        });
        var listener = new Listener();
        var ws = http.newWebSocketBuilder().buildAsync(URI.create("ws://127.0.0.1:" + port + path), listener).get(8, SECONDS);
        var encoded = Base64.getEncoder().encodeToString(payload);
        ws.sendText(encoded.substring(0, 100), false).join();
        ws.sendText(encoded.substring(100), true).join();
        var received = new ByteArrayOutputStream();
        while (received.size() < payload.length) {
            byte[] part = listener.data.poll(8, SECONDS);
            if (part == null) throw new AssertionError("Upstream bytes missing");
            received.write(part);
        }
        check(Arrays.equals(payload, received.toByteArray()));
        ws.sendText("***", true).join();
        check(listener.end.get(8, SECONDS) == 1007);
        ack.get(8, SECONDS);
    }

    static int status(int port, String path) throws Exception {
        var req = HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + path)).timeout(Duration.ofSeconds(2)).build();
        return http.send(req, HttpResponse.BodyHandlers.discarding()).statusCode();
    }

    public static void main(String[] args) throws Exception {
        try (var hall = new ServerSocket(0, 5, loopback); var game = new ServerSocket(0, 5, loopback)) {
            int port;
            try (var probe = new ServerSocket(0, 1, loopback)) { port = probe.getLocalPort(); }
            var launch = new ProcessBuilder(Path.of(System.getProperty("java.home"), "bin", "java").toString(), "-jar", args[0]).inheritIO();
            var env = launch.environment();
            env.putAll(Map.of("GAME_ROLE", "gateway", "GAME_PORT", "" + port, "GAME_BIND_ADDRESS", "127.0.0.1",
                    "HALL_HOST", "127.0.0.1", "HALL_PORT", "" + hall.getLocalPort(), "DOUNIU_HOST", "127.0.0.1", "DOUNIU_PORT", "" + game.getLocalPort()));
            var gateway = launch.start();
            try {
                for (int i = 0; i < 200 && gateway.isAlive(); i++) {
                    try { if (status(port, "/health") == 200) break; } catch (java.io.IOException ignored) {}
                    Thread.sleep(100);
                }
                check(status(port, "/health") == 200);
                check(status(port, "/ws/other") == 404);
                check(status(port, "/ws/hall") == 400);
                route(port, "/ws/hall", hall);
                route(port, "/ws/douniu", game);
                game.close();
                try {
                    http.newWebSocketBuilder().buildAsync(URI.create("ws://127.0.0.1:" + port + "/ws/douniu"), new Listener()).join();
                    throw new AssertionError("Missing upstream accepted");
                } catch (CompletionException error) {
                    check(error.getCause() instanceof WebSocketHandshakeException e && e.getResponse().statusCode() == 502);
                }
                System.out.println("Verified both gateway routes, packet bytes, failure status and paired connection cleanup.");
            } finally { gateway.destroy(); if (!gateway.waitFor(12, SECONDS)) gateway.destroyForcibly(); }
        }
    }
}
