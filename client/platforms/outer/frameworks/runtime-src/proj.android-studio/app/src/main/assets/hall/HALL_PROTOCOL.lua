--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--

local T = bm.PACKET_DATA_TYPE
local P = {}

local HALL_PROTOCOL = P
HALL_PROTOCOL.HALL_PROTOCOL_EX = "HALL_PROTOCOL_EX"
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------
P.CLI_HEART = 0x110 --发送心跳
CLIENT[P.CLI_HEART] ={
    ver = 1,
    fmt = {
        {name = "tid",type = T.INT},
    }
}

P.CLI_LOGIN =                        0x116    --登录大厅
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "storeId", type = T.INT},
        {name = "kind", type = T.BYTE},
        {name = "userInfo", type = T.STRING},
    }
}


P.CLI_LOGIN_GAME =                        0x113    --进入游戏
CLIENT[P.CLI_LOGIN_GAME] = {
    ver = 1,
    fmt = {
        {name = "Level", type = T.SHORT},--游戏场等级
        {name = "Chip", type = T.INT},--请求场次的底注
        {name = "Sid", type = T.INT},--游戏场的id
        {name = "tid", type = T.INT},
        {name = "activity_id", type = T.INT}, --带入活动id
        {name = "baseChip", type = T.INT}, --带入活动id
        {name = "isWatch", type = T.BYTE}, --带入活动id
        {name = "juli", type = T.INT}, --带入活动id
        {name = "latitude", type = T.STRING}, --经度
        {name = "longitude", type = T.STRING}, --纬度
    }
}

--P.CLI_LOGIN_ENCRYPT_GAME =                        0x261    --进入游戏
--CLIENT[P.CLI_LOGIN_ENCRYPT_GAME] = {
--    ver = 1,
--    fmt = {
--        {name = "Level", type = T.SHORT},--游戏场等级
--        {name = "Chip", type = T.INT},--请求场次的底注
--        {name = "Sid", type = T.INT},--游戏场的id
--        {name = "tid", type = T.INT},
--        {name = "activity_id", type = T.INT}, --带入活动id
--        {name = "baseChip", type = T.INT}, --带入活动id
--        {name = "password", type = T.STRING} --输入密码
--    }
--}

--P.CLI_LOGIN_ROOM_GROUP                 = 0x1001    --登录组局房间
--CLIENT[P.CLI_LOGIN_ROOM_GROUP] = {
--    ver = 1,
--    fmt = {
--        {name = "tableid", type = T.INT},   --桌子ID
--        {name = "nUserId", type = T.INT},   --用户ID
--        {name = "strkey", type = T.STRING}, --需要验证的key
--        {name = "strinfo", type = T.STRING}, --用户个人信息
--        {name = "iflag", type = T.INT},   --登陆标志
--        {name = "version", type = T.STRING}, --用户版本
--        {name = "activity_id", type = T.STRING} --带入活动id
--    }
--}

P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x801    --向服务器发送向组局里发送的文字信息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}

--P.CLIENT_CMD_HALL_SEND_MSG_TO_SERVER                = 0x168    --发送信息给指定用户
--CLIENT[P.CLIENT_CMD_HALL_SEND_MSG_TO_SERVER] = {
--    ver = 1,
--    fmt = {
--        {name = "uid", type = T.INT},   --接受信息的用户uid
--        {name = "msg", type = T.STRING}
--    }
--}

P.CLIENT_CMD_LOGIN_ALLOC               = 0x151   --登录Alloc
CLIENT[P.CLIENT_CMD_LOGIN_ALLOC] = {
    ver = 1,
    fmt = {
        {name = "level",type = T.SHORT},  --游戏level
    }
}

P.CLIENT_CMD_LOGOUT_ALLOC               = 0x153    --登出Alloc
CLIENT[P.CLIENT_CMD_LOGOUT_ALLOC] = {
    ver = 1,
    fmt = {
        {name = "level",type = T.SHORT},  --游戏level
    }
}


