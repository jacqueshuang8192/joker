package com.j.joker.rooms.domain;

/** 六位数字口令，保留前导零。 */
public final class RoomPin {
    private final String digits;
    private RoomPin(String digits) { this.digits = digits; }
    public static RoomPin of(String digits) {
        if (digits == null || !digits.matches("[0-9]{6}")) throw new IllegalArgumentException("房间密码须为六位数字");
        return new RoomPin(digits);
    }
    public String digits() { return digits; }
}
