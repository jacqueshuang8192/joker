--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--
local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require("hall.HALL_PROTOCOL")
local P = class("HALL_SERVER_PROTOCOL",HALL_PROTOCOL)

local HALL_SERVER_PROTOCOL = P
-- P.CONFIG = {}
-- P.CONFIG.CLIENT = {}
-- P.CONFIG.SERVER = {}
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
P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}


P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}

--获取筹码
P.CLI_GET_CHIP                   = 0x806
CLIENT[P.CLI_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT} --用户id
    }
}


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

P.CLI_MSG_FACE                 =0x1004
CLIENT[P.CLI_MSG_FACE]={
    ver=1,
    fmt={
        {name="type",type=T.INT},
    }
}


P.SVR_LOGIN_ROOM_BROADCAST                 = 0x100D    --服务器广播用户登陆房间
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},--玩家uid
        {name = "seat_id", type = T.INT},--玩家座位号
        {name = "if_ready", type = T.BYTE},--玩家座位号
        {name = "sex",type = T.BYTE},   --座位id
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "latitude",type = T.STRING},   --用户赢数
        {name = "longitude",type = T.STRING},   --用户输数
        {name = "otherInfo", type = T.STRING}, --用户个人信息 
        {name = "ip",type = T.STRING},   --用户状态
        {name = "user_gold", type = T.INT},--玩家筹码数
        {name = "user_gold_64", type = T.INT},--玩家筹码数
    }
}

P.SVR_LOGOUT_ROOM_OK                = 0x1008    --服务器返回玩家退出游戏成功
SERVER[P.SVR_LOGOUT_ROOM_OK] = {
    ver = 1
}


P.SVR_RELOAD_ROOM                = 0x1009    --玩家重连逻辑
SERVER[P.SVR_RELOAD_ROOM] = {
    ver = 1,
    fmt = {
        {name = "clubId", type = T.INT},  --俱乐部ID
        {name = "playMode", type = T.INT},  --游戏模式是几人的
        {name = "isTest", type = T.INT},  --游戏模式是几人的
        {name = "m_bAIUser", type = T.SHORT},--m_bAIUser
        {name = "spade_three", type = T.INT},  --游戏模式是几人的
        {name = "inviteCode", type = T.STRING},  --游戏模式是几人的        
        {name = "Basechip", type = T.INT},--底注
        {name = "tableUserCount", type = T.SHORT},--其他玩家的个数
        {name = "PlayerCount", type = T.SHORT},-- 桌子上的玩家
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "PlayerCount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--其他玩家的uid
                {name = "seat_id", type = T.SHORT}, -- 其他玩家的seatid
                {name = "m_bAIUser",type = T.SHORT},   --玩家是否托管
                {name = "if_ready", type = T.SHORT}, -- 其他玩家是否准备
                {name = "if_online", type = T.SHORT}, -- 其他玩家是否准备
                {name = "if_alert", type = T.SHORT}, -- 玩家是否报单                
                -- {name = "user_info", type = T.STRING}, -- 其他玩家的信息
                {name ="sex",type = T.BYTE},   --座位id
                {name ="nickName",type = T.STRING},   --用户json字符串
                {name ="portrait",type = T.STRING},   --用户金币
                {name ="latitude",type = T.STRING},   --用户赢数
                {name ="longitude",type = T.STRING},   --用户输数
                {name ="otherInfo", type = T.STRING}, --用户个人信息 
                {name ="ip",type = T.STRING},         --用户状态                
                {name ="user_gold", type = T.INT},    --其他玩家的金币      
                {name ="HandCardCount", type = T.INT},--其他玩家的金币
                {name ="pickScore", type = T.INT},  --捡分
                {name ="happyScore", type = T.INT}, --当前喜分
                {name ="bombCount", type = T.INT},  --当前已丢炸弹数
                {name ="friend_uid", type = T.INT}, --队友UID
                {name ="opt", type = T.INT}, --投降炒作// 1 同意  2 拒绝
            }
        },
        {name = "surrenderUid", type = T.INT},--申请投降人的UID
        {name = "OwnerID", type = T.INT},--底注
        {name = "Outcardtime", type = T.SHORT},--出牌时间
        {name = "GAME_STATE", type = T.SHORT},--桌子状态
        {name = "qieSeatId", type = T.SHORT},--切牌玩家ID
        {name = "Handcardcount", type = T.BYTE},--手牌数量
        {name = "HandCardDatas", type = T.ARRAY,fixedLengthParser = "Handcardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        },
        {name = "OutCardUserId", type = T.INT},--当前要出牌玩家id
        {name = "LeftTime", type = T.SHORT},--出牌剩余时间
        
        {name = "turnCardSeatId", type = T.INT},--前个出牌玩家id
        {name = "turnCardType", type = T.BYTE},--
        {name = "turnCardSize", type = T.BYTE},--
        {name = "turnCards", type = T.ARRAY,fixedLengthParser = "turnCardSize",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        },
        {name="roomConfigStr", type = T.STRING}, --房间配置信息
        {name="bank_uid",      type = T.INT},    --包庄玩家ID 或者庄家ID
        {name="canOutCards",   type = T.BYTE},    --当前能否出牌
        {name="firstOutCards", type = T.BYTE},    --是否第一个出牌人
    }
}

