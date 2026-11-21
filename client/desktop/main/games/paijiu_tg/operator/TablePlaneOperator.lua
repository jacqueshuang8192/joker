local TablePlaneOperator = class("TablePlaneOperator")
local Card = require(TpackageName .. ".DominoCard")

local random_uid_ex = -1

--抢庄特效间隔
local GrabBankerDelay = 0.23

local coin_img_path = TpackageName .. "/images/effect_gold.png"

local cacheFrames = cc.SpriteFrameCache:getInstance()

local jubaopen_img_path = { [1] = TpackageName .. "/images/jubaopen_2.png" ,
                            [2] = TpackageName .. "/images/jubaopen_3.png" ,
                            [3] = TpackageName .. "/images/jubaopen_4.png" ,
                            [4] = TpackageName .. "/images/jubaopen_5.png" }

local POOL_CARD_COUNT_PER_ROW = 8
local POOL_ROW_SPACE = 10
local POOL_COL_SPACE = 3
local POOL_Y_EDGE = 20
local POOL_X_EDGE = 50

function TablePlaneOperator:init(panel)

    -- self.coin:setPosition(cc.p(-100,-100))
    -- self.coin:setScale(0.6)
    -- PAIJIU_GAME_SCENE:addChild(self.coin)
    --cacheFrames:addSpriteFrames(TpackageName .. "/images/coins.plist")

	self.banker_choose_frame = panel:getChildByName("banker_choose_frame")
    -- 倒计时
    self.clock = panel:getChildByName("clock_panel")
    self.clock:setVisible(false)
    self.clock_txt = self.clock:getChildByName("fnt_clock_time")

    self.progressClock = cc.ProgressTimer:create(cc.Sprite:create(TpackageName .. "/images/leftTime_bg.png"))
    self.progressClock:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    local clock_bottom = self.clock:getChildByName("sp_clock_bottom")
    self.progressClock:setPosition(clock_bottom:getPosition())
    self.clock:addChild(self.progressClock)

    -------------------------- 中心牌堆 ------------------------
    self.card_pool_panel = PAIJIU_GAME_SCENE:getChildByName("card_pool_panel")
    self.card_pool_panel:setVisible(true)

    -------------------------- 骰钟和骰子 ---------------------
    self.dice_panel = panel:getChildByName("dice_panel")
    self.dice_panel:setVisible(false)
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
    elseif stage == 2 or stage == nil then
--[[    	RANDOM_BANKER = {}

        self.stage_img:setVisible(false)
        self:resetCardNumCount()

        local hall_panel = PAIJIU_GAME_SCENE:getParent():getChildByName("hall_panel")
        local btn_switch_bet_mode = hall_panel:getChildByName("btn_switch_bet_mode")
        local bottom_img = btn_switch_bet_mode:getChildByName("bottom_img")

              btn_switch_bet_mode:setPosition(cc.p(96,110))
              btn_switch_bet_mode:setScale(1)
              bottom_img:setColor(cc.c3b(125,125,125))]]
              -- bottom_img:setContentSize(cc.size(110,102))
    end
end

function TablePlaneOperator:resetCardNumCount()

    local left_txt = self.niuniu_cardcount_panel:getChildByName("left_txt")
    local middle_txt = self.niuniu_cardcount_panel:getChildByName("middle_txt")
    local right_txt = self.niuniu_cardcount_panel:getChildByName("right_txt")
    local result_txt = self.niuniu_cardcount_panel:getChildByName("result_txt")

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
        local lbVersion = cc.Label:createWithTTF(taiFeiTxt, TpackageName .."/font/fzcyjt.TTF",50)
        lbVersion:setColor(cc.c3b(255, 40, 40))
        lbVersion:setPosition(cc.p(PAIJIU_GAME_SCENE:getContentSize().width/2,100))
        PAIJIU_GAME_SCENE:addChild(lbVersion,9999)
        lbVersion:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() lbVersion:removeFromParent() end)))
    end

    
end

