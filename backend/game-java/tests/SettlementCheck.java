import com.j.joker.game.niuniu.domain.card.CardLogic;
import com.j.joker.game.niuniu.domain.card.Card;
import com.j.joker.game.niuniu.domain.card.CardType;
import java.util.Arrays;
import java.util.List;
import com.j.joker.game.niuniu.domain.card.Deck;
import com.j.joker.game.niuniu.domain.rules.GameConfig;
import com.j.joker.game.niuniu.domain.table.*;
import java.util.Collections;
import java.util.Random;

/** 审计报告的固定种子场景，加上整数余额上界和尾数分摊。 */
class SettlementCheck {
    static void check(boolean ok, String message) {
        if (!ok) throw new AssertionError(message);
    }

    static List<Card> cards(int... codes) {
        return Arrays.stream(codes).mapToObj(Card::of).toList();
    }

    static void checkCardsAndPush() throws Exception {
        var rules = GameConfig.fromJson("""
                {"subGameType":1,"speType":"1,2,3,6,8","times":"1,2,4","tuizhu":5,
                 "grabTimes":"2,4","round":5,"niu7":2,"niu8":3,"niu9":3,"niu10":4}
                """);
        var straight = cards(0x21,0x22,0x23,0x24,0x25);
        check(CardLogic.evaluate(straight, rules).type() == CardType.TONG_HUA_SHUN, "straight flush precedence");
        check(CardLogic.evaluate(straight, GameConfig.builder().speType("3").build()).type() == CardType.TONG_HUA,
                "straight flush option disabled");
        check(CardLogic.evaluate(cards(0x01,0x11,0x02,0x12,0x34), rules).type() == CardType.WU_XIAO, "five small totals ten");
        check(CardLogic.evaluate(cards(0x01,0x11,0x02,0x12,0x35), rules).type() != CardType.WU_XIAO, "five small totals eleven");
        check(CardLogic.evaluate(cards(0x0a,0x1a,0x2b,0x3c,0x0d), rules).type() == CardType.WU_HUA, "ten in five flower hand");
        var plain = GameConfig.builder().speType("1").build();
        var lowA = CardLogic.evaluate(straight, plain);
        var lowB = CardLogic.evaluate(cards(1,2,3,4,5), plain);
        check(CardLogic.compare(lowA, lowB, plain) > 0 && CardLogic.compare(lowB, lowA, plain) < 0, "equal low straights use suit");
        var mid = CardLogic.evaluate(cards(2,3,4,5,6), plain);
        check(CardLogic.compare(lowA, mid, plain) < 0, "deployed room compares same straights by highest single card");
        var withLegacyOption = GameConfig.builder().speType("7").build();
        check(CardLogic.evaluate(cards(0x0a,0x1b,0x2c,0x3d,0x08), withLegacyOption).type() != CardType.SI_SHI_DA,
                "unused legacy type cannot override normal room settlement");
        var bankerCards = cards(1,0x12,0x24,0x38,0x1a);
        var sideCards = cards(0x0a,0x1b,0x2c,0x23,0x37);
        check(CardLogic.evaluate(sideCards, rules).type() == CardType.NIU_NIU, "fixed winning hand");
        var zeroRandom = new Random(0) {
            @Override public int nextInt(int bound) { return 0; }
        };
        var table = new NiuNiuTable(1, rules, zeroRandom);
        var bank = table.sit(0, new Player(1, "庄", 10000, false));
        var side = table.sit(1, new Player(2, "闲", 10000, false));
        table.presetHand(0, bankerCards);
        table.presetHand(1, sideCards);
        table.beginRound();
        table.grabBanker(1,4);
        table.grabBanker(2,0);
        table.bet(2,2);
        table.reveal(1);
        // 第一人已亮牌后重启，超时应只补亮第二人，用同一局号结算一次。
        var copy = new NiuNiuTable(1, rules, zeroRandom);
        var seen = new java.util.ArrayList<Long>();
        var settled = new java.util.concurrent.CountDownLatch(1);
        copy.addListener(new NiuNiuTable.TableListener() {
            public void onReveal(NiuNiuTable t, Player p) { seen.add(p.uid()); }
            public void onState(NiuNiuTable t, GameState phase) {
                if (phase == GameState.WAIT_READY) settled.countDown();
            }
        });
        copy.restore(table.snapshot());
        check(copy.userStatus(copy.byUid(1)) == 8 && copy.userStatus(copy.byUid(2)) == 7, "restored partial reveal");
        copy.startTimers();
        try {
            copy.resume();
            check(settled.await(6, java.util.concurrent.TimeUnit.SECONDS) && seen.equals(List.of(2L)), "reveal timeout");
        } finally { copy.stopTimers(); }
        table.reveal(2);
        check(side.chips() == 10320 && bank.chips() == 9680 && side.pushLimit() == 5 && bank.pushLimit() == 0,
                "configured niuniu multiplier, push cap and loss");
        check(copy.byUid(2).chips() == side.chips(), "restored settlement amount");
        table.leaveDisconnected(side);
        var idle = new NiuNiuTable(1, rules, zeroRandom);
        idle.restore(table.snapshot());
        var replacement = idle.sit(1, new Player(3, "新", 10000, false));
        check(replacement.pushLimit() == 0, "new occupant cannot inherit push");
        idle.standUp(3);
        idle.sit(0, new Player(1,"庄",bank.chips(),false));
        var original = idle.sit(1, new Player(2,"闲",side.chips(),false));
        check(original.pushLimit() == 5, "restored player retains push");
        idle.presetHand(0, bankerCards);
        idle.presetHand(1, sideCards);
        idle.beginRound();
        idle.grabBanker(1,4);
        idle.grabBanker(2,4);
        check(idle.banker().uid() == 1 && idle.betChoices(original).equals(List.of(1,2,4,5)), "eligible extra choice");
        original.addChips(19 - original.chips());
        check(idle.pushBet(original) == 0 && idle.betChoices(original).equals(List.of(1,2,4)), "balance below required push");
        original.addChips(-12);
        check(idle.betChoices(original).equals(List.of(1)) && idle.displayedBets(original).equals(List.of(1,2,4,5)),
                "affordable bets are a subset of displayed bets");
        original.addChips(-7);
        check(idle.betChoices(original).isEmpty(), "zero chips cannot manually bet");
        original.addChips(10000);
        original.setGrabTimes(2);
        check(idle.pushBet(original) == 0, "highest grab required");
        original.setGrabTimes(4);
        idle.bet(2,5);
        idle.reveal(1);
        idle.reveal(2);
        check(original.pushLimit() == 0, "push consumed");
    }

