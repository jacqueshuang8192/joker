local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require("hall.HALL_PROTOCOL")
local P = class("HALL_SERVER_PROTOCOL", HALL_PROTOCOL)

local HALL_SERVER_PROTOCOL = P

local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

----------------------------------------------------------------
------------------------- 登录房间  ----------------------------
----------------------------------------------------------------

P.C_LOGIN_ROOM = 0x1001 --登录房间
CLIENT[P.C_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},
        {name = "uid", type = T.INT},
        {name = "seatId", type = T.INT},
        {name = "sex", type = T.BYTE},
        {name = "nickName", type = T.STRING},
        {name = "portrait", type = T.STRING},
        {name = "latitude", type = T.STRING},
        {name = "longitude", type = T.STRING},
        {name = "otherInfo", type = T.STRING},
        {name = "activityId", type = T.INT},
        {name = "ip", type = T.STRING}
    }
}
P.CLIENT_COMMAND_USER_PIAO = 0x1305 --用户飘
CLIENT[P.CLIENT_COMMAND_USER_PIAO] = {
    ver = 1,
    fmt = {
        {name = "piaoFeng", type = T.INT},
    }
}
P.SERVER_BROADCAST_USER_PIAO = 0x6003 --广播玩家飘分
SERVER[P.SERVER_BROADCAST_USER_PIAO] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "piaoFeng", type = T.INT},
    }
}
P.SERVER_BROADCAST_START_GAME = 0x6002 --广播开始游戏
SERVER[P.SERVER_BROADCAST_START_GAME] = {
    ver = 1,
    fmt = {
        {name = "piaoFeng", type = T.INT},
        {name = "time", type = T.INT},
    }
}

P.S_LOGIN_ROOM = 0x1007 --登陆房间返回
SERVER[P.S_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "maxPlayerCount", type = T.SHORT},
        {name = "club_id", type = T.INT},
        {name = "baseChip", type = T.INT},
        {name = "seatId", type = T.SHORT},
        {name = "inviteCode", type = T.STRING},
        {name = "userCount", type = T.SHORT},
        {
            name = "tPlayers",
            type = T.ARRAY,
            fixedLengthParser = "userCount",
            fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "chips", type = T.INT},
                {name = "m_bAI", type = T.INT},
                {name = "seatId", type = T.SHORT},
                {name = "ready", type = T.SHORT},
                {name = "onLine", type = T.SHORT},
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},
                {name = "portrait", type = T.STRING},
                {name = "latitude", type = T.STRING},
                {name = "longitude", type = T.STRING},
                {name = "otherInfo", type = T.STRING},
                {name = "ip", type = T.STRING}
            }
        },
        {name = "m_bAI", type = T.INT},
        {name = "ownerId", type = T.INT},
        {name = "gameConfig", type = T.STRING}
    }
}

P.S_LOGIN_ROOM_BROADCAST = 0x100D --登陆房间广播
SERVER[P.S_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "seatId", type = T.INT},
        {name = "ready", type = T.BYTE},
        {name = "sex", type = T.BYTE},
        {name = "nickName", type = T.STRING},
        {name = "portrait", type = T.STRING},
        {name = "latitude", type = T.STRING},
        {name = "longitude", type = T.STRING},
        {name = "otherInfo", type = T.STRING},
        {name = "ip", type = T.STRING},
        {name = "chips", type = T.INT}
    }
}
P.CLI_ROBOT                  = 0x2005    --请求托管
CLIENT[P.CLI_ROBOT] = {
    ver = 1,
    fmt = {
        {name = "m_bAI", type = T.INT},  --牌
    }
}
P.S_LOGIN_ROOM_FAIL = 0x1005 --登陆房间失败提示
SERVER[P.S_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT} --错误码
    }
}
    
