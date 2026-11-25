import com.j.joker.game.niuniu.domain.card.*;
import com.j.joker.game.niuniu.domain.rules.*;
import com.j.joker.game.niuniu.domain.table.*;
import java.util.*;

public class VariantsCheck {
    static void check(boolean ok, String message) { if (!ok) throw new AssertionError(message); }
    static void rejected(Runnable action) {
        try { action.run(); throw new AssertionError("invalid action accepted"); }
        catch (IllegalArgumentException expected) { }
    }
    static List<Card> cards(int... codes) { return Arrays.stream(codes).mapToObj(Card::of).toList(); }
    static void wildcards() {
        check(Card.of(0x4e).logicValue()==10 && Card.of(0x4f).logicValue()==10 && Card.of(1).logicValue()==1, "joker pip values");
        for (int mode=0; mode<=2; mode++) for (boolean faces: List.of(true,false)) {
            var cfg=GameConfig.fromMap(Map.of("hasLeper", mode, "gaoji",faces ? "" : "6"));
            for(int seed=0;seed<100;seed++) {
                var choices=Deck.chooseLepers(cfg,new Random(seed));
                var deck=Deck.forRound(cfg,choices);
                check(deck.size()==(faces ? 52 : 40)+(mode==1 ? 2 : 0),"deck size");
                check(deck.cards().stream().filter(c->c.suit()==Suit.LAI_ZI).count()==(mode==2?4:mode*2),"wildcard copies");
                if(mode==2) check(deck.cards().stream().noneMatch(c->c.suit()!=Suit.LAI_ZI && c.value()==(choices.getFirst()&15)),"replaced all suits");
            }
        }
        var cfg=GameConfig.fromMap(Map.of("hasLeper",2,"speType","8,6,5,4,3,2,1"));
        check(CardLogic.evaluate(cards(0x12,0x13,0x15,0x16,0x48),cfg).type()==CardType.TONG_HUA_SHUN,"wild straight flush");
        check(CardLogic.evaluate(cards(1,0x11,0x12,3,0x48),cfg).type()==CardType.WU_XIAO,"wild five small");
        check(CardLogic.evaluate(cards(9,0x19,0x29,3,0x48),cfg).type()==CardType.SI_ZHA,"wild quads");
        var plain=GameConfig.fromMap(Map.of("hasLeper",2,"speType",""));
        var hand=cards(0x43,0x43,0x43,0x43,9);
        check(CardLogic.evaluate(hand,plain).type()==CardType.NIU_NIU && CardLogic.evaluate(hand,plain).hand().containsAll(hand),"four original wildcards");
        var table=new NiuNiuTable(1,plain,new Random(0){public int nextInt(int bound){return Math.min(2,bound-1);}});
        table.sit(0,new Player(10,"a",10000,false)); table.sit(1,new Player(20,"b",10000,false));
        table.presetHand(0,hand); table.beginRound();
        var restored=new NiuNiuTable(1,plain,new Random(7)); restored.restore(table.snapshot());
        check(restored.lepers().equals(List.of(0x43)) && restored.bySeat(0).cards().equals(hand),"duplicate wildcards survive restart");
    }
    static void round(boolean claimed, boolean gong) {
        var cfg=GameConfig.fromMap(Map.of("subGameType",gong?5:1,"speType","","waiwei","1","guodi",30,"round",2));
        var t=new NiuNiuTable(3,cfg,new Random(7));
        var bank=t.sit(0,new Player(10,"a",20000,false));
        var bettor=t.sit(1,new Player(20,"b",20000,false));
        t.presetHand(0,cards(1,0x12,0x24,0x38,0x1a)); t.presetHand(1,cards(0x0a,0x1b,0x2c,0x23,0x37));
        t.beginRound(); t.grabBanker(10,1); t.grabBanker(20,0);
        if (gong) rejected(()->t.bet(20,11));
        t.bet(20,gong?10:1);
        check(t.state()==GameState.SIDE_GRAB,"side phase before cards opened");
        if(claimed) {
            rejected(()->t.sideDealer(30,7));
            t.sideDealer(30,10);
        } else t.startSideBets();
        rejected(()->t.sideBet(20,0,1)); rejected(()->t.sideBet(20,1,-1));
        rejected(()->t.sideBet(20,1,11)); rejected(()->t.sideBet(333,1,1));
        t.sideBet(20,1,3); t.sideBet(20,1,4);
        var standing = new Player(40,"standing",100,false);
        standing.setSeatId(-2);
        t.sideBet(standing,1,2);
        var copy=new NiuNiuTable(3,cfg,new Random(8)); copy.restore(t.snapshot());
        check(copy.playingSide(40) && copy.side().outsideBalances().get(40L)==100,"standing stake survives restart");
        check(copy.side().bySeat(20,1)==7 && copy.side().dealer()==(claimed?30:0),"restored side book");
        copy.openAndSettle();
        var reveal=new NiuNiuTable(3,cfg,new Random(9)); reveal.restore(copy.snapshot());
        reveal.reveal(10); reveal.reveal(20);
        check(reveal.lastSide().delta(20)==7 && reveal.lastSide().delta(40)==2 && reveal.lastSide().dealerDelta()==-9,"side pays even money");
        check(reveal.lastSide().closingBalances().get(40L)==102,"standing closing balance survives settlement");
        check(reveal.bySeat(0).chips()+reveal.bySeat(1).chips()-7==bank.chips()+bettor.chips(),"all accounts balance");
        if (gong) {
            check(reveal.potPoints()==0 && reveal.bySeat(0).roundDelta()==-3000,"shot exhausts pot at 100 chips per point");
            reveal.bySeat(0).setOnline(true); reveal.bySeat(1).setOnline(true); reveal.beginRound();
            check(reveal.state()==GameState.BANKER_OPTION,"next pot action");
            rejected(()->reveal.bankerAction(20,1));
            var restored=new NiuNiuTable(3,cfg,new Random(10)); restored.restore(reveal.snapshot());
            restored.bankerAction(10,1);
            check(restored.banker().uid()==20 && restored.potPoints()==30 && restored.pot().number()==2,"rotated funded pot");
        }
    }
    static void tableCharges() {
        var rules=GameConfig.fromMap(Map.of("subGameType",5,"guodi",30,"round",4,"startCost",25,
                "startCostOneOrAll",1,"upBankWater",2,"downBankWater",10));
        var t=new NiuNiuTable(4,rules,new Random(4));
        t.sit(0,new Player(10,"a",20000,false)); t.sit(1,new Player(20,"b",20000,false));
        t.presetHand(1,cards(1,0x12,0x24,0x38,0x1a)); t.presetHand(0,cards(0x0a,0x1b,0x2c,0x23,0x37));
        t.beginRound();
        check(t.pendingCharges().size()==2 && t.byUid(20).chips()==19975,"opening costs before play");
        t.acknowledgeCharges();
        t.grabBanker(10,1); t.grabBanker(20,0);
        check(t.pendingCharges().getFirst().amount()==60,"up fee uses configured pot");
        t.acknowledgeCharges(); t.bet(20,10); t.reveal(10); t.reveal(20);
        long profit=t.byUid(10).chips()-(20000-25-60);
        check(profit>0,"forced banker win");
        var saved=t.snapshot();
        t.beginRound();
        check(t.pendingCharges().isEmpty(),"once per player across rounds");
        var recovered=new NiuNiuTable(4,rules,new Random(12));
        recovered.restore(saved); recovered.standUp(10);
        check(recovered.pot().owner()==0,"recovered banker released");
        check(recovered.pendingCharges().size()==1 && recovered.pendingCharges().getFirst().amount()==profit/10,"banker profit survives idle restart");
        recovered.endTenure();
        check(recovered.pendingCharges().size()==1,"tenure charged once");
    }

