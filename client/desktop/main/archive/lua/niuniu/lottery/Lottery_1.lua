local Lottery = class('Lottery')

local PlaneOperator = require(TpackageName .. '.lottery.PlaneOperator')

local stageRemainTime = 0
local stageTotalTime = 0

local CardTypeTransLate = {}
local BetDetailDatas = {} --key = seatId , value = { {bet_uid = ,bet_chip = },{bet_uid = ,bet_chip = } }
local bankerSeatId = nil

local curStage = ''
local betResult = {}

setmetatable(
    BetDetailDatas,
    {
        __call = function(table, typ)
            if typ == 'clear' then
                for seatId, data in pairs(table) do
                    table[seatId] = nil
                end
            end
        end
    }
)

function Lottery:init(initialChips)
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    CardTypeTransLate = {
        [-1] = '完成', --完成
        [0] = '盖牌', --盖牌
        [1] = '无牛', --无牛
        [2] = '牛一', --牛一
        [3] = '牛二',
        [4] = '牛三',
        [5] = '牛四',
        [6] = '牛五',
        [7] = '牛六',
        [8] = '牛七',
        [9] = '牛八',
        [10] = '牛九',
         --牛九
        [11] = '牛牛',
         --牛牛
        [CARDKIND_SHUNZI] = '顺子牛',
         -- 顺子牛
        [CARDKIND_WUHUA] = '五花牛',
         -- 五花牛
        [CARDKIND_TONGHUANIU] = '同花牛',
         -- 同花牛
        [CARDKIND_HULUNIU] = '葫芦牛',
         -- 葫芦牛
        [CARDKIND_SIZHA] = '四炸牛',
         -- 四炸牛
        [CARDKIND_WUXIAONIU] = '五小牛'
     --
    }

    PlaneOperator:init(initialChips)

    self:clearGameDatas()
    if device.platform == 'windows' then
        Lottery:test()
    end
end

function Lottery:test()
    -- self:dealCards(0,{1,2,3,4,5})
    -- self:showCardType(0,2)
    -- PlaneOperator:showGrabBankerBtn(0)
end

function Lottery:showBetPanel(seatId)
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    PlaneOperator:showBetPanel(seatId)
end

function Lottery:clearGameDatas()
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    curStage = ''
    BetDetailDatas('clear')
    bankerSeatId = nil
    PlaneOperator:clearGameDatas()
end

function Lottery:remainStageProgress(countdown, typ)
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    countdown = countdown or 10

    stageRemainTime = countdown
    stageTotalTime = countdown

    curStage = typ

    PlaneOperator:showStageText(stageRemainTime, typ)

    if typ == 'grabBanker' or typ == 'bet' then
        PlaneOperator:showStageProgress(stageRemainTime)
    end

    if self.actionHand then
        NIUNIU_GAME_SCENE:stopAction(self.actionHand)
    end
    self.actionHand =
        NIUNIU_SCENE:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.CallFunc:create(
                    function()
                        stageRemainTime = stageRemainTime - 1
                        PlaneOperator:showStageText(stageRemainTime, typ)

                        if stageRemainTime <= 0 then
                            NIUNIU_GAME_SCENE:stopAction(self.actionHand)
                        end
                    end
                )
            )
        )
    )
end

function Lottery:stopStageProgress(typ)

    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    if typ == 'grabBanker' then
        self:hideGrabBankerBtn()
        PlaneOperator:showStageText(nil, 'clear')
    elseif typ == 'bet' then
        self:shieldBet()
        PlaneOperator:showStageText(nil, 'clear')
    end
end

function Lottery:getCurCountdown()
    return stageRemainTime
end

function Lottery:getTotalCountdown()
    return stageTotalTime
end

function Lottery:getCurStage()
    return curStage
end

------------------------------------------------外围庄家相关

function Lottery:showGrabBankerBtn(bankerSeatId)
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    self:setBankerSeatId(bankerSeatId)
    PlaneOperator:setCurtBetSeatId(bankerSeatId)
    PlaneOperator:showGrabBankerBtn(bankerSeatId)
end

function Lottery:hideGrabBankerBtn()
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    PlaneOperator:hideGrabBankerBtn()
end

function Lottery:getBankerSeatId()
    return bankerSeatId or NIUNIU_SEAT_TABLE[BANKER_UID]
