--[[
* author:   zwm
* date:     2019-04-11
* describe: 跑的块主场景
--]]

local zixidadungameScene = class("zixidadungameScene", function()
    return display.newScene()
end)
TpackageName = "zixidadun"
local zixidadunServer = import(TpackageName .. ".src.protocol.zixidadunServer")
local zixidadunHandle = import(TpackageName .. ".src.protocol.zixidadunHandle")
local PROTOCOL  = require(TpackageName .. ".src.protocol.zixidadunProtocol")
local zixidadunDefine = require(TpackageName .. ".src.logic.zixidadunDefine")

function zixidadungameScene:ctor()
    print("zixidadungameScene:ctor------------------",TpackageName, debug.traceback())
    dump(USER_INFO)
    self:initProtocol()
    zixidadunDefine:initGlobalData()
    self.roomConfigure = {}
    self.myHandlerCards = {}
    self.prevOutCards = {} -- 保存上次的出牌
    self.prevOutCardType = 0
    self:loadAllLayer()
    g_mainScene = self
    g_zxddGameData = require("zixidadun.src.data.GameData").new()
    local faceUI = require("hall.FaceUI.faceUI")
    local faceUI_node = faceUI.new();
    faceUI_node:setHandle(bm.server:getHandle())
    g_mainScene:addChild(faceUI_node, 9999)
    faceUI_node:setName("faceUI")
    SCENENOW["scene"].GameRound=0
    --显示表情符号
    local idx = ViewBase:getZOrderByChilds(self)
    local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), self)
    EmojiArmatureView:setLocalZOrder(idx)

    -- display.loadSpriteFrames("zixidadun/res/image/cards/cards.plist","zixidadun/res/image/cards/cards.png")
    -- loadSpriteFrames
    local FrameCache = cc.SpriteFrameCache:getInstance()
    FrameCache:addSpriteFrames("zixidadun/res/image/cards/cards.plist", "zixidadun/res/image/cards/cards.png")

    g_mainScene.userInfoByViewId = {}
    
end

function zixidadungameScene:onEnter()
     local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    zixidadunServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
    HEART_BEAT_TID = USER_INFO["tid"]
    cc.SimpleAudioEngine:getInstance():playMusic("zixidadun/res/audio/bgm.mp3",true)
end

function zixidadungameScene:initProtocol()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(zixidadunHandle.new())

end

function zixidadungameScene:initGameConfigData(configStr)
    self._gameConfingStr = configStr
    local data = json.decode(configStr)
    self:initRoomConfigure(data or {})
    self.tableLayer:setWanfaDes(data.wanfa)
end

function zixidadungameScene:initRoomConfigure(data)
    local canPick = string.split(data.canPick, ",");
    self.roomConfigure.mustTakeForEnd = self:_findCanPick(canPick, 8) --8表示 带牌出的牌型，最后出的牌必须带够数量
    self.roomConfigure.canBombTake    = self:_findCanPick(canPick, 5) --5表示 有4带3的类型
    self.roomConfigure.threeAIsBomb   = self:_findCanPick(canPick, 7) --7表示 3个A算最大炸弹
    self.gameConfigTable = data
    if data.dis_agree and data.dis_agree == 3 then
        self:hideDisbandBtn()
    end
end

function zixidadungameScene:_findCanPick(lst, value)
    for i, v in ipairs( lst or {} ) do
        if tonumber(v) == value then
            return true
        end
    end

    return false
end

function zixidadungameScene:loadAllLayer()
    self.tableLayer = self:loadLayerByName(TpackageName .. ".src.view.TableLayer", 1)
    self.playerInfoLayer = self:loadLayerByName(TpackageName .. ".src.view.PlayerInfoLayer", 2)
    self.roomCommonLayer = self:loadLayerByName(TpackageName ..".src.view.RoomCommonZXDDLayer", 3, self:getToDisbandFuncs())
    self.gameMsgLayer = self:loadLayerByName("hall.roomCommonUI.GameMsgLayer", 5, self:getToSendFaceAndTxtFuncs())
    self.gameMsgLayer:setVisible(false)
    self.tgLayer = self:loadLayerByName(TpackageName .. ".src.view.tgLayer", 999)
end


function zixidadungameScene:getToDisbandFuncs()
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


function zixidadungameScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end

function zixidadungameScene:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = self:loadLayerByName("hall.roomCommonUI.GameMoreFuncLayer", 4)
        if self.gameConfigTable and self.gameConfigTable.dis_agree and self.gameConfigTable.dis_agree == 3 then
            self:hideDisbandBtn()
        end
    else
        if 0 == SCENENOW["scene"].GameRound then
            self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        else
            if self.gameConfigTable and self.gameConfigTable.dis_agree and self.gameConfigTable.dis_agree == 3 then
                self:hideDisbandBtn()
            else
                self.moreFuncLayer.btnDisbandRoom:setVisible(true)
            end
        end
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
end

