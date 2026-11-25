import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import com.j.joker.game.niuniu.util.Json;

/** 使用现有登录、纯 Java API 和当前业务库验证完整好友场次目录。资料仅写在一次性测试容器中。 */
public class FriendTableCheck {
    static final Path SAVE = Path.of("/tmp/friend-room-check.json");
    static int num(Object value) { return ((Number)value).intValue(); }
    static void check(boolean ok,String message) { if (!ok) throw new AssertionError(message); }
    static Map<?,?> post(HallRoomCheck.Client c,String path,Map<String,?> input) throws Exception {
        return (Map<?,?>)c.request("/friendTable/"+path,input);
    }
    static void denied(HallRoomCheck.Client c,String path,Map<String,?> input) throws Exception {
        try { post(c,path,input); } catch (AssertionError refusal) { return; }
        throw new AssertionError("unexpected acceptance: "+path);
    }
    static void seed() throws Exception {
        var players=new ArrayList<HallRoomCheck.Client>();
        for (int i=0; i<4; i++) players.add(HallRoomCheck.Client.register());
        var rooms=new ArrayList<Integer>();
        var snapshots=new ArrayList<Map<?,?>>();
        for (var rules : com.j.joker.game.tables.domain.FriendRules.values()) {
            int level=rules.level;
            if (!rules.terms.isEmpty()) check(rules.terms.equals(post(players.getFirst(),"current",Map.of("level",level)).get("terms")),"pre-entry rule disclosure "+level);
            var create=Map.of("level",level,"rounds",level==325 || level==308 ? 10 : 1,"red",level!=308,"birds",level==308?999:2,"requestId",UUID.randomUUID().toString());
            int code=num(post(players.getFirst(),"create",create).get("code"));
            check(code==num(post(players.getFirst(),"create",create).get("code")),"creation receipt");
            rooms.add(code);
            var lookup=Map.of("code",code);
            var join=Map.of("code",code,"level",level);
            denied(players.get(1),"state",lookup);
            var forged=new HallRoomCheck.Client(players.getFirst().uid(),"invalid-session","","");
            denied(forged,"state",lookup);
            var joined=post(players.get(1),"join",join);
            check(post(players.get(1),"join",join).equals(joined),"join retry");
            int seats=rules.seats;
            for (int i=2; i<seats; i++) post(players.get(i),"join",join);
            if (seats<4) denied(players.get(seats),"join",join);
            var state=post(players.getFirst(),"state",lookup);
            var seen=new HashSet<>();
            for (int i=0; i<seats; i++) {
                var mine=post(players.get(i),"current",Map.of("level",level));
                check(num(mine.get("seat"))==i && num(mine.get("code"))==code && !mine.containsKey("deck") &&
                        !mine.containsKey("moves") && !mine.containsKey("hands"),"private view");
                var hand=(List<?>)mine.get("hand");
                int size=switch(level) {case 324,9324->17;case 325,9325,9425->16;case 317->0;case 360->2;case 365->13;case 308->i==0?14:13;default->-1;};
                check(size<0 || hand.size()==size,"private hand size");
                if (List.of(324,325,317,360,365).contains(level)) for(var card:hand) check(seen.add(card),"other seat disclosed our cards");
            }
            var action=Map.of("code",code,"version",state.get("version"),"action","auto");
            int turn=num(state.get("turn"));
            denied(players.get((turn+1)%seats),"act",action);
            // 并发重发同一版本。两个回包只推进一次。
            try(var executor=Executors.newVirtualThreadPerTaskExecutor()) {
                Callable<Map<?,?>> perform=() -> post(players.get(turn),"act",action);
                var a=executor.submit(perform); var b=executor.submit(perform);
                check(a.get().equals(b.get()),"concurrent retry changed state");
            }
            var after=post(players.getFirst(),"state",lookup);
            check(num(after.get("version"))==num(state.get("version"))+1,"version skipped");
            snapshots.add(after);
        }
        var accounts=players.stream().map(p -> Map.of("uid",p.uid(),"token",p.token())).toList();
        Files.writeString(SAVE,Json.write(Map.of("players",accounts,"rooms",rooms,"snapshots",snapshots)));
        System.out.println(rooms.size()+" friend tables saved in flight for API restart.");
    }

