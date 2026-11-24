-- Java 牛牛的整局入账回执。与玩家分表筹码在同一 MySQL 事务内提交。
-- projected=0 表示 Java data 仍须把已提交的余额同步到 Redis。
CREATE TABLE IF NOT EXISTS joker_douniu_settlement (
    round_id CHAR(36) CHARACTER SET ascii NOT NULL PRIMARY KEY,
    game_id SMALLINT NOT NULL,
    balances VARCHAR(512) CHARACTER SET ascii NOT NULL,
    projected TINYINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY pending_projection (game_id, projected)
) ENGINE=InnoDB;