    static void checkBankerModes() {
        for (int mode : List.of(2, 3, 4)) {
            var cfg = GameConfig.fromMap(java.util.Map.of("subGameType", mode, "round", 4, "maxSeatCount", 6));
            var t = new NiuNiuTable(80, cfg, new Random(10));
            t.sit(0, new Player(1, "甲", 10000, false));
            t.sit(4, new Player(2, "乙", 10000, false));
            // 首局四号位比零号位大且持牛牛；次局双方均不足牛牛。
            for (int round = 1; round <= 3; round++) {
                t.presetHand(0, cards(1,0x12,0x24,0x38,0x1a));
                t.presetHand(4, round == 1 ? cards(0x0a,0x1b,0x2c,0x23,0x37) : cards(0x21,0x32,4,0x18,0x2a));
                t.beginRound();
                int wanted = switch (mode) {
                    case 3 -> round == 2 ? 4 : 0;
                    case 4 -> round == 1 ? 0 : 4;
                    default -> 0;
                };
                check(t.state() == GameState.CALL_TIMES && t.banker().seatId() == wanted, "mode " + mode + " round " + round);
                var side = t.bySeat(wanted == 0 ? 4 : 0);
                t.bet(side.uid(), 1);
                t.reveal(1);
                t.reveal(2);
                var snapshot = t.snapshot();
                var restore = new NiuNiuTable(80, cfg, new Random(11));
                restore.restore(snapshot);
                for (var p : t.players()) restore.sit(p.seatId(), new Player(p.uid(), p.nickName(), p.chips(), false));
                t = restore;
            }
        }
    }