--断线重连
P.SERVER_COMMAND_RECONNECT_SUCCESS = 0x1009 
SERVER[P.SERVER_COMMAND_RECONNECT_SUCCESS] = {
    ver = 1,
    fmt = {
        {name = "maxPlayerCount", type = T.SHORT},
        {name = "m_bAI", type = T.INT},
        {name = "club_id", type = T.INT},
        {name = "baseChip", type = T.INT},
        --{name = "m_HuXi", type = T.INT},
        -- {name = "seatId", type = T.SHORT},
        {name = "inviteCode", type = T.STRING},
        {name = "duoPai", type = T.INT},--垛牌
        {name = "userCount", type = T.SHORT},
        { name = "tPlayers", type = T.ARRAY, fixedLengthParser = "userCount", fixedLength = 0,
            fmt = {
                {name = "outCardCount", type = T.SHORT},
                { name = "tOutCards", type = T.ARRAY, fixedLengthParser = "outCardCount", fixedLength = 0,
                    fmt = {
                        {name = "cardId", type = T.BYTE},--牌值//对应数值
                        {name = "source", type = T.BYTE}--//打出去的该牌是手牌还是垛牌 1：手牌 2：垛牌
                    }
                },
                {name = "m_byTableCardSize", type = T.SHORT},  --用户操作过后
                { name = "m_byTableCardData", type = T.ARRAY, fixedLengthParser = "m_byTableCardSize", fixedLength = 0,
                  fmt = {
                      --NOTHING = 0,    //没有动作
                      --CHI		= 1,	//吃
                      --PENG	= 2,	//碰
                      --TIE		= 3,	//贴
                      --SHAO	= 4,	//勺
                      --KAN		= 5,	//坎
                      --ZOU		= 6,	//走
                      --HU		= 7,	//胡
                      --SHUN	= 8,	//顺
                      --OTHER	= 9,	//其它
                      {name = "m_isZiMo", type = T.BYTE},--类型
                      {name = "cbActiveType", type = T.BYTE},--类型
                      {name = "cbCardCount", type = T.BYTE},--牌数量
                      { name = "cbCardData", type = T.ARRAY, fixedLengthParser = "cbCardCount", fixedLength = 0,
                        fmt = {
                            {name = "cardId", type = T.BYTE}--牌值
                        }
                      },
                  }
                },
                {name = "uid", type = T.INT},
                {name = "m_nPiao", type = T.INT},-- 用户飘分
                {name = "m_turnBlc", type = T.INT},--
                {name = "m_totalBlc", type = T.INT},--总输赢
                {name = "chips", type = T.INT},
                {name = "m_HuXi", type = T.INT},
                {name = "seatId", type = T.SHORT},
                {name = "ready", type = T.SHORT},
                -- {name = "onLine", type = T.SHORT},
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},
                {name = "portrait", type = T.STRING},
                {name = "latitude", type = T.STRING},
                {name = "longitude", type = T.STRING},
                {name = "otherInfo", type = T.STRING},
                {name = "ip", type = T.STRING}
            }
        },
        {name = "ownerId", type = T.INT},
        {name = "gameStatus", type = T.SHORT},  --桌子状态 0 停止游戏状态 1 正在游戏状态 2 等待下一局游戏状态
        {name = "bankerSeatId", type = T.INT},
        {name = "curRound", type = T.INT},
        {name = "totalRound", type = T.INT},
        {name = "gameConfig", type = T.STRING},
        {name = "UserOnSeatCount", type = T.SHORT},
        {name = "curOptSeatId", type = T.INT},
        {name = "cardCount", type = T.SHORT},  --手牌数据
        { name = "tCards", type = T.ARRAY, fixedLengthParser = "cardCount", fixedLength = 0,
          fmt = {
              { name = "cardId", type = T.BYTE }--牌值
          }
        },
        {name = "opCard", type = T.BYTE},  --当前操作的牌
        {name = "opCode", type = T.INT},  --当前操作的的值   贴 3  吃 1
        {name = "opCardCount", type = T.SHORT},  --操作的数据
        { name = "opCards", type = T.ARRAY, fixedLengthParser = "opCardCount", fixedLength = 0,
          fmt = {
              { name = "cardId", type = T.BYTE }--牌值
          }
        },
        {name = "tingSize", type = T.BYTE},
        {
            name = "tingCards",
            type = T.ARRAY,
            fixedLengthParser = "tingSize",
            fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
                {name = "tingCardSize", type = T.BYTE},
                {
                    name = "cards",
                    type = T.ARRAY,
                    fixedLengthParser = "tingCardSize",
                    fixedLength = 0,
                    fmt = {
                        {name = "cardId", type = T.BYTE},
                        {name = "huxi", type = T.INT},
                    }
                },
            }
        },
    }
}

