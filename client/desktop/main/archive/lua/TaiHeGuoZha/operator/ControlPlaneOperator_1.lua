--
-- Author: Your Name
-- Date: 2017-09-05 19:57:03
local ControlPlaneOperator = class("ControlPlaneOperator")

local ddzServer = require("TaiHeGuoZha.ddzServer")
local unpack = table.unpack or unpack
local CardAnalysis, CARDTYPE = unpack(require("TaiHeGuoZha.CardAnalysis"))
local Card = require("TaiHeGuoZha.Card")
local CardPlaneOperator = require("TaiHeGuoZha.operator.CardPlaneOperator")

function ControlPlaneOperator:init()
    local CardPlaneOperator = require("TaiHeGuoZha.operator.CardPlaneOperator")

    layout_ui = cardScene:getChildByName("layout_ui")

    self.btn_showGroupResult = layout_ui:getChildByName("btn_showGroupResult"):setVisible(false)
    self.btn_returnToHall = layout_ui:getChildByName("btn_returnToHall"):setVisible(false)

    local checkGroupResult = function(sender, event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            if sender == self.btn_showGroupResult then
                local GameResult = SCENENOW["scene"]:getChildByName("gameresultScene")
                if GameResult then
                    GameResult:setVisible(true)
                end
            elseif sender == self.btn_returnToHall then
                if SCENENOW["scene"].initData then
                    SCENENOW["scene"]:initData("release")
                end
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
            end
        end
    end

    self.btn_showGroupResult:addTouchEventListener(checkGroupResult)
    self.btn_returnToHall:addTouchEventListener(checkGroupResult)

    ------------------------
    self.btn_ready = layout_ui:getChildByName("btn_ready"):setVisible(false)

    local startGameFunc = function(sender, event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            require("hall.GameCommon"):playEffectSound("TaiHeGuoZha/res/audio/Audio_Button_Click.mp3")

            if sender == self.btn_ready then
                ddzServer:CLI_READY_GAME(1)
            end
        end
    end

    self.btn_ready:addTouchEventListener(startGameFunc)

    -------------------------------
    self.operate_btns = layout_ui:getChildByName("operate_btns"):setVisible(false)

    self.btn_pass = self.operate_btns:getChildByName("btn_pass")
    self.btn_tip = self.operate_btns:getChildByName("btn_tip")
    self.btn_discard = self.operate_btns:getChildByName("btn_discard")

    self.btn_pass:onClick(
        function(sender, event)
            ddzServer:CLI_PASS()
            --选的牌收回
            CardPlaneOperator:resetCards()
            --消息发送隐藏按钮
            self:showControlButtons(4, false)
        end
    )

    self.btn_tip:onClick(
        function(event)
            local tipCards = CardAnalysis:GetTipCard()
            if tipCards and tipCards.clientCard then
                CardPlaneOperator:popCard(tipCards.clientCard)
            else
                ddzServer:CLI_PASS()
                --选的牌收回
                self:showControlButtons(4, false)
            end
        end
    )

    self.btn_discard:onClick(
        function( event)
            local chids = Mycard_layout:getChildren()
            local cardData
            for i, cardNode in ipairs(chids) do
                local posy = cardNode:getPositionY()
                -- if posy == CardPlaneOperator.cardUpPosY then
                if posy == CardPlaneOperator.cardUpPosY then
                    cardData = cardNode._cardData
                    break
                end
            end
            if not cardData then
                return
            end
            local num = cardData.num
            local maxCard = cardData.maxCard
            ddzServer:CLI_OUT_CARD(num, maxCard)
            -- local isCanPlayCard = true
            -- if tbPlayCardInfo and tbPlayCardInfo.last_cards then
            --     local last_cards = tbPlayCardInfo.last_cards
            --     local value, king = Card:init(last_cards[1])
            --     local clientCard = cardData.clientCard
            --     if num == #last_cards and clientCard < value then
            --         isCanPlayCard = false
            --     elseif num < #last_cards then
            --         isCanPlayCard = false
            --     end
            -- end
            -- if isCanPlayCard then
            --     ddzServer:CLI_OUT_CARD(num, maxCard)
            -- else
            --     viewMgr:showTip({text = "出牌不符合规则"})
            -- end
        end
    ) 
end

function ControlPlaneOperator:showCheckResultButton(flag)
    self.btn_returnToHall:setVisible(flag)
    self.btn_showGroupResult:setVisible(flag)

    if flag == true then
        self:clearGameDatas()
    end
end

function ControlPlaneOperator:clearGameDatas()
    self:showControlButtons(1, false)
end

--state qiang","noqiang","nojiao","jiao","noyao","chupai"
function ControlPlaneOperator:disPlayChoice(seat, state, viewId)
    local playerType = self:getPlayerType(seat)
    if viewId ~= nil then
        playerType = viewId
    end

    local spTT = layout_ui:getChildByName("tt" .. tostring(playerType))
    if spTT then
        spTT:removeSelf()
    end

    local v_pos_effect = {
        [CARD_PLAYERTYPE_MY] = cc.p(SCREEN_WIDTH / 2, 300),
        [CARD_PLAYERTYPE_LEFT] = cc.p(300, 400),
        [CARD_PLAYERTYPE_RIGHT] = cc.p(1050, 400),
        [CARD_PLAYERTYPE_TOP] = cc.p(SCREEN_WIDTH / 2, 550)
    }

    local img_array = {
        ["noyao"] = "TaiHeGuoZha/res/images/ddz_text_buchu.png"
    }

    local music_array = {
        ["qiang"] = {"TaiHeGuoZha/res/audio/CallLandlord_QDZ_M.mp3", "TaiHeGuoZha/res/audio/CallLandlord_QDZ_W.mp3"},
        ["noqiang"] = {"TaiHeGuoZha/res/audio/CallLandlord_BQDZ_M.mp3", "TaiHeGuoZha/res/audio/CallLandlord_BQDZ_W.mp3"},
        ["nojiao"] = {"TaiHeGuoZha/res/audio/CallLandlord_BJDZ_M.mp3", "TaiHeGuoZha/res/audio/CallLandlord_BJDZ_W.mp3"},
        ["jiao"] = {"TaiHeGuoZha/res/audio/CallLandlord_JDZ_M.mp3", "TaiHeGuoZha/res/audio/CallLandlord_JDZ_W.mp3"},
        ["noyao"] = {"TaiHeGuoZha/res/audio/Audio_Pass1_M.mp3", "TaiHeGuoZha/res/audio/Audio_Pass1_W.mp3"},
        ["chupai"] = {"TaiHeGuoZha/res/audio/yasi.mp3", "TaiHeGuoZha/res/audio/dani.mp3"}
    }

    --不要的音效随机生成
    if state == "noyao" then
        math.randomseed(socket.gettime())
        local rnd = math.random(1, 4)
        local music_tb = {
            [1] = {"TaiHeGuoZha/res/audio/Audio_Pass1_M.mp3", "TaiHeGuoZha/res/audio/Audio_Pass1_W.mp3"},
            [2] = {"TaiHeGuoZha/res/audio/Audio_Pass2_M.mp3", "TaiHeGuoZha/res/audio/Audio_Pass2_W.mp3"},
            [3] = {"TaiHeGuoZha/res/audio/Audio_Pass3_M.mp3", "TaiHeGuoZha/res/audio/Audio_Pass3_W.mp3"},
            [4] = {"TaiHeGuoZha/res/audio/Audio_Pass4_M.mp3", "TaiHeGuoZha/res/audio/Audio_Pass4_W.mp3"}
        }
        music_array["noyao"] = music_tb[rnd]
    end

    --出牌的音效随机生成
    if state == "chupai" then
        math.randomseed(socket.gettime())
        local rnd = math.random(1, 3)
        local music_tb = {
            [1] = {"TaiHeGuoZha/res/audio/dani_M.mp3", "TaiHeGuoZha/res/audio/dani_W.mp3"},
            [2] = {"TaiHeGuoZha/res/audio/yasi_M.mp3", "TaiHeGuoZha/res/audio/yasi_W.mp3"},
            [3] = {"TaiHeGuoZha/res/audio/wanshang_M.mp3", "TaiHeGuoZha/res/audio/wanshang_W.mp3"}
        }
        music_array["chupai"] = music_tb[rnd]
    end

    --图片
    local img_path = img_array[state]
    local sp = display.newSprite(img_path)
    sp:setName("tt" .. tostring(playerType))
    sp:setPosition(v_pos_effect[playerType])
    layout_ui:addChild(sp)

    --音效
    local music = music_array[state]
    -- local _sex = THGZ_USERINFO_TABLE[SEAT2USERID[seat]].sex
    local _sex = 1
    if _sex == nil then
        _sex = 1
    end
    require("hall.GameCommon"):playEffectSound(music[tonumber(_sex)])
end

---------------------------------------------------------------------

--打牌的3个按钮（不出，提示， 出牌）
function ControlPlaneOperator:showFourButton(isBtnPassSta, isBtnChu)
    _notice = {}
    _hasselect = {}
    tbTipsCards["last_cards"] = nil

    local bshow = true
    self.operate_btns:setVisible(bshow)

    if isBtnPassSta == 1 then
        self.btn_pass:setVisible(true)
    else
        self.btn_pass:setVisible(false)
    end
    self.btn_tip:setVisible(true)
    if isBtnChu == 1 then
        self.btn_discard:setVisible(true)
    else
        self.btn_discard:setVisible(false)
    end
end

--准备，（抢庄）（加倍）（摊牌，出牌）  游戏操作按钮
function ControlPlaneOperator:showControlButtons(stage, flag, isBtnPassSta, isBtnChu )
    dump(stage, "游戏阶段")
    dump(flag, "显示标记")
    
    if flag == false then
        self.btn_ready:setVisible(false)
        self.operate_btns:setVisible(false) --游戏操作按钮
        return
    end
    if stage == 1 then --准备阶段
        self.btn_ready:setVisible(true)
        self.operate_btns:setVisible(false)
    elseif stage == 2 then --选搭伙阶段
        self.btn_ready:setVisible(true)
        self.operate_btns:setVisible(false)
    elseif stage == 4 then --游戏操作
        self.btn_ready:setVisible(false)
        self.operate_btns:setVisible(true)
        self:showFourButton(isBtnPassSta, isBtnChu)
    end
end

--------------------------------------------------------------

--计算出牌是否点亮
function ControlPlaneOperator:chuIfLight(cards)
    if true then
        self.btn_discard:setTouchEnabled(true)
        return
    end

    --点亮出牌
    local selectedCard = {}

    for i, cardNode in ipairs(Mycard_layout:getChildren()) do
        if cardNode.selected == 1 then
            table.insert(selectedCard, cardNode._value)
        -- return
        end
    end

    if next(selectedCard) then
        if CardPlaneOperator:checkPlayCard(false) == false then --false表示不拦截，true表示拦截
        else
            self.btn_discard:setBright(true)
            self.btn_discard:setTouchEnabled(true)
            return
        end
    end

    self.btn_discard:setBright(false)
end


--显示不出的按钮
function ControlPlaneOperator:showNot2Play()
    -- layout_ui:setTouchEnabled(true)
    self:showErrorTips("no_match")
end

--出牌错误内容
function ControlPlaneOperator:showErrorTips(errCode)
    if layout_ui:getChildByName("card_error_msg") then
        layout_ui:removeChildByName("card_error_msg")
    end

    --1dump(errCode, "出牌错误errCode")
    display.addSpriteFrames("TaiHeGuoZha/res/images/msg.plist", "TaiHeGuoZha/res/images/msg.png")
    local str = ""
    if errCode == "no_match" then --牌值小于
        str = "#TaiHeGuoZha/res/images/txt_no_match.png"
    elseif errCode == "kind_error" then --牌型不对
        str = "#TaiHeGuoZha/res/images/txt_illegal.png"
    else
        return
    end

    local sp = display.newSprite(str)

    -- sp:addTo(layout_ui)
    -- sp:setPosition(cc.p(SCREEN_WIDTH/2,100))

    local fullRect = cc.rect(0, 0, sp:getContentSize().width + 200, sp:getContentSize().height + 30)
    local imageView = ccui.ImageView:create()
    imageView:setScale9Enabled(true)
    imageView:loadTexture("TaiHeGuoZha/res/images/gold_box.png")
    imageView:setContentSize(cc.size(fullRect.width, fullRect.height))
    imageView:setPosition(SCREEN_WIDTH / 2, 80)
    imageView:setName("card_error_msg")

    layout_ui:addChild(imageView, 101)
    sp:addTo(imageView, 10)
    sp:setPosition(fullRect.width / 2, fullRect.height / 2)

    imageView:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.Hide:create()))
    if errCode == "kind_error" then
        CardPlaneOperator:resetCards()
    end
