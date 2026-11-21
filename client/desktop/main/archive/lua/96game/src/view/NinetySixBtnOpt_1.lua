--按钮操作
local NinetySixBtnOpt = class("NinetySixBtnOpt")

function NinetySixBtnOpt:ctor(scene, parent)
    self.scene = scene
    self.parent = parent
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic

    self:initUI()
    self:bindButton()
    self:hideAllBtn()
end

function NinetySixBtnOpt:onEnter()
    self.tEvents = {
        GameEvent:addListen("NinetySixShowOption", handler(self, self.showOption)),
        GameEvent:addListen("NinetySixHideOption", handler(self, self.hideOption)),
        GameEvent:addListen("NinetySixNextRoundClean", handler(self, self.hideAllBtn)),
        GameEvent:addListen("NinetySixNextShowSettleBtn", handler(self, self.showSettleBtn)),
        GameEvent:addListen("NinetySixReadyBtnShow", handler(self, self.setReadyBtnShow)),
        GameEvent:addListen("NinetySixShowOptionPiao", handler(self, self.ShowOptionPiao)),
        GameEvent:addListen("NinetySixShowStopTime", handler(self, self.stopTimer)),
        GameEvent:addListen("NinetySixHideAi", handler(self, self.HideRobotAi))
    }
end

function NinetySixBtnOpt:onExit()
    for k, e in pairs(self.tEvents) do
        GameEvent:delListen(e)
    end
end

function NinetySixBtnOpt:setReadyBtnShow(show)
    self.Button_ready:setVisible(show)
end

function NinetySixBtnOpt:initUI()
    self.Layout_rightBtn = self.parent:getChildByName("Layout_rightBtn")
    self.Layout_startBtn = self.parent:getChildByName("Layout_startBtn")
    self.Layout_endBtn = self.parent:getChildByName("Layout_endBtn")
    self.Operate_btn = self.parent:getChildByName("Operate_btn")
    self.Layout_p_btn = self.parent:getChildByName("Layout_p_btn")
    self.take_bg = self.parent:getChildByName("take_bg")

    self.Button_Setting = self.Layout_rightBtn:getChildByName("Button_Setting")
    self.Button_Chat = self.Layout_rightBtn:getChildByName("Button_Chat")
    self.Button_Voice = self.Layout_rightBtn:getChildByName("Button_Voice")

    self.Button_share = self.Layout_startBtn:getChildByName("Button_share")
    self.BtnCopyRoomId = self.Layout_startBtn:getChildByName("BtnCopyRoomId")
    self.Button_ready = self.Layout_startBtn:getChildByName("Button_ready")
    self.Button_settlement = self.Layout_startBtn:getChildByName("Button_settlement")
    if self.take_bg then
         self.Button_cl = self.take_bg:getChildByName("Button_cl")
    end
   
    self.stage_img = self.Layout_p_btn:getChildByName("stage_img")
    self.stage_txt = self.stage_img:getChildByName("stage_txt")
    self.Button_not_p = self.Layout_p_btn:getChildByName("Button_not_p")
    self.Button_not_p.piaoFeng = 0
    self.Button_p_num_2 = self.Layout_p_btn:getChildByName("Button_p_num_2")
    self.Button_p_num_2.piaoFeng = 2
    self.Button_p_num_3 = self.Layout_p_btn:getChildByName("Button_p_num_3")
    self.Button_p_num_3.piaoFeng = 3

    self.Button_back = self.Layout_endBtn:getChildByName("Button_back")
    self.Button_again = self.Layout_endBtn:getChildByName("Button_again")
    self.Button_tie = self.Operate_btn:getChildByName("Button_tie")
    self.Button_chi = self.Operate_btn:getChildByName("Button_chi")
    self.Button_hu = self.Operate_btn:getChildByName("Button_hu")
    self.Button_guo = self.Operate_btn:getChildByName("Button_guo")
    if self.take_bg then
         self.take_bg:setVisible(false)
    end
     
end

function NinetySixBtnOpt:hideAllBtn()
    self.Button_share:setVisible(false)
    self.BtnCopyRoomId:setVisible(false)
    self.Button_ready:setVisible(false)
    self.Button_back:setVisible(false)
    self.Layout_p_btn:setVisible(false)
    self.Button_not_p:setVisible(false)
    self.Button_p_num_2:setVisible(false)
    self.Button_p_num_3:setVisible(false)
    self.Button_again:setVisible(false)
    self.Button_settlement:setVisible(false)
   
    self:hideOption()
end

function NinetySixBtnOpt:bindButton()
    self.Button_Setting:addClickEventListener(handler(self, self.onClickSetting))
    self.Button_Chat:addClickEventListener(handler(self, self.onClickChat))

    -- g_family_is_chat = true
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    VoiceRecordView:addVoiceRecordEvent(self.Button_Voice)
     if self.Button_cl then
        self.Button_cl:addClickEventListener(handler(self, self.onClickROBOT))
     end
    
    self.Button_share:addClickEventListener(handler(self, self.onClickShare))
    self.BtnCopyRoomId:addClickEventListener(handler(self, self.onClickCopyRoomId))
    self.Button_ready:addClickEventListener(handler(self, self.onClickReady))
    self.Button_settlement:addClickEventListener(handler(self, self.onClickShowSettlement))

    self.Button_back:addClickEventListener(handler(self, self.onClickBack))
    self.Button_again:addClickEventListener(handler(self, self.onClickAgain))

    self.Button_not_p:addClickEventListener(handler(self, self.onClickPiao))
    self.Button_p_num_2:addClickEventListener(handler(self, self.onClickPiao))
    self.Button_p_num_3:addClickEventListener(handler(self, self.onClickPiao))
    self.Button_tie:addClickEventListener(handler(self, self.onClickTie))
    self.Button_chi:addClickEventListener(handler(self, self.onClickChi))
    self.Button_guo:addClickEventListener(handler(self, self.onClickGuo))
    self.Button_hu:addClickEventListener(handler(self, self.onClickHu))
