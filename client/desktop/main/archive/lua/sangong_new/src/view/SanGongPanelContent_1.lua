--
local SanGongPanelContent = class("SanGongPanelContent")
local SanGongDefine = require("sangong_new.src.ctrl.SanGongDefine")

function SanGongPanelContent:ctor(scene, parent)
    self.scene = scene
    self.parent = parent
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic

    self:initUI()
    self:bindButton()
    self:hideContent()
    self:updateRound()
    if self.logic.bIsTest then
        self:doTest()
    end
end

function SanGongPanelContent:onEnter()
    self.tEvents = {
        GameEvent:addListen("SanGongCountDown", handler(self, self.startCountdown)),
        GameEvent:addListen("SanGongUpdateRoundInfo", handler(self, self.updateRound)),
        GameEvent:addListen("SanGongReadyBtnShow", handler(self, self.setReadyBtnShow)),
        GameEvent:addListen("SanGongSetDiChi", handler(self, self.setDiChi)),
        GameEvent:addListen("SanGongSetBetSliderShow", handler(self, self.setBetSliderShow)),
        GameEvent:addListen("SanGongSetLiangPaiBtnShow", handler(self, self.setLiangPaiBtnShow)),
        GameEvent:addListen("SanGongSetFangPaiBtnShow", handler(self, self.setFangPaiBtnShow)),
        GameEvent:addListen("UpdateSanGongGameStatus", handler(self, self.updateGameStatus)),
    }
end

function SanGongPanelContent:updateGameStatus(st)
    if st == SanGongDefine.END_STATUS then
        self:setDiChi(false)
    end
end

function SanGongPanelContent:doTest()
    self:startCountdown(99)
    self:setDiChi(true, math.random(9999, 99999))
end

function SanGongPanelContent:setFangPaiBtnShow(show)
    self.parent.btn_fanpai:setVisible(show)
    if show then
        self.parent.btn_liangpai:setVisible(false)
    end
end

function SanGongPanelContent:setLiangPaiBtnShow(show)
    self.parent.btn_liangpai:setVisible(show)
    if show then
        self.parent.btn_fanpai:setVisible(false)
    end
end

function SanGongPanelContent:updateRound()
    local str = string.format("局数:   %s/%s", tostring(self.logic.curRound), tostring(self.logic.totalRound))
    self.parent.info_bg.txt_game_round:setString(str)

    str = string.format("房号: %s", tostring(self.logic.inviteCode))
    self.parent.info_bg.txt_invitecode:setString(str)
end

function SanGongPanelContent:onExit()
    for k, e in pairs(self.tEvents) do
        GameEvent:delListen(e)
    end
end

function SanGongPanelContent:initUI()
    GameUtils.setNodeNameBindObj(self.parent)

    local function updateDeviceInfo()
        self.parent.info_bg.txt_time:setString(os.date("%H:%M"))
        self:updateElectricity()
        self:updateSignalQuality()
    end
    local seqAc = cc.Sequence:create(cc.CallFunc:create(updateDeviceInfo), cc.DelayTime:create(5))
    self.parent.info_bg:runAction(cc.RepeatForever:create(seqAc))
    self.parent.Sprite_xiazhu.Slider_xiazhu:addEventListener(handler(self, self.onSliderChange))
end

function SanGongPanelContent:onSliderChange(sender, eventType)
    if eventType == ccui.SliderEventType.percentChanged then
        local rateScore = self.logic.maxChip - self.logic.minChip
        local getPercent = sender:getPercent()
        local tempScore = math.ceil(rateScore * getPercent / 100 + self.logic.minChip)

        if tempScore > self.logic.maxChip then
            tempScore = self.logic.maxChip
        end
        self.nCurBetSlider = tempScore
        self.parent.Sprite_xiazhu.bet_txt_cur:setString(self.nCurBetSlider / 100)
    end
end

--滑动下注
function SanGongPanelContent:setBetSliderShow(show)
    self.parent.Sprite_xiazhu:setVisible(show)
    if show then
        self.nCurBetSlider = self.logic.minChip
        self.parent.Sprite_xiazhu.Slider_xiazhu:setPercent(0)
        self.parent.Sprite_xiazhu.bet_txt_min:setString(self.logic.minChip / 100)
        self.parent.Sprite_xiazhu.bet_txt_max:setString(self.logic.maxChip / 100)
        self.parent.Sprite_xiazhu.bet_txt_cur:setString("")
    end
end

