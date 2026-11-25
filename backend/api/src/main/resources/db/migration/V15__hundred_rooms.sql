-- 每个场次各有一张经典桌和一张拼庄桌。限额、上庄门槛均以钱包最小单位计。
CREATE TABLE joker_hundred_room (
    tid INT PRIMARY KEY, level_id INT NOT NULL, banker_seats INT NOT NULL,
    min_capital INT NOT NULL DEFAULT 10000, max_rounds INT NOT NULL DEFAULT 5,
    area_limit INT NOT NULL DEFAULT 1000000, bet_seconds INT NOT NULL DEFAULT 30,
    round_id CHAR(36) CHARACTER SET ascii NULL
) ENGINE=InnoDB;
INSERT INTO joker_hundred_room(tid,level_id,banker_seats)
VALUES (6619137,101,1),(6619138,101,6),(6684673,102,1),(6684674,102,6);

-- 自增序号固定申请顺序，跨桌申请由同一个钱包占用检查裁决。
CREATE TABLE joker_hundred_banker (
    seq BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, tid INT NOT NULL, uid INT NOT NULL,
    served INT NOT NULL DEFAULT 0, retiring BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE KEY room_player(tid,uid), KEY rotation(tid,seq)
) ENGINE=InnoDB;
-- 牌序和封盘时刻在开放接单前写入。封盘回执、钱包和缓存补记在同一事务提交。
CREATE TABLE joker_hundred_round (
    id CHAR(36) CHARACTER SET ascii PRIMARY KEY, tid INT NOT NULL, deadline BIGINT NOT NULL,
    area_limit INT NOT NULL, bankers JSON NOT NULL, cards JSON NOT NULL, receipt JSON NULL,
    closed_at BIGINT NULL, KEY history(tid,closed_at)
) ENGINE=InnoDB;
CREATE TABLE joker_hundred_order (
    round_id CHAR(36) CHARACTER SET ascii NOT NULL, uid INT NOT NULL,
    request_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    area INT NOT NULL, chips INT NOT NULL,
    PRIMARY KEY(round_id,uid,request_id)
) ENGINE=InnoDB;
