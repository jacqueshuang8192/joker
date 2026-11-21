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
    }
}


P.CLI_READY_GAME                     = 0x2001    --用户发送准备
CLIENT[P.CLI_READY_GAME] = {
    ver = 1,
    {name = "readyState", type = T.INT},  -- 0是取消准备，1是准备
}


P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x801    --用户发送消息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}

P.CLI_OUT_CARD                    = 0x1301    --玩家出牌
CLIENT[P.CLI_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "CardValue", type = T.BYTE},--玩家的牌值
        {name = "Cardbuf", type = T.BYTE},--玩家出牌的的数量
    }
}

P.CLI_PASS                = 0x1302    --玩家pass
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
		{name = "seatID", type = T.INT}, 				--自己座位ID
		{name = "bankUserSeatID", type = T.INT}, 		--庄家座位ID
		{name = "currentSeatID", type = T.INT}, 		--当前正在操作的玩家ID
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
        {name = "user_gold", type = T.INT},       --玩家筹码数
        {name = "user_gold_64", type = T.INT64},  --玩家筹码数
    }
}

--P.SVR_LOGOUT_ROOM_OK                = 0x1008    --服务器返回玩家退出游戏成功
--SERVER[P.SVR_LOGOUT_ROOM_OK] = {
--    ver = 1
--}


P.BROADCAST_USER_SIT_DOWN  =          0x1031   --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt ={
		{name = "uid", type = T.INT},          --玩家ID
        {name = "seat_id", type = T.INT},      --座位id  
        {name = "sex",type = T.BYTE},          --性别
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "user_gold",type = T.INT},     --用户金币
        {name = "latitude",type = T.STRING},    -- 
        {name = "longitude",type = T.STRING},   --
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
	 fmt = {
        {name = "MaxPlayerCount", type = T.SHORT},  	--游戏模式是几人的
        {name = "BaseChip", type = T.INT},  			--房间底注
        {name = "clubId", type = T.INT},  			--俱乐部id
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
                {name="ip",type = T.STRING}   --用户状态                
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
        {name = "baseChip", type = T.INT},  --底注
        {name = "clubId", type = T.INT},  --俱乐部id
        {name = "inviteCode", type = T.STRING},  --邀请码
        {name = "Playercount", type = T.SHORT},--玩家的个数
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "Playercount",fixedLength = 0,
            fmt = { 
                {name = "uid",type = T.INT},   --桌子其他玩家uid
                {name = "user_gold",type = T.INT},   --桌子其他玩家chip
				{name = "seatID",type = T.SHORT}, 
				{name = "handCardCount",type = T.BYTE},
                {name = "if_ready",type = T.SHORT},   --是否准备
				{name = "sex",type = T.BYTE}, 
				
               
   
                {name = "nickName",type = T.STRING}, 
                {name = "portrait",type = T.STRING},   
                {name = "latitude",type = T.STRING},   
                {name = "longitude",type = T.STRING},  
				{name = "otherInfo",type = T.STRING},  
				{name = "ip",type = T.STRING},
            }
        },
		
		
        {name = "ownerId", type = T.INT},
        {name = "gameStatus", type = T.SHORT},
		
        {name = "bankerUser", type = T.INT},
        {name = "txtFen", type = T.INT},--桌面分
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
		
        {name = "playercounts", type = T.SHORT},--玩家的数量
        {
            name = "userScores", type = T.ARRAY,fixedLengthParser = "playercounts",fixedLength = 0,
                fmt = {
                    {name = "rewardScore",type = T.INT},   --扑克牌数值
                    {name = "pickScore",type = T.INT},   --扑克牌数值
                },
            -- name = "Jiang", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            --     fmt = {
            --         {type = T.INT}   --分值
            --         },
            -- name = "Fen", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            --     fmt = {
            --         {type = T.INT}   --分值
            --     }
        },
		{name = "jokerpos", type = T.INT},--头奖位置
		{name = "currentUser", type = T.INT},
        {name = "turnwiner", type = T.INT},
        {name = "shengyuFen", type = T.INT},
        {name = "outCardSeatID", type = T.INT},
        {name = "cardcount", type = T.BYTE},--牌的数量
        {
            name = "cards", type = T.ARRAY,fixedLengthParser = "cardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE}   --扑克牌数值
            }
        },
    }
}

P.SVR_RESET_USER_SEAT           = 0x1010 --在第一发牌前，重新把所有玩家设置位置，处理前端位置错乱的bug
SERVER[P.SVR_RESET_USER_SEAT] = {
    ver = 1,
    fmt = {
        {name = "Playercount", type = T.SHORT},--玩家的个数
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "Playercount",fixedLength = 0,
            fmt = { 
                {name = "uid",type = T.INT},   --桌子其他玩家uid
                {name = "user_gold",type = T.INT},   --桌子其他玩家chip
                {name = "seatID",type = T.SHORT}, 
                {name = "handCardCount",type = T.BYTE},
                {name = "if_ready",type = T.SHORT},   --是否准备
                {name = "sex",type = T.BYTE}, 
                {name = "nickName",type = T.STRING}, 
                {name = "portrait",type = T.STRING},   
                {name = "latitude",type = T.STRING},   
                {name = "longitude",type = T.STRING},  
                {name = "otherInfo",type = T.STRING},  
                {name = "ip",type = T.STRING},
            }
        },
    }
}


