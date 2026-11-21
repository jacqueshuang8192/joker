local ResLoader = require('hall.tool.utils.res_loader')
local common_res_list = require('hall.tool.config.common_res_list')
local NiuNiuSendHandle = import("NewNiuniu.src.protocol.NiuNiuSendHandle")

local NiuNiuGameScene =
    class(
    'NiuNiuGameScene',
    function()
        return display.newScene('NiuNiuGameScene')
    end
)

function NiuNiuGameScene:ctor()
    --牛牛包名
    TpackageName = 'NewNiuniu'
    GROUP_MODE = 2

    if device.platform == 'ios' then
        if isiOSVerify then
            self.gameMianLayer = cc.CSLoader:createNode(TpackageName .. '/res/csb/gameMianLayer.csb'):addTo(self)
        else
            self.gameMianLayer =
                cc.CSLoader:createNode(
                cc.FileUtils:getInstance():getWritablePath() ..
                    TpackageName .. '/res/csb/gameMianLayer.csb'
            ):addTo(self)
        end
    else
        self.gameMianLayer = cc.CSLoader:createNode(TpackageName .. '/res/csb/gameMianLayer.csb'):addTo(self)
    end
    
    self.gameMianLayer = GameUtils.setNodeNameBindObj(self.gameMianLayer)
    self:_toGetObj(self.gameMianLayer)
    DESIGN_SCREEN_WIDTH = 1920
    DESIGN_SCREEN_HEIGHT = 1080

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    self.gameMianLayer:setScale(SCREEN_WIDTH / DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT / DESIGN_SCREEN_HEIGHT)
    
    -- self.gameMianLayer.root = self.gameMianLayer:getChildByName("root")
    -- self.gameMianLayer.root.laizi_vw = self.gameMianLayer.root:getChildByName("laizi_vw")
    -- self.gameMianLayer.root.audience_brand = self.gameMianLayer.root:getChildByName("audience_brand")
    -- self.gameMianLayer.root.roomInfo = self.gameMianLayer.root:getChildByName("roomInfo")

    self.gameMianLayer.root.laizi_vw:setVisible(false)
    self.gameMianLayer.root.audience_brand:setVisible(false)
    self.gameMianLayer.root.roomInfo:setVisible(false)
    g_mainScene = self
end

function NiuNiuGameScene:onEnter()
    g_mainScene = self
    self.gameDefine = require("NewNiuniu.src.logic.NiuniuDefine").new()
    self:loadUserInfoLayer()
    self:loadGameOptLayer()
    self:LoginRoom()
    self:_loadFile()
    self:initRoomInfo()
    
    SoundUtils = import(TpackageName .. '.src.sound.SoundUtils')
    self:ChoseBgMusic()
    self:onChangeBg()
    if device.platform ~= 'windows' then
        function dump()
        end
    end

    local faceUI_node = require('hall.FaceUI.faceUI').new()
    faceUI_node:setHandle(NiuNiuSendHandle)
    self:addChild(faceUI_node, 9999)
    faceUI_node:setName('faceUI')

    local EmojiArmatureView =
    require('hall.EmojiArmatureView.EmojiArmatureView'):newEmojiArmatureView(
            self:getToSendFaceAndTxtFuncs(),
            g_mainScene
    )
    EmojiArmatureView:setLocalZOrder(9999)
end

function NiuNiuGameScene:_toGetObj(node)
    if node == nil then return end

    if node.getName then
        --去掉csb命名的空格，加一层括号，只返回格式化后的字符串
        local name = (string.gsub(node:getName(), "^%s*(.-)%s*$", "%1")) 
        print("_toGetObj ---------------------", name)
        node[name] = node
    end

    local child = node:getChildren()
    if #child ~= 0 then
        for i, v in ipairs( child or {} ) do
            self:_toGetObj(v)
        end
    end
end

function NiuNiuGameScene:_loadFile(callback)

end

function NiuNiuGameScene:ChoseBgMusic()
    if HasThreeBgm and HasThreeBgm > 0  then
        SoundUtils:playBgmByType()
    else
        --播放背景音乐
        SoundUtils:playBackgroundMusic()
    end
