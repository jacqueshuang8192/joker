
local SocketService = class("SocketService")

local PacketParser = require("src.socket.PacketParser")
local PacketBuilder = require("src.socket.PacketBuilder")
local Encrypt = require("src.socket.Encrypt")
local clockUtils = require("hall.network.ClockUtils")
local TYPE = require("src.socket.PACKET_DATA_TYPE")

local scheduler = require("framework.scheduler")


-- 包头长度
local HEAD_LEN = 18

--socket相关
local socket_
local host_
local port_
local isChat_Msg

--protocol相关
local name_
local protocol_
local game_protocol
local game_handle
local parser_

--Handle相关
local _handle

--心跳相关
local HeartNum
local reconnect_num = 0
local connectTimeTickScheduler

--socket类初始化
function SocketService:ctor(name, protocol, isChatMsg)
    print("SocketService:ctor -------------------", name, protocol, isChatMsg)
    isChat_Msg = isChatMsg
    name_ = name
    self.isConnectedCheck = true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
--socket相关

--建立Socket连接
function SocketService:connect(host, port, retryConnectWhenFailure)
    print("===== [LOG] SocketService:connect =====", "host:", host, "port:", port, "connected:", self:isConnected())

    if self:isConnected() then
        print("===== [LOG] 已经连接，跳过 =====")
        return;
    end

    host_ = host or host_
    port_ = port or port_
    local port_temp = port_
    if not socket_ then
        print("创建新Socket实例----------------")
        if device.platform ~= "windows" and IS_TONGC_DUN == 1 then
            local tablePort ={}
            if device.platform =="android" then
                table.insert(tablePort,tonumber(port_temp))
            else
                tablePort["prot"] = port_temp
            end
            --local sigs = "Ljava/lang/String;"
            --port_ = cct.getDateForApp("getHttpAddr",tablePort,sigs)
            port_temp = cct.getDataForApp("getPort", tablePort, "I")
            print("hall_port",port_temp)
        end
        socket_ = cc.net.SocketTCP.new(host_, port_temp)
        
        -- 为所有事件添加监听和打印
        local function onSocketEvent(evt)
            print("===== Socket 事件触发 =====", evt.name)
            dump(evt, "Socket 事件内容:")
        end
        
        socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, function(evt)
            print("===== EVENT_CONNECTED 事件 =====")
            self:onConnected(evt)
        end)
        socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, function(evt)
            print("===== EVENT_CLOSE 事件 =====")
            self:onClose(evt)
        end)
        socket_:addEventListener(cc.net.SocketTCP.EVENT_DATA, function(evt)
            print("===== EVENT_DATA 事件 =====")
            self:onData(evt)
        end)
        socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, function(evt)
            print("===== EVENT_CLOSED 事件 =====")
            self:onClosed(evt)
        end)
        
        -- 监听所有事件
        socket_:addEventListener("*", onSocketEvent)
    else
        print("Socket实例已经存在", "-----ScoketGame-----")
    end

    socket_:setName(name_):connect(host_, port_temp)
end

--获取socket对象
function SocketService:getSocketTCP()
    return socket_
end

--获取socket链接状态
function SocketService:isConnected()
    if socket_ then
        return socket_.isConnected
    end
    return false
end

function SocketService:onAfterConnected()
    print("socket成功连接")
end

function SocketService:netClose()
    print("socket断开")
    --self:showReloginTip()
end

--Sockey连接后
function SocketService:onConnected(evt)
    print("===== [LOG] ScoketGame:onConnected =====", "socketId:", evt.target.socketId_, evt.name)
    print("===== [LOG] host_=", host_, "port_=", port_)
    print("NEO [%d] onConnected. %s", evt.target.socketId_, evt.name)

    self:onAfterConnected()
    print("===== [LOG] onAfterConnected 返回，继续 =====")
    require(NetworkLoadingView_filePath):removeView(44)
    --停止所有旧的心跳检测
    self:unscheduleHeartBeat()
    print("===== [LOG] unscheduleHeartBeat 完成，调用 scheduleHeartBeat =====")
    --开始心跳检测
    self:scheduleHeartBeat(2)
    print("===== [LOG] scheduleHeartBeat 返回 =====")
    print("socket成功连接")
    showingReconnect = false
    beginreConnect = false
    --移除重连弹框
    SCENENOW["scene"]:removeChildByName("reconnect_tips")
    reconnect_num = 0
    print("===== [LOG] ScoketGame:onConnected 结束 =====")

