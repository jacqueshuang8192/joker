--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--
local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require("hall.HALL_PROTOCOL")
local P = class("HALL_SERVER_PROTOCOL",HALL_PROTOCOL)

local HALL_SERVER_PROTOCOL = P
--P.CONFIG = {}
--P.CONFIG.CLIENT = {}
--P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

P.CLI_HEART = 0x110 --发送心跳
CLIENT[P.CLI_HEART] ={
    ver = 1,
    fmt = {
        {name = "tid",type = T.INT}, 
    }
}
----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------
P.CLI_LOGIN_ROOM                 = 0x1001    --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "seat_id", type = T.INT}, --需要验证的key
        {name = "sex", type = T.BYTE}, --需要验证的key
        {name = "nickName", type = T.STRING}, --用户个人信息
        {name = "portrait", type = T.STRING}, --用户个人信息
        {name = "latitude", type = T.STRING}, --用户个人信息
        {name = "longitude", type = T.STRING}, --用户个人信息 
        {name = "otherInfo", type = T.STRING}, --用户个人信息 
        {name = "activityId", type = T.INT}, --用户个人信息
		{name = "ip", type = T.STRING}, --用户个人信息
		{name = "addres", type = T.STRING},
    }
}


P.CLI_READY_GAME                     = 0x2001    --用户发送准备
CLIENT[P.CLI_READY_GAME] = {
    ver = 1,
    {name = "readyState", type = T.INT},  -- 0是取消准备，1是准备
}

--用户操作托管
P.CLIENT_COMMAND_AUTO                   = 0x2005
CLIENT[P.CLIENT_COMMAND_AUTO] = {
    ver = 1,
    fmt = {
        {name = "AIState", type = T.INT} --用户托管状态：0表示取消托管，1表示托管
    }
}
--广播桌子用户托管状态
P.SERVER_COMMAND_AUTO                 = 0x2005
SERVER[P.SERVER_COMMAND_AUTO] = {
    ver = 1,
    fmt = {
        {name = "seatID", type = T.INT},
        {name = "AIState", type = T.BYTE}
    }
}


P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x801    --用户发送消息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}

P.CLI_OUT_CARD                    = 0x1201    --玩家出牌
CLIENT[P.CLI_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "Cardcount", type = T.BYTE},--玩家出牌的的数量
        {name = "ChangeCardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {name = "card",type = T.BYTE},   --转换后的牌
            }
        },
		{name = "SrcCardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
				{name = "card",type = T.BYTE},   --原始的牌
            }
        }
    }
}

P.CLI_PASS                = 0x1202    --玩家pass
CLIENT[P.CLI_PASS] = nil

P.SVR_QUICK_SUC               = 0x1008   --用户自己退出成功
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1,
}


P.CLI_QUIT_ROOM                     = 0x1033    --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

-------------------  解散房间相关  ------------------------------
--请求解散房间 
P.C2G_CMD_DISSOLVE_ROOM                   = 0x808
CLIENT[P.C2G_CMD_DISSOLVE_ROOM] = {
    ver = 1
}

--回复请求解散房间
P.C2G_CMD_REPLY_DISSOLVE_ROOM                   = 0x809
CLIENT[P.C2G_CMD_REPLY_DISSOLVE_ROOM] = {
    ver = 1,
    fmt = {
        {name = "agree", type = T.INT} --0为拒绝解散，1为解散
    }
}

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}

P.SERVER_CMD_MESSAGE                = 0x801    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.STRING}, --消息
    }
}

P.BROADCAST_ERROR_TIPS  =          0x5001
SERVER[P.BROADCAST_ERROR_TIPS] = {
    ver = 1,
    fmt ={
        {name = "errorCode", type = T.SHORT}, 
    }
}

P.SVR_READY_GAME                 = 0x2001    --用户准备返回
SERVER[P.SVR_READY_GAME] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}
    }
}

P.SVR_DEAL                       = 0x4001    --发牌
SERVER[P.SVR_DEAL] = {
    ver = 1,
    fmt = {
		{name = "seatID", type = T.INT}, 				--自己椅子ID
		{name = "bankUserSeatID", type = T.INT}, 		--庄家椅子ID
		{name = "currentSeatID", type = T.INT}, 		--当前操作的椅子ID
        {name = "Cardcount", type = T.SHORT}, 			-- 总共多少牌
        {name = "HandCardDatas", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   						--扑克牌数值
            }
        }
    }
}

