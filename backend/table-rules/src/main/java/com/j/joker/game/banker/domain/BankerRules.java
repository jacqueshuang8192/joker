package com.j.joker.game.banker.domain;

import com.j.joker.game.tables.domain.*;
import java.util.*;
import java.util.random.RandomGenerator;

public enum BankerRules implements TableVariant {
    PAI_GOW, POT_DOMINO, POT_BULL;
    public int seats() { return 4; }
    boolean pot() { return this!=PAI_GOW; }
    int handSize() { return this==POT_BULL?5:this==PAI_GOW?4:2; }
    public List<Integer> pack() {
        if(this==POT_BULL) return TableVariant.poker(1);
        var pack=new ArrayList<Integer>();
        for(int i=1;i<=15;i++) pack.addAll(List.of(i,i));
        pack.add(16); pack.add(17);
        return pack;
    }
    public List<Integer> shuffle(RandomGenerator random) {
        var deck=new ArrayList<Integer>();
        for(int i=0;i<(pot()?6:1);i++) {
            var shoe=pack(); Collections.shuffle(shoe,random);
            deck.addAll(shoe.subList(0,seats()*handSize()));
        }
        return deck;
    }
    public FriendRound start(List<Integer> deck,int first) { return new BankerRound(this,deck,first); }
    public String terms() {
        String game=switch(this) {
            case PAI_GOW -> "大牌九每人四张，自选两张组一门，系统排列大小门。两门均赢收注，一胜一负和局。";
            case POT_DOMINO -> "小牌九每人两张，至尊、对子、天王、天地杠、天地高九、普通点依次比。";
            case POT_BULL -> "五张取三张凑十，余二张定牛数；牛牛3倍、牛七至九2倍，其余1倍。按赢家倍数结算。";
        };
        String tie=this==POT_BULL?"牛数同先比最大牌点（K最大），再比花色。":"普通牌比点数再比最高单牌，平手庄胜。";
        return "独立规则 v1｜四人轮庄，先押1或2分再发牌。"+game+tie+
                (pot()?"锅底18分，闲家依下注意愿顺序用锅内可赔额接注；庄家每手可切锅或留庄，锅不足最低赔额可补18分一次。每组最多六手。":"本局一手，次局轮庄。");
    }
}
