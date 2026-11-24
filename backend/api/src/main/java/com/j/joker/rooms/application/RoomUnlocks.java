package com.j.joker.rooms.application;

public interface RoomUnlocks {
    /** 当前登录态不在此桌返回 0，其他情况返回当前窗口内的尝试次数。 */
    long attempt(long uid, String token, long activity);
    boolean grant(long uid, String token, long activity);
}