end

function Lottery:setBankerSeatId(seatId)
    bankerSeatId = seatId
end

--显示庄家结果
function Lottery:showGrabResult(data)
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    self:hideGrabBankerBtn()
    local bankerSeatId = self:getBankerSeatId()

    if bankerSeatId then
        PlaneOperator:showLotteryBanker(bankerSeatId, data)
    end
end

----------------------------------------------------下注相关

function Lottery:updateBetDatas(seatId, betPlayerUid, value)
    local data = {betPlayerUid = betPlayerUid, value = value}
    BetDetailDatas[seatId] = BetDetailDatas[seatId] or {}
    table.insert(BetDetailDatas[seatId], data)
end

--广播下注
function Lottery:updateBetSituation(seatId, betPlayerUid, value)
    PlaneOperator:updateBetSituation(seatId, betPlayerUid, value)
end

function Lottery:setTotalBet(seatId, value)
    PlaneOperator:setTotalBet(seatId, value)
end

function Lottery:setMyBet(seatId, value)
    PlaneOperator:setMyBet(seatId, value)
end

function Lottery:setBetLimit(baseChip, limitTimes)
    PlaneOperator:setBetLimit(baseChip, limitTimes)
end

function Lottery:storeBetResultData(data)
    betResult = data
end

function Lottery:delayCallShowBetResult()
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    local betResult = betResult --pack.betResult
    -- dump(betResult,"BROADCAST_WAIWEI_RESULT")

    for k, data in pairs(betResult) do
        local uid = data.bet_uid
        local score = data.score

        if uid > 0 then
            local playerChip = data.chip
            NIUNIU_USERINFO_TABLE[uid].coins = playerChip

            local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]

            if playerType then
                GamePlaneOperator:setCoin(playerType, playerChip)
            end

            if uid == USER_INFO['uid'] then
                local betDetailResult = data.betDetailResult
                for _, detailData in ipairs(betDetailResult) do
                    local seatId = detailData.seatId
                    local detail_score = detailData.detail_score

                    if detail_score > 0 then
                        self:showBetResultAnim(seatId, detail_score)
                    end
                end

                self:showBetResult(score)

                NIUNIU_SCENE:performWithDelay(
                    function()
                        PlaneOperator:showMyChipChangeAnim() --显示我的筹码变动的动画
                    end,
                    0.5
                )
            end
        end
    end
end

function Lottery:showBetResult(chip)
    PlaneOperator:showBetResult(chip)
end

function Lottery:showBetResultAnim(seatId, value)
    PlaneOperator:showCoinFly(seatId, value)
end

function Lottery:checkBetDetailsCache(seatId)
    local betDetailData = BetDetailDatas[seatId]

    if betDetailData == nil or next(betDetailData) == nil then
        return false
    end

    return true
end

function Lottery:showBetDetails(seatId, data)
    local betDetailData = data or (BetDetailDatas[seatId] or {})
    PlaneOperator:showBetDetails(betDetailData)
end

function Lottery:shieldBet()
    PlaneOperator:shieldBet()
end

function Lottery:openBet()
    local bankerSeatId = self:getBankerSeatId()
    PlaneOperator:openBet(bankerSeatId)
end

-------------------------------------------------------------------------------------
function Lottery:getMyChip()
    if NIUNIU_USERINFO_TABLE[tonumber(USER_INFO['uid'])] then
        return NIUNIU_USERINFO_TABLE[tonumber(USER_INFO['uid'])].coins
    else
        print('获取自己用户信息失败')
        return 0
    end
end

function Lottery:dealCards(seatId, cardDatas, cardState)
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    PlaneOperator:dealCards(seatId, cardDatas, cardState)
end

function Lottery:openCards()
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    PlaneOperator:openCards()
end

function Lottery:showCardType(seatId, cardKind)
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    PlaneOperator:showCardType(seatId, cardKind)
end

function Lottery:showPlaneItemChange(seatId, typ, data)
    if GAME_CONFIG['买牛'] ~= true then
        return
    end

    if typ == 'leaveRoom' then
        return
    end

    PlaneOperator:showPlaneItemChange(seatId, typ, data)
end

