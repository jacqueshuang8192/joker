--[[
* author:   zwm
* date:     2020-10-14
* describe: 公牛操作按钮界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local NiuNiuSendHandle = import("NewNiuniu.src.protocol.NiuNiuSendHandle")
local ViewBaseLayer = require("hall.ViewBaseLayer")
local GameGongNiuOptLayer = class("GameGongNiuOptLayer", ViewBaseLayer)

function GameGongNiuOptLayer:ctor()
    GameOptLayer.super.ctor(self, "NewNiuniu/res/csb/gameGongNiuOptLayer.csb")
    self._csbNode:setScale(1280/1920, 720/1080)
end

function GameGongNiuOptLayer:onEnter()
    self.betSlider:addEventListener(handler(self, self.sliderChanged))
    self.readyNode:setVisible(false)
end

function sliderChanged(sender, eventType)
    if eventType == ccui.SliderEventType.percentChanged then
        local amount = sender:getPercent()
        self.sliderScoreValue = math.floor((self.dgnShotScore - self.minBetScore) * (amount / 100)) + self.minBetScore
        self.sliderScore:setString(self.sliderScoreValue)
    end
end

function GameGongNiuOptLayer:showBetBtnScore()
    if USER_INFO['uid'] == BANKER_UID then
        return
    end
    self:setBetBtnVisible(true)
    local baseGuodi = g_mainScene.baseGuodi or ((g_mainScene.gameConfigTable.guodi or 50) * BASE_CHIP)
    local curGuodi = g_mainScene.curGuodi or ((g_mainScene.gameConfigTable.guodi or 50) * BASE_CHIP)
    local minScore = 1
    if g_mainScene.bFristBet then
        if g_mainScene.gameConfigTable.firstBetLimit ~= nil then
            minScore = math.floor(baseGuodi * tonumber(g_mainScene.gameConfigTable.firstBetLimit) / 100) or 1
        end
    else
        if g_mainScene.gameConfigTable.afterBetLimit ~= nil then
            minScore = math.floor(baseGuodi * tonumber(g_mainScene.gameConfigTable.afterBetLimit) / 100) or 1
        end
    end
    local _maxScore = math.floor(curGuodi / 3)
    local maxScore = _maxScore < 10 and _maxScore or (math.floor(math.floor(curGuodi / 3) / 10) * 10 or minScore)
    maxScore = maxScore < minScore and minScore or maxScore
    self.minBetScore = minScore == 0 and 1 or minScore
    self.midBetScore = maxScore == 0 and 1 or maxScore
    self.dgnShotScore = math.floor(curGuodi / 3) == 0 and 1 or math.floor(curGuodi / 3)
    self.dgnShotScore = self.dgnShotScore < maxScore and maxScore or self.dgnShotScore
    self.sliderScoreValue = self.minBetScore
    self.sliderScore:setString(self.sliderScoreValue)
    self.betSlider:setPercent(0)
    self.btnBetLeft:getChildByName('score'):setString(minScore .. ' 分')
    self.btnBetMid:getChildByName('score'):setString(maxScore .. ' 分')
end

function GameGongNiuOptLayer:setBetBtnVisible(flag)
    self.betNode:setVisible(flag)
end

function GameGongNiuOptLayer:onClickBtnBetLeft(sender, event)
    local value = sender.betValue
    NiuNiuSendHandle:addBase(value)
end

function GameGongNiuOptLayer:onClickBtnBetMid(sender, event)
    local value = sender.betValue
    NiuNiuSendHandle:addBase(value)
end

function GameGongNiuOptLayer:onClickBtnBetRight(sender, event)
    local value = self.sliderScore
    NiuNiuSendHandle:addBase(value)
end

function GameGongNiuOptLayer:onClickBtnBetShot(sender, event)
    local value = sender.betValue
    NiuNiuSendHandle:addBase(value)
end

function GameGongNiuOptLayer:onClickBtnDownBank(sender, event)
    NiuNiuSendHandle:sendUserDownBankOpt(1)
end

function GameGongNiuOptLayer:onClickBtnNotUpBank(sender, event)
    NiuNiuSendHandle:sendUserUpBankOpt(2)
end

function GameGongNiuOptLayer:onClickBtnUpBank(sender, event)
    NiuNiuSendHandle:sendUserUpBankOpt(1)
end

function GameGongNiuOptLayer:onClickBtnDownBankOther(sender, event)
    NiuNiuSendHandle:sendUserDownBankOpt(1)
end

function GameGongNiuOptLayer:onClickBtnUpBank(sender, event)
    NiuNiuSendHandle:readyNow(1)
end

function GameGongNiuOptLayer:setGuoJusize(ju, guo)
    guoJuSize:setString(string.format("第%d/%s局", guo, tostring(ju or "0")))
end

function GameGongNiuOptLayer:setUpBankBtnVisible(flag, state)
    if flag == nil then
        flag = false
    end
    self.douGongniu_plane:getChildByName('bankOptNode'):setVisible(flag)
    if flag then
        if state == 7 then
            self.btnDownBank:setBright(true)
            self.btnDownBank:setEnabled(true)
            self.btnNotUpBank:setBright(true)
            self.btnNotUpBank:setEnabled(true)
            self.btnUpBank:setBright(true)
            self.btnUpBank:setEnabled(true)
        elseif state == 6 then
            self.btnDownBank:setBright(false)
            self.btnDownBank:setEnabled(false)
            self.btnNotUpBank:setBright(true)
            self.btnNotUpBank:setEnabled(true)
            self.btnUpBank:setBright(true)
            self.btnUpBank:setEnabled(true)
        elseif state == 5 then
            self.btnDownBank:setBright(true)
            self.btnDownBank:setEnabled(true)
            self.btnNotUpBank:setBright(false)
            self.btnNotUpBank:setEnabled(false)
            self.btnUpBank:setBright(true)
            self.btnUpBank:setEnabled(true)
        elseif state == 3 then
            self.btnDownBank:setBright(true)
            self.btnDownBank:setEnabled(true)
            self.btnNotUpBank:setBright(true)
            self.btnNotUpBank:setEnabled(true)
            self.btnUpBank:setBright(false)
            self.btnUpBank:setEnabled(false)
        elseif state == 1 then
            self.btnDownBank:setBright(true)
            self.btnDownBank:setEnabled(true)
            self.btnNotUpBank:setBright(false)
            self.btnNotUpBank:setEnabled(false)
            self.btnUpBank:setBright(false)
            self.btnUpBank:setEnabled(false)
        end
    end
end

function GameGongNiuOptLayer:clearForClickReady()
    self:setBetBtnVisible(false)
    self.bankOptNode:setVisible(false)
    self.readyNode:setVisible(false)
end

function GameGongNiuOptLayer:setGuodiScore(score)
    self.guoScore:setString(score or "0")
end

function GameGongNiuOptLayer:showOptClock(time)
    self.clockBg:setVisible(true)
    self.timesTxt:setString(time or 0)
end

function GameGongNiuOptLayer:onEixt()

end

return GameGongNiuOptLayer