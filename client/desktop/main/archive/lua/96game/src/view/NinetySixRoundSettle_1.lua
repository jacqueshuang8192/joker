--单局结算

local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local NinetySixRoundSettle = class("NinetySixRoundSettle", NewViewBaseLayer)
local GameCommon = require("hall.GameCommon")
local NinetySixPokerCard = require("96game.src.view.NinetySixPokerCard")
local NinetySixDefine = require("96game.src.ctrl.NinetySixDefine")
function NinetySixRoundSettle:ctor(scene)
    self.scene = scene
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic
    self.card_scale = 0.3
    self.scene.isShowRund = true
    NinetySixRoundSettle.super.ctor(self, "96game/res/csb/NinetySixRoundSettle.csb")
    self:setName("NinetySixRoundSettle")
    self.scene:addChild(self)
    
    self:initData()
    self:initUI()
end

function NinetySixRoundSettle:onEnter()
    self.tEvents = {
        GameEvent:addListen("NinetySixNextShowSettlement", handler(self, self.onShowMe)),
        GameEvent:addListen("NinetySixSettlementButton", handler(self, self.onShowButton)),
    }
end

function NinetySixRoundSettle:onExit()
    for k, e in pairs(self.tEvents) do
        GameEvent:delListen(e)
    end
end
function NinetySixRoundSettle:onShowButton()
    if tolua.isnull(self.Button_end) == false then
        self.Button_end:setVisible(true)
        self.Button_again:setVisible(false)
    end

end
function NinetySixRoundSettle:onShowMe()
    self:setVisible(true)
end

function NinetySixRoundSettle:initData()

end

function NinetySixRoundSettle:initUI()
    --[[
    self._csbNode = cc.CSLoader:createNode("96game/res/csb/NinetySixRoundSettle.csb")
    self.scene:addChild(self._csbNode)

    self.Panel_center = self._csbNode:getChildByName("Panel_center")
    self.Panel_bottom = self._csbNode:getChildByName("Panel_bottom")

    self.Image_title = self.Panel_center:getChildByName("Image_title")
    self.Text_hu = self.Panel_center:getChildByName("Text_hu")

    self.Panel_group1 = self.Panel_center:getChildByName("Panel_group1")
    self.Panel_group2 = self.Panel_center:getChildByName("Panel_group2")

    self.Button_again = self.Panel_bottom:getChildByName("Button_again")
    self.Button_kanshoupai = self.Panel_bottom:getChildByName("Button_kanshoupai")
    self.Button_returnhall = self.Panel_bottom:getChildByName("Button_returnhall")
    --]]

    self.Button_again:addClickEventListener(handler(self, self.onClickAgain))
    self.Button_kanshoupai:addClickEventListener(handler(self, self.onClickHide))
    self.Button_returnhall:addClickEventListener(handler(self, self.onClickBack))
    self.Button_end:addClickEventListener(handler(self, self.onClickShowTotal))
    for i = 1, 4 do
        local player = self.Panel_center:getChildByName("player" .. i)
        player:setVisible(false)
    end
    self.Button_end:setVisible(false)
    self.Button_again:setVisible(false)
    if self.logic.curRound >= self.logic.totalRound or self.ctrl.receive.totalSettlePack then
        self.Button_end:setVisible(true)
    else
        self.Button_again:setVisible(true)
    end

end

