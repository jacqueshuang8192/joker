--[[
* author:   zwm
* date:     2019-04-11
* describe: 跑的块主场景
--]]

local PDKgameScene = class("PDKgameScene", function()
    return display.newScene()
end)

local PDKServer = import(TpackageName .. ".src.protocol.PDKServer")
local PDKHandle = import(TpackageName .. ".src.protocol.PDKHandle")
local PROTOCOL  = require(TpackageName .. ".src.protocol.PDKProtocol")
local PDKDefine = require(TpackageName .. ".src.logic.PDKDefine")

function PDKgameScene:ctor()
    print("[ANDROID] PDKgameScene:ctor START - Timestamp:", os.time())
    print("[ANDROID] PDKgameScene:ctor - self:", self)
    print("[ANDROID] PDKgameScene:ctor - TpackageName:", TpackageName)
    print("[ANDROID] PDKgameScene:ctor - Stack Trace:", debug.traceback())
    print("[ANDROID] PDKgameScene:ctor - USER_INFO dump start:")
    dump(USER_INFO, "[ANDROID] USER_INFO")
    print("[ANDROID] PDKgameScene:ctor - USER_INFO dump end")
    
    print("[ANDROID] PDKgameScene:ctor - Calling initProtocol...")
    self:initProtocol()
    print("[ANDROID] PDKgameScene:ctor - initProtocol completed")
    
    print("[ANDROID] PDKgameScene:ctor - Calling PDKDefine:initGlobalData...")
    PDKDefine:initGlobalData()
    print("[ANDROID] PDKgameScene:ctor - PDKDefine:initGlobalData completed")
    
    self.roomConfigure = {}
    self.myHandlerCards = {}
    self.prevOutCards = {} -- 保存上次的出牌
    self.prevOutCardType = 0
    
    print("[ANDROID] PDKgameScene:ctor - Calling loadAllLayer...")
    self:loadAllLayer()
    print("[ANDROID] PDKgameScene:ctor - loadAllLayer completed")
    
    print("[ANDROID] PDKgameScene:ctor - Setting g_mainScene = self:", self)
    g_mainScene = self
    print("[ANDROID] PDKgameScene:ctor - g_mainScene after assignment:", g_mainScene)
    
    print("[ANDROID] PDKgameScene:ctor - Creating faceUI...")
    local faceUI = require("hall.FaceUI.faceUI")
    local faceUI_node = faceUI.new();
    faceUI_node:setHandle(bm.server:getHandle())
    g_mainScene:addChild(faceUI_node, 9999)
    faceUI_node:setName("faceUI")
    print("[ANDROID] PDKgameScene:ctor - faceUI created and added")

    g_mainScene.userInfoByViewId = {}
    print("[ANDROID] PDKgameScene:ctor - userInfoByViewId initialized")
    
    print("[ANDROID] PDKgameScene:ctor - Creating EmojiArmatureView...")
    local ok, EmojiArmatureViewOrErr = pcall(require("hall.EmojiArmatureView.EmojiArmatureView").newEmojiArmatureView, require("hall.EmojiArmatureView.EmojiArmatureView"), self:getToSendFaceAndTxtFuncs(), self)
    if ok then
        print("[ANDROID] PDKgameScene:ctor - EmojiArmatureView created successfully")
        local idx = ViewBase:getZOrderByChilds(self)
        print("[ANDROID] PDKgameScene:ctor - ZOrder idx:", idx)
        if EmojiArmatureViewOrErr then
            EmojiArmatureViewOrErr:setLocalZOrder(idx)
        end
    else
        print("[ANDROID] PDKgameScene:ctor - EmojiArmatureView creation FAILED:", EmojiArmatureViewOrErr)
    end
    print("[ANDROID] PDKgameScene:ctor END - EmojiArmatureView creation attempted")
end