end

--断开Socket连接
function SocketService:disconnect()
    parser_:reset()
    socket_:disconnect()
    socket_ = nil
end
--Socket断开
--这里有可能是服务器发过来的断开
function SocketService:onClose()
    print("===== [LOG] ScoketGame:onClose 被调用 =====")
    print("===== [LOG] 当前 host_=", host_, "port_=", port_, "isConnected:", self:isConnected())
    print("===== [LOG] reconnect_num =", reconnect_num, "beginreConnect =", beginreConnect)
    print("===== [LOG] bm.SocketFirstConnectSuccess =", bm.SocketFirstConnectSuccess)
    print("onclose---------------------", debug.traceback())
    print("socket断开")
    print("===== [LOG] 准备调用 netClose =====")
    self:netClose()
    print("===== [LOG] netClose 返回 =====")
end

function SocketService:showReloginTip()
    if  showingReconnect ~= true then
        local data = {type = 1, title = "提示", content = "离线时间过长,请手动重连？", callBackSingleSure = handler(self, self.reloginFunc)}
        require(CommonTips_filePath):showTips(data)
        showingReconnect = true
    end
end

function SocketService:reloginFunc()
    self:reConnect()
    require(NetworkLoadingView_filePath):showLoading("拼命加载中")

    showingReconnect = false

    SCENENOW["scene"]:removeChildByName("reconnect_tips")
    --if STATUS_GAME == true then
    --    print("in game ")
    --    self:reConnect()
    --    require(NetworkLoadingView_filePath):showLoading("拼命加载中")
    --    print("in game 11")
    --
    --    --查看组局记录返回
    --    local function viewReganizeHistory_callback(data)
    --
    --        dump(data, "-----重连记录数据-----")
    --        --验证返回数据
    --        local data_netData = data.netData
    --        if data_netData == nil then
    --            return
    --        end
    --
    --        --检查是否有未结束组局
    --        data_netData = json.decode(data_netData)
    --
    --        dump(data_netData.data, "-----当前用户未结束的组局-----")
    --        if next(data_netData.data) == nil  then
    --            print(" data is nil ")
    --            --没重连数据
    --            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
    --            return
    --        end
    --
    --        --有重连数据
    --        local level = tonumber(data_netData.data["level"])
    --        local tid = data_netData.data["tid"]
    --        local userId = data_netData.data["userId"]
    --        local activityId = data_netData.data["activityId"]
    --        local club_id = data_netData.data["groupId"]
    --        USER_INFO["tid"] = tonumber(tid)
    --        USER_INFO["activity_id"] = tonumber(activityId)
    --        --USER_INFO["family_id"] = tonumber(club_id)
    --
    --        print(" level tid userId " ..level.." "..tid.." "..userId )
    --        if  tid == "0" then   --当前在金币场某个分场里,退出alloc
    --            require(HallServer_filePath):logoutAlloc(level)
    --        else    --有未结束组局，进入最后一次加入的未结束组局
    --            USER_INFO["tid"] = tid
    --            dump(USER_INFO,"fgeg-----------")
    --            USER_INFO["club_id"] = {["groupId"] = USER_INFO["family_id"] ,
    --                                    ["tid"] = USER_INFO["tid"] ,
    --                                    ["activity_id"] = USER_INFO["activity_id"]}
    --            --USER_INFO["enter_code"] = enter_code[level]
    --            if  SCENENOW["scene"].reConnect then
    --                SCENENOW["scene"]:reConnect()
    --            else
    --                print("找不到游戏内重连方法！！！！")
    --            end
    --        end
    --    end
    --
    --    --查询当前用户组局历史记录
    --    dump(HttpAddr .. "/viewReganizeHistory" .. "   user:" .. USER_INFO["uid"], "-----重连操作，查询当前用户组局历史记录-----")
    --    cct.createHttRq({
    --        --url=HttpAddr .. "/viewReganizeHistory",
    --        url=HttpAddr .. "/queryUserGameStatus",
    --        date={
    --            userId = USER_INFO["uid"]
    --        },
    --        type_="POST",
    --        callBack = viewReganizeHistory_callback
    --    })
    --
    --    showingReconnect = false
    --    print("in game 22")
    --    SCENENOW["scene"]:removeChildByName("reconnect_tips")
    --
    --else
    --    print(" not in game ")
    --    self:reConnect()
    --    require(NetworkLoadingView_filePath):showLoading("拼命加载中")
    --
    --    showingReconnect = false
    --
    --    SCENENOW["scene"]:removeChildByName("reconnect_tips")
    --
    --end
