package com.j.joker.game.mahjong.domain;

import java.util.List;

/** zhuaniao=999 对应客户端的“一码全中”，其余取实际抓牌数。 */
public record HongzhongOptions(boolean red,int birds) {
    public static final HongzhongOptions DEFAULT = new HongzhongOptions(true,2);
    public HongzhongOptions {
        if (!List.of(0,2,4,6,8,999).contains(birds)) throw new IllegalArgumentException("抓鸟选项无效");
    }
    public int drawCount() { return birds==999 ? 1 : birds; }
    public int hits(List<Integer> drawn) {
        if (drawn.isEmpty()) return 0;
        if (birds==999) return drawn.getFirst()==HongzhongHand.RED ? 9 : (drawn.getFirst() & 15);
        return (int)drawn.stream().filter(t -> t==HongzhongHand.RED || (t & 15)%4==1).count();
    }
}