--P.CLIENT_CMD_CREAT_TABLE               = 0x160    -- 创建桌子
--CLIENT[P.CLIENT_CMD_CREAT_TABLE] = {
--    ver = 1,
--    fmt = {
--        {name = "uid", type = T.INT},
--        {name = "level",type = T.INT},
--        {name = "baseChip",type = T.INT},
--        {name = "initChip",type = T.INT},
--        {name = "configJson",type = T.STRING}
--    }
--}

P.CLUB_DATA = 0x172 --请求获取联盟信息
CLIENT[P.CLUB_DATA] ={
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT},
        {name = "groupType", type = T.INT},  -- 2 积分   3 房卡
        {name = "page", type = T.INT},  --
        {name = "num", type = T.INT},  --
        {name = "gameType", type = T.INT},  --   -1查全部  不是负一 就把某个子游戏type带上
        {name = "configId", type = T.INT},  --   -11查全部  不是负一 就把玩法id带过来
        {name = "nickName", type = T.STRING},  --   -用户名字
        {name = "portrait", type = T.STRING},  --   -用户头像

    }
}


--心跳
P.CLISVR_HEART_BEAT              = 0x0110    --server心跳包
-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
----登录Alloc 返回
--P.SERVER_CMD_LOGIN_ALLOC                    = 0x151
--SERVER[P.SERVER_CMD_LOGIN_ALLOC] = {
--    ver = 1,
--    fmt = {
--        {name = "returnCode",type = T.BYTE},  -- 返回码
--        {name = "tableListSize",type = T.SHORT},
--        {name = "tableList",type = T.ARRAY,fixedLengthParser = "tableListSize",fixedLength = 0,
--            fmt = {
--                {name = "tid",type = T.INT},
--                {name = "activity_id",type = T.INT},
--                {name = "invity_code",type = T.STRING},
--                {name = "description",type = T.STRING},
--                {name = "play_nums",type = T.BYTE},
--                {name = "in_coin",type = T.INT},
--                {name = "baseChip",type = T.INT},
--                {name = "max_nums",type = T.BYTE},
--                {name = "ower_uid",type = T.INT},
--                {name = "creator_nikename",type = T.STRING},
--                {name = "creator_portrait",type = T.STRING},
--                {name = "bonus_pool",type = T.INT},
--                {name = "userMapSize",type = T.BYTE},
--                {name = "userMap",type = T.ARRAY,fixedLengthParser = "userMapSize",fixedLength = 0,
--                    fmt = {
--                        -- {name = "uid",type = T.INT},
--                        {name = "seatId",type = T.INT}
--                        -- {name = "nickname",type = T.STRING},
--                        -- {name = "portrait",type = T.STRING}
--                    }
--                },
--            }
--        },
--        {name = "tablePasswordList",type = T.ARRAY,fixedLengthParser = "tableListSize",fixedLength = 0,
--            fmt = {
--                {name = "password",type = T.STRING}
--            }
--        },
--    }
--}


P.SERVER_CMD_LOGOUT_ALLOC               = 0x153    --登出Alloc
SERVER[P.SERVER_CMD_LOGOUT_ALLOC] = {
    ver = 1,
}


----创建桌子返回
--P.SERVER_CMD_CREAT_TABLE            = 0x360
--SERVER[P.SERVER_CMD_CREAT_TABLE] = {
--    ver = 1,
--    fmt = {
--        {name = "msg",type = T.INT},
--        {name = "createFlag",type = T.INT},
--        {name = "msg",type = T.INT},
--        {name = "tid",type = T.INT},
--        {name = "msg",type = T.STRING},
--        {name = "msg",type = T.INT},
--        {name = "msg",type = T.INT},
--        {name = "msg",type = T.INT}
--    }
--}