end

--Socket已断开
function SocketService:onClosed(evt)
    --完全断开 --
    print("===== [LOG] ScoketGame:onClosed =====", "isConnectedCheck:", bm.server.isConnectedCheck)
    print("===== [LOG] reconnect_num:", reconnect_num, "beginreConnect:", beginreConnect)
    print("===== [LOG] SocketFirstConnectSuccess:", bm.SocketFirstConnectSuccess)
    print("oncloseed------")
    if bm.server.isConnectedCheck == false then
        print("===== [LOG] onClosed: isConnectedCheck=false, 直接 return =====")
        return
    end
    if bm.SocketFirstConnectSuccess then
        bm.netdisConnect = true
        print("===== [LOG] onClosed: netdisConnect=true =====")
        if reconnect_num == 0 then
            print("===== [LOG] onClosed: 首次重连, 调用 reConnect =====")
            self:reConnect()
        else
            if not beginreConnect then
                print("===== [LOG] onClosed: showReloginTip =====")
                self:showReloginTip()
            else
                print("===== [LOG] onClosed: beginreConnect=true, 跳过 =====")
            end
        end
    else
        print("===== [LOG] onClosed: SocketFirstConnectSuccess=false, 跳过重连 =====")
    end

end

--Socket重连
function SocketService:reConnect()

    --重连次数+1
    reconnect_num = reconnect_num + 1

    print("===== [LOG] reConnect 开始, 重连次数:", reconnect_num, "host_:", host_, "port_:", port_)

    beginreConnect = true

    if socket_ then
        --断开Socket连接
        print("disconnect")
        self:disconnect()
    end

    --建立Socket连接
    print("connect")
    self:connect()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
--心跳相关

--创建心跳包持续发送
function SocketService:scheduleHeartBeat(time)
    print("===== scheduleHeartBeat 开始 =====", time)

    HeartNum = 0

    clockUtils:init()

    --发送心跳包
    connectTimeTickScheduler = scheduler.scheduleGlobal(function()
            print("===== 心跳定时器触发 =====")
            if  bm.checknetworking ~= false then
                print("===== 发送心跳包 =====")
                --发送心跳包
                local heartPack = self:buildHeart()
                self:send(heartPack)

                clockUtils:send()

            else
                print("===== bm.checknetworking 为 false，不发送心跳 =====")
            end

        end

    , time)
    --开始检查心跳是否超时
    self:startHeart()
    print("===== scheduleHeartBeat 结束 =====")
end

--创建心跳包
function SocketService:buildHeart()

    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_LITTLE)
    --写包头，包体长度先写0
    buf:writeInt(15)--包体长度
    buf:writeStringBytes("BY")-- 魔数
    buf:writeUShort(1)-- 版本号
    buf:writeInt(0x110)                    -- 命令字
    buf:writeUShort(JAVA_DOUNIU and 0 or 1)                            -- gameid
    buf:writeUShort(JAVA_DOUNIU and 0 or 1)                            -- 业务id
    buf:writeByte(0)                              --平台ID
    buf:writeByte(0)                              --平台ID
    buf:writeInt(HEART_BEAT_TID or 0)                 -----tid

     --修改包体长度
    buf:setPos(1)
    buf:writeInt(buf:getLen()-4)
    buf:setPos(buf:getLen() + 1)

    buf = Encrypt:EncryptBuffer(buf)

    return buf
