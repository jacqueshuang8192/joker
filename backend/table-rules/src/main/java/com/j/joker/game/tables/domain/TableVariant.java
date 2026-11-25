package com.j.joker.game.tables.domain;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.random.RandomGenerator;

/** 固定版本的好友桌规则。牌序只在开局时生成，恢复时使用已保存的牌序。 */
public interface TableVariant {
    int seats();
    String terms();
    List<Integer> pack();
    FriendRound start(List<Integer> deck, int first);

    default List<Integer> shuffle(RandomGenerator random) {
        var cards = new ArrayList<>(pack());
        Collections.shuffle(cards, random);
        return cards;
    }

    static List<Integer> poker(int copies) {
        var pack = new ArrayList<Integer>();
        for (int suit = 0; suit < 4; suit++)
            for (int rank = 1; rank <= 13; rank++)
                pack.addAll(Collections.nCopies(copies, 16 * suit + rank));
        return pack;
    }
}
