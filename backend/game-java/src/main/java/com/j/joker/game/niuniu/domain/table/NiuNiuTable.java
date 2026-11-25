package com.j.joker.game.niuniu.domain.table;

import com.j.joker.game.niuniu.domain.card.Card;
import com.j.joker.game.niuniu.domain.card.Deck;
import com.j.joker.game.niuniu.domain.card.CardLogic;
import com.j.joker.game.niuniu.domain.card.CardType;
import com.j.joker.game.niuniu.domain.card.HandResult;
import com.j.joker.game.niuniu.domain.rules.GameConfig;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

/**
 * 一张牛牛桌的完整状态机。
 *
 * <p>对应 CGameTable：座位管理、准备、发牌、抢庄、下注、亮牌、结算、下一局。
 * 阶段与超时参考二进制中的 StartXxxTimer / ProcXxxTimeOut。
 */
public final class NiuNiuTable {

    public static final int MAX_SEATS = 10;

    private final int tableId;
    private final GameConfig cfg;
    private final Map<Integer, Player> seats = new LinkedHashMap<>();
    private final Random random;
    private final BotPolicy botPolicy;
    private final CardController cardController;
    private final List<TableListener> listeners = new ArrayList<>();
    private final java.util.Set<Long> grabDecided = new java.util.HashSet<>();
    private final java.util.Set<Long> betDecided = new java.util.HashSet<>();
    // 空闲桌重启后玩家重新入座并读取最新筹码，上一局推注资格仍跟随原玩家。
    private final Map<Long, Integer> returningPush = new LinkedHashMap<>();
    private final Set<Long> revealed = new HashSet<>();
    private ScheduledExecutorService scheduler;
    private ScheduledFuture<?> phaseTimer;

    private volatile GameState state = GameState.RESET_TABLE;
    private int roundNo;
    private UUID roundId;
    private List<Integer> lepers = List.of();

    public List<Integer> lepers() { return lepers; }
    private Settlement.Result pendingSettlement;
    private Player banker;
    private int lastBankerSeat = -1;
    private int niuBankerSeat;
    // 锅底以整积分展示，只限定本庄赔付；实际筹码仍随每局回执入账。
    public record Pot(long owner, int points, int number, int rounds, int raises, int tenure) {}
    public record TableCharge(UUID id, int round, String kind, int uid, int before, int amount) {}
    private final List<TableCharge> charges = new ArrayList<>();
    private final Set<Long> paidStart = new HashSet<>();
    private long bankerProfit;
    private long bankerBalance;

    public List<TableCharge> pendingCharges() { return List.copyOf(charges); }
    public void acknowledgeCharges() { charges.clear(); }

    private void charge(String kind, long uid, long before, long amount) {
        if (amount <= 0) return;
        var player = byUid(uid);
        if (player != null) player.addChips(-amount);
        charges.add(new TableCharge(UUID.randomUUID(), roundNo, kind, Math.toIntExact(uid),
                Math.toIntExact(before), Math.toIntExact(amount)));
    }

    public void endTenure() {
        if (pot.owner() == 0) return;
        var player = byUid(pot.owner());
        long before = player == null ? bankerBalance : player.chips();
        long amount = Math.min(before, Math.max(0, bankerProfit) * cfg.clubFee().downRate() / 100);
        charge("DOWN", pot.owner(), before, amount);
        bankerProfit = 0;
    }

    private SideBets side = new SideBets();
    private SideBets.Posting lastSide;
    public SideBets side() { return side; }
    public SideBets.Posting lastSide() { return lastSide; }
    public boolean playingSide(long uid) { return inRound() && side.hasOutside(uid); }
    public UUID roundId() { return roundId; }

    public long sideDealerMinimum() { return sideLimit() * (players().size() - 1); }

    public synchronized void sideDealer(long uid, long chips) {
        if (state != GameState.SIDE_GRAB || byUid(uid) != null || chips < sideDealerMinimum()) throw new IllegalArgumentException("不能抢外围庄");
        side.claim(uid, chips);
        startSideBets();
    }
    public synchronized void startSideBets() {
        if (state != GameState.SIDE_GRAB) return;
        cancelTimer();
        changeState(GameState.SIDE_BET);
        sideDeadline();
    }
    private void sideDeadline() {
        boolean grab = state == GameState.SIDE_GRAB;
        long ms = grab ? 5000 : 20000;
        fire(l -> l.onPhaseDeadline(this, state, ms));
        schedule(ms, grab ? this::startSideBets : this::openAndSettle);
    }
    public synchronized void sideBet(long uid, int seat, int amount) {
        sideBet(byUid(uid), seat, amount);
    }
    public void validateSideBet(Player buyer, int seat, int amount) {
        if (state != GameState.SIDE_BET || bySeat(seat) == null || bySeat(seat) == banker)
            throw new IllegalArgumentException("无效外围阶段或座位");
        side.validate(buyer, seat, amount, sideLimit());
    }
    public synchronized void sideBet(Player buyer, int seat, int amount) {
        validateSideBet(buyer, seat, amount);
        side.bet(buyer, seat, amount, sideLimit());
    }
    public long sideLimit() { return Math.min(Integer.MAX_VALUE, (long)cfg.baseChip() * cfg.sideLimitTimes()); }