function PDKgameScene:onEnter()
    print("[ANDROID] PDKgameScene:onEnter called - Timestamp:", os.time())
    print("[ANDROID] PDKgameScene:onEnter - self:", self)
    print("[ANDROID] PDKgameScene:onEnter - g_mainScene:", g_mainScene)
    print("[ANDROID] PDKgameScene:onEnter - self == g_mainScene:", self == g_mainScene)
    
    print("[ANDROID] PDKgameScene:onEnter - USER_INFO dump:")
    dump(USER_INFO, "[ANDROID] USER_INFO in onEnter")
    
    print("[ANDROID] PDKgameScene:onEnter - TpackageName:", TpackageName)
    print("[ANDROID] PDKgameScene:onEnter - USER_INFO[tid]:", USER_INFO["tid"])
    print("[ANDROID] PDKgameScene:onEnter - USER_INFO[seat_id]:", USER_INFO["seat_id"])
    print("[ANDROID] PDKgameScene:onEnter - USER_INFO[activity_id]:", USER_INFO["activity_id"])
    print("[ANDROID] PDKgameScene:onEnter - USER_INFO[uid]:", USER_INFO["uid"])
    print("[ANDROID] PDKgameScene:onEnter - USER_INFO[level]:", USER_INFO["level"])
    
    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    print("[ANDROID] PDKgameScene:onEnter - groupId:", groupId)
    
    print("[ANDROID] PDKgameScene:onEnter - Calling PDKServer:LoginRoom with tid:", USER_INFO["tid"], "seat_id:", USER_INFO["seat_id"], "activity_id:", USER_INFO["activity_id"], "groupId:", groupId)
    PDKServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
    HEART_BEAT_TID = USER_INFO["tid"]
    print("[ANDROID] PDKgameScene:onEnter - HEART_BEAT_TID set to:", HEART_BEAT_TID)
    
    print("[ANDROID] PDKgameScene:onEnter - Calling ChoseBgMusic...")
    self:ChoseBgMusic()
    print("[ANDROID] PDKgameScene:onEnter END - All operations completed")
end

function PDKgameScene:ChoseBgMusic()
    if HasThreeBgm and HasThreeBgm > 0 then

        local musicPath = cc.UserDefault:getInstance():getIntegerForKey("bgMusicType_"..USER_INFO.level, 1)

        local sound_path = "hall/scene/res/common/music/AllBgMusic/pdk_"..musicPath..".mp3"

        cc.SimpleAudioEngine:getInstance():playMusic(sound_path, true)

    else
        --播放背景音乐
        cc.SimpleAudioEngine:getInstance():playMusic("pdk/res/audio/bgm.mp3",true)
    end
end

function PDKgameScene:initProtocol()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(PDKHandle.new())

end

function PDKgameScene:buildGameModeString(data)
    ---
    dump(data,"PDKgameScene:buildGameModeString")
    local canPick = string.split(data.canPick, ",");

    local outThreeCanLack = self:_findCanPick(canPick, 12)  --三张可少带出完
    local trunThreeCanLack = self:_findCanPick(canPick,13)  --三张可少带接完
    local outPlaneCanLack = self:_findCanPick(canPick,14)   --飞机可少带出完
    local trunPlaneCanLack = self:_findCanPick(canPick,15)  --飞机可少带接完
    local heartTenDouble = self:_findCanPick(canPick,6)     --红桃10双倍
    local threeAIsBomb = self:_findCanPick(canPick,7)       --3A算炸
    local four_take_three = self:_findCanPick(canPick,9)    --4带3
    local four_take_two = self:_findCanPick(canPick,10)     --4带2
    local four_take_one = self:_findCanPick(canPick,11)     --4带1
    local threeNoCarry = self:_findCanPick(canPick,17)      --允许3张不带
    local half_param = self:_findCanPick(canPick,16)        --0.5倍率

    local piaoScore = data.times                            --飘分
    local wanfa = data.wanfa                                --1代表16张 0代表15张玩法
    local outcardlose = data.outcardlose                    --出一张加扣10分,出2~3张加扣5分
    local al_pade_three = data.al_pade_three                --黑桃三先出  false 第二局赢家先出
    local baseChip = data.baseChip

    local finalStr = ""

    if half_param then
        baseChip = baseChip * 0.5 
    end

    finalStr = string.format("%.1f", baseChip).."倍率 "

    if wanfa == 1 then
        finalStr = finalStr.."16张玩法 "
    else
        finalStr = finalStr.."15张玩法 "
    end

    finalStr = finalStr.."出牌:"
    if al_pade_three == 1 then
        finalStr = finalStr.."黑桃3先出 "
    else
        finalStr = finalStr.."第二局赢家先出"
    end

    
    if piaoScore ~= nil then
        
        if  #piaoScore == 1 then
            finalStr = finalStr.."飘分:"
            finalStr = finalStr.."不飘 "
        else
            finalStr = finalStr.."飘分:"
            finalStr = finalStr..piaoScore.." "
        end
    end

    if outcardlose ~= nil and outcardlose == 1 then
        finalStr = finalStr.."出一张加扣10分,出2~3张加扣5分 "
    end

    if threeNoCarry then
        finalStr = finalStr.."允许3张不带 "
    end

    if four_take_one then
        finalStr = finalStr.."4带1 "
    end

    if four_take_two then
        finalStr = finalStr.."4带2 "
    end

    if four_take_three then
        finalStr = finalStr.."4带3 "
    end

    if threeAIsBomb then
        finalStr = finalStr.."3A算炸 "
    end

    if heartTenDouble then
        finalStr = finalStr.."红桃10双倍 "
    end

    if trunPlaneCanLack then
        finalStr = finalStr.."飞机可少带接完 "
    end

    if outPlaneCanLack then
        finalStr = finalStr.."飞机可少带出完 "
    end

    if trunThreeCanLack then
        finalStr = finalStr.."三张可少带接完 "
    end

    if outThreeCanLack then
        finalStr = finalStr.."三张可少带出完 "
    end

    self.tableLayer:setWanfaDes(finalStr)