P.SVR_LOGIN_ROOM_BROADCAST                 = 0x100D    --服务器广播用户登陆房间
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        -- {name = "uid", type = T.INT},--玩家uid
        -- {name = "seat_id", type = T.INT},--玩家座位号
        -- {name = "sex",type = T.BYTE},   --座位id
        -- {name = "nickName",type = T.STRING},   --用户json字符串
        -- {name = "portrait",type = T.STRING},   --用户金币
        -- {name = "latitude",type = T.STRING},   --用户赢数
        -- {name = "longitude",type = T.STRING},   --用户输数
        -- {name = "otherInfo", type = T.STRING}, --用户个人信息 
        -- {name = "ip",type = T.STRING},   --用户状态
        -- {name = "user_gold", type = T.INT},--玩家筹码数
        -- {name = "user_gold_64", type = T.INT},--玩家筹码数
		{name = "uid", type = T.INT},             --玩家uid
        {name = "seat_id", type = T.INT},         --玩家座位号
        {name = "if_ready", type = T.BYTE},       --玩家座位号
        {name = "sex",type = T.BYTE},             --座位id
        {name = "nickName",type = T.STRING},      --用户json字符串
        {name = "portrait",type = T.STRING},      --用户金币
        {name = "latitude",type = T.STRING},      --用户赢数
        {name = "longitude",type = T.STRING},     --用户输数
        {name = "otherInfo", type = T.STRING},    --用户个人信息 
        {name = "ip",type = T.STRING},            --用户状态
		{name = "addres",type = T.STRING},
        {name = "user_gold", type = T.INT},       --玩家筹码数
        {name = "user_gold_64", type = T.INT64},  --玩家筹码数
    }
}

P.SVR_LOGOUT_ROOM_OK                = 0x1008    --服务器返回玩家退出游戏成功
SERVER[P.SVR_LOGOUT_ROOM_OK] = {
    ver = 1
}


P.BROADCAST_USER_SIT_DOWN  =          0x1031   --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt ={
        -- {name = "uid", type = T.INT}, 
        -- {name = "old_seat_id", type = T.INT}, 
        -- {name = "seat_id", type = T.INT}, 
        -- {name = "sex",type = T.BYTE},   --座位id       
        -- {name = "nickName",type = T.STRING},   --用户json字符串
        -- {name = "portrait",type = T.STRING},   --用户金币
        -- {name = "user_gold",type = T.INT},   --用户金币
		{name = "uid", type = T.INT},          --玩家ID
        {name = "seat_id", type = T.INT},      --座位id  
        {name = "sex",type = T.BYTE},          --性别
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "user_gold",type = T.INT},     --用户金币
        {name = "latitude",type = T.STRING},    -- 
        {name = "longitude",type = T.STRING},   --
		{name = "ip",type = T.STRING},
		{name = "addres",type = T.STRING},
    }
}

P.BROADCAST_USER_STAND_UP  =          0x1032   --站起
SERVER[P.BROADCAST_USER_STAND_UP] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT}, 
    }
}


P.SVR_BROADCAST_USER_LEAVEROOM                = 0x1033    --服务器广播玩家退出
SERVER[P.SVR_BROADCAST_USER_LEAVEROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
    }
}

P.SVR_LOGOUT_ROOM                = 0x100E    --服务器广播玩家退出
SERVER[P.SVR_LOGOUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "Uid", type = T.INT},
    }
}

