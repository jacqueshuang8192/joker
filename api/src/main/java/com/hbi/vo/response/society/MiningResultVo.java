package com.hbi.vo.response.society;

/**
 * Created by ceeuoo on 4/8/2016.
 */
public class MiningResultVo {
    /**
     * 当前轮数
     */
    private Integer round;

    /**
     * 挖坑返回数据
     */
    private MiningDig miningDig;

    /**
     * 战斗返回数据
     */
    private BattleResult battleResult;

    public BattleResult getBattleResult() {
        return battleResult;
    }

    public void setBattleResult(BattleResult battleResult) {
        this.battleResult = battleResult;
    }

    public MiningDig getMiningDig() {
        return miningDig;
    }

    public void setMiningDig(MiningDig miningDig) {
        this.miningDig = miningDig;
    }

    public Integer getRound() {
        return round;
    }

    public void setRound(Integer round) {
        this.round = round;
    }
}
