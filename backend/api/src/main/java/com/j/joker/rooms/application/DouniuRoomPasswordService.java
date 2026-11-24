package com.j.joker.rooms.application;

import com.j.joker.constants.Constants;
import com.j.joker.rooms.domain.RoomPin;
import com.j.joker.utils.InfServerException;
import org.springframework.security.crypto.password.PasswordEncoder;

public class DouniuRoomPasswordService {
    private final RoomPasswords passwords;
    private final RoomUnlocks unlocks;
    private final boolean javaRooms;
    private final PasswordEncoder encoder;

    public DouniuRoomPasswordService(RoomPasswords passwords, RoomUnlocks unlocks, PasswordEncoder encoder, boolean javaRooms) {
        this.passwords = passwords;
        this.unlocks = unlocks;
        this.encoder = encoder;
        this.javaRooms = javaRooms;
    }

    public String forNewRoom(Integer level, String password, Long previousActivity) throws InfServerException {
        if (!Integer.valueOf(302).equals(level)) return null;
        if (previousActivity != null) {
            String prior = passwords.find(previousActivity);
            if (prior != null) {
                if (!javaRooms) throw failure("请切换到 Java 牛牛后再续开密码房");
                return prior;
            }
        }
        if (!javaRooms || password == null || password.isEmpty()) return null;
        return encoder.encode(pin(password).digits());
    }

    public void save(long activity, String hash) {
        passwords.insert(activity, hash);
    }

    public void unlock(long uid, String token, long activity, String password) throws InfServerException {
        RoomPin pin = pin(password);
        long attempts = unlocks.attempt(uid, token, activity);
        if (attempts == 0) throw failure("请先从大厅进入这张桌子");
        if (attempts > 5) throw failure("尝试次数过多，请稍后重试");
        String hash = passwords.find(activity);
        if (hash == null || !encoder.matches(pin.digits(), hash)) throw failure("房间密码错误");
        if (!unlocks.grant(uid, token, activity)) throw failure("请重新进入这张桌子");
    }

    private static RoomPin pin(String password) throws InfServerException {
        try { return RoomPin.of(password); }
        catch (IllegalArgumentException invalid) { throw failure(invalid.getMessage()); }
    }

    private static InfServerException failure(String message) {
        return new InfServerException(Constants.RETURN_CODE_FAIL, message);
    }
}
