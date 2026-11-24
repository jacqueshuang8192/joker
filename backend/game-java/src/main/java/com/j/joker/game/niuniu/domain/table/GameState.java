package com.j.joker.game.niuniu.domain.table;

/**
 * 桌子状态。对应二进制 CGameTable::GetTableStatus / change table status 日志
 * （日志中可见 ResetTable、StopGame；其余阶段由 ProcessOnTimerOut/checkRound 驱动）。
 */
public enum GameState {
    RESET_TABLE(0, "ResetTable"),
    WAIT_READY(1, "WaitReady"),
    WAIT_START(2, "WaitStart"),
    SEND_CARD(3, "SendCard"),
    GRAB_DEALER(4, "GrabDealer"),
    CALL_TIMES(5, "CallTimes"),
    OPEN_CARD(6, "OpenCard"),
    SETTLE(7, "Settle"),
    STOP_GAME(8, "StopGame");

    private final int code;
    private final String logName;

    GameState(int code, String logName) {
        this.code = code;
        this.logName = logName;
    }

    public int code() {
        return code;
    }

    public String logName() {
        return logName;
    }

    public static GameState of(int code) {
        for (GameState s : values()) {
            if (s.code == code) {
                return s;
            }
        }
        return RESET_TABLE;
    }
}
