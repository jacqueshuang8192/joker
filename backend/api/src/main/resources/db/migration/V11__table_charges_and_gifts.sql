-- 每次开局、上庄或下庄的实际扣费。房间先保存事件编号，再向 data 提交。
CREATE TABLE joker_table_charge (
    event_id CHAR(36) CHARACTER SET ascii PRIMARY KEY,
    activity_id INT NOT NULL, club_id INT NOT NULL, level_id INT NOT NULL, round_index INT NOT NULL,
    kind ENUM('START','UP','DOWN') NOT NULL, uid INT NOT NULL, before_chips INT NOT NULL,
    amount INT NOT NULL, projected BOOLEAN NOT NULL DEFAULT FALSE,
    INDEX by_activity(activity_id,uid), INDEX by_projection(projected)
) ENGINE=InnoDB;

-- 旧客户端赠钻记录同时用作幂等回执。旧数据不参与缓存补记。
ALTER TABLE t_gift_room_card
    ADD request_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,
    ADD money_after BIGINT NULL, ADD recipient_after BIGINT NULL,
    ADD projected BOOLEAN NOT NULL DEFAULT TRUE,
    ADD UNIQUE KEY gift_request(user_id,request_id), ADD INDEX gift_projection(projected);
