local PlaneItemOperator = class('PlaneItemOperator')

local ControlOperator = require(TpackageName .. '.lottery.ControlOperator')
local Card = require(TpackageName .. '.PokerCard')

local default_head_img = TpackageName .. '/images/lottery/kongtouxiang_d.png'

function PlaneItemOperator:init(seatId, plane)
    plane:setVisible(false)
    self:clearGameDatas(plane)

    local text_player_index = plane:getChildByName('my_bet_chip')
    local btn_panel = plane:getChildByName('btn_panel')
    local image = btn_panel:getChildByName('image'):setVisible(false)

    -- local detail_panel = plane:getChildByName("detail_panel")
    local text_details = plane:getChildByName('text_details'):setVisible(true)

    local progressClock =
        cc.ProgressTimer:create(cc.Sprite:create(TpackageName .. '/images/lottery/faguan.png')):setType(
        cc.PROGRESS_TIMER_TYPE_RADIAL
    ):setAnchorPoint(image:getAnchorPoint()):setPosition(image:getPosition()):addTo(btn_panel):setName('progressClock'):setPercentage(
        0
    )

    btn_panel:addTouchEventListener(
        function(sender, event)
            if event == TOUCH_EVENT_ENDED then
                ControlOperator:requestBet(seatId)
                require(TpackageName .. '.lottery.PlaneOperator'):setCurtBetSeatId(seatId)
            end
        end
    )

    text_details:addTouchEventListener(
        function(sender, event)
            if event == TOUCH_EVENT_ENDED then
                -- if plane.shieldBet == true then
                -- 	return
                -- end

                if plane.lotteryBankerData then
                    local lotteryBankerData = plane.lotteryBankerData

                    local photoUrl = lotteryBankerData.photoUrl
                    local uid = lotteryBankerData.uid
                    local sex = lotteryBankerData.sex
                    local nickname = lotteryBankerData.nickname

                    require('hall.GameCommon'):showPlayerInfoForGetHead(photoUrl, uid, sex, nickname)
                else
                    require(TpackageName .. '.lottery.ControlOperator'):requestBetDetails(seatId)
                end
            end
        end
    )
end

function PlaneItemOperator:setMyBet(plane, value)
    local my_bet_chip = plane:getChildByName('my_bet_chip')

    local Text_2 = plane:getChildByName('Text_2')

    my_bet_chip:setString(value)

    if value > 0 then
        my_bet_chip:setTextColor(cc.c3b(255, 255, 0))
        Text_2:setTextColor(cc.c3b(255, 255, 0))
        my_bet_chip:setVisible(true)
        Text_2:setVisible(true)
    else
        my_bet_chip:setTextColor(cc.c3b(255, 255, 255))
        Text_2:setTextColor(cc.c3b(255, 255, 255))
        my_bet_chip:setVisible(false)
        Text_2:setVisible(false)
    end

    plane.my_bet_value = value
end

function PlaneItemOperator:setTotalBet(plane, value)
    local total_bet_chip = plane:getChildByName('total_bet_chip')
    local Text_1 = plane:getChildByName('Text_1')

    if value > 0 then
        total_bet_chip:setVisible(true)
        Text_1:setVisible(true)
    else
        total_bet_chip:setVisible(false)
        Text_1:setVisible(false)
    end

    total_bet_chip:setString(value)
    plane.total_bet_value = value
end

function PlaneItemOperator:updateMyBet(plane, value)
    local initialValue = plane.my_bet_chip or 0
    local finalValue = initialValue + value
    self:setMyBet(plane, finalValue)
end

function PlaneItemOperator:updateTotalBet(plane, value)
    local initialValue = plane.total_bet_value or 0
    local finalValue = initialValue + value
    self:setTotalBet(plane, finalValue)
end

function PlaneItemOperator:clearGameDatas(plane)
    self:setMyBet(plane, 0)
    self:setTotalBet(plane, 0)
    self:clearCards(plane)
    self:clearLotteryBanker(plane)
    self:shieldBet(plane)

    local text_details = plane:getChildByName('text_details'):setString(''):setTouchEnabled(false)

    -- local detail_panel = plane:getChildByName("detail_panel")

    plane.lotteryBankerData = nil
end

function PlaneItemOperator:clearCards(plane)
    plane.seat = false

    local gold_panel = plane:getChildByName('gold_panel')
    gold_panel:removeAllChildren()
    plane:setColor(cc.c3b(100, 100, 100))
end

function PlaneItemOperator:clearLotteryBanker(plane)
    local user_head = plane:getChildByName('bankerWinnerHead')
    if user_head then
        user_head:removeFromParent()
    end
end

function PlaneItemOperator:showLotteryBanker(plane, data)
    local planeSize = plane:getContentSize()
    local planeAnchor = cc.p(0.5, 0.8) -- plane:getAnchorPoint()
    local pos = cc.p(planeSize.width * planeAnchor.x, planeSize.height * planeAnchor.y)
    local headImgWidth = 110

    -- local user_head = ccui.ImageView:create(default_head_img)
    -- :addTo(plane)
    -- :setPosition(pos)
    -- :setName("bankerWinnerHead")

    -- user_head:ignoreContentAdaptWithSize(false)

    -- local user_head_size = user_head:getContentSize()
    -- user_head:setScale(headImgWidth/user_head_size.width)

    local uid = data.uid

    local text_details = plane:getChildByName('text_details')

    if uid ~= 0 then
        -- local detail_panel = plane:getChildByName("detail_panel")
        local photoUrl = data.icon_url
        local sex = data.sex
        local nickname = data.nick

        plane.lotteryBankerData = {photoUrl = photoUrl, sex = sex, uid = uid, nickname = nickname}
        -- require("hall.GameCommon"):getUserHead(photoUrl, uid, sex, user_head, headImgWidth, false, nickname)
        nickname = require('hall.GameCommon'):formatNick(nickname, 5)
        text_details:setString(nickname .. '坐庄'):setTouchEnabled(true)
    else
        text_details:setString('系统坐庄')
    end
end

function PlaneItemOperator:showPlaneItemChange(seatId, plane, typ, data)
    local user_head = plane:getChildByName('user_head')

    if typ == 'sitDown' then
        plane:setVisible(true)
        local uid = data.uid
        local photoUrl = data.icon_url
        local sex = data.sex
        local nickname = data.nick

        local text_player_index = plane:getChildByName('text_player_index')
        text_player_index:setString(require('hall.GameCommon'):formatNick(nickname, 4))

        require('hall.GameCommon'):getUserHead(photoUrl, uid, sex, user_head, 78, false, nickname)
    elseif typ == 'standUp' then
        self:clearGameDatas(plane)
        plane:setVisible(false)
        user_head:loadTexture(default_head_img)
    end
end

function PlaneItemOperator:openBet(plane)
    if plane.seat ~= true then
        return
    end

    local btn_panel = plane:getChildByName('btn_panel')
    btn_panel:setTouchEnabled(true)
    plane.shieldBet = false

    local text_details = plane:getChildByName('text_details'):setString('押注详情'):setTouchEnabled(true)

    -- local detail_panel = plane:getChildByName("detail_panel")
end

function PlaneItemOperator:shieldBet(plane)
    local btn_panel = plane:getChildByName('btn_panel')
    btn_panel:setTouchEnabled(false)
    plane.shieldBet = true
    -- local text_details = plane:getChildByName("text_details")
    -- :setString("")
end

function PlaneItemOperator:showStageProgress(plane)
    local curCountdown = require(TpackageName .. '.lottery.Lottery'):getCurCountdown()
    local totalCountdown = require(TpackageName .. '.lottery.Lottery'):getTotalCountdown()
    local curStage = require(TpackageName .. '.lottery.Lottery'):getCurStage()

    --dump(curCountdown,"curCountdown")
    --dump(totalCountdown,"totalCountdown")

    local percentage = curCountdown / totalCountdown * 100
    local progressClock = plane:getChildByName('btn_panel'):getChildByName('progressClock')
    self:stopStageProgress(plane)

    if curStage == 'grabBanker' then
        progressClock:setColor(cc.c3b(0, 255, 0))
    else
        progressClock:setColor(cc.c3b(255, 255, 255))
    end

    progressClock:setPercentage(100)

    if curCountdown > 0 then
        local progressAc = cc.ProgressTo:create(curCountdown, 0)
        progressClock:setPercentage(percentage)
        progressClock:runAction(progressAc)
    end
end

function PlaneItemOperator:stopStageProgress(plane)
    if tolua.isnull(plane) == false then
        --dump("关闭上一个玩家的选中状态")
        local progressClock = plane:getChildByName('btn_panel'):getChildByName('progressClock')
        progressClock:stopAllActions()
        progressClock:setPercentage(0)
    end
end

function PlaneItemOperator:dealCards(seatId, plane, cardDatas, cardState)
    plane.seat = true
    plane:setColor(cc.c3b(255, 255, 255))
    local gold_panel = plane:getChildByName('gold_panel')

    local target_point_y = 0
    local OtherCardScale = 0.4
    local OtherCardInterval = 150 * OtherCardScale
    local planeWidth = gold_panel:getContentSize().width

    for i = 1, 5 do
        local card = gold_panel:getChildByName('card_' .. i)

        if card == nil then
            local target_point_x = planeWidth / 2 - (3 - i) * OtherCardInterval
            card = Card.new()
            card:setScale(OtherCardScale)
            card:addTo(gold_panel)
            card:setPosition(cc.p(target_point_x, target_point_y))
            card:setName('card_' .. i)
            card:showBack()
        end

        if cardDatas[i] and cardDatas[i] > 0 then
            card:setCard(cardDatas[i])
            if cardState == 'cover' then
                card:showBack()
            else
                card:showFront()
            end
        end
    end
end

function PlaneItemOperator:openCards(seatId, plane)
    local gold_panel = plane:getChildByName('gold_panel')

    for i = 1, 5 do
        local card = gold_panel:getChildByName('card_' .. i)

        if card == nil then
            break
        end

        if card:hasValue() == true then
            card:showFront()
        end
    end
end

function PlaneItemOperator:showCardType(plane, cardKind)
    local gold_panel = plane:getChildByName('gold_panel')

    local planeWidth = gold_panel:getContentSize().width
    local planeHeight = gold_panel:getContentSize().height

    local OtherCardScale = 0.7

    local target_point_y = planeHeight / 2 - 30
    local target_point_x = planeWidth / 2

    local cardKind_imgPath = CARDTYPE_IMAGE_PATH[cardKind]
    if cardKind < 1 then
        return
    end
    local cardType = ccui.ImageView:create(cardKind_imgPath, 1)
    cardType:addTo(gold_panel)
    cardType:setPosition(cc.p(target_point_x, target_point_y))
    cardType:setScale(OtherCardScale)

    local cardTypeTimes = NIUNIU_CARDTYPE_TABLE[cardKind]

    local isSkip = string.find(g_mainScene.gameConfigTable.gaoji or '', '7')
    if cardTypeTimes and cardTypeTimes > 1 and not isSkip then
        local fnt = TpackageName .. '/font/cardType_yellow.fnt'
        if cardKind >= 11 then
            fnt = TpackageName .. '/font/cardType_red.fnt'
        end

        local size = cardType:getContentSize()
        local card_type_times_txt = ccui.TextBMFont:create('x' .. cardTypeTimes, fnt)
        card_type_times_txt:setAnchorPoint(1, 0)
        card_type_times_txt:setPosition(size.width, 0)
        card_type_times_txt:addTo(cardType)
    end
end

return PlaneItemOperator
