--玩家头像
local SanGongPanelPlayer = class("SanGongPanelPlayer")
local PokerCard = require('hall.PokerCard')
local SanGongDefine = require("sangong_new.src.ctrl.SanGongDefine")

function SanGongPanelPlayer:ctor(scene, parent, viewId)
    self.scene = scene
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic

    self.viewId = viewId
    self.node = parent:getChildByName("player_plane_" .. viewId)
    self.tPokerCards = {}
    self:initUI()
    self:playerExit()

    if self.logic.bIsTest then
        self:doTest()
    end
end

function SanGongPanelPlayer:onEnter()
    self.tEvents = {
        GameEvent:addListen("SanGongLoginRoomInfo", handler(self, self.playerExit)),
        GameEvent:addListen("SanGongAddPlayer", handler(self, self.setPlayer)),
        GameEvent:addListen("SanGongDelPlayer", handler(self, self.delPlayerByUid)),
        GameEvent:addListen("SanGongPlayerDisconnect", handler(self, self.playerDisconnect)),
        GameEvent:addListen("SanGongChangeBankerSeat", handler(self, self.changeBanker)),
        GameEvent:addListen("SanGongReadyStatus", handler(self, self.setReadyImageShow)),
        GameEvent:addListen("SanGongDealCards", handler(self, self.onDealCards)),
        GameEvent:addListen('SanGongNextRoundClean', handler(self, self.nextRoundClean)),
        GameEvent:addListen('SanGongSetBetAndGold', handler(self, self.setBetAndGold)),
        GameEvent:addListen('UpdateSanGongPlayerGold', handler(self, self.updateGold)),
        GameEvent:addListen('SanGongPlayerOpenCards', handler(self, self.openCards)),
        GameEvent:addListen("UpdateSanGongGameStatus", handler(self, self.updateGameStatus)),
        GameEvent:addListen("SanGongSettlementPlayer", handler(self, self.onSettlement)),
    }
end

function SanGongPanelPlayer:updateGameStatus(st)
    if st ~= SanGongDefine.WAIT_STATUS and st ~= SanGongDefine.END_STATUS then
        self:hideReadyImage()
    end
end

function SanGongPanelPlayer:onExit()
    for k, e in pairs(self.tEvents) do
        GameEvent:delListen(e)
    end
end

function SanGongPanelPlayer:initUI()
    GameUtils.setNodeNameBindObj(self.node)
    self.headWSPos = self.node.head_plane:convertToWorldSpace(self.node.head_plane.head_img:getPosition())
    self.dealCardsPos = self.node.inhand_plane.cards_node:convertToNodeSpace(self.scene.dealCardWSPos)
end

function SanGongPanelPlayer:playerExit()
    self.data = nil
    self:setGrabBankerTimes(false)
    self:setBetChip(false)
    self:setEffectShow(false)
    self:hideReadyImage()
    self:setCardType(false)
    self:setHandCards(false)

    self.node.head_plane.name_txt:setVisible(false)
    self.node.head_plane.chip_txt:setVisible(false)

    self.node.head_plane.fangzhutip_img:setVisible(false)
    self.node.head_plane.zhuang_flag:setVisible(false)
    self.node.head_plane.network_img:setVisible(false)
    self.node.head_plane.score_txt:setVisible(false)
    self.node.head_plane.head_img:setVisible(false)
    self.node:setVisible(false)
end

--设置抢x1...
function SanGongPanelPlayer:setGrabBankerTimes(show, num)
    if show then
        self.node.head_plane.grab_banker_times_txt:setString(num) --抢x1
        self.node.head_plane.grab_banker_times_txt:setVisible(true)
        self.node.head_plane.grab_banker_img:setVisible(true)
    else
        self.node.head_plane.grab_banker_times_txt:setVisible(false)
        self.node.head_plane.grab_banker_img:setVisible(false)
    end
end

function SanGongPanelPlayer:setBetAndGold(uid, bet, gold)
    if self.data == nil or self.data.uid ~= uid then
        return
    end

    self:setBetChip(true, bet)
    self.node.head_plane.chip_txt:setString(gold / 100)
end

--下注筹码
function SanGongPanelPlayer:setBetChip(show, num)
    if show then
        self.node.head_plane.chip_img.bet_times_txt:setString(num / 100)
        self.node.head_plane.chip_img:setVisible(true)
    else
        self.node.head_plane.chip_img:setVisible(false)
    end
end

function SanGongPanelPlayer:setEffectShow(show)
    self.node.head_plane.effect_frame:setVisible(show)

    if show then
        local ac = cc.RepeatForever:create(
            cc.Sequence:create(
                cc.FadeOut:create(0.05),
                cc.DelayTime:create(0.15),
                cc.FadeIn:create(0.05)
            )
        )
        self.node.head_plane.effect_frame:stopAllActions()
        self.node.head_plane.effect_frame:runAction(ac)
    end
