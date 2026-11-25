-- 好友积分桌。牌序和操作只在服务端保存，邀请码用于加入尚未满员的桌。
CREATE TABLE joker_friend_table (
    code INT UNSIGNED NOT NULL,
    level INT NOT NULL,
    owner_uid INT NOT NULL,
    create_key VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    revision INT NOT NULL DEFAULT 0,
    phase VARCHAR(12) NOT NULL DEFAULT 'WAITING',
    journal MEDIUMTEXT NOT NULL,
    changed_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (code),
    UNIQUE KEY uq_friend_creation (owner_uid,create_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 同场次每人只能占一张活动桌。局分与结束版本同时提交，保留每位参与者的回执。
CREATE TABLE joker_friend_seat (
    code INT UNSIGNED NOT NULL,
    uid INT NOT NULL,
    level INT NOT NULL,
    position INT NOT NULL,
    active_uid INT NULL,
    points INT NULL,
    PRIMARY KEY (code,uid),
    UNIQUE KEY uq_friend_seat (code,position),
    UNIQUE KEY uq_friend_active (level,active_uid),
    KEY ix_friend_history (uid,level),
    CONSTRAINT fk_friend_table FOREIGN KEY (code) REFERENCES joker_friend_table(code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
