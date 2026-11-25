-- 同一玩家的购买回执和余额在 data 的同一事务内提交。
CREATE TABLE joker_chip_purchase (
    game_id SMALLINT NOT NULL,
    uid INT NOT NULL,
    request_id VARCHAR(80) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    activity INT NOT NULL,
    wanted INT NOT NULL,
    bring_amount INT NOT NULL,
    accepted BOOLEAN NOT NULL,
    chips_after INT NOT NULL,
    money_after BIGINT NOT NULL,
    PRIMARY KEY(game_id,uid,request_id)
) ENGINE=InnoDB;

ALTER TABLE joker_friend_table
    ADD vote_until DATETIME(3) NULL,
    ADD INDEX ix_friend_timeout(phase,changed_at),
    ADD INDEX ix_friend_vote(vote_until);
ALTER TABLE joker_friend_seat ADD dissolve_yes BOOLEAN NOT NULL DEFAULT FALSE;

-- 叫牌阶段可能重新发牌；同一局的每次发牌都各自保留。
CREATE TABLE joker_friend_replay (
    code INT UNSIGNED NOT NULL,
    round_no INT NOT NULL,
    deal_no INT NOT NULL,
    journal MEDIUMTEXT NOT NULL,
    outcome VARCHAR(12) NOT NULL,
    PRIMARY KEY(code,round_no,deal_no),
    CONSTRAINT fk_friend_replay FOREIGN KEY(code) REFERENCES joker_friend_table(code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 老数据只回填仍有牌序和操作的已结算局，早期各局保留原积分。
INSERT INTO joker_friend_replay(code,round_no,deal_no,journal,outcome)
SELECT t.code,t.round_no,1,t.journal,'SETTLED' FROM joker_friend_table t
WHERE t.phase IN ('FINISHED','INTERMISSION') AND EXISTS (
  SELECT 1 FROM joker_friend_round_score s WHERE s.code=t.code AND s.round_no=t.round_no
);
