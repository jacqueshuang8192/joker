local SanGongSendHandle = class('SanGongSendHandle')
local PROTOCOL = import(TpackageName .. '.handle.SanGongProtocol')

function SanGongSendHandle:ctor()
end

--登陆游戏 113 服务器会返回210消息
function SanGongSendHandle:enterGroupRoom(Level, Chip, Sid, activity_id)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter('level', Level)
        :setParameter('Chip', Chip)
        :setParameter('Sid', Sid)
        :setParameter('activity_id', activity_id):build()
    bm.server:send(pack)
end

-- 113 服务器会返回210消息
function SanGongSendHandle:enterRoom(level)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter('level', level)
        :setParameter('Chip', 0)
        :setParameter('Sid', 0)
        :setParameter('activity_id', '')
        :build()
    bm.server:send(pack)
end

--1001 登陆桌子
function SanGongSendHandle:LoginRoom(tid, seatId, activityId)
    local latitude = '0.00'
    local longitude = '0.00'
    local groupId = USER_INFO['family_id']
    if type(USER_INFO['family_id']) == 'nil' then
        groupId = -1
    else
        groupId = tonumber(USER_INFO['family_id'])
    end
    local otherInfoTable = {
        ['city'] = USER_INFO['LocalCity'] or '',
        ['club_id'] = groupId,
        ['addres'] = USER_INFO.addres,
        ['ip'] = USER_INFO.ip
    }

    if device.platform == 'ios' then
        latitude = cct.getDataForApp('getLatitude', {}, 'string')
        longitude = cct.getDataForApp('getLongitude', {}, 'string')
    elseif device.platform == 'android' then
        local args = {}
        local sigs = '()Ljava/lang/String;'
        local luaj = require 'cocos.cocos2d.luaj'
        local className = luaJniClass

        local ok, ret = luaj.callStaticMethod(className, 'getLongitude', args, sigs)
        if not ok then
            print('luaj error:', ret)
        else
            longitude = ret
        end

        ok, ret = luaj.callStaticMethod(className, 'getLatitude', args, sigs)
        if not ok then
            print('luaj error:', ret)
        else
            latitude = ret
        end
    elseif device.platform == 'windows' then
        latitude = '10.00'
        longitude = '10.00'
    end
    otherInfoTable['latitude'] = latitude or '0.0.0.0'
    otherInfoTable['longitude'] = longitude or '0.0.0.0'
    USER_INFO.latitude = latitude or '0'
    USER_INFO.longitude = longitude or '0'
    local otherInfo = json.encode(otherInfoTable)
    seatId = seatId or -1

    local activityId = activityId or USER_INFO['activity_id']
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
        :setParameter('tid', tid)
        :setParameter('uid', USER_INFO['uid'])
        :setParameter('sex', USER_INFO['sex'])
        :setParameter('nickName', USER_INFO['nick'])
        :setParameter('portrait', USER_INFO['icon_url'])
        :setParameter('latitude', latitude)
        :setParameter('longitude', longitude)
        :setParameter('otherInfo', otherInfo)
        :setParameter('activityId', activityId)
        :setParameter('city', '广州')
        :setParameter('ip', USER_INFO.ip)
        :setParameter('isWatch', USER_INFO.isWatch)
        :build()
    bm.server:send(pack)
end

--请求录纸1035
function SanGongSendHandle:CLI_REQUEST_LUZHI()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LUZHI):build()
    bm.server:send(pack)
end

--请求带控
function SanGongSendHandle:CLIENT_CMD_REQ_TEST()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_REQ_TEST):build()
    bm.server:send(pack)
end

--带控
function SanGongSendHandle:CLIENT_CMD_TEST(seat, rank)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_TEST)
        --:setParameter("seat", seat)
        :setParameter('rank', rank)
        :build()
    bm.server:send(pack)
end

--外围请求下注1040
function SanGongSendHandle:CLI_REQUEST_BET(seat, betChip)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_BET)
        :setParameter('seat', seat)
        :setParameter('betChip', betChip)
        :build()
    bm.server:send(pack)
end

--请求查看下注情况1037
function SanGongSendHandle:CLIENT_CMD_REQ_YAZHU_INFO()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_REQ_YAZHU_INFO):build()
    bm.server:send(pack)
end

--坐下
function SanGongSendHandle:sitDown(seatId)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter('seat', seatId)
        :build()
    bm.server:send(pack)
end

--站起
function SanGongSendHandle:standUp()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP):build()
    bm.server:send(pack)
end

--退出房间
function SanGongSendHandle:quitRoom()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM):build()
    bm.server:send(pack)
end

--请求托管
function SanGongSendHandle:requestAutoPlay(isOpenAuto)
    grab_times = grab_times or 1
    bet_times = bet_times or 1

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_AUTO_PLAY)
        :setParameter('isOpenAuto', isOpenAuto)
        :build()
    bm.server:send(pack)
end

--开始游戏
function SanGongSendHandle:StartGame()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_START_GAME):build()
    bm.server:send(pack)
end

--请求获取服务器筹码
function SanGongSendHandle:getChips()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
        :setParameter('uid', USER_INFO['uid'])
        :build()
    bm.server:send(pack)