end

function SocketService:startHeart()

    if  check_networking_scheduler then
        scheduler.unscheduleGlobal(check_networking_scheduler)
    end

    check_networking_scheduler = scheduler.scheduleGlobal(

        function()

            if  bm.checknetworking ~= false then

                --print(HeartNum, "----心跳数-----")

                if HeartNum > 0 then

                    HeartNum = 0

                else
                    --断线
                    HeartNum = 0
                    if bm.server.isConnectedCheck == true then
                        --重连
                        if reconnect_num == 0 then

                            print("重连pppp")
                            self:reConnect()

                        else

                            local callfunc = cc.CallFunc:create(function()
                                self:showReloginTip()
                            end)

                            RELOGIN_TIMER = callfunc
                            SCENENOW["scene"]:runAction(RELOGIN_TIMER)

                        end
                    end


                end

            end

        end, 6)

    clockUtils:start()

end

--移除心跳检测
function SocketService:unscheduleHeartBeat()
    print("unschduleHeartBeat----------------------")

    HeartNum = 0

    --移除心跳包发送
    if connectTimeTickScheduler then
        scheduler.unscheduleGlobal(connectTimeTickScheduler)
    end

    connectTimeTickScheduler = nil
end


----------------------------------------------------------------------------------------------------------------------------------------------------------
--protocol相关

--设置protocol
function SocketService:setProtocol(protocol, isHall)


    if protocol == nil then
        return
    end

    protocol_ = protocol
    parser_ = PacketParser.new(protocol.CONFIG.SERVER, name_, isChat_Msg)
	
	--dump(protocol.CONFIG.SERVER, 'protocol')
	--print('-------setProtocol----', isHall, debug.traceback())

    if not isHall then
        game_protocol = protocol
    end
end

--获取protocol
function SocketService:getProtocol()
    return protocol_
end

--获取protocol
function SocketService:getGameProtocol()
    return game_protocol
end

--创建一个数据包
function SocketService:createPacketBuilder(cmd)

    if protocol_ ~= nil then
        return PacketBuilder.new(cmd, protocol_.CONFIG.CLIENT[cmd], name_, isChat_Msg)
    else
        error("协议不存在")
        bm.netdisConnect = false
        bm.notCheckReload = 0
        display_scene("app.scenes.MainScene")
    end

end

----------------------------------------------------------------------------------------------------------------------------------------------------------
--Handle相关

--设置handle
function SocketService:setHandle(handle, isHall)
    if handle == nil then
        return
    end
    _handle = handle

    if not isHall then
        game_handle = handle
    end
end

--获取handle
function SocketService:getHandle()
    return _handle
end

function SocketService:getGameHandle()
    return game_handle
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
--数据相关

--发送数据包
function SocketService:send(data)
    local dataLen = 0
    if type(data) == "string" then
        dataLen = #data
    elseif data and data.getLen then
        dataLen = data:getLen()
    end
    print("===== [LOG] SocketService:send =====", "len:", dataLen, "connected:", self:isConnected(), "host_:", host_, "port_:", port_)
    if data and data.getPack then
        local pack = data:getPack()
        local hex = cc.utils.ByteArray.toString(pack, 16)
        print("===== [LOG] send hex(前64字节):", string.sub(hex, 1, 64))
    end

  if self:isConnected() == true then
    if type(data) == "string" then
        print("===== 发送字符串数据 =====", string.len(data))
        socket_:send(data)
    else
        print("===== 发送数据包 =====")
        socket_:send(data:getPack())
    end
  else
    print("===== Socket未连接，不能发送 =====")
  end

end

