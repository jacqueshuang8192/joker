local TablePlaneOperator = class("TablePlaneOperator")

local random_uid_ex = -1

--抢庄特效间隔
local GrabBankerDelay = 0.23

local coin_img_path = TpackageName .. "/images/effect_gold_3.png"

local cacheFrames = cc.SpriteFrameCache:getInstance()

local jubaopen_img_path = { [1] = TpackageName .. "/images/jubaopen_2.png" ,
                            [2] = TpackageName .. "/images/jubaopen_3.png" ,
                            [3] = TpackageName .. "/images/jubaopen_4.png" ,
                            [4] = TpackageName .. "/images/jubaopen_5.png" }

function TablePlaneOperator:init()

    -- self.coin:setPosition(cc.p(-100,-100))
    -- self.coin:setScale(0.6)
    -- NIUNIU_GAME_SCENE:addChild(self.coin)
    cacheFrames:addSpriteFrames(TpackageName .. "/images/coins.plist")

	self.banker_choose_frame = NIUNIU_GAME_SCENE:getChildByName("banker_choose_frame")

    self.clock = NIUNIU_GAME_SCENE:getChildByName("clock") 
    self.clock:setVisible(false)
    self.clock_txt = self.clock:getChildByName("text_center")

    self.progressClock = cc.ProgressTimer:create(cc.Sprite:create(TpackageName .. "/images/clock_progress_dark.png"))
    self.progressClock:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    local clock_bottom = self.clock:getChildByName("clock_bottom") 
    self.progressClock:setPosition(clock_bottom:getPosition())
    self.clock:addChild(self.progressClock)

    self.stage_img = NIUNIU_GAME_SCENE:getChildByName("stage_img")
    self.stage_img:setVisible(false)

    NIUNIU_GAME_SCENE:getChildByName("niuniu_start"):setVisible(false) --游戏开始  

    self.audience_brand = NIUNIU_GAME_SCENE:getChildByName("audience_brand") 
    self.audience_brand:setVisible(false)

    self.niuniu_cardcount_plane = NIUNIU_GAME_SCENE:getChildByName("niuniu_cardcount_plane") 
    self.niuniu_cardcount_plane:setVisible(false)

    self.stage_txt = NIUNIU_GAME_SCENE:getChildByName("stage_txt") 
    self.stage_txt:setString("")

    self.auto_cancel_plane = NIUNIU_GAME_SCENE:getParent():getChildByName("hall_plane"):getChildByName("auto_cancel_plane")
    self.auto_cancel_plane:setVisible(false)

    local auto_cancel_button = self.auto_cancel_plane:getChildByName("auto_cancel_button")
    local auto_cancel_layer = self.auto_cancel_plane:getChildByName("auto_cancel_layer")

    local function cancelAutoEvent(sender,event)

        if  event == TOUCH_EVENT_BEGAN then
            NiuNiuSendHandle:requestAutoPlay(1-(IS_AUTO_PLAY or 0),1,1)
        end

    end

    auto_cancel_button:addTouchEventListener(cancelAutoEvent)
    auto_cancel_layer:addTouchEventListener(cancelAutoEvent)

end

function TablePlaneOperator:switchTableImg(typeIndex)

    local background = SCENENOW["scene"]:getChildByName("background")

    if background then
        if  typeIndex == 1 then
            background:loadTexture("")
        elseif typeIndex == 2 then
            background:loadTexture("")
        end
    end

end

function TablePlaneOperator:clearGameDatas(stage)

    
    if stage == 1 then
        self:hideCardNumCountEffect()
        self:showAudienceBrand(false)
    elseif stage == 2 or stage == nil then
    	RANDOM_BANKER = {}

        self.stage_txt:setString("等待开始...")
        self.stage_img:setVisible(false)
        self:resetCardNumCount()

        -- local hall_plane = NIUNIU_GAME_SCENE:getParent():getChildByName("hall_plane")
        -- local btn_switch_bet_mode = hall_plane:getChildByName("btn_switch_bet_mode")
        -- local bottom_img = btn_switch_bet_mode:getChildByName("bottom_img")

        --       btn_switch_bet_mode:setPosition(cc.p(96,110))
        --       btn_switch_bet_mode:setScale(1)
        --       bottom_img:setColor(cc.c3b(125,125,125))
              -- bottom_img:setContentSize(cc.size(110,102)) 
    end

end

function TablePlaneOperator:showAudienceBrand(flag)
    if  flag == false then
        self.audience_brand:setVisible(false)
    else
        self.audience_brand:setVisible(true)
    end
end

