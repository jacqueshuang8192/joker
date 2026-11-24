package com.j.joker.game.niuniu.domain.card;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

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

    public static Deck forConfig(com.j.joker.game.niuniu.domain.rules.GameConfig cfg) {
        return new Deck(cfg.hasJQK() ? 13 : 10);
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
