local ControlOperator = class('ControlOperator')

local default_chip_values = {1, 10, 100, 1000}
local lotteryFilePath = TpackageName .. '.lottery.Lottery'

--waiwei_choose_plane
function ControlOperator:init(plane, initialChips)
    self._scene = plane

    --当前押注分数
    self.curBetValue = cc.UserDefault:getInstance():getIntegerForKey('NIUNIU_LOTTERY_BET_VALUE', 1)

    --押注输入框
    self.text_gold =
        plane:getChildByName('chip_bg'):getChildByName('text_gold'):setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER) --设置文字水平居中

    self:addEditBoxEventListener(self.text_gold)

    --全压
    self.btn_allin = plane:getChildByName('btn_allin')

    --清空
    self.btn_clear = plane:getChildByName('btn_clear')

    --确认押注
    self.btn_confirm = plane:getChildByName('btn_confirm')

    --抢庄按钮
    self.btn_grabBanker = plane:getChildByName('btn_grabBanker')

    local touchEvent = function(sender, event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELLED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)

            if sender == self.btn_allin then
                local myChip = require(lotteryFilePath):getMyChip()
                if myChip < 0 then
                    myChip = 0
                end
                self:setCurBetValue(myChip)
            elseif sender == self.btn_clear then
                self:setCurBetValue(1)
            elseif sender == self.btn_grabBanker then
                self:requestGrabBanker()
                self:hideGrabBankerBtn()
            elseif sender == self.btn_confirm then
                local curtBetSeatId = require(TpackageName .. '.lottery.PlaneOperator'):getCurtBetSeatId()
                if curtBetSeatId then
                    self:requestBet(curtBetSeatId)
                else
                    require('hall.GameTips'):showSmallTips('请选中一个座位！', 1.5)
                end
            end
        end
    end

    self.btn_allin:addTouchEventListener(touchEvent)
    self.btn_clear:addTouchEventListener(touchEvent)
    self.btn_confirm:addTouchEventListener(touchEvent)
    self.btn_grabBanker:addTouchEventListener(touchEvent)

    self:setChips(initialChips)
    self:setCurBetValue(self.curBetValue)
end

function ControlOperator:clearGameDatas()
end

function ControlOperator:requestBetDetails(seatId)
    if require(lotteryFilePath):checkBetDetailsCache(seatId) == false then
        NiuNiuSendHandle:CLI_CMD_REQ_YAZHU_DETAILS(seatId)
        return
    end

    return require(lotteryFilePath):showBetDetails(seatId)
end

function ControlOperator:requestGrabBanker()
    local bankerSeatId = require(lotteryFilePath):getBankerSeatId()
    if bankerSeatId then
        NiuNiuSendHandle:CLI_REQUEST_GRAB_BANKER(bankerSeatId)
    end
end

function ControlOperator:showGrabBankerBtn(pos)
    self.btn_grabBanker:setPosition(pos)
    self.btn_grabBanker:setVisible(true)
end

function ControlOperator:hideGrabBankerBtn()
    self.btn_grabBanker:setVisible(false)
end

function ControlOperator:requestBet(curtBetSeatId)
    NiuNiuSendHandle:CLI_REQUEST_BET(curtBetSeatId, self.curBetValue)
end

function ControlOperator:addEditBoxEventListener(editBox)
    local function TextFieldEventHandle(pSender, strEventName)
        if strEventName == TEXTFIELD_EVENT_DETACH_WITH_IME then
            local strFmt
            strFmt = pSender:getString() -- string.format("editBox %p DidEnd !", edit)

            local inputBetValue = tonumber(strFmt)
            if inputBetValue then
                self:setCurBetValue(inputBetValue)
            else
                require('hall.GameTips'):showSmallTips('请输入纯数字！')
                self:setCurBetValue(self.curBetValue)
            end
        end
    end

    editBox:addEventListener(TextFieldEventHandle)
end

function ControlOperator:requestBet(curtBetSeatId)
    NiuNiuSendHandle:CLI_REQUEST_BET(curtBetSeatId, self.curBetValue)
end

function ControlOperator:setUppeLimit(value)
    self.uppeLimit = value
end

function ControlOperator:setCurBetValue(value)
    if self.uppeLimit and value > self.uppeLimit then --当前下注超过上限
        value = self.uppeLimit
    end

    self.curBetValue = value
    cc.UserDefault:getInstance():setIntegerForKey('NIUNIU_LOTTERY_BET_VALUE', value)
    self.text_gold:setString(value)

    for i, v in ipairs(default_chip_values) do
        if v == value then
            local selectedChip = self._scene:getChildByName('bet_chip_' .. i)

            if selectedChip then
                self:resetChipsStatus()
                selectedChip:setColor(cc.c3b(255, 255, 255))
            end

            return
        end
    end

    --如果当前下注和筹码都不一致，暗化所有筹码
    self:resetChipsStatus()
end

function ControlOperator:resetChipsStatus()
    for i = 1, 4 do
        local bet_chip = self._scene:getChildByName('bet_chip_' .. i)
        bet_chip:setColor(cc.c3b(120, 120, 120))
    end
end

function ControlOperator:setChips(chip_values)
    local chip_values = chip_values or default_chip_values

    for i, v in ipairs(chip_values) do
        default_chip_values[i] = v
    end

    for i = 1, 4 do
        local chip_value = chip_values[i]
        local bet_chip = self._scene:getChildByName('bet_chip_' .. i)

        if chip_value then
            bet_chip:setVisible(true)

            local bet_chip_txt = bet_chip:getChildByName('bet_chip_txt'):setString(chip_value)

            if chip_value > 999 then
                bet_chip_txt:setString(chip_value / 1000 .. '千')
            end

            bet_chip:addTouchEventListener(
                function(sender, event)
                    if event == TOUCH_EVENT_BEGAN then
                        sender:setScale(0.9)
                    end

                    if event == TOUCH_EVENT_CANCELLED then
                        sender:setScale(1.0)
                    end

                    if event == TOUCH_EVENT_ENDED then
                        sender:setScale(1.0)
                        self:setCurBetValue(chip_value)
                    end
                end
            )
        else
            bet_chip:setVisible(false)
        end
    end
end

return ControlOperator
