//package com.hbi.service.common;
//
//import org.apache.commons.lang.math.RandomUtils;
//
//import com.core.util.RadomUtil;
//
//public class FightUtil {
//    /**
//     * @param attack
//     * @param defense
//     * @param danTotal 攻击方段位和
//     * @return
//     */
//    public static Long calculateDamage(Long attack, Long defense, Integer danTotal) {
//        if (RadomUtil.calProbability(0.1)) {// 闪避
//            return 0l;
//        }
//        Double criticalTime = 1d; // 暴击倍数
//        if (RadomUtil.calProbability(0.15)) {// 打出暴击
//            Double temp = RandomUtils.nextInt(4) / 10d;
//            criticalTime = 1.2 + temp;
//        }
//        if (danTotal == null || danTotal == 0) {
//            danTotal = 1;
//        }
////        Long damage = (long) (attack * criticalTime
////                * (1d - (defense / (defense + 80d))));
//        Long damage = (long) (criticalTime * attack
//                / (1d + (defense / danTotal)));
//        return damage;
//    }
//}
