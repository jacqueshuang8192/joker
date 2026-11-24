import com.j.joker.game.rooms.application.RoomAllocation;
import com.j.joker.game.rooms.domain.RoomDefinition;
import com.j.joker.game.rooms.domain.RoomRoute;
import java.util.HashMap;
import java.util.Map;

/** 桌号回绕、同活动重试与冲突。无需启动 Spring 或数据库。 */
public class RoomAllocationCheck {
    static final class Tables implements RoomAllocation.Rooms {
        final Map<Integer,RoomRoute> routes = new HashMap<>();
        public RoomRoute route(int tid) { return routes.get(tid); }
        public RoomRoute activityRoute(int activity) {
            return routes.values().stream().filter(r -> r.activity() == activity).findFirst().orElse(null);
        }
        public void create(int tid, RoomDefinition room) {
            if (routes.putIfAbsent(tid, new RoomRoute(tid,room.activity(),room.owner(),room.invite(),room.club(),room.base(),room.seats(),room.rules())) != null)
                throw new AssertionError("reused active table");
        }
        public void requestRemoval(int tid, int activity) { routes.remove(tid); }
        public int release(int uid, int tid) { throw new AssertionError("unexpected release"); }
    }
    static RoomDefinition request(int activity, int owner, int level) {
        return new RoomDefinition(level,activity,owner,"123456",0,2,4,1,0,0,15,"","{}");
    }
    static void check(boolean pass) { if (!pass) throw new AssertionError(); }
    public static void main(String[] args) {
        for (String rule : new String[]{"{}", "{\"profit\":null}", "{\"profit\":\" \"}", "{\"profit\":\"0.00\"}"})
            new RoomDefinition(302, 1, 2, "123456", 0, 2, 4, 1, 0, 0, 15, "", rule);
        for (String rule : new String[]{"{\"profit\":0.25}", "{\"hasLeper\":1}", "{\"hasLeper\":2}", "{\"subGameType\":5}"}) {
            try {
                new RoomDefinition(302, 1, 2, "123456", 0, 2, 4, 1, 0, 0, 15, "", rule);
                throw new AssertionError("unsupported rules accepted " + rule);
            } catch (IllegalArgumentException expected) { }
        }
        var rooms = new Tables();
        var sequence = new java.util.concurrent.atomic.AtomicLong(65535);
        var alloc = new RoomAllocation(302,1802,sequence::getAndIncrement,rooms);
        int a = alloc.create(request(18,31,302));
        int b = alloc.create(request(19,33,302));
        check(a==(1802<<16|65535) && b==(1802<<16|1));
        check(alloc.create(request(18,31,302))==a);
        check(alloc.create(request(18,32,302))<0);
        check(alloc.create(request(20,34,301))==-2);
        sequence.set(1);
        check(alloc.create(request(20,34,302))==(1802<<16|2));
        check(alloc.dissolve(a)==0 && rooms.route(b).activity()==19 && rooms.route(a)==null);
        System.out.println("Verified allocation wraparound, active table collision, retries and isolated removal.");
    }
}