function TablePlaneOperator:showAutoPlayTip(flag)
    --添加扣除台费显示

    local hall_panel = PAIJIU_GAME_SCENE:getParent():getChildByName("hall_panel")
    local btn_auto_play = hall_panel:getChildByName("btn_auto_play")

    if  flag == true then
        dump("提示自己进入托管状态")
        -- local tipTxt =  "您正处于托管状态..."
        -- local autoPlayTip = cc.Label:createWithTTF(tipTxt,""res/fonts/fzcy.ttf"",45):addTo(PAIJIU_GAME_SCENE,1001)
        -- autoPlayTip:setColor(cc.c3b(0, 0, 0))
        -- autoPlayTip:setPosition(cc.p(PAIJIU_GAME_SCENE:getContentSize().width/2,470))
        -- autoPlayTip:setName("autoPlayTip")
        self.auto_cancel_panel:setVisible(true)
        btn_auto_play:setBright(false)
    else
        dump("隐藏托管状态")
        -- local autoPlayTip = PAIJIU_GAME_SCENE:getChildByName("autoPlayTip") 
        -- if  autoPlayTip then
        --     autoPlayTip:removeFromParent()
        -- end
        self.auto_cancel_panel:setVisible(false)
        btn_auto_play:setBright(true)
    end
end

function TablePlaneOperator:showNumCount(value,index,flag)
    
    self.niuniu_cardcount_panel:setVisible(true)

    if  value == nil then
        return
    end

    local value = require(TpackageName .. ".cardLogic"):GetCardLogicValue(value) 

    local left_txt = self.niuniu_cardcount_panel:getChildByName("left_txt")
    local middle_txt = self.niuniu_cardcount_panel:getChildByName("middle_txt")
    local right_txt = self.niuniu_cardcount_panel:getChildByName("right_txt")
    local result_txt = self.niuniu_cardcount_panel:getChildByName("result_txt")
    
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

    self.niuniu_cardcount_panel:setVisible(true)

    local left_num = arg.left_num

    local middle_num = arg.middle_num

    local right_num = arg.right_num
    
    local left_txt = self.niuniu_cardcount_panel:getChildByName("left_txt")
    local middle_txt = self.niuniu_cardcount_panel:getChildByName("middle_txt")
    local right_txt = self.niuniu_cardcount_panel:getChildByName("right_txt")
    local result_txt = self.niuniu_cardcount_panel:getChildByName("result_txt")
   
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
        self.niuniu_cardcount_panel:setVisible(false)
    end,2)

end

function TablePlaneOperator:hideCardNumCountEffect()
    self.niuniu_cardcount_panel:setVisible(false)
end