function TablePlaneOperator:resetCardNumCount()

    local left_txt = self.niuniu_cardcount_plane:getChildByName("left_txt") 
    local middle_txt = self.niuniu_cardcount_plane:getChildByName("middle_txt") 
    local right_txt = self.niuniu_cardcount_plane:getChildByName("right_txt") 
    local result_txt = self.niuniu_cardcount_plane:getChildByName("result_txt")

          left_txt:setString("")
          middle_txt:setString("")
          right_txt:setString("")
          result_txt:setString("")

end


function TablePlaneOperator:showTaiFeiTips(value)
    --添加扣除台费显示
    local taiFeiTxt
    if  value < 0 then
        taiFeiTxt = "扣除台费"..math.abs(value)
    end

-- niuniu/font/arial.ttf

    local lbVersion = cc.Label:createWithTTF(taiFeiTxt, TpackageName .."/font/fzcs.ttf",50)
          NIUNIU_GAME_SCENE:addChild(lbVersion,9999)
          lbVersion:setColor(cc.c3b(0xBF, 0xBF, 0xBF))
          lbVersion:setPosition(cc.p(NIUNIU_GAME_SCENE:getContentSize().width/2,100))
          lbVersion:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() lbVersion:removeFromParent() end)))
end

function TablePlaneOperator:showAutoPlayTip(flag)
    --添加扣除台费显示

    local hall_plane = NIUNIU_GAME_SCENE:getParent():getChildByName("hall_plane")
    local btn_auto_play = hall_plane:getChildByName("btn_auto_play")

    if  flag == true then
        dump("提示自己进入托管状态")
        -- local tipTxt =  "您正处于托管状态..."
        -- local autoPlayTip = cc.Label:createWithTTF(tipTxt,""res/fonts/fzcy.ttf"",45):addTo(NIUNIU_GAME_SCENE,1001)
        -- autoPlayTip:setColor(cc.c3b(0, 0, 0))
        -- autoPlayTip:setPosition(cc.p(NIUNIU_GAME_SCENE:getContentSize().width/2,470))
        -- autoPlayTip:setName("autoPlayTip")
        self.auto_cancel_plane:setVisible(true)    
        btn_auto_play:setBright(false)
    else
        dump("隐藏托管状态")
        -- local autoPlayTip = NIUNIU_GAME_SCENE:getChildByName("autoPlayTip") 
        -- if  autoPlayTip then
        --     autoPlayTip:removeFromParent()
        -- end
        self.auto_cancel_plane:setVisible(false)   
        btn_auto_play:setBright(true)
    end


end

function TablePlaneOperator:showNumCount(value,index,flag)
    
    self.niuniu_cardcount_plane:setVisible(true)

    if  value == nil then
        return
    end

    local value = require(TpackageName .. ".cardLogic"):GetCardLogicValue(value) 

    local left_txt = self.niuniu_cardcount_plane:getChildByName("left_txt") 
    local middle_txt = self.niuniu_cardcount_plane:getChildByName("middle_txt") 
    local right_txt = self.niuniu_cardcount_plane:getChildByName("right_txt") 
    local result_txt = self.niuniu_cardcount_plane:getChildByName("result_txt") 
    
    if flag == false then
        
        if  index == 1 then
            left_txt:setString("")
        elseif  index == 2 then
            middle_txt:setString("")
        elseif  index == 3 then
            right_txt:setString("")
        end

        result_txt:setString("") 

    else
        
        if  index == 1 then
            left_txt:setString(value)
        elseif  index == 2 then
            middle_txt:setString(value)
        elseif  index == 3 then
            right_txt:setString(value)
        end

        local  left_num = tonumber(left_txt:getString())
        local  middle_num = tonumber(middle_txt:getString())
        local  right_num = tonumber(right_txt:getString())

        if  left_num and  middle_num and right_num then
            result_txt:setString(left_num + middle_num + value)
        else
            result_txt:setString("")
        end

    end
end


function TablePlaneOperator:showCardNumCountEffect(arg)

    self.niuniu_cardcount_plane:setVisible(true)

    local left_num = arg.left_num

    local middle_num = arg.middle_num

    local right_num = arg.right_num
    
    local left_txt = self.niuniu_cardcount_plane:getChildByName("left_txt") 
    local middle_txt = self.niuniu_cardcount_plane:getChildByName("middle_txt") 
    local right_txt = self.niuniu_cardcount_plane:getChildByName("right_txt") 
    local result_txt = self.niuniu_cardcount_plane:getChildByName("result_txt") 
   
    local function starEffect()
    end
    
    left_txt:setString(left_num)

    SCENENOW["scene"]:performWithDelay(function() 
        middle_txt:setString(middle_num)

        SCENENOW["scene"]:performWithDelay(function()
            right_txt:setString(right_num)

            SCENENOW["scene"]:performWithDelay(function() 
                result_txt:setString(left_num + middle_num + right_num)
                starEffect()
            end,0.2)

        end,0.2)

    end,0.2)

    SCENENOW["scene"]:performWithDelay(function() 
        self.niuniu_cardcount_plane:setVisible(false)
    end,2)