end

--用户发送准备
function SanGongSendHandle:readyNow(readyState)
    readyState = readyState or 1
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
        :setParameter('readyState', readyState)
        :build()
    bm.server:send(pack)
    -- if GROUP_MODE == 2 then
    --     local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
    --         :setParameter("readyState",readyState)
    --         :build()
    --     bm.server:send(pack)
    -- else
    --     local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
    --         :build()
    --     bm.server:send(pack)
    -- end
end

--抢庄
function SanGongSendHandle:qiang(value)
    local value = tonumber(value) or 1
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QIANGZHUANG)
        :setParameter('if_qiang', value)
        :build()
    bm.server:send(pack)
end

--加倍倍数
function SanGongSendHandle:addBase(base)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_USER_BASES)
        :setParameter('bases', base)
        :build()
    bm.server:send(pack)
end

--发送牌数据
function SanGongSendHandle:sendMycards(cards)
    local tmp = {}

    for i, v in ipairs(cards) do
        local tmp_c = {}
        tmp_c['card'] = 0
        table.insert(tmp, tmp_c)
    end

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_OUT_CARD)
        -- :setParameter("mount", #tmp)
        -- :setParameter("cards",tmp)
        :build()
    bm.server:send(pack)
end

--发送牌数据
function SanGongSendHandle:sendMycards_no()
    local tmp = {}
    local ik = 1
    local kkk = {7, 11, 28}
    for i, v in pairs(bm.Room.Mychoice) do
        local tmp_c = {}
        tmp_c['card'] = kkk[ik]
        table.insert(tmp, tmp_c)
        ik = ik + 1
    end

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
        :setParameter('mount', #tmp)
        :setParameter('cards', tmp)
        :build()
    bm.server:send(pack)
end

--解散相关
--请求解散房间
function SanGongSendHandle:C2G_CMD_DISSOLVE_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM):build()
    bm.server:send(pack)
end

--回复请求解散房间
function SanGongSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
        :setParameter('agree', agree)
        :build()
    bm.server:send(pack)
end

--聊天相关
function SanGongSendHandle:CLI_MSG_FACE(id, msgType, to_uid)
    if not msgType then
        msgType = 'emoji'
    end
    local data = {
        msgType = msgType,
        type = id,
        uid = USER_INFO['uid'],
        to_uid = to_uid
    }
    local msg = json.encode(data)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
        :setParameter('level', USER_INFO['GroupLevel'])
        :setParameter('msg', msg)
        :build()
    bm.server:send(pack)
end

--发送组局信息
function SanGongSendHandle:SendGameMsg(level, msg)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
        :setParameter('level', level)
        :setParameter('msg', msg)
        :build()
    bm.server:send(pack)
end

--发送距离等信息
function SanGongSendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)
    local latitude = '0.00'
    local longitude = '0.00'
    local msg = {}

    if device.platform == 'ios' then
        latitude = cct.getDataForApp('getLatitude', {}, 'string')
        longitude = cct.getDataForApp('getLongitude', {}, 'string')
    elseif device.platform == 'android' then
        local args = {}
        local sigs = '()Ljava/lang/String;'
        local luaj = require 'cocos.cocos2d.luaj'
        local className = luaJniClass

        local ok, ret = luaj.callStaticMethod(className, 'getLongitude', args, sigs)
        if not ok then
            print('luaj error:', ret)
        else
            longitude = ret
        end

        ok, ret = luaj.callStaticMethod(className, 'getLatitude', args, sigs)
        if not ok then
            print('luaj error:', ret)
        else
            latitude = ret
        end
    elseif device.platform == 'windows' then
        latitude = '10.00'
        longitude = '10.00'
    end

    local level = USER_INFO['GroupLevel']
    msg['ip'] = ip
    msg['uid'] = USER_INFO['uid']
    msg['nickName'] = USER_INFO['nick']
    msg['latitude'] = latitude
    msg['longitude'] = longitude
    msg['invote_code'] = USER_INFO['invote_code']
    msg = json.encode(msg)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
        :setParameter('level', level)
        :setParameter('msg', msg)
        :build()
    bm.server:send(pack)
end

function SanGongSendHandle:CLIENT_CMD_YA(uid, zhu)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_YA)
        :setParameter('uid', uid)
        :setParameter('zhu', zhu)
        :build()
    bm.server:send(pack)
end

function SanGongSendHandle:CLIENT_CMD_REQ_YAZHU_DETAILS(seat)
    local pack = bm.server:createPacketBuilder(PROTOCOL.SERVER_CMD_REQ_YAZHU_DETAILS)
        :setParameter('seat', seat)
        :build()
    bm.server:send(pack)
end

function SanGongSendHandle:CLIENT_CMD_GIVE_COINS(desUid, coins)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_GIVE_COINS)
        :setParameter('desUid', desUid)
        :setParameter('coins', coins)
        :build()
    bm.server:send(pack)
end

function SanGongSendHandle:CLI_COMMAND_GAMERESULT_RECORD(resultIndex)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_COMMAND_GAMERESULT_RECORD)
        :setParameter('resultIndex', resultIndex)
        :build()
    bm.server:send(pack)
end

return SanGongSendHandle