end

function PDKgameScene:initGameConfigData(configStr)
    self._gameConfingStr = configStr
    local data = json.decode(configStr)
    self:initRoomConfigure(data or {})
    --self.tableLayer:setWanfaDes(data)--data.wanfa
    self:buildGameModeString(data)
end

function PDKgameScene:initRoomConfigure(data)
    local canPick = string.split(data.canPick, ",");
    self.roomConfigure.mustTakeForEnd = self:_findCanPick(canPick, 8) --8表示 带牌出的牌型，最后出的牌必须带够数量
    self.roomConfigure.canBombTake    = self:_findCanPick(canPick, 5) --5表示 有4带3的类型
    self.roomConfigure.threeAIsBomb   = self:_findCanPick(canPick, 7) --7表示 3个A算最大炸弹
    self.gameConfigTable = data
    if data.dis_agree and data.dis_agree == 3 then
        self:hideDisbandBtn()
    end
end

function PDKgameScene:_findCanPick(lst, value)
    for i, v in ipairs( lst or {} ) do
        if tonumber(v) == value then
            return true
        end
    end

    return false
end

function PDKgameScene:loadAllLayer()
    print("[ANDROID] PDKgameScene:loadAllLayer START - Timestamp:", os.time())
    print("[ANDROID] PDKgameScene:loadAllLayer - self:", self)
    print("[ANDROID] PDKgameScene:loadAllLayer - TpackageName:", TpackageName)
    
    print("[ANDROID] PDKgameScene:loadAllLayer - Loading TableLayer...")
    self.tableLayer = self:loadLayerByName(TpackageName .. ".src.view.TableLayer", 1)
    print("[ANDROID] PDKgameScene:loadAllLayer - tableLayer loaded:", self.tableLayer)
    print("[ANDROID] PDKgameScene:loadAllLayer - tableLayer is nil:", self.tableLayer == nil)
    
    print("[ANDROID] PDKgameScene:loadAllLayer - Loading PlayerInfoLayer...")
    self.playerInfoLayer = self:loadLayerByName(TpackageName .. ".src.view.PlayerInfoLayer", 2)
    print("[ANDROID] PDKgameScene:loadAllLayer - playerInfoLayer loaded:", self.playerInfoLayer)
    print("[ANDROID] PDKgameScene:loadAllLayer - playerInfoLayer is nil:", self.playerInfoLayer == nil)
    
    print("[ANDROID] PDKgameScene:loadAllLayer - Loading RoomCommonPDKLayer...")
    self.roomCommonLayer = self:loadLayerByName("hall.roomCommonUI.RoomCommonPDKLayer", 3, self:getToDisbandFuncs())
    print("[ANDROID] PDKgameScene:loadAllLayer - roomCommonLayer loaded:", self.roomCommonLayer)
    print("[ANDROID] PDKgameScene:loadAllLayer - roomCommonLayer is nil:", self.roomCommonLayer == nil)
    
    print("[ANDROID] PDKgameScene:loadAllLayer - Loading GameMsgLayer...")
    self.gameMsgLayer = self:loadLayerByName("hall.roomCommonUI.GameMsgLayer", 5, self:getToSendFaceAndTxtFuncs())
    print("[ANDROID] PDKgameScene:loadAllLayer - gameMsgLayer loaded:", self.gameMsgLayer)
    print("[ANDROID] PDKgameScene:loadAllLayer - gameMsgLayer is nil:", self.gameMsgLayer == nil)
    
    print("[ANDROID] PDKgameScene:loadAllLayer - Setting gameMsgLayer visible to false...")
    self.gameMsgLayer:setVisible(false)
    print("[ANDROID] PDKgameScene:loadAllLayer - gameMsgLayer visibility set")
    
    print("[ANDROID] PDKgameScene:loadAllLayer - Loading tgLayer...")
    self.tgLayer = self:loadLayerByName(TpackageName .. ".src.view.tgLayer", 999)
    print("[ANDROID] PDKgameScene:loadAllLayer - tgLayer loaded:", self.tgLayer)
    print("[ANDROID] PDKgameScene:loadAllLayer - tgLayer is nil:", self.tgLayer == nil)
    
    print("[ANDROID] PDKgameScene:loadAllLayer END - All layers loaded successfully")