end

function TablePlaneOperator:hideCardNumCountEffect()
    self.niuniu_cardcount_plane:setVisible(false)
end


function TablePlaneOperator:loadRulePlane()
    local s = cc.CSLoader:createNode(TpackageName.."/csb/rulePlane.csb"):addTo(SCENENOW["scene"],99999)
    s:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)

    local rule_plane = s:getChildByName("rule_plane")

    local mask = rule_plane:getChildByName("mask")
    local cardType_item = rule_plane:getChildByName("cardType_item")
    local cardType_lv = rule_plane:getChildByName("cardType_lv")

    mask:setTouchEnabled(true)
    mask:addTouchEventListener(function(sender,event)

            if  event == TOUCH_EVENT_ENDED then
                dump("触摸")
                s:removeSelf()
            end

        end)

    local cardtype_tansform_table = {
        [1]  = "无牛", --无牛
        [2]  = "牛一",  --牛一
        [3]  = "牛二",
        [4]  = "牛三",
        [5]  = "牛四",
        [6]  = "牛五",
        [7]  = "牛六",
        [8]  = "牛七",
        [9]  = "牛八",
        [10]  = "牛九",--牛九
        [11]  = "牛牛",--牛牛
        [CARDKIND_SHUNZI]  = "顺子牛",-- 顺子牛
        [CARDKIND_WUHUA]  = "五花牛",-- 五花牛
        [CARDKIND_TONGHUANIU]  = "同花牛",-- 同花牛
        [CARDKIND_HULUNIU]  = "葫芦牛",-- 葫芦牛
        [CARDKIND_SIZHA]  = "炸弹牛" ,-- 四炸牛
        [CARDKIND_WUXIAONIU]  = "五小牛",-- 五小牛
    }

    local cardtype_examplane_path_table = 
    {
        [1]   =  {0x01,0x36,0x17,0x18,0x23}, --无牛
        [2]   =  {0x0D,0x0C,0x1B,0x02,0x39},  --牛一
        [3]   =  {0x0D,0x0C,0x0B,0x33,0x19},
        [4]   =  {0x0D,0x0C,0x0B,0x14,0x19},
        [5]   =  {0x0D,0x0C,0x0B,0x36,0x38},
        [6]   =  {0x0D,0x0C,0x0B,0x27,0x28},
        [7]   =  {0x0D,0x0C,0x0B,0x13,0x33},
        [8]   =  {0x0D,0x0C,0x0B,0x13,0x34},
        [9]   =  {0x0D,0x0C,0x0B,0x14,0x14},
        [10]   =  {0x0D,0x0C,0x0B,0x21,0x38},--牛九
        [11]   =  {0x0D,0x0C,0x0B,0x12,0x28},--牛牛
        [CARDKIND_SHUNZI] =  {0x32,0x23,0x14,0x05,0x26},-- 顺子牛
        [CARDKIND_WUHUA] =  {0x2C,0x3C,0x0B,0x2B,0x0D},-- 五花牛
        [CARDKIND_TONGHUANIU] =  {0x3E,0x34,0x37,0x39,0x3D},-- 同花牛
        [CARDKIND_HULUNIU] =  {0x09,0x19,0x29,0x04,0x34},-- 葫芦牛
        [CARDKIND_SIZHA] =  {0x14,0x24,0x34,0x04,0x18},-- 四炸牛
        [CARDKIND_WUXIAONIU] =  {0x11,0x21,0x32,0x12,0x23},-- 五小牛
    }


    if GAME_CONFIG["无花牛牛"] then

        cardtype_tansform_table = {
            [1]  = "无牛", --无牛
            [2]  = "牛一",  --牛一
            [3]  = "牛二",
            [4]  = "牛三",
            [5]  = "牛四",
            [6]  = "牛五",
            [7]  = "牛六",
            [8]  = "牛七",
            [9]  = "牛八",
            [10]  = "牛九",--牛九
            [11]  = "牛牛",--牛牛
            [-1]  = "金牌牛",--牛牛
            [CARDKIND_SHUNZI]  = "顺子牛",-- 顺子牛
            [CARDKIND_TONGHUANIU]  = "同花牛",-- 同花牛
            [CARDKIND_HULUNIU]  = "葫芦牛",-- 葫芦牛
            [CARDKIND_SIZHA]  = "炸弹牛" ,-- 四炸牛
            [CARDKIND_WUXIAONIU]  = "五小牛",-- 五小牛
            [CARDKIND_SISHIDA]  = "四十大",-- 五小牛
        }

        cardtype_examplane_path_table = 
        {
            [1]   =  {0x01,0x36,0x17,0x18,0x23}, --无牛
            [2]   =  {0x02,0x03,0x15,0x02,0x39},  --牛一
            [3]   =  {0x02,0x03,0x15,0x33,0x19},
            [4]   =  {0x02,0x03,0x15,0x14,0x19},
            [5]   =  {0x02,0x03,0x15,0x36,0x38},
            [6]   =  {0x02,0x03,0x15,0x27,0x28},
            [7]   =  {0x02,0x03,0x15,0x13,0x33},
            [8]   =  {0x02,0x03,0x15,0x13,0x34},
            [9]   =  {0x02,0x03,0x15,0x14,0x14},
            [10]   = {0x02,0x03,0x15,0x21,0x38},--牛九
            [11]   = {0x02,0x03,0x15,0x12,0x28},--牛牛
            [-1]  =  {0x09,0x09,0x09,0x12,0x28},--金牌牛
            [CARDKIND_SHUNZI] =  {0x32,0x23,0x14,0x05,0x26},-- 顺子牛
            [CARDKIND_TONGHUANIU] =  {0x37,0x34,0x37,0x39,0x35},-- 同花牛
            [CARDKIND_HULUNIU] =  {0x09,0x19,0x29,0x04,0x34},-- 葫芦牛
            [CARDKIND_SIZHA] =  {0x14,0x24,0x34,0x04,0x18},-- 四炸牛
            [CARDKIND_WUXIAONIU] =  {0x11,0x21,0x32,0x12,0x23},-- 五小牛
            [CARDKIND_SISHIDA] =  {0x18,0x28,0x39,0x29,0x27},-- 四十大
        }

    end

    -- table.sort(NIUNIU_CARDTYPE_TABLE) 

    -- dump(NIUNIU_CARDTYPE_TABLE,"NIUNIU_CARDTYPE_TABLE")

    local Card = require(TpackageName .. ".PokerCard")

    local y = 14.5

    for i, v in pairs(NIUNIU_CARDTYPE_TABLE) do

        local v = NIUNIU_CARDTYPE_TABLE[i] or "??"
        local cardDatas = cardtype_examplane_path_table[i]

        if i == -1 then
            v = "??"
        end

        if cardDatas then
            local cardType_item_clone = cardType_item:clone()
            local bottom = cardType_item_clone:getChildByName("bottom")
            local cardType_times = cardType_item_clone:getChildByName("cardType_times")

            if  i%2 == 0 then
                bottom:setVisible(false)
            end

            -- dump(i,"cardtype_examplane_path_table_i")
            -- dump(cardtype_examplane_path_table ,"cardtype_examplane_path_table")

            for index = 1,5 do 
                -- local img  = cardType_item_clone:getChildByName("card_"..index)
                -- local card_image_path = Card:getCardPath(cardDatas[index])
                -- card:loadTexture(card_image_path)
                local x = 64 + 77 * (index - 1)

                local card = Card.new()
                card:setCard(cardDatas[index])
                card:setPosition(cc.p(x,y))
                card:setScale(0.3)
                cardType_item_clone:addChild(card)
            end 

            cardType_times:setString(cardtype_tansform_table[i] .. "    " .. v .. "倍")
            cardType_lv:pushBackCustomItem(cardType_item_clone)
        end
    end