--广播用户听牌列表
P.SERVER_BROADCAST_TING_CATDS = 0x1212
SERVER[P.SERVER_BROADCAST_TING_CATDS] = {
    ver = 1,
    fmt = {
        {name = "tingSize", type = T.BYTE},
        {
            name = "tingCards",
            type = T.ARRAY,
            fixedLengthParser = "tingSize",
            fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
                {name = "tingCardSize", type = T.BYTE},
                {
                    name = "cards",
                    type = T.ARRAY,
                    fixedLengthParser = "tingCardSize",
                    fixedLength = 0,
                    fmt = {
                        {name = "cardId", type = T.BYTE},
                        {name = "huxi", type = T.INT}
                    }
                },
            }
        },
    }
}

P.C_COMMAND_QUIT = 0x1033 --用户退出桌子
CLIENT[P.C_COMMAND_QUIT] = {
    ver = 1
}

P.BROADCAST_USER_QUIT_ROOM = 0x1033 --广播用户退出
SERVER[P.BROADCAST_USER_QUIT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}
    }
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
--发送玩家自己选的手牌
P.CLIENT_COMMAND_USER_CARD          = 0x1138
CLIENT[P.CLIENT_COMMAND_USER_CARD] = {
    ver = 1,
    fmt = {
        {name = "card", type = T.BYTE},   --牌
    }
}
P.SERVER_COMMAND_USER_CARD               = 0x1138   -- 收到下发的剩余的牌
SERVER[P.SERVER_COMMAND_USER_CARD] = {
    ver = 1,
    fmt = {
        {name = "res", type = T.BYTE},   --牌

    }

}

P.CLIENT_COMMAND_GET_CARD                  = 0x1038    --请求牌
CLIENT[P.CLIENT_COMMAND_GET_CARD] = {
    ver = 1,
}
P.CLI_QUIT_ROOM = 0x1002 --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1
}

P.C_PLAYER_READY = 0x2001 --用户发送准备
CLIENT[P.C_PLAYER_READY] = {
    ver = 1,
    fmt = {name = "ready", type = T.BYTE} -- 0是取消准备，1是准备
}

P.CLIENT_COMMAND_USER_OUT_CARD = 0x1301 --出牌
CLIENT[P.CLIENT_COMMAND_USER_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "cardId", type = T.BYTE}
    }
}

P.CLIENT_COMMAND_USER_PASS = 0x1302 --过牌(弃牌)
CLIENT[P.CLIENT_COMMAND_USER_PASS] = {
    ver = 1
}
P.CLIENT_COMMAND_USER_HU_CARD = 0x1306 --胡牌
CLIENT[P.CLIENT_COMMAND_USER_HU_CARD] = {
    ver = 1,
}
P.CLIENT_COMMAND_USER_CHI_CARD = 0x1303 --吃牌
CLIENT[P.CLIENT_COMMAND_USER_CHI_CARD] = {
    ver = 1,
    fmt = {
        {name = "card_type", type = T.INT},
        {name = "cardId1", type = T.BYTE},
        {name = "cardId2", type = T.BYTE},
        {name = "cardId3", type = T.BYTE}
    }
}