    private Pot pot = new Pot(0, 0, 0, 0, 0, 0);
    public Pot pot() { return pot; }
    public int potPoints() { return cfg.gongNiu() ? pot.points() : cfg.guodi(); }
    public int bankerOptions() {
        if (!cfg.gongNiu() || banker == null) return 0;
        int base = cfg.openingPot();
        boolean low = pot.points() < (long)(pot.raises() + 1) * base / 10;
        boolean forced = cfg.upBankGuodiTimes() > 0 && pot.points() >= (long)base * cfg.upBankGuodiTimes();
        boolean raise = cfg.linkBankPattern() == 1 && pot.raises() < cfg.upBankTimes()
                && banker.chips() / 100 >= ((long)base << (pot.raises() + 1));
        int mask = (pot.tenure() >= 4 || 10L * pot.points() < base ? 1 : 0) | (low ? 0 : 2) | (raise ? 4 : 0);
        boolean replacement = players().stream().anyMatch(p -> p.chips()/100 >= base);
        if (!replacement && pot.points() > 0) return 2;
        return forced || mask == 0 ? 1 : mask;
    }

    public synchronized void bankerAction(long uid, int action) {
        if (state != GameState.BANKER_OPTION || banker == null || banker.uid() != uid ||
                (action != 1 && action != 2 && action != 4) || (bankerOptions() & action) == 0)
            throw new IllegalArgumentException("当前不能执行该庄家操作");
        cancelTimer();
        Player chosen = banker;
        if (action == 1) {
            chosen = nextPotBanker();
            openPot(chosen);
        } else if (action == 4) {
            int raised = Math.toIntExact((long)cfg.openingPot() << (pot.raises() + 1));
            pot = new Pot(uid, raised, pot.number() + 1, 0, pot.raises() + 1, pot.tenure());
        }
        startBetting(chosen, action);
    }

    private Player nextPotBanker() {
        return players().stream().filter(p -> p.chips() / 100 >= cfg.openingPot())
                .min(Comparator.comparingInt(p -> Math.floorMod(p.seatId() - lastBankerSeat - 1, cfg.maxSeatCount())))
                .orElseThrow(() -> new IllegalStateException("无玩家可承担锅底"));
    }

    private void openPot(Player p) {
        endTenure();
        pot = new Pot(p.uid(), cfg.openingPot(), pot.number() + 1, 0, 0, 0);
        long amount = (long)cfg.clubFee().upRate() * pot.points();
        if (amount > 0) charge("UP", p.uid(), p.chips(), p.chips() - pot.points() <= amount ? p.chips() : amount);
        bankerBalance = p.chips();
    }

    private void bankerDeadline() {
        fire(l -> l.onPhaseDeadline(this, state, GRAB_DEADLINE_MS));
        schedule(GRAB_DEADLINE_MS, () -> bankerAction(banker.uid(), (bankerOptions() & 2) != 0 ? 2 : 1));
    }

    private long totalBetThisRound;
    private volatile boolean running;
    private boolean reconnectWindow;

    public NiuNiuTable(int tableId, GameConfig cfg, Random random) {
        this.tableId = tableId;
        this.cfg = cfg;
        this.random = random;
        this.botPolicy = new BotPolicy(random);
        this.cardController = new CardController(cfg, random);
    }

    // ---------------------------------------------------------------- 座位

    public synchronized Player sit(int seatId, Player p) {
        if (seatId < 0 || seatId >= Math.min(MAX_SEATS, cfg.maxSeatCount())) {
            throw new IllegalArgumentException("非法座位: " + seatId);
        }
        if (inRound()) throw new IllegalStateException("对局中不能更换座位");
        if (seats.containsKey(seatId)) {
            throw new IllegalStateException("座位已被占用: " + seatId);
        }
        Integer recovered = returningPush.remove(p.uid());
        if (recovered != null) p.setPushLimit(recovered);
        p.setSeatId(seatId);
        seats.put(seatId, p);
        fire(l -> l.onSeatChange(this, p));
        return p;
    }

    public synchronized void leaveDisconnected(Player player) {
        if (inRound()) return;
        if (player.pushLimit() > 0) returningPush.put(player.uid(), player.pushLimit());
        standUp(player.uid());
    }

    public synchronized void standUp(long uid) {
        Player p = byUid(uid);
        if (inRound()) return;
        // 空闲阶段重启后牌座尚未重建，原庄家仍可退桌并结清任期。
        if (cfg.clubFee().downRate() > 0 && uid == pot.owner()) {
            endTenure();
            pot = new Pot(0, 0, pot.number(), 0, 0, 0);
        }
        if (p != null) {
            seats.remove(p.seatId());
            if (banker == p) banker = null;
            fire(l -> l.onSeatChange(this, p));
        }
    }

    public boolean inRound() {
        return switch (state) {
            case SIDE_GRAB, SIDE_BET, BANKER_OPTION, SEND_CARD, GRAB_DEALER, CALL_TIMES, OPEN_CARD, SETTLE -> true;
            default -> false;
        };
    }