P.SVR_LOGIN_ROOM_OK              = 0x1007    --登录房间OK
SERVER[P.SVR_LOGIN_ROOM_OK] = {
    ver = 1,
    -- fmt = {
        -- {name = "activity_id", type = T.INT},  --游戏模式是几人的
        -- {name = "m_TmpScore", type = T.INT},  --游戏模式是几人的
        -- {name = "inviteCode", type = T.STRING},  --游戏模式是几人的
        -- {name = "Basechip", type = T.INT},--房间底注
        -- {name = "seat_id", type = T.SHORT},--座位ID
        -- {name = "gold", type = T.INT},--玩家金币
        -- {name = "user_mount", type = T.SHORT},--桌子上其他玩家的个数
        -- {name = "playerlist", type = T.ARRAY,fixedLength = 2, fixedLengthParser = "user_mount",
            -- fmt = {
                -- {name = "uid", type = T.INT},--其他玩家的uid
                -- {name = "seat_id", type = T.SHORT}, -- 其他玩家的seatid
                -- {name = "if_ready", type = T.SHORT}, -- 其他玩家是否准备
                -- {name = "if_online", type = T.SHORT}, -- 其他玩家是否准备
                -- -- {name = "user_info", type = T.STRING}, -- 其他玩家的信息
                -- {name="sex",type = T.BYTE},   --座位id
                -- {name="nickName",type = T.STRING},   --用户json字符串
                -- {name="portrait",type = T.STRING},   --用户金币
                -- {name="latitude",type = T.STRING},   --用户赢数
                -- {name="longitude",type = T.STRING},   --用户输数
                -- {name="otherInfo", type = T.STRING}, --用户个人信息 
                -- {name="ip",type = T.STRING},   --用户状态                
                -- {name ="user_gold", type = T.INT},--其他玩家的金币
            -- }
        -- },
        -- {name = "OwnerID", type = T.INT}--房主ID
    -- }
	 fmt = {
        {name = "MaxPlayerCount", type = T.SHORT},  	--游戏模式是几人的
        {name = "BaseChip", type = T.INT},  			--房间底注
        {name = "SeatID", type = T.SHORT},				--座位ID
		{name = "InviteCode", type = T.STRING},  		--邀请码
        --{name = "gold", type = T.INT},--玩家金币
        {name = "UserCount", type = T.SHORT},			--桌子上其他玩家的个数
        {name = "playerlist", type = T.ARRAY,fixedLength = "UserCount", fixedLengthParser = "UserCount",
            fmt = {
                {name = "uid", type = T.INT},			--其他玩家的uid
				{name ="user_gold", type = T.INT},		--其他玩家的金币
                {name = "seat_id", type = T.SHORT}, 	-- 其他玩家的seatid
                {name = "if_ready", type = T.SHORT}, 	-- 其他玩家是否准备
                {name = "if_online", type = T.SHORT}, 	-- 其他玩家是否准备
                -- {name = "user_info", type = T.STRING}, -- 其他玩家的信息
                {name="sex",type = T.BYTE},   --座位id
                {name="nickName",type = T.STRING},   --用户json字符串
                {name="portrait",type = T.STRING},   --用户金币
                {name="latitude",type = T.STRING},   --用户赢数
                {name="longitude",type = T.STRING},   --用户输数
                {name="otherInfo", type = T.STRING}, --用户个人信息 
                {name="ip",type = T.STRING},   --用户状态        
				{name = "addres",type = T.STRING},
            }
        },
        {name = "OwnerID", type = T.INT},				--房主ID
		{name = "Config", type = T.STRING},  			--配置
    }
}


