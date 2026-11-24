-- 密码房单独保存带盐校验值。大厅可以公开房规，六位房间密码仅用于校验。
CREATE TABLE joker_douniu_room_password (
    activity_id BIGINT NOT NULL PRIMARY KEY,
    password_hash VARCHAR(160) CHARACTER SET ascii NOT NULL
) ENGINE=InnoDB;
