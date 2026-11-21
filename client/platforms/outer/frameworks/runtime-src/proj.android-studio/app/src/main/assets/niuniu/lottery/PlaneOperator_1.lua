local PlaneOperator = class('PlaneOperator')

local ControlOperator = require(TpackageName .. '.lottery.ControlOperator')
local PlaneItemOperator = require(TpackageName .. '.lottery.PlaneItemOperator')

local lottery_plane_ori_pos = cc.p(1710 * 1280 / 1920, 0)
local coin_img_path = TpackageName .. '/images/effect_gold.png'

local audiencePanelCsb = TpackageName .. '/csb/audiencePanel.csb'
local betDetailCsb = TpackageName .. '/csb/betDetail.csb'
local betPanelCsb = TpackageName .. '/csb/betPanel.csb'

local player_item_table = {}
local chip_bg_pos = nil --筹码文本框相对于主界面的坐标

function PlaneOperator:init(initialChips)
    ---NIUNIU_GAME_SCENE:getParent()
    local s =
        NIUNIU_SCENE:getChildByName('bet_situation_plane') or
        cc.CSLoader:createNode(betPanelCsb):addTo(NIUNIU_SCENE, 101):setName('bet_situation_plane'):setPosition(
            lottery_plane_ori_pos
        ):setScale(1280 / 1920)

    self._scene = s

    local waiwei_choose_plane = s:getChildByName('waiwei_choose_plane')
    ControlOperator:init(waiwei_choose_plane, initialChips)

    local chip_bg = waiwei_choose_plane:getChildByName('chip_bg')
    local chip_bg_world_pos = waiwei_choose_plane:convertToWorldSpace(chip_bg:getPosition())
    chip_bg_pos = s:convertToNodeSpace(chip_bg_world_pos)

    local content_lv = s:getChildByName('content_lv')
    local items_ly_1 = content_lv:getChildByName('items_ly_1')
    local items_ly_2 = content_lv:getChildByName('items_ly_2')

    for i = 1, 5 do
        player_item_table[i] = items_ly_1:getChildByName('bet_panel_item_' .. i)
        local seatId = i - 1
        PlaneItemOperator:init(seatId, player_item_table[i])
    end

    for i = 6, 10 do
        player_item_table[i] = items_ly_2:getChildByName('bet_panel_item_' .. i)
        local seatId = i - 1
        PlaneItemOperator:init(seatId, player_item_table[i])
    end

    s.isPullIn = true

    local open_bt = s:getChildByName('open_bt')
    local mask = s:getChildByName('mask'):setTouchEnabled(false):setVisible(false)

    local openBetSituation = function(sender, event)
        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            if s.isPullIn == true then
                self:showBetPanel()
            else
                self:hideBetPanel()
            end
        end
    end

    open_bt:addTouchEventListener(openBetSituation)
    mask:addTouchEventListener(openBetSituation)

    local win_trend_bt = s:getChildByName('win_trend_bt'):setVisible(false)

    local audience_bt = s:getChildByName('audience_bt')
    -- :setVisible(false)

    win_trend_bt:addTouchEventListener(
        function(sender, event)
            if event == TOUCH_EVENT_ENDED then
                self:showWinTrend()

                if device.platform == 'windows' then
                    self:showCoinFly(0)
                    require(TpackageName .. '.lottery.Lottery'):showBetResultAnim(0, 100)
                    self:showMyChipChangeAnim(460, 500)
                end
            end
        end
    )

    audience_bt:addTouchEventListener(
        function(sender, event)
            if event == TOUCH_EVENT_ENDED then
                local audienceData = {}
                local audienceNum = 0
                for uid, data in pairs(NIUNIU_USERINFO_TABLE) do
                    local seatId = NIUNIU_SEAT_TABLE[uid] or -1
                    if seatId < 0 then
                        table.insert(audienceData, data)
                        audienceNum = audienceNum + 1
                    end
                end

                self:showAudiencePlane(audienceData, audienceNum)
            end
        end
    )

    self.stage_text = s:getChildByName('stage_text')
    self.my_chip_text = s:getChildByName('my_chip_text')
    self.tips = s:getChildByName('tips'):setString('')
    self:showStageText(0, 'clear')
end

function PlaneOperator:showBetPanel(seatId)
    local mask = self._scene:getChildByName('mask'):setTouchEnabled(true):setVisible(true)

    self:setMyChipText() --打开界面后刷新自己钱数

    self._scene:runAction(cc.MoveTo:create(0.2, cc.p(0, 0)))
    if seatId then
        self:setCurtBetSeatId(seatId)
    end

    self._scene.isPullIn = false
end