---- 广播桌子状态
--P.SERVER_CMD_TABLE_STATE       = 0x159
--SERVER[P.SERVER_CMD_TABLE_STATE] = {
--    ver = 1,
--    fmt = {
--        {name = "type",type = T.BYTE},
--        {name = "m_nLevel",type = T.SHORT},
--        {name = "tid",type = T.INT},
--        {name = "activity_id",type = T.INT},
--        {name = "invity_code",type = T.STRING},
--        {name = "description",type = T.STRING},
--        {name = "play_nums",type = T.BYTE},
--        {name = "in_coin",type = T.INT},
--        {name = "baseChip",type = T.INT},
--        {name = "max_nums",type = T.BYTE},
--        {name = "ower_uid",type = T.INT},
--        {name = "creator_nikename",type = T.STRING},
--        {name = "creator_portrait",type = T.STRING},
--        {name = "bonus_pool",type = T.INT},
--        {name = "uid",type = T.INT},
--        {name = "seatId",type = T.INT},
--        {name = "nickname",type = T.STRING},
--        {name = "portrait",type = T.STRING},
--        {name = "password",type = T.STRING},
--    }
--}

P.SERVER_CMD_HALL_GET_MESSAGE                = 0x168    --接收服务器放回的指定用户信息
SERVER[P.SERVER_CMD_HALL_GET_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --接受信息的用户uid
        {name = "msg", type = T.STRING}
    }
}

P.CLIENT_BROADCAST_MSG                = 0x169    --广播
CLIENT[P.CLIENT_BROADCAST_MSG] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT},   --接受信息的用户uid
        {name = "msg", type = T.STRING}
    }
}

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SERVER_CMD_FORWARD_MESSAGE                = 0x0213    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msgCount", type = T.INT}, --消息长度
        {name = "msgList", type = T.ARRAY, fixedLengthParser = "msgCount", fixedLength = 0,
            fmt = {
                {name = "msg", type = T.STRING}, --消息
            }
        },
    }
}

P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}

P.SVR_CLOSE_NET               = 0x0301    --当前玩家被服务器断网
SERVER[P.SVR_CLOSE_NET] = {
    ver = 1
}
P.SVR_KICK_OFF               = 0x0203    --当前玩家被踢下线
SERVER[P.SVR_KICK_OFF] = {
    ver = 1
}

P.SVR_LOGIN_GAME                = 0x0210    --服务器返回进入游戏
SERVER[P.SVR_LOGIN_GAME] = {
    ver = 1,
    fmt = {
        {name = "Tid", type = T.INT}, --桌子ID
        {name = "ServerID", type = T.SHORT}, --服务器ID
        {name = "Ip", type = T.STRING},--服务器ip，如果ip为空的话，则是服务器不够用了，客户端可显示服务器繁忙
        {name = "Port", type = T.INT}, --端口号
        {name = "Res", type = T.INT}, --返回标注
        {name = "level", type = T.SHORT},--游戏
        {name = "player_nums", type = T.BYTE},--游戏
        {name = "activityId", type = T.INT},--游戏
        {name = "shortGameConfig", type = T.STRING},--游戏
        {name = "roomPassword", type = T.STRING},--游戏
        {name = "isWatch", type = T.BYTE}, --
    }
}


P.SVR_ENTER_ROOM_FAIL                = 0x0212    --服务器返回组局收到的信息
SERVER[P.SVR_ENTER_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.SHORT}, --桌子ID
        {name = "errorCode", type = T.SHORT}, --桌子ID
    }
}


