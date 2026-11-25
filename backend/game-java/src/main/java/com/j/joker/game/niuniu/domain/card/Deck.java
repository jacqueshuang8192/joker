package com.j.joker.game.niuniu.domain.card;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import com.j.joker.game.niuniu.domain.rules.GameConfig;

/** 一副 52 张牌（不含大小王），对应服务端 CGameLogic::ShulffleCard / GetPokerList。 */
public final class Deck {

    private final List<Card> cards = new ArrayList<>(52);

    public Deck() {
        this(13);
    }

    /** hasJQK=0（无 JQK 玩法）时只造 40 张：点数 1~10。 */
    public Deck(int maxRank) {
        for (int suit = 0x00; suit <= 0x30; suit += 0x10) {
            for (int rank = 1; rank <= maxRank; rank++) {
                cards.add(Card.of(suit | rank));
            }
        }
    }

    public static List<Integer> chooseLepers(GameConfig cfg, Random random) {
        return switch (cfg.leperMode()) {
            case 1 -> List.of(Card.SMALL_JOKER, Card.BIG_JOKER);
            case 2 -> List.of(0x40 | (1 + random.nextInt(cfg.hasJQK() ? 13 : 10)));
            default -> List.of();
        };
    }

    public static Deck forConfig(GameConfig cfg) {
        return forRound(cfg, chooseLepers(cfg, java.util.concurrent.ThreadLocalRandom.current()));
    }

    /** 验证本局实际公布的癞子，恢复时逐张核销同一副牌。 */
    public static Deck forRound(GameConfig cfg, List<Integer> lepers) {
        int max = cfg.hasJQK() ? 13 : 10;
        Deck deck = new Deck(max);
        switch (cfg.leperMode()) {
            case 0 -> {
                if (!lepers.isEmpty()) throw new IllegalArgumentException("普通牌桌含癞子");
            }
            case 1 -> {
                if (!lepers.equals(List.of(Card.SMALL_JOKER, Card.BIG_JOKER)))
                    throw new IllegalArgumentException("大小王配置无效");
                lepers.forEach(code -> deck.cards.add(Card.of(code)));
            }
            case 2 -> {
                if (lepers.size() != 1 || lepers.getFirst() < 0x41 || lepers.getFirst() > 0x40 + max)
                    throw new IllegalArgumentException("随机癞子点数无效");
                Card wild = Card.of(lepers.getFirst());
                deck.cards.replaceAll(card -> card.value() == wild.value() ? wild : card);
            }
        }
        return deck;
    }

    public static Deck shuffled(Random random) {
        Deck d = new Deck();
        Collections.shuffle(d.cards, random);
        return d;
    }

    public List<Card> cards() {
        return cards;
    }

    public int size() {
        return cards.size();
    }

    /** 从牌堆顶取 n 张。 */
    public List<Card> draw(int n) {
        if (n > cards.size()) {
            throw new IllegalStateException("牌不够: need=" + n + " left=" + cards.size());
        }
        List<Card> out = new ArrayList<>(n);
        for (int i = 0; i < n; i++) {
            out.add(cards.remove(cards.size() - 1));
        }
        return out;
    }

    public void removeAll(List<Card> used) {
        cards.removeAll(used);
    }

    /**
     * 服务端控牌入口：把指定牌插入牌堆顶部（发牌时优先发出）。
     * 对应 CGameTable::RandomShulffle 中先洗牌再按目标牌型重排的逻辑。
     */
    public void stackTop(List<Card> target) {
        cards.removeAll(target);
        cards.addAll(target);
    }
}