--画金币
function TablePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,oriChipTable,_type)
     
    --获取庄位置
    dump(bankerUid, "-----庄家UID-----")
    math.randomseed(os.time())
   
    local bankerPlayerType = PAIJIU_PLAYERTYPE_TABLE[bankerUid]
    
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

        coinfly = function(oriPos,targetPos,i)
             
            local coin_sp = display.newSprite(coin_img_path)
            coin_sp:setPosition(oriPos)
            coin_sp:setScale(0.6)
            SCENENOW["scene"]:addChild(coin_sp, 100)

            local random = i

            if  random > 20 then
                random = 20
            end

            local delaytime = 0.4 + 0.1 * math.random(random)

            local jumpHeight = 50

            local mb = cc.JumpTo:create(delaytime, targetPos, jumpHeight, 1)
            local fo = cc.FadeOut:create(0.5)
            local remove_action = cc.CallFunc:create(function()           
                coin_sp:removeSelf()
            end)

            local seq = cc.Sequence:create(mb, fo, remove_action) --cc.DelayTime:create(0.4),
            coin_sp:runAction(seq)

        end

    end
    
    
    local ZhuangWinDelay = 2
    --显示更新内容（文字和筹码）
    for uid,value in pairs(tbWin) do
       
        local  playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        dump(playerType, "-----对应座位-----")
        dump(value, "-----更新筹码数-----")
             
        local pos = PLAYER_HEADS_POSITION_TABLE[uid]

        if  playerType then

            local x = pos.x
            local y = pos.y
            
            local pos = PLAYER_HEADS_POSITION_TABLE[bankerUid]
            local zhuang_x = pos.x
            local zhuang_y = pos.y
           
            --计算生成筹码数
            local coin_count = math.abs(math.ceil(value/BASE_CHIP))
            -- if coin_count > 0 and coin_count < 5 then
            --     coin_count = 1
            -- end
            
            if coin_count > 30 then
               coin_count = 30
            end

            -- local coinLiu_count = 5             

            --判断当前位置是否为庄
            if playerType == bankerPlayerType then

                if  isZhuanWin == true and playerCount > 2 then
                    GamePlaneOperator:updateCoin(playerType,zhuang_win,oriChipTable[uid],uid)

                    SCENENOW["scene"]:performWithDelay(function() 
                        GamePlaneOperator:updateCoin(playerType,zhuang_lose,oriChipTable[uid],uid)
                    end, ZhuangWinDelay) 
                else
                    GamePlaneOperator:updateCoin(playerType,tbWin[uid],oriChipTable[uid],uid)
                end

            else --当前用户不是庄家

                --添加显示减少的筹码
                if value < 0 then

                    --玩家输，筹码从玩家生成，飞向庄家
                    dump("-----筹码飞动，玩家输，飞向庄家x-----")
                    --金币流数    

                    -- for a=0, coinLiu_count*coin_count do
                    -- for a=0, coinLiu_count do 
                        --添加筹码
                        for i=1,coin_count do
                             
                            local randomX = math.random(coin_count)/2
                            local randomY = math.random(coin_count)/2
                              
                            local oriPosition = cc.p(x+randomX, y+randomY)
                            local targetPos = cc.p(zhuang_x, zhuang_y)

                            coinfly(oriPosition,targetPos,i)

                        end

                    -- end

                    SoundUtils:playEffect("coinfly_short",false)

                   	GamePlaneOperator:updateCoin(playerType,tbWin[uid],oriChipTable[uid],uid)

                elseif value > 0 then

                    --玩家赢，筹码从庄家生成，飞向玩家
                    dump(x, "-----筹码飞动，玩家赢，飞向玩家x-----")
                    dump(y, "-----筹码飞动，玩家赢，飞向玩家y-----")          

                    --添加筹码

                    if isZhuanWin == true and playerCount > 2 then
                        --庄有赢而且当前玩家数大于2

                        local action = cc.Sequence:create(cc.DelayTime:create(ZhuangWinDelay),cc.CallFunc:create(function()
                         
    	                    -- for a=0, coinLiu_count do
    	                        for i=1, coin_count do

                                    local randomX = math.random(coin_count)/2
                                    local randomY = math.random(coin_count)/2

                                    local oriPosition = cc.p(zhuang_x + randomX, zhuang_y + randomY)

    	                            --筹码飞动 
    	                            local targetPos = cc.p(x, y)
    	                            coinfly(oriPosition,targetPos,i)

    	                        end
    	                    -- end

    	                    SoundUtils:playEffect("coinfly_long",false)
    	                    
    	                    GamePlaneOperator:updateCoin(playerType,tbWin[uid],oriChipTable[uid],uid)

                        end))

                        SCENENOW["scene"]:runAction(action)                 

                    else
                      
                        -- for a=0, coinLiu_count do
                            for i=1, coin_count do

                                local randomX = math.random(coin_count)/2
                                local randomY = math.random(coin_count)/2

                                local oriPosition = cc.p(zhuang_x +randomX, zhuang_y+randomY)

                                --筹码飞动
                                local targetPos = cc.p(x, y)
                                coinfly(oriPosition,targetPos,i)
                            end
                        -- end
       
                        SoundUtils:playEffect("coinfly_long",false)
                        GamePlaneOperator:updateCoin(playerType,tbWin[uid],oriChipTable[uid],uid)

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
            GamePlaneOperator:updateCoin(playerType,score,chip)
        end,1)
    end

