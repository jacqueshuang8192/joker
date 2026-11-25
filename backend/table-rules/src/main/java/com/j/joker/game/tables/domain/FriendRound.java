package com.j.joker.game.tables.domain;

import java.util.List;
import java.util.Map;

/** 牌桌只向当前座位投影手牌。存档保存服务端牌序和已接受的操作。 */
public interface FriendRound {
    record Move(int seat, String action, List<Integer> cards) {
        public Move {
            cards = List.copyOf(cards);
        }
    }

    String phase();
    int currentSeat();
    List<Integer> hand(int seat);
    List<String> actions(int seat);
    void apply(Move move);
    Map<String,Object> board(int viewer);
    List<Integer> points();
    Move automatic(int seat);
    int nextStarter(java.util.random.RandomGenerator random);
}
