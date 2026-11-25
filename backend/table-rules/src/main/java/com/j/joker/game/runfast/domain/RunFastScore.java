package com.j.joker.game.runfast.domain;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 325 三人十六张基础房。只为没有被更大炸弹盖过的炸弹计分。 */
public final class RunFastScore {
    private RunFastScore() {}

    public record Seat(int uid, int cardsLeft, int winningBombs) {
        public Seat {
            if (uid <= 0 || cardsLeft < 0 || cardsLeft > 16 || winningBombs < 0 || winningBombs * 4L > 16 - cardsLeft)
                throw new IllegalArgumentException("跑得快结算人数、剩牌或炸弹数有误");
        }
    }

    public static Map<Integer,Long> settle(List<Seat> seats, int pointUnit) {
        if (pointUnit <= 0 || (seats.size()<2 || seats.size()>3) || seats.stream().map(Seat::uid).distinct().count() != seats.size())
            throw new IllegalArgumentException("需要两或三个不同的玩家和正数底分");
        var winners = seats.stream().filter(seat -> seat.cardsLeft == 0).toList();
        if (winners.size() != 1) throw new IllegalArgumentException("应有一人先出完");
        int winner = winners.getFirst().uid;
        int allBombs = seats.stream().mapToInt(Seat::winningBombs).sum();
        var points = new HashMap<Integer,Long>();
        long cardPot = 0;
        for (Seat seat : seats) {
            int charge = switch (seat.cardsLeft) {
                case 0, 1 -> 0;
                case 16 -> 32;
                default -> seat.cardsLeft;
            };
            cardPot += (long)charge * pointUnit;
            // 每个有效炸弹向另外两家各收十分，包括最后没有出完的炸弹赢家。
            long bombScore = 10L * (seats.size() * seat.winningBombs - allBombs);
            points.put(seat.uid, (bombScore - charge) * pointUnit);
        }
        points.merge(winner, cardPot, Math::addExact);
        return Map.copyOf(points);
    }
}