------------------------------------------
----客户端命令
P.CLI_READY_GAME                     = 0x2001    --用户发送准备
CLIENT[P.CLI_READY_GAME] = {
    ver = 1,
    {name = "readyState", type = T.INT},  -- 0是取消准备，1是准备
}

P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x801    --向服务器发送向组局里发送的缓存信息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}


P.CLI_PLAYER_CARD                    = 0x1201    --玩家出牌
CLIENT[P.CLI_PLAYER_CARD] = {
    ver = 1,
    fmt = {
        {name = "Cardcount", type = T.BYTE},--玩家出牌的的数量
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},   --扑克牌数值
            }
        }
    }
}

P.CLI_PLAYER_SELECT_CARD                    = 0x1302    --玩家选牌 作弊功能
CLIENT[P.CLI_PLAYER_SELECT_CARD] = {
    ver = 1,
    fmt = {
        {name = "Cardcount", type = T.BYTE},--玩家出牌的的数量
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},   --扑克牌数值
            }
        }
    }
}

P.CLI_PASS          = 0x1202    --玩家pass
CLIENT[P.CLI_PASS]  = {
    ver = 1,
}

P.SVR_BROADCAST_PASS = 0x1202   --服务器广播PASS
SERVER[P.SVR_BROADCAST_PASS] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
    }
}

---------------------------------------------
----服务器命令

P.SVR_PLAY_CARD                   = 0x1201    --服务器广播玩家出牌
SERVER[P.SVR_PLAY_CARD] = {
    ver = 1,
    fmt = {
        {name = "nPreOutUserId", type = T.INT},   --出牌玩家ID
        {name = "Cardtype", type = T.BYTE},     --牌型
        {name = "KeyValue", type = T.BYTE},     --关键
        {name = "Continuous", type = T.BYTE},   --连牌数量
        
        {name = "Cardcount" , type = T.BYTE} , --底牌的数量
        {name = "Putcount", type = T.BYTE},        --出牌的数量
        {
            name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Putcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE}   --扑克牌数值
            }
        },
    }
}

P.SVR_BROADCAST_COUNT_DOWN      = 0x1203   --广播倒计时广播切牌
SERVER[P.SVR_BROADCAST_COUNT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "time", type = T.BYTE},
        {name = "uid", type = T.INT},
    }
}


P.SERVER_BROADCAST_USER_BOMB_FEN      = 0x1205   --广播用户炸弹分 喜分
SERVER[P.SERVER_BROADCAST_USER_BOMB_FEN] = {
    ver = 1,
    fmt = {
        {name = "UserCount", type = T.SHORT}, -- 总共多少人
        {name = "ScoreData", type = T.ARRAY,fixedLengthParser = "UserCount",fixedLength = 0,
            fmt = {
                    {name = "uid", type = T.INT },
                    {name = "happyScore", type = T.INT},
                    {name = "bombCount", type = T.INT},
            } 
        },
    }
}