end

function PDKgameScene:getToDisbandFuncs()
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

function PDKgameScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end

function PDKgameScene:loadMoreFuncLayer()
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

function PDKgameScene:hideDisbandBtn()
    if self.moreFuncLayer then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    end
end

function PDKgameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function PDKgameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        dump("gameMsgLayer====")

    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function PDKgameScene:loadLayerByName(path, zOrder, data)
    if path == nil then
        print("PDKgameScene:loadLayerByName [path] is nil ----------------------")
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

function PDKgameScene:sendFaceByIdx(id, msgType, to_uid)
    PDKServer:CLI_MSG_FACE(id, msgType, to_uid)
end

function PDKgameScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end

function PDKgameScene:quitRoom()

    print ("quitRoom" , SCENENOW["scene"].GameRound)
    if  SCENENOW["scene"].GameRound ~= 0 then
        local paras = {type = 1, title = "提示", content = "游戏中不能退出！！！"}
        local tempNode =  require("hall.tips.CommonTips").new(paras)
        self:addChild(tempNode,9999999)
        return 
    end
    PDKServer:quitRoom()
end

function PDKgameScene:disbandRoom()
    print("send disband msg --------------")
    PDKServer:C2G_CMD_DISSOLVE_ROOM()



end

function PDKgameScene:rejectDisband()
    PDKServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function PDKgameScene:agreeDisband()
    PDKServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function PDKgameScene:showAllResultLayer(data)
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
    self.allResultLayer = self:loadLayerByName("pdk.src.view.TotalResultLayer", 50, data.playerlist)
    -- local singleLayer = require("pdk.src.view.SingleResultLayer").new(info.playerList)
    -- if singleLayer then
    --     singleLayer:setName("singleResultLayer")
    --     singleLayer:setLocalZOrder(20)
    --     g_mainScene:addChild(singleLayer)
    -- end
end

function  PDKgameScene:showSelectCardsLayer()
    self.selectCardsLayer = self:loadLayerByName("pdk.src.view.SelectCardsLayer", 9999, {})
    self.selectCardsLayer:setName("selectCardsLayer")
end

function PDKgameScene:getShowResultData(data)
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
function PDKgameScene:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function PDKgameScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(PDKHandle.new())
    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    PDKServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"] , groupId)
end
function PDKgameScene:onExit()
    --g_mainScene = nil
    --PDKDefine:clearGlobalData()
    -- print ("PDKgameScene_onExit")
    --退出跑得快移除时间定时器
    self.roomCommonLayer:DeleteTimer()
end

return PDKgameScene