    public int userStatus(Player player) {
        return switch (state) {
            case GRAB_DEALER -> !grabDecided.contains(player.uid()) ? 2 : player.grabTimes() == 0 ? 3 : 4;
            case SIDE_GRAB, SIDE_BET -> 6;
            case CALL_TIMES -> betDecided.contains(player.uid()) ? 6 : 5;
            case OPEN_CARD -> revealed.contains(player.uid()) ? 8 : 7;
            case SETTLE -> 8;
            default -> player.ready() ? 1 : 0;
        };
    }

    public synchronized int autoSeat() {
        for (int i = 0; i < Math.min(MAX_SEATS, cfg.maxSeatCount()); i++) {
            if (!seats.containsKey(i)) {
                return i;
            }
        }
        return -1;
    }

    public Player byUid(long uid) {
        for (Player p : seats.values()) {
            if (p.uid() == uid) {
                return p;
            }
        }
        return null;
    }

    public Player bySeat(int seatId) {
        return seats.get(seatId);
    }

    public List<Player> players() {
        return new ArrayList<>(seats.values());
    }

    // ---------------------------------------------------------------- 准备/开始

    public synchronized void ready(long uid, boolean ready) {
        if (state != GameState.WAIT_READY && state != GameState.RESET_TABLE) return;
        Player p = byUid(uid);
        if (p == null) {
            throw new IllegalArgumentException("玩家不在桌上: " + uid);
        }
        if (p.ready() == ready) return;
        p.setReady(ready);
        fire(l -> l.onReady(this, p));
        if (ready && allReady()) {
            beginRound();
        }
    }

    private boolean allReady() {
        int n = 0;
        for (Player p : seats.values()) {
            if (p.online()) {
                n++;
                if (!p.ready()) {
                    return false;
                }
            }
        }
        return n >= 2;
    }

    /** 房主强制开始 / 倒计时结束。 */
    public synchronized void startGame(long operatorUid) {
        if (state == GameState.WAIT_READY || state == GameState.RESET_TABLE) {
            beginRound();
        }
    }

    /** 配牌：指定座位下一局拿到的手牌（ProUserSelectCard / 控盘）。 */
    public void presetHand(int seatId, List<com.j.joker.game.niuniu.domain.card.Card> hand) {
        cardController.preset(seatId, hand);
    }

    // ---------------------------------------------------------------- 一局

    private long openingCost(Player player) {
        return cfg.clubFee().firstOnly() && paidStart.contains(player.uid()) ? 0
                : Math.min(player.chips(), cfg.clubFee().startCost());
    }

    public synchronized void beginRound() {
        if (inRound() || state == GameState.STOP_GAME || seats.size() < 2) {
            return;
        }
        if (cfg.gongNiu() && players().stream().noneMatch(p -> (p.chips() - openingCost(p)) / 100 >= cfg.openingPot())
                && (byUid(pot.owner()) == null || pot.points() <= 0))
            throw new IllegalStateException("本桌筹码不足以开锅");
        banker = null;
        returningPush.clear(); // 离座错过一局即中断连续推注。
        roundNo++;
        roundId = UUID.randomUUID();
        side = new SideBets();
        totalBetThisRound = 0;
        grabDecided.clear();
        betDecided.clear();
        revealed.clear();
        for (Player p : seats.values()) {
            p.resetForRound();
            p.setBetTimes(1);
        }
        for (Player p : seats.values()) {
            long cost = openingCost(p);
            if (cost > 0) {
                charge("START", p.uid(), p.chips(), cost);
                if (cfg.clubFee().firstOnly()) paidStart.add(p.uid());
            }
        }
        dealCards();
        changeState(GameState.SEND_CARD);
        if (!cfg.gongNiu()) for (Player player : seats.values()) fire(l -> l.onDeal(this, player));
        if (cfg.gongNiu() && roundNo > 1) {
            continuePot();
            return;
        }
        changeState(GameState.GRAB_DEALER);
        if (automaticBanker()) {
            finishGrab();
            return;
        }
        fire(l -> l.onPhaseDeadline(this, GameState.GRAB_DEALER, grabDeadlineMs()));
        if (!running) {
            // 同步模式（测试/模拟）：由调用方驱动
            return;
        }
        schedule(grabDeadlineMs(), this::onGrabTimeout);
        autoPlayBotsGrab();
    }

    private void continuePot() {
        banker = byUid(pot.owner());
        if (banker != null && pot.points() <= 0 && players().stream().noneMatch(p -> p.chips()/100 >= cfg.openingPot()))
            throw new IllegalStateException("筹码不足以开新锅");
        if (banker == null) {
            Player next = nextPotBanker();
            openPot(next);
            startBetting(next);
        } else {
            banker.setBanker(true);
            changeState(GameState.BANKER_OPTION);
            bankerDeadline();
        }
    }

    private void dealCards() {
        List<Player> list = new ArrayList<>(seats.values());
        lepers = Deck.chooseLepers(cfg, random);
        var hands = cardController.deal(list, Deck.forRound(cfg, lepers));
        for (int i = 0; i < list.size(); i++) {
            Player p = list.get(i);
            p.cards().addAll(hands.get(i));
            p.setHand(CardLogic.evaluate(p.cards(), cfg));
        }
    }