end

function TablePlaneOperator:stopTimer()
    self.clock_txt:stopAllActions()
    self.progressClock:stopAllActions()
    
    self.clock:setVisible(false)
    --self.stage_img:setVisible(false)
end

--设置倒计时时间显示
function TablePlaneOperator:startTimer(time, stage)
    
    dump(time,"startTimer_time")

    self.clock_txt:stopAllActions()
    self.progressClock:stopAllActions()

    --self.stage_txt:setString("您正处于买牛模式...")

    if  time <= 0 then
        self.clock:setVisible(false)
        self.stage_img:setVisible(false)
        return
    else
        self.clock:setVisible(true)
    end

    local  timer_value = time
    local  refreshTime = 1

    self.clock_txt:setString(tostring(timer_value))

    self.progressClock:setPercentage(0)
    local showProgressAc = cc.ProgressTo:create(timer_value,100)
    self.progressClock:runAction(showProgressAc)

    local showTimerAc = cc.CallFunc:create(function()
          timer_value = timer_value - refreshTime

          self.clock_txt:setString(tostring(timer_value))
--[[          if stage == "下注阶段" then
             self.stage_txt:setVisible(true)
             self.stage_txt:setString("离截止买牛还有"..timer_value.. "秒")
          end]]
        --SoundUtils:playEffect("倒计时")
        if timer_value == 0 then

            self.clock_txt:stopAllActions()

            self.clock:setVisible(false)
            --[[                self.stage_img:setVisible(false)]]
            -- if  MY_TOTAL_BET_CHIP > 0  then
            --     self.stage_txt:setVisible(true)
            -- else
            --     self.stage_txt:setVisible(false)
            -- end
        end

    end)

    local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime), showTimerAc)
    self.clock_txt:runAction(cc.RepeatForever:create(seqAc))

    -----------------------------阶段显示------------------
--[[    if  stage == nil then
        return
    end]]
--[[

    local my_total_bet_chip =  SINGLE_BET_CHIP[USER_INFO["uid"]]--[[


    if  my_total_bet_chip and my_total_bet_chip > 0  then
        self.stage_txt:setVisible(true)
        self.stage_txt:setString("我的总下注:"..my_total_bet_chip)
    else
        self.stage_txt:setVisible(false)
    end

    local stage_pic = ""
    if stage == "抢庄阶段" then

         stage_pic = "text_qiangzhuangjieduan.png" --抢庄阶段

    elseif stage == "加倍阶段" then

         stage_pic = "text_jiabei.png" --加倍阶段

    elseif stage == "出牌阶段" then

         stage_pic = "text_chupaijieduan.png" --出牌阶段

    elseif stage == "准备阶段" then

         stage_pic = "text_ready.png" --请准备
    end

    self.stage_img:setVisible(true)

    if stage_pic~="" then
        self.stage_img:setTexture(TpackageName .. "/images/"..stage_pic)
    end
]]
end

function TablePlaneOperator:showStageTxt(flag)
    self.stage_txt:setVisible(flag)
end

--显示游戏开始
function TablePlaneOperator:showStartAnimation()
      
	SoundUtils:playEffect("gameStart")

	local niuniu_start = PAIJIU_GAME_SCENE:getChildByName("niuniu_start") --游戏开始  
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

--显示游戏结果
function TablePlaneOperator:showGameEndAnimation(isWin)
      
    local niuniu_start = PAIJIU_GAME_SCENE:getChildByName("niuniu_start") --游戏开始  
    
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

function TablePlaneOperator:showRandomBankerChoose(grabBankerCount, grabBankerArray)
    
    if  next(grabBankerArray) == nil then
        return
    end

    self.banker_choose_frame:setOpacity(255)
    self.banker_choose_frame:setVisible(true)
    self.banker_choose_frame:stopAllActions()

    --local  random_banker = random_banker

    --local  random_banker_size = #random_banker

    local  callfunc = cc.CallFunc:create(function()
        local  random_uid = grabBankerArray[math.random(1,grabBankerCount)] or 0
--[[            if grabBankerCount>1 then
                while random_uid == random_uid_ex do
                    random_uid = random_banker[math.random(1,random_banker_size)] or 0
                end
            end]]
            SoundUtils:playEffect(8)
            --self.banker_choose_frame:setScale(1.2)
            --random_uid_ex = random_uid
            --self.banker_choose_frame:setPosition(cc.p(PLAYER_HEADS_POSITION_TABLE[random_uid].x*GLOBAL_SCALE,PLAYER_HEADS_POSITION_TABLE[random_uid].y*GLOBAL_SCALE))
        self.banker_choose_frame:setPosition(cc.p(PLAYER_HEADS_POSITION_TABLE[random_uid].x, PLAYER_HEADS_POSITION_TABLE[random_uid].y))
    end)
   
   local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay)) 
   self.banker_choose_frame:runAction(cc.RepeatForever:create(seqAc))
