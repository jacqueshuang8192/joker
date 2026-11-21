local Control=class("Control")
local frame_x=100                       --初始位置x
local frame_y=50                        --初始位置y
local value=nil                          --第几位
local max=nil
--初始化
function Control:init(ss,index)
    max=ss
    self.controlscene = cc.CSLoader:createNode(TpackageName.."/csb/controlscene.csb")
    self.controlscene:setPosition(cc.p(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))
    SCENENOW["scene"]:addChild(self.controlscene,10000)
    self.controlscene:setScale(cc.Director:getInstance():getWinSize().width/1920)
    self.controlscene:setName("controlscene")
    self.controlscene:setAnchorPoint(0.5,0.5)

    self.panel_btn=self.controlscene:getChildByName("panel_btn")
    self:addBtn()
    if index>0 then
        self:clearBtn(index)
    end
end

--添加按钮
function Control:addBtn()
    for i=1,max do
        local btn=self.controlscene:getChildByName("btn"):clone()
        local bgimg=btn:getChildByName("bg"):getChildByName("Image_9")
        local sfimg=btn:getChildByName("sf"):getChildByName("Image_9")
        bgimg:loadTexture(TpackageName.."/images/choice/bg_"..i..".png")
        sfimg:loadTexture(TpackageName.."/images/choice/sf_"..i..".png")
        btn:setAnchorPoint(cc.p(0.5, 0.5))
        btn:setPosition(cc.p(frame_x+i*210,frame_y))
        btn:setName(i)
        self.panel_btn:addChild(btn)
        self:addListener(btn)
    end
end

--添加点击事件
function Control:addListener(btn)
    btn:setTouchEnabled(true)
    btn:addTouchEventListener(function(sender,event)
        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            value=tonumber(sender:getName())-1
            self:clearBtn(value+1)
            -- if value and isOpenControlSeat then
            --     SanGongSendHandle:CLIENT_CMD_TEST(isOpenControlSeat,value)
            --     dump(isOpenControlSeat,"11111111111111111111111111111111111111111111")
            --     dump(value,"22222222222222222222222222222222222222222222")
            -- end
            if value then
                SanGongSendHandle:CLIENT_CMD_TEST(nil,value)
                dump(value,"22222222222222222222222222222222222222222222")
            end
        end
    end)
end

--清理按钮
function Control:clearBtn(index)
    for i=1,max do
        local btn=self.panel_btn:getChildByName(tostring(i))
        btn:getChildByName("bg"):setVisible(true)
        btn:getChildByName("sf"):setVisible(false)
        btn:setTouchEnabled(true)
    end
    if index then
        local btn_=self.panel_btn:getChildByName(tostring(index))
        btn_:getChildByName("bg"):setVisible(false)
        btn_:getChildByName("sf"):setVisible(true)
        btn_:setTouchEnabled(false)
    end
end

--移除界面
function Control:removeScene()
    local s = SCENENOW["scene"]:getChildByName("controlscene")
    if s then
        s:removeSelf()
    end
end

--隐藏界面
function Control:showScene()
    self:clearBtn()
    value=nil
    local s = SCENENOW["scene"]:getChildByName("controlscene")
    if s then
        local flag=s:isVisible()
        if flag then
            s:setVisible(false)
        else
            s:setVisible(true)
        end
    end
end

--取整数
function Control:getIntPart(x)
    if x <= 0 then
       return math.ceil(x);
    end
    
    if math.ceil(x) == x then
       x = math.ceil(x);
    else
       x = math.ceil(x) - 1;
    end
    return x;
end

return Control