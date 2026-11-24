package com.j.joker.game.rooms.domain;

/** 玩家当前分配到的场次、牌桌和活动。 */
public record RoomAssignment(int level, int tid, int activity) {}