function zixidadungameScene:hideDisbandBtn()
    if self.moreFuncLayer then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    end
end

function zixidadungameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function zixidadungameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        dump("gameMsgLayer====")

    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function zixidadungameScene:loadLayerByName(path, zOrder, data)
    if path == nil then
        print("zixidadungameScene:loadLayerByName [path] is nil ----------------------")
    end
    zOrder = zOrder == nil and self:getChildrenCount() + 1 or zOrder
    dump(path)
    dump(data)
    local layer = require(path).new(data)
    print("======layer==zOrder=====",zOrder)
    if not tolua.isnull(layer) then
        print("======111111111111======")
        layer:addTo(self, zOrder)
    end
    print("======111111111111======")
    return layer
end

function zixidadungameScene:sendFaceByIdx(id, msgType, to_uid)
    zixidadunServer:CLI_MSG_FACE(id, msgType, to_uid)
end

function zixidadungameScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end

function zixidadungameScene:quitRoom()

    print ("quitRoom" , SCENENOW["scene"].GameRound)
    if  SCENENOW["scene"].GameRound ~= 0 then
        local paras = {type = 1, title = "提示", content = "游戏中不能退出！！！"}
        local tempNode =  require("hall.tips.CommonTips").new(paras)
        self:addChild(tempNode,9999999)
        return 
    end
    zixidadunServer:quitRoom()
end

function zixidadungameScene:disbandRoom()
    print("send disband msg --------------")
    zixidadunServer:C2G_CMD_DISSOLVE_ROOM()



end

function zixidadungameScene:rejectDisband()
    zixidadunServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function zixidadungameScene:agreeDisband()
    zixidadunServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function zixidadungameScene:showAllResultLayer(data)
    -- data = SVR_GROUP_BILLBOARD
    -- data['activity_id'] = USER_INFO['activity_id']
    -- print("showAllResultLayer ----------------------")
    -- dump(data)
    -- if data.playercount == 0 then 
    --     print("=======data===data.playercount===",data.playercount)
    --     require("hall.tips.CommonTips"):_gameToHall()
    --     return 
    -- end
    -- self.allResultLayer = self:loadLayerByName("hall.roomCommonUI.CommonEndResult", 5, self:getShowResultData(data))
    self.allResultLayer = self:loadLayerByName("zixidadun.src.view.TotalResultLayer", 50, data.playerlist)
    -- local singleLayer = require("zixidadun.src.view.SingleResultLayer").new(info.playerList)
    -- if singleLayer then
    --     singleLayer:setName("singleResultLayer")
    --     singleLayer:setLocalZOrder(20)
    --     g_mainScene:addChild(singleLayer)
    -- end
end

function  zixidadungameScene:showSelectCardsLayer()
    self.selectCardsLayer = self:loadLayerByName("zixidadun.src.view.SelectCardsLayer", 51, {})
end

function zixidadungameScene:getShowResultData(data)
    local result = {}
    result.user_mount = data.playercount
    result.activity_id = data.activity_id
    result.playerlist = {}
    local winIdx = 1
    local winScore = 0 

    for i, v in ipairs( data.playerlist or {} ) do
        if v.chips > winScore then
            winIdx = i
        end
        local tmp = {}
        tmp.uid = v.uid
        tmp.score = v.chips
        tmp.isMaxWin = false
        tmp.sex = v.sex
        tmp.nickName = v.nickName
        tmp.portrait = v.portrait
        tmp.match_mount = v.gameCount
        tmp.matchlist= {}
        for j, v2 in ipairs( v.eachScores ) do
            local sTmp = {}
            sTmp.matchScore = v2
            table.insert(tmp.matchlist, sTmp)
        end
        -- tmp.matchlist = v.eachScores
        table.insert(result.playerlist, tmp)
    end

    if result.playerlist[winIdx] then
        result.playerlist[winIdx].isMaxWin = true
    end

    return result 
end
function zixidadungameScene:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function zixidadungameScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(zixidadunHandle.new())
    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    zixidadunServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
end
function zixidadungameScene:onExit()
    --g_mainScene = nil
    --zixidadunDefine:clearGlobalData()
    -- print ("zixidadungameScene_onExit")
    --退出跑得快移除时间定时器
    self.roomCommonLayer:DeleteTimer()
end

return zixidadungameScene