end


--画金币
function TablePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,changedMoneyArr,_type)
    dump(changedMoneyArr)
    --获取庄位置
    dump(bankerUid, "-----庄家UID-----")
    math.randomseed(os.time())
   
    local bankerPlayerType = NIUNIU_PLAYERTYPE_TABLE[bankerUid]
    
    --庄家输赢情况
    local zhuang_win = 0
    local zhuang_lose = 0

    local isZhuanWin = false

    for uid,value in pairs(tbWin) do
        if uid ~= bankerUid and value < 0 then
            isZhuanWin = true
            zhuang_win = zhuang_win - value
        elseif uid ~= bankerUid and value > 0 then
            zhuang_lose = zhuang_lose - value
        end
    end

    --闲家数
    local   playerCount = table.nums(tbWin)
    dump(tbWin, "-----输赢分数-----")

    local coinfly 

    if _type == "bet" then

        coinfly = function(oriPos,targetPos,i)
                
            local frameName = jubaopen_img_path[math.random(4)]
            local coin_sp = cc.Sprite:createWithSpriteFrameName(frameName)
            -- local coin_sp = display.newSprite(jubaopen_img_path[math.random(4)])
            if coin_sp then

                coin_sp:setPosition(oriPos)
                coin_sp:setScale(0.6)
                SCENENOW["scene"]:addChild(coin_sp, 100)

                local random = i

                if  random > 20 then
                    random = 20
                end

                local delaytime = 0.4 + 0.1 * math.random(random)

                local jumpHeight = math.random(20,80)

                local mb = cc.JumpTo:create(delaytime, targetPos, jumpHeight, 1)
                local fo = cc.FadeOut:create(0.5)
                local remove_action = cc.CallFunc:create(function()           
                      coin_sp:removeFromParent()
                end)

                local seq = cc.Sequence:create(mb, fo, remove_action) --cc.DelayTime:create(0.4),
                coin_sp:runAction(seq)

            end

        end

    else

        local sceneNow = SCENENOW["scene"]

        coinfly = function(oriPos,targetPos,i)
           
            local delaytime = i*0.035 + math.random(-2,2)/100

            sceneNow:performWithDelay(function()

                oriPos = cc.pAdd(oriPos,cc.p(math.random(-30,30),0 ) )

                local coin_sp = display.newSprite(coin_img_path):setPosition(oriPos):setScale(0.9)

                sceneNow:addChild(coin_sp, 100)
                targetPos = cc.pAdd(targetPos,cc.p(math.random(-30,30),math.random(-8,8) ) )

                local middleY = (targetPos.y + oriPos.y)/2

                local q1 = cc.p((targetPos.x - oriPos.x)*0.56 + oriPos.x,(targetPos.y - oriPos.y)*0.44 + oriPos.y)
                local q2 = cc.p((targetPos.x - oriPos.x)*0.67 + oriPos.x,(targetPos.y - oriPos.y)*0.8 + oriPos.y)
                local mb = cc.BezierTo:create(0.4,{q1, q2,targetPos})

                local fo = cc.FadeOut:create(0.4)

                local seq = cc.Sequence:create(mb,fo,cc.RemoveSelf:create()) --cc.DelayTime:create(0.4),
                coin_sp:runAction(seq)

            end,delaytime)

        end

    end
    
    
    local ZhuangWinDelay = 2
    --显示更新内容（文字和筹码）
    --显示更新内容（文字和筹码）
    dump(tbWin,"显示更新内容（文字和筹码）")
    dump(changedMoneyArr,"显示更新内容（文字和筹码）")
    for uid,value in pairs(tbWin) do
        local value2 = changedMoneyArr[uid]
        local  playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
        dump(playerType, "-----对应座位-----")
        dump(value, "-----更新筹码数-----")
             
        if  playerType then

            local pos = PLAYER_HEADS_POSITION_TABLE[uid]

            local x = pos.x
            local y = pos.y
            
            local pos = PLAYER_HEADS_POSITION_TABLE[bankerUid]
            local zhuang_x = pos.x
            local zhuang_y = pos.y
           
            --计算生成筹码数

            local coin_count = 20     

            --判断当前位置是否为庄
            if playerType == bankerPlayerType then
                if  isZhuanWin == true and playerCount > 2 then
                    print("==557==")
                    print("==557==")
                    print("==557==")
                    GamePlaneOperator:updateCoin(playerType,tbWin[uid],changedMoneyArr[uid])

                    -- SCENENOW["scene"]:performWithDelay(function() 
                    --     GamePlaneOperator:updateCoin(playerType,tbWin[uid])  --zhuang_lose
                    -- end, ZhuangWinDelay) 
                else
                    print("==564==")
                    print("==564==")
                    print("==564==")

                    GamePlaneOperator:updateCoin(playerType,tbWin[uid],changedMoneyArr[uid])
                end

            else --当前用户不是庄家
                GamePlaneOperator:updateCoin(playerType,tbWin[uid],changedMoneyArr[uid])
                local changedMoney = changedMoneyArr[uid]
                --添加显示减少的筹码
                if changedMoney < 0 then

                    --玩家输，筹码从玩家生成，飞向庄家
                    -- dump("-----筹码飞动，玩家输，飞向庄家x-----")
                    --金币流数    
                        --添加筹码
                        for i=1,coin_count do
                           
                            local oriPosition = cc.p(x, y)
                            local targetPos = cc.p(zhuang_x, zhuang_y)

                            coinfly(oriPosition,targetPos,i)

                        end

                    -- end

                    SoundUtils:playEffect("coinfly_long",false)
                    print("==594==")
                    print("==594==")
                    print("==594==")
                   	-- GamePlaneOperator:updateCoin(playerType,tbWin[uid],changedMoneyArr[uid])

                elseif changedMoney > 0 then

                    --玩家赢，筹码从庄家生成，飞向玩家
                    -- dump(x, "-----筹码飞动，玩家赢，飞向玩家x-----")
                    -- dump(y, "-----筹码飞动，玩家赢，飞向玩家y-----")          

                    --添加筹码

                    if isZhuanWin == true and playerCount > 2 then
                        --庄有赢而且当前玩家数大于2

                        local action = cc.Sequence:create(cc.DelayTime:create(ZhuangWinDelay),cc.CallFunc:create(function()
                         
    	                    -- for a=0, coinLiu_count do
    	                        for i=1, coin_count do

                                    -- local randomX = math.random(coin_count)/2
                                    -- local randomY = math.random(coin_count)/2

                                    local oriPosition = cc.p(zhuang_x,zhuang_y)

    	                            --筹码飞动 
    	                            local targetPos = cc.p(x, y)
    	                            coinfly(oriPosition,targetPos,i)

    	                        end
    	                    -- end

    	                    SoundUtils:playEffect("coinfly_long",false)
    	                    print("==628==")
                    
    	                    -- GamePlaneOperator:updateCoin(playerType,tbWin[uid],changedMoneyArr[uid])

                        end))

                        SCENENOW["scene"]:runAction(action)                 

                    else
                      
                        -- for a=0, coinLiu_count do
                            for i=1, coin_count do

                                -- local randomX = math.random(coin_count)/2
                                -- local randomY = math.random(coin_count)/2

                                local oriPosition = cc.p(zhuang_x, zhuang_y)

                                --筹码飞动
                                local targetPos = cc.p(x, y)
                                coinfly(oriPosition,targetPos,i)
                            end
                        -- end
                        print("==651==")
                        SoundUtils:playEffect("coinfly_long",false)
                        
                        -- GamePlaneOperator:updateCoin(playerType,tbWin[uid],changedMoneyArr[uid])
                    end

                end
            end

        end
        
    end