--开始倒计时
function SanGongPanelContent:startCountdown(sec)
    self.nCurSec = sec
    if sec <= 0 then
        self.parent.Image_countdown_bg:stopAllActions()
        self.parent.Image_countdown_bg:setVisible(false)
        return
    end

    self.parent.Image_countdown_bg.Text_countdown:setString("倒计时: " .. self.nCurSec)
    if self.parent.Image_countdown_bg:isVisible() then
        return
    end

    local function update_sec()
        self.nCurSec = self.nCurSec - 1
        self.parent.Image_countdown_bg.Text_countdown:setString("倒计时: " .. self.nCurSec)
        if self.nCurSec <= 0 then
            self.parent.Image_countdown_bg:stopAllActions()
            self.parent.Image_countdown_bg:setVisible(false)
        end
    end
    local seqAc = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(update_sec))
    self.parent.Image_countdown_bg:setVisible(true)
    self.parent.Image_countdown_bg:runAction(cc.RepeatForever:create(seqAc))
end

--设置底池
function SanGongPanelContent:setDiChi(show, dichi)
    if show then
        self.parent.img_dichi_bg:setVisible(true)
        self.parent.img_dichi_bg.dichiTxt:setString("底池：" .. tostring(dichi / 100))
    else
        self.parent.img_dichi_bg:setVisible(false)
    end
end

--是否旁观
function SanGongPanelContent:updatePanGuan()
    self.parent.Image_panguan:setVisible(self.logic.bIsWatch == 1)
end

--获取设备电量
function SanGongPanelContent:updateElectricity()
    local betteryPercent = 100

    if device.platform == "ios" then
        betteryPercent = cct.getDataForApp("getBetteryPercent", {}, "I")
    elseif device.platform == "android" then
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        --[[
        -- 获取应用版本
        local appVersion
        local ok, ret = luaj.callStaticMethod(className, "getAppVersion", args, sigs)
        if not ok then
            print("luaj error:", ret)
        else
            appVersion = ret
        end
        --]]

        --获取应用电量
        ok, ret = luaj.callStaticMethod(className, "getPhonePower", args, sigs)
        if not ok then
            print("luaj error:", ret)
        else
            betteryPercent = tonumber(ret)
        end
    end

    self.parent.info_bg.battery_level:setPercent(betteryPercent)
end

--检测网络质量
function SanGongPanelContent:updateSignalQuality()
    local wifi_level_num = 4 --00 -- 04
    if PINT_TIME ~= nil then
        local ping = PINT_TIME
        if tonumber(ping) <= 120 then
            wifi_level_num = 4
        elseif tonumber(ping) > 120 and tonumber(ping) <= 200 then
            wifi_level_num = 3
        elseif tonumber(ping) > 200 and tonumber(ping) <= 300 then
            wifi_level_num = 2
        elseif tonumber(ping) > 300 and tonumber(ping) <= 500 then
            wifi_level_num = 1
        elseif tonumber(ping) > 500 then
            wifi_level_num = 0
        end
    end

    local str = string.format("sangong_new/res/images/wifi_icon_0%d.png", wifi_level_num)
    self.parent.info_bg.Image_wifi_level:loadTexture(str, 1)
end

function SanGongPanelContent:setStartBtnShow(show)
    self.parent.btn_start:setVisible(show)
end

function SanGongPanelContent:setReadyBtnShow(show)
    self.parent.btn_ready:setVisible(show)
end

function SanGongPanelContent:hideContent()
    self.parent.btn_start:setVisible(false)
    self.parent.btn_ready:setVisible(false)
    self.parent.share_btn:setVisible(false)
    self.parent.copy_btn:setVisible(false)
    self.parent.btn_chakanzhanji:setVisible(false)
    
    self.parent.btn_fanpai:setVisible(false)
    self.parent.btn_liangpai:setVisible(false)
    self.parent.Sprite_xiazhu:setVisible(false)
    self.parent.Image_countdown_bg:setVisible(false)
    self.parent.Image_panguan:setVisible(false)
    self.parent.img_dichi_bg:setVisible(false)
end

function SanGongPanelContent:bindButton()
    -- self.Button_again:addClickEventListener(handler(self, self.onClickAgain))

    self.parent.btn_start:addClickEventListener(handler(self, self.onClickStart))
    self.parent.btn_ready:addClickEventListener(handler(self, self.onClickReady))
    self.parent.share_btn:addClickEventListener(handler(self, self.onClickShare))
    self.parent.copy_btn:addClickEventListener(handler(self, self.onClickCopyRoomId))

    self.parent.btn_chakanzhanji:addClickEventListener(handler(self, self.onClickZhanji))   
    self.parent.btn_fanpai:addClickEventListener(handler(self, self.onClickFanpai))
    self.parent.btn_liangpai:addClickEventListener(handler(self, self.onClickLiangpai))
    self.parent.btn_record:addClickEventListener(handler(self, self.onClickRecord))
    self.parent.btn_tuoguan:addClickEventListener(handler(self, self.onClickTuoGuan))

    -- g_family_is_chat = true
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    VoiceRecordView:addVoiceRecordEvent(self.parent.btn_voice)
    self.parent.btn_chat:addClickEventListener(handler(self, self.onClickChat))
    self.parent.btn_setting:addClickEventListener(handler(self, self.onClickSetting))
    self.parent.btn_help_rule:addClickEventListener(handler(self, self.onClickShowHelp))
    self.parent.Sprite_xiazhu.btn_bet_slider:addClickEventListener(handler(self, self.onClickBetSlider))
    self.parent.Sprite_xiazhu.btn_bet_allin:addClickEventListener(handler(self, self.onClickBetAllin))
