package com.j.joker.game.tables.domain;

import com.j.joker.game.landlord.domain.LandlordTable;
import com.j.joker.game.mahjong.domain.HongzhongRound;
import com.j.joker.game.mahjong.domain.HongzhongOptions;
import com.j.joker.game.runfast.domain.RunFastRound;
import com.j.joker.game.threecard.domain.GoldenFlower;
import com.j.joker.game.threecard.domain.Sangong;
import com.j.joker.game.banker.domain.BankerRules;
import com.j.joker.game.climbing.domain.ClimbingRules;
import com.j.joker.game.meld.domain.MeldRules;
import com.j.joker.game.water.domain.WaterRound;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.random.RandomGenerator;

public enum FriendRules {
    LANDLORD(324, 3), RUN_FAST(325, 3), HONGZHONG(308, 4),
    GOLDEN_FLOWER(317,3,GoldenFlower.RULES), SANGONG(360,3,Sangong.RULES), WATER(365,4,WaterRound.RULES),
    OPEN_LANDLORD(9324,3,"独立规则 v1｜三人叫抢，叫1或3，每抢翻倍，四张炸弹翻倍。定庄后各选普通、暗加倍×2或公开余牌×4。两名农民分别与地主结算，双方个人倍数相乘。"),
    FLOAT_DUEL(9325,2,"独立规则 v1｜两人各16张，余16张封存。首局黑桃三持有者先出，封存时房主先出。开局每人飘0至2分。先出完者收对方剩牌分及两人飘分；剩一张免牌分，16张关门双倍。有效炸弹向对手收10分。"),
    FLOAT_THREE(9425,3,"独立规则 v1｜三人16张，先选飘0至2分。首局黑桃三先出，以后赢家先出。每家输家付剩牌分及自己和赢家飘分之和。报单免牌分，关门双倍，有效炸弹向其余各家收10分。"),
    CLASSIC_DOMINO(315,BankerRules.PAI_GOW), POT_DOMINO(318,BankerRules.POT_DOMINO), POT_BULL(368,BankerRules.POT_BULL),
    FIVE_TEN_KING(369,ClimbingRules.XINYU), GUOZHA(381,ClimbingRules.TAIHE), DAZHA(397,ClimbingRules.XINHUA),
    QIANFEN(383,ClimbingRules.QIANFEN), CHANGDE(342,MeldRules.CHANGDE), LOUDI(345,MeldRules.LOUDI),
    HANSHOU(501,MeldRules.HANSHOU), SHAOYANG(353,MeldRules.SHAOYANG), BAYI(359,MeldRules.BAYI),
    SANPI(374,MeldRules.SANPI), PENGPENG(375,MeldRules.PENGPENG), GUIHU(379,MeldRules.GUIHU),
    XUPU(392,MeldRules.XUPU), LIUZHOU_WORD(9342,MeldRules.LIUZHOU_WORD), JINGCHU(388,MeldRules.JINGCHU),
    NINETY_SIX(384,MeldRules.NINETY_SIX), LIUZHOU(329,MeldRules.LIUZHOU), CHANGSHA(320,MeldRules.CHANGSHA),
    XINYU(371,MeldRules.XINYU), YUANJIANG(358,MeldRules.YUANJIANG), MEIZHOU(366,MeldRules.MEIZHOU),
    CHUOXIA(389,MeldRules.CHUOXIA), LAOPAI(391,MeldRules.LAOPAI);

    public final int level;
    public final int seats;
    public final String terms;
    private final TableVariant variant;
    FriendRules(int level,TableVariant variant) {
        this.level=level; this.seats=variant.seats(); this.terms=variant.terms(); this.variant=variant;
    }
    FriendRules(int level,int seats) { this(level,seats,""); }
    FriendRules(int level,int seats,String terms) { this.level=level; this.seats=seats; this.terms=terms; this.variant=null; }

    public static FriendRules forLevel(int level) {
        for (var rules : values()) if (rules.level == level) return rules;
        throw new IllegalArgumentException("该场次尚未开放好友桌");
    }

    public List<Integer> deck(RandomGenerator random) {
        return deck(random,HongzhongOptions.DEFAULT);
    }
    public List<Integer> deck(RandomGenerator random,HongzhongOptions options) {
        if (variant!=null) return variant.shuffle(random);
        var deck = new ArrayList<Integer>();
        if (this == HONGZHONG) {
            for (int suit = 0; suit < 3; suit++)
                for (int face = 1; face <= 9; face++) deck.addAll(Collections.nCopies(4, suit * 16 + face));
            if (options.red()) deck.addAll(Collections.nCopies(4, 0x41));
        } else {
            for (int suit = 0; suit < 4; suit++) {
                for (int face = 1; face <= 13; face++) {
                    if ((this == RUN_FAST || this == FLOAT_DUEL || this == FLOAT_THREE) && (face == 1 && suit == 0 || face == 2 && suit != 3)) continue;
                    deck.add(suit * 16 + face);
                }
            }
            if (this == LANDLORD || this == OPEN_LANDLORD) deck.addAll(List.of(0x4e, 0x4f));
        }
        Collections.shuffle(deck, random);
        return deck;
    }

    public FriendRound start(List<Integer> deck) {
        return start(deck,-1,HongzhongOptions.DEFAULT);
    }

    public FriendRound start(List<Integer> deck, int first,HongzhongOptions options) {
        if (variant!=null) return variant.start(deck,Math.max(0,first));
        return switch (this) {
            case GOLDEN_FLOWER -> new GoldenFlower(deck,Math.max(0,first));
            case WATER -> new WaterRound(deck,Math.max(0,first));
            case SANGONG -> new Sangong(deck,Math.max(0,first));
            case OPEN_LANDLORD -> new LandlordTable(deck,Math.max(0,first),true);
            case FLOAT_DUEL,FLOAT_THREE -> new RunFastRound(deck,first,seats,true);
            case LANDLORD -> new LandlordTable(deck,Math.max(0,first));
            case RUN_FAST -> new RunFastRound(deck,first);
            case HONGZHONG -> new HongzhongRound(deck,Math.max(0,first),options);
            default -> throw new IllegalStateException(name());
        };
    }
}