function PlaneOperator:hideBetPanel()
    local mask = self._scene:getChildByName('mask'):setTouchEnabled(false):setVisible(false)

    self._scene:runAction(cc.MoveTo:create(0.2, lottery_plane_ori_pos))

    self._scene.isPullIn = true
end

function PlaneOperator:openBet(bankerSeatId)
    for seatId = 0, 9 do
        if seatId ~= bankerSeatId then
            local planeItem = self:getPlaneItem(seatId)
            PlaneItemOperator:openBet(planeItem)
        end
    end
end

function PlaneOperator:showLotteryBanker(seatId, data)
    local planeItem = self:getPlaneItem(seatId)
    PlaneItemOperator:showLotteryBanker(planeItem, data)
end

function PlaneOperator:clearGameDatas()
    for seatId = 0, 9 do
        local planeItem = self:getPlaneItem(seatId)
        PlaneItemOperator:clearGameDatas(planeItem)
    end
    ControlOperator:clearGameDatas()
end

function PlaneOperator:removeScene()
    local bet_situation_plane = NIUNIU_GAME_SCENE:getParent():getChildByName('bet_situation_plane')
    if bet_situation_plane then
        bet_situation_plane:removeFromParent()
    end
end

function PlaneOperator:getPlaneItem(seatId)
    return player_item_table[seatId + 1] --服务器的座位号是0到9
end

function PlaneOperator:showWinTrend()
end

function PlaneOperator:showBetDetails(data)
    local s = cc.CSLoader:createNode(betDetailCsb):addTo(self._scene):setName('detail_plane')

    local mask = s:getChildByName('mask')
    mask:addTouchEventListener(
        function(sender, event)
            if event == TOUCH_EVENT_ENDED then
                s:removeFromParent()
            end
        end
    )

    local bet_detail_item = s:getChildByName('bet_detail_item')
    local content_lv = s:getChildByName('content_lv')

    local minusData = {}
    for _, v in pairs(data) do
        minusData[v.betPlayerUid] = (minusData[v.betPlayerUid] or 0) + v.value
    end

    for betPlayerUid, bet_value in pairs(minusData) do
        local bet_detail_item = bet_detail_item:clone()
        local nickName = NIUNIU_USERINFO_TABLE[betPlayerUid].nick
        bet_detail_item:setString(nickName .. '押注了' .. bet_value)
        content_lv:pushBackCustomItem(bet_detail_item)
    end
end

function PlaneOperator:showAudiencePlane(audienceData, audienceNum)
    local s = cc.CSLoader:createNode(audiencePanelCsb):addTo(self._scene):setName('audience_plane')

    local mask = s:getChildByName('mask')
    mask:setTouchEnabled(false)

    local btn_close = s:getChildByName('btn_close')
    btn_close:addTouchEventListener(
        function(sender, event)
            if event == TOUCH_EVENT_ENDED then
                s:removeFromParent()
            end
        end
    )

    local line_content_lv = s:getChildByName('line_content_lv')
    local content_lv = s:getChildByName('content_lv')

    local group_ending_box = s:getChildByName('group_ending_box')

    --   local oneLineCount = 3
    --   local lineListViewTable = {}
    --   for i = 1,math.ceil(audienceNum/oneLineCount) do
    --   	lineListViewTable[i] = line_content_lv:clone()
    -- content_lv:pushBackCustomItem(lineListViewTable[i])
    --   end

    -- local k = 0

    for uid, data in pairs(audienceData) do
        -- k = k + 1

        local uid = data.uid
        local photoUrl = data.icon_url
        local sex = data.sex
        local nickname = data.nick

        -- local line_content_lv = lineListViewTable[math.ceil(k/oneLineCount-0.01)]

        local group_ending_box = group_ending_box:clone()
        local nickName_txt = group_ending_box:getChildByName('nickName_txt')
        local head_im = group_ending_box:getChildByName('head_im')

        require('hall.GameCommon'):getUserHead(photoUrl, uid, sex, head_im, 61, false, nickname)

        nickName_txt:setString(nickname)

        content_lv:pushBackCustomItem(group_ending_box)
    end
end