end

function SanGongPanelPlayer:updateGold(uid, gold)
    if self.data and self.data.uid == uid then
        self.node.head_plane.chip_txt:setString(gold / 100)
    end
end

function SanGongPanelPlayer:updateUser()
    if self.data == nil then
        return
    end

    local common = require("hall.GameCommon")
    self.node.head_plane.name_txt:setString(common:formatNick(self.data.nickName))
    self.node.head_plane.chip_txt:setString(self.data.gold / 100)
    self.node.head_plane.name_txt:setVisible(true)
    self.node.head_plane.chip_txt:setVisible(true)

    local isok = self.logic.gameStatus == SanGongDefine.WAIT_STATUS or self.logic.gameStatus == SanGongDefine.END_STATUS
    self.node.head_plane.ready_img:setVisible(self.data.ready == 1 and isok)
    self.node.head_plane.fangzhutip_img:setVisible(self.logic.ownerId == self.data.uid)
    self.node.head_plane.zhuang_flag:setVisible(self.logic.bankerSeatId == self.data.seatId)
    self.node.head_plane.score_txt:setVisible(false)
    self.node.head_plane.network_img:setVisible(self.data.onLine == 0)

    local head = self.node.head_plane.head_img
    head:setVisible(true)
    common:getUserHead(self.data.portrait, self.data.uid, self.data.sex, head, 70, false, self.data.nickName)
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(self.data.uid, self.headWSPos)
end

