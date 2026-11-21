-- Compatibility schema reconstructed from the deployed Java models and MyBatis SQL.
-- Only absent tables are created. Existing business data and definitions are retained.
-- No business configuration, balances, rates, or orders are seeded.

-- SMS, agency accounting, goods and payment orders (ImsMsgMapper, TUserMapper, GoldMapper, TGoodsMapper).
CREATE TABLE IF NOT EXISTS `ims_msg` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `phone` VARCHAR(255),
  `msgcode` INT,
  `type` INT,
  `addtime` VARCHAR(255),
  `content` TEXT,
  `status` INT,
  `agentid` INT,
  KEY `idx_phone_id` (`phone`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpagentgoldreport` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `date` DATE,
  `gold_countA` BIGINT DEFAULT 0,
  `gold_countB` BIGINT DEFAULT 0,
  `gold_countC` BIGINT DEFAULT 0,
  `player_count` BIGINT DEFAULT 0,
  `play_count` BIGINT DEFAULT 0,
  `card_countA` BIGINT DEFAULT 0,
  `card_countB` BIGINT DEFAULT 0,
  `card_countC` BIGINT DEFAULT 0,
  `order_count` BIGINT DEFAULT 0,
  `use_money` BIGINT DEFAULT 0,
  `channel_money` BIGINT DEFAULT 0,
  `robot_use` BIGINT DEFAULT 0,
  `surplus` BIGINT DEFAULT 0,
  `parent_money_card` BIGINT DEFAULT 0,
  `parent_money_gold` BIGINT DEFAULT 0,
  KEY `idx_agent_id_date` (`agent_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpcard` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `userid` BIGINT,
  `money` BIGINT,
  `agentid` BIGINT,
  `agentincome` BIGINT DEFAULT 0,
  `parentid` BIGINT,
  `parentincome` BIGINT DEFAULT 0,
  `grandparentid` BIGINT,
  `grandparentincome` BIGINT DEFAULT 0,
  `surplus` BIGINT DEFAULT 0,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agentid_create_time` (`agentid`, `create_time`),
  KEY `idx_parentid_create_time` (`parentid`, `create_time`),
  KEY `idx_grandparentid_create_time` (`grandparentid`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpcommissions` (
  `id` INT NOT NULL PRIMARY KEY,
  `commissions1` INT,
  `commissions2` INT,
  `commissions3` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpcomplaint` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `type` VARCHAR(255),
  `advice` TEXT,
  `addtime` DATETIME,
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpgold` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `userid` BIGINT,
  `isower` INT,
  `owerincome` BIGINT DEFAULT 0,
  `agentid` BIGINT,
  `agentincome` BIGINT DEFAULT 0,
  `parentid` BIGINT,
  `parentincome` BIGINT DEFAULT 0,
  `grandparentid` BIGINT,
  `grandparentincome` BIGINT DEFAULT 0,
  `surplusgold` BIGINT DEFAULT 0,
  `type` INT,
  `createtime` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_userid_isower` (`userid`, `isower`),
  KEY `idx_agentid_createtime` (`agentid`, `createtime`),
  KEY `idx_parentid_createtime` (`parentid`, `createtime`),
  KEY `idx_grandparentid_createtime` (`grandparentid`, `createtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpgoods` (
  `goodsid` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `goodsname` VARCHAR(255),
  `photo` TEXT,
  `cardnum` INT,
  `goodsprice` DECIMAL(18,2),
  `goodscreatetime` DATETIME,
  `goodsstatus` VARCHAR(16),
  `category_type` VARCHAR(16),
  `goodscreateperson` VARCHAR(255),
  KEY `idx_goodsstatus_category_type` (`goodsstatus`, `category_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tporders` (
  `orderid` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `order_no` VARCHAR(255),
  `goodsid` INT,
  `price` DECIMAL(20,4),
  `user_id` INT,
  `ordersstatus` INT,
  `count` INT,
  `type` INT,
  `create_at` BIGINT,
  `parentid` INT,
  `commissionlevel` INT,
  `year` INT,
  `month` INT,
  `myselfrebate` DECIMAL(20,4),
  `player_id` INT,
  `thirdparty_order_num` VARCHAR(255),
  `callback_time` BIGINT,
  `actually_paid` VARCHAR(255),
  `wx_order_num` VARCHAR(255),
  `good_type` INT,
  `commission` INT,
  `commission_money` INT,
  KEY `idx_order_no` (`order_no`),
  KEY `idx_ordersstatus_callback_time` (`ordersstatus`, `callback_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpplayergoldreport` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player` BIGINT,
  `date` DATE,
  `gold_count` BIGINT DEFAULT 0,
  KEY `idx_player_date` (`player`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_account_charge` (
  `charge_id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `account_id` BIGINT,
  `user_id` BIGINT,
  `coin_amount` INT,
  `rmb_amount` INT,
  `discounted_rmb_amount` INT,
  `charge_date` DATETIME,
  `create_date` DATETIME,
  `channel` VARCHAR(255),
  `pay_type` VARCHAR(255),
  `status` VARCHAR(16),
  `charge_order` VARCHAR(255),
  `channel_order_id` VARCHAR(255),
  `before_charge_coin` VARCHAR(255),
  `after_charge_coin` VARCHAR(255),
  `goods_id` BIGINT,
  `agent_id` BIGINT,
  `number` INT,
  `remark` TEXT,
  KEY `idx_user_id_status` (`user_id`, `status`),
  KEY `idx_charge_order` (`charge_order`),
  KEY `idx_channel_order_id` (`channel_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_biqi_cardid` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `card_id` VARCHAR(255),
  `card_pw` VARCHAR(255),
  `status` INT DEFAULT 0,
  `player_id` BIGINT,
  `use_time` DATETIME,
  `money_type` INT,
  `price` INT,
  KEY `idx_status_money_type` (`status`, `money_type`),
  KEY `idx_player_id_use_time` (`player_id`, `use_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_charge_pool` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `amount` DECIMAL(20,4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_goods` (
  `goods_id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `category_id` BIGINT,
  `category_code` VARCHAR(255),
  `category_photo` TEXT,
  `category_name` VARCHAR(255),
  `category_type` VARCHAR(16),
  `category_sort` INT,
  `name` VARCHAR(255),
  `remark` TEXT,
  `photo` TEXT,
  `amount` INT,
  `price` INT,
  `vip` INT,
  `create_date` DATETIME,
  `status` VARCHAR(16),
  KEY `idx_status_category_type` (`status`, `category_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_robot_send_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `callback_money` DECIMAL(20,4),
  `before_send_money` DECIMAL(20,4),
  `callback_time` DATETIME,
  KEY `idx_callback_time` (`callback_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player activities, service text and operational settings.
CREATE TABLE IF NOT EXISTS `t_advert` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `photo_url` TEXT,
  `phone_url` TEXT,
  `describe` TEXT,
  `is_show` INT,
  `create_time` DATETIME,
  `phone_name` VARCHAR(255),
  `visit_url` TEXT,
  KEY `idx_is_show` (`is_show`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_agent_id` (
  `agent_id` BIGINT NOT NULL PRIMARY KEY,
  `used_flag` VARCHAR(16) DEFAULT '0',
  KEY `idx_used_flag` (`used_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_fortune_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `fortune_id` BIGINT,
  `fortune_name` VARCHAR(255),
  `type` VARCHAR(16),
  `count` INT,
  `address` TEXT,
  `phone` VARCHAR(255),
  `status` INT,
  `date` DATETIME,
  KEY `idx_user_id_date` (`user_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_record` (
  `id` VARCHAR(191) NOT NULL PRIMARY KEY,
  `sequences` BIGINT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_rongcloud_server` (
  `rongcloud_id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `province` VARCHAR(255),
  `room_id` VARCHAR(255),
  `room_name` VARCHAR(255),
  `createTime` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `token` TEXT,
  KEY `idx_province` (`province`),
  KEY `idx_room_id` (`room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_sec_operator` (
  `operator_id` BIGINT NOT NULL PRIMARY KEY,
  `compere_num` INT DEFAULT 0,
  `customer_num` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_service_information` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `content` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_task` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `task_id` INT,
  `task_name` VARCHAR(255),
  `squence` INT DEFAULT 0,
  `status` INT,
  `parent_id` INT,
  `task_term` INT,
  `task_describe` TEXT,
  `gift` TEXT,
  KEY `idx_task_id_squence` (`task_id`, `squence`),
  KEY `idx_parent_id_status` (`parent_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Game availability, results and rankings.
CREATE TABLE IF NOT EXISTS `t_free_game_singleresult` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `game_id` BIGINT,
  `user_id` BIGINT,
  `date` DATE,
  `score` BIGINT DEFAULT 0,
  `win` BIGINT DEFAULT 0,
  `lose` BIGINT DEFAULT 0,
  `draw` BIGINT DEFAULT 0,
  `total` BIGINT DEFAULT 0,
  `level` INT,
  KEY `idx_date_user_id` (`date`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_free_game_total` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `score` BIGINT DEFAULT 0,
  `total` BIGINT DEFAULT 0,
  `win` BIGINT DEFAULT 0,
  `draw` BIGINT DEFAULT 0,
  `lose` BIGINT DEFAULT 0,
  `level` INT,
  UNIQUE KEY `uq_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_free_game_totalranking` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `game_id` BIGINT NOT NULL,
  `score` BIGINT DEFAULT 0,
  `total` BIGINT DEFAULT 0,
  `win` BIGINT DEFAULT 0,
  `draw` BIGINT DEFAULT 0,
  `lose` BIGINT DEFAULT 0,
  `level` INT,
  UNIQUE KEY `uq_game_id_user_id` (`game_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_game_province` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `province_id` BIGINT,
  `province_name` VARCHAR(255),
  `agent_number` BIGINT,
  `is_show` BIGINT,
  `is_hot` BIGINT,
  `is_new` BIGINT,
  `default_agent` BIGINT,
  KEY `idx_province_id` (`province_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_game_type_game` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `game_type_id` BIGINT,
  `game_id` BIGINT,
  `province_id` BIGINT,
  `game_level` BIGINT,
  `game_name` VARCHAR(255),
  `agent_id` BIGINT,
  KEY `idx_agent_id_game_type_id` (`agent_id`, `game_type_id`),
  KEY `idx_game_level` (`game_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_game_type_gold` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255),
  `game_id` BIGINT,
  `game_type` VARCHAR(255),
  `is_show` BIGINT,
  KEY `idx_game_id` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_province_agent` (
  `province_id` BIGINT NOT NULL,
  `agent_id` BIGINT NOT NULL,
  PRIMARY KEY (`province_id`, `agent_id`),
  KEY `idx_agent_id_province_id` (`agent_id`, `province_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Club history, unions and membership.
CREATE TABLE IF NOT EXISTS `t_group_choushui_history` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `uid` BIGINT,
  `group_id` BIGINT,
  `choushui` DECIMAL(20,4),
  KEY `idx_group_id_uid` (`group_id`, `uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_group_union` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `union_name` VARCHAR(255),
  `config` TEXT,
  `cost_pattern` INT,
  `cost_limit` DECIMAL(20,4),
  `commission` DECIMAL(20,4),
  `cost_user_type` INT,
  `create_time` DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_group_union_member` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `union_id` INT,
  `player_id` INT,
  `inviter_id` INT,
  `player_type` INT,
  `from_group_id` INT,
  `bonus` DECIMAL(20,4),
  `create_time` DATETIME,
  KEY `idx_union_id_player_id` (`union_id`, `player_id`),
  KEY `idx_union_id_from_group_id_player_type` (`union_id`, `from_group_id`, `player_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Physical shards. Each definition is independent so an existing custom shard is never cloned.
CREATE TABLE IF NOT EXISTS `ims_tpmoney0` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney1` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney2` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney3` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney4` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney5` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney6` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney7` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney8` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ims_tpmoney9` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `agent_id` BIGINT,
  `uid` BIGINT,
  `type` INT,
  `money` DECIMAL(20,4),
  `parent_money` DECIMAL(20,4),
  `cj` INT,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_agent_id_type_create_time` (`agent_id`, `type`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task0` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task1` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task2` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task3` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task4` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task5` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task6` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task7` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task8` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_player_task9` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `player_id` BIGINT,
  `task_id` INT,
  `squence` INT DEFAULT 0,
  `term_now` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `is_enough` INT DEFAULT 0,
  KEY `idx_player_id_task_id_squence` (`player_id`, `task_id`, `squence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history0` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history1` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history2` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history3` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history4` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history5` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history6` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history7` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history8` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_waiweiorder_history9` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT,
  `order_id` VARCHAR(255),
  `create_time` DATETIME,
  `money` INT,
  `surplus_money` INT,
  `status` INT,
  `result` INT,
  KEY `idx_user_id_id` (`user_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