P.SVR_PLAY_CARD                   = 0x1201    --服务器广播玩家出牌
SERVER[P.SVR_PLAY_CARD] = {
    ver = 1,
	fmt = {
        {name = "outCardSeatID", type = T.INT}, --出牌玩家位置ID
        {name = "cardcount", type = T.BYTE},--牌的数量
        {
            name = "cards", type = T.ARRAY,fixedLengthParser = "cardcount",fixedLength = 0,
                fmt = {
                    {type = T.BYTE}   --扑克牌数值
                }
        },
        {name = "nextUser",type = T.INT},   --下一个出牌玩家椅子ID  
        {name = "txtFen",type = T.INT},   --桌子中间的显示分值
        {name = "shengyuFen",type = T.INT},   --桌子剩余分
    }
}
--SERVER_BROADCAST_USER_OUT_CARD  = 0x1201, //广播用户出牌

P.SVR_PASS                   = 0x1202  --服务器广播玩家pass
SERVER[P.SVR_PASS] =  {
    ver = 1,
    fmt = {
        {name = "nPassSeatId", type = T.INT},--Pass的玩家椅子ID
		{name = "nextUser",type = T.INT},   --下一个出牌玩家椅子ID
    }
}



P.SERVER_BROADCAST_BEGIN_OUT                  = 0x1204
SERVER[P.SERVER_BROADCAST_BEGIN_OUT] = {
    ver = 1,
    fmt = {
        {name = "currentUser", type = T.INT},--出牌玩家椅子ID
    }
}

--更新玩家的捡分(庄上)
 P.SERVER_BROADCAST_USER_FEN                  = 0x1205
SERVER[P.SERVER_BROADCAST_USER_FEN] = {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--玩家的数量
        {
            name = "Fen", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
                fmt = {
                    {type = T.INT}   --分值
                }
        },
    }
} 

--更新玩家的奖分(炸弹和头奖)
P.SERVER_BROADCAST_USER_JIANG                  = 0x1206
SERVER[P.SERVER_BROADCAST_USER_JIANG] = {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--玩家的数量
        {
            name = "Jiang", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
                fmt = {
                    {type = T.INT}   --炸弹奖值
                }
        },
        {name = "jokerpos", type = T.INT}, --头奖
    }
}


--合并发送两条出牌或Pass的消息
P.SERVER_BROADCAST_MORE_OPT                  = 0x1207
SERVER[P.SERVER_BROADCAST_MORE_OPT] = {
    ver = 1,
    fmt = {
        {name = "msgSize", type = T.INT},--玩家的数量
        {
            name = "msgLst", type = T.ARRAY,fixedLengthParser = "msgSize",fixedLength = 0,
            fmt = {
                {name = "cmd", type = T.INT},--那条命令
                {name = "outCardSeatID", type = T.INT},--玩家出牌类型
                {name = "cardSize", type = T.BYTE},--玩家出牌类型
                {
                    name = "cards", type = T.ARRAY,fixedLengthParser = "cardSize",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    },
                },
                {name = "nextUser", type = T.INT},--那条命令
                {name = "txtFen", type = T.INT},--玩家出牌类型
                {name = "shengyuFen", type = T.INT},--那条命令
                {name = "playercount", type = T.INT},--玩家出牌类型
                {
                    name = "jiangAndFen", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
                    fmt = {
                        {name = "jiang",type = T.INT},   --炸弹奖值
                        {name = "fen",type = T.INT},   --捡分奖值
                    }
                },
                {name = "jokerpos", type = T.INT}, --头奖
            },
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
        {name = "playercount", type = T.INT},--人数
        {name = "playerList", type = T.ARRAY, fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--玩家uid
                {name = "cardcount", type = T.BYTE},--玩家还剩的牌的数量
                {name = "scards", type = T.ARRAY,fixedLengthParser = "cardcount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}   --扑克牌数值
                    }
                },
                {name = "rank", type = T.BYTE}, --排名
                {name = "JSFen", type = T.INT}, --捡分
                {name = "JSJiang", type = T.INT}, --奖分
                {name = "correctFen", type = T.INT}, --当局分
                {name = "AllFen", type = T.INT}, --总得分
                {name = "m_chips", type = T.INT}, --当前金币数
                {name = "JiangPai", type = T.BYTE}, --奖牌数量
                {name = "jiangpaiinfo", type = T.ARRAY,fixedLengthParser = "JiangPai",fixedLength = 0,
                    fmt = {
                        {name = "cards", type = T.BYTE},----扑克牌数值
                        {name = "cardtype", type = T.BYTE},--玩家出牌类型
                    }
                },
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

--发送玩家自己选的手牌
P.CLIENT_COMMAND_USER_CARD          = 0x1138
CLIENT[P.CLIENT_COMMAND_USER_CARD] = {
    ver = 1,
    fmt = {
        {name = "cardCount", type = T.BYTE}, --牌的数量
        {name = "cards", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},   --牌
            }
        }
    }
}

P.CLIENT_COMMAND_GET_CARD                  = 0x1038    --请求牌
CLIENT[P.CLIENT_COMMAND_GET_CARD] = {
    ver = 1,
}

P.SERVER_COMMAND_GET_CARD               = 0x1038   -- 收到下发的剩余的牌
SERVER[P.SERVER_COMMAND_GET_CARD] = {
    ver = 1,
    fmt = {
        {name = "cardCount",type = T.SHORT},
        {name = "cards", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
         fmt = {
             {name = "card", type = T.BYTE},
         }
        }
    }

}

P.CLIENT_COMMAND_GET_HANDLER_CARD                  = 0x1039    --请求牌
CLIENT[P.CLIENT_COMMAND_GET_CARD] = {
    ver = 1,
}

P.SERVER_COMMAND_GET_HANDLER_CARD               = 0x1039   -- 收到下发的剩余的牌
SERVER[P.SERVER_COMMAND_GET_HANDLER_CARD] = {
    ver = 1,
    fmt = {
        {name = "cardCount",type = T.SHORT},
        {name = "cards", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
         fmt = {
             {name = "card", type = T.BYTE},
         }
        }
    }

}

return HALL_SERVER_PROTOCOL




