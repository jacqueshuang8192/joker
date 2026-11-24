package com.j.joker.game.rooms.domain;

/** 活动与桌号的有效绑定。只在牌桌仍存在时提供路由。 */
public record RoomRoute(int tid, int activity, int owner, String invite, int club, int base, int seats, String rules) {}
