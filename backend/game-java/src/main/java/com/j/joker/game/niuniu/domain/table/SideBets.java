package com.j.joker.game.niuniu.domain.table;

import com.j.joker.game.niuniu.domain.card.CardLogic;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** 外围每个目标座位各自与牌桌庄家比牌。相同投注人的多次下注合并显示。 */
public final class SideBets {
    public record Stake(long uid, int seat, int amount) {}
    public record Position(long uid, int seat, int amount, int delta) {}
    public record Posting(long dealer, long dealerBefore, List<Position> positions,
                          Map<Long,Long> standingBalances, Map<Long,Long> closingBalances) {
        public Posting {
            positions = List.copyOf(positions);
            standingBalances = standingBalances == null ? Map.of() : Map.copyOf(standingBalances);
            closingBalances = closingBalances == null ? Map.of() : Map.copyOf(closingBalances);
        }
        public Posting withClosingBalances(List<Settlement.Entry> entries) {
            var closing = new LinkedHashMap<Long,Long>();
            for (var p : positions) {
                if (standingBalances.containsKey(p.uid())) closing.put(p.uid(), standingBalances.get(p.uid()) + delta(p.uid()));
            }
            for (var e : entries) if (positions.stream().anyMatch(p -> p.uid() == e.uid())) closing.put(e.uid(), e.before() + e.delta());
            return new Posting(dealer, dealerBefore, positions, standingBalances, closing);
        }
        public long dealerDelta() { return -positions.stream().mapToLong(Position::delta).sum(); }
        public long delta(long uid) {
            return positions.stream().filter(p -> p.uid() == uid).mapToLong(Position::delta).sum();
        }
    }
    public record Book(long dealer, long dealerBefore, List<Stake> stakes, Map<Long,Long> standingBalances) {
        public Book { standingBalances = standingBalances == null ? Map.of() : Map.copyOf(standingBalances); }
    }
    private final Map<Long,Long> standing = new LinkedHashMap<>();
    public Map<Long,Long> outsideBalances() {
        var outside = new LinkedHashMap<>(standing);
        if (dealer > 0) outside.put(dealer, dealerBefore);
        return outside;
    }
    public boolean hasOutside(long uid) { return uid > 0 && (uid == dealer || standing.containsKey(uid)); }
    private long dealer, dealerBefore;
    private final Map<Integer,Map<Long,Integer>> seats = new LinkedHashMap<>();

    public long dealer() { return dealer; }
    public void claim(long uid, long balance) {
        if (uid <= 0 || balance <= 0 || dealer != 0 || !seats.isEmpty()) throw new IllegalArgumentException("不能抢外围庄");
        dealer = uid;
        dealerBefore = balance;
    }
    public long total(int seat) {
        return seats.getOrDefault(seat, Map.of()).values().stream().mapToLong(Integer::longValue).sum();
    }
    public int bySeat(long uid, int seat) { return seats.getOrDefault(seat, Map.of()).getOrDefault(uid, 0); }
    public long reserved(long uid) {
        return seats.values().stream().mapToLong(row -> row.getOrDefault(uid, 0)).sum();
    }
    public void validate(Player buyer, int seat, int amount, long seatLimit) {
        if (buyer == null || buyer.uid() == dealer || amount <= 0 || total(seat) + amount > seatLimit
                || reserved(buyer.uid()) + amount > Math.min(buyer.chips(), Integer.MAX_VALUE - buyer.chips()))
            throw new IllegalArgumentException("外围下注超额");
        long exposure = seats.keySet().stream().mapToLong(this::total).sum() + amount;
        if (exposure > Integer.MAX_VALUE || dealer > 0 && exposure > Math.min(dealerBefore, Integer.MAX_VALUE - dealerBefore))
            throw new IllegalArgumentException("外围庄家筹码不足");
        // 原大厅单帧最多 8192 字节，单座明细的记录数使用一个字节。
        if (bySeat(buyer.uid(),seat) == 0) {
            long records = 1 + seats.values().stream().mapToLong(Map::size).sum();
            long buyers = java.util.stream.Stream.concat(seats.values().stream().flatMap(row -> row.keySet().stream()),
                    java.util.stream.Stream.of(buyer.uid())).distinct().count();
            if (seats.getOrDefault(seat,Map.of()).size() >= Byte.MAX_VALUE || 22 + 13 * (buyers + 1) + 8 * records > 8192)
                throw new IllegalArgumentException("外围明细已达协议上限");
        }
    }
    public void bet(Player buyer, int seat, int amount, long seatLimit) {
        validate(buyer, seat, amount, seatLimit);
        if (buyer.seatId() == -2) standing.putIfAbsent(buyer.uid(), buyer.chips());
        seats.computeIfAbsent(seat, k -> new LinkedHashMap<>()).merge(buyer.uid(), amount, Math::addExact);
    }
    public Book snapshot() {
        var bets = new ArrayList<Stake>();
        seats.forEach((seat,row) -> row.forEach((uid,amount) -> bets.add(new Stake(uid, seat, amount))));
        return new Book(dealer, dealerBefore, List.copyOf(bets), standing);
    }
    public Posting settle(NiuNiuTable table) {
        if (seats.isEmpty()) return null;
        var positions = snapshot().stakes().stream().map(s -> {
            boolean wins = CardLogic.compare(table.bySeat(s.seat()).hand(), table.banker().hand(), table.config()) > 0;
            return new Position(s.uid(), s.seat(), s.amount(), wins ? s.amount() : -s.amount());
        }).toList();
        return new Posting(dealer, dealerBefore, positions, standing, Map.of());
    }
}