P.CLIENT_COMMAND_USER_TIE_CARD = 0x1304 --贴牌
CLIENT[P.CLIENT_COMMAND_USER_TIE_CARD] = {
    ver = 1,
    fmt = {
        {name = "cardId1", type = T.BYTE},
        {name = "cardId2", type = T.BYTE}
    }
}

--广播桌子用户请求解散组局
P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP = 0x102A
SERVER[P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
        {name = "applyId", type = T.INT} --申请解散房间的用户id
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
        {name = "rejectId", type = T.INT} --拒绝的用户id
    }
}

P.SVR_QUICK_SUC = 0x1008 --用户自己退出成功
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1
}

P.SVR_QUIT_ROOM = 0x100E --广播玩家推出返回
SERVER[P.SVR_QUIT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT} --用户id
    }
}

--服务端发牌
P.SERVER_COMMAND_DEAL_CARD = 0x4001
SERVER[P.SERVER_COMMAND_DEAL_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "bankerSeatId", type = T.INT},
        {name = "curOptSeatId", type = T.INT},
        {name = "duoPai", type = T.INT},--垛牌
        {name = "cardCount", type = T.SHORT},
        { name = "tCards", type = T.ARRAY, fixedLengthParser = "cardCount", fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}
            }
        },
    }
}

--提示玩家是否吃牌
P.SERVER_COMMAND_TIP_CHI_CARD = 0x4002
SERVER[P.SERVER_COMMAND_TIP_CHI_CARD] = {
    ver = 1,
    fmt = {
        {name = "cardCount", type = T.BYTE},
        {
            name = "tCards",
            type = T.ARRAY,
            fixedLengthParser = "cardCount",
            fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}
            }
        }
    }
}

--提示玩家是否贴牌
P.SERVER_COMMAND_TIP_TIE_CARD = 0x4003
SERVER[P.SERVER_COMMAND_TIP_TIE_CARD] = {
    ver = 1,
    fmt = {
        {name = "cardCount", type = T.BYTE},
        {
            name = "tCards",
            type = T.ARRAY,
            fixedLengthParser = "cardCount",
            fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}
            }
        }
    }
}
--提示玩家是否胡牌
P.SERVER_COMMAND_TIP_HU_CARD = 0x4006
SERVER[P.SERVER_COMMAND_TIP_HU_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.BYTE},
    }
}
--广播用户出牌
P.SERVER_BROADCAST_USER_OUT_CARD = 0x1201
SERVER[P.SERVER_BROADCAST_USER_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "cardId", type = T.BYTE},
        {name = "curOptSeatId", type = T.INT}
    }
}

--广播用户过牌
P.SERVER_BROADCAST_USER_PASS_CARD = 0x1202
SERVER[P.SERVER_BROADCAST_USER_PASS_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "curOptSeatId", type = T.INT}
    }
}

--广播用户开始出牌
P.SERVER_BROADCAST_USER_BEGIN_OUT = 0x1204
SERVER[P.SERVER_BROADCAST_USER_BEGIN_OUT] = {
    ver = 1,
    fmt = {}
}

--广播用户得分
P.SERVER_BROADCAST_USER_FEN = 0x1205
SERVER[P.SERVER_BROADCAST_USER_FEN] = {
    ver = 1,
    fmt = {}
}

--广播用户得奖
P.SERVER_BROADCAST_USER_JIANG = 0x1206
SERVER[P.SERVER_BROADCAST_USER_JIANG] = {
    ver = 1,
    fmt = {}
}

