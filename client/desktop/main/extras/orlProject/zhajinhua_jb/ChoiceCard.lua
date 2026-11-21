local ChoiceCard=class("ChoiceCard")
local cardCount=3                       --几张牌
local currentcardCount=1                --选到第几张牌
local cardValue={}                      --牌值数组
local frame_x=35                        --被选牌初始位置x
local frame_y=100                       --被选牌初始位置y
local distance_x=200                    --选牌框之间的距离
local CardData=                         --牌型
{  
    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x01,   --方块
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x11,   --樱花
    0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x21,   --红桃
    0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x31,   --黑桃
}

function ChoiceCard:init2()
    self.choicescene = cc.CSLoader:createNode(TpackageName.."/layout/room2.csb")
    self.choicescene:setPosition(cc.p(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))
	self.choicescene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
    SCENENOW["scene"]:addChild(self.choicescene,999)
    self.choicescene:setName("choicescene"):setScale(1280/1920)
    self.choicescene:setAnchorPoint(0.5,0.5)
    local test_pgv=self.choicescene:getChildByName("test_lv")
    test_pgv:jumpToPercentHorizontal(50)
    test_pgv:addEventListener(function(sender,event)
        local currentIndex=test_pgv:getCurSelectedIndex()
        --[[local item
        if currentIndex==0 then
            item=test_pgv:getItem(2):clone()
            test_pgv:removePageAtIndex(2)
            test_pgv:insertPage(item,0)
            test_pgv:setCurrentPageIndex(2)
        elseif currentIndex==2 then
            item=test_pgv:getItem(0):clone()
            test_pgv:removePageAtIndex(0)
            test_pgv:insertPage(item,2)
            test_pgv:setCurrentPageIndex(1)
        end]]
        dump(currentIndex,"111111111111111111111111111111111111111111111")
        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
            dump("111111111111111111111111111111111111111111111")
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
            dump("111111111111111111111111111111111111111111111")
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
        end
        if currentIndex==0 then
            test_pgv:scrollToPercentHorizontal(0,0.2,true)
        elseif currentIndex==1 then
            test_pgv:scrollToPercentHorizontal(50,0.2,true)
        elseif currentIndex==2 then
            test_pgv:scrollToPercentHorizontal(100,0.2,true)
        end
    end)
end

function ChoiceCard:xh(test_pgv,index)
    test_pgv:setCurrentPageIndex(index)
