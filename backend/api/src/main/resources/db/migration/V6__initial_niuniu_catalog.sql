-- 仅初始化四张目录表均为空的部署。已有运营目录由运营方维护。
-- 档案来源为 interface_yuan 的 InitDbData.sql，只选用本编排提供的 302 牛牛。
START TRANSACTION;
SET @init_niuniu = NOT EXISTS (SELECT 1 FROM t_game)
    AND NOT EXISTS (SELECT 1 FROM t_game_type)
    AND NOT EXISTS (SELECT 1 FROM t_game_config)
    AND NOT EXISTS (SELECT 1 FROM t_group_game);

INSERT INTO t_game(game_Id,type,code,level,is_gold,name,status,game_type,is_show,max_player_count)
SELECT 302,2,'niuniu',302,2,'牛牛','2','15',1,10 WHERE @init_niuniu;

INSERT INTO t_game_type(id,name,game_id,game_type,is_show,roomType,game_type_parent_id,room_name)
SELECT 15,'牛牛',302,'15',1,2,1,'扑克' WHERE @init_niuniu;

INSERT INTO t_game_config(id,level,content)
SELECT 2,302,'{"gameName":"牛牛","level":302,"subGameType":1,"gameConfig":[{"configShowName":"局数","configGroup":[{"config":"round","isCheckBox":0,"configOption":[{"optionName":"10局","cardCount":4,"aa_cardCount":1,"optionValue":10,"isDefualt":1},{"optionName":"20局","cardCount":6,"aa_cardCount":1,"optionValue":20,"isDefualt":0},{"optionName":"30局","cardCount":8,"aa_cardCount":2,"optionValue":30,"isDefualt":0}]}]},{"configShowName":"最大人数","configGroup":[{"config":"maxSeatCount","isCheckBox":0,"configOption":[{"optionName":"6人","optionValue":6,"isDefualt":0},{"optionName":"8人","optionValue":8,"isDefualt":1},{"optionName":"10人","optionValue":10,"isDefualt":0}]}]},{"configShowName":"子游戏类型","configGroup":[{"config":"subGameType","isCheckBox":0,"isShow":1,"configOption":[{"optionName":"明牌抢庄","optionValue":1,"isDefualt":1}]}]},{"configShowName":"明牌张数","configGroup":[{"config":"showCardNums","isCheckBox":0,"configOption":[{"optionName":"明3张","optionValue":3,"isDefualt":0},{"optionName":"明4张","optionValue":4,"isDefualt":1}]}]},{"configShowName":"推注","configGroup":[{"config":"tuizhu","isCheckBox":0,"configOption":[{"optionName":"推注10倍","optionValue":10,"isDefualt":1},{"optionName":"推注5倍","optionValue":5,"isDefualt":1},{"optionName":"不可推注","optionValue":0,"isDefualt":0}]}]},{"configShowName":"癞子","configGroup":[{"config":"hasLeper","isCheckBox":0,"configOption":[{"optionName":"无癞子","optionValue":0,"isDefualt":1},{"optionName":"大小王","optionValue":1,"isDefualt":0},{"optionName":"随机癞子","optionValue":2,"isDefualt":0}]}]},{"configShowName":"托管","configGroup":[{"config":"tgTime","isCheckBox":0,"configOption":[{"optionName":"关闭","optionValue":0,"isDefualt":1},{"optionName":"30秒托管","optionValue":30,"isDefualt":0},{"optionName":"60秒托管","optionValue":60,"isDefualt":0}]}]},{"configShowName":"可选","configGroup":[{"config":"speType","isCheckBox":1,"configOption":[{"optionName":"顺子牛","optionValue":1,"isDefualt":1},{"optionName":"五花牛","optionValue":2,"isDefualt":1},{"optionName":"同花牛","optionValue":3,"isDefualt":1},{"optionName":"葫芦牛","optionValue":4,"isDefualt":1},{"optionName":"炸弹牛","optionValue":5,"isDefualt":1},{"optionName":"五小牛","optionValue":6,"isDefualt":1},{"optionName":"四十大","optionValue":7,"isDefualt":0},{"optionName":"同花顺牛","optionValue":8,"isDefualt":1}]}]},{"configShowName":"高级","configGroup":[{"config":"gaoji","isCheckBox":1,"configOption":[{"optionName":"强制准备","optionValue":4,"isDefualt":1},{"optionName":"开始后禁止加入","optionValue":5,"isDefualt":1},{"optionName":"无JQK","optionValue":6,"isDefualt":0},{"optionName":"点差","optionValue":7,"isDefualt":1}]}]}],"profitType":0,"baseChip":1,"readyPoint":2000,"joinGamePoint":5000,"profitLimit":5000,"profit":0,"rateOrConstant":1,"gameId":302}' WHERE @init_niuniu;

-- HTTP 接口与 alloc 共享容器网络空间，11603 是当前编排的内部房间分配端口。
INSERT INTO t_group_game(id,name,level,game_id,coins,ori_coins,status,ip,port,player_count)
SELECT 3,'牛牛',302,302,100,10,'1','127.0.0.1',11603,10 WHERE @init_niuniu;
COMMIT;