    static void finish() throws Exception {
        var journal=Json.parseObject(Files.readString(SAVE));
        var players=new ArrayList<HallRoomCheck.Client>();
        for(Object value:(List<?>)journal.get("players")) {
            var p=(Map<?,?>)value;
            players.add(new HallRoomCheck.Client(num(p.get("uid")),p.get("token").toString(),"",""));
        }
        var rooms=(List<?>)journal.get("rooms");
        for(int index=0; index<rooms.size(); index++) {
            int code=num(rooms.get(index));var lookup=Map.of("code",code);
            var saved=(Map<?,?>)((List<?>)journal.get("snapshots")).get(index);
            try(var db=VariantsWireCheck.db()) {
                check(VariantsWireCheck.scalar(db,"SELECT revision FROM joker_friend_table WHERE code=?",code)>=num(saved.get("version")),"restart lost a committed action");
                // 保证慢速 CI 上的重启检查与 45 秒托管检查分别执行。
                try(var q=db.prepareStatement("UPDATE joker_friend_table SET changed_at=UTC_TIMESTAMP(3) WHERE code=?")) {
                    q.setInt(1,code); q.executeUpdate();
                }
            }
            var state=post(players.getFirst(),"state",lookup);
            if (num(state.get("version"))==num(saved.get("version")))
                check(state.equals(saved),"API restart changed persisted turn or private hand");
            int initialVersion=num(state.get("version"));
            check(post(players.getFirst(),"state",Map.of("code",code,"version",state.get("version"))).equals(Map.of("unchanged",true)),"unchanged poll");
            try(var db=VariantsWireCheck.db();var q=db.prepareStatement("UPDATE joker_friend_table SET changed_at=UTC_TIMESTAMP(3)-INTERVAL 46 SECOND WHERE code=?")) {
                q.setInt(1,code); q.executeUpdate();
            }
            if (index==0) {
                // 不向 API 发送任何请求，直接观察数据库等后台托管推进版本。
                try(var db=VariantsWireCheck.db()) {
                    for (int i=0;i<40 && VariantsWireCheck.scalar(db,"SELECT revision FROM joker_friend_table WHERE code=?",code)==initialVersion;i++)
                        Thread.sleep(250);
                    check(VariantsWireCheck.scalar(db,"SELECT revision FROM joker_friend_table WHERE code=?",code)==initialVersion+1,"offline scheduler");
                }
            }
            state=post(players.getFirst(),"state",Map.of("code",code,"version",state.get("version")));
            check(num(state.get("version"))==initialVersion+1,"timeout was not persisted");
            int steps=0;
            while (!state.get("phase").equals("FINISHED")) {
                check(++steps<=470,"round failed to finish");
                if (state.get("phase").equals("INTERMISSION")) {
                    if (num(state.get("roundNo")) == 2) {
                        state=post(players.getFirst(),"act",Map.of("code",code,"version",state.get("version"),"action","leave"));
                        break;
                    }
                    var capacity=num(state.get("capacity"));
                    for (int seat=0; seat<capacity; seat++) {
                        var ready=Map.of("code",code,"version",state.get("version"),"action","next");
                        state=post(players.get(seat),"act",ready);
                        check(post(players.get(seat),"act",ready).equals(state),"duplicate ready");
                    }
                    check(num(state.get("roundNo"))==2,"next round not started");
                }
                var actor=players.get(num(state.get("turn")));
                var action=Map.of("code",code,"version",state.get("version"),"action","auto");
                state=post(actor,"act",action);
                if (state.get("phase").equals("FINISHED"))
                    check(post(actor,"act",action).equals(state),"duplicate last move");
            }
            check("FINISHED".equals(state.get("phase")),"table still active");
            var points=(List<?>)state.get("points");
            check(points.stream().mapToInt(FriendTableCheck::num).sum()==0,"unbalanced settlement");
            try(var db=VariantsWireCheck.db()) {
                check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_seat WHERE points IS NOT NULL AND active_uid IS NULL AND code=?",code)==points.size(),"receipt count");
                check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_round_score WHERE code=?",code)
                        ==points.size()*num(state.get("roundNo")),"each finished hand has one receipt per player");
            }
            int level=num(state.get("level"));
            var history=(List<?>)post(players.getFirst(),"history",Map.of("level",level)).get("rooms");
            check(history.stream().anyMatch(item->num(((Map<?,?>)item).get("code"))==code),"account room history");
            var rounds=(List<?>)post(players.getFirst(),"rounds",lookup).get("rounds");
            check(rounds.size()==num(state.get("roundNo")),"round history");
            for (var item:rounds) {
                var record=(Map<?,?>)item;
                int round=num(record.get("round")),deals=num(record.get("deals"));
                var end=post(players.getFirst(),"replay",Map.of("code",code,"round",round,"deal",deals,"step",-1));
                var start=post(players.getFirst(),"replay",Map.of("code",code,"round",round,"deal",1,"step",0));
                check(num(start.get("step"))==0 && !start.containsKey("move") && end.containsKey("move"),"replay steps");
                check(((List<?>)end.get("points")).getFirst().equals(record.get("points")),"playback differs from score receipt");
            }
            System.out.println("Verified online game "+state.get("level")+", "+steps+" moves, "+points.size()+" receipts.");
        }
        waitingExpiry(players);
        lifecycle(players);
        unattended(players);
        redeal(players);
        Files.delete(SAVE);
    }
    static void ageWaiting(int code,int minutes) throws Exception {
        try (var db=VariantsWireCheck.db();var q=db.prepareStatement("""
                UPDATE joker_friend_table SET changed_at=IF(revision=0,CURRENT_TIMESTAMP(3),UTC_TIMESTAMP(3))-INTERVAL ? MINUTE
                WHERE code=? AND phase='WAITING'""")) {
            q.setInt(1,minutes); q.setInt(2,code);
            check(q.executeUpdate()==1,"expected a waiting room");
        }
    }

    static void waitingExpiry(List<HallRoomCheck.Client> players) throws Exception {
        var owner=players.get(0);
        var guest=players.get(1);
        var create=Map.of("level",324,"requestId",UUID.randomUUID().toString());
        var room=post(owner,"create",create);
        int code=num(room.get("code"));
        check(num(room.get("waitingMinutes"))==30,"waiting limit in player view");
        ageWaiting(code,29);
        var invite=Map.of("code",code,"level",324);
        var waiting=post(guest,"join",invite);
        check("WAITING".equals(waiting.get("phase")),"premature closure");
        try (var db=VariantsWireCheck.db()) {
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_table WHERE code=? AND changed_at>UTC_TIMESTAMP(3)-INTERVAL 1 MINUTE",code)==1,"new seat refreshes deadline");
        }
        ageWaiting(code,29);
        var poll=Map.of("code",code,"version",waiting.get("version"));
        check(post(owner,"state",poll).equals(Map.of("unchanged",true)),"waiting poll changed the table");
        try (var db=VariantsWireCheck.db()) {
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_table WHERE code=? AND changed_at<UTC_TIMESTAMP(3)-INTERVAL 28 MINUTE",code)==1,"poll extended wait");
        }
        ageWaiting(code,31);
        // 和最后一位玩家入座同时触发到期检查，不能发牌或重复释放。
        try (var workers=Executors.newVirtualThreadPerTaskExecutor()) {
            var late=workers.submit(()->{ denied(players.get(2),"join",invite); return true; });
            var closing=workers.submit(()->post(owner,"state",poll));
            late.get();
            var closed=closing.get();
            check("CLOSED".equals(closed.get("phase")) && num(closed.get("version"))==num(waiting.get("version"))+1,"expired table should close once");
            check(post(owner,"create",create).equals(closed),"old creation retry revived expired room");
        }
        check(!post(guest,"current",Map.of("level",324)).containsKey("code"),"expired guest still seated");
        try (var db=VariantsWireCheck.db()) {
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_round_score WHERE code=?",code)==0,"unplayed table has score receipts");
        }

        var destination=post(players.get(2),"create",Map.of("level",324,"requestId",UUID.randomUUID().toString()));
        int destinationCode=num(destination.get("code"));
        var second=post(owner,"create",Map.of("level",324,"requestId",UUID.randomUUID().toString()));
        int oldCode=num(second.get("code"));
        ageWaiting(oldCode,31);
        check(num(post(owner,"join",Map.of("level",324,"code",destinationCode)).get("code"))==destinationCode,"expired seat blocked another invitation");
        var active=post(guest,"join",Map.of("level",324,"code",destinationCode));
        check("CALL".equals(active.get("phase")),"unexpired room did not start");

        var level=Map.of("level",325);
        var empty=post(owner,"create",Map.of("level",325,"requestId",UUID.randomUUID().toString()));
        ageWaiting(num(empty.get("code")),31);
        int fresh=num(post(owner,"create",Map.of("level",325,"requestId",UUID.randomUUID().toString())).get("code"));
        check(fresh!=num(empty.get("code")),"new creation reused expired room");
        post(guest,"join",Map.of("level",325,"code",fresh));
        ageWaiting(fresh,31);
        // 后台回收期间只读取数据库，整桌没有在线请求。
        try (var db=VariantsWireCheck.db()) {
            for (int i=0;i<40 && VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_seat WHERE code=? AND active_uid IS NOT NULL",fresh)>0;i++)
                Thread.sleep(250);
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_table WHERE code=? AND phase='CLOSED'",fresh)==1,"unattended waiting room did not close");
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_seat WHERE code=? AND active_uid IS NOT NULL",fresh)==0,"unattended seats not released");
        }
        check(!post(owner,"current",level).containsKey("code") && !post(guest,"current",level).containsKey("code"),"could not leave expired waiting room");
        // 清理已正常开局的桌，后续斗地主用例继续使用这三个测试账号。
        for (var player:players.subList(0,3)) active=post(player,"act",Map.of("code",destinationCode,"version",active.get("version"),"action","dissolveYes"));
        check("CLOSED".equals(active.get("phase")),"active-room cleanup");
        System.out.println("Verified idle waiting rooms, seat renewal, late final joins, creation retries and unattended seat release.");
    }

    static void lifecycle(List<HallRoomCheck.Client> players) throws Exception {
        int code=num(post(players.getFirst(),"create",Map.of("level",9325,"rounds",10,"requestId",UUID.randomUUID().toString())).get("code"));
        var lookup=Map.of("code",code);
        var live=post(players.get(1),"join",Map.of("level",9325,"code",code));
        var premature=Map.of("code",code,"round",1,"deal",1,"step",0);
        denied(players.get(1),"replay",premature);
        var vote=Map.of("code",code,"version",live.get("version"),"action","dissolveYes");
        denied(players.get(2),"act",vote);
        live=post(players.getFirst(),"act",vote);
        check(Boolean.TRUE.equals(live.get("voted")) && num(live.get("voteCount"))==1,"first vote");
        check(post(players.getFirst(),"act",vote).equals(live),"vote retry");
        live=post(players.get(1),"act",Map.of("code",code,"version",live.get("version"),"action","dissolveNo"));
        check(!live.containsKey("voteCount"),"declined vote");
        live=post(players.getFirst(),"act",Map.of("code",code,"version",live.get("version"),"action","dissolveYes"));
        try(var db=VariantsWireCheck.db();var q=db.prepareStatement("UPDATE joker_friend_table SET vote_until=UTC_TIMESTAMP(3)-INTERVAL 1 SECOND WHERE code=?")) {
            q.setInt(1,code); q.executeUpdate();
        }
        live=post(players.get(1),"state",lookup);
        check(!live.containsKey("voteCount"),"expired votes must not carry over");
        for (int i=0;i<2;i++) live=post(players.get(i),"act",Map.of("code",code,"version",live.get("version"),"action","dissolveYes"));
        check("CLOSED".equals(live.get("phase")) && !post(players.getFirst(),"current",Map.of("level",9325)).containsKey("code"),"votes release seats");
        var record=(Map<?,?>)((List<?>)post(players.getFirst(),"rounds",lookup).get("rounds")).getFirst();
        check("DISSOLVED".equals(record.get("outcome")) && num(record.get("points"))==0,"incomplete round not charged");
        post(players.get(1),"replay",premature);
        denied(players.get(2),"replay",premature);
        denied(players.get(2),"rounds",lookup);
        var page=(List<?>)post(players.getFirst(),"history",Map.of("level",9325,"before",code)).get("rooms");
        check(!page.isEmpty() && num(((Map<?,?>)page.getFirst()).get("code"))!=code,"history cursor");
    }

    // 用数据库时钟加速等待，开局后没有任何玩家请求推进牌局。
    static void unattended(List<HallRoomCheck.Client> players) throws Exception {
        int code=num(post(players.getFirst(),"create",Map.of("level",360,"rounds",10,"requestId",UUID.randomUUID().toString())).get("code"));
        for(int i=1;i<3;i++) post(players.get(i),"join",Map.of("level",360,"code",code));
        try(var db=VariantsWireCheck.db();
            var expire=db.prepareStatement("UPDATE joker_friend_table SET changed_at=UTC_TIMESTAMP(3)-INTERVAL 16 MINUTE WHERE code=? AND phase IN ('ACTIVE','INTERMISSION')")) {
            expire.setInt(1,code);
            boolean finished=false;
            for(int i=0;i<120;i++) {
                expire.executeUpdate();
                if (VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_table WHERE code=? AND phase='FINISHED'",code)==1) {
                    finished=true;
                    break;
                }
                Thread.sleep(500);
            }
            check(finished,"offline table stuck before closure");
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_round_score WHERE code=?",code)==3,"offline receipts");
            check(VariantsWireCheck.scalar(db,"SELECT COUNT(*) FROM joker_friend_seat WHERE code=? AND active_uid IS NOT NULL",code)==0,"idle intermission still holds seats");
        }
        System.out.println("Verified unattended play to settlement and automatic intermission closure.");
    }

    static void redeal(List<HallRoomCheck.Client> players) throws Exception {
        int code=num(post(players.getFirst(),"create",Map.of("level",324,"requestId",UUID.randomUUID().toString())).get("code"));
        var join=Map.of("code",code,"level",324);
        post(players.get(1),"join",join);
        var s=post(players.get(2),"join",join);
        for(int i=0;i<3;i++) s=post(players.get(num(s.get("turn"))),"act",
                Map.of("code",code,"version",s.get("version"),"action","decline"));
        var firstDeal=Map.of("code",code,"round",1,"deal",1,"step",-1);
        denied(players.getFirst(),"replay",firstDeal);
        for(int i=0;i<3;i++) s=post(players.get(i),"act",Map.of("code",code,"version",s.get("version"),"action","dissolveYes"));
        var frame=post(players.getFirst(),"replay",firstDeal);
        check(num(frame.get("steps"))==3 && "REDEAL".equals(frame.get("phase")),"missing declined deal");
        var second=post(players.getFirst(),"replay",Map.of("code",code,"round",1,"deal",2,"step",0));
        check("DISSOLVED".equals(second.get("outcome")),"missing last deal");
        System.out.println("Verified redeals, hidden live journals and completed vote archives.");
    }

    public static void main(String[] args) throws Exception {
        if ("--seed".equals(args[0])) seed(); else finish();
    }
}
