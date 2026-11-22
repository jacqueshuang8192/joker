-- Tables referenced by entity-based CRUD. Existing business tables and data are retained.

CREATE TABLE IF NOT EXISTS `landlord_score_section` (
  `section_info` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_ad` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255),
  `url` TEXT,
  `link` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_chip_select` (
  `chip_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255),
  `level` INT,
  `remark` TEXT,
  `photo` TEXT,
  `category_id` BIGINT,
  `game_id` BIGINT,
  `version` BIGINT,
  `coin_count` INT,
  `player_count` INT,
  `Nullity` VARCHAR(32)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_exchange_history` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `goods_id` BIGINT,
  `nickname` VARCHAR(255),
  `goods_name` VARCHAR(255),
  `exchange_code` VARCHAR(255),
  `time` DATETIME,
  `status` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_feedback` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `content` TEXT,
  `date` DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_fortune_address` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `user_name` VARCHAR(255),
  `phone` VARCHAR(64),
  `address` TEXT,
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_gift_point` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `to_user_id` BIGINT,
  `point` INT,
  `user_point` INT,
  `to_user_point` INT,
  `create_time` DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_goods_category` (
  `category_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(255),
  `type` VARCHAR(64),
  `category_photo` TEXT,
  `parent_id` BIGINT,
  `name` VARCHAR(255),
  `remark` TEXT,
  `sort` INT,
  `status` VARCHAR(32)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_rechargeticheng_flow` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `agent_id` BIGINT,
  `ticheng` DOUBLE,
  `nick_name` VARCHAR(255),
  `date` DATETIME,
  `isbinding` INT,
  `rechargenumber` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_role_res` (
  `roleId` BIGINT NOT NULL,
  `resourceId` BIGINT NOT NULL,
  PRIMARY KEY (`roleId`, `resourceId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_sec_resource` (
  `resourceId` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `resourceName` VARCHAR(255),
  `resourceTitle` VARCHAR(255),
  `resourceUrl` TEXT,
  `resourceDesc` TEXT,
  `parentId` BIGINT,
  `path` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_sec_role` (
  `roleId` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `roleName` VARCHAR(255),
  `roleDesc` TEXT,
  `status` SMALLINT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_user_goods_buy_record` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `type` VARCHAR(64),
  `goods_id` BIGINT,
  `goods_photo` TEXT,
  `goods_name` VARCHAR(255),
  `total_price` INT,
  `amount` INT,
  `buy_date` DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_yaoqing_bangding` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `promoter_id` BIGINT,
  `promoter_name` VARCHAR(255),
  `user_name` VARCHAR(255),
  `date` DATETIME,
  `is_getRoomcard` INT,
  `yaoqing_roomcards` INT,
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- MySQL 5.7 lacks ADD COLUMN IF NOT EXISTS. Add only missing columns in one ALTER.
SET @chip_columns = (
  SELECT GROUP_CONCAT(CONCAT('ADD COLUMN `', expected.name, '` INT') ORDER BY expected.name)
  FROM (SELECT 'bring_chip' AS name UNION ALL SELECT 'present_chip') AS expected
  LEFT JOIN information_schema.columns AS actual
    ON actual.table_schema = DATABASE() AND actual.table_name = 't_activity_user'
    AND actual.column_name = expected.name
  WHERE actual.column_name IS NULL
);
SET @chip_ddl = IF(@chip_columns IS NULL, 'DO 0',
                   CONCAT('ALTER TABLE `t_activity_user` ', @chip_columns));
PREPARE chip_stmt FROM @chip_ddl;
EXECUTE chip_stmt;
DEALLOCATE PREPARE chip_stmt;
