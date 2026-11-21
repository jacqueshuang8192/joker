

local xhdzgameScene = class("xhdzgameScene", function()
    return display.newScene()
end)

local xhdzServer = import(TpackageName .. ".src.protocol.xhdzServer")
local xhdzHandle = import(TpackageName .. ".src.protocol.xhdzHandle")
local PROTOCOL  = require(TpackageName .. ".src.protocol.xhdzProtocol")
local xhdzDefine = require(TpackageName .. ".src.logic.xhdzDefine")

function xhdzgameScene:ctor()
    print("xhdzgameScene:ctor------------------",TpackageName, debug.traceback())
    dump(USER_INFO)
    self:initProtocol()
    xhdzDefine:initGlobalData()
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

    --显示表情符号
    local idx = ViewBase:getZOrderByChilds(self)
    local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), self)
    EmojiArmatureView:setLocalZOrder(idx)

    g_mainScene.userInfoByViewId = {}
end

function xhdzgameScene:onEnter()
     local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    xhdzServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
    HEART_BEAT_TID = USER_INFO["tid"]
    cc.SimpleAudioEngine:getInstance():playMusic("xinhuadazha/res/audio/bgm.mp3",true)
end

function xhdzgameScene:initProtocol()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(xhdzHandle.new())

end

function xhdzgameScene:initGameConfigData(configStr)
    self._gameConfingStr = configStr
    local data = json.decode(configStr)
    self:initRoomConfigure(data or {})
    self.tableLayer:setWanfaDes(data.canPick)
    dump(data,"xhdzgameScene:initGameConfigData")
    self.playerInfoLayer.showCardCount = tonumber(data.showCount) == 1 or false
end

function xhdzgameScene:initRoomConfigure(data)
    local canPick = string.split(data.canPick, ",");
    self.roomConfigure.mustTakeForEnd = self:_findCanPick(canPick, 8) --8表示 带牌出的牌型，最后出的牌必须带够数量
    self.roomConfigure.canBombTake    = self:_findCanPick(canPick, 5) --5表示 有4带3的类型
    self.roomConfigure.threeAIsBomb   = self:_findCanPick(canPick, 7) --7表示 3个A算最大炸弹
    self.gameConfigTable = data
    if data.dis_agree and data.dis_agree == 3 then
        self:hideDisbandBtn()
    end
end

function xhdzgameScene:_findCanPick(lst, value)
    for i, v in ipairs( lst or {} ) do
        if tonumber(v) == value then
            return true
        end
    end

    return false
end

function xhdzgameScene:loadAllLayer()
    self.tableLayer = self:loadLayerByName(TpackageName .. ".src.view.TableLayer", 1)
    self.playerInfoLayer = self:loadLayerByName(TpackageName .. ".src.view.PlayerInfoLayer", 2)
    self.roomCommonLayer = self:loadLayerByName("hall.roomCommonUI.RoomCommonPDKLayer", 3, self:getToDisbandFuncs())
    self.gameMsgLayer = self:loadLayerByName("hall.roomCommonUI.GameMsgLayer", 5, self:getToSendFaceAndTxtFuncs())
    self.gameMsgLayer:setVisible(false)
    self.tgLayer = self:loadLayerByName(TpackageName .. ".src.view.tgLayer", 999)

    self.roomCommonLayer.btnChange:setVisible(false)
end

function xhdzgameScene:getToDisbandFuncs()
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

function xhdzgameScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end

function xhdzgameScene:loadMoreFuncLayer()
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
        --把解散按钮直接隐藏掉  闲游平台需要隐藏
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)

        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
    if 0 == SCENENOW["scene"].GameRound then
        self.moreFuncLayer.btnQuitRoom:getChildByName("quitDes"):setString("退出房间")
        self.moreFuncLayer.btnQuitRoom.title = nil
        self.moreFuncLayer.btnQuitRoom.content = nil
    else
        self.moreFuncLayer.btnQuitRoom:getChildByName("quitDes"):setString("投降")
        self.moreFuncLayer.btnQuitRoom.title = "投降"
        self.moreFuncLayer.btnQuitRoom.content = "确定要投降?"
    end
end

function xhdzgameScene:hideDisbandBtn()
    if self.moreFuncLayer then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    end
end

function xhdzgameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function xhdzgameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        dump("gameMsgLayer====")

    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function xhdzgameScene:loadLayerByName(path, zOrder, data)
    if path == nil then
        print("xhdzgameScene:loadLayerByName [path] is nil ----------------------")
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

function xhdzgameScene:sendFaceByIdx(id, msgType, to_uid)
    xhdzServer:CLI_MSG_FACE(id, msgType, to_uid)
end

function xhdzgameScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end

function xhdzgameScene:quitRoom()

    print ("quitRoom" , SCENENOW["scene"].GameRound)
    if SCENENOW["scene"].GameRound ~= 0 then
        if SCENENOW["scene"].isTouxiang then
            local paras = {type = 1, title = "提示", content = "一局只能投降一次！！！"}
            local tempNode =  require("hall.tips.CommonTips").new(paras)
            self:addChild(tempNode,9999999)
        else
            xhdzServer:C2G_CMD_APPLY_SURRENDER()
            SCENENOW["scene"].isTouxiang = true
        end
    else
        xhdzServer:quitRoom()
    end
end

function xhdzgameScene:disbandRoom()
    print("send disband msg --------------")
    xhdzServer:C2G_CMD_DISSOLVE_ROOM()



end

function xhdzgameScene:rejectDisband()
    xhdzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function xhdzgameScene:agreeDisband()
    xhdzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function xhdzgameScene:showAllResultLayer(data)

    dump(data,"xhdzgameScene:showAllResultLayer")

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
    self.allResultLayer = self:loadLayerByName("xinhuadazha.src.view.TotalResultLayer", 50, data.playerlist)
    -- local singleLayer = require("pdk.src.view.SingleResultLayer").new(info.playerList)
    -- if singleLayer then
    --     singleLayer:setName("singleResultLayer")
    --     singleLayer:setLocalZOrder(20)
    --     g_mainScene:addChild(singleLayer)
    -- end
end

function  xhdzgameScene:showSelectCardsLayer()
    self.selectCardsLayer = self:loadLayerByName("xinhuadazha.src.view.SelectCardsLayer", 51, {})
end

function xhdzgameScene:getShowResultData(data)
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
function xhdzgameScene:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function xhdzgameScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(xhdzHandle.new())
    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    xhdzServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
end
function xhdzgameScene:onExit()
    --g_mainScene = nil
    --xhdzDefine:clearGlobalData()
    -- print ("xhdzgameScene_onExit")
    --退出新化打炸移除时间定时器
    self.roomCommonLayer:DeleteTimer()
end

return xhdzgameScene