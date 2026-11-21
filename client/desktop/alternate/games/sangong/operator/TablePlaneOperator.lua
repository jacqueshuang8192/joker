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
    self.btn_ready = SanGongPanel.hall_plane.btn_ready--准备
    self.share_btn = SanGongPanel.hall_plane.share_btn--微信邀请
    self.copy_btn = SanGongPanel.hall_plane.copy_btn--复制房间号
    self.btn_check_group_result = SanGongPanel.hall_plane.btn_check_group_result--查看总结算
    self.bet_plane = SanGongPanel.hall_plane.bet_plane--下注分数
    self.grab_banker_plane = SanGongPanel.hall_plane.grab_banker_plane--抢庄
    self.xiazhu = SanGongPanel.game_plane.xiazhu--下注滑动条
    self.btn_xiazhu = self.xiazhu.btn_xiazhu
    self.Slider_1 = self.xiazhu.Slider_1
    self.bei_txt = self.xiazhu.bei_txt

    self.btn_bet = SanGongPanel.hall_plane.btn_bet--抢庄
    self.stage_img = SanGongPanel.hall_plane.stage_img--倒计时
    self.stage_txt = self.stage_img.stage_txt
    self.btn_fanpai = SanGongPanel.hall_plane.btn_fanpai--翻牌
    self.btn_outcard = SanGongPanel.hall_plane.btn_outcard--搓牌之后 亮牌

    self.share_btn:onClick(handler(self, self.onClickShare))
    for playerType = 1,TOTAL_PLAYERNUM do
        self:setSeatGold(playerType,0)
    end
end
function TablePlaneOperator:onClickShare(event)
    USER_INFO["invote_code"] = USER_INFO["invote_code"] or " "
    local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
    local share_content = ""
    for k,v in pairs(config_arr) do
        if v ~= "" then
            share_content = share_content .. v .. ","
        end
    end
    share_content = string.sub(share_content, 1, string.len(share_content) - 1)  
    local paras = {}
    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
    paras["imagePath"] = "url"
    paras["name"] = "三公，房号：" .. USER_INFO["invote_code"]
    paras["showType"] = 2;
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"],9999999)
    end
end

function TablePlaneOperator:setSeatGold(playerType,value)
--    local panel =  self.panel_seat:getChildByName("panel_"..playerType)
--     if panel then
--         local text_gold = panel:getChildByName("text_gold")
--         if text_gold then
--             text_gold:setString(value or 0)
--         end
--     end

end

function TablePlaneOperator:showIsButtonXZ(flag)
    -- self.dow_xiazu:setVisible(flag)
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
    	RANDOM_BANKER = {}

        -- self.stage_txt:setString("等待开始")
        -- self.stage_img:setVisible(false)
        self:resetCardNumCount()

        -- local hall_plane = SANGONG_GAME_SCENE:getParent():getChildByName("hall_plane")
        -- local btn_switch_bet_mode = hall_plane:getChildByName("btn_switch_bet_mode")
        -- local bottom_img = btn_switch_bet_mode:getChildByName("bottom_img")

        --       btn_switch_bet_mode:setPosition(cc.p(96,110))
        --       btn_switch_bet_mode:setScale(1)
        --       bottom_img:setColor(cc.c3b(125,125,125))
              -- bottom_img:setContentSize(cc.size(110,102))

    end
    self:stopTimer()
end


function TablePlaneOperator:resetCardNumCount()

    -- local left_txt = self.sangong_cardcount_plane:getChildByName("left_txt")
    -- local middle_txt = self.sangong_cardcount_plane:getChildByName("middle_txt")
    -- local right_txt = self.sangong_cardcount_plane:getChildByName("right_txt")
    -- local result_txt = self.sangong_cardcount_plane:getChildByName("result_txt")

    --       left_txt:setString("")
    --       middle_txt:setString("")
    --       right_txt:setString("")
    --       result_txt:setString("")

end


function TablePlaneOperator:showTaiFeiTips(value)
    --添加扣除台费显示
    local taiFeiTxt
    if  value < 0 then
        taiFeiTxt = "扣除台费"..math.abs(value)
    end

-- sangong/font/arial.ttf

    local lbVersion = cc.Label:createWithTTF(taiFeiTxt, TpackageName .."/font/fzcs.ttf",50)
          SANGONG_GAME_SCENE:addChild(lbVersion,9999)
          lbVersion:setColor(cc.c3b(255, 40, 40))
          lbVersion:setPosition(cc.p(SANGONG_GAME_SCENE:getContentSize().width/2,100))
          lbVersion:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() lbVersion:removeFromParent() end)))