end

function NinetySixBtnOpt:showSettleBtn()
    self.Button_settlement:setVisible(true)
end
function NinetySixBtnOpt:HideRobotAi(opt)
    dump(opt,"HideRobotAi")
    if opt == 0 then
         self.take_bg:setVisible(false)
         self.istuoguan = false
        else
        self.take_bg:setVisible(true)
        self.istuoguan = true
    end
end
function NinetySixBtnOpt:showOption(opt, pack)
    self.pack = pack
    if opt == 'tie' then
        self.Button_tie:setVisible(true)
        self.Button_guo:setVisible(true)
    elseif opt == 'chi' then
        self.Button_chi:setVisible(true)
        self.Button_guo:setVisible(true)
    elseif opt == 'hu' then
        self.Button_hu:setVisible(true)
        self.Button_guo:setVisible(true)
    end
end

function NinetySixBtnOpt:ShowOptionPiao(pack)
    if pack.piaoFeng > 0 then
        self:startTimer(pack.time,"")
        self.Button_not_p:setVisible(true)
        self.Button_p_num_2:setVisible(true)
        self.Button_p_num_3:setVisible(true)
        self.Layout_p_btn:setVisible(true)
    else
        self.Layout_p_btn:setVisible(false)
    end
end

function NinetySixBtnOpt:hideOption()
    self.Button_tie:setVisible(false)
    self.Button_chi:setVisible(false)
    self.Button_guo:setVisible(false)
    self.Button_hu:setVisible(false)
end

function NinetySixBtnOpt:onClickSetting(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.scene:hideTingCards()
    self:loadMoreFuncLayer()
    self:setGameSetting()
end

function NinetySixBtnOpt:setGameSetting()
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

function NinetySixBtnOpt:loadMoreFuncLayer()
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

    if g_isWatch == 0 then
        self.moreFuncLayer:set_btnDisbandRoom_visible(false)
    end
end

function NinetySixBtnOpt:onClickChat(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    --self.scene:hideTingCards()
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

function NinetySixBtnOpt:onClickShare(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:doShareRoom()
end
function NinetySixBtnOpt:onClickROBOT(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:doQuitAl()
end
function NinetySixBtnOpt:onClickCopyRoomId(sender)
    require("hall.util.GameMenu"):registCopyRoomIdFunc(self.copy_btn, self.logic.inviteCode, "96扑克")
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
end

function NinetySixBtnOpt:onClickReady(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl.send:sendReady(1)
end

function NinetySixBtnOpt:onClickBack(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:returnToHall()
end

function NinetySixBtnOpt:onClickAgain(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:onceAgain()
end

function NinetySixBtnOpt:onClickTie(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl.send:tieCard(self.pack.tCards[1], self.pack.tCards[2])
    self:hideOption()
end

function NinetySixBtnOpt:onClickChi(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl.send:chiCard(1, self.pack.tCards[1], self.pack.tCards[2], self.pack.tCards[3])
    self:hideOption()
end

function NinetySixBtnOpt:onClickGuo(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl.send:userPass()
    self:hideOption()
end
function NinetySixBtnOpt:onClickHu(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl.send:huCard()
    self:hideOption()
end
function NinetySixBtnOpt:onClickShowSettlement(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.Button_settlement:setVisible(false)
    self.scene:hideTingCards()
    GameEvent:dispatch("NinetySixNextShowSettlement")
end

function NinetySixBtnOpt:onClickPiao(sender)
    print("sender.piaoFeng",sender.piaoFeng)
    self.ctrl.send:CLIENT_COMMAND_USER_PIAO(sender.piaoFeng)
    self.Button_p_num_2:setVisible(false)
    self.Button_p_num_3:setVisible(false)
    self.Button_not_p:setVisible(false)
    --self:stopTimer()
end
--设置倒计时时间显示
function NinetySixBtnOpt:startTimer(time,stage)

    --dump(time,stage.."------------------------")
    self.stage_img:stopAllActions()
    local  timer_value = time
    local  refreshTime = 1
    local func = function ( timer_value )
        if timer_value ~= nil then
            local str = stage or ""
            self.stage_txt:setString(str..""..string.format( "%02d", timer_value ))
            self.stage_img:setVisible(true)
        end
    end
    func(timer_value)
    local showTimerAc = cc.CallFunc:create(function()
        timer_value = timer_value - refreshTime
        --dump(timer_value,stage.."------------------------")
        if  timer_value > 0 then
            func(timer_value)
        else
            self:stopTimer()
        end
    end)

    local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime),showTimerAc)
    self.stage_img:runAction(cc.RepeatForever:create(seqAc))
end
function NinetySixBtnOpt:stopTimer()
    self.stage_img:stopAllActions()
    self.Layout_p_btn:setVisible(false)
end
return NinetySixBtnOpt
