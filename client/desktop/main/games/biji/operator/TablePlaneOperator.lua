local TablePlaneOperator = class("TablePlaneOperator")

function TablePlaneOperator:init()
    self.clock= BIJI_GAME_SCENE:getChildByName("clock")
    self.clock:setVisible(false)
    local function touchButtonEvent(sender,event)
        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.8)
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
        end
    end
end
function TablePlaneOperator:startGameTime(time)
    local clock_txt =  self.clock:getChildByName("text_center")
    clock_txt:stopAllActions()
    local clock_bottom =  self.clock:getChildByName("clock_bottom")
    if  time <= 0 then
        self.clock:setVisible(false)
        return
    else
        self.clock:setVisible(true)
    end
    local  timer_value = time
    local  refreshTime = 1
    clock_txt:setString(tostring(timer_value))
    local showTimerAc = cc.CallFunc:create(function()
        timer_value = timer_value - refreshTime
        clock_txt:setString(tostring(timer_value))
        if timer_value <= 0 then
            clock_txt:stopAllActions()
            self.clock:setVisible(false)
        end
    end)
    local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime), showTimerAc)
    clock_txt:runAction(cc.RepeatForever:create(seqAc))
end



return TablePlaneOperator