end

--检查是否最后一张牌，是--自动出牌(暂时屏蔽这个功能)
function ControlPlaneOperator:checkLastCard()
end

function ControlPlaneOperator:getPlayerType(seatId) --seatId为服务器座位号
    print("getPlayerType  ", seatId, TaiHeGuoZhaRoomInfo, TaiHeGuoZhaRoomInfo and TaiHeGuoZhaRoomInfo.maxSeatCount)
    if seatId == nil or seatId < 0 then
        return nil
    end
    print("f1")
    if not TaiHeGuoZhaRoomInfo then
        print("ddzSettings:getPlayerType error", debug.traceback())
        return nil
    end
    print("f2")
    local playerType = CARD_PLAYERTYPE_MY
    if TaiHeGuoZhaRoomInfo.maxSeatCount == 2 then
        if seatId == MY_SEAT_ID then
            playerType = CARD_PLAYERTYPE_MY
        else
            playerType = CARD_PLAYERTYPE_TOP
        end
    else
        local other_index = seatId - MY_SEAT_ID

        if other_index < 0 then
            other_index = other_index + TaiHeGuoZhaRoomInfo.maxSeatCount
        end

        playerType = other_index + 1 -- otherIndex2playerType[other_index]
        if playerType > 4 then
            playerType = 4
        end
    end

    print("f3", playerType)
    return playerType
end

return ControlPlaneOperator