    // ---------------------------------------------------------------- 抢庄

    private boolean automaticBanker() {
        return switch (cfg.subGameType()) {
            case FIXED_BANKER, ROTATE_BANKER, NIU_NIU_BANKER -> true;
            default -> false;
        };
    }

    public boolean canGrab(Player player) {
        // 房规使用整积分，data 的筹码单位是百分之一积分。
        return (!cfg.gongNiu() || player.chips() / 100 >= cfg.openingPot()) && !automaticBanker() && player.chips() >= 100L * cfg.grabDealerChips();
    }

    public synchronized void grabBanker(long uid, int times) {
        if (state != GameState.GRAB_DEALER) {
            throw new IllegalStateException("当前阶段不能抢庄: " + state);
        }
        Player p = byUid(uid);
        if (p == null || grabDecided.contains(uid)) return;
        if (times != 0 && !cfg.grabOptions().contains(times)) throw new IllegalArgumentException("无此抢庄档位");
        if (times > 0 && !canGrab(p)) throw new IllegalArgumentException("抢庄的积分不足");
        int t = times;
        p.setGrabTimes(t);
        grabDecided.add(uid);
        fire(l -> l.onGrab(this, p, t));
        if (allActedGrab()) {
            finishGrab();
        }
    }

    private boolean allActedGrab() {
        for (Player p : seats.values()) {
            if ((p.online() || reconnectWindow) && !grabDecided.contains(p.uid())) {
                return false;
            }
        }
        return true;
    }

    private void onGrabTimeout() {
        synchronized (this) {
            if (state == GameState.GRAB_DEALER) {
                finishGrab();
            }
        }
    }

    private Player selectBanker() {
        if (automaticBanker()) {
            int seat = cfg.subGameType() == GameConfig.SubGameType.NIU_NIU_BANKER ? niuBankerSeat : Math.max(0, lastBankerSeat);
            if (cfg.subGameType() == GameConfig.SubGameType.ROTATE_BANKER && roundNo > 1) {
                do {
                    seat = (seat + 1) % cfg.maxSeatCount();
                } while (!seats.containsKey(seat));
            }
            Player chosen = seats.get(seat);
            return chosen != null ? chosen : players().get(random.nextInt(seats.size()));
        }
        Player highest = null;
        for (Player p : seats.values()) {
            if (highest == null || p.grabTimes() > highest.grabTimes()) {
                highest = p;
            }
        }
        Player chosen;
        if (highest == null || highest.grabTimes() == 0) {
            List<Player> eligible = seats.values().stream().filter(this::canGrab).toList();
            List<Player> candidates = eligible.isEmpty() ? players() : eligible;
            chosen = candidates.get(random.nextInt(candidates.size()));
        } else {
            List<Player> top = new ArrayList<>();
            for (Player p : seats.values()) {
                if (p.grabTimes() == highest.grabTimes()) {
                    top.add(p);
                }
            }
            chosen = top.get(random.nextInt(top.size()));
        }
        return chosen;
    }

    private synchronized void finishGrab() {
        reconnectWindow = false;
        cancelTimer();
        Player chosen = selectBanker();
        if (cfg.gongNiu()) {
            if (chosen.chips() / 100 < cfg.openingPot()) chosen = nextPotBanker();
            openPot(chosen);
        }
        startBetting(chosen);
    }

    private void startBetting(Player chosen) {
        startBetting(chosen, 0);
    }

    private void startBetting(Player chosen, int action) {
        if (cfg.gongNiu()) pot = new Pot(chosen.uid(), pot.points(), pot.number(), pot.rounds() + 1, pot.raises(), pot.tenure() + 1);
        for (Player p : seats.values()) {
            p.setBanker(p == chosen);
        }
        banker = chosen;
        lastBankerSeat = chosen.seatId();
        changeState(GameState.CALL_TIMES);
        if (action == 1 || action == 4) fire(l -> l.onPot(this, action == 4));
        fire(l -> l.onBankerDecided(this, chosen));
        if (cfg.gongNiu()) for (Player player : seats.values()) fire(l -> l.onDeal(this, player));
        fire(l -> l.onPhaseDeadline(this, GameState.CALL_TIMES, betDeadlineMs()));
        if (running) {
            schedule(betDeadlineMs(), this::onBetTimeout);
            autoPlayBotsBet();
        }
    }

    /** 测试/同步模式：直接结束抢庄阶段。 */
    public synchronized void finishGrabNow() {
        if (state == GameState.GRAB_DEALER) {
            finishGrab();
        }
    }

    // ---------------------------------------------------------------- 下注

    private int betScale(Player p) {
        return cfg.doubleBet() && cfg.subGameType() == GameConfig.SubGameType.MING_PAI_GRAB
                && cfg.showCardNums() > 2 && p.grabTimes() == 1 ? 2 : 1;
    }

    private int pushOption(Player p) {
        return p != banker && p.grabTimes() == cfg.grabOptions().getLast() ? p.pushLimit() * betScale(p) : 0;
    }