end

function TablePlaneOperator:showAutoPlayTip(flag)
    --添加扣除台费显示

    local hall_plane = SANGONG_GAME_SCENE:getParent():getChildByName("hall_plane")
    local btn_auto_play = hall_plane:getChildByName("btn_auto_play")

    if  flag == true then
        dump("提示自己进入托管状态")
        -- local tipTxt =  "您正处于托管状态..."
        -- local autoPlayTip = cc.Label:createWithTTF(tipTxt,""res/fonts/fzcy.ttf"",45):addTo(SANGONG_GAME_SCENE,1001)
        -- autoPlayTip:setColor(cc.c3b(0, 0, 0))
        -- autoPlayTip:setPosition(cc.p(SANGONG_GAME_SCENE:getContentSize().width/2,470))
        -- autoPlayTip:setName("autoPlayTip")
        self.auto_cancel_plane:setVisible(true)    
        btn_auto_play:setBright(false)
    else
        dump("隐藏托管状态")
        -- local autoPlayTip = SANGONG_GAME_SCENE:getChildByName("autoPlayTip")
        -- if  autoPlayTip then
        --     autoPlayTip:removeFromParent()
        -- end
        self.auto_cancel_plane:setVisible(false)   
        btn_auto_play:setBright(true)
    end


end

function TablePlaneOperator:showNumCount(value,index,flag)
    
    -- self.sangong_cardcount_plane:setVisible(true)

    -- if  value == nil then
    --     return
    -- end

    -- local value = require(TpackageName .. ".cardLogic"):GetCardLogicValue(value) 

    -- local left_txt = self.sangong_cardcount_plane:getChildByName("left_txt")
    -- local middle_txt = self.sangong_cardcount_plane:getChildByName("middle_txt")
    -- local right_txt = self.sangong_cardcount_plane:getChildByName("right_txt")
    -- local result_txt = self.sangong_cardcount_plane:getChildByName("result_txt")
    
    -- if flag == false then
        
    --     if  index == 1 then
    --         left_txt:setString("")
    --     elseif  index == 2 then
    --         middle_txt:setString("")
    --     elseif  index == 3 then
    --         right_txt:setString("")
    --     end

    --     result_txt:setString("") 

    -- else
        
    --     if  index == 1 then
    --         left_txt:setString(value)
    --     elseif  index == 2 then
    --         middle_txt:setString(value)
    --     elseif  index == 3 then
    --         right_txt:setString(value)
    --     end

    --     local  left_num = tonumber(left_txt:getString())
    --     local  middle_num = tonumber(middle_txt:getString())
    --     local  right_num = tonumber(right_txt:getString())

    --     if  left_num and  middle_num and right_num then
    --         result_txt:setString(left_num + middle_num + value)
    --     else
    --         result_txt:setString("")
    --     end

    -- end
end


function TablePlaneOperator:showCardNumCountEffect(arg)

    -- self.sangong_cardcount_plane:setVisible(true)

    -- local left_num = arg.left_num

    -- local middle_num = arg.middle_num

    -- local right_num = arg.right_num
    
    -- local left_txt = self.sangong_cardcount_plane:getChildByName("left_txt")
    -- local middle_txt = self.sangong_cardcount_plane:getChildByName("middle_txt")
    -- local right_txt = self.sangong_cardcount_plane:getChildByName("right_txt")
    -- local result_txt = self.sangong_cardcount_plane:getChildByName("result_txt")
   
    -- local function starEffect()
    -- end
    
    -- left_txt:setString(left_num)

    -- SCENENOW["scene"]:performWithDelay(function() 
    --     middle_txt:setString(middle_num)

    --     SCENENOW["scene"]:performWithDelay(function()
    --         right_txt:setString(right_num)

    --         SCENENOW["scene"]:performWithDelay(function() 
    --             result_txt:setString(left_num + middle_num + right_num)
    --             starEffect()
    --         end,0.2)

    --     end,0.2)

    -- end,0.2)

    -- SCENENOW["scene"]:performWithDelay(function() 
    --     self.sangong_cardcount_plane:setVisible(false)
    -- end,2)

end

