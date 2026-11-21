--[[
* author:   zwm
* date:     2020-04-23
* describe: 战绩回放的基类
* explain:  主要功能，处理网络消息
--]]


local RecordBaseLayer = class("RecordBaseLayer", function()
        return display:newLayer()
    end)

local PROC_MSG_TIME = 1

local GAME_TYPE_PROTOCOL = {[366] = {protocolFile = "mzhz_majiang.handle.ZZMJPortocol", revcFile = "mzhz_majiang.handle.ZZMJReceiveHandle"},

}

function RecordBaseLayer:ctor(msgLst, cmds, gameType, bJson)
    self:setNodeEventEnabled(true)
    self._gameType = gameType
    if bJson then
        self:exChangeForJson(msgLst)
    else
        self._gameMsgLst = msgLst or {}
        self._optCmds = cmds.optCmds
        self._userInfoCmd = cmds.userInfoCmd
        self._sendCardsCmd = cmds.sendCardsCmd
        self:PacketParserALLMsg()
    end
    self._msgIndex = 1
end

function RecordBaseLayer:onEnter( ... )
    dump("2")
end

function RecordBaseLayer:loadVideoLayer()
    self._videoOptLayer = require("hall.record.RecordOptLayer").new(self)
    self._videoOptLayer:setScale(720/1080)
    self._videoOptLayer:setLocalZOrder(10000)
    self._videoOptLayer:addTo(self._scene)
end

function RecordBaseLayer:PacketParserALLMsg()
    self._allOptMsgs = {}
    self._allUserInfoMsgs = {}
    self._allHandCardsMsgs = {}
    local parserMsgs = {}

    for i, v in ipairs(self._gameMsgLst or {}) do
        local succ, msg = self:PacketParserMsg(v)
        if succ then
            for j, v2 in ipairs(msg or {}) do
                table.insert(parserMsgs, v2)
            end
        end
    end


    for i, v in ipairs(parserMsgs) do
        if v.cmd == self._userInfoCmd then
            table.insert(self._allUserInfoMsgs, v)
        elseif v.cmd == self._sendCardsCmd then
            table.insert(self._allHandCardsMsgs, v)
        elseif self:isUsefulOptCmd(v.cmd) then
            table.insert(self._allOptMsgs, v)
        end
    end

end

function RecordBaseLayer:exChangeForJson(data)
    self._allOptMsgs = {}
    self._allUserInfoMsgs = {}
    self._allHandCardsMsgs = {}
    self._allSettlements = {}

    local _msg = json.decode(data)
    dump(_msg.userinfos, "exChangeForJson == ")
    local userSize = self:getUserSize(_msg.userinfos)
    self._userSize = userSize
    if userSize == 0 then return end
    if _msg.cards then
        for i = 1, userSize do
            local cards = string.split(_msg.cards[i] or "", ",")
            local lst = {}
            for j,v in ipairs(cards or {}) do
                table.insert(lst, tonumber(v))
            end
            table.insert(self._allHandCardsMsgs, lst)
        end
    end
   

    for i = 1, userSize do 
        local userInfo = _msg.userinfos[i] or {}
        table.insert(self._allUserInfoMsgs, userInfo)
    end

    for k,v in pairs(_msg.frame or {}) do
        local exchangedMsg = self:exChangeMsgForRevc(v, self._gameType)
        if exchangedMsg then
            table.insert(self._allOptMsgs, exchangedMsg)
        end
    end

    if self._gameType == 329 or self._gameType == 394 then
         if _msg.settlements then
            for k,v in pairs(_msg.settlements or {}) do        
                table.insert(self._allSettlements, v)
            end
        end   
    end
end

function RecordBaseLayer:getUserSize(userinfos)
    if userinfos == nil then return 0 end
    return #userinfos
end

function RecordBaseLayer:exChangeMsgForRevc(msg, gameType)
    if gameType == nil then return end
    if gameType == 366 then --梅州红中宝
        return self:exChangeMsgMzhz(msg)
    else
        return msg
    end
end

function RecordBaseLayer:exChangeMsgMzhz(msg)
    return msg
end

function RecordBaseLayer:getUserInfoMsg()
    return self._allUserInfoMsgs or {}
end

function RecordBaseLayer:getAllHandCardsMsg()
    return self._allUserInfoMsgs or {}
end

function RecordBaseLayer:isUsefulOptCmd(cmd)
    for i,v in ipairs(self._optCmds or {}) do
        if cmd == v then
            return true
        end
    end
    return false
end

function RecordBaseLayer:playingNextVideo()
    if #self._allOptMsgs < self._msgIndex then return end
    local pack = self._allOptMsgs[self._msgIndex]
    if pack == nil then
        return
    end

    local _handle = bm.SocketService:getHandle()
    _handle:callFunc(pack)
    self._msgIndex = self._msgIndex + 1
end

function RecordBaseLayer:PacketParserMsg(msg)
    local packets = bm.SocketService:procForVideoMsg(msg)
    if packets == nil then
        return false
    end

    return true, packets
end

function RecordBaseLayer:initAllUsers()
    local _handle = bm.SocketService:getHandle()
    for i,v in ipairs(self._allUserInfoMsgs or {}) do
        _handle:callFunc(pack)
    end
end

function RecordBaseLayer:initUsersHandlercards()
    local _handle = bm.SocketService:getHandle()
    for i,v in ipairs(self._allHandCardsMsgs or {}) do
        _handle:callFunc(pack)
    end