--接收到服务端返回的数据
function SocketService:onData(evt)
    print("===== [LOG] ScoketGame onData 收到数据 =====", "len:", evt.data and #evt.data or 0)
    local rawHex = cc.utils.ByteArray.toString(evt.data, 16)
    print("===== [LOG] onData raw hex(前80字节):", string.sub(rawHex, 1, 80))
    
    --if bm.server.isConnectedCheck ==false then
    --    return
    --end
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_LITTLE)
    buf:writeBuf(evt.data)
    buf:setPos(1)
    
    local success, packets
    local ok, err = xpcall(function()
        success, packets = parser_:read(buf)
    end, function(msg)
        print("===== [ERROR] parser_:read 崩溃: " .. tostring(msg) .. " =====")
        print("===== [ERROR] traceback: " .. debug.traceback() .. " =====")
        return msg
    end)
    
    if not ok then
        print("===== [ERROR] parser_:read 异常, err=" .. tostring(err) .. " =====")
        return
    end
    
    print("===== 解析结果 =====", "success:", success, "packets count:", packets and #packets or 0)
    
    local isDump = true
    local protocol_str = "当前所在：" .. tostring(USER_INFO["joinGameName"]) .. "，当前协议下的协议号："
    if parser_.config_ ~= nil then
        for k,v in pairs(parser_.config_) do
            protocol_str = protocol_str .. string.format("%#x", tostring(k)) .. "，"
        end
    end

    if not success or packets == nil then

        dump("数据解析异常，" .. protocol_str, "-----协议解析输出-----")

        if device.platform == "windows" then
            error("数据解析异常，" .. protocol_str)
        else

            --local gameList = require(GameList_filePath):getList()
            --if gameList ~= nil and #gameList > 0 then
            --    local callback = function ()
            --        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
            --    end
            --    require("hall.groudgamemanager"):requestGroupStatus(callback)
            --else
            --    require("hall.GameCommon"):landLoading(false)
            --    display_scene("hall.hallScene", 1)
            --end

        end

    else

        if #packets > 0 then

            for i, v in ipairs(packets) do

                if v.cmd == 0x110 then
                    print("===== 收到心跳包 =====")
                    bm.server.isConnectedCheck = true
                    --接收心跳包
                    HeartNum = HeartNum + 1

                    clockUtils:receive()

                else
                    print("===== 收到协议包 =====", string.format("%#x", tostring(v.cmd)))

                    if isShowNetLog then
                        print("NEO[====PACK====][%x][%s]\n==>%s", v.cmd, table.keyof(protocol_, v.cmd), json.encode(v))
                    end
                    --接收到操作

                    --移除所有加载圈
                    --if SCENENOW["scene"]:getChildByName("loading") then
                    --    SCENENOW["scene"]:removeChildByName("loading")
                    --end
                    print("===== 调用 handle:callFunc 处理包 =====")
                    _handle:callFunc(v)

                end

            end

        else
            print("数据解析异常，" .. protocol_str .. "-----协议解析输出-----")
        end

    end

    if packets ~= nil then

        if type(sData) == "string" or type(packets) == "string" then

            protocol_str = protocol_str .. "协议解析出错，packets：" .. packets

        else

            if #packets > 0 then
                for k,v in pairs(packets) do
                    protocol_str = protocol_str .. "当前解析协议号：" .. string.format("%#x", tostring(v.cmd)) .. "，"

                    if v.cmd == 0x110 then
                        isDump = false
                    end

                end
            else
                protocol_str = protocol_str .. "没有数据，解析出空数组"
            end

        end

    else
        protocol_str = protocol_str .. "没有解析出数据"

    end

    if isDumpProtocol_str then

        if isDump then
            --dump(protocol_str, "-----协议解析输出-----")
        end

    end
end

function SocketService:procForVideoMsg(data)
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_LITTLE)
    buf:writeBuf(data)
    buf:setPos(1)

    local success, packets = parser_:read(buf)
    local isDump = true
    local protocol_str = "当前所在：" .. tostring(USER_INFO["joinGameName"]) .. "，当前协议下的协议号："
    if parser_.config_ ~= nil then
        for k,v in pairs(parser_.config_) do
            protocol_str = protocol_str .. string.format("%#x", tostring(k)) .. "，"
        end
    end

    if not success or packets == nil then
        dump("数据解析异常，" .. protocol_str, "-----协议解析输出-----")
        return nil
    end

    if packets ~= nil then

        if type(packets) == "string" then

            protocol_str = protocol_str .. "协议解析出错，packets：" .. packets
            return nil
        else

            if #packets > 0 then
                for k,v in pairs(packets) do
                    protocol_str = protocol_str .. "当前解析协议号：" .. string.format("%#x", tostring(v.cmd)) .. "，"

                    if v.cmd == 0x110 then
                        isDump = false
                    end

                end
            else
                protocol_str = protocol_str .. "没有数据，解析出空数组"
                return nil

            end

        end

    else
        protocol_str = protocol_str .. "没有解析出数据"

        return nil
    end

    return packets