P.SVR_RELOAD_ROOM                = 0x1009    --玩家重连逻辑
SERVER[P.SVR_RELOAD_ROOM] = {
    ver = 1,
	 fmt = {
        --{name = "max_playerCount", type = T.SHORT},  --游戏人数
        --{name = "bAI", type = T.INT},  --托管
        {name = "baseChip", type = T.INT},  --底注
        {name = "inviteCode", type = T.STRING},  --邀请码
        {name = "Playercount", type = T.SHORT},--玩家的个数
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "Playercount",fixedLength = 0,
            fmt = { 
                {name = "uid",type = T.INT},   --桌子其他玩家uid
                {name = "user_gold",type = T.INT},   --桌子其他玩家chip
				{name = "seatID",type = T.SHORT}, 
				{name = "handCardCount",type = T.BYTE},
                {name = "if_ready",type = T.SHORT},   --是否准备
                --{name = "if_online",type = T.SHORT},   --是否准备
				{name = "sex",type = T.BYTE}, 
                {name = "nickName",type = T.STRING}, 
                {name = "portrait",type = T.STRING},   
                {name = "latitude",type = T.STRING},   
                {name = "longitude",type = T.STRING},  
				{name = "otherInfo",type = T.STRING},  
				{name = "ip",type = T.STRING},
				{name = "addres",type = T.STRING},
				{name = "AIState", type = T.BYTE},   --玩家托管状态
				{name = "bombchip", type = T.INT},--炸弹得分
				{name = "k510chip", type = T.INT},--510K得分
				{name = "totalchip", type = T.INT},--总分
				{name = "rank", type = T.INT},--名次（1表示头游，2表示二游，-1表示还没有名次）
            }
        },
		
		{name = "tablechip", type = T.INT},--桌面分
        {name = "ownerId", type = T.INT},
        {name = "gameStatus", type = T.SHORT},
		
        {name = "bankerUser", type = T.INT},
        --{name = "bankerAss", type = T.INT},
        --{name = "assCard", type = T.BYTE},
        {name = "groupTimes", type = T.INT},
		{name = "totalRound", type = T.INT},
		{name = "configStr", type = T.STRING},
		
		
		{name = "handcardcount", type = T.BYTE},--牌的数量
        {
            name = "handcarddatas", type = T.ARRAY,fixedLengthParser = "handcardcount",fixedLength = 0,
                fmt = {
                    {type = T.BYTE}   --扑克牌数值
                }
        },
		
		{name = "turnCount", type = T.BYTE},--牌的数量
        {
            name = "turnChangeCards", type = T.ARRAY,fixedLengthParser = "turnCount",fixedLength = 0,
                fmt = {
                    {type = T.BYTE},  --转换后的牌
                }
        },
		{
            name = "turnSrcCards", type = T.ARRAY,fixedLengthParser = "turnCount",fixedLength = 0,
                fmt = {
					{type = T.BYTE}   --原始的牌
                }
        },
		
		{name = "currentUser", type = T.INT},
		{name = "turnwiner", type = T.INT},
		{name = "turnCardType", type = T.BYTE},
    }
}


-- P.SVR_GAME_START                 = 0x6002    --服务器广播游戏开始
-- SERVER[P.SVR_GAME_START] = {
    -- ver = 1,
    -- fmt = {
        -- {name = "bankerUid", type = T.INT},
        -- {name = "playercount", type = T.BYTE},
        -- {name = "playerHandcards", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 4,
            -- fmt = { 
                -- {name = "uid",type = T.INT},   --桌子其他玩家uid
                -- {name = "cardcount",type = T.SHORT},   --玩家手牌数量
                -- {name = "cards", type = T.ARRAY,fixedLengthParser = "cardcount",fixedLength = 0,
                    -- fmt = {
                        -- {type = T.BYTE},   --扑克牌数值
                    -- }
                -- },
            -- }
        -- },

    -- }
-- }

-- P.SVR_CUR_OUT_PLAYER                   = 0x6004    --服务器广播开始打牌
-- SERVER[P.SVR_CUR_OUT_PLAYER] = {
    -- ver = 1,
    -- fmt = {
        -- {name = "OutCardUserId", type = T.INT},--出牌玩家的uid
    -- }
-- }

P.SVR_PLAY_CARD                   = 0x1201    --服务器广播玩家出牌
SERVER[P.SVR_PLAY_CARD] = {
    ver = 1,
	fmt = {
        {name = "outCardSeatID", type = T.INT},--出牌玩家椅子ID
        {name = "cardcount", type = T.BYTE},--牌的数量
        {
            name = "changeCards", type = T.ARRAY,fixedLengthParser = "cardcount",fixedLength = 0,
                fmt = {
                    {type = T.BYTE},  --转换后的牌
                }
        },
		{
            name = "srcCards", type = T.ARRAY,fixedLengthParser = "cardcount",fixedLength = 0,
                fmt = {
					{type = T.BYTE},  --原始牌
                }
        },
		{name = "cardType",type = T.BYTE},   --出牌类型
        {name = "nextUser",type = T.INT},   --下一个出牌玩家椅子ID  
		{name = "tablechip", type = T.INT},--桌面分
    }
}

P.SVR_PASS                   = 0x1202  --服务器广播玩家pass
SERVER[P.SVR_PASS] =  {
    ver = 1,
    fmt = {
        {name = "nPassSeatId", type = T.INT},--Pass的玩家椅子ID
		{name = "nextUser",type = T.INT},   --下一个出牌玩家椅子ID
		{name = "cardType",type = T.BYTE},   --此轮出牌类型
    }
}