P.SVR_LOGIN_OK                   = 0x201    --登录成功
SERVER[P.SVR_LOGIN_OK] = {
    ver = 1,
    fmt = {
        {name = "Ver", type = T.INT},--成功与否标注，1为成功
        {name = "Levelcount", type = T.INT},--等级场个数
        {name = "Usercount", type = T.ARRAY,fixedLengthParser = "Levelcount",fixedLength = 0,
            fmt = {
                {name = "counts", type = T.INT},   --等级场人数
            }
        },
        {name = "Friendcount", type = T.INT},
        {name = "Tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "Ip", type = T.STRING,request = "Tid",requestValue = 0}, --服务器ip
        {name = "port", type = T.INT,request = "Tid",requestValue = 0},--服务器端口
        {name = "Serverlevel", type = T.SHORT,request = "Tid",requestValue = 0},--服务器等级
        {name = "on_look_user", type = T.INT},--围观用户id
        {name = "type", type = T.INT},--游戏类型
         {name = "battles_count", type = T.BYTE},--场次列表
         {name = "battles_list", type = T.ARRAY,fixedLengthParser = "battles_count",fixedLength = 0,
             fmt = {
                 {name = "level", type = T.INT},   --等级
                 {name = "counts", type = T.INT},   --等级场人数
             }
         },
    }
}



--围观重连
P.SVR_LOGINLOOK_OK                   = 0x532
SERVER[P.SVR_LOGINLOOK_OK] = {
    ver = 1,
    fmt = {
        {name = "Ver", type = T.INT},--成功与否标注，1为成功
        {name = "Levelcount", type = T.INT},--等级场个数
        {name = "Usercount", type = T.ARRAY,fixedLengthParser = "Levelcount",fixedLength = 0,
            fmt = {
                {name = "counts", type = T.INT},   --等级场人数
            }
        },
        {name = "Friendcount", type = T.INT},
        {name = "Tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "Ip", type = T.STRING,request = "Tid",requestValue = 0}, --服务器ip
        {name = "port", type = T.INT,request = "Tid",requestValue = 0},--服务器端口
        {name = "Serverlevel", type = T.SHORT,request = "Tid",requestValue = 0},--服务器等级
        {name = "on_look_user", type = T.INT},--围观用户id
        {name = "type", type = T.INT},--游戏类型
        -- {name = "battles_count", type = T.INT},--场次列表
        -- {name = "battles_list", type = T.ARRAY,fixedLengthParser = "battles_count",fixedLength = 0,
        --     fmt = {
        --         {name = "level", type = T.INT},   --等级
        --         {name = "counts", type = T.INT},   --等级场人数
        --     }
        -- },
    }
}

--用户当前IP
P.SERVER_USER_IP                = 0x202    --接收服务器放回的用户当前IP地址
SERVER[P.SERVER_USER_IP] = {
    ver = 1,
    fmt = {
        {name = "IP", type = T.STRING}
    }
}

P.TABLE_DATA_CHANGE = 0x173 --更新联盟桌子信息
SERVER[P.TABLE_DATA_CHANGE] ={
    ver = 1,
    fmt = {
        {name = "type", type = T.BYTE}, --
        {name = "table_id", type = T.INT},
        {name = "club_id", type = T.INT},
        {name = "level", type = T.INT},
        {name = "is_start", type = T.BYTE},
        {name = "id", type = T.INT},
        {name = "gameType", type = T.INT},
        {name = "currRound", type = T.INT},
        {name = "table_info", type = T.STRING},
        {name = "userinfo", type = T.STRING},
        {name = "groupName", type = T.STRING},
        {name = "m_strInviteCode", type = T.STRING},
    }
}

P.TABLE_DATA = 0x174 --返回联盟桌子信息
SERVER[P.TABLE_DATA] ={
    ver = 1,
    fmt = {
        {name = "is_end", type = T.BYTE},
        {name = "table_num", type = T.BYTE},
        {name = "table_data", type = T.ARRAY, fixedLengthParser = "table_num", fixedLength = 0,
         fmt = {
             {name = "table_id", type = T.INT},
             {name = "club_id", type = T.INT},
             {name = "level", type = T.SHORT},
             {name = "is_start", type = T.BYTE},
             {name = "player_total", type = T.BYTE},

             {name = "id", type = T.INT},
             {name = "gameType", type = T.INT},
             {name = "currRound", type = T.INT},
             {name = "table_info", type = T.STRING},
             {name = "groupName", type = T.STRING},
             {name = "player_num", type = T.BYTE},
             {name = "user_list", type = T.ARRAY, fixedLengthParser = "player_num", fixedLength = 0,
                  fmt = {
                      {name = "userinfo", type = T.STRING},
                  }
             },

         }
        },
        --fmt = {
        --    {name = "uid", type = T.INT},
        --    {name = "club_id", type = T.INT},
        --    {name = "level", type = T.SHORT},
        --    {name = "is_start", type = T.BYTE},
        --    {name = "player_total", type = T.BYTE},
        --    {name = "table_info", type = T.STRING},
        --    {name = "player_num", type = T.BYTE},
        --    fmt = {
        --
        --    }
        --}

    }
}
P.B2A_HALL_GAME_PLAY_TO_SERVER = 0x587 --更新联盟玩法桌子信息
SERVER[P.B2A_HALL_GAME_PLAY_TO_SERVER] ={
    ver = 1,
    fmt = {

        {name = "club_id", type = T.INT},
        {name = "configId", type = T.INT},
        {name = "gameType", type = T.INT},
        {name = "table_info", type = T.STRING},
        {name = "type", type = T.BYTE},
        {name = "name", type = T.STRING},
    }
}
P.TABLE_DATA_NEW = 0x175 --单个返回信息
SERVER[P.TABLE_DATA_NEW] ={
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT},
        --{name = "table_num", type = T.BYTE},
        --{name = "countNumber", type = T.BYTE},
        {name = "isFlag", type = T.INT},
        {name = "table_id", type = T.INT},
        {name = "level", type = T.INT},
        {name = "id", type = T.INT},
        {name = "gameType", type = T.INT},
        {name = "currRound", type = T.INT},
        {name = "player_num", type = T.BYTE},
        {name = "user_list", type = T.ARRAY, fixedLengthParser = "player_num", fixedLength = 0,
          fmt = {
              {name = "userinfo", type = T.STRING},
          }
        },
         --{name = "table_info", type = T.STRING},
        {name = "groupName", type = T.STRING},
        {name = "m_strInviteCode", type = T.STRING},
    }
}