function SanGongPanelPlayer:doTest()
    local data = {
        portrait = "",
        uid = self.viewId,
        seatId = self.viewId,
        nickName = "test" .. self.viewId,
        gold = math.random(100, 9999),
        ready = math.random(0, 1),
        sex = math.random(1, 2),
        onLine = math.random(0, 1),

    }
    self:setPlayer(self.viewId, data)

    local tbl = PokerCard:CardIdTbl()
    local list = {tbl[math.random(1, #tbl)], tbl[math.random(1, #tbl)], tbl[math.random(1, #tbl)]}
    self:setHandCards(true, list)
    self:setCardType(true, math.random(0, 11), math.random(0, 3))
    -- self:setEffectShow(true)
    self:setBetChip(true, math.random(1, 88))
end

function SanGongPanelPlayer:setPlayer(viewId, data)
    if viewId ~= self.viewId then
        return
    end
    self.data = data
    self:updateUser()
    self.node:setVisible(true)
end

function SanGongPanelPlayer:playerDisconnect(uid, onLine)
    if self.data and self.data.uid == uid then
        self.node.head_plane.network_img:setVisible(onLine == 0)
    end
end

function SanGongPanelPlayer:setReadyImageShow(uid, ready)
    if self.data and self.data.uid == uid then
        local isok = self.logic.gameStatus == SanGongDefine.WAIT_STATUS or self.logic.gameStatus == SanGongDefine.END_STATUS
        self.node.head_plane.ready_img:setVisible(ready == 1 and isok)
        self:nextRoundClean()
    end
end

function SanGongPanelPlayer:hideReadyImage()
    self.node.head_plane.ready_img:setVisible(false)
end

function SanGongPanelPlayer:delPlayerByUid(uid)
    if self.data and self.data.uid == uid then
        self:playerExit()
    end
end

function SanGongPanelPlayer:changeBanker()
    self.node.head_plane.zhuang_flag:setVisible(self.data and self.logic.bankerSeatId == self.data.seatId)
end

function SanGongPanelPlayer:nextRoundClean()
    self:setGrabBankerTimes(false)
    self:setBetChip(false)
    self:setEffectShow(false)
    self:setCardType(false)
    self:setHandCards(false)
    self.node.head_plane.score_txt:setVisible(false)
end

function SanGongPanelPlayer:setCardType(show, cards_point, cards_type)
    if show then
        self.node.inhand_plane.Image_state_bg:setVisible(true)
        local str
        if cards_type == 1 then
            str = 'sangong_new/res/images/card_type1_' .. cards_point .. '.png'
        elseif cards_type == 2 then
            str = 'sangong_new/res/images/card_type_10.png'
        elseif cards_type == 3 then
            str = 'sangong_new/res/images/card_type_11.png'
        else
            str = 'sangong_new/res/images/card_type_' .. cards_point .. '.png'
        end

        self.node.inhand_plane.Image_state_bg.card_type:loadTexture(str, 1)
        self.node.inhand_plane.Image_state_bg.card_type:ignoreContentAdaptWithSize(true)
    else
        self.node.inhand_plane.Image_state_bg:setVisible(false)
    end
end

function SanGongPanelPlayer:setHandCards(show, list, isDeal)
    if show then
        self.node.inhand_plane.cards_node:setVisible(true)
        local scale, gap = 0.6, 70
        local x, y = 70, 85
        if self.viewId == 1 then
            scale, gap = 1.2, 120
            x, y = 180, 150
        end
        for i, card in ipairs(list) do
            local poker = self.tPokerCards[i]
            if poker == nil then
                poker = PokerCard.new(scale)
                table.insert(self.tPokerCards, poker)
                self.node.inhand_plane.cards_node:addChild(poker)
            end

            poker:setVisible(true)
            poker:setCardId(tonumber(card))
            if isDeal then
                if self.viewId ~= 1 then
                    poker:showBack()
                else
                    if i == 1 then
                        poker:showFront()
                    else
                        poker:showBack()
                    end
                end

                poker:setPosition(self.dealCardsPos)
                poker:setScale(0.5)
                local function doCall()
                    -- poker:showFront()
                end

                local a1 = cc.DelayTime:create(i * 0.1)
                local a3 = cc.MoveTo:create(0.2, cc.p(x + (i - 1) * gap, y))
                local a4 = cc.ScaleTo:create(0.2, 1)
                local spaw = cc.Spawn:create(a3, a4)
                local cbAction2 = cc.CallFunc:create(doCall)
                poker:runAction(cc.Sequence:create(a1, spaw, cbAction2, cbAction))
            else
                poker:setScale(1)
                poker:showFront()
                poker:setPosition(x + (i - 1) * gap, y)
            end
        end
    else
        for _, p in pairs(self.tPokerCards) do
            p:setVisible(false)
        end
        self.node.inhand_plane.cards_node:setVisible(false)
    end
end

function SanGongPanelPlayer:onDealCards()
    if self.data and self.data.handCardArr then
        self:hideReadyImage()
        self:setHandCards(true, self.data.handCardArr, true)
    end
end

function SanGongPanelPlayer:openCards(uid, voice, isManual)
    if not (self.data and self.data.uid == uid) then
        return
    end
    self:setHandCards(true, self.data.handCardArr, false)

    if isManual then
        return
    end

    self:setCardType(true, self.data.cards_point, self.data.cards_type)
    if voice then

    end
end


function SanGongPanelPlayer:onSettlement(pp)
    if not (self.data and pp and self.data.uid == pp.uid) then
        return
    end

end

--[[
function SanGongPanelPlayer:showCoinFlyAnimation(pack)
    math.randomseed(os.time())

    local tbWin = {}
    for k, v in pairs(pack.userinfo) do
        local playerType = SANGONG_PLAYERTYPE_TABLE[v.uid]
        if playerType then
            local userinfo = SANGONG_USERINFO_TABLE[v.uid]
            SANGONG_USERINFO_TABLE[v.uid].gold = SanGongUtils:goldMath(v.chips)
            GamePlaneOperator:updateCoin(playerType, v.score / 100, userinfo.gold)
            GamePlaneOperator:setCoin(playerType, SANGONG_USERINFO_TABLE[v.uid].gold)
            if v.score >= 1 then
                tbWin[v.uid] = v.score / 100
            end
        end
    end

    local coinfly
    local sceneNow = SCENENOW['scene']
    coinfly = function(oriPos, targetPos, i)
        local delaytime = i * 0.01 + math.random(-2, 2) / 1000
        sceneNow:performWithDelay(
            function()
                oriPos = cc.pAdd(oriPos, cc.p(math.random(-30, 30), math.random(-30, 30)))
                local coin_sp = display.newSprite(coin_img_path):setPosition(oriPos):setScale(0.8)
                sceneNow:addChild(coin_sp, 100)
                targetPos = cc.pAdd(targetPos, cc.p(math.random(-0, 0), math.random(-0, 0)))
                local middleY = (targetPos.y + oriPos.y) / 2
                local q1 = cc.p((targetPos.x - oriPos.x) * 0.56 + oriPos.x, (targetPos.y - oriPos.y) * 0.44 + oriPos.y)
                local q2 = cc.p((targetPos.x - oriPos.x) * 0.67 + oriPos.x, (targetPos.y - oriPos.y) * 0.8 + oriPos.y)
                local mb = cc.BezierTo:create(0.4, {q1, q2, targetPos})
                local fo = cc.FadeOut:create(0.4)
                local seq = cc.Sequence:create(mb, fo, cc.RemoveSelf:create()) --cc.DelayTime:create(0.4),
                coin_sp:runAction(seq)
            end,
            delaytime
        )
    end
    local size = sceneNow:getContentSize()
    local oriPosition = cc.p(size.width / 2, size.height / 2)
    --显示更新内容（文字和筹码）
    for uid, value in pairs(tbWin) do
        local playerType = SANGONG_PLAYERTYPE_TABLE[uid]
        local targetPos = PLAYER_HEADS_POSITION_TABLE[uid]
        if playerType then
            local coin_count = 20
            for idx = 1, coin_count do
                --筹码飞动
                coinfly(oriPosition, targetPos, idx)
            end
        end
    end
end
--]]

return SanGongPanelPlayer