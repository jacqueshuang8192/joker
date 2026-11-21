local FamilyBraodComponent  = class("FamilyBraodComponent")
local default_braod_message = braodComponentDefaulMessage
local messages = {braodComponentDefaulMessage}
local Timer = require("hall.lib.Timer")

function FamilyBraodComponent:showBraod(plane)

    local braodWidth = plane:getSize().width --跑马灯的长度   

    if plane:getChildByName("Braod") then
        plane:removeChildByName("Braod")
    end

    if self.scrollView then 
        self.scrollView = nil
    end 
    if self.queneTimer then 
        self.queneTimer:release()
        self.queneTimer = nil
    end

    self.scrollView = cc.ScrollView:create()  
    self.scrollView:setViewSize(cc.size(braodWidth, plane:getSize().height))   
    self.scrollView:setName("Braod")
    self.scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_NONE )   
    self.scrollView:setClippingToBounds(true)   
    self.scrollView:setBounceable(true)  
    self.scrollView:setTouchEnabled(false)   

    plane:addChild(self.scrollView)   

end

function FamilyBraodComponent:setDefaultBraodMessage(msg)
    default_braod_message = msg
    local time = self:showMessage()
    if time then
        self.queneTimer = self.queneTimer or Timer.new()
        self.queneTimer:release()
        self.queneTimer:start(self, self.showMessage, time)
    end
end

function FamilyBraodComponent:showMessage()
    
    if tolua.isnull(self.scrollView) then
        if self.queneTimer then
            self.queneTimer:release() 
        end
        return
    end

    local message = default_braod_message 
    local label = cc.Label:createWithTTF(message, "hall/res/font/FZY3JW.TTF", self.scrollView:getViewSize().height - 10)
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

return FamilyBraodComponent