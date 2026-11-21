--[[
* author:   zwm
* date:     2019-04-11
* describe: 跑的块主场景
--]]

local YJQFgameScene = class("YJQFgameScene", function()
    return display.newScene()
end)

local YJQFServer = import(TpackageName .. ".src.protocol.YJQFServer")
local YJQFHandle = import(TpackageName .. ".src.protocol.YJQFHandle")
local PROTOCOL  = require(TpackageName .. ".src.protocol.YJQFProtocol")
local YJQFDefine = require(TpackageName .. ".src.logic.YJQFDefine")

function YJQFgameScene:ctor()
    print("YJQFgameScene:ctor------------------",TpackageName, debug.traceback())
    dump(USER_INFO)
    self:initProtocol()
    YJQFDefine:initGlobalData()
    self.roomConfigure = {}
    self.myHandlerCards = {}
    self.prevOutCards = {} -- 保存上次的出牌
    self.prevOutCardType = 0
    self:loadAllLayer()
    g_mainScene = self
    local faceUI = require("hall.FaceUI.faceUI")
    local faceUI_node = faceUI.new();
    faceUI_node:setHandle(bm.server:getHandle())
    g_mainScene:addChild(faceUI_node, 9999)
    faceUI_node:setName("faceUI")
    g_mainScene.userInfoByViewId = {}

end

function YJQFgameScene:onEnter()
     local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    YJQFServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
    HEART_BEAT_TID = USER_INFO["tid"]

end

function YJQFgameScene:initProtocol()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(YJQFHandle.new())

end

function YJQFgameScene:initGameConfigData(configStr)
    local data = json.decode(configStr)
    self._roomConfigStr = configStr
    self:initRoomConfigure(data or {})
end

function YJQFgameScene:initRoomConfigure(data)
    local canPick = string.split(data.canPick, ",");
    -- self.roomConfigure.mustTakeForEnd = self:_findCanPick(canPick, 8) --8表示 带牌出的牌型，最后出的牌必须带够数量
    -- self.roomConfigure.canBombTake    = self:_findCanPick(canPick, 5) --5表示 有4带3的类型
    -- self.roomConfigure.threeAIsBomb   = self:_findCanPick(canPick, 7) --7表示 3个A算最大炸弹
end

function YJQFgameScene:_findCanPick(lst, value)
    for i, v in ipairs( lst or {} ) do
        if tonumber(v) == value then
            return true
        end
    end

    return false
end

function YJQFgameScene:loadAllLayer()
    self.tableLayer = self:loadLayerByName(TpackageName .. ".src.view.TableLayer", 1)
    self.playerInfoLayer = self:loadLayerByName(TpackageName .. ".src.view.PlayerInfoLayer", 2)
    self.roomCommonLayer = self:loadLayerByName("hall.roomCommonUI.RoomCommonPDKLayer", 3, self:getToDisbandFuncs())
    self.gameMsgLayer = self:loadLayerByName("hall.roomCommonUI.GameMsgLayer", 5, self:getToSendFaceAndTxtFuncs())
    self.gameMsgLayer:setVisible(false)
    self.tgLayer = self:loadLayerByName(TpackageName .. ".src.view.tgLayer", 999)
end

function YJQFgameScene:getToDisbandFuncs()
    local data = {} 
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
    data.showGameMsgLayerHandler = handler(self, self.loadGameMsgLayer)
    data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)

    return data
end

function YJQFgameScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end

function YJQFgameScene:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = self:loadLayerByName("hall.roomCommonUI.GameMoreFuncLayer", 4)
    else
        if 0 == SCENENOW["scene"].GameRound then
            self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        else
            self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
end

function YJQFgameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function YJQFgameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        dump("gameMsgLayer====")

    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function YJQFgameScene:loadLayerByName(path, zOrder, data)
    if path == nil then
        print("YJQFgameScene:loadLayerByName [path] is nil ----------------------")
    end
    zOrder = zOrder == nil and self:getChildrenCount() + 1 or zOrder
    local layer = require(path).new(data)
    print("======layer==zOrder=====",zOrder)
    if not tolua.isnull(layer) then
        print("======111111111111======")
        layer:addTo(self, zOrder)
    end
    print("======111111111111======")
    return layer
end

function YJQFgameScene:sendFaceByIdx(id)
    print("sendFaceMsg --------------------------", id)
    YJQFServer:CLI_MSG_FACE(id)
end

function YJQFgameScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end

function YJQFgameScene:quitRoom()

    print ("quitRoom" , SCENENOW["scene"].GameRound)
    if  SCENENOW["scene"].GameRound ~= 0 then
        local paras = {type = 1, title = "提示", content = "游戏中不能退出！！！"}
        local tempNode =  require("hall.tips.CommonTips").new(paras)
        self:addChild(tempNode,9999999)
        return 
    end
    YJQFServer:quitRoom()
end

function YJQFgameScene:disbandRoom()
    print("send disband msg --------------")
    YJQFServer:C2G_CMD_DISSOLVE_ROOM()



end

function YJQFgameScene:rejectDisband()
    YJQFServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function YJQFgameScene:agreeDisband()
    YJQFServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function YJQFgameScene:showAllResultLayer(data)
    -- data = SVR_GROUP_BILLBOARD
    data['activity_id'] = USER_INFO['activity_id']
    print("showAllResultLayer ----------------------")
    dump(data)
    if data.playercount == 0 then 
        print("=======data===data.playercount===",data.playercount)
        require("hall.tips.CommonTips"):_gameToHall()
        return 
    end
    -- self:saveUserInfo()
    self.allResultLayer = self:loadLayerByName("yuanjiangqianfen.src.view.TotalResultLayer", 5, data)
    -- self.allResultLayer:setVisible(false)
end

-- function YJQFgameScene:getShowResultData(data)
-- end

function YJQFgameScene:getShowResultData(data)
    local result = {}
    result.user_mount = data.playercount
    result.activity_id = data.activity_id or 1
    result.playerlist = {}
    local winIdx = 1
    local winScore = 0 

    for i, v in ipairs( data.playerlist or {} ) do
        if v.finalScore > winScore then
            winIdx = i
            winScore = v.finalScore
        end
        local tmp = {}
        tmp.uid = v.uid
        tmp.score = v.finalScore / 100
        tmp.isMaxWin = false
        tmp.sex = v.sex
        tmp.nickName = v.nickName
        tmp.portrait = v.portrait
        -- tmp.match_mount = v.gameCount
        tmp.matchlist= {}
        -- for j, v2 in ipairs( v.eachScores ) do
        --     local sTmp = {}
        --     sTmp.matchScore = v2
        --     table.insert(tmp.matchlist, sTmp)
        -- end
        -- tmp.matchlist = v.eachScores
        table.insert(result.playerlist, tmp)
    end

    if result.playerlist[winIdx] then
        result.playerlist[winIdx].isMaxWin = true
    end

    return result 
end
function YJQFgameScene:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function YJQFgameScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(YJQFHandle.new())
    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    YJQFServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
end
function YJQFgameScene:onExit()
    --g_mainScene = nil
    --YJQFDefine:clearGlobalData()
    -- print ("YJQFgameScene_onExit")
    --退出跑得快移除时间定时器
    self.roomCommonLayer:DeleteTimer()
end

return YJQFgameScene