local function coinfly(oriPos, targetPos, plane, coinCount)
    for i = 1, coinCount do
        local delaytime = i * 0.035 + math.random(-2, 2) / 100

        plane:performWithDelay(
            function()
                oriPos = cc.pAdd(oriPos, cc.p(math.random(-15, 15), 0))
                targetPos = cc.pAdd(targetPos, cc.p(math.random(-15, 15), math.random(-8, 8)))

                local middleY = (targetPos.y + oriPos.y) / 2

                local q1 = cc.p((targetPos.x - oriPos.x) * 0.56 + oriPos.x, (targetPos.y - oriPos.y) * 0.44 + oriPos.y)
                local q2 = cc.p((targetPos.x - oriPos.x) * 0.67 + oriPos.x, (targetPos.y - oriPos.y) * 0.8 + oriPos.y)
                local mb = cc.BezierTo:create(0.4, {q1, q2, targetPos})
                -- local mb = cc.MoveBy:create(0.5, targetPos)
                local fo = cc.FadeOut:create(0.4)

                local seq = cc.Sequence:create(mb, fo, cc.RemoveSelf:create()) --cc.DelayTime:create(0.4),

                local coin_sp =
                    display.newSprite(coin_img_path):setScale(1.3):setPosition(oriPos):setScale(0.9):addTo(plane, 1000):runAction(seq)
            end,
            delaytime
        )
    end
end

--显示赢的飞金币动画，从赢的玩家身上飞钱到我的筹码
function PlaneOperator:showCoinFly(seatId, winGold)
    local planeItem = self:getPlaneItem(seatId)

    local planeItem_world_pos = (planeItem:getParent()):convertToWorldSpace(planeItem:getPosition())
    local planeItemPos = self._scene:convertToNodeSpace(planeItem_world_pos)

    local my_chip_text_pos = self.my_chip_text:getPosition()

    winGold = winGold or 10
    winGold = winGold > 10 and 10 or winGold

    coinfly(planeItemPos, my_chip_text_pos, self._scene, winGold)
end

--显示押注的飞金币动画，从我的分数栏飞到押注的玩家身上
function PlaneOperator:showChipFly(seatId, betChip)
    local planeItem = self:getPlaneItem(seatId)

    local planeItem_world_pos = (planeItem:getParent()):convertToWorldSpace(planeItem:getPosition())
    local planeItemPos = self._scene:convertToNodeSpace(planeItem_world_pos)
    local chip_bg_pos = chip_bg_pos

    betChip = betChip or 5
    betChip = betChip > 10 and 10 or betChip

    coinfly(chip_bg_pos, planeItemPos, self._scene, betChip)
end

function PlaneOperator:setMyChipText(value)
    local value = value or require(TpackageName .. '.lottery.Lottery'):getMyChip()

    self.my_chip_text.value = value
    self.my_chip_text:setString('我的筹码：' .. require(NumberUtil_filePath):toWan(value, 99999))

    -- if value > 99999 then
    -- 	value = require(NumberUtil_filePath):toWan(value, 99999)
    -- 	self.my_chip_text:setString("我的筹码：" .. value)
    -- end
end

function PlaneOperator:showBetResult(chip)
    if chip > 0 then
        local msg = '您在外围押注中赢了' .. chip
        require('hall.GameTips'):showSmallTips(msg, 5)
    elseif chip < 0 then
        local msg = '您在外围押注中输了' .. math.abs(chip)
        require('hall.GameTips'):showSmallTips(msg, 5)
    end
end

function PlaneOperator:showGrabBankerBtn(seatId)
    local planeItem = self:getPlaneItem(seatId)
    local planeItemPosWorld = (planeItem:getParent()):convertToWorldSpace(planeItem:getPosition())

    local waiwei_choose_plane = self._scene:getChildByName('waiwei_choose_plane')
    local planeItemPosNode = waiwei_choose_plane:convertToNodeSpace(planeItemPosWorld)

    planeItemPosNode.y = planeItemPosNode.y - 30
    ControlOperator:showGrabBankerBtn(planeItemPosNode)
end

function PlaneOperator:hideGrabBankerBtn()
    ControlOperator:hideGrabBankerBtn()
end

function PlaneOperator:updateBetSituation(seatId, betPlayerUid, value)
    local planeItem = self:getPlaneItem(seatId)
    -- PlaneItemOperator:updateTotalBet(planeItem, value) --更新总下注(服务器已经返回总下注，无需自行更新)

    if betPlayerUid == USER_INFO['uid'] then
        self:showChipFly(seatId, value)
        self:setMyChipText() --更新主界面我的筹码

    -- PlaneItemOperator:updateMyBet(planeItem, value) --更新我的下注(服务器已经返回总下注，无需自行更新)
    end
end

function PlaneOperator:setTotalBet(seatId, value)
    local planeItem = self:getPlaneItem(seatId)
    PlaneItemOperator:setTotalBet(planeItem, value) --更新总下注
end

function PlaneOperator:setMyBet(seatId, value)
    local planeItem = self:getPlaneItem(seatId)
    PlaneItemOperator:setMyBet(planeItem, value) --更新总下注
end