end


--画金币
function TablePlaneOperator:waiWeiCoinFly(playerType,pos,score,chip,finalPos)

    local  targetPos
    local  oriPos 

    if  finalPos == nil then
        print("waiWeiCoinFly_目标位置为nil")
        return
    end

    if  score > 0 then
        targetPos = pos 
        oriPos = finalPos  -- PLAYER_HEADS_POSITION_TABLE[bankerUid]
    else
        targetPos = finalPos -- PLAYER_HEADS_POSITION_TABLE[bankerUid]  --cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2 + 50)
        oriPos = pos
    end

    local  function coinfly(oriPos,targetPos,i)
            
        local frameName = jubaopen_img_path[math.random(4)]
        local coin_sp = cc.Sprite:createWithSpriteFrameName(frameName)
        -- local coin_sp = display.newSprite(jubaopen_img_path[math.random(4)])
        coin_sp:setPosition(oriPos)
        coin_sp:setScale(0.6)
        SCENENOW["scene"]:addChild(coin_sp, 100)

        local random = i

        if  random > 20 then
            random = 20
        end

        local delaytime = 0.4 + 0.1 * math.random(random)

        local jumpHeight = math.random(20,80)

        local mb = cc.JumpTo:create(delaytime, targetPos, jumpHeight, 1)
        local fo = cc.FadeOut:create(0.5)
        local remove_action = cc.CallFunc:create(function()           
              coin_sp:removeFromParent()
        end)

        local seq = cc.Sequence:create(mb, fo, remove_action) --cc.DelayTime:create(0.4),
        coin_sp:runAction(seq)

    end

    dump(oriPos,"waiWeiCoinFly")
    dump(targetPos,"waiWeiCoinFly")
    local coin_count = 10
    for i = 1,coin_count do 
        coinfly(oriPos,targetPos,coin_count)
    end

    if playerType then
        SCENENOW["scene"]:performWithDelay(function()
            -- GamePlaneOperator:setCoin(playerType,chip)
            GamePlaneOperator:updateCoin(playerType,score,{0,0},chip)
        end,1)
    end