end
--初始化
function ChoiceCard:init()
    self.choicescene = cc.CSLoader:createNode(TpackageName.."/layout/choicescene.csb")
    self.choicescene:setPosition(cc.p(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))
    SCENENOW["scene"]:addChild(self.choicescene)
    self.choicescene:setName("choicescene"):setScale(1280/1920)
    self.choicescene:setAnchorPoint(0.5,0.5)
    self:addBtnCard()
    self:clearCard(1)
    self.choicescene:setScale(0.5)
    local action1=cc.ScaleTo:create(0.1,0.8)
    local action2=cc.ScaleTo:create(0.1,1280/1920)
    self.choicescene:runAction(cc.Sequence:create(action1,action2))
    self.btn_exit=self.choicescene:getChildByName("btn_exit")
    self.btn_exit:addTouchEventListener(function(sender,event)
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
            self:removeScene()
        end
    end)
    self.bg_mask=self.choicescene:getChildByName("bg_mask")
    self.bg_mask:addTouchEventListener(function(sender,event)
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
            self:removeScene()
        end
    end)
    self.btn_sure=self.choicescene:getChildByName("btn_sure")
    self.btn_sure:addTouchEventListener(function(sender,event)
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
            local i=0
            for _,v in pairs(cardValue) do
                i=i+1
            end
            if i==cardCount then
                require(TpackageName..".ZhajinHuaServer"):CLI_CHOICE_CARD(cardValue)
                --require(TpackageName..".view.MenjiroomView"):showChoice(false)
                self:removeScene()
            else
                require("hall.GameTips"):showTips("提示", "", 3, "请选择"..cardCount.."张牌")
            end
        end
    end)
    self.btn_choice=self.choicescene:getChildByName("btn_choice")
    self.btn_choice:addTouchEventListener(function(sender,event)
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
            if cardValue~={} then
                dump(#cardValue,"------------------------------")
                self:clearCard(1)
                cardValue={}
                self:showCardData()
            end
        end
    end)
    self.card_panle=self.choicescene:getChildByName("card_panle")
    self:showPanel()
end

--取整数
function ChoiceCard:getIntPart(x)
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

--绘制选牌
function ChoiceCard:showPanel()
    for k,v in pairs(CardData) do
        k=k-1
        local i=k%13
        local j=self:getIntPart(k/13)
        local cardUint={}
        cardUint.value=self:getValue(v)
        cardUint.color=self:getVariety(v)
        local layer = ccui.Layout:create()
        layer:addTo(self.card_panle)
        layer:setContentSize(cc.size(100,120))
        layer:setAnchorPoint(cc.p(0.5, 0.5))
        layer:setPosition(cc.p(frame_x+i*120,frame_y+j*140))
        layer:setName(k+1)
        local card = require(TpackageName..".common.PokerCard").new()
        card:addTo(layer)
        card:showFront()
        card:setCard(cardUint)
        card:setScale(0.4)
        card:setAnchorPoint(cc.p(0.5, 0.5))
        card:setPosition(cc.p(50,0))
        -- card:setPosition(cc.p(size.width/2, 0))

        card:setName("card")
        self:addListener(layer)
    end
end

--添加选牌事件
function ChoiceCard:addListener(layer)
    layer:setTouchEnabled(true)
    layer:addTouchEventListener(function(sender,event)
        -- 触摸开始
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
            table.remove(cardValue,currentcardCount)
            table.insert(cardValue,currentcardCount,CardData[tonumber(sender:getName())])
            self:addCard(CardData[tonumber(sender:getName())])
            currentcardCount=currentcardCount+1
            if currentcardCount>cardCount then
                currentcardCount=1
            end
            self:clearCard(currentcardCount,true)
            self:showCardData()
        end
    end)
end

--创建选牌框
function ChoiceCard:addBtnCard()
    for i=1,cardCount do
        local new_btn_card=self.choicescene:getChildByName("btn_card"):clone()
        new_btn_card:addTo(self.choicescene)
        new_btn_card:setPosition(cc.p((960-(cardCount-1)*distance_x/2)+(i-1)*distance_x, 900))
        new_btn_card:setName("btn_card"..i)
        new_btn_card:addTouchEventListener(function(sender,event)
            -- 触摸开始
            if event == TOUCH_EVENT_BEGAN then
            end
    
            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
            end
    
            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                currentcardCount=i
                self:clearCard(currentcardCount,true)
            end
        end)
    end
end

--所选牌值加入选牌框
function ChoiceCard:addCard(value)
    local s = SCENENOW["scene"]:getChildByName("choicescene")
    local btn_card=s:getChildByName("btn_card"..currentcardCount)
    local img_card=btn_card:getChildByName("img_card")
    if img_card then
        img_card:removeSelf()
    end
    local cardUint={}
    cardUint.value=self:getValue(value)
    cardUint.color=self:getVariety(value)
    local card = require(TpackageName..".common.PokerCard").new()
    local size = btn_card:getContentSize()
    card:addTo(btn_card)

    card:showFront()
    card:setCard(cardUint)
    card:setScale(0.5)
    card:setAnchorPoint(cc.p(0.5, 0.5))
    -- card:setPosition(cc.p(size.width/2,size.height/2))
    card:setPosition(cc.p(size.width/2, 0))
    -- card:setPositionX(size.width)
    -- GameUtils.setNodeNameBindObjDebug(btn_card)
    -- GameUtils.setNodeNameBindObjDebug(card)
    card:setName("img_card")
    -- card:setScale(0.4)

end

--所选牌值对应事件
function ChoiceCard:showCardData()
    for k,v in pairs(CardData) do
        self.card_panle:getChildByName(k):setTouchEnabled(true)
        self.card_panle:getChildByName(k):getChildByName("card").font_pai_:setOpacity(255)
        for _,data in pairs(cardValue) do
            if v==data then
                self.card_panle:getChildByName(k):setTouchEnabled(false)
                self.card_panle:getChildByName(k):getChildByName("card").font_pai_:setOpacity(100)
            end
        end
    end
end

--清理所选牌值
function ChoiceCard:clearCard(tag,flag)
    local s = SCENENOW["scene"]:getChildByName("choicescene")
    for i=1,cardCount do
        s:getChildByName("btn_card"..i):getChildByName("img_kuang"):setVisible(false)
        if not flag then
            local img_card=s:getChildByName("btn_card"..i):getChildByName("img_card")
            if img_card then
                img_card:removeSelf()
            end
        end
    end
    if tag then
        currentcardCount=tag
        s:getChildByName("btn_card"..tag):getChildByName("img_kuang"):setVisible(true)
    end
end

--移除牌框内子控件
function ChoiceCard:clearPanel()
    self.card_panle:removeAllChildren()
end

--移除界面
function ChoiceCard:removeScene()
    cardValue={}
    currentcardCount=1
    local s = SCENENOW["scene"]:getChildByName("choicescene")
    if s then
        s:removeSelf()
    end
end

--隐藏界面
function ChoiceCard:showScene(flag)
    currentcardCount=1
    local s = SCENENOW["scene"]:getChildByName("choicescene")
    if s then
        s:setVisible(flag)
    end
end

-- 获得花色
function ChoiceCard:getVariety(card)
	return bit.band(card, 0xF0)
end

-- 获得牌值
function ChoiceCard:getValue(card)
	local value = bit.band(card, 0x0F)
	if value == 1 then
		value = 14
	end
	return value
end

return ChoiceCard