end

function NiuNiuGameScene:setGameSetting()
    self.roomCommonLayer = require('hall.roomCommonUI.RoomCommonPDKLayer').new(self:getToDisbandFuncs())
    self:addChild(self.roomCommonLayer, 15)
    self.roomCommonLayer:setTouchSwallowEnabled(false)
    self.roomCommonLayer:setVisible(false)
end

function NiuNiuGameScene:showGameSetting()
    self:setGameSetting()
    self:loadMoreFuncLayer()
end

function NiuNiuGameScene:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        -- g_roomCommonLayer = self.moreFuncLayer
        self.moreFuncLayer = require('hall.roomCommonUI.GameMoreFuncLayer').new()
        self.moreFuncLayer:setLocalZOrder(100)
        self:addChild(self.moreFuncLayer)
        local data = {}
        data.quitRoom = handler(self, self.quitRoom)
        data.disbandRoom = handler(self, self.disbandRoom)
        
        self.moreFuncLayer:registerDisbandFuncs(data)
        if GAME_TYPE == 5 then
            self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        end
    else
        if 0 == g_mainScene.GameRound then
            self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        else
            self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
        if GAME_TYPE == 5 then
            self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        end
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end

    if g_isWatch == 0 then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    end
end

function NiuNiuGameScene:disbandRoom()
    NiuNiuSendHandle:C2G_CMD_DISSOLVE_ROOM()
end

function NiuNiuGameScene:rejectDisband()
    NiuNiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function NiuNiuGameScene:agreeDisband()
    NiuNiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function NiuNiuGameScene:getToDisbandFuncs()
    local data = {}
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
    data.showGameMsgLayerHandler = handler(self, self.loadGameMsgLayer)
    return data
end

function NiuNiuGameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require('hall.roomCommonUI.GameMsgLayer').new(self:getToSendFaceAndTxtFuncs())
        self.gameMsgLayer:setLocalZOrder(900)
        self.gameMsgLayer:addTo(self)
        -- self:addChild(self.gameMsgLayer, 15)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function NiuNiuGameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function NiuNiuGameScene:sendFaceByIdx(id, msgType, to_uid)

    NiuNiuSendHandle:CLI_MSG_FACE(id, msgType, to_uid)
end

function NiuNiuGameScene:sendEditTxt(str)

end

function NiuNiuGameScene:loadUserInfoLayer()
    if self.gameUserInfoLayer == nil then
        self.gameUserInfoLayer = require('NewNiuniu.src.view.gameUserInfoLayer').new()
        self.gameUserInfoLayer:setLocalZOrder(10)
        self.gameUserInfoLayer:addTo(self)
    end
end

function NiuNiuGameScene:loadGameOptLayer()
    if self.gameOptLayer == nil then
        self.gameOptLayer = require('NewNiuniu.src.view.gameOptLayer').new()
        self.gameOptLayer:setLocalZOrder(11)
        self.gameOptLayer:addTo(self)
    end
end

function NiuNiuGameScene:loadGameGongNiuOptLayer()
    if self.gameGongNiuOptLayer == nil then
        self.gameGongNiuOptLayer = require('NewNiuniu.src.view.gameGongNiuOptLayer').new()
        self.gameGongNiuOptLayer:setLocalZOrder(12)
        self.gameGongNiuOptLayer:addTo(self)
    end
end

function NiuNiuGameScene:LoginRoom()
    local NiuNiuProtocol = import(TpackageName .. '.src.protocol.NiuNiuProtocol')
    local NiuNiuReceiveHandle = import(TpackageName .. '.src.protocol.NiuNiuReceiveHandle')

    --设置协议和协议处理
    bm.server:setProtocol(NiuNiuProtocol)
    bm.server:setHandle(NiuNiuReceiveHandle.new())

    local groupId = tonumber(USER_INFO["family_id"])
    dump(USER_INFO, "USER_INFO == ")
    NiuNiuSendHandle:LoginRoom(USER_INFO['tid'], USER_INFO['seat_id'], USER_INFO['activity_id'], groupId)
    HEART_BEAT_TID = USER_INFO['tid']
