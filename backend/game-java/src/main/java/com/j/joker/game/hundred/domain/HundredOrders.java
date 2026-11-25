package com.j.joker.game.hundred.domain;

import java.util.*;
import static com.j.joker.game.hundred.domain.HundredSettlement.*;

/** 最小筹码单位。封盘前验证每一单的区域限红、玩家余额和拼庄出资。 */
public final class HundredOrders {
    private record Key(int uid,String request) {}
    private final int level;
    private final List<Banker> bankers;
    private final Map<Integer,Integer> balances;
    private final long[] limits, totals;
    private final Map<Key,Bet> orders = new LinkedHashMap<>();
    private final Map<Integer,Long> held = new HashMap<>();
    private final Map<Integer,long[]> byPlayer = new HashMap<>();
    private final Set<Integer> dealers = new HashSet<>();
    private Map<Integer,Long> receipt;
    private List<Integer> resultCards;

    public HundredOrders(int level,List<Banker> bankers,Map<Integer,Integer> opening,List<Integer> areaLimits) {
        int areas=areas(level);
        if (areaLimits.size()!=areas || areaLimits.stream().anyMatch(n->n<=0) || bankers.isEmpty() || bankers.size()>6)
            throw new IllegalArgumentException("下注区或上庄配置无效");
        for (var b:bankers) if (!dealers.add(b.uid()) || opening.getOrDefault(b.uid(),0)<b.chips())
            throw new IllegalArgumentException("庄家重复或出资超过可用余额");
        this.level=level;
        this.bankers=List.copyOf(bankers);
        balances=Map.copyOf(opening);
        limits=areaLimits.stream().mapToLong(Integer::longValue).toArray();
        totals=new long[areas];
    }

    public void accept(String request,Bet bet) {
        if (request==null || request.isBlank() || request.length()>64) throw new IllegalArgumentException("订单编号无效");
        var key=new Key(bet.uid(),request);
        var previous=orders.get(key);
        if (bet.equals(previous)) return;
        if (previous!=null || receipt!=null || dealers.contains(bet.uid())) throw new IllegalArgumentException("当前不能接单");
        int i=bet.area()-1;
        if (i<0 || i>=totals.length || totals[i]+bet.chips()>limits[i]) throw new IllegalArgumentException("超过本区剩余限额");
        long hold=held.getOrDefault(bet.uid(),0L)+(level==102?13L:1L)*bet.chips();
        if (hold>balances.getOrDefault(bet.uid(),0)) throw new IllegalArgumentException("玩家可用筹码不足");
        var projected=totals.clone();
        projected[i]+=bet.chips();
        var own = byPlayer.getOrDefault(bet.uid(), new long[totals.length]).clone();
        own[i] += bet.chips();
        HundredExposure.check(level, bankers, balances.getOrDefault(bet.uid(),0), own, projected);
        byPlayer.put(bet.uid(),own);
        orders.put(key,bet); totals[i]=projected[i]; held.put(bet.uid(),hold);
    }

    public long held(int uid) { return receipt==null?held.getOrDefault(uid,0L):0; }
    public Map<Integer,Long> close(List<Integer> cards) {
        if (resultCards!=null) {
            if (!resultCards.equals(cards)) throw new IllegalArgumentException("同一局的开牌不能更改");
            return receipt;
        }
        receipt=settle(level,bankers,List.copyOf(orders.values()),cards);
        resultCards=List.copyOf(cards);
        return receipt;
    }
}
