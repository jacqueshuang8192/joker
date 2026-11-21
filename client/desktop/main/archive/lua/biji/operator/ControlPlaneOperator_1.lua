
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ControlPlaneOperator = class("ControlPlaneOperator")
local CardPlaneOperator = require(TpackageName .. ".operator.CardPlaneOperator")

function ControlPlaneOperator:init(plane)
    print("ControlPlaneOperator init---", debug.traceback())
    local resourceNode = SCENENOW["scene"]:getChildByName("cardLayer")
    self.plane = plane

    local option_bg = resourceNode:getChildByName("option_bg")

    --查看总结算按钮
    -- self.btn_check_group_result = plane:getChildByName("btn_check_group_result")
    -- self.btn_check_group_result:setVisible(false)
    --BiJiSendHandle
    --GamePlaneOperator
    --
    local pier_panel = resourceNode:getChildByName("pier_panel")

    for i = 1, 3 do

    end
    local count = 3
    ---选择推荐牌型
    for i = 1 ,count do
        -- local group = "group_"..i
        -- self[group] =  resourceNode:getChildByName(group)
        -- self[group]:onClick(function()
        --     dump(MY_BEST_CARDS, "=============MY_BEST_CARDS===========")
        --     CardPlaneOperator:clearCardPlane()
        --     for k = 1 ,#MY_BEST_CARDS[i] do

        --         CardPlaneOperator:showEachPiersCards(k, MY_BEST_CARDS[i][k].son_card, MY_BEST_CARDS[i][k].son_card_type)
        --     end
        --     MY_HAND_CARDS_TEMP = {}
        --     CardPlaneOperator:resetOptionBtn()
        -- end)
        self["card_arch"..tostring(i)] = pier_panel:getChildByName("card_arch" .. i)
        local pier_cancel = pier_panel:getChildByName("pier_cancel_" .. i)
        
        pier_cancel:onClick(function()
            CardPlaneOperator:clearOutCard(i)
            self:resetShowMode()
            for j = 1, 3 do
                self["card_arch"..tostring(j)]:setVisible(true)
            end
        end)
        self["card_arch"..tostring(i)]:onClick(function()
            local flag = CardPlaneOperator:checkCrch(i)
            if flag then
                self:resetShowMode() --因为重新生成了牌，所以要重置按钮
            end
            if #CardPlaneOperator.recordPiersIndex == 3 then
                for j = 1, 3 do
                    self["card_arch"..tostring(j)]:setVisible(false)
                end
            end
        end)
    end
    ---选择手牌牌型
    self.option_btn_6 = option_bg:getChildByName("option_btn_6")
    self.option_btn_5 = option_bg:getChildByName("option_btn_5")
    self.option_btn_4 = option_bg:getChildByName("option_btn_4")
    self.option_btn_3 = option_bg:getChildByName("option_btn_3")
    self.option_btn_2 = option_bg:getChildByName("option_btn_2")
    self.option_btn_1 = option_bg:getChildByName("option_btn_1")

    self.option_btn_6:onClick(handler(self, self.callBackToAutoCard))
    
    self.confirm_btn = resourceNode:getChildByName("confirm_btn")
    self.confirm_btn:onClick(handler(self, self.callBackToSendCard))

    self.btnShowCard = resourceNode:getChildByName("btnShowCard")
    self.btnShowCard:addTouchEventListener(handler(self, self.showCardByMode))
    -- self.cancel_btn = resourceNode:getChildByName("cancel_btn")
    -- self.cancel_btn:onClick(function()
    --     for i =1,3 do
    --         CardPlaneOperator:clearOutCard(i)
    --     end

    --     CardPlaneOperator:clearCardPlane()
    --     CardPlaneOperator:resetShowCards()
    --     CardPlaneOperator.recordPiersIndex = 0
    -- end)

    -- self:showCardCountDown()
end

function ControlPlaneOperator:callBackToAutoCard()
    CardPlaneOperator.recordPiersIndex = {1,2,3}
    CardPlaneOperator:clearCardPlane()
    dump(MY_BEST_CARDS, "=============MY_BEST_CARDS===========")
    CardPlaneOperator:clearCardPlane()
    if MY_BEST_CARDS[1] == nil then return end
    for k = 1 ,#MY_BEST_CARDS[1] do

        GamePlaneOperator:showEachPiersCards(k, MY_BEST_CARDS[1][k].son_card, MY_BEST_CARDS[1][k].son_card_type)
    end
    MY_HAND_CARDS_TEMP = {}
    CardPlaneOperator:resetOptionBtn()
    
end

function ControlPlaneOperator:callBackToSendCard()
    local cards_1, cards_2, cards_3 = CardPlaneOperator:getOutCards()
    
    if cards_1 == nil or cards_2 == nil or cards_3 == nil or  (#cards_1 ~=3) or (#cards_2 ~=3) or (#cards_3~= 3) then
        CardPlaneOperator:showTipsText("请完整出牌")
        return
    end
    for j = 1, 3 do
        self["card_arch"..tostring(j)]:setVisible(true)
    end
    if self.cardCountDowmHandler then
        scheduler.unscheduleGlobal(self.cardCountDowmHandler)
        self.cardCountDowmHandler = nil
    end
    CardPlaneOperator.recordPiersIndex = {}
    BiJiSendHandle:CLI_OPEN_CARD(cards_1, cards_2, cards_3)
end

function ControlPlaneOperator:showCardCountDown(timeout)
    if self.cardCountDowmHandler == nil then 
        local resourceNode = SCENENOW["scene"]:getChildByName("cardLayer")
        self.cardCountDown = resourceNode:getChildByName("clock_image"):getChildByName("clock_num")
        self.beginTime = timeout
        self.cardCountDown:setString(tostring(self.beginTime))
        self.cardCountDowmHandler = scheduler.scheduleGlobal(handler(self, self.playCountDown), 1.0)
    end
end

function ControlPlaneOperator:playCountDown()
    self.beginTime = self.beginTime - 1
    local resourceNode = SCENENOW["scene"]:getChildByName("cardLayer")
    if resourceNode == nil then return end

    local label = resourceNode:getChildByName("clock_image"):getChildByName("clock_num")
    label:setString(tostring(self.beginTime))
    if self.beginTime == 0 then
        scheduler.unscheduleGlobal(self.cardCountDowmHandler)
        self.cardCountDowmHandler = nil
        --self:callBackToAutoCard()
        --self:callBackToSendCard()
    end
end

function ControlPlaneOperator:showCardByMode(sender, event)
    if event == TOUCH_EVENT_ENDED then
        self.showMode = (self.showMode or 1) * (-1)
        local path = self.showMode > 0 and "btnHuaSe.png" or "btnDaXiao.png"
        path = TpackageName.."/res/images/"..path
        sender:loadTextureNormal(path)
        CardPlaneOperator:showCardByMode(self.showMode)
    end
end

function ControlPlaneOperator:resetShowMode()
    self.showMode = nil
    path = TpackageName.."/res/images/btnHuaSe.png"
    self.btnShowCard:loadTextureNormal(path)
end


return ControlPlaneOperator