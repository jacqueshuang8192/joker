-- 外围按局记借贷。dealer_uid=0 为系统账户，其余额由所有系统坐庄流水之和得出，允许为负。
CREATE TABLE joker_douniu_side_ledger (
    round_id CHAR(36) CHARACTER SET ascii PRIMARY KEY,
    activity_id INT NOT NULL,
    dealer_uid INT NOT NULL,
    dealer_delta BIGINT NOT NULL,
    orders JSON NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY dealer_round (dealer_uid, created_at)
) ENGINE=InnoDB;

-- 局号 0 表示普通房整桌结账，斗公牛使用实际局号。子表保存每人的实际扣款和缓存投影。
CREATE TABLE joker_douniu_club_bill (
    activity_id INT NOT NULL, round_index INT NOT NULL, club_id INT NOT NULL,
    close_key CHAR(64) CHARACTER SET ascii NULL,
    fee_total BIGINT NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(activity_id,round_index)
) ENGINE=InnoDB;
CREATE TABLE joker_douniu_club_debit (
    activity_id INT NOT NULL, round_index INT NOT NULL, uid INT NOT NULL,
    base_fee INT NOT NULL, additional_fee INT NOT NULL, after_chips INT NOT NULL,
    projected TINYINT NOT NULL, PRIMARY KEY(activity_id,round_index,uid), KEY projection(projected)
) ENGINE=InnoDB;

-- 玩家参与外围时，余额只能由同一局的结算使用。系统庄不占用玩家余额。
CREATE TABLE joker_douniu_side_hold (
    uid INT PRIMARY KEY,
    round_id CHAR(36) CHARACTER SET ascii NOT NULL,
    before_chips INT NOT NULL,
    KEY held_round (round_id)
) ENGINE=InnoDB;

-- 外围站起玩家也随本局入账，十席以外的余额明细可能超过旧回执的 512 字符。
ALTER TABLE joker_douniu_settlement MODIFY balances TEXT CHARACTER SET ascii NOT NULL;