function TablePlaneOperator:hideCardNumCountEffect()
    -- self.sangong_cardcount_plane:setVisible(false)
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
        [1]   =  {0x01,0x36,0x17,0x18,0x22}, --无牛
        [2]   =  {0x0D,0x0C,0x0B,0x02,0x09},  --牛一
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
        [CARDKIND_WUHUA] =  {0x2C,0x3C,0x0B,0x2A,0x0D},-- 五花牛
        [CARDKIND_TONGHUANIU] =  {0x3E,0x34,0x37,0x39,0x3D},-- 同花牛
        [CARDKIND_HULUNIU] =  {0x09,0x19,0x29,0x04,0x34},-- 葫芦牛
        [CARDKIND_SIZHA] =  {0x14,0x24,0x34,0x04,0x18},-- 四炸牛
        [CARDKIND_WUXIAONIU] =  {0x11,0x21,0x32,0x12,0x23},-- 五小牛
    }

    -- table.sort(SANGONG_CARDTYPE_TABLE)

    dump(SANGONG_CARDTYPE_TABLE,"SANGONG_CARDTYPE_TABLE")

    local Card = require(TpackageName .. ".PokerCard")

    local y = 14.5

    for i= #SANGONG_CARDTYPE_TABLE,1,-1 do

        local v = SANGONG_CARDTYPE_TABLE[i]
        local cardType_item_clone = cardType_item:clone()
        local bottom = cardType_item_clone:getChildByName("bottom")
        local cardType_times = cardType_item_clone:getChildByName("cardType_times")

        if  i%2 == 0 then
            bottom:setVisible(false)
        end

        local cardDatas = cardtype_examplane_path_table[i]

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


--画金币
function TablePlaneOperator:showCoinFlyAnimation_1(bankerUid,tbWin,_type)
     
    --获取庄位置
    dump(bankerUid, "-----庄家UID-----")
    math.randomseed(os.time())
   
    local bankerPlayerType = SANGONG_PLAYERTYPE_TABLE[bankerUid]
    
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

                local coin_sp = display.newSprite(coin_img_path):setPosition(oriPos):setScale(0.5)

                sceneNow:addChild(coin_sp, 100)
                targetPos = cc.pAdd(targetPos,cc.p(math.random(-30,30),math.random(-8,8) ) )
                -- local random = i

                -- if  random > 20 then
                --     random = 20
                -- end

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
    for uid,value in pairs(tbWin) do
       
        local  playerType = SANGONG_PLAYERTYPE_TABLE[uid]
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

            local coin_count = 20
            --判断当前位置是否为庄
            if playerType == bankerPlayerType then

                if  isZhuanWin == true and playerCount > 2 then
                    GamePlaneOperator:updateCoin(playerType,zhuang_win)

                    SCENENOW["scene"]:performWithDelay(function() 
                        GamePlaneOperator:updateCoin(playerType,zhuang_lose)
                    end, ZhuangWinDelay) 
                else
                    GamePlaneOperator:updateCoin(playerType,tbWin[uid])
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
                             
                            -- local randomX = math.random(coin_count)/2
                            -- local randomY = math.random(coin_count)/2
                              
                            local oriPosition = cc.p(x, y)
                            local targetPos = cc.p(zhuang_x, zhuang_y)

                            coinfly(oriPosition,targetPos,i)

                        end

                    -- end

                    SoundUtils:playEffect("coinfly_long",false)

                   	GamePlaneOperator:updateCoin(playerType,tbWin[uid])

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

                                    -- local randomX = math.random(coin_count)/2
                                    -- local randomY = math.random(coin_count)/2

                                    local oriPosition = cc.p(zhuang_x,zhuang_y)

    	                            --筹码飞动 
    	                            local targetPos = cc.p(x, y)
    	                            coinfly(oriPosition,targetPos,i)

    	                        end
    	                    -- end

    	                    SoundUtils:playEffect("coinfly_long",false)
    	                    
    	                    GamePlaneOperator:updateCoin(playerType,tbWin[uid])

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
       
                        SoundUtils:playEffect("coinfly_long",false)
                        GamePlaneOperator:updateCoin(playerType,tbWin[uid])

                    end

                end
            end

        end
        
    end
end