end

function RecordBaseLayer:playUserOptVideo(speed)
    self:stopUserOpt()
    speed  = (speed or 1) > 3 and 3 or (speed or 1)
    speed = speed < 1/3 and 1/3 or speed
    local times = PROC_MSG_TIME/speed
    self.curSpeed = times
    self.opt_key = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.executeOptMsg), times, false)
end

function RecordBaseLayer:stopUserOpt()
    if self.opt_key then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.opt_key)
        self.opt_key = nil
    end
end

function RecordBaseLayer:executeOptMsg()
    if self._gameType == 366 or self._gameType == 308 or self._gameType == 320 or self._gameType == 329
        or self._gameType == 376 or self._gameType == 612 or self._gameType == 386 
        or self._gameType == 387 or self._gameType == 371 or self._gameType == 358 
        or self._gameType == 348 or self._gameType == 370 or self._gameType == 390 or self._gameType == 391
        or self._gameType == 393 or self._gameType == 394 or self._gameType == 399
        or self._gameType == 393 or self._gameType == 393 or self._gameType == 389 or self._gameType == 400
        then -- 麻将类的游戏另外的处理方式 战绩数据为原有的json格式
        self:playingNextVideoForMJ()
    elseif self._gameType == 375 or self.level == 342 or self.level == 353 or self.level == 618 or self.level == 611 or self.level == 359 or self.level == 379 or self.level == 396 or self.level == 392 or self.level == 388 or self.level == 398 or self.level == 345 then 
        -- 字牌的游戏另外的处理方式 战绩数据为原有的json格式
        self:playingNextVideoForMJ()
    elseif self._gameType == 325 then
        self:playingNextVideoForPDK()
    elseif self._gameType == 369 then
        self:playingNextVideoForXinYu510k()
    elseif self._gameType == 381 then
        self:playingNextVideoForTaiHe()
    elseif self._gameType == 383 then
        self:playingNextVideoForYuanJiangQianfen()
    elseif self._gameType == 374 then
        self:playingNextVideoForFSP()
    elseif self._gameType == 384 then
        self:playingNextVideoFor96()
    else

        self:playingNextVideo()
    end
end

function RecordBaseLayer:playingNextVideoForPDK()
    if #self._allOptMsgs < self._msgIndex then return end
    local pack = self._allOptMsgs[self._msgIndex]
    if pack == nil then
        return
    end
    self._msgIndex = self._msgIndex + 1

    if self.callFunc then
        self.callFunc(self, pack)
    end
end

function RecordBaseLayer:playingNextVideoForYuanJiangQianfen()
    if #self._allOptMsgs < self._msgIndex then return end
    local pack = self._allOptMsgs[self._msgIndex]
    if pack == nil then
        return
    end
    self._msgIndex = self._msgIndex + 1

    if self.callFunc then
        self.callFunc(self, pack)
    end
end
function RecordBaseLayer:playingNextVideoFor96()
    if #self._allOptMsgs < self._msgIndex then return end
    local pack = self._allOptMsgs[self._msgIndex]
    if pack == nil then
        return
    end
    self._msgIndex = self._msgIndex + 1

    if self.callFunc then
        self.callFunc(self, pack)
    end
end
function RecordBaseLayer:playingNextVideoForFSP()
    if #self._allOptMsgs < self._msgIndex then return end
    local pack = self._allOptMsgs[self._msgIndex]
    if pack == nil then
        return
    end
    self._msgIndex = self._msgIndex + 1

    if self.callFunc then
        self.callFunc(self, pack)
    end
end

function RecordBaseLayer:playingNextVideoForXinYu510k()
    if #self._allOptMsgs < self._msgIndex then return end
    local pack = self._allOptMsgs[self._msgIndex]
    if pack == nil then
        return
    end
    self._msgIndex = self._msgIndex + 1

    if self.callFunc then
        self.callFunc(self, pack)
    end
end

function RecordBaseLayer:playingNextVideoForTaiHe()
    if #self._allOptMsgs < self._msgIndex then return end
    local pack = self._allOptMsgs[self._msgIndex]
    if pack == nil then
        return
    end
    self._msgIndex = self._msgIndex + 1

    if self.callFunc then
        self.callFunc(self, pack)
    end
end

function RecordBaseLayer:playingNextVideoForMJ()
    if #self._allOptMsgs < self._msgIndex then
       return
    end

    local pack = self._allOptMsgs[self._msgIndex]
    if pack == nil then
        return
    end
    self._msgIndex = self._msgIndex + 1

    if self.callFunc then
        self.callFunc(self, pack)
    end

    --表示前面的执行数据以及播完，开始显示结算界面了
    if #self._allOptMsgs == (self._msgIndex - 1) then

        --这里是显示结算的

        if not self._allSettlements or #self._allSettlements == 0 then 
           return
        end

        local pack = self._allSettlements

        if pack == nil then
            return
        end

        pack.type = 24584  -- 对应服务的 麻将回放协议 0x6008协议 

        if self.callFunc then
            self.callFunc(self, pack)
        end

    end

end

function RecordBaseLayer:quitRecordScene()
end

function RecordBaseLayer:closeSelf()
    self:stopUserOpt()
    self:removeFromParent()
end

function RecordBaseLayer:onExit()
    self:stopUserOpt()
end

return RecordBaseLayer