end


function TablePlaneOperator:stopTimer()
    self.clock_txt:stopAllActions()
    self.progressClock:stopAllActions()
    
    self.clock:setVisible(false)
    self.stage_img:setVisible(false)
    self.stage_txt:setString("")
end

--设置倒计时时间显示
function TablePlaneOperator:startTimer(time,stage)
    
    dump(time,"startTimer_time")

    self.progressClock:stopAllActions()
    self.clock_txt:stopAllActions()

    if  time <= 0 then
        self.clock:setVisible(false)
        self.stage_img:setVisible(false)
        return
    end

    local  timer_value = time
    local  refreshTime = 1

    -- self.clock_txt:setString(timer_value)

    -- self.progressClock:setPercentage(0)
    -- self.progressClock:runAction(cc.ProgressTo:create(timer_value,100))

    if  stage == "抢庄阶段" then
        self.stage_txt:setString("请操作抢庄："..timer_value)
    elseif stage == "加倍阶段" then
        self.stage_txt:setString("请选择下注倍数："..timer_value)
    elseif stage == "出牌阶段" then
        self.stage_txt:setString("查看手牌："..timer_value)
    elseif stage == "准备阶段" then
        self.stage_txt:setString("即将开始："..timer_value)
    elseif stage == "外围抢庄阶段" then
        self.stage_txt:setString("外围抢庄中："..timer_value)
    elseif stage == "外围下注阶段" then
        self.stage_txt:setString("外围下注中："..timer_value)
    else
        self.stage_txt:setString("")
    end

    local   showTimerAc = cc.CallFunc:create(function()
            -- self.clock_txt:setString(timer_value)

            timer_value = timer_value - refreshTime

            if  timer_value > 0 then

                if  stage == "抢庄阶段" then
                    self.stage_txt:setString("请操作抢庄："..timer_value)
                elseif stage == "加倍阶段" then
                    self.stage_txt:setString("请选择下注倍数："..timer_value)
                elseif stage == "出牌阶段" then
                    self.stage_txt:setString("查看手牌："..timer_value)
                elseif stage == "准备阶段" then
                    self.stage_txt:setString("即将开始："..timer_value)
                elseif stage == "外围抢庄阶段" then
                    self.stage_txt:setString("外围抢庄中："..timer_value)
                elseif stage == "外围下注阶段" then
                    self.stage_txt:setString("外围下注中："..timer_value)
                elseif stage == "下注阶段" then
                    self.stage_txt:setString("下注中："..timer_value)
                elseif stage == "选牌阶段" then
                    self.stage_txt:setString("选牌中："..timer_value)
                elseif stage == "比牌阶段" then
                    self.stage_txt:setString("比牌中："..timer_value)
                end

            elseif  timer_value == 0 then

                if  stage == "抢庄阶段" then
                    self.stage_txt:setString("请操作抢庄...")
                elseif stage == "加倍阶段" then
                    self.stage_txt:setString("请选择下注倍数...")
                elseif stage == "出牌阶段" then
                    self.stage_txt:setString("查看手牌...")
                elseif stage == "准备阶段" then
                    self.stage_txt:setString("即将开始...")
                elseif stage == "外围抢庄阶段" then
                    self.stage_txt:setString("外围抢庄中...")
                elseif stage == "外围下注阶段" then
                    self.stage_txt:setString("外围下注中...")
                elseif stage == "下注阶段" then
                    self.stage_txt:setString("下注中："..timer_value)
                elseif stage == "选牌阶段" then
                    self.stage_txt:setString("选牌中："..timer_value)
                elseif stage == "比牌阶段" then
                    self.stage_txt:setString("比牌中："..timer_value)
                end

                self.clock_txt:stopAllActions()
                self.clock:setVisible(false)
                self.stage_img:setVisible(false)
                self.stage_txt:setString("")
            end


        end)

    local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime),showTimerAc)
    self.clock_txt:runAction(cc.RepeatForever:create(seqAc))

