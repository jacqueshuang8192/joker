package com.j.joker.game.hundred.domain;

import java.util.*;

/** 原版经典庄和拼庄均按申请顺序补位。连庄上限和最低上庄分来自房间配置。 */
public final class BankerQueue {
    private final int seats, minimum, maxRounds;
    private final Set<Integer> waiting = new LinkedHashSet<>();
    private final Map<Integer,Integer> serving = new LinkedHashMap<>();
    private final Set<Integer> retiring = new HashSet<>();
    private boolean playing;

    public BankerQueue(int seats,int minimum,int maxRounds) {
        if (seats < 1 || seats > 6 || minimum <= 0 || maxRounds <= 0) throw new IllegalArgumentException("上庄配置无效");
        this.seats=seats; this.minimum=minimum; this.maxRounds=maxRounds;
    }

    public void apply(int uid,int available,boolean seated) {
        if (uid<=0 || available<minimum || seated || serving.containsKey(uid))
            throw new IllegalArgumentException("不符合申请上庄条件");
        waiting.add(uid);
    }

    public void withdraw(int uid) {
        waiting.remove(uid);
        if (!serving.containsKey(uid)) return;
        if (playing) retiring.add(uid); else serving.remove(uid);
    }
    public List<Integer> waiting() { return List.copyOf(waiting); }

    /** 读入本局实际可用筹码，不足门槛的申请自动退出。无庄时保留待开局状态。 */
    public List<HundredSettlement.Banker> start(Map<Integer,Integer> available) {
        if (playing) throw new IllegalStateException("上一局仍在进行");
        serving.entrySet().removeIf(e -> e.getValue()>=maxRounds || available.getOrDefault(e.getKey(),0)<minimum);
        var next=waiting.iterator();
        while(serving.size()<seats && next.hasNext()) {
            int uid=next.next();
            next.remove();
            if (available.getOrDefault(uid,0)>=minimum) serving.put(uid,0);
        }
        var bankers=serving.keySet().stream().map(uid -> new HundredSettlement.Banker(uid,available.get(uid))).toList();
        playing=!bankers.isEmpty();
        return bankers;
    }

    public void finish() {
        if (!playing) throw new IllegalStateException("牌局尚未开始");
        serving.replaceAll((uid,rounds) -> rounds+1);
        serving.keySet().removeAll(retiring);
        retiring.clear();
        playing=false;
    }
}
