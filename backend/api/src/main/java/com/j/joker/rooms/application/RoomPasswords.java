package com.j.joker.rooms.application;

public interface RoomPasswords {
    String find(long activity);
    void insert(long activity, String hash);
}