P.SERVER_BROADCAST_USER_GAIN_SCORE      = 0x1206   --广播用户获得分牌的分
SERVER[P.SERVER_BROADCAST_USER_GAIN_SCORE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, -- UID
        {name = "pickScore", type = T.INT}, -- 分数
    }
}

P.SERVER_BROADCAST_NEXT_OPT_USER      = 0x1207   --下个操作的玩家
SERVER[P.SERVER_BROADCAST_NEXT_OPT_USER] = {
    ver = 1,
    {name = "UserSeat", type = T.BYTE}, -- seatID
}

P.SERVER_SEND_TURN_RESULT      = 0x1208   --小局结算
SERVER[P.SERVER_SEND_TURN_RESULT] = {
    ver = 1,
    fmt = {
        {name = "Basechip", type = T.INT}, -- 2人底牌
        {name = "playercount", type = T.INT}, --每个人剩余牌
        {name = "playerList", type = T.ARRAY, fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "Uid", type = T.INT},      --玩家seat
                {name = "Turningscore", type = T.INT},--变化的钱
                {name = "Totalscore" , type = T.INT} ,--头像上显示的钱

                {name = "rank", type = T.BYTE},      --排行
                {name = "rankscore", type = T.INT},  --排行得分
                {name = "pickscore", type = T.INT},  --捡分
                {name = "happyscore", type = T.INT}, --喜分
                {name = "allscore", type = T.INT},   --总分


                {name = "Cardcount", type = T.BYTE},--玩家还剩的牌的数量
                {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}   --扑克牌数值
                    }
                },
            }
        },

        {name = "otherCardSize", type = T.BYTE},--剩余的第3手牌(两人模式)
        {name = "otherCards", type = T.ARRAY, fixedLengthParser = "otherCardSize",fixedLength = 0,
            fmt = {
                {type = T.BYTE}   --扑克牌数值
            }
        },
    }
}


P.CLI_SELECTUNDERTAKE                    = 0x1301    -- 玩家选择是否包庄
CLIENT[P.CLI_SELECTUNDERTAKE] = {
    ver = 1,
    fmt = {
        {name = "isSelect", type = T.BYTE},--玩家选择  1  包庄 2 不包庄
    }
}


P.SVR_DEAL                       = 0x4001    --发牌  发牌了  证明不用包庄步骤
SERVER[P.SVR_DEAL] = {
    ver = 1,
    fmt = {
        {name = "nOutCardUserId", type = T.INT}, -- 出牌玩家uid
        {name = "QieCardSeatId", type = T.INT},  -- 拿到明牌的玩家
        {name = "QieCard", type = T.INT},        -- 明牌值
        {name = "FriendUserId", type = T.INT},
        {name = "CardCount", type = T.SHORT},    -- 总共多少牌
        {name = "HandCardDatas", type = T.ARRAY,fixedLengthParser = "CardCount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        }
    }
}

P.SVR_SELECTUNDERTAKE                = 0x4003    -- 通知玩家可以选择包庄
SERVER[P.SVR_SELECTUNDERTAKE] = {
    ver = 1,
    fmt = {
        {name = "nSelectSeat", type = T.INT},    -- 轮到谁选择包牌
        {name = "nShowCardSeat", type = T.INT},  -- 拿到明牌的玩家
        {name = "nShowCard", type = T.BYTE},      -- 明牌值
    }
}

P.SVR_SELECTUNDERTAKERESULT          = 0x4006    -- 通知玩家选择包庄
SERVER[P.SVR_SELECTUNDERTAKERESULT] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},           -- UID
        {name = "nUserSeat", type = T.BYTE},    -- 谁选择包牌
        {name = "isSelect", type = T.BYTE},     -- 选择包牌结果
    }
}