function NinetySixRoundSettle:doTest(  )
    local test1 = {}
    local test2 = {}
    for i = 1, math.random(5, 8) do
        local tbl = {cbActiveType = math.random(0, 9), score = math.random(1, 9), cbCardData = {}, huCardId = 0}
        for a = 2, math.random(2, 5) do
            local idx = math.random(1, #self.logic.card_config)
            table.insert(tbl.cbCardData, self.logic.card_config[idx])
        end
        table.insert(test1, tbl)
    end

    for a = 2, math.random(10, 60) do
        local idx = math.random(1, #self.logic.card_config)
        table.insert(test2, self.logic.card_config[idx])
    end
    self:updateGroupCards1(test1)
    self:updateGroupCards2(test2)

    for i = 1, 4 do
        local player = self.Panel_center:getChildByName("player" .. i)
        player:setVisible(true)
    end

    local res = "ninetysix_poker_lose.png"
    if math.random(0, 1) == 1 then
        res = "ninetysix_poker_win.png"
    end
    self.Image_title:loadTexture(res, 1)
end

function NinetySixRoundSettle:setPackData(pack)
    dump("self.logic..curRound",self.logic.curRound)
    dump(" self.totalRound", self.logic.totalRound)
    if pack == nil then
        self:doTest()
        return
    end

    local userHu = pack.huUserSeatid or self.logic.mySeatId
    local res = "ninetysix_poker_lose.png"
    if userHu == self.logic.mySeatId then
        res = "ninetysix_poker_win.png"
    end

    if pack.nRoundResult == 0 then
        res = "ninetysix_poker_liuju.png"
    end
    self.Image_title:loadTexture(res, 1)

    local str = nil
    local cfg = self.logic.tOptStr[pack.huType]
    if cfg then
        str = cfg.str
    end
    self.Text_hu:setString(str or tostring(pack.huType))

    local curViewId = 1
    for k, player in pairs(pack.tPlayers) do
        local p = self.logic:getPlayerByUid(player.uid)
        if p then
            player.seatId = p.seatId
            player.sex = p.sex
        else
            assert(false, "not found this user:", player.uid)
        end

        if player.seatId == userHu then
            self:updatePlayer(1, player)
            self:updateGroupCards1(player.m_byTableCardData, pack)
        else
            curViewId = curViewId + 1
            self:updatePlayer(curViewId, player)
        end
    end

    self:updateGroupCards2(pack.m_cbPileCardData) 
end

function NinetySixRoundSettle:updateGroupCards1(data, pack)
    self.Panel_group1:removeAllChildren()
    local x, y, zorder
    local pokerHu = NinetySixPokerCard.new(self, self.Panel_group1, self.card_scale) --138, 188
    pokerHu:setCardId(pack.huCardId)
    pokerHu:setState(2)
    pokerHu:setPosition(595.00, 176)
    pokerHu:setLocalZOrder(999)
    if pokerHu and pack.huCardId >0 then
        pokerHu:showLight(2)
        pokerHu:showHu()
    end
    for i, t in ipairs(data) do
        x = 25 + ((i - 1) % 10) * 60
        local m_isZiMo = t.m_isZiMo
        local cardType = t.cbActiveType
        local str = ""
        local cfg = self.logic.tOptStr[t.cbActiveType]
        if cfg then
            str = cfg.str
        end

        local text1 = ccui.Text:create(str, "96game/res/font/FZY3JW.TTF", 22)
        text1:setColor(cc.c3b(0x66, 0x38, 0x1a))
        text1:setPosition(cc.p(x, 175))
        self.Panel_group1:addChild(text1)
        
        for k, v in ipairs(t.cbCardData) do
            y = 130 - (k - 1) * 30
            zorder = x + k

            local poker = NinetySixPokerCard.new(self, self.Panel_group1, self.card_scale) --138, 188
            poker:setCardId(v)
            if NinetySixDefine.ZOU == cardType or NinetySixDefine.BAN_ZHAO == cardType or NinetySixDefine.MAN_ZHAO == cardType then
                if (k == 1 or k == 2 or k == 3) and m_isZiMo ==1 then
                    poker:setState(1)
                else
                    poker:setState(2)
                end
            else
                if NinetySixDefine.SAO == cardType then
                    if (k == 1 or k == 2 ) then
                        poker:setState(1)
                    else
                        poker:setState(2)
                    end
                else
                    poker:setState(2)
                end

            end

            poker:setPosition(x, y)
            poker:setLocalZOrder(zorder)
            --if pack and pack.huCardId == v then
            --    poker:showLight(2)
            --    poker:showHu()
            --end
        end

        local text2 = ccui.Text:create(t.score or "", "96game/res/font/FZY3JW.TTF", 24)
        text2:setColor(cc.c3b(0x56, 0x28, 0x0b))
        text2:setPosition(cc.p(x, -10))
        self.Panel_group1:addChild(text2)
    end
end

--底牌数据
function NinetySixRoundSettle:updateGroupCards2(cards)
    self.Panel_group2:removeAllChildren()
    local x, y
    for k, v in ipairs(cards) do
        x = 25 + ((k - 1) % 30) * 25
        y = 40 - math.floor((k - 1) / 30) * 30

        local poker = NinetySixPokerCard.new(self, self.Panel_group2, self.card_scale) --138, 188
        poker:setCardId(v)
        poker:setState(2)
        poker:setPosition(x, y)
    end
end

function NinetySixRoundSettle:updatePlayer(idx, data)
    local player = self.Panel_center:getChildByName("player" .. idx)
    local Head = player:getChildByName("Head")
    local Text_info1 = player:getChildByName("Text_info1")
    local Text_info2 = player:getChildByName("Text_info2")
    local PiaoScore = player:getChildByName("PiaoScore")
    local Piao_Txt = PiaoScore:getChildByName("Piao_Txt")
    local Image_banker = player:getChildByName("Image_banker")
    local Image_win = player:getChildByName("Image_win")
    local Text_win = player:getChildByName("Text_win")

    if data.turnChip > 0 then
        Image_win:loadTexture("ninetysix_poker_win2.png", 1)
        Text_win:setColor(cc.c3b(0xff, 0x5e, 0x1f))
        Text_win:setString("+" .. tostring(data.turnChip / 100))
    else
        Image_win:loadTexture("ninetysix_poker_lose2.png", 1)
        Text_win:setColor(cc.c3b(0x56, 0x28, 0x0b))
        Text_win:setString(data.turnChip / 100)
    end

    player:setVisible(true)
    Piao_Txt:setString(data.m_nPiao or "0")
    Text_info1:setString(GameCommon:formatNick(data.nickName))
    Text_info2:setString(data.chips)
    Image_banker:setVisible(data.seatId == self.logic.bankerSeatId)
    Head:setVisible(true)
    GameCommon:getUserHead(data.portrait, data.uid, data.sex, Head, 70, false, data.nickName)
end

function NinetySixRoundSettle:onClickBack(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.ctrl:returnToHall()
end
function NinetySixRoundSettle:onClickShowTotal(sender)
    local pack =self.ctrl.receive.totalSettlePack
    if pack == nil then
        return
    end
    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end
    local data = {}
    data["resultSceneType"] = 2 --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = self.logic.inviteCode --房间号
    data["fenchang"] = "" --分场
    data["round"] = GAME_ROUND --.."/"..GROUP_TOTAL_ROUND                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M") --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data["activity_id"] = USER_INFO["activity_id"]
    data["resultData"] = {}

    for uid, user_info in pairs(pack.playerlist) do
        local user_result = {} --玩家数据实体
        user_result["nick"] = user_info["nickName"] --昵称
        user_result["uid"] = user_info.uid --uid
        user_result["icon_url"] = user_info["portrait"] --头像链接
        user_result["sex"] = user_info["sex"] --性别
        user_result["isRoomOwer"] = 0 --是否为房主，1是，非1或不填不是
        if user_info["chips"] > 0 then
            user_result["isWinner"] = 1 --是否为赢家，1是，非1或不填不是
        else
            user_result["isWinner"] = 0
        end
        user_result["total"] = user_info["chips"] --总输赢分

        user_result["gameDetail"] = {} --游戏详情数组
        local gameDetail1 = {} --游戏详情实体
        gameDetail1["showName"] = "赢的次数" --展示名
        gameDetail1["value"] = user_info["win_num"] or 0 --值

        local gameDetail2 = {}
        gameDetail2["showName"] = "输的次数"
        gameDetail2["value"] = user_info["lose_num"] or 0

        table.insert(user_result["gameDetail"], gameDetail1)
        table.insert(user_result["gameDetail"], gameDetail2)
        table.insert(data["resultData"], user_result)
    end
    --返回大厅按钮点击事件
    local backHall_action = function(sender, event)
        self.ctrl:returnToHall()
    end

    --再来一局
    local extend_action = function(sender, event)
        self.ctrl:onceAgain()
    end

    --分享按钮点击事件
    local share_action = function(sender, event)
        self.ctrl:doShareScreen()
    end
    -- require(GameResultScene_filePath):showScene(data, backHall_action, share_action)
    require("hall.settlement.settlement").new(data, backHall_action, share_action, nil, extend_action)
end
function NinetySixRoundSettle:onClickAgain(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self.scene.isShowRund = false
    GROUP_96 = false
    self._csbNode:removeFromParent()
    self.logic:nextRoundClean()
    self.ctrl.send:sendReady(1)
    GameEvent:dispatch("NinetySixNextRoundClean")
    --GameEvent:dispatch("NinetySixTheNextRoundClean")

end

function NinetySixRoundSettle:onClickHide(sender)
    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
    self:setVisible(false)
    GameEvent:dispatch("NinetySixNextShowSettleBtn")
end
return NinetySixRoundSettle