    public static void main(String[] args) throws Exception {
        checkBankerModes();
        checkCardsAndPush();
        var limits = GameConfig.fromJson("{\"grabDealerChips\":2,\"grabTimes\":3}");
        check(limits.grabOptions().equals(List.of(1,2,3)), "numeric grab limit");
        var restricted = new NiuNiuTable(77, limits, new Random(1));
        var poor = restricted.sit(0, new Player(11, "低", 199, false));
        var eligible = restricted.sit(1, new Player(12, "足", 200, false));
        restricted.beginRound();
        check(!restricted.canGrab(poor) && restricted.canGrab(eligible), "whole-point grab threshold");
        try {
            restricted.grabBanker(poor.uid(), 1);
            throw new AssertionError("unaffordable grab accepted");
        } catch (IllegalArgumentException expected) {
            check(restricted.userStatus(poor) == 2, "rejected grab leaves decision open");
        }
        restricted.grabBanker(poor.uid(), 0);
        restricted.grabBanker(eligible.uid(), 0);
        check(restricted.banker() == eligible, "unclaimed banker goes to eligible player");
        var random = new Random(42);
        var cfg = GameConfig.fromJson("{\"baseChip\":1,\"maxSeatCount\":6}");
        int paidLimit = 0, receivedLimit = 0;
        for (int i = 0; i < 1500; i++) {
            var table = new NiuNiuTable(i, cfg, random);
            var deck = Deck.forConfig(cfg);
            Collections.shuffle(deck.cards(), random);
            for (int seat = 0; seat < 4; seat++) {
                int chips = seat == 0 ? 20 : 100;
                if (i >= 500) chips = i < 1000 ? random.nextInt(62) : Integer.MAX_VALUE - random.nextInt(100);
                var p = new Player(seat + 1, "test", chips, false);
                table.sit(seat, p);
                p.setBanker(seat == 0);
                p.setGrabTimes(1);
                p.setBetTimes(2);
                p.cards().addAll(deck.draw(5));
                p.setHand(CardLogic.evaluate(p.cards(), cfg));
            }
            var result = Settlement.settle(table);
            long net = 0;
            for (var entry : result.entries()) {
                long after = table.byUid(entry.uid()).chips();
                if (after < 0 || after > Integer.MAX_VALUE || after != entry.before() + entry.delta()
                        || Math.abs(entry.delta()) > entry.before()) throw new AssertionError("balance " + i);
                net += entry.delta();
            }
            if (net != 0) throw new AssertionError("round sum " + i);
            if (i < 500 && result.bankerDelta() == -20) paidLimit++;
            if (i < 500 && result.bankerDelta() == 20) receivedLimit++;
        }
        // 302 目录也有十人桌，普通牌一副须能给十人各发五张互异的牌。
        var ten = new NiuNiuTable(2000, GameConfig.fromJson("{\"maxSeatCount\":10}"), random);
        for (int seat = 0; seat < 10; seat++) ten.sit(seat, new Player(seat + 1, "test", 1000, false));
        ten.beginRound();
        if (ten.autoSeat() != -1 || ten.players().stream().flatMap(p -> p.cards().stream())
                .map(c -> c.code()).distinct().count() != 50) throw new AssertionError("ten-seat deal");
        if (paidLimit == 0 || receivedLimit == 0) throw new AssertionError("both banker caps");
        System.out.println("Verified 1500 settlements, grab limits, three automatic banker modes across restart, special hands, reveal and push bets");
    }
}
