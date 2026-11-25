-- 旧筹码协议没有流水号。先将分表余额和待同步账号一起提交，重启后再从分表恢复缓存。
CREATE TABLE IF NOT EXISTS joker_player_cache_sync (
    game_id SMALLINT NOT NULL,
    uid INT NOT NULL,
    PRIMARY KEY (game_id, uid)
) ENGINE=InnoDB;