P.TABLE_DATA_NEW_TEMP = 0x176 --这个是假桌子
SERVER[P.TABLE_DATA_NEW_TEMP] ={
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT},
        {name = "isFlag", type = T.INT},
        {name = "table_id", type = T.INT},
        {name = "level", type = T.INT},
        {name = "id", type = T.INT},
        {name = "gameType", type = T.INT},
        {name = "currRound", type = T.INT},
        {name = "player_num", type = T.BYTE},
        {name = "user_list", type = T.ARRAY, fixedLengthParser = "player_num", fixedLength = 0,
         fmt = {
             {name = "userinfo", type = T.STRING},
         }
        },
        --{name = "table_info", type = T.STRING},
        {name = "groupName", type = T.STRING},
    }
}
P.SERVER_COMMAND_UPDATE_GAME_ROUND = 0x0358 --更新桌子局数
SERVER[P.SERVER_COMMAND_UPDATE_GAME_ROUND] ={
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT},
        {name = "level", type = T.SHORT},
        {name = "table_id", type = T.INT},
        {name = "currRound", type = T.INT},
    }
}
P.CLIENT_REMOVE_GROUP               = 0x155    --广播
CLIENT[P.CLIENT_REMOVE_GROUP] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --请求注销桌子

    }
}
P.SERVER_COMMAND_ERROR = 0x5001 -- 错误提示   1 加入房间失败
SERVER[P.SERVER_COMMAND_ERROR] ={
    ver = 1,
    fmt ={
        {name = "errorCode", type = T.SHORT},
    }
}
P.CLIENT_DISABLE_USER_GAME               = 0x177   --禁用某个玩家玩游戏
CLIENT[P.CLIENT_DISABLE_USER_GAME] = {
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT},   --
        {name = "ohetUid", type = T.INT},   --被禁用的玩家
        {name = "status", type = T.INT},   --1 禁用  0 开启
    }
}
P.SERVER_DISABLE_USER_GAME               = 0x177   --禁用某个玩家玩游戏
SERVER[P.SERVER_DISABLE_USER_GAME] = {
    ver = 1,
    fmt = {
        {name = "code", type = T.INT},   --禁用某个玩家玩游戏返回   1成功   0失败

    }
}

P.CLIENT_USER_GAME_STATUS               = 0x0668   --
CLIENT[P.CLIENT_USER_GAME_STATUS] = {
    ver = 1
}