end

function SanGongPanelContent:onClickSetting(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self:loadMoreFuncLayer()
    self:setGameSetting()
end

function SanGongPanelContent:setGameSetting()
    local data = {}
    data.disbandRoomHandler = function(sender, event)
        self.ctrl.send:C2G_CMD_DISSOLVE_ROOM()
    end

    data.quitRoomHandler = function(sender, event)
        require("hall.GameCommon"):showSettings(false)
        self.ctrl.send:quitRoom()
    end
    self.moreFuncLayer._quitRoom = data.quitRoomHandler
    self.moreFuncLayer._disbandRoom = data.disbandRoomHandler
end

function SanGongPanelContent:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        -- g_roomCommonLayer = self.moreFuncLayer
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self.scene:addChild(self.moreFuncLayer)
    else
        --if 0 == SCENENOW["scene"].GameRound then
        --    self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        --else
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        --end
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end

    if self.logic.bIsWatch == 0 then
        self.moreFuncLayer:set_btnDisbandRoom_visible(false)
    end
end

function SanGongPanelContent:onClickChat(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    if tolua.isnull(self.gameMsgLayer) then
        local data = {
            sendFaceHand = handler(self.ctrl.send, self.ctrl.send.CLI_MSG_FACE)
        }
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(data)
        self.scene:addChild(self.gameMsgLayer)
        self.gameMsgLayer:setVisible(false)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function SanGongPanelContent:onClickShare(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:doShareRoom()
end

function SanGongPanelContent:onClickCopyRoomId(sender)
    require("hall.util.GameMenu"):registCopyRoomIdFunc(self.copy_btn, self.logic.inviteCode, "欢乐三公")
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
end

function SanGongPanelContent:onClickReady(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl.send:sendReady(1)
end

function SanGongPanelContent:onClickAgain(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:onceAgain()
end

function SanGongPanelContent:onClickStart(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl.send:StartGame()
    self.parent.btn_start:setVisible(false)
end

function SanGongPanelContent:onClickZhanji(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

    local GameResult = self.scene:getChildByName('gameresultScene')
    if GameResult then
        GameResult:setVisible(true)
    end
end

function SanGongPanelContent:onClickFanpai(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    GameEvent:dispatch("SanGongPlayerOpenCards", USER_INFO['uid'], false, true)
    self.parent.btn_liangpai:setVisible(true)
    self.parent.btn_fanpai:setVisible(false)
end

function SanGongPanelContent:onClickLiangpai(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.parent.btn_liangpai:setVisible(false)
    self.ctrl.send:sendMycards()
end

function SanGongPanelContent:onClickRecord(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    local game_round = math.max(self.logic.curRound - 1, 1)
    self.ctrl.send:CLI_COMMAND_GAMERESULT_RECORD(game_round)
end

function SanGongPanelContent:onClickTuoGuan(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl.send:requestAutoPlay(1)
end

function SanGongPanelContent:onClickShowHelp(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

    local tbl = {
        {['人数'] = self.logic.gameConfigTable.maxSeatCount},
        {['底分'] = self.logic.gameConfigTable.times},
        {['封顶'] = self.logic.maxChip},
        {['开始'] = self.logic.gameConfigTable.startCount == '0' and '手动开始' or '满' .. self.logic.gameConfigTable.startCount .. '人开始'}
    }

    require('hall.util.GameMenu'):showConfigPanel(tbl)
end

function SanGongPanelContent:onClickBetSlider(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.parent.Sprite_xiazhu:setVisible(false)

    local score = self.nCurBetSlider
    local userInfo = self.logic:getPlayerByUid(USER_INFO['uid'])
    if userInfo and userInfo.gold and score > userInfo.gold then
        score = userInfo.gold
    end
    self.ctrl.send:CLIENT_CMD_YA(USER_INFO['uid'], score)
end

function SanGongPanelContent:onClickBetAllin(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

    self.parent.Sprite_xiazhu:setVisible(false)
    self.ctrl.send:CLIENT_CMD_YA(USER_INFO['uid'], self.logic.maxChip)
end

return SanGongPanelContent
