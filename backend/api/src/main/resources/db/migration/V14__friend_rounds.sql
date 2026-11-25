-- 现有好友桌默认为一局；连局房由房主在创建时选择局数。
ALTER TABLE joker_friend_table
    ADD round_limit INT NOT NULL DEFAULT 1,
    ADD round_no INT NOT NULL DEFAULT 1,
    ADD next_seat INT NOT NULL DEFAULT -1;

ALTER TABLE joker_friend_seat ADD ready_next TINYINT NOT NULL DEFAULT 0;

CREATE TABLE joker_friend_round_score (
    code INT UNSIGNED NOT NULL,
    round_no INT NOT NULL,
    uid INT NOT NULL,
    points INT NOT NULL,
    PRIMARY KEY (code,round_no,uid),
    CONSTRAINT fk_friend_score_seat FOREIGN KEY (code,uid) REFERENCES joker_friend_seat(code,uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO joker_friend_round_score(code,round_no,uid,points)
SELECT code,1,uid,points FROM joker_friend_seat WHERE points IS NOT NULL;