    private boolean canAfford(Player p, int times) {
        // 原版默认 LimitConfig 系数为 1。通过除法避免大额底注与抢庄倍数相乘溢出。
        int grab = banker == null ? 1 : Math.max(1, banker.grabTimes());
        return (long) times * cfg.baseChip() <= p.chips() / grab;
    }

    public int pushBet(Player p) {
        if (cfg.gongNiu()) return 0;
        int offer = pushOption(p);
        return canAfford(p, offer) ? offer : 0;
    }

    public int minPotBet() {
        long minimum = pot.rounds() <= 1 ? (long)pot.points() * cfg.firstBetLimit() : (long)cfg.openingPot() * cfg.afterBetLimit();
        return (int)Math.max(1, minimum / 100);
    }

    public List<Integer> displayedBets(Player p) {
        if (cfg.gongNiu()) return List.of(minPotBet(), Math.max(minPotBet(), pot.points() / 3));
        List<Integer> choices = new ArrayList<>();
        int scale = betScale(p);
        for (int value : cfg.betOptions()) {
            if (p.pushLimit() == 0 || value < p.pushLimit()) choices.add(value * scale);
        }
        int offer = pushOption(p);
        if (offer > 0 && !choices.contains(offer)) choices.add(offer);
        if (choices.isEmpty()) choices.add(cfg.betOptions()[0] * scale);
        return choices;
    }

    public List<Integer> betChoices(Player p) {
        if (cfg.gongNiu()) return displayedBets(p).stream().map(n -> (int)Math.min(n, p.chips() / 100)).distinct().toList();
        return displayedBets(p).stream().filter(value -> canAfford(p, value)).toList();
    }

    public synchronized void bet(long uid, int times) {
        if (state != GameState.CALL_TIMES) {
            throw new IllegalStateException("当前阶段不能下注: " + state);
        }
        Player p = byUid(uid);
        if (p == null || p == banker || betDecided.contains(uid)) {
            return;
        }
        if (cfg.gongNiu()) {
            int cap = (int)(p.chips() / 100);
            if (times < Math.min(cap, minPotBet()) || times > Math.min(cap, Math.max(minPotBet(), pot.points() / 3)))
                throw new IllegalArgumentException("下注超出锅底范围");
        } else if (!betChoices(p).contains(times)) throw new IllegalArgumentException("该玩家没有此下注档位");
        int t = times;
        p.setBetTimes(t);
        totalBetThisRound += (long) cfg.guodi() * t;
        betDecided.add(uid);
        fire(l -> l.onBet(this, p, t));
        if (allActedBet()) {
            openAndSettle();
        }
    }

    private void onBetTimeout() {
        synchronized (this) {
            if (state == GameState.CALL_TIMES) {
                openAndSettle();
            }
        }
    }

    private boolean allActedBet() {
        for (Player p : seats.values()) {
            if (p == banker || (!p.online() && !reconnectWindow)) {
                continue;
            }
            if (!betDecided.contains(p.uid())) {
                return false;
            }
        }
        return true;
    }

    // ---------------------------------------------------------------- 亮牌/结算

    public synchronized void openAndSettle() {
        if (state != GameState.CALL_TIMES && state != GameState.SIDE_BET) return;
        cancelTimer();
        reconnectWindow = false;
        for (Player p : seats.values()) {
            if (p != banker && betDecided.add(p.uid())) {
                var available = betChoices(p);
                p.setBetTimes(available.isEmpty() ? 1 : available.getFirst());
                totalBetThisRound += (long) cfg.guodi() * p.betTimes();
                fire(l -> l.onBet(this, p, p.betTimes()));
            }
            if (p.hand() == null) p.setHand(CardLogic.evaluate(p.cards(), cfg));
        }
        if (cfg.waiweiEnabled() && state == GameState.CALL_TIMES) {
            changeState(GameState.SIDE_GRAB);
            sideDeadline();
            return;
        }
        // 在亮牌广播和 data 写入前冻结整局金额，恢复时沿用原局明细。
        pendingSettlement = Settlement.calculate(this);
        changeState(GameState.OPEN_CARD);
        for (Player p : seats.values()) fire(l -> l.onOpenCard(this, p));
        fire(l -> l.onPhaseDeadline(this, GameState.OPEN_CARD, OUT_CARD_DEADLINE_MS));
        UUID id = roundId;
        schedule(OUT_CARD_DEADLINE_MS, () -> finishReveal(id));
    }

    public synchronized void reveal(long uid) {
        Player player = byUid(uid);
        if (state != GameState.OPEN_CARD || player == null || !revealed.add(uid)) return;
        fire(l -> l.onReveal(this, player));
        if (revealed.size() == seats.size()) finishReveal(roundId);
    }

    private synchronized void finishReveal(UUID id) {
        if (state != GameState.OPEN_CARD || !id.equals(roundId)) return;
        cancelTimer();
        for (Player p : seats.values()) {
            if (revealed.add(p.uid())) fire(l -> l.onReveal(this, p));
        }
        changeState(GameState.SETTLE);
        finishSettlement(roundId, pendingSettlement);
    }