end

function NiuNiuGameScene:quitRoom()
    NiuNiuSendHandle:quitRoom()
end

function NiuNiuGameScene:getGameConfig()
    local fanbeiRule = ''

    local roomRule = ''
    if GAME_TOTAL_ROUND and (isGoldGame == 1 or isGoldGame == 2) then
        roomRule = GAME_TOTAL_ROUND .. '局'
    end

    local specialRule = ''

    if GAME_CONFIG['允许搓牌'] == true then
        specialRule = '  允许搓牌'
    end

    if self.gameConfigTable['gaoji'] and string.find(self.gameConfigTable['gaoji'], '6') then
        specialRule = specialRule .. '  无花牛牛'
    end

    if string.find(self.gameConfigTable.gaoji or '', '7') then
        specialRule = specialRule .. '  点子牛'

        if self.gameConfigTable.pointMode == 1 then
            fanbeiRule = '牛N x N倍'
        elseif self.gameConfigTable.pointMode == 2 then
            fanbeiRule = '点子相差'
        end
    end

    local gameConfigTable = {
        {['玩法'] = GAME_TYPE_NAME, ['底分'] = baseChip},
        {['翻倍规则'] = fanbeiRule},
        {['房间规则'] = roomRule},
        {['特殊玩法'] = specialRule}
    }

    return gameConfigTable
end

function NiuNiuGameScene:initRoomInfo()
    local roomInfo = self.gameMianLayer.root.roomInfo
    require('hall.util.GameMenu'):getDeviceInfo(roomInfo, roomInfo.powerVal, roomInfo.wifi, roomInfo.time)
    -- self:updateRoomInfo(inviteCode, round, total_round)
end

function NiuNiuGameScene:updateRoomInfo(inviteCode, round, total_round)
    require('hall.util.GameMenu'):registCopyRoomIdFunc(g_mainScene.gameOptLayer.btnCopyRoom, g_mainScene.invote_code, "牛牛")
    self.gameMianLayer.root.roomInfo:setVisible(true)
    self.gameMianLayer.root.roomInfo.roomNum:setString(inviteCode)
    if self.GAME_TYPE == 5 then
        self.gameGongNiuOptLayer:setGuoJusize(round, self.m_nGuoCount)
    else
        self.gameMianLayer.root.roomInfo.juSize:setString(string.format("%s/%s局", tostring(round or "0"), tostring(total_round or "0")))
    end
end

function NiuNiuGameScene:setRoomNum( roomNum )
    self.gameMianLayer.root.roomInfo.roomNum:setString(roomNum )
end

function NiuNiuGameScene:setRoomRoundVisible(flag)
    self.gameMianLayer.root.roomInfo.juSize:setVisible(flag)
    
end

--解散组局相关
--解散组局
function NiuNiuGameScene:disbandGroup()
    local function disband()
        NiuNiuSendHandle:C2G_CMD_DISSOLVE_ROOM()
    end

    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    cct.createHttRq(
        {
            url = HttpAddr .. '/freeGame/queryGroupGameStatus',
            date = {
                activityId = USER_INFO['activity_id'],
                interfaceType = 'j'
            },
            type_ = 'POST',
            callBack = function(data)
                local responseData = data.netData
                responseData = json.decode(responseData)
                local returnCode = responseData.returnCode
                if returnCode == '0' then
                    local data = tonumber(responseData.data)
                    if data == 1 then
                        --创建组局
                        if isiOSVerify then
                            require('hall.GameTips'):showDisbandTips(
                                '解散房间',
                                'new_disbandGroup',
                                1,
                                '是否解散房间？',
                                _,
                                disband
                            )
                        else
                            require('hall.GameTips'):showDisbandTips(
                                '解散房间',
                                'new_disbandGroup',
                                1,
                                '当前解散房间不需扣除房卡，是否解散？',
                                _,
                                disband
                            )
                        end
                    elseif data == 2 then
                        --开始组局
                        if isiOSVerify then
                            require('hall.GameTips'):showDisbandTips(
                                '解散房间',
                                'new_disbandGroup',
                                1,
                                '是否解散房间？',
                                _,
                                disband
                            )
                        else
                            require('hall.GameTips'):showDisbandTips(
                                '解散房间',
                                'new_disbandGroup',
                                1,
                                '当前已经扣除房卡，是否申请解散房间？',
                                _,
                                disband
                            )
                        end
                    elseif data == 0 then
                        --结束组局
                        require('hall.GameTips'):showTips('提示', 'tohall', 1, '当前组局已结束，是否返回大厅？')
                    end
                else
                end
            end
        }
    )