function PlaneOperator:showMyChipChangeAnim(previousValue, endValue)
    local previousValue = previousValue or (self.my_chip_text.value or 0)
    local endValue = endValue or require(TpackageName .. '.lottery.Lottery'):getMyChip()

    local changeTimes = 20
    local intervelTime = 0.05

    local winChip = endValue - previousValue
    local chipChangeRate = winChip / changeTimes

    local i = 0

    self.my_chip_text:stopAllActions()
    self.my_chip_text:runAction(
        cc.Repeat:create(
            cc.Sequence:create(
                cc.DelayTime:create(0.05),
                cc.CallFunc:create(
                    function()
                        i = i + 1

                        if i == changeTimes then
                            self:setMyChipText()
                            self.my_chip_text:stopAllActions()
                            return
                        end

                        self:setMyChipText(previousValue + math.floor(i * chipChangeRate))
                    end
                )
            ),
            changeTimes
        )
    )
end

function PlaneOperator:showStageProgress(countdown, typ)
    local curtBetSeatId = self:getCurtBetSeatId()
    if curtBetSeatId then
        local planeItem = self:getPlaneItem(curtBetSeatId)
        PlaneItemOperator:showStageProgress(planeItem, typ)
    end
end

function PlaneOperator:showStageText(countdown, typ)
    if typ == 'grabBanker' then
        self.stage_text:setString('离停止抢庄还有：' .. countdown)
    elseif typ == 'bet' then
        self.stage_text:setString('离停止下注还有：' .. countdown)
    elseif typ == 'checkCard' then
        self.stage_text:setString('玩家看牌中：' .. countdown)
    elseif typ == 'compare' then
        self.stage_text:setString('玩家比牌中：' .. countdown)
    elseif typ == 'grabGameBanker' then
        self.stage_text:setString('内场抢庄中...')
    elseif typ == 'gameBet' then
        self.stage_text:setString('内场加倍中...')
    elseif typ == 'wait' then
        self.stage_text:setString('中场休息')
    elseif typ == 'start' then
        self.stage_text:setString('游戏即将开始：' .. countdown)
    elseif typ == 'clear' then
        self.stage_text:setString('')
    end
end

--屏蔽下注
function PlaneOperator:shieldBet()
    for seatId = 0, 9 do
        local planeItem = self:getPlaneItem(seatId)
        PlaneItemOperator:shieldBet(planeItem)
    end
end

function PlaneOperator:setBetLimit(baseChip, limitTimes)
    local betLimitChip = limitTimes * baseChip
    ControlOperator:setUppeLimit(betLimitChip)

    self.tips:setString('座位注码限制：' .. require(NumberUtil_filePath):toWan(betLimitChip, 9999))

    -- if betLimitChip > 9999 then
    -- 	betLimitChip = require(NumberUtil_filePath):toWan(value, 9999)
    -- 	self.tips:setString("座位注码限制：".. betLimitChip .. "万")
    -- end
end

--画牌
function PlaneOperator:dealCards(seatId, cardDatas, cardState)
    local planeItem = self:getPlaneItem(seatId)
    PlaneItemOperator:dealCards(seatId, planeItem, cardDatas, cardState)
end

--开牌
function PlaneOperator:openCards()
    for seatId = 0, 9 do
        local planeItem = self:getPlaneItem(seatId)
        if planeItem.seat == true then
            PlaneItemOperator:openCards(seatId, planeItem) --更新总下注
        end
    end
end

--画牌
function PlaneOperator:showCardType(seatId, cardKind)
    local planeItem = self:getPlaneItem(seatId)
    PlaneItemOperator:showCardType(planeItem, cardKind)
end

function PlaneOperator:showPlaneItemChange(seatId, typ, data)
    local planeItem = self:getPlaneItem(seatId)
    PlaneItemOperator:showPlaneItemChange(seatId, planeItem, typ, data)
end

function PlaneOperator:setCurtBetSeatId(seatId)
    local curtBetSeatId = self:getCurtBetSeatId()

    if curtBetSeatId == seatId then
        return
    end

    if curtBetSeatId then
        local previousPlaneItem = self:getPlaneItem(curtBetSeatId)
        PlaneItemOperator:stopStageProgress(previousPlaneItem)
    end

    self.curtBetSeatId = seatId
    local planeItem = self:getPlaneItem(seatId)
    PlaneItemOperator:showStageProgress(planeItem)
end

function PlaneOperator:getCurtBetSeatId()
    return self.curtBetSeatId
end

-- for _,_func in pairs(PlaneOperator) do
-- 	dump(_func,"_func")
-- 	if type(_func) == "function" then
-- 		setmetatable(_func,{
-- 		    __call = function(table,params)
-- 		        dump(table,"Lottery__table")
-- 		        dump(params,"Lottery__params")
-- 		    end
-- 		})
-- 	end
-- end

return PlaneOperator
