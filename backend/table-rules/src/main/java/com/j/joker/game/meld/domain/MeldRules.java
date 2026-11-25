package com.j.joker.game.meld.domain;

import com.j.joker.game.tables.domain.*;
import java.util.*;

/** 新版好友桌的固定规则；地区名称用于选择牌具及计分方案。 */
public enum MeldRules implements TableVariant {
    CHANGDE(Pack.WORD,15,3), LOUDI(Pack.WORD,15,1), HANSHOU(Pack.WORD,18,3),
    SHAOYANG(Pack.WORD,10,3), BAYI(Pack.WORD,10,1), SANPI(Pack.WORD,6,3),
    PENGPENG(Pack.WORD,6,1), GUIHU(Pack.WORD,10,3), XUPU(Pack.WORD,9,3),
    LIUZHOU_WORD(Pack.WORD,12,3), JINGCHU(Pack.FLOWER,3,1), NINETY_SIX(Pack.RED_BLACK,6,3),
    LIUZHOU(Pack.HONORS,1,1), CHANGSHA(Pack.SUITED,1,1), XINYU(Pack.SUITED,1,1),
    YUANJIANG(Pack.RED,2,1), MEIZHOU(Pack.RED,3,1), CHUOXIA(Pack.RED,2,1), LAOPAI(Pack.HONORS,1,1);

    enum Pack { WORD, FLOWER, RED_BLACK, SUITED, HONORS, RED }
    final Pack type;
    final int minimum, step;
    MeldRules(Pack type, int minimum, int step) { this.type=type; this.minimum=minimum; this.step=step; }
    boolean mahjong() { return type==Pack.SUITED || type==Pack.HONORS || type==Pack.RED; }
    boolean pairRequired() { return mahjong(); }
    int initial() { return mahjong() ? 13 : 20; }
    public int seats() { return mahjong() ? 4 : 3; }
    int wildcard() { return type==Pack.RED ? 65 : this==GUIHU ? 42 : type==Pack.FLOWER ? 45 : 0; }
    public List<Integer> pack() {
        var cards=new ArrayList<Integer>();
        if (mahjong()) {
            for (int suit=0;suit<3;suit++) addRange(cards,16*suit+1,9,4);
            if (type==Pack.HONORS) addRange(cards,49,7,4);
            if (type==Pack.RED) addRange(cards,65,1,4);
        } else if (type==Pack.FLOWER) {
            for(int n=1;n<=10;n++) {
                boolean hasFlower=n%2==1;
                addRange(cards,n,1,hasFlower?3:5);
                if(hasFlower) addRange(cards,16+n,1,2);
            }
            addRange(cards,33,12,5); addRange(cards,45,1,2);
        } else {
            int width=type==Pack.RED_BLACK ? 12 : 10;
            addRange(cards,1,width,4); addRange(cards,17,width,4);
            if (this==GUIHU) addRange(cards,42,1,2);
        }
        return cards;
    }
    int face(int tile) {
        return type==Pack.FLOWER && tile>=17 && tile<=25 ? tile&15 : tile;
    }
    private static void addRange(List<Integer> out,int first,int count,int copies) {
        for(int i=0;i<count;i++) out.addAll(Collections.nCopies(copies,first+i));
    }
    private static final Map<MeldRules,MeldHand> HANDS = new EnumMap<>(MeldRules.class);
    static { for (var rules : values()) HANDS.put(rules,new MeldHand(rules)); }
    MeldHand evaluator() { return HANDS.get(this); }
    public FriendRound start(List<Integer> deck,int first) { return new MeldRound(this,deck,first); }
    public String terms() {
        if (mahjong()) {
            String tiles = type==Pack.HONORS ? "136张，含风箭" : type==Pack.RED ? "112张，红中万能" : "万条筒108张";
            String feature=switch(this) {
                case CHANGSHA -> "普通胡须二五八作将。";
                case XINYU -> "手牌与明组集齐同门一至九再加2分。";
                case LIUZHOU -> "胡后翻两张，159、东、中每中一张加1分。";
                case LAOPAI -> "清一色或字一色加2分。";
                case CHUOXIA -> "胡后翻一张，点数加分（红中9分）。";
                default -> "";
            };
            return "独立规则 v1｜四人，"+tiles+"，四组一对或门清七对，可吃碰杠。"+feature+
                    "胡牌底"+minimum+"分，七对加2。自摸三家各付双倍，点炮一人付；多人争胡取下家顺序首位。杠只补牌，流局零分。";
        }
        String faces=switch(type) {
            case FLOWER -> "112张含素牌、花牌及两别杠。花素同字可合组，别杠代闭手牌。孔乙己、化三千、十七土、八九子、上大人、可知礼可成句。";
            case RED_BLACK -> "96张红黑扑克，红黑各A至Q每点四张；同色三连和二七十可成句。";
            default -> "大小一至十各四张；同门三连、二七十、同点大小搭可成句。";
        };
        return "独立规则 v1｜三人20张，七组胡，无将。"+faces+
                (this==GUIHU?"另加两鬼，可替闭手牌。":"")+
                "暗刻小3大6，碰小1大3，杠小6大9；一二三、二七十或花牌字句小3大6，其余顺搭零息。"
                +(type==Pack.FLOWER?"每张实花加一息。":"")+minimum+"息起，1分起每多"+step+"息加1分。"
                +(this==SANPI?"结算乘3。":this==PENGPENG?"全刻再翻倍。":"")
                +"下家可吃，碰杠优先。点炮单付，自摸两家各付，流局零分。";
    }
}
