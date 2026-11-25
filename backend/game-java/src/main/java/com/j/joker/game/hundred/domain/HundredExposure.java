package com.j.joker.game.hundred.domain;

import java.math.BigInteger;
import java.util.Arrays;
import java.util.List;
import static com.j.joker.game.hundred.domain.HundredSettlement.*;

/** 报单前检查所有可能的输赢，避免封盘时才发现钱包无法存入赢分。 */
public final class HundredExposure {
    private HundredExposure() {}

    private static long baccaratMaxWin(long[] a) {
        return Math.max(Math.abs(a[0]-a[1]),8*a[2])+11*(a[3]+a[4]);
    }
    public static void check(int level, List<Banker> bankers, int balance, long[] own, long[] totals) {
        long maxLoss = Arrays.stream(own).sum() * (level == 102 ? 13 : 1);
        long playerWin, houseLoss, houseWin;
        if (level == 101) {
            long d = totals[0], t = totals[1], tie = totals[2];
            houseLoss = Math.max(Math.abs(d - t) - tie, 6 * tie);
            houseWin = Math.max(0, Math.abs(d - t) + tie);
            playerWin = Math.max(Math.abs(own[0] - own[1]) - own[2], 6 * own[2]);
        } else if(level==Baccarat.LEVEL) {
            houseLoss=baccaratMaxWin(totals);
            playerWin=baccaratMaxWin(own);
            houseWin=Arrays.stream(totals).sum();
        } else {
            playerWin = maxLoss;
            houseWin = houseLoss = 13 * Arrays.stream(totals).sum();
        }
        if (maxLoss > balance || playerWin > Integer.MAX_VALUE - balance)
            throw new IllegalArgumentException("玩家筹码不足或可能超过钱包上限");
        long pool = bankers.stream().mapToLong(Banker::chips).sum();
        if (houseLoss > pool) throw new IllegalArgumentException("庄家出资不足");
        for (var banker : bankers) {
            // 最大余数分摊可能向上取整一个单位。
            var maxWin = BigInteger.valueOf(houseWin).multiply(BigInteger.valueOf(banker.chips()));
            var capacity = BigInteger.valueOf(Integer.MAX_VALUE - banker.chips()).multiply(BigInteger.valueOf(pool));
            if (maxWin.compareTo(capacity) > 0) throw new IllegalArgumentException("庄家赢分可能超过钱包上限");
        }
    }
}
