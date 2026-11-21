--[[
* author:   zwm
* date:     2020-09-27
* describe: 牛牛操作按钮界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local NiuNiuSendHandle = import("NewNiuniu.src.protocol.NiuNiuSendHandle")
local ViewBaseLayer = require("hall.ViewBaseLayer")
local GameOptLayer = class("GameOptLayer", ViewBaseLayer)

function GameOptLayer:ctor()
    GameOptLayer.super.ctor(self, "NewNiuniu/res/csb/gameOptLayer.csb")
    DESIGN_SCREEN_WIDTH = 1920
    DESIGN_SCREEN_HEIGHT = 1080

    SCREEN_WIDTH = 1280--cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = 720 -- cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    self._csbNode:setScale(SCREEN_WIDTH / DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT / DESIGN_SCREEN_HEIGHT)
end

function GameOptLayer:onEnter()
    local voice_bt_worldpoint = self:convertToWorldSpace(self.btnVoice:getPosition())
    
    local VoiceRecordView = require('hall.VoiceRecord.VoiceRecordView')
    if VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(self.btnVoice, 999)
    else
        VoiceRecordView:showView(voice_bt_worldpoint.x, voice_bt_worldpoint.y, 999)
    end

    
    self:createQiangBankerBtn()
    self:createBetBtn()
    self:initUI()
end

function GameOptLayer:initUI()
    self.btnReady:setVisible(false)
    self.btnStartGame:setVisible(false)
    self.btnGameConfigMsg:setVisible(false)
    self.btnCopyRoom:setVisible(false)
    self.btnInvite:setVisible(false)
    self.btnCuoPai:setVisible(false)
    self.btnFanPai:setVisible(false)
    self.btnHuikan:setVisible(false)
end

function forTestGlod()
    local temp = {}
    temp.uid = 10019
    temp.win_times = 5
    temp.win_chip = 500
    temp.chips = 5238
    temp.handCards = {0x03, 0x08, 0x09, 0x0c, 0x2b}
    local result = {}
    result.bonusPool = 0
    result.userinfo = {}
    result.handCards = {0x03, 0x08, 0x09, 0x0c, 0x2b}
    result.banker_uid = 10019
    result.banker_win_times = 5
    result.banker_win_chip = 156
    result.banker_chips = 3000
    result.time = 2
    result.round = 8
    result.guodi = 2000

    for i = 1, 10 do
        local t = clone(temp)
        t.uid = t.uid + (i - 1)
        t.win_chip = i > 5 and (t.win_chip - 1000) or t.win_chip
        table.insert(result.userinfo, t)
    end

    return result
end

function GameOptLayer:onClickBtnReady(sender, event)
    -- local idxLst = {1,2,3,4, 5}
    -- g_mainScene._myHandCards = {0x03, 0x08, 0x09, 0x0c, 0x0d}
    -- g_mainScene.gameUserInfoLayer:showSendCardAni(idxLst)

    -- g_mainScene.gameUserInfoLayer:showGoldMoveAni(forTestGlod())
    -- g_mainScene.gameUserInfoLayer.grabBankerUid = {}
    -- g_mainScene.gameUserInfoLayer:showSelectZhuanAni(10019)
    g_mainScene.gameUserInfoLayer:clearForClickReady()
	NiuNiuSendHandle:readyNow(1)
end


function GameOptLayer:onClickBtnSetting(sender, event)
	g_mainScene:loadMoreFuncLayer()
end

-- function GameOptLayer:onClickBtnVoice(sender, event)
	-- NiuNiuSendHandle:readyNow(1)
-- end

function GameOptLayer:onClickBtnMsg(sender, event)
	g_mainScene:loadGameMsgLayer()
end

function GameOptLayer:onClickBtnStartGame(sender, event)
    self.btnStartGame:setVisible(false)
	NiuNiuSendHandle:StartGame()
end

function GameOptLayer:onClickBtnGameConfigMsg(sender, event)
	-- if isOpenControl == true then
        local gameConfigTable = self:getGameConfig()
        require('hall.util.GameMenu'):showConfigPanel(gameConfigTable)
    -- end
end

-- function GameOptLayer:onClickBtnCopyRoom(sender, event)
-- 	NiuNiuSendHandle:readyNow(1)
-- end

function GameOptLayer:onClickBtnInvite(sender, event)
	local paras = {}
    paras['desc'] = USER_INFO['gameConfigMsg'] or ' '
    paras['imagePath'] = 'url'
    paras['name'] = '牛牛，房号：' .. USER_INFO['invote_code']
    paras['showType'] = 2
    paras['url'] = appDownLoadAddress
    local shareLayer = require('hall.share.ShareLayer').new(paras)
    if shareLayer then
        shareLayer:addTo(g_mainScene, 9999999)
    end
end

function GameOptLayer:onClickBtnCuoPai(sender, event)
	local cardUint = g_mainScene._myHandCards[5]
    print("onClickBtnCuoPai -----------------", cardUint)
	require('NewNiuniu.src.view.LayerShuffling').new(cardUint)
end

function GameOptLayer:onClickBtnFanPai(sender, event)
    g_mainScene.gameUserInfoLayer:turnMyLastCards()
    NiuNiuSendHandle:sendMycards({0, 0, 0})
end

function GameOptLayer:onClickBtnGiveupBanker(sender, event)
	NiuNiuSendHandle:qiang(0)
end

-- function GameOptLayer:onClickBtnQiang1(sender, event)
-- 	NiuNiuSendHandle:readyNow(1)
-- end

function GameOptLayer:onClickBtnHuikan(sender, event)
	NiuNiuSendHandle:readyNow(1)
end

function GameOptLayer:createQiangBankerBtn()
    for i = 1, 4 do
        local qiangBtn = self.btnBet:clone()--:setScale(72/128)
        self["qiangBtn"..i] = qiangBtn        
        qiangBtn:setName("qiangBtn"..i)
        qiangBtn:addTo(self.root)
        qiangBtn:addTouchEventListener(handler(self, self.onClickGrabBanker))
    end
end

function GameOptLayer:onClickGrabBanker(sender, event)
    if event == TOUCH_EVENT_ENDED then
        local name = sender:getName()
        local value = sender.getGrabValue
        if value ~= nil then
            NiuNiuSendHandle:qiang(value)
        end
    end
end

function GameOptLayer:showGrabBankerBtn(grabTimes)
    self.btnGiveupBanker:setPosition(self:getPositionByIdx(1, #grabTimes + 1))
    for i, v in ipairs(grabTimes or {}) do
        self["qiangBtn"..i].getGrabValue = v
        local name = self["qiangBtn"..i]:getChildByName("name")
        name:setString(string.format("%d倍", v))
        local pos = self:getPositionByIdx((i+1), #grabTimes + 1)
        self["qiangBtn"..i]:setPosition(pos)
    end
end

function GameOptLayer:getPositionByIdx(idx, size)
    local h = 380
    if (size % 2) == 0 then
        local mid = (size)/2
        return cc.p((960 - 150 + (idx - mid)*300)*self:_getScaleParam2(), h)
    else
        local mid = (size + 1)/2
        return cc.p((960 + (idx - mid)*300)*self:_getScaleParam2(), h)
    end
end

function GameOptLayer:hideGrabBankerBtn()
    self.btnGiveupBanker:setPosition(cc.p(-500, 380))
    for i = 1, 4 do
        self["qiangBtn"..i]:setPosition(cc.p(-500, 380))
    end
end

function GameOptLayer:createBetBtn()
    for i = 1, 5 do
        local betBtn = self.btnBet:clone()--:setScale(72/128)
        self["betBtn"..i] = betBtn        
        betBtn:setName("betBtn"..i)
        betBtn:addTo(self.root)
        betBtn:addTouchEventListener(handler(self, self.onClickBet))
    end
end

function GameOptLayer:onClickBet(sender, event)
    if event == TOUCH_EVENT_ENDED then
        local name = sender:getName()
        local value = sender.betValue
        if value ~= nil then
            NiuNiuSendHandle:addBase(value)
        end
    end
end

function GameOptLayer:showBetBtn(bets)
    for i, v in ipairs(bets or {}) do
        self["betBtn"..i].betValue = v
        local name = self["betBtn"..i]:getChildByName("name")
        name:setString(string.format("%d分", v))
        local pos = self:getPositionByIdx((i), #bets)
        self["betBtn"..i]:setPosition(pos)
    end
end

function GameOptLayer:hideBetBtn()
    for i = 1, 5 do
        self["betBtn"..i]:setPosition(cc.p(-500, 380))
    end
end

function GameOptLayer:setStartGameBtnVisible(flag)
    self.btnStartGame:setVisible(flag)
end

function GameOptLayer:setShareVisible(flag)    
    self.btnCopyRoom:setVisible(flag)
    self.btnInvite:setVisible(flag)
end

function GameOptLayer:setOptCardsVisible(flag)    
    local info = g_mainScene.gameUserInfoLayer.allUserInfo[USER_INFO.uid]
    if info == nil or (not info._isPlaying) then
        return
    end

    if flag and g_mainScene:canCuoPai() then
        self.btnCuoPai:setVisible(true)
    else
        self.btnCuoPai:setVisible(false)
    end
    self.btnFanPai:setVisible(flag)
end

function GameOptLayer:onEixt()
	-- body
end

return GameOptLayer