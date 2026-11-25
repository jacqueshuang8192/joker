package com.j.joker.game.climbing.domain;

import com.j.joker.game.tables.domain.*;
import java.util.List;

public enum ClimbingRules implements TableVariant {
    XINYU(2, true, 0), TAIHE(2, false, 10), XINHUA(2, false, 20), QIANFEN(3, false, 0);

    final int copies, bombPrize;
    final boolean fiveTenKing;
    ClimbingRules(int copies, boolean fiveTenKing, int bombPrize) {
        this.copies = copies;
        this.fiveTenKing = fiveTenKing;
        this.bombPrize = bombPrize;
    }
    public int seats() { return 4; }
    public List<Integer> pack() { return TableVariant.poker(copies); }
    public FriendRound start(List<Integer> deck, int first) { return new ClimbingRound(this, deck, first); }
    public String terms() {
        String special = fiveTenKing ? "杂色510K压普通牌，同花510K更大（黑桃最高），四炸可压510K。" :
                "同点四张起炸，先比张数再比点数。";
        return "独立规则 v1｜四人对家组队，" + copies + "副去王牌。单、对、三张、五张起顺、两对起连对；2最大且不入顺。可过牌。"
                + special + "5计5分，10和K计10分，末手赢家收墩。一人出完即收本墩及余牌分，头游奖20分。"
                + (bombPrize > 0 ? "收墩的炸弹另奖" + bombPrize + "分。" : "")
                + "两队分差由每位队员分别赢付。";
    }
}
