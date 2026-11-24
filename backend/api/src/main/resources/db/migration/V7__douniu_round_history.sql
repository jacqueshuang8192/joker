-- 十人桌的头像、昵称及手牌可能超过原来的 2000 字符。已有战绩保留原内容。
-- 同一局号只写一次；原生房间沿用默认 NULL，可继续使用原来的写入方式。
ALTER TABLE t_free_game_round
    MODIFY COLUMN content MEDIUMTEXT NULL,
    ADD COLUMN douniu_round_id CHAR(36) CHARACTER SET ascii NULL,
    ADD UNIQUE KEY uq_douniu_round_id (douniu_round_id);