end

function TablePlaneOperator:showBankerChoose(uid)
   
    self.banker_choose_frame:stopAllActions()

    local  playerType = PAIJIU_PLAYERTYPE_TABLE[uid]

    local  callfunc = cc.CallFunc:create(function()
        --GamePlaneOperator:clearEffectFrame()
        --GamePlaneOperator:setEffectFrame(playerType,1,true)
        GamePlaneOperator:showBankerFrame(playerType, true)
    end)
    
    local  callfunc2 = cc.CallFunc:create(function()
        --GamePlaneOperator:setEffectFrame(playerType,2)
        GamePlaneOperator:showBankerFrame(playerType, false)
    end)

    local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay+0.2),callfunc2) 

    self.banker_choose_frame:runAction(seqAc)
    
    --random_uid_ex = -1
end

function TablePlaneOperator:showPoolCards(showCards)

    -- if not (self.card_pool_panel and showCards and #showCards) then
    --     return
    -- end
    -- if true then
    --     return
    -- end

    -- self.card_pool_panel:removeAllChildren()

    -- local scale = 0.4
    -- local card = Card:new(0)
    -- local panelSize = self.card_pool_panel:getContentSize()
    -- local scale = panelSize.height / card:getSize().height

    -- local cardHeight = card:getSize().height * scale
    -- local cardWidth = card:getSize().width * scale + POOL_COL_SPACE
    -- local interval = 6
    -- local height = math.ceil(#showCards / interval) * (panelSize.height + 10)
    -- if height < panelSize.height then
    --     height = panelSize.height
    -- end

    -- for index,value in ipairs(showCards) do
    --     card = Card:new(value)
    --     card:setScale(scale)
    --     local  y = math.ceil(index / interval)
    --     local indexY = height - (cardHeight) * y
    --     if y > 1 then
    --         index = index % interval
    --         if index == 0 then
    --             index = interval
    --         end 
    --     end
    --     local x = (index-1) * (cardWidth+10)
    --     card:setPosition(cc.p(x, indexY))
    --     self.card_pool_panel:addChild(card)
    -- end

    if not self.card_pool_panel then
        return
    end

    self.card_pool_panel:removeAllChildren()

    local totalRow = PJ_TOTAL_CARD_COUNT / POOL_CARD_COUNT_PER_ROW
    if PJ_TOTAL_CARD_COUNT % POOL_CARD_COUNT_PER_ROW ~= 0 then
        --todo
        totalRow = totalRow + 1
    end

    if totalRow == 0 then
        --todo
        return
    end

    local nonShowCardCount = PJ_TOTAL_CARD_COUNT - #showCards

    local totalCards = {}

    for i=1,#showCards do
        table.insert(totalCards, showCards[i])
    end

    for i=1,nonShowCardCount do
        table.insert(totalCards, 0)
    end

    local cardHeight = (self.card_pool_panel:getContentSize().height - POOL_Y_EDGE * 2 - (totalRow - 1) * POOL_ROW_SPACE) / totalRow
    local cardWidth = (self.card_pool_panel:getContentSize().width - POOL_X_EDGE * 2 - (POOL_CARD_COUNT_PER_ROW - 1) * POOL_COL_SPACE) / POOL_CARD_COUNT_PER_ROW

    local card = Card:new(0)

    local scale1 = cardHeight / card:getSize().height
    local scale2 = cardWidth / card:getSize().width

    local scale = scale1
    if scale1 > scale2 then
        --todo
        scale = scale2
    end

    cardHeight = card:getSize().height * scale
    cardWidth = card:getSize().width * scale

    local oriX = (self.card_pool_panel:getContentSize().width - POOL_CARD_COUNT_PER_ROW * cardWidth - (POOL_CARD_COUNT_PER_ROW - 1) * POOL_COL_SPACE) / 2
    local oriY = (self.card_pool_panel:getContentSize().height - totalRow * cardHeight - (totalRow - 1) * POOL_ROW_SPACE) / 2

    for i,v in ipairs(totalCards) do
        card = Card:new(v)

        card:setScale(scale)

        local row = math.floor((i - 1) / POOL_CARD_COUNT_PER_ROW)
        local col = (i - 1) % POOL_CARD_COUNT_PER_ROW

        local x = oriX + (cardWidth + POOL_COL_SPACE) * col + cardWidth / 2
        local y = oriY + (cardHeight + POOL_ROW_SPACE) * row + cardHeight / 2

        card:setPosition(cc.p(x, y))

        self.card_pool_panel:addChild(card)
    end
end

function TablePlaneOperator:showRemainCards(remainCount)

    -- if not self.card_pool_panel then
    --     return
    -- end
    -- self.card_pool_panel:removeAllChildren()
    -- if remainCount == 0 then
    --     return
    -- end

    -- local card = Card:new(0)
    -- local size = self.card_pool_panel:getContentSize()
    -- local scale = size.height / card:getSize().height

    -- local cardHeight = card:getSize().height * scale
    -- local cardWidth = card:getSize().width * scale + POOL_COL_SPACE
    
    -- local oriX = size.width - (POOL_CARD_COUNT_PER_ROW * cardWidth) - cardWidth / 2
    -- local oriY = size.height / 2

    -- local number = remainCount
    -- local cardIdx = 1
    -- for idx=1,number/2 do
    --     for index = 1,2 do
    --         card = Card:new(0)
    --         -- local value = totalCards[idx]
    --         -- card = Card:new(value)
    --         -- cardIdx = cardIdx + 1
    --         card:setScale(scale)
    --         local x = oriX + cardWidth * (idx - 1) 
    --         local y = oriY + ((index-1) * 20)
    --         card:setPosition(cc.p(x, y))
    --         self.card_pool_panel:addChild(card)
    --     end
    -- end

    
    if not self.card_pool_panel then
        return
    end

    self.card_pool_panel:removeAllChildren()

    if remainCount == 0 then
        --todo
        return
    end

    local totalRow = remainCount / POOL_CARD_COUNT_PER_ROW
    if remainCount % POOL_CARD_COUNT_PER_ROW ~= 0 then
        --todo
        totalRow = totalRow + 1
    end

    if totalRow == 0 then
        --todo
        return
    end

    local totalCards = {}

    for i=1,remainCount do
        table.insert(totalCards, 0)
    end

    local cardHeight = (self.card_pool_panel:getContentSize().height - POOL_Y_EDGE * 2 - (totalRow - 1) * POOL_ROW_SPACE) / totalRow
    local cardWidth = (self.card_pool_panel:getContentSize().width - POOL_X_EDGE * 2 - (POOL_CARD_COUNT_PER_ROW - 1) * POOL_COL_SPACE) / POOL_CARD_COUNT_PER_ROW

    local card = Card:new(0)

    local scale1 = cardHeight / card:getSize().height
    local scale2 = cardWidth / card:getSize().width

    local scale = scale1
    if scale1 > scale2 then
        --todo
        scale = scale2
    end

    cardHeight = card:getSize().height * scale
    cardWidth = card:getSize().width * scale

    local oriX = (self.card_pool_panel:getContentSize().width - POOL_CARD_COUNT_PER_ROW * cardWidth - (POOL_CARD_COUNT_PER_ROW - 1) * POOL_COL_SPACE) / 2
    local oriY = (self.card_pool_panel:getContentSize().height - totalRow * cardHeight - (totalRow - 1) * POOL_ROW_SPACE) / 2

    for i,v in ipairs(totalCards) do
        card = Card:new(v)

        card:setScale(scale)

        local row = math.floor((i - 1) / POOL_CARD_COUNT_PER_ROW)
        local col = (i - 1) % POOL_CARD_COUNT_PER_ROW

        local x = oriX + (cardWidth + POOL_COL_SPACE) * col + cardWidth / 2
        local y = oriY + (cardHeight + POOL_ROW_SPACE) * row + cardHeight / 2

        card:setPosition(cc.p(x, y))

        self.card_pool_panel:addChild(card)
    end
end


function TablePlaneOperator:showShizi()
    local dice_cover = self.dice_panel:getChildByName("dice_cover")
    dice_cover:stopAllActions()
    self.dice_panel:stopAllActions()
    self.dice_panel:setVisible(false)
end

--几个骰子，骰子数字，整个动画的时间
function TablePlaneOperator:showShiziAnimotion(shaiziCount, shaiziArray, outTime)
    --[[    local animation_node = PAIJIU_GAME_SCENE:getChildByName("node_shaizi")
        animation_node:setVisible(true)
        --色子开始动画
        local start_image = self:CreactObjectByName("ImageView",-1000,-100)
        start_image:loadTexture("paijiu/images/animation/1.png")
        start_image:setName("start_image")
        --start_image:setScale(0.7)
        animation_node:addChild(start_image)
        start_image:moveTo(0.3, -165, -130)
        bm.SchedulerPool:delayCall(function()
            animation_node:removeChildByName("start_image", true)
        end, 0.6)
        --色子摇的动画
        bm.SchedulerPool:delayCall(function()
            SoundUtils:playEffect("色子")
            display.addSpriteFrames(TpackageName .. "/images/animation/Plist.plist", TpackageName.."/images/animation/Plist.png")
            local pic_num = 13
            local time =0.07
            local sprite =display.newSprite("#1.png")
            sprite:setPosition(cc.p(0, -12))
            local frames = display.newFrames("%d.png", 1, pic_num)
            local animation = display.newAnimation(frames, time)
            sprite:playAnimationOnce(animation)
            --animation_node:setScale(0.7)
            animation_node:addChild(sprite)

            bm.SchedulerPool:delayCall(function()
                local positionX
                for i = 1 , shaiziCount do
                    if i == 1 then
                        positionX = 0
                    else
                        positionX = -45
                    end
                    local dice_point_image = self:CreactObjectByName("ImageView", positionX ,-163)
                    dice_point_image:loadTexture(TpackageName.."/images/animation/dice_number_"..shaiziArray[i]..".png")
                    animation_node:addChild(dice_point_image)
                end
            end,0.8)
        end,0.6)
        bm.SchedulerPool:delayCall(function()
            animation_node:removeAllChildren()
            animation_node:setVisible(false)
        end,outTime)]]
    self.dice_panel:setVisible(true)
    self.dice_panel:setRotation(0)

    --local playerType,dice_value_list,animateTime = ...

    -- local dice_1 = display.newSprite(dice1_value):addTo(self.dice_plane)
    -- local dice_2 = display.newSprite(dice2_value):addTo(self.dice_plane)
    -- 计算骰子飞向谁
    local target_number = 0
    for _, i in ipairs(shaiziArray) do
        target_number = target_number + i
    end
    target_number=(target_number+PAIJIU_PLAYERTYPE_TABLE[BANKER_UID]-1)%TOTAL_PLAYERNUM
    local pos
    if target_number==1 then
        pos=cc.p(0,-350)
        BANKER_MSG=1
    elseif target_number==2 then
        pos=cc.p(600,0)
        BANKER_MSG=2
    elseif target_number==3 then
        pos=cc.p(0,450)
        BANKER_MSG=3
    else
        pos=cc.p(-600,0)
        BANKER_MSG=4
    end

    --local target_playerType = target_number + 1
    --local playerPanel = GamePlaneOperator:getPlayerPlane(target_playerType)
    --local targetPlane = playerPanel:getChildByName("inhand_plane")
    self.dice_panel:setVisible(true)
    self.dice_panel:setRotation(0)

    local dice_cover = self.dice_panel:getChildByName("dice_cover")
    dice_cover:setPositionY(185)

    local dice_bottom = self.dice_panel:getChildByName("dice_bottom")

    local rollToRightAc = cc.RotateTo:create(0.08,-20)
    local rollToLeftAc = cc.RotateTo:create(0.08,20)

    local rollAc = cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(rollToRightAc,rollToLeftAc), outTime),cc.RotateTo:create(0.1,0))

    local openCoverAc = cc.CallFunc:create(function()
--[[        dice_cover:runAction(cc.Sequence:create(cc.MoveBy:create(0.4, cc.p(0,200))), cc.CallFunc:create(function ()
            dice_cover:setVisible(false)
        end))]]
        dice_cover:runAction(cc.MoveBy:create(0.4, cc.p(0,200)))
    end)

    --local targetPos_world = (targetPlane:getParent()):convertToWorldSpace(targetPlane:getPosition())

    --local targetPos_node  = self.dice_panel:convertToNodeSpace(targetPos_world)