end

function TablePlaneOperator:showStageTxt(info)
    self:stopTimer()
    self.stage_txt:setString(info)
end

--显示游戏开始
function TablePlaneOperator:showStartAnimation()
      
	SoundUtils:playEffect("gameStart")

	local niuniu_start = NIUNIU_GAME_SCENE:getChildByName("niuniu_start") --游戏开始  
    local niuniu_start_txt = niuniu_start:getChildByName("niuniu_start_txt") --游戏开始  
          niuniu_start:loadTexture(TpackageName .. "/images/game_start_01.png")

    if niuniu_start_txt then
        niuniu_start_txt:removeFromParent()
    end

    niuniu_start_txt = display.newSprite(TpackageName .. "/images/game_start_02.png")
    niuniu_start:addChild(niuniu_start_txt)
    niuniu_start_txt:setName("niuniu_start_txt")
    niuniu_start_txt:setPosition(niuniu_start:getContentSize().width/2,niuniu_start:getContentSize().height/2)
    niuniu_start:setVisible(true)
    niuniu_start:setOpacity(255)
    niuniu_start:setScale(0.5)

    local start_fade = cc.FadeOut:create(0.3)
    local niuniuwei = cc.ScaleTo:create(0.2,1)

	local delay= cc.DelayTime:create(0.6)
    niuniu_start:runAction(cc.Sequence:create(niuniuwei,delay,start_fade))

	niuniu_start:setZOrder(999)

end