    static void fees() {
        var scores=Map.of(1,951L,2,951L,3,-1902L);
        var balances=Map.of(1,2000L,2,2000L,3,5000L);
        var cfg=ClubFee.from(Map.of("profit","10","profitLimit",100,"profitType",1,"additionalPoint",2,"oneOrAll",2));
        var plan=cfg.calculate(scores,balances);
        check(plan.total()==194 && plan.attribution().get(1)==64 && plan.attribution().get(3)==63,"tied winners, shared attribution, residue");
        var partner = ClubFee.from(Map.of("profit",10,"profitLimit",0,"additionalPoint",20,"additional_point_from","partner"))
                .calculate(scores,balances);
        check(partner.total()==190 && partner.attribution().values().stream().mapToInt(i->i).sum()==170
                && partner.charges().values().stream().mapToInt(ClubFee.Charge::additional).sum()==20, "bonus from partner share");
        var fixed=ClubFee.from(Map.of("rateOrConstant",2,"profit","1.25","profitLimit",0));
        check(fixed.calculate(scores,balances).total()==250,"fixed display point scale");
        var tiers=ClubFee.from(Map.of("rateOrConstant",3,"profitLimit",0,"secConstant","0-499-50,500-1000-100"));
        check(tiers.calculate(scores,balances).total()==200,"tiered fee");
    }
    public static void main(String[] args) {
        wildcards(); fees(); tableCharges();
        for(boolean claimed:List.of(true,false)) for(boolean gong:List.of(true,false)) round(claimed,gong);
        System.out.println("Verified wildcard decks and fixed hands, banker pot and shot, both side dealers, restart, fee tiers and ties.");
    }
}