end

--校验包头，并返回包体长度与命令字, 校验不通过则都返回-1
local function verifyHeadAndGetBodyLenAndCmd(buf)
    local cmd = -1
    local len = -1

    local pos = buf:getPos()
    buf:setPos(5)

    if buf:readStringBytes(2) == "BY" then
        buf:setPos(9)
        cmd = buf:readInt()
        buf:setPos(1)
        len = buf:readInt()
    end

    buf:setPos(pos)
    return cmd, len
end

--解析包的方法
function SocketService:read(buf)

    local ret = {}
    local success = true
    while true do

        if not self.buf_ then
            self.buf_ = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_LITTLE)
        else
            dump("hrehrthtr0000")
            self.buf_:setPos(self.buf_:getLen())
        end

        local available = buf:getAvailable()
        local buffLen = self.buf_:getLen()
        if available <= 0 then
            break

        else

            local headCompleted = (buffLen >= HEAD_LEN)

            --先收包头
            if not headCompleted then

                if available + buffLen >= HEAD_LEN then

                    --收到完整包头，按包头长度写入缓冲区
                    for i=1, HEAD_LEN - buffLen do
                        self.buf_:writeRawByte(buf:readRawByte())
                    end
                    headCompleted = true

                else

                    --不够完整包头，把全部内容写入缓冲区
                    for i=1, available do
                        self.buf_:writeRawByte(buf:readRawByte())
                    end
                    break

                end

            end

            if headCompleted then

                --包头已经完整，取包体长度并校验包头
                local command, bodyLen = verifyHeadAndGetBodyLenAndCmd(self.buf_)

                if bodyLen == 14 then

                    --无包体，直接返回一个只有cmd字段的table，并重置缓冲区
                    ret[#ret + 1] = { cmd = command }
                    self:reset()

                elseif bodyLen > 0 then

                    --有包体
                    available = buf:getAvailable()
                    buffLen = self.buf_:getLen()

                    if available <= 0 then
                        break

                    elseif available + buffLen >= 4 + bodyLen - HEAD_LEN then

                        -- 收到完整包，向缓冲区补齐当前包剩余字节
                        for i=1, bodyLen + 4 - HEAD_LEN do
                            self.buf_:writeRawByte(buf:readRawByte())
                        end

                        -- 开始解析
                        -- 解密
                        local debuffer = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_LITTLE)
                        if not self.isEncrypt then
                            debuffer = Encrypt:DecryptBuffer(self.buf_)
                        else
                            debuffer = self.buf_
                        end

                        -- 对解包做异常监听
                        local packet
                        xpcall(function()

                            end,function(msg)
                            local str = "zt trace:\n"..msg.."\n".."解析数据包出现了异常。协议号："..command.."\n 数据是"..cc.utils.ByteArray.toString(debuffer, 16)
                            cct.runErrorScene(str)

                        end)

                        packet = self:parsePacket_(debuffer)
                        if packet then
                            ret[#ret + 1] = packet
                        end

                        --重置缓冲区
                        self:reset()

                    else

                        --不够包体长度，全部内容写入缓冲区
                        for i=1, available do
                            self.buf_:writeRawByte(buf:readRawByte())
                        end

                        break

                    end

                else

                    -- 包头校验失败
                    return false, "PKG HEAD VERIFY ERROR, " .. cc.utils.ByteArray.toString(self.buf_, 16)

                end

            end

        end

    end

    return true, ret
end

function SocketService:parsePacket_(buf)

    buf_cache = "#[PACK_PARSE] len:" .. buf:getLen() .. " [" .. cc.utils.ByteArray.toString(buf, 16) .. "]"
    dump(buf_cache, "-----buf_cache-----")

    return nil
end

function SocketService:reset()
    self.buf_ = nil
end

return SocketService
