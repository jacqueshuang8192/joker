package com.j.joker.game.niuniu.domain.table;

import com.j.joker.game.niuniu.domain.card.Card;
import com.j.joker.game.niuniu.domain.card.Deck;
import com.j.joker.game.niuniu.domain.rules.GameConfig;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

/** 普通桌从同一副洗好的牌依次发牌。固定牌例只用于进程内测试，一局后清空。 */
public final class CardController {
    private final Random random;
    private final GameConfig cfg;
    private final Map<Integer, List<Card>> presets = new HashMap<>();

    public CardController(GameConfig cfg, Random random) {
        this.cfg = cfg;
        this.random = random;
    }

    public void preset(int seat, List<Card> cards) {
        if (cards.size() != cfg.handSize()) throw new IllegalArgumentException("固定手牌张数不符");
        presets.put(seat, List.copyOf(cards));
    }

    List<List<Card>> deal(List<Player> players) {
        Deck deck = Deck.forConfig(cfg);
        Collections.shuffle(deck.cards(), random);
        for (Player player : players) {
            for (Card card : presets.getOrDefault(player.seatId(), List.of())) {
                if (!deck.cards().remove(card)) throw new IllegalArgumentException("重复或无效的固定牌");
            }
        }
        List<List<Card>> hands = new ArrayList<>(players.size());
        for (Player player : players) {
            List<Card> preset = presets.get(player.seatId());
            hands.add(preset == null ? deck.draw(cfg.handSize()) : preset);
        }
        presets.clear();
        return hands;
    }
}