P.SVR_SHANGESEAT          = 0x4005    -- 通知玩家换座位
SERVER[P.SVR_SHANGESEAT] = {
    ver = 1,
    fmt = {
        {name = "nUserSeat1", type = T.BYTE},      -- 谁nUserSeat1和谁nUserSeat2换座位
        {name = "nUserSeat2", type = T.BYTE},      
    }
}





P.SVR_QUICK_SUC               = 0x1008   --用户自己退出成功
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1,
}



P.CLI_QUIT_ROOM                     = 0x1033    --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

P.CLI_SIT_DOWN  =          0x1031   --坐下
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    {name="seat_id",type = T.INT},   --座位id       
}


P.CLI_STAND_UP  =          0x1032   --站起
CLIENT[P.CLI_STAND_UP] = {
    ver = 1,
}

------------------------------ 投降 ------------------------------
P.C2G_CMD_APPLY_SURRENDER                   = 0x818  -- 请求投降
CLIENT[P.C2G_CMD_APPLY_SURRENDER] = {
    ver = 1
}

P.C2G_CMD_OPT_SURRENDER                   = 0x819  -- 投降操作
CLIENT[P.C2G_CMD_OPT_SURRENDER] = {
    ver = 1,
    fmt = {
        {name = "opt", type = T.BYTE} --1 同意，2为拒绝
    }
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

--请求开始游戏 切牌
P.CLI_QIEPAI                   = 0x2016
CLIENT[P.CLI_QIEPAI] = {
    ver = 1,
}

--请求开始游戏洗牌
P.CLIENT_USER_SHUFFLE                   = 0x2017
CLIENT[P.CLIENT_USER_SHUFFLE] = {
    ver = 1,
}



-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------

P.SERVER_CMD_MESSAGE                = 0x801    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.STRING}, --消息
    }
}

P.BROADCAST_ERROR_TIPS  =          0x5001   --错误提示
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





P.BROADCAST_USER_SIT_DOWN  =          0x1031   --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT}, 
        {name = "seat_id", type = T.INT}, 
        {name = "sex",type = T.BYTE},   --座位id       
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "user_gold",type = T.INT},   --用户金币
        {name = "ip",type = T.STRING},   --用户状态
        {name = "latitude",type = T.STRING},   --用户赢数
        {name = "longitude",type = T.STRING},   --用户输数
        {name = "pickScore", type = T.INT},  --捡分
        {name = "happyScore", type = T.INT}, --当前喜分
        {name = "bombCount", type = T.INT},  --当前炸弹
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
        {name = "clubId", type = T.INT},
        {name = "cardLess", type = T.INT},  --是不是去掉3,4 王
        --{name = "isTest", type = T.INT},  --游戏模式是几人的
        {name = "m_bAIUser", type = T.INT},--m_bAIUser
        {name = "Basechip", type = T.INT},--房间底注
        {name = "SeatID", type = T.SHORT},--座位ID
        {name = "inviteCode", type = T.STRING},  --游戏模式是几人的
        {name = "tableUserCount", type = T.SHORT},--其他玩家的个数
        {name = "user_mount", type = T.SHORT},--桌子上其他玩家的个数
        {name = "playerlist", type =T.ARRAY,fixedLengthParser = "user_mount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--其他玩家的uid
                {name = "user_gold", type = T.INT},--其他玩家的金币
                {name = "seat_id", type = T.SHORT}, -- 其他玩家的seatid
                {name = "m_bAIUser",type = T.SHORT},   --玩家是否托管
                {name = "if_ready", type = T.SHORT}, -- 其他玩家是否准备
                {name = "if_online", type = T.SHORT}, -- 其他玩家是否在线
                -- {name = "user_info", type = T.STRING}, -- 其他玩家的信息
                {name = "sex",type = T.BYTE},   --性别
                {name = "nickName",  type = T.STRING},   --用户昵称
                {name = "portrait",  type = T.STRING},   --用户金币
                {name = "latitude",  type = T.STRING},   --用户赢数
                {name = "longitude", type = T.STRING},   --用户输数
                {name = "otherInfo", type = T.STRING}, --用户个人信息 
                {name = "ip",        type = T.STRING},   --用户状态
                
                {name = "pickScore", type = T.INT},    --捡分
                {name = "happyScore", type = T.INT},   --当前喜分数
                {name = "bombCount", type = T.INT},    --当前炸弹数
            }
        },
        {name = "OwnerID", type = T.INT},--房主ID
        {name="roomConfigStr", type = T.STRING}, --房间配置信息
    }
}