    private synchronized void finishSettlement(java.util.UUID id, Settlement.Result result) {
        for (TableListener listener : listeners) {
            if (!listener.commitRound(id, result)) {
                schedule(3000, () -> finishSettlement(id, result));
                return;
            }
        }
        Settlement.apply(this, result);
        lastSide = result.side();
        if (cfg.subGameType() == GameConfig.SubGameType.NIU_NIU_BANKER) {
            Player winner = seats.values().stream().max((a, b) -> CardLogic.compare(a.hand(), b.hand(), cfg)).orElseThrow();
            if (winner.hand().type().id() >= CardType.NIU_NIU.id()) niuBankerSeat = winner.seatId();
        }
        if (cfg.gongNiu()) pot = new Pot(pot.owner(), Math.max(0, Math.toIntExact(pot.points() + (result.bankerDelta() + result.entries().stream().filter(Settlement.Entry::banker).findFirst().orElseThrow().commission()
                        - (result.side() == null ? 0 : result.side().delta(banker.uid()))) / 100)),
                pot.number(), pot.rounds(), pot.raises(), pot.tenure());
        if (cfg.gongNiu()) {
            var entry = result.entries().stream().filter(Settlement.Entry::banker).findFirst().orElseThrow();
            bankerProfit += entry.delta() + entry.commission() - (result.side() == null ? 0 : result.side().delta(banker.uid()));
            bankerBalance = banker.chips();
        }
        fire(l -> l.onSettled(this, result));
        for (Player p : seats.values()) {
            p.setReady(false);
        }
        pendingSettlement = null;
        changeState(roundNo >= cfg.round() ? GameState.STOP_GAME : GameState.WAIT_READY);
    }

    // ---------------------------------------------------------------- 机器人

    public synchronized void autoPlayBotsGrab() {
        for (Player p : seats.values()) {
            if ((p.robot() || p.autoPlay()) && !grabDecided.contains(p.uid())) {
                int choice = canGrab(p) ? botPolicy.chooseGrabTimes(p, () -> cfg.grabOptions().getLast()) : 0;
                p.setGrabTimes(cfg.grabOptions().stream().filter(n -> n <= choice).mapToInt(n -> n).max().orElse(0));
                grabDecided.add(p.uid());
                fire(l -> l.onGrab(this, p, p.grabTimes()));
            }
        }
    }

    public synchronized void autoPlayBotsBet() {
        for (Player p : seats.values()) {
            if (p == banker) {
                continue;
            }
            if ((p.robot() || p.autoPlay()) && !betDecided.contains(p.uid())) {
                int[] choices = betChoices(p).stream().mapToInt(Integer::intValue).toArray();
                if (choices.length == 0) continue; // 等待超时按默认一倍处理。
                p.setBetTimes(botPolicy.chooseBetTimes(p, choices));
                totalBetThisRound += (long) cfg.guodi() * p.betTimes();
                betDecided.add(p.uid());
                fire(l -> l.onBet(this, p, p.betTimes()));
            }
        }
    }

    // ---------------------------------------------------------------- 定时器