P.SERVER_USER_GAME_STATUS               = 0x0668   --
SERVER[P.SERVER_USER_GAME_STATUS] = {
    ver = 1,
    fmt = {
        {name = "Level", type = T.SHORT},--游戏场等级
        {name = "tid", type = T.INT},
        {name = "activity_id", type = T.INT}, --带入活动id
        {name = "baseChip", type = T.INT}, --带入活动id
        {name = "isWatch", type = T.BYTE}, --带入活动id
    }
}

P.CLIENT_COMMAND_USER_INFO               = 0x1188   --用户登入大厅后需要发送给alloc的数据
CLIENT[P.CLIENT_COMMAND_USER_INFO] = {
    ver = 1,
    fmt = {
        {name = "latitude", type = T.STRING},-- 经度
        {name = "longitude", type = T.STRING}, --纬度
        {name = "ip", type = T.STRING}, -- ip
    }
}

P.CLIENT_COMMAND_USER_ONLINE               = 0x1189
CLIENT[P.CLIENT_COMMAND_USER_ONLINE] = {
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT}, --俱乐部id

    }
}

P.SERVER_CMD_TABLE_COUNT               = 0x178   --//统计桌子数量
SERVER[P.SERVER_CMD_TABLE_COUNT] = {
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT}, --俱乐部id
        {name = "tableSum", type = T.INT}, --桌子数
    }
}
P.CLIENT_CMD_JOIN_TABLE               = 0x179   --//快速加入
CLIENT[P.CLIENT_CMD_JOIN_TABLE] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT}, --游戏level
        {name = "club_id", type = T.INT}, --俱乐部id
        {name = "configId", type = T.INT}, --玩法id
    }
}
P.CLIENT_COMMAND_ONLINE               = 0x188   --//获取在线用户
CLIENT[P.CLIENT_COMMAND_ONLINE] = {
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT}, --俱乐部id
        {name = "page", type = T.INT}, --
        {name = "num", type = T.INT}, --
    }
}
P.SERVER_COMMAND_ONLINE               = 0x188   --//获取在线用户
SERVER[P.SERVER_COMMAND_ONLINE] = {
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT}, --俱乐部id
        {name = "uid", type = T.INT}, --        uid
        {name = "status", type = T.INT}, --    是否在线  0 在线  
        {name = "nickName", type = T.STRING}, --        用户名
        {name = "portrait", type = T.STRING}, --        头像
    }
}
P.SERVER_COMMAND_ONLINE_END               = 0x189   --//获取在线用户结束
SERVER[P.SERVER_COMMAND_ONLINE_END] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --
    }
}
P.CLINET_CMD_ENET_GAME               = 0x190   --//邀请在线玩家
CLIENT[P.CLINET_CMD_ENET_GAME] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --俱乐部id
        {name = "club_id", type = T.INT}, --
        {name = "tid", type = T.INT}, --
        {name = "activityId", type = T.INT}, --
        {name = "level", type = T.INT}, --
        {name = "nickName", type = T.STRING}, --
        {name = "portrait", type = T.STRING}, --
        {name = "config", type = T.STRING}, --
    }

}
P.SERVER_CMD_ENET_GAME               = 0x190   --//返回邀请在线玩家
SERVER[P.SERVER_CMD_ENET_GAME] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --俱乐部id
        {name = "club_id", type = T.INT}, --
        {name = "tid", type = T.INT}, --
        {name = "activityId", type = T.INT}, --
        {name = "level", type = T.INT}, --
        {name = "nickName", type = T.STRING}, --
        {name = "portrait", type = T.STRING}, --
        {name = "config", type = T.STRING}, --
    }

}

P.B2A_HALL_SEND_PLAYER_MSG_TO_SERVER               = 0x169   --//返回接口消息
SERVER[P.B2A_HALL_SEND_PLAYER_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "club_id", type = T.INT}, --俱乐部id
        {name = "str", type = T.STRING}, -- json需要解析的数据
    }

}
P.SERVER_CMD_JOIN_TABLE               = 0x179   --//快速加入
SERVER[P.SERVER_CMD_JOIN_TABLE] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT}, --游戏level
        {name = "club_id", type = T.INT}, --俱乐部id
        {name = "configId", type = T.INT}, --玩法id
    }
}
return HALL_PROTOCOL