P.SERVER_BROADCAST_BEGIN_OUT                  = 0x1204
SERVER[P.SERVER_BROADCAST_BEGIN_OUT] = {
    ver = 1,
    fmt = {
        {name = "currentUser", type = T.INT},--出牌玩家椅子ID
    }
}

--广播用户总分
P.SERVER_BROADCAST_TOTAL_CHIP                  = 0x1205
SERVER[P.SERVER_BROADCAST_TOTAL_CHIP] = {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--玩家的数量
        {
            name = "chiplist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
                fmt = {
                    {name = "totalchip", type = T.INT},		--总分值
					{name = "bombchip", type = T.INT},		--炸弹得分
					{name = "k510chip", type = T.INT},		--510K得分
                }
        },
    }
}

P.SVR_REFRESH_MONEY                  = 0x600D    --服务器广播玩家出牌
SERVER[P.SVR_REFRESH_MONEY] = {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--底牌的数量
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--玩家出牌类型
                {name = "money", type = T.INT},--玩家出牌类型
            }
        },
    }
}

--服务器广播牌局单局结束
P.SVR_GAME_OVER                  =0x1208
SERVER[P.SVR_GAME_OVER] = {
    ver = 1,
    fmt = {
        -- {name = "spring", type = T.INT},--是否是春天
        -- {name = "winnerType", type = T.INT},--地主还是农民赢
        {name = "playercount", type = T.INT},--地主还是农民赢
        {name = "playerList", type = T.ARRAY, fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--玩家uid
                {name = "cardcount", type = T.BYTE},--玩家还剩的牌的数量
                {name = "cards", type = T.ARRAY,fixedLengthParser = "cardcount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}   --扑克牌数值
                    }
                },
				{name = "rank", type = T.INT},--名次
                {name = "turnchip", type = T.INT},--争游得分
				{name = "bombchip", type = T.INT},--炸弹得分
				{name = "k510chip", type = T.INT},--510K得分
				{name = "totalchip", type = T.INT},--总分
            }
        },
    }
}

--服务器广播牌局总结算
P.SVR_GAME_OVER_TOTAL                  =0x1209
SERVER[P.SVR_GAME_OVER_TOTAL] = {
    ver = 1,
    fmt = {
        {name = "showsingle", type = T.BYTE},
        {name = "playercount", type = T.INT},
        {name = "playerList", type = T.ARRAY, fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--玩家uid
                {name = "totalblc", type = T.BYTE},
            }
        },
    }
}

--服务器广播重置座位
P.SVR_USER_RESET_SEATID                  =0x1210
SERVER[P.SVR_USER_RESET_SEATID] = {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--玩家数量
        {name = "playerList", type = T.ARRAY, fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--玩家uid
                {name = "seatID", type = T.INT},--玩家座位ID
            }
        },
    }
}

--服务器广播名次
P.SVR_USER_RANK                  =0x1211
SERVER[P.SVR_USER_RANK] = {
    ver = 1,
    fmt = {
        {name = "seatID", type = T.INT},--玩家坐位ID
        {name = "rank", type = T.INT},--玩家名次
    }
}

P.SVR_CHIP_CHANGE_BROADCAST              = 0x4800   --广播玩家钱数变化（用于扣取台费）
SERVER[P.SVR_CHIP_CHANGE_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "user_mount", type = T.BYTE}, --闲家数量
        {name = "userinfo", type = T.ARRAY,fixedLengthParser = "user_mount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --用户id
                {name = "change_chip", type = T.INT}, --玩家输赢倍数
            }
        }
    }
}

P.SVR_CHARGE_BROADCAST                 =0x111
SERVER[P.SVR_CHARGE_BROADCAST]={
    ver=1,
    fmt={
    
        {name="uid",type=T.INT},
        {name="chargeCoins",type=T.INT}
    }

}

--组局排行榜
-- P.SVR_GROUP_BILLBOARD                   = 0x5100
-- SERVER[P.SVR_GROUP_BILLBOARD] =  {
    -- ver = 1,
    -- fmt = {  
        -- {name = "playercount", type = T.BYTE},--土豪
        -- {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            -- fmt = {
                -- {name = "uid", type = T.INT},
                -- {name = "sex", type = T.BYTE},
                -- {name = "scoreSize", type = T.BYTE},
                -- {name = "eachScores", type = T.ARRAY,fixedLengthParser = "scoreSize",fixedLength = 0,
                 -- fmt = {
                     -- {type = T.INT}   --每局分数
                 -- }
                -- },
                -- {name = "nickName", type = T.STRING},--游戏玩家数
                -- {name = "portrait", type = T.STRING},--游戏玩家数
                -- {name = "chips", type = T.INT},
            -- }
        -- },
        -- {name = "game_amount", type = T.INT}, --总局数
    -- }
-- }