    public synchronized void startTimers() {
        running = true;
        if (scheduler == null) {
            scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
                Thread t = new Thread(r, "niuniu-table-" + tableId);
                t.setDaemon(true);
                return t;
            });
        }
    }

    public synchronized void stopTimers() {
        running = false;
        cancelTimer();
        if (scheduler != null) {
            scheduler.shutdownNow();
            scheduler = null;
        }
    }

    private void schedule(long ms, Runnable task) {
        if (scheduler != null) {
            UUID scheduledRound = roundId;
            GameState scheduledState = state;
            phaseTimer = scheduler.schedule(() -> {
                synchronized (this) {
                    if (running && scheduledState == state && scheduledRound.equals(roundId)) task.run();
                }
            }, ms, TimeUnit.MILLISECONDS);
        }
    }

    private void cancelTimer() {
        if (phaseTimer != null) {
            phaseTimer.cancel(false);
            phaseTimer = null;
        }
    }

    // 二进制 ReadConfFromDB 尾部硬覆盖：GrabDealer=5s、CallTimes=4s、OutCard=3s、Ready=1s、SettleAnim=3s
    public static final long GRAB_DEADLINE_MS = 5000;
    public static final long BET_DEADLINE_MS = 4000;
    public static final long OUT_CARD_DEADLINE_MS = 3000;
    public static final long READY_DEADLINE_MS = 1000;
    public static final long SETTLE_ANIMATION_MS = 3000;

    private long grabDeadlineMs() {
        return GRAB_DEADLINE_MS;
    }

    private long betDeadlineMs() {
        return BET_DEADLINE_MS;
    }

    private void changeState(GameState s) {
        state = s;
        fire(l -> l.onState(this, s));
    }

    // ---------------------------------------------------------------- 监听

    public void addListener(TableListener l) {
        listeners.add(l);
    }

    private void fire(java.util.function.Consumer<TableListener> action) {
        for (TableListener l : listeners) {
            action.accept(l);
        }
    }

    public interface TableListener {
        default void onState(NiuNiuTable t, GameState s) { }
        default void onSeatChange(NiuNiuTable t, Player p) { }
        default void onReady(NiuNiuTable t, Player p) { }
        default void onDeal(NiuNiuTable t, Player p) { }
        default void onGrab(NiuNiuTable t, Player p, int times) { }
        default void onPot(NiuNiuTable table, boolean raised) {}
        default void onBankerDecided(NiuNiuTable t, Player p) { }
        default void onBet(NiuNiuTable t, Player p, int times) { }
        default void onOpenCard(NiuNiuTable t, Player p) { }
        default void onReveal(NiuNiuTable t, Player p) { }
        default boolean commitRound(java.util.UUID id, Settlement.Result result) { return true; }
        default void onSettled(NiuNiuTable t, Settlement.Result r) { }
        default void onPhaseDeadline(NiuNiuTable t, GameState s, long ms) { }
    }

    public record Seat(long uid, int seat, String name, String portrait, long chips, boolean robot,
                       boolean autoPlay, boolean ready, int grab, int bet, long delta, long total,
                       List<Integer> cards, int sex) {}

    public record Snapshot(GameState phase, int round, UUID roundId, int bankerSeat, int lastBankerSeat,
                           long totalBet, Set<Long> grabbed, Set<Long> bet, List<Seat> players,
                           Settlement.Result pendingSettlement, Set<Long> revealed, Map<Long,Integer> pushLimits,
                           int niuBankerSeat, List<Integer> lepers, Pot pot, SideBets.Book side, SideBets.Posting lastSide, Set<Long> paidStart, List<TableCharge> charges, long bankerProfit, long bankerBalance) {}

    public synchronized Snapshot snapshot() {
        // 发牌/亮牌是同步广播；恢复到广播后玩家下一步实际能操作的阶段。
        var phase = switch (state) {
            case SEND_CARD -> GameState.GRAB_DEALER;
            default -> state;
        };
        var players = seats.values().stream().map(p -> new Seat(p.uid(), p.seatId(), p.nickName(), p.portrait(),
                p.chips(), p.robot(), p.autoPlay(), p.ready(), p.grabTimes(), p.betTimes(), p.roundDelta(),
                p.totalDelta(), p.cards().stream().map(Card::code).toList(), p.sex())).toList();
        var pushLimits = new LinkedHashMap<>(returningPush);
        seats.values().stream().filter(p -> p.pushLimit() > 0).forEach(p -> pushLimits.put(p.uid(), p.pushLimit()));
        return new Snapshot(phase, roundNo, roundId, banker == null ? -1 : banker.seatId(), lastBankerSeat,
                totalBetThisRound, Set.copyOf(grabDecided), Set.copyOf(betDecided), players, pendingSettlement,
                Set.copyOf(revealed), pushLimits, niuBankerSeat, lepers, pot, side.snapshot(), lastSide, Set.copyOf(paidStart), List.copyOf(charges), bankerProfit, bankerBalance);
    }

    public synchronized void restore(Snapshot saved) {
        if (!seats.isEmpty() || saved.round() < 0) throw new IllegalArgumentException("无效牌桌快照");
        state = saved.phase();
        roundNo = saved.round();
        roundId = saved.roundId();
        lastBankerSeat = saved.lastBankerSeat();
        niuBankerSeat = saved.niuBankerSeat();
        totalBetThisRound = saved.totalBet();
        if (saved.pushLimits() != null) returningPush.putAll(saved.pushLimits());
        if (saved.paidStart() != null) paidStart.addAll(saved.paidStart());
        if (saved.charges() != null) charges.addAll(saved.charges());
        bankerProfit = saved.bankerProfit();
        bankerBalance = saved.bankerBalance();
        lastSide = saved.lastSide();
        if (saved.pot() != null) pot = saved.pot();
        lepers = saved.lepers() == null ? List.of() : List.copyOf(saved.lepers());
        if (!inRound()) return; // 等待开局时玩家重新进房，从 data 读取当前筹码。
        if (roundId == null || roundNo == 0 || saved.players().size() < 2
                || !(state == GameState.SIDE_BET || state == GameState.SIDE_GRAB || state == GameState.BANKER_OPTION || state == GameState.GRAB_DEALER || state == GameState.CALL_TIMES || state == GameState.OPEN_CARD || state == GameState.SETTLE)) {
            throw new IllegalArgumentException("无法恢复该局阶段");
        }
        var deck = Deck.forRound(cfg, lepers).cards();
        Set<Long> uids = new HashSet<>();
        for (Seat seat : saved.players()) {
            if (seat.seat() < 0 || seat.seat() >= Math.min(MAX_SEATS, cfg.maxSeatCount())
                    || seats.containsKey(seat.seat()) || seat.uid() <= 0 || !uids.add(seat.uid())
                    || seat.chips() < 0 || seat.chips() > Integer.MAX_VALUE || seat.cards().size() != cfg.handSize()) {
                throw new IllegalArgumentException("无效座位或手牌");
            }
            Player player = new Player(seat.uid(), seat.name(), seat.chips(), seat.robot());
            player.setSeatId(seat.seat());
            player.setOnline(seat.robot());
            player.setReady(seat.ready());
            player.setAutoPlay(seat.autoPlay());
            player.setPortrait(seat.portrait());
            player.setSex(seat.sex());
            player.setGrabTimes(seat.grab());
            Integer push = returningPush.remove(player.uid());
            if (push != null) player.setPushLimit(push);
            player.setBetTimes(seat.bet());
            player.setRoundDelta(seat.delta());
            player.addTotalDelta(seat.total());
            for (int code : seat.cards()) {
                Card card = Card.of(code);
                if (code != card.code() || !deck.remove(card)) {
                    throw new IllegalArgumentException("手牌快照无效");
                }
                player.cards().add(card);
            }
            player.setHand(CardLogic.evaluate(player.cards(), cfg));
            seats.put(seat.seat(), player);
        }
        banker = seats.get(saved.bankerSeat());
        if ((state != GameState.GRAB_DEALER) != (banker != null)
                || !uids.containsAll(saved.grabbed()) || !uids.containsAll(saved.bet())) {
            throw new IllegalArgumentException("无效庄家或操作记录");
        }
        if (banker != null) banker.setBanker(true);
        if (saved.side() != null) {
            var book = saved.side();
            if (book.dealer() > 0) side.claim(book.dealer(), book.dealerBefore());
            for (var stake : book.stakes()) {
                if (bySeat(stake.seat()) == null || bySeat(stake.seat()) == banker)
                    throw new IllegalArgumentException("外围目标无效");
                Player buyer = byUid(stake.uid());
                Long before = book.standingBalances().get(stake.uid());
                if (before != null) {
                    if (buyer != null || before < 0 || before > Integer.MAX_VALUE) throw new IllegalArgumentException("站起玩家余额无效");
                    buyer = new Player(stake.uid(), "", before, false);
                    buyer.setSeatId(-2);
                }
                side.bet(buyer, stake.seat(), stake.amount(), sideLimit());
            }
        }
        grabDecided.addAll(saved.grabbed());
        betDecided.addAll(saved.bet());
        if (saved.revealed() != null) {
            if (!uids.containsAll(saved.revealed())) throw new IllegalArgumentException("无效亮牌座位");
            revealed.addAll(saved.revealed());
        }
        if (state == GameState.SETTLE || state == GameState.OPEN_CARD) {
            pendingSettlement = saved.pendingSettlement();
            if (pendingSettlement == null || pendingSettlement.roundNo() != roundNo
                    || pendingSettlement.bankerUid() != banker.uid() || pendingSettlement.entries().size() != seats.size()) {
                throw new IllegalArgumentException("缺少原局结算明细");
            }
            long net = 0;
            Set<Long> billed = new HashSet<>();
            for (var entry : pendingSettlement.entries()) {
                Player p = seats.get(entry.seatId());
                long after = Math.addExact(entry.before(), entry.delta());
                if (p == null || entry.uid() != p.uid() || !billed.add(p.uid()) || entry.before() != p.chips()
                        || after < 0 || after > Integer.MAX_VALUE) throw new IllegalArgumentException("结算明细与座位不符");
                net += entry.delta();
            }
            if (pendingSettlement.side() != null) {
                var posting = pendingSettlement.side();
                net += posting.dealerDelta();
                for (long uid : posting.standingBalances().keySet()) net += posting.delta(uid);
            }
            net += pendingSettlement.commissionTotal();
            if (net != 0) throw new IllegalArgumentException("结算明细总额不符");
        }
    }

    /** 重新注册后给玩家一个重连窗口；已经开始结算的牌局继续核账。 */
    public synchronized void resume() {
        if (state == GameState.SIDE_GRAB || state == GameState.SIDE_BET) {
            sideDeadline();
        } else if (state == GameState.BANKER_OPTION) {
            bankerDeadline();
        } else if (state == GameState.GRAB_DEALER && cfg.gongNiu() && roundNo > 1) {
            continuePot();
        } else if (state == GameState.SETTLE) {
            schedule(0, () -> finishSettlement(roundId, pendingSettlement));
        } else if (state == GameState.OPEN_CARD) {
            UUID id = roundId;
            fire(l -> l.onPhaseDeadline(this, state, OUT_CARD_DEADLINE_MS));
            schedule(OUT_CARD_DEADLINE_MS, () -> finishReveal(id));
        } else if (state == GameState.GRAB_DEALER && automaticBanker()) {
            finishGrab();
        } else if (state == GameState.GRAB_DEALER || state == GameState.CALL_TIMES) {
            reconnectWindow = true;
            long reconnectMillis = 15_000;
            fire(l -> l.onPhaseDeadline(this, state, reconnectMillis));
            schedule(reconnectMillis, state == GameState.GRAB_DEALER ? this::onGrabTimeout : this::onBetTimeout);
        }
    }

    // ---------------------------------------------------------------- getter

    public int tableId() { return tableId; }
    public GameConfig config() { return cfg; }
    public GameState state() { return state; }
    public int roundNo() { return roundNo; }
    public Player banker() { return banker; }
    public long totalBetThisRound() { return totalBetThisRound; }
    public Map<Integer, Player> seats() { return seats; }
}