--画金币
function TablePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,_type)
    math.randomseed(os.time())
    dump(tbWin, "-----输赢分数-----")

    local coinfly 
    local sceneNow = SCENENOW["scene"]
    coinfly = function(oriPos,targetPos,i)
        local delaytime = i*0.035 + math.random(-2,2)/100
        sceneNow:performWithDelay(function()
            oriPos = cc.pAdd(oriPos,cc.p(math.random(-30,30),math.random(-30,30) ) )
            local coin_sp = display.newSprite(coin_img_path):setPosition(oriPos):setScale(0.8)
            sceneNow:addChild(coin_sp, 100)
            targetPos = cc.pAdd(targetPos,cc.p(math.random(-0,0),math.random(-0,0) ) )
            local middleY = (targetPos.y + oriPos.y)/2
            local q1 = cc.p((targetPos.x - oriPos.x)*0.56 + oriPos.x, (targetPos.y - oriPos.y)*0.44 + oriPos.y)
            local q2 = cc.p((targetPos.x - oriPos.x)*0.67 + oriPos.x, (targetPos.y - oriPos.y)*0.8 + oriPos.y)
            local mb = cc.BezierTo:create(0.4,{q1, q2,targetPos})
            local fo = cc.FadeOut:create(0.4)
            local seq = cc.Sequence:create(mb,fo,cc.RemoveSelf:create()) --cc.DelayTime:create(0.4),
            coin_sp:runAction(seq)
        end,delaytime)
    end
    local size = sceneNow:getContentSize()
    local oriPosition = cc.p(size.width/2,size.height/2)
    --显示更新内容（文字和筹码）
    for uid,value in pairs(tbWin) do
        local playerType = SANGONG_PLAYERTYPE_TABLE[uid]
        local targetPos = PLAYER_HEADS_POSITION_TABLE[uid]
        if  playerType then
            local coin_count = 20
            for i=1, coin_count do
                --筹码飞动 
                coinfly(oriPosition,targetPos,i)
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
    self.stage_img:stopAllActions()
    self.stage_img:setVisible(false)
end

--设置倒计时时间显示
function TablePlaneOperator:startTimer(time,stage)
    if not (self.stage_img and SanGongPanel and SCENENOW["name"] == TpackageName ..".view.SanGongRoomScene") then
        return
    end
    dump(time,stage.."------------------------")
    self.stage_img:stopAllActions()
    if  time <= 0 then
        self.stage_img:setVisible(false)
        return
    end

    local  timer_value = time
    local  refreshTime = 1
    local func = function ( timer_value )
        if timer_value ~= nil then
            self.stage_txt:setString("倒计时:"..string.format( "%02d", timer_value ))
            self.stage_img:setVisible(true)
        end
    end
    func(timer_value)
    local showTimerAc = cc.CallFunc:create(function()
            timer_value = timer_value - refreshTime
            dump(timer_value,stage.."------------------------")
            if  timer_value > 0 then
                func(timer_value)
            else
                self:stopTimer()
            end
        end)

    local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime),showTimerAc)
    self.stage_img:runAction(cc.RepeatForever:create(seqAc))
end

function TablePlaneOperator:showStageTxt(info)
    self:stopTimer()
end

--显示游戏开始
function TablePlaneOperator:showStartAnimation()
      
	SoundUtils:playEffect("gameStart")

	-- local sangong_start = SANGONG_GAME_SCENE:getChildByName("sangong_start") --游戏开始
    -- local sangong_start_txt = sangong_start:getChildByName("sangong_start_txt") --游戏开始
    --       sangong_start:loadTexture(TpackageName .. "/images/game_start_01.png")

    -- if sangong_start_txt then
    --     sangong_start_txt:removeFromParent()
    -- end

    -- sangong_start_txt = display.newSprite(TpackageName .. "/images/game_start_02.png")
    -- sangong_start:addChild(sangong_start_txt)
    -- sangong_start_txt:setName("sangong_start_txt")
    -- sangong_start_txt:setPosition(sangong_start:getContentSize().width/2,sangong_start:getContentSize().height/2)
    -- sangong_start:setVisible(true)
    -- sangong_start:setOpacity(255)
    -- sangong_start:setScale(0.5)

    -- local start_fade = cc.FadeOut:create(0.3)
    -- local sangongwei = cc.ScaleTo:create(0.2,1)

	-- local delay= cc.DelayTime:create(0.6)
    -- sangong_start:runAction(cc.Sequence:create(sangongwei,delay,start_fade))


end