--单局结算
P.SERVER_SEND_TURN_RESULT = 0x1208
SERVER[P.SERVER_SEND_TURN_RESULT] = {
    ver = 1,
    fmt = {
        {name = "nRoundResult", type = T.INT},  --是否流局  0流局  1自摸 2平胡
        {name = "huUserSeatid", type = T.INT},  --胡牌玩家ID
        {name = "dianPaoid", type = T.INT},  --点炮id
        {name = "huType", type = T.INT},  --胡的类型
        {name = "huXi", type = T.INT},  --胡息
        {name = "huCardId", type = T.INT},  --胡的哪张牌
        {name = "playerCount", type = T.INT},
        { name = "tPlayers", type = T.ARRAY, fixedLengthParser = "playerCount", fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "m_nPiao", type = T.INT},
                {name = "turnChip", type = T.INT},  --当前输赢分
                {name = "m_totalBlc", type = T.INT},  --总输赢
                {name = "chips", type = T.INT},  --用户本身金币
                {name = "nickName", type = T.STRING},  --用户toux
                {name = "portrait", type = T.STRING},
                {name = "m_byTableCardSize", type = T.BYTE},  --用户操作过后
                { name = "m_byTableCardData", type = T.ARRAY, fixedLengthParser = "m_byTableCardSize", fixedLength = 0,
                  fmt = {
                      --NOTHING = 0,    //没有动作
                      --CHI		= 1,	//吃
                      --PENG	= 2,	//碰
                      --TIE		= 3,	//贴
                      --SHAO	= 4,	//勺
                      --KAN		= 5,	//坎
                      --ZOU		= 6,	//走
                      --HU		= 7,	//胡
                      --SHUN	= 8,	//顺
                      --OTHER	= 9,	//其它
                      {name = "m_isZiMo", type = T.BYTE},--类型
                      {name = "cbActiveType", type = T.BYTE},--类型
                      {name = "cbCardCount", type = T.BYTE},--牌数量
                      { name = "cbCardData", type = T.ARRAY, fixedLengthParser = "cbCardCount", fixedLength = 0,
                        fmt = {
                            {name = "cardId", type = T.BYTE}--牌值
                        }
                      },
                  }
                },
            }
        },
        {name = "m_cbPileCardSize", type = T.BYTE},
        { name = "m_cbPileCardData", type = T.ARRAY, fixedLengthParser = "m_cbPileCardSize", fixedLength = 0,
          fmt = {
              {name = "cardId", type = T.BYTE}--牌值
          }
        },
        --{name = "huHandCount", type = T.SHORT},  --胡牌的人的牌
        --{ name = "huHandCards", type = T.ARRAY, fixedLengthParser = "huHandCount", fixedLength = 0,
        --  fmt = {
        --      {name = "cbActiveType", type = T.BYTE},--类型
        --      {name = "cbCardCount", type = T.BYTE},--牌数量
        --      { name = "cbCardData", type = T.ARRAY, fixedLengthParser = "cbCardCount", fixedLength = 0,
        --        fmt = {
        --            {name = "cardId", type = T.BYTE}--牌值
        --        }
        --      },
        --  }
        --},
    }
}
P.SVR_ROBOT                  = 0x2005    --请求托管
SERVER[P.SVR_ROBOT] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},  --牌
        {name = "m_bAI", type = T.INT},  --牌
    }
}
--总结算(已废弃)
P.SERVER_SEND_TOTAL_RESULT = 0x1209
SERVER[P.SERVER_SEND_TOTAL_RESULT] = {
    ver = 1,
    fmt = {
        {name = "isShowSingle", type = T.BYTE},
        {name = "playercount", type = T.INT},
        {
            name = "playerlist",
            type = T.ARRAY,
            fixedLengthParser = "playercount",
            fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "totalBlc", type = T.INT},
                {name = "winCount", type = T.INT} --赢得次数
            }
        }
    }
}

--总结算
P.SVR_GROUP_BILLBOARD = 0x5100
SERVER[P.SVR_GROUP_BILLBOARD] = {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.BYTE},
        {
            name = "playerlist",
            type = T.ARRAY,
            fixedLengthParser = "playercount",
            fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},
                {name = "portrait", type = T.STRING},
                {name = "chips", type = T.INT},
                {name = "TurnBlcCount", type = T.INT},
                {
                    name = "turnBlcList",
                    type = T.ARRAY,
                    fixedLengthParser = "TurnBlcCount",
                    fixedLength = 0,
                    fmt = {
                        {name = "turnBlc", type = T.INT}
                    }
                }
            }
        },
        {name = "game_amount", type = T.INT} --总局数
    }
}

