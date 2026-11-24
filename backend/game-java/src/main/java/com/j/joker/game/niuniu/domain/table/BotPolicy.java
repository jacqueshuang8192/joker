package com.j.joker.game.niuniu.domain.table;

import com.j.joker.game.niuniu.domain.card.HandResult;
import java.util.List;
import java.util.Random;

/**
 * 机器人/托管决策。
 *
 * <p>对应二进制 CGameTable::autoDealGrabDealer / autoDealCallTimes /
 * getBestTimes4SmartRobot：按手牌强度决定抢庄倍数与下注倍数。
 */
public final class BotPolicy {

    private final Random random;

    public BotPolicy(Random random) {
        this.random = random;
    }

    /** 抢庄：0=不抢，1..4=抢几倍。 */
    public int chooseGrabTimes(Player p, GameConfigView cfg) {
        HandResult h = p.hand();
        if (h == null) {
            return 0;
        }
        int s = h.type().strength();
        if (s >= 10) {
            return 4;
        }
        if (s >= 8) {
            return random.nextInt(4) < 3 ? 3 : 2;
        }
        if (s >= 5) {
            return random.nextInt(3) < 2 ? 2 : 1;
        }
        if (s >= 2) {
            return random.nextInt(3) == 0 ? 1 : 0;
        }
        return 0;
    }

    /** 下注倍数：从配置可选倍数里挑。 */
    public int chooseBetTimes(Player p, int[] options) {
        HandResult h = p.hand();
        if (h == null || options.length == 0) {
            return 1;
        }
        int s = h.type().strength();
        int idx;
        if (s >= 10) {
            idx = options.length - 1;
        } else if (s >= 7) {
            idx = Math.max(0, options.length - 2);
        } else if (s >= 4) {
            idx = Math.min(options.length - 1, options.length / 2);
        } else {
            idx = 0;
        }
        // 少量随机扰动，避免机器人行为完全固定
        if (random.nextInt(100) < 20 && idx > 0) {
            idx--;
        }
        return options[idx];
    }

    /** 供策略使用的配置视图，避免机器人直接依赖可变配置。 */
    public interface GameConfigView {
        int maxGrabTimes();
    }
}