--显示游戏结束动画
function TablePlaneOperator:showGameEndAnimation(isWin)
      
    -- local sangong_start = SANGONG_GAME_SCENE:getChildByName("sangong_start") --游戏开始
    
    -- local sangong_start_txt = sangong_start:getChildByName("sangong_start_txt") --游戏开始
    
    -- if  sangong_start_txt then
    --     sangong_start_txt:removeFromParent()
    -- end
 
    -- if  isWin == true then
    --     sangong_start:loadTexture(TpackageName .. "/images/game_end.png")
    --     sangong_start_txt = display.newSprite(TpackageName .. "/images/win_txt.png")
    --     SoundUtils:playEffect("赢")
    -- else
    --     sangong_start:loadTexture(TpackageName .. "/images/game_end.png")
    --     sangong_start_txt = display.newSprite(TpackageName .. "/images/lose_txt.png")
    --     SoundUtils:playEffect("输")
    -- end
    
    -- sangong_start_txt:setPosition(sangong_start:getContentSize().width/2,sangong_start:getContentSize().height/2)
    
    -- sangong_start:addChild(sangong_start_txt)
    -- sangong_start_txt:setName("sangong_start_txt")
     
    -- sangong_start:setVisible(true)
    -- sangong_start:setOpacity(255)

    -- local start_fade = cc.FadeOut:create(0.8)
    -- local delay= cc.DelayTime:create(1.1)
    -- sangong_start:runAction(cc.Sequence:create(delay,start_fade))


end



function TablePlaneOperator:showRandomBankerChoose(random_banker)
    
    if  next(random_banker) == nil then
        return
    end

    --self.banker_choose_frame:setOpacity(255)
    --self.banker_choose_frame:setVisible(true)
    --self.banker_choose_frame:stopAllActions()

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
    
    --self.banker_choose_frame:setScale(1.2)
    random_uid_ex = random_uid
    --self.banker_choose_frame:setPosition(cc.p(PLAYER_HEADS_POSITION_TABLE[random_uid].x*GLOBAL_SCALE,PLAYER_HEADS_POSITION_TABLE[random_uid].y*GLOBAL_SCALE))  

    end)
   
   local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay)) 
   --self.banker_choose_frame:runAction(cc.RepeatForever:create(seqAc))
end

function TablePlaneOperator:showBankerChoose(uid)
	--self.banker_choose_frame:stopAllActions()
	--self.banker_choose_frame:setPosition(cc.p(PLAYER_HEADS_POSITION_TABLE[uid].x*GLOBAL_SCALE,PLAYER_HEADS_POSITION_TABLE[uid].y*GLOBAL_SCALE))
	--self.banker_choose_frame:runAction(cc.Sequence:create(
        -- cc.ScaleTo:create(0.3,1.3),
        -- cc.Spawn:create(cc.ScaleTo:create(0.5,1),cc.FadeOut:create(1.2)),
        -- cc.CallFunc:create(function()
        --     local playerType = SANGONG_PLAYERTYPE_TABLE[uid]
        --         GamePlaneOperator:setEffectFrame(playerType,2)
        --     end)
        -- ))
end


function TablePlaneOperator:showRandomBankerChoose(random_banker)
    
    if  next(random_banker) == nil then
        return
    end
    
    --self.banker_choose_frame:stopAllActions()
    math.randomseed(os.time())

    local  random_banker = random_banker

    local  random_banker_size = #random_banker

    local  callfunc = cc.CallFunc:create(function()
        
        if  random_uid_ex ~= -1 then
            local playerType_ex = SANGONG_PLAYERTYPE_TABLE[random_uid_ex]
            dump(playerType_ex,"showRandomBankerChoose_playerType_ex")
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

        local  playerType = SANGONG_PLAYERTYPE_TABLE[random_uid]
        dump(playerType,"showRandomBankerChoose_playerType")
        GamePlaneOperator:setEffectFrame(playerType,1,true)
        
    end)
    
    local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay)) 
    --self.banker_choose_frame:runAction(cc.RepeatForever:create(seqAc))

end


function TablePlaneOperator:showBankerChoose(uid)
   
    --self.banker_choose_frame:stopAllActions()

    local  playerType = SANGONG_PLAYERTYPE_TABLE[uid]

    local  callfunc = cc.CallFunc:create(function()
        GamePlaneOperator:clearEffectFrame()
        GamePlaneOperator:setEffectFrame(playerType,1,true)
    end)
    
    local  callfunc2 = cc.CallFunc:create(function()
        GamePlaneOperator:setEffectFrame(playerType,2)
    end)

    local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay+0.2),callfunc2) 

    --self.banker_choose_frame:runAction(seqAc)
    
    random_uid_ex = -1
end

return TablePlaneOperator