--广播用户碰牌
P.SERVER_BROADCAST_USER_PENG = 0x120A
SERVER[P.SERVER_BROADCAST_USER_PENG] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "cardCount", type = T.BYTE},
        {
            name = "tCards",
            type = T.ARRAY,
            fixedLengthParser = "cardCount",
            fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}
            }
        },
        {name = "curOptSeatId", type = T.INT},
        {name = "m_HuXi", type = T.INT}
    }
}

--广播用户走牌
P.SERVER_BROADCAST_USER_ZOU = 0x120B
SERVER[P.SERVER_BROADCAST_USER_ZOU] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "cardCount", type = T.BYTE},
        {
            name = "tCards",
            type = T.ARRAY,
            fixedLengthParser = "cardCount",
            fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}
            }
        },
        {name = "curOptSeatId", type = T.INT},
        {name = "m_HuXi", type = T.INT},
        {name = "m_isZiMo", type = T.BYTE},
        {name = "m_isSLXZ", type = T.BYTE},
        {name = "card_type", type = T.BYTE},--桌牌还是手牌

    }
}

--广播用户勺牌
P.SERVER_BROADCAST_USER_SHAO = 0x120C
SERVER[P.SERVER_BROADCAST_USER_SHAO] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "cardCount", type = T.BYTE},
        {
            name = "tCards",
            type = T.ARRAY,
            fixedLengthParser = "cardCount",
            fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}
            }
        },
        {name = "curOptSeatId", type = T.INT},
        {name = "m_HuXi", type = T.INT}
    }
}

--广播用户贴牌
P.SERVER_BROADCAST_USER_TIE = 0x120D
SERVER[P.SERVER_BROADCAST_USER_TIE] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "cardCount", type = T.BYTE},
        {
            name = "tCards",
            type = T.ARRAY,
            fixedLengthParser = "cardCount",
            fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}
            }
        },
        {name = "curOptSeatId", type = T.INT},
        {name = "m_HuXi", type = T.INT}
    }
}

--广播用户吃牌
P.SERVER_BROADCAST_USER_CHI = 0x120E
SERVER[P.SERVER_BROADCAST_USER_CHI] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "card_type", type = T.INT}, --类型吃桌牌还是1手牌   2桌牌就是贴了 然后加一张变成吃
        {name = "cardCount", type = T.BYTE},
        {
            name = "tCards",
            type = T.ARRAY,
            fixedLengthParser = "cardCount",
            fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}  --最后一张就是要执行的动作
            }
        },
        {name = "curOptSeatId", type = T.INT},
        {name = "m_HuXi", type = T.INT}
    }
}

--广播用户抓牌
P.SERVER_BROADCAST_USER_ZHUA = 0x120F
SERVER[P.SERVER_BROADCAST_USER_ZHUA] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "cardId", type = T.BYTE},
        {name = "curOptSeatId", type = T.INT},
        {name = "duoPai", type = T.INT},--垛牌
    }
}

--广播用户该牌无人操作（应用于玩家的摸牌或手牌打出去没有人要的场景）
P.SERVER_BROADCAST_NO_USER_ACTIVE = 0x1210
SERVER[P.SERVER_BROADCAST_NO_USER_ACTIVE] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "cardId", type = T.BYTE},
        {name = "curOptSeatId", type = T.INT}
    }
}

