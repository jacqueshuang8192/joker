--
-- Author: Your Name
-- Date: 2017-08-15 14:35:04
--
local testConfig = class("testConfig")

local scale = 1.1
local cardspace
-- = 74.6 *scale
local boxwidth = 171.00*scale
local boxheight = 110.0*scale

local screenWidth = 1280
local screenHeight = 720


-- local T = bm.PACKET_DATA_TYPE
-- local P = {}

-- local HALL_SERVER_PROTOCOL = P
-- P.CONFIG = {}
-- P.CONFIG.CLIENT = {}
-- P.CONFIG.SERVER = {}
-- local CLIENT = P.CONFIG.CLIENT
-- local SERVER = P.CONFIG.SERVER

-- P.CLI_SEND_TEST_CARD                 =0x1999
-- CLIENT[P.CLI_SEND_TEST_CARD]={
--     ver=1,
--     fmt={
--         {name="card",type=T.BTYE},
--     }
-- }


function testConfig:addChooseCardButton(cards_tbl,card_path,test_func)
    local ChooseCardButton = ccui.Button:create()
    ChooseCardButton:loadTextureNormal("hall/res/images/verify/prop.png")
    SCENENOW["scene"]._scene:addChild(ChooseCardButton)
    ChooseCardButton:setZOrder(999)
    ChooseCardButton:setVisible(true)
    ChooseCardButton:setScale(0.8)
    ChooseCardButton:setPosition(cc.p(1210,580))
    ChooseCardButton:addTouchEventListener(
                function(sender,event)
                    --触摸开始
                    if event == TOUCH_EVENT_BEGAN then
                        sender:setScale(0.9)
                    end

                    --触摸取消
                    if event == TOUCH_EVENT_CANCELED then
                        sender:setScale(1)
                    end

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then
                        sender:setScale(1.0)
                        self:chooseCard(cards_tbl,card_path,test_func)
                    end

                end)

    dump(ChooseCardButton:getPosition(), "ChooseCardButton")

    return  ChooseCardButton

end

function testConfig:chooseCard(cards_tbl,card_path,test_func, type_)


    self:removeScene()
    -- body
    self.layout = cc.CSLoader:createNode("hall/res/csb/verify/result_effect.csb")

    local card_path = card_path or  "zz_majiang_old_3d/image/card/"
    -- self.layout:setScale(0.75)

    self.result_effect_bg = self.layout:getChildByName("result_effect_bg")


    -- self.result_effect_bg:setFileData("hall/scene/verify/moniao_box01.png")
    self.result_effect_item = self.layout:getChildByName("result_effect_item")

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0,0))
    layerTouch:setContentSize(cc.size(1280,720))

    layerTouch:setTouchEnabled(true)
    layerTouch:addTouchEventListener(function(sender,event)
            if event == 2  then
                self:removeScene()
            end
        end)
    self.layout:addChild(layerTouch,self.result_effect_item:getZOrder()-1)

    local cards_num = table.nums(cards_tbl)
    local cards_num_half = math.modf(cards_num / 2)   --几对牌
    local cards_num_less = cards_num % 2

    local effect_base_w_cm

    if cards_num<=8 then
        effect_base_w_cm = cards_num
    else
        effect_base_w_cm = 8
    end

    local weitiaoX = 15
    local weitiaoY = 20

    local effect_base_w = boxwidth/2 *effect_base_w_cm
          cardspace = boxwidth/2
    local effect_base_h = boxheight*(math.floor(cards_num/8.01)+1)
    self.result_effect_bg:setContentSize(cc.size(effect_base_w,effect_base_h))
    self.result_effect_bg:setPosition(635+ weitiaoX,360+ weitiaoY)

    -- local x_cards_num_change = {[0]=0,[1]=40,[2]=65,[3]=49,[4]=73,[5]=60,[6]=78}
    -- local x_cards_num_change_cm = x_cards_num_change[cards_num] or 78
    --74.6为牌的间隔
    local x = screenWidth/2 - effect_base_w/2 + weitiaoX
    -- - x_cards_num_change_cm
    -- - (480 - 411.56)
    local y = screenHeight/2 + effect_base_h/2

    local lineNum = math.floor(cards_num/8.01) +1


    if cards_num_less == 0 then  --偶数  个
        x = x - (cards_num_less)*cardspace
    else                         --奇数  个
        x = x + cardspace/2
        x = x - (cards_num_less-0.5)*cardspace
    end

    local x_store = x

    local time_deley = 0
    for i,card_value in pairs(cards_tbl) do
          local result_effect_item = self.result_effect_item:clone()
          result_effect_item:setScale(scale)

          local iLine =math.floor(i/8.01)

          x_store = x + (i%8.01-1)*cardspace
          y =  screenHeight/2 + effect_base_h/2 - effect_base_h/lineNum*iLine + weitiaoY

          result_effect_item:setPosition(cc.p(x_store,y))

        if card_value ~= nil and card_value ~= 0 then
            local image_tx = card_path .. card_value .. ".png"
            local result_effect_card = result_effect_item:getChildByName("result_effect_card")
            local result_effect_center = result_effect_item:getChildByName("result_effect_center")
            local result_effect_base = result_effect_item:getChildByName("result_effect_base")

            local result_effect_value = result_effect_card:getChildByName("result_effect_value")
            result_effect_value:loadTexture(image_tx)
            result_effect_card:onClick(
	        function(sender,event)
                    if test_func then
                        test_func(card_value)
                    end
                    self:removeScene()
	        end, true)

            self.layout:addChild(result_effect_item)

            result_effect_card:setVisible(true)
            result_effect_center:setVisible(true)
            if string.find(card_path,'2DMahjongCard') then
                result_effect_center:setVisible(false)
                result_effect_base:setVisible(false)
                result_effect_card:setBackGroundImageOpacity(0)
                result_effect_value:ignoreContentAdaptWithSize(true)
                result_effect_value:setScale(0.7)
            end
        end
    end

    self.layout:setName("testConfigScene")
    SCENENOW["scene"]:addChild(self.layout)

end

function testConfig:removeScene()

   local s = SCENENOW["scene"]:getChildByName("testConfigScene")

   if s and not tolua.isnull(s) then
        s:removeFromParent()
   end

end


return testConfig