--显示游戏结束动画
function TablePlaneOperator:showGameEndAnimation(isWin)
      
    local niuniu_start = NIUNIU_GAME_SCENE:getChildByName("niuniu_start") --游戏开始  
    
    local niuniu_start_txt = niuniu_start:getChildByName("niuniu_start_txt") --游戏开始  
    
    if  niuniu_start_txt then
        niuniu_start_txt:removeFromParent()
    end
 
    if  isWin == true then
        niuniu_start:loadTexture(TpackageName .. "/images/game_end.png")
        niuniu_start_txt = display.newSprite(TpackageName .. "/images/win_txt.png")
        SoundUtils:playEffect("赢")
    else
        niuniu_start:loadTexture(TpackageName .. "/images/game_end.png")
        niuniu_start_txt = display.newSprite(TpackageName .. "/images/lose_txt.png")
        SoundUtils:playEffect("输")
    end
    
    niuniu_start_txt:setPosition(niuniu_start:getContentSize().width/2,niuniu_start:getContentSize().height/2)
    
    niuniu_start:addChild(niuniu_start_txt)
    niuniu_start_txt:setName("niuniu_start_txt")
     
    niuniu_start:setVisible(true)
    niuniu_start:setOpacity(255)

    local start_fade = cc.FadeOut:create(0.8)
    local delay= cc.DelayTime:create(1.1)
    niuniu_start:runAction(cc.Sequence:create(delay,start_fade))

    niuniu_start:setZOrder(999)

end

function TablePlaneOperator:showRandomBankerChoose(random_banker)
    
    if  next(random_banker) == nil then
        return
    end

    self.banker_choose_frame:setOpacity(255)
    self.banker_choose_frame:setVisible(true)
    self.banker_choose_frame:stopAllActions()

    local  random_banker = random_banker

    local  random_banker_size = #random_banker

    local  callfunc = cc.CallFunc:create(function()

    local  random_uid = random_banker[math.random(1,random_banker_size)] or 0

    if random_banker_size>1 then
    
        while random_uid == random_uid_ex do
            random_uid = random_banker[math.random(1,random_banker_size)] or 0
        end

        SoundUtils:playEffect(8)
    end
    
    self.banker_choose_frame:setScale(1.2)
    random_uid_ex = random_uid
    self.banker_choose_frame:setPosition(cc.p(PLAYER_HEADS_POSITION_TABLE[random_uid].x*GLOBAL_SCALE,PLAYER_HEADS_POSITION_TABLE[random_uid].y*GLOBAL_SCALE_Y))  

    end)
   
   local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay)) 
   self.banker_choose_frame:runAction(cc.RepeatForever:create(seqAc))
end

function TablePlaneOperator:showBankerChoose(uid)
	self.banker_choose_frame:stopAllActions()
	self.banker_choose_frame:setPosition(cc.p(PLAYER_HEADS_POSITION_TABLE[uid].x*GLOBAL_SCALE,PLAYER_HEADS_POSITION_TABLE[uid].y*GLOBAL_SCALE_Y))
	self.banker_choose_frame:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.3,1.3),
        cc.Spawn:create(cc.ScaleTo:create(0.5,1),cc.FadeOut:create(1.2)),
        cc.CallFunc:create(function()
            local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
                GamePlaneOperator:setEffectFrame(playerType,2)
            end)
        ))
end


function TablePlaneOperator:showRandomBankerChoose(random_banker)
    
    if  next(random_banker) == nil then
        return
    end
    
    self.banker_choose_frame:stopAllActions()
    math.randomseed(os.time())

    local  random_banker = random_banker

    local  random_banker_size = #random_banker

    local  callfunc = cc.CallFunc:create(function()
        
        if  random_uid_ex ~= -1 then
            local playerType_ex = NIUNIU_PLAYERTYPE_TABLE[random_uid_ex]
            -- dump(playerType_ex,"showRandomBankerChoose_playerType_ex")
            GamePlaneOperator:setEffectFrame(playerType_ex,1,false)
        end

        local  random_uid = random_banker[math.random(1,random_banker_size)] or 0

        if random_banker_size>1 then

            while random_uid == random_uid_ex do
                random_uid = random_banker[math.random(1,random_banker_size)] or 0
            end

            SoundUtils:playEffect(8)
        end

        random_uid_ex = random_uid

        local  playerType = NIUNIU_PLAYERTYPE_TABLE[random_uid]
        -- dump(playerType,"showRandomBankerChoose_playerType")
        GamePlaneOperator:setEffectFrame(playerType,1,true)
        
    end)
    
    local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay)) 
    self.banker_choose_frame:runAction(cc.RepeatForever:create(seqAc))

end


function TablePlaneOperator:showBankerChoose(uid)
   
    self.banker_choose_frame:stopAllActions()

    local  playerType = NIUNIU_PLAYERTYPE_TABLE[uid]

    local  callfunc = cc.CallFunc:create(function()
        GamePlaneOperator:clearEffectFrame()
        GamePlaneOperator:setEffectFrame(playerType,1,true)
    end)
    
    local  callfunc2 = cc.CallFunc:create(function()
        GamePlaneOperator:setEffectFrame(playerType,2)
    end)

    local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay+0.2),callfunc2) 

    self.banker_choose_frame:runAction(seqAc)
    
    random_uid_ex = -1
end

return TablePlaneOperator