P.SERVER_BROADCAST_HALF_CHANGE_FULL = 0x1211 --广播用户半招变满招
SERVER[P.SERVER_BROADCAST_HALF_CHANGE_FULL] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "cardCount", type = T.BYTE},
        {
            name = "tCards",
            type = T.ARRAY,
            fixedLengthParser = "cardCount",
            fixedLength = 0,
            fmt = {
                {name = "cardId", type = T.BYTE}
            }
        },
        {name = "curOptSeatId", type = T.INT},
        {name = "m_HuXi", type = T.INT},
        {name = "m_isZiMo", type = T.BYTE}
    }
}


P.BROADCAST_USER_SIT_DOWN = 0x1031 --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "seatId", type = T.INT},
        {name = "sex", type = T.BYTE},
        {name = "nickName", type = T.STRING},
        {name = "portrait", type = T.STRING},
        {name = "chips", type = T.INT},
        {name = "latitude", type = T.STRING},
        {name = "longitude", type = T.STRING}
    }
}

--组局回合信息
P.SVR_GROUP_TIME = 0x5101
SERVER[P.SVR_GROUP_TIME] = {
    ver = 1,
    fmt = {
        {name = "curRound", type = T.INT},
        {name = "totalRound", type = T.INT},
    }
}

--发送心跳
P.CLI_HEART = 0x110 
CLIENT[P.CLI_HEART] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT}
    }
}

--坐下
P.CLI_SIT_DOWN = 0x1031 
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT}
    }
}

--站起
P.CLI_STAND_UP = 0x1032 
CLIENT[P.CLI_STAND_UP] = {
    ver = 1
}

--聊天相关
P.CLIENT_CMD_SEND_MSG_TO_SERVER = 0x801 
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT}, --游戏level
        {name = "msg", type = T.STRING}
    }
}

--请求解散房间
P.C2G_CMD_DISSOLVE_ROOM = 0x808
CLIENT[P.C2G_CMD_DISSOLVE_ROOM] = {
    ver = 1
}

--回复请求解散房间
P.C2G_CMD_REPLY_DISSOLVE_ROOM = 0x809
CLIENT[P.C2G_CMD_REPLY_DISSOLVE_ROOM] = {
    ver = 1,
    fmt = {
        {name = "agree", type = T.INT} --0为拒绝解散，1为解散
    }
}

--请求开始游戏
P.CLIENT_CMD_START_GAME = 0x2006
CLIENT[P.CLIENT_CMD_START_GAME] = {
    ver = 1
}


-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------


--站起
P.BROADCAST_USER_STAND_UP = 0x1032 
SERVER[P.BROADCAST_USER_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}
    }
}

--错误码
P.BROADCAST_ERROR_TIPS = 0x5001 
SERVER[P.BROADCAST_ERROR_TIPS] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.SHORT}
    }
}

P.SERVER_CMD_MESSAGE = 0x801 --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.STRING} --消息
    }
}

--解散房间相关
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
        {name = "applyId", type = T.INT},
        --申请解散房间的用户id
        {name = "agreeNum", type = T.INT},
        --当前同意解散的人数
        {
            name = "agreeMember_arr",
            type = T.ARRAY,
            fixedLengthParser = "agreeNum",
            fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}
                --已经同意解散的用户
            }
        }
    }
}

--广播玩家充值
P.SVR_CHARGE_BROADCAST = 0x111
SERVER[P.SVR_CHARGE_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "chargeCoins", type = T.INT}
    }
}

P.SERVER_READYNOW_ROOM = 0x2001 --广播用户准备
SERVER[P.SERVER_READYNOW_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "ready", type = T.BYTE} -- 0是取消准备，1是准备
    }
}

P.SVR_CHIP_CHANGE_BROADCAST = 0x4800 --广播玩家钱数变化（用于扣取台费）
SERVER[P.SVR_CHIP_CHANGE_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "user_mount", type = T.BYTE}, --闲家数量
        {
            name = "userinfo",
            type = T.ARRAY,
            fixedLengthParser = "user_mount",
            fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --用户id
                {name = "change_chip", type = T.INT} --玩家输赢倍数
            }
        }
    }
}

return HALL_SERVER_PROTOCOL