--[[    if 	target_playerType == CARD_PLAYERTYPE_MY then
        targetPos_node.y = targetPos_node.y - 100
    end]]

    local dice_bottom_middle_x = dice_bottom:getContentSize().width/2

    local dice_bottom_middle_y = dice_bottom:getContentSize().height/2

    local showRollResult = cc.CallFunc:create(function()

        for i = 1,2 do
            local dice_point_image = ccui.ImageView:create()
            dice_point_image:loadTexture(TpackageName.."/images/animation/dice_number_"..shaiziArray[i]..".png")
            --dice_point_image:setPosition(cc.p( dice_bottom_middle_x + (i - 1.5) * 50 + math.random(-7,7), dice_bottom_middle_y+math.random(-10,10)))
            dice_point_image:setPosition(cc.p( dice_bottom_middle_x + (i - 1.5) * 50 , dice_bottom_middle_y))
            dice_bottom:addChild(dice_point_image)
            local callFunc2 = cc.CallFunc:create(function()
                self.dice_panel:setVisible(false)
                dice_bottom:removeAllChildren()
            end)

            local dicepos=dice_point_image:getPosition()
            dice_point_image:runAction(cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.MoveTo:create(0.5,cc.p(dicepos.x+pos.x,dicepos.y+pos.y)),
            cc.DelayTime:create(outTime*0.1),
            callFunc2))
            -- self:showDiceRollAnim(animSprite,dice_value_list[i],cc.p(targetPos_node.x + (i - 1.5) * 50,targetPos_node.y))
        end

    end)
    SoundUtils:playEffect("色子")

    local roll_dice_ac = cc.Sequence:create(rollAc, openCoverAc, showRollResult)
    self.dice_panel:runAction(roll_dice_ac)
end

function TablePlaneOperator:CreactObjectByName(name,position_X,position_Y)
    local obj
    if name == "ImageView" then
        obj = ccui.ImageView:create()
    elseif name == "Button" then
        obj = ccui.Button:create()
    elseif name == "Sprite" then
        obj = ccui.Sprite:create()
    elseif name == "Text" then
        obj = ccui.Text:create()
    end
    obj:setAnchorPoint(0,0)
    obj:setPositionX(position_X)
    obj:setPositionY(position_Y)
    return obj
end

return TablePlaneOperator