P.SVR_BROADCAST_NOTICE_USER_OUTCARD            = 0x1207    --广播通知那个玩家操作
SERVER[P.SVR_BROADCAST_NOTICE_USER_OUTCARD] = {
    ver = 1,
    fmt = {
        {name = "nOutCardUserId", type = T.INT},--出牌玩家的uid
        {name = "outTime", type = T.BYTE},      --出牌时间
        {name = "canOutCards", type = T.BYTE},  --是否能出牌
        {name = "firstOutCards", type = T.BYTE},--是否第一个出牌人
    }
}

P.SVR_PLAY_CARD_ERROR                   = 0x4002    --返回出牌错误
SERVER[P.SVR_PLAY_CARD_ERROR] = {
    ver = 1,
    fmt = {
        {name = "nError", type = T.INT},--错误类型
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


P.SVR_PASS                   = 0x6006  --服务器广播玩家pass
SERVER[P.SVR_PASS] =  {
    ver = 1,
    fmt = {
        -- {name = "nIsNewTurn", type = T.INT},--是否是新回合
        {name = "nPassUserId", type = T.INT},--Pass的玩家uid
        -- {name = "nNextOutUserId", type = T.INT}--下一个出牌玩家
    }
}

P.SVR_ALERT                   = 0x6007  --服务器广播玩家报单
SERVER[P.SVR_ALERT] =  {
    ver = 1,
    fmt = {
        {name = "userId", type = T.INT},--Pass的玩家uid
    }
}

--服务器广播牌局结束，结算结果
    --服务器广播牌局结束，结算结果
P.SVR_GAME_OVER                  =0x6008
SERVER[P.SVR_GAME_OVER] = {
    ver = 1,
    fmt = {
        {name = "Basechip", type = T.INT},--底注
        {name = "playercount", type = T.INT},--地主还是农民赢
        {name = "playerList", type = T.ARRAY, fixedLengthParser = "playercount",fixedLength = 3,
            fmt = {
                {name = "Uid", type = T.INT},--玩家uid
                {name = "Turningscore", type = T.INT},--变化的钱
                {name = "Totalscore" , type = T.INT} ,--头像上显示的钱
                {name = "isChunTian", type = T.BYTE}, --是否春天
                {name = "Cardcount", type = T.BYTE},--玩家还剩的牌的数量
                {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}   --扑克牌数值
                    }
                },
            }
        },
        {name = "otherCardSize", type = T.SHORT},--剩余的第3手牌(两人模式)
        {name = "otherCards", type = T.ARRAY, fixedLengthParser = "otherCardSize",fixedLength = 15,
            fmt = {
                {type = T.BYTE}   --扑克牌数值
            }
        },

    }
}

P.SVR_SHOW_CARD                  = 0x6011    --服务器广播用户亮牌
SERVER[P.SVR_SHOW_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {
            name = "cards", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        }
    }
}


P.SVR_GET_BASE_CARDS                   = 0x6025  --接收地主底牌
SERVER[P.SVR_GET_BASE_CARDS] =  {
    ver = 1,
    fmt = {
        {name = "Cardcount", type = T.SHORT},--底牌的数量
        {name = "LandCarddata", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE}   --扑克牌数值
            }
        }
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
        -- {name = "time", type = T.INT},--当前组局剩余时间
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

P.CLIENT_SEND_MINGPAI_REMIND =             0x6021    --提示地主开启明牌模式
CLIENT[P.CLIENT_SEND_MINGPAI_REMIND] = {
    ver = 1,
}