end

function NiuNiuGameScene:showPangguang()
    self.gameMianLayer.root.audience_brand:setVisible(true)
end


function NiuNiuGameScene:showTableLaizi(value, isAction)
    if not value then
        return
    end
    if isAction == nil then
        isAction = true
    end
    local card = NIUNIU_GAME_SCENE.laizi_vw:getChildByName('tableLaizi')
    local laizi_vw = NIUNIU_GAME_SCENE.laizi_vw
    local scale = 0.7
    if not card then
        card = Card.new()
        local _, csize = Card:getSingleCardBackPath()
        local size = laizi_vw:getContentSize()
        local x = (size.width / 2)
        local y = (size.height / 2 - csize.height * scale / 2)
        card:setScale(scale)
        card:addTo(laizi_vw)
        card:setPosition(x, y)
        card:setName('tableLaizi')
        local zindx = NIUNIU_GAME_SCENE:getChildByName('ten_people_player_plane'):getLocalZOrder()
        laizi_vw:setLocalZOrder(zindx + 1)
    end
    laizi_vw:show()
    card:setCard(value)
    card:showFront()
    if isAction then
        laizi_vw.shine:show()
        laizi_vw.shine_0:show()
        card:showBack()
        card:flipCard()
        laizi_vw:setScale(0.1)
        local scaleAction1 = cc.ScaleTo:create(0.1, 1.2)
        local scaleAction2 = cc.ScaleTo:create(0.05, 1)
        local CallFunc =
            cc.CallFunc:create(
            function()
                local CallFunc =
                    cc.CallFunc:create(
                    function()
                        laizi_vw.shine:setRotation(1)
                        laizi_vw.shine:hide()
                        laizi_vw.shine_0:hide()
                    end
                )
                local rotateAc = cc.RotateBy:create(1, 360)
                local Repeat = cc.Repeat:create(rotateAc, 3)
                local Sequence = cc.Sequence:create(Repeat, CallFunc)
                laizi_vw.shine:runAction(Sequence)
            end
        )
        local Sequence = cc.Sequence:create(scaleAction1, scaleAction2, CallFunc)
        laizi_vw:runAction(Sequence)
    end
end

function NiuNiuGameScene:hideTableLaizi()
    local laizi_vw = NIUNIU_GAME_SCENE.laizi_vw
    local tableLaizi = laizi_vw:getChildByName('tableLaizi')
    if tableLaizi then
        tableLaizi:stopAllActions()
    end
    laizi_vw:stopAllActions()
    laizi_vw.shine:stopAllActions()
    laizi_vw:hide()
    laizi_vw.shine:hide()
    laizi_vw.shine_0:hide()
end

function NiuNiuGameScene:canCuoPai()
    local wanfaStr = g_mainScene.gameConfig.gaoji
    if wanfaStr and type(wanfaStr) == "string" then
        return string.find(wanfaStr, "3")
    end

    return false
end

function NiuNiuGameScene:onExit()
    g_mainScene = nil
    g_isWatch = nil
end

function NiuNiuGameScene:onChangeBg()
   local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO["level"],2)
    local room_bg1 = self.gameMianLayer:getChildByName("bg"):getChildByName("image")
    room_bg1:setTexture(TpackageName.."/res/image/bg_"..str..".png")
end

return NiuNiuGameScene
