local BraodComponent  = class("BraodComponent")
local default_braod_message = braodComponentDefaulMessage_hall
local messages = {braodComponentDefaulMessage_hall}
local Timer = require("hall.lib.Timer")

function BraodComponent:showBraod(plane)

    local braodWidth = plane:getSize().width --跑马灯的长度   
    plane:removeAllChildren()
    --if plane:getChildByName("Braod") then
    --    return
    --    plane:getChildByName("Braod"):removeSelf()
    --end

    self.scrollView = cc.ScrollView:create()  
    self.scrollView:setViewSize(cc.size(braodWidth, plane:getSize().height))   
    self.scrollView:setName("Braod")
    self.scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_NONE )   
    self.scrollView:setClippingToBounds(true)   
    self.scrollView:setBounceable(true)  
    self.scrollView:setTouchEnabled(false)   

    local time = self:showMessage()
    self.queneTimer = self.queneTimer or Timer.new()
    self.queneTimer:release()
    self.queneTimer:start(self, self.showMessage, time)

    plane:addChild(self.scrollView)   

end

function BraodComponent:setDefaultBraodMessage(msg)
    default_braod_message = msg
    local time = self:showMessage()
    if time then
        self.queneTimer = self.queneTimer or Timer.new()
        self.queneTimer:release()
        self.queneTimer:start(self, self.showMessage, time)
    end
end

function BraodComponent:showMessage()
    
    if tolua.isnull(self.scrollView) then
        if self.queneTimer then
            self.queneTimer:release()
            return 
        end
        return
    end

    local message = default_braod_message  --table.getn(messages) > 0 and messages[1] or
    local label = cc.Label:createWithTTF(message, "hall/res/font/FZY3JW.TTF", self.scrollView:getViewSize().height-4)
        :setPosition(cc.p(self.scrollView:getViewSize().width, 0))   
        :setAnchorPoint(cc.p(0,0))
        :addTo(self.scrollView)

    local labelWidth = label:getContentSize().width 

    local time = 5 + labelWidth / self.scrollView:getViewSize().width * 5
    local removeAction = cc.RemoveSelf:create()
    local leftAction = cc.MoveTo:create(time, cc.p(0 - labelWidth ,0))
    local seqAction = cc.Sequence:create(leftAction, removeAction)   
    label:runAction(seqAction)  

    return time
end

return BraodComponent