P.SVR_SEND_MINGPAI_REMIND =             0x6022    --提示地主开启明牌模式
SERVER[P.SVR_SEND_MINGPAI_REMIND] = {
    ver = 1,
    fmt = {
            {name = "Cardcount", type = T.INT}, -- 总共多少牌
            {name = "HandCardDatas", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
                fmt = {
                    { name = "user_id" , type = T.INT},   --数字id
                    { name = "card_num" , type = T.INT},   --扑克牌数值
                    { name = "card_datas", type = T.ARRAY,fixedLengthParser = "card_num",fixedLength = 0,
                         fmt = {
                            {name = "card_value", type = T.BYTE},--手牌
                        }
                    }
                }
            }
        }
    
}

P.CLI_PEI_PAI =             0x2218    --请求配牌
CLIENT[P.CLI_PEI_PAI] = {
    ver = 1,
    fmt = {
        {name = "cardCount", type = T.BYTE},--出牌历史次数
        {name = "cardList", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},--手牌
            }
        }
    }
}

P.CLI_COMMON_MINGPAI =                        0x200B    --地主请求开启明牌模式
CLIENT[P.CLI_COMMON_MINGPAI] = {
    ver = 1,
}


P.SVR_BROADCAST_MINGPAI                  = 0x6023   --明牌后广播玩家手牌
SERVER[P.SVR_BROADCAST_MINGPAI] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --用户座位号
        {name = "cardCount", type = T.INT},--出牌历史次数
        {name = "cardList", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},--手牌
            }
        }
    }
}


P.SVR_BROADCAST_USERCALL                  = 0x6026  
SERVER[P.SVR_BROADCAST_USERCALL] = {
    ver = 1,
    fmt = {
        {name = "PreScoreUserId", type = T.INT},--上一个叫分玩家的userid
        {name = "PreScore", type = T.INT},--上一个叫分玩家的分数
    }
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

--解散房间相关（废弃）
--没有此房间，解散房间失败  0x908
P.S2C_DISSOLVE_FAILED = 0x908
SERVER[P.S2C_DISSOLVE_FAILED] = {
    ver = 1
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

--广播桌子用户请求投降
P.SERVER_BROADCAST_REQUEST_SURRENDER = 0x112A
SERVER[P.SERVER_BROADCAST_REQUEST_SURRENDER] = {
    ver = 1,
    fmt = {
         {name = "applyId",type = T.INT}, --申请解散房间的用户id
    }
}

--广播桌子用户 投降操作
P.SERVER_BROADCAST_OPT_SURRNEDER = 0x114A
SERVER[P.SERVER_BROADCAST_OPT_SURRNEDER] = {
    ver = 1,
    fmt = {
            {name = "optUid",type = T.INT}, --处理投降玩家
            {name = "curUid",type = T.INT}, --当前操作玩家
            {name = "opt",type = T.INT}, --// 1 同意  2 拒绝
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

--广播桌子用户报单提示
P.SERVER_SEND_SINGE_DATA                 = 0x6033    --广播桌子用户报单提示
SERVER[P.SERVER_SEND_SINGE_DATA] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}
    }
}
--用户请求托管
P.CLIENT_COMMAND_AUTO                   = 0x1034
CLIENT[P.CLIENT_COMMAND_AUTO] = {
    ver = 1,
    fmt = {
        {name = "m_bAIUser", type = T.BYTE} --用户id
    }
}
--广播桌子用户报单提示
P.SERVER_COMMAND_AUTO                 = 0x1034    --广播桌子用户报单提示
SERVER[P.SERVER_COMMAND_AUTO] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "m_bAIUser", type = T.BYTE}
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
                {name = "nickName", type = T.STRING},--昵称
                {name = "portrait", type = T.STRING},--肖像
                {name = "chips", type = T.INT},      --积分
                {name = "gameCount", type = T.INT},  --
                {name = "eachScores", type = T.ARRAY,fixedLengthParser = "gameCount",fixedLength = 0,
                    fmt = {{name = "score", type = T.INT}}
                },
            }
        },
        {name = "game_amount", type = T.INT}, --总局数
    }
}


return HALL_SERVER_PROTOCOL