function Lottery:showPaper(record_paper)

    self:showBetSituationView(false)

    local WinTrend = cc.CSLoader:createNode(TpackageName .. '/csb/WinTrend.csb'):addTo(NIUNIU_SCENE)
    WinTrend:setScale(SCREEN_WIDTH / DESIGN_SCREEN_WIDTH)
    WinTrend:setName('WinTrend')

    -- local winTrendScale =  SCREEN_WIDTH/DESIGN_SCREEN_WIDTH
    -- WinTrend:setPosition(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
    local content_ly = WinTrend:getChildByName('content_ly')
    content_ly:setScale(1.4)

    local mask = content_ly:getChildByName('mask')
    mask:addTouchEventListener(
        function(sender, event)
            --触摸结束（检查当前组局状态）
            if event == TOUCH_EVENT_ENDED then
                self:showBetSituationView(true)
            end
        end
    )

    local winTrend_bottom = content_ly:getChildByName('winTrend_bottom')
    winTrend_bottom:addTouchEventListener(
        function(sender, event)
            --触摸结束（检查当前组局状态）
            if event == TOUCH_EVENT_ENDED then
                self:showBetSituationView(true)
            end
        end
    )

    local winTrend_lv = content_ly:getChildByName('winTrend_lv')

    winTrend_lv:removeAllChildren()
    self.player_win_trend_item = content_ly:getChildByName('player_win_trend_item')

    local total_record_round = #record_paper

    for index = total_record_round - 9, total_record_round do
        if total_record_round > 0 then
            local data = record_paper[index] or {}

            local uid = data.uid or 0
            if uid > 0 then
                local seat_id = NIUNIU_SEAT_TABLE[uid]
                local icon_url = NIUNIU_USERINFO_TABLE[uid].icon_url or ''
                local nickName = NIUNIU_USERINFO_TABLE[uid].nick or ''

                nickName = require('hall.GameCommon'):formatNick(nickName, 4)

                local single_record_paper = data.single_record_paper
                local player_win_trend_item =
                    self:loadSinglePlayerItemInfoForPaper(icon_url, nickName, single_record_paper, seat_id)
                winTrend_lv:pushBackCustomItem(player_win_trend_item)
            end
        end
    end

    --刷新录纸
    local btn_refresh = content_ly:getChildByName('btn_refresh')
    btn_refresh:addTouchEventListener(
        function(sender, event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束（检查当前组局状态）
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                NiuNiuSendHandle:CLI_REQUEST_LUZHI()
            end
        end
    )
end

function Lottery:loadSinglePlayerItemInfoForPaper(icon_url, nickName, single_record_paper, index)
    local player_win_trend_item_clone = self.player_win_trend_item:clone()
    local nick_txt = player_win_trend_item_clone:getChildByName('nick_txt')
    local index_txt = player_win_trend_item_clone:getChildByName('index_txt')
    local head = player_win_trend_item_clone:getChildByName('head')
    require('hall.GameCommon'):getUserHead(icon_url, 0, 1, head, 52, false)

    for round, v in pairs(single_record_paper) do
        local balance_txt = cc.Label:createWithTTF(v.balance, TpackageName .. '/font/fzcs.ttf', 20)
        local niuType_txt = cc.Label:createWithTTF(CardTypeTransLate[v.niuType], TpackageName .. '/font/fzcs.ttf', 20)

        if v.balance > 0 then
            balance_txt:setColor(cc.c3b(255, 0, 0))
        else
            balance_txt:setColor(cc.c3b(0x0E, 0xEF, 0x0E))
        end

        player_win_trend_item_clone:addChild(balance_txt)
        player_win_trend_item_clone:addChild(niuType_txt)

        local x = (round - 1) * 111 + 130
        balance_txt:setPosition(cc.p(x, 60))
        niuType_txt:setPosition(cc.p(x, 18))
        niuType_txt:setColor(cc.c3b(0, 0, 0))
    end

    nick_txt:setString(nickName)
    index_txt:setString(index)

    return player_win_trend_item_clone
end

function Lottery:showBetSituationView(flag)
    local WinTrend = NIUNIU_SCENE:getChildByName('WinTrend')
    if WinTrend then
        WinTrend:removeFromParent(not flag)
    end

    local lotteryScene = NIUNIU_SCENE:getChildByName('lotteryScene')
    if lotteryScene then
        lotteryScene:setVisible(flag)
    end
end

return Lottery