--组局排行榜
P.SVR_GROUP_BILLBOARD                   = 0x5100
SERVER[P.SVR_GROUP_BILLBOARD] =  {
    ver = 1,
    fmt = {  
        {name = "playercount", type = T.BYTE},--土豪
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},--游戏玩家数
                {name = "portrait", type = T.STRING},--游戏玩家数
                {name = "totalchips", type = T.INT},
				{name = "turncount", type = T.INT},
				{name = "turnchip", type = T.ARRAY, fixedLengthParser = "turncount",fixedLength = 0,
					fmt = {
						{type = T.INT},
					}
				},

            }
        },
        {name = "game_amount", type = T.INT}, --总局数
    }
}

P.SVR_LOGIN_ROOM_FAIL               = 0x1005   --登陆房间失败提示
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT},  --错误码
    }
}  


--组局时长
P.SVR_GROUP_TIME                  = 0x5101
SERVER[P.SVR_GROUP_TIME] =  {
    ver = 1,
    fmt = {
        --{name = "time", type = T.INT},--当前组局剩余时间
        {name = "round", type = T.INT},--当前组局已进行多少局
        {name = "round_total", type = T.INT},--当前组局总局数
    }
}

P.SVR_MSG_FACE                 =0x1004
SERVER[P.SVR_MSG_FACE]={
    ver=1,
    fmt={
        {name="uid",type=T.INT},
        {name="type",type=T.INT}
    }

}

P.CLI_COMMON_MINGPAI =                        0x200B    --地主请求开启明牌模式
CLIENT[P.CLI_COMMON_MINGPAI] = {
    ver = 1,
}



P.SVR_BROADCAST_BONUS                  = 0x6024   --广播玩家奖励手牌
SERVER[P.SVR_BROADCAST_BONUS] = {
    ver = 1,
    fmt = {
        {name = "user_mount", type = T.INT},--桌子上其他玩家的个数
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "user_mount",fixedLength = 0,
        fmt = {
                {name = "uid", type = T.INT},   --用户UID
                {name = "bonus_score", type = T.INT},   --奖励分数
                {name = "cardCount", type = T.INT},--出牌历史次数
                {name = "cardList", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},--手牌
                    }
                },
            }
        },
        {name = "LandLordUid", type = T.INT},   --用户座位号
    }
}

--解散房间相关（新）
--没有此房间，解散房间失败  0x908
P.G2H_CMD_DISSOLVE_FAILED = 0x908
SERVER[P.G2H_CMD_DISSOLVE_FAILED] = {
    ver = 1
}

--广播当前组局解散情况
P.G2H_CMD_REFRESH_DISSOLVE_LIST = 0x909
SERVER[P.G2H_CMD_REFRESH_DISSOLVE_LIST] = {
    ver = 1,
    fmt = {
        {name = "applyId",type = T.INT},--申请解散房间的用户id
         -- {name = "applyTime",type = T.INT},--当前解散时间
        {name = "agreeNum", type = T.INT},--当前同意解散的人数
        {name = "agreeMember_arr", type = T.ARRAY,fixedLengthParser = "agreeNum",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}--已经同意解散的用户
            }
        }
    }
}

--广播桌子用户请求解散组局
P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP = 0x102A
SERVER[P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
         {name = "applyId",type = T.INT}, --申请解散房间的用户id
    }
}


--广播桌子用户成功解散组局
P.SERVER_BROADCAST_DISSOLVE_GROUP = 0x103A
SERVER[P.SERVER_BROADCAST_DISSOLVE_GROUP] = {
    ver = 1
}

--广播桌子用户解散组局 ，解散组局失败
P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP = 0x104A
SERVER[P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
         {name = "rejectId",type = T.INT}, --拒绝的用户id
    }
}


return HALL_SERVER_PROTOCOL




