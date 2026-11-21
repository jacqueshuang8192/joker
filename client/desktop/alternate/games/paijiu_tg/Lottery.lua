local Lottery = class("Lottery")

local Card = require(TpackageName .. ".PokerCard")
local coin_img_path = TpackageName .. "/images/effect_gold.png"

local Lottery_Seat_Table = {}

local CardTypeTransLate = 
    {
        [-1] = "完成", --完成           
        [0] = "盖牌",   --盖牌
        [1] = "无牛", --无牛
        [2] = "牛一",  --牛一
        [3] = "牛二",
        [4] = "牛三",
        [5] = "牛四",
        [6] = "牛五",
        [7] = "牛六",
        [8] = "牛七",
        [9] = "牛八",
        [10] = "牛九",--牛九
        [11] = "牛牛",--牛牛
--[[        [CARDKIND_SHUNZI] = "顺子牛",-- 顺子牛
        [CARDKIND_WUHUA] = "五花牛",-- 五花牛
        [CARDKIND_TONGHUANIU] = "同花牛",-- 同花牛
        [CARDKIND_HULUNIU] = "葫芦牛",-- 葫芦牛
        [CARDKIND_SIZHA] = "四炸牛",-- 四炸牛
        [CARDKIND_WUXIAONIU] = "五小牛",-- ]]
    }

function Lottery:init(flag)

    local bet_situation_panel = PAIJIU_GAME_SCENE:getParent():getChildByName("bet_situation_panel")

          if  flag == false then
              bet_situation_panel:setVisible(false)
              return
          else
              bet_situation_panel:setVisible(true)
          end


          bet_situation_panel.isPullIn = true

    local content_sv = bet_situation_panel:getChildByName("content_sv")
    self.content_ly = content_sv:getChildByName("content_ly")

    local open_bt = bet_situation_panel:getChildByName("open_bt")

    local mask = bet_situation_panel:getChildByName("mask")
          mask:setTouchEnabled(false)

    local hall_panel = PAIJIU_GAME_SCENE:getParent():getChildByName("hall_panel")
    local btn_switch_bet_mode = hall_panel:getChildByName("btn_switch_bet_mode")

    local bottom_img = btn_switch_bet_mode:getChildByName("bottom_img")
          bottom_img:setColor(cc.c3b(125,125,125))

    local effect_light = btn_switch_bet_mode:getChildByName("effect_light")
          effect_light:setVisible(false)

    local openBetSituation = function(sender,event)

            --触摸结束
            if  event == TOUCH_EVENT_ENDED then

                if  bet_situation_panel.isPullIn == true then
                    require(TpackageName..".Lottery"):showBetSituation()
                    bet_situation_panel:runAction( cc.MoveTo:create(0.25,cc.p(0,0)) )
                    mask:setTouchEnabled(true)
                else
                    bet_situation_panel:runAction( cc.MoveTo:create(0.25,cc.p(1479,0)) )
                    mask:setTouchEnabled(false)
                end

                GamePlaneOperator:updateWaiWeiButton()
                bet_situation_panel.isPullIn = not bet_situation_panel.isPullIn

            end

        end

    btn_switch_bet_mode:addTouchEventListener(openBetSituation)
    open_bt:addTouchEventListener(openBetSituation)
    mask:addTouchEventListener(openBetSituation)

    --查看录纸
    local win_trend_bt = bet_situation_panel:getChildByName("win_trend_bt")

    local menuBtEvent = function(sender,event)

            if  event == TOUCH_EVENT_ENDED then
                dump("菜单触摸事件")
                PaiJiuSendHandle:CLI_REQUEST_LUZHI()
            end
        end

          win_trend_bt:addTouchEventListener(menuBtEvent)

    self.waiwei_choose_panel = bet_situation_panel:getChildByName("waiwei_choose_panel")

    for i = 1,4 do
        local bet_chip_bt =  self.waiwei_choose_panel:getChildByName("bet_chip_" .. i)

        if  i == BETCOUNT then
            bet_chip_bt:setColor(cc.c3b(255,255,255))
        else
            bet_chip_bt:setColor(cc.c3b(120,120,120))
        end

        local bet_chip_txt = self.waiwei_choose_panel:getChildByName("bet_chip_txt_" .. i)
        local touchFunc = function(sender,event)

            --触摸结束（检查当前组局状态）
            if  event == TOUCH_EVENT_ENDED then

                for i = 1,4 do 
                    local bet_chip_bt =  self.waiwei_choose_panel:getChildByName("bet_chip_" .. i)
                    bet_chip_bt:setColor(cc.c3b(120,120,120))
                end

                bet_chip_bt:setColor(cc.c3b(255,255,255))

                dump(i,"touchFunc")

                BETCOUNT = i
            end

        end

        bet_chip_txt:addTouchEventListener(touchFunc)
        bet_chip_bt:addTouchEventListener(touchFunc)

    end


end

function Lottery:showBetSituation()

 --获取总结算界面
    local s = SCENENOW["scene"]._scene:getChildByName("bet_situation_panel")

    dump(BETCOUNT,"showWaiWeiSituation")

    for i = 1,4 do

        local bet_chip_txt = self.waiwei_choose_panel:getChildByName("bet_chip_txt_" .. i)
        local bet_chip_bt =  self.waiwei_choose_panel:getChildByName("bet_chip_" .. i)

        if  i == BETCOUNT then
            bet_chip_bt:setColor(cc.c3b(255,255,255))
        else
            bet_chip_bt:setColor(cc.c3b(120,120,120))
        end
              
        if  i <= #WAIWEI_BET_CHIPS then
            bet_chip_txt:setString(WAIWEI_BET_CHIPS[i])
        else
            bet_chip_bt:setTouchEnabled(false)
            bet_chip_txt:setTouchEnabled(false)
            bet_chip_txt:setString("???")
        end

    end

    --结果显示区域
    local content_sv = s:getChildByName("content_sv")
    self.content_ly:removeAllChildren()

    --定义结果分项
    local result_Item = s:getChildByName("group_ending_box") 

    local result_Item_position_index = 1

    local playerNum = table.nums(GAME_PARTICIPANTS)

    local lineCount = math.ceil(playerNum/2)

    local contentHeight = content_sv:getInnerContainerSize().height
    local contentWidth = content_sv:getInnerContainerSize().width

    if contentHeight < 160 * lineCount then  contentHeight = 160 * lineCount end

    content_sv:setInnerContainerSize(cc.size(contentWidth,contentHeight))
    self.content_ly:setContentSize(cc.size(contentWidth,contentHeight))
    self.content_ly:setPositionY(contentHeight)

    local positionIndex = 0

    --生成界面
    if  next(GAME_PARTICIPANTS) == nil then
        return
    end

    for _,bet_uid in pairs(GAME_PARTICIPANTS) do  
        ------------------------------------------数据-----------------------------------
        local bet_chip = TOTAL_BET_CHIP[bet_uid] or 0 
        local my_bet_chip = MY_BET_CHIP[bet_uid] or 0
        local bet_seat_id = PAIJIU_SEAT_TABLE[bet_uid]

        local sex= 1    
        local nickName = PAIJIU_USERINFO_TABLE[bet_uid].nick
        local icon_url = PAIJIU_USERINFO_TABLE[bet_uid].icon_url
        local namenick = require("hall.GameCommon"):formatNick(nickName, 7)
        -------------------------------------------界面-------------------------------------------
        positionIndex = positionIndex + 1
        local result_Item = result_Item:clone()
        self.content_ly:addChild(result_Item)

        local x = (math.ceil(positionIndex % 2.01) - 1) * 750 + 20
        local y = contentHeight - (math.ceil(positionIndex/2.01) - 1) * 155 

        result_Item:setPosition(cc.p(x,y))
        result_Item:setTag(bet_seat_id)

        --用户头像
        local head_im = result_Item:getChildByName("head_im")
        require("hall.GameCommon"):getUserHead(icon_url, bet_uid, sex, head_im, head_im:getContentSize().width, false, nickName)

        head_im:setTouchEnabled(false)

        --下注
        result_Item:addTouchEventListener(function(sender,event)
        
            if event == TOUCH_EVENT_ENDED then

                if  USER_INFO["uid"] == BANKER_UID then
                    require("hall.GameTips"):showTips("提示", "", 3, "庄家无法下注") 
                    return
                end

                if  SINGLE_BET_CHIP[USER_INFO["uid"]] and SINGLE_BET_CHIP[USER_INFO["uid"]] >=  WAIWEI_BET_LIMIT then
                    require("hall.GameTips"):showTips("提示", "", 3, "下注超过上限") 
                    return
                end

                if  GAME_STATE == GAME_STATUS_TIMES then
                            
                    if  bet_uid == BANKER_UID then
                        require("hall.GameTips"):showTips("提示", "", 3, "无法对庄家下注") 
                        return
                    end

                    PaiJiuSendHandle:CLI_REQUEST_BET(bet_seat_id,BETCOUNT*BASE_CHIP)

                end

                SoundUtils:playEffect("click")

            end

        end)

        --用户昵称
        local nickName_txt = result_Item:getChildByName("nickName_txt")
        
        local total_bet_chip = result_Item:getChildByName("total_bet_chip")
              total_bet_chip:setString(bet_chip)
        local bet_chip_txt = result_Item:getChildByName("bet_chip")
              bet_chip_txt:setString(my_bet_chip)

        nickName_txt:setString(namenick)

        -- for _,node in pairs(result_Item:getChildren()) do
        --     dump(node:getName(),"result_Item_child")
        -- end

        local zhuang_flag = result_Item:getChildByName("zhuang_flag")

        if  bet_uid == BANKER_UID then
            zhuang_flag:setVisible(true)
        else
            zhuang_flag:setVisible(false)
        end

    end

end


--广播下注
function Lottery:updateBetSituation(bet_uid,costCoins,bet_chip,my_bet_chip)
    
    if  not tolua.isnull(self.content_ly) then

        local bet_seat_id = PAIJIU_SEAT_TABLE[bet_uid]
        local result_Item = self.content_ly:getChildByTag(bet_seat_id)

        if result_Item then

            local total_bet_chip = result_Item:getChildByName("total_bet_chip")
                  total_bet_chip:setString(bet_chip)
            local bet_chip_txt = result_Item:getChildByName("bet_chip")
                  bet_chip_txt:setString(my_bet_chip)

        end

    end

end

-- function Lottery:showBetSituation(bonus_record,bonusPoolCoins)
     
--     Lottery_Seat_Table = {}
--     self:removeView()
--    	local lotteryScene = cc.CSLoader:createNode(TpackageName.."/csb/lottery.csb"):addTo(SCENENOW["scene"])
--           lotteryScene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
--    		  lotteryScene:setName("lotteryScene")
    
--     local lottery_bottom = lotteryScene:getChildByName("lottery_bottom")
--     lottery_bottom:addTouchEventListener(
--         function(sender,event)

--             --触摸结束（检查当前组局状态）
--             if  event == TOUCH_EVENT_ENDED then
--                 self:removeView()
--             end
--         end)
    
--     --设置奖池
--     self:setBonusPool(bonusPoolCoins)

--     self.lottery_player_list = lotteryScene:getChildByName("lottery_player_list")
--     self.lottery_player_list:removeAllChildren()

--    	self.lottery_player = lotteryScene:getChildByName("lottery_player")

--     local function darkAllChips()
--         for i = 1,4 do 
--             local lottery_coin = lotteryScene:getChildByName("lottery_coin_"..i)
--             lottery_coin:setColor(cc.c3b(120,120,120))
--         end
--     end

--     darkAllChips()

--     for i = 1,4 do 
--        local lottery_coin = lotteryScene:getChildByName("lottery_coin_"..i)
--        local lottery_chip_txt = lotteryScene:getChildByName("lottery_chip_txt_"..i)
--              lottery_chip_txt:setString(i*BASE_CHIP)

--        if   i == 1 then
--             lottery_coin:setColor(cc.c3b(255,255,255))
--        end

--         lottery_coin:addTouchEventListener(
--         function(sender,event)

--             --触摸结束（检查当前组局状态）
--             if  event == TOUCH_EVENT_ENDED then
--                 darkAllChips()
--                 lottery_coin:setColor(cc.c3b(255,255,255))
--                 BetCount = i
--             end
--         end)
--     end
  
--     local lottery_player_list_size = self.lottery_player_list:getContentSize()
--     local oneLineCount = 5
--     local lineNum = TOTAL_PLAYERNUM/oneLineCount

--     for i,data in pairs(bonus_record) do
        
--         local uid = data.uid
--         local seat_id = i - 1

--         if uid > 0 then
              
--             Lottery_Seat_Table[uid] = seat_id
--             local icon_url = PAIJIU_USERINFO_TABLE[uid].icon_url or ""
--             local nick = PAIJIU_USERINFO_TABLE[uid].nick or ""     
--                   nick = require("hall.GameCommon"):formatNick(nick, 4)

--             local SINGLE_BET_CHIP = 0
--             local total_bet_chip = 0 
--             local single_bonus_record = data.single_bonus_record

--             for _,v in pairs(single_bonus_record) do

--                 local bet_uid = v.bet_uid
--                 local bet_count = v.bet_count 

--                 if  bet_uid == USER_INFO["uid"] then
--                     SINGLE_BET_CHIP = bet_count
--                 end

--                 total_bet_chip = total_bet_chip + bet_count
--             end

--       		local lottery_player = self:loadSinglePlayerItemInfoForSituation(icon_url,nick,total_bet_chip,SINGLE_BET_CHIP,seat_id)
--       		lottery_player:setTag(seat_id)
--       		self.lottery_player_list:addChild(lottery_player) 

--             self:drawSmallCards(uid)

--       		local x = ((i % (oneLineCount + 0.01) - 1)*2 +1) *  lottery_player_list_size.width/ ( 2 * oneLineCount)
--       		local y = ( (lineNum * 2 + 1) - 2 * math.ceil(i/(oneLineCount + 0.01)) ) *  (lottery_player_list_size.height)/(2*lineNum)
--             -- local y = 
--             lottery_player:setPosition(cc.p(x,y))
             
--             dump(cc.p(x,y),"lottery_player坐标")


--         end

--     end


--     --请求查看录纸
--     local lottery_check_out_trend = lotteryScene:getChildByName("lottery_check_out_trend")
--     lottery_check_out_trend:addTouchEventListener(
--         function(sender,event)
--             --触摸开始
--             if event == TOUCH_EVENT_BEGAN then
--                 sender:setScale(0.9)
--             end

--             --触摸取消
--             if event == TOUCH_EVENT_CANCELED then
--                 sender:setScale(1.0)
--             end

--             --触摸结束（检查当前组局状态）
--             if event == TOUCH_EVENT_ENDED then
--                 sender:setScale(1.0)

--                 -- local lotteryScene = SCENENOW["scene"]:getChildByName("lotteryScene")
--                 -- if   lotteryScene then
--                     PaiJiuSendHandle:CLI_REQUEST_LUZHI()
--                 -- end

--             end
--         end)

-- end 

function Lottery:drawSmallCards(uid)
  
    if not tolua.isnull(self.lottery_player_list) then
         
        local seat_id = Lottery_Seat_Table[uid]
        local lottery_player = self.lottery_player_list:getChildByTag(seat_id)
        local card_panel = lottery_player:getChildByName("card_panel")

        local target_point_y = 0 
        local OtherCardScale = 0.2
        local OtherCardInterval = 150 * OtherCardScale
        local panelWidth = card_panel:getContentSize().width

        if PAIJIU_OUTCARDS[uid] then
            for i,card in pairs(card_panel:getChildren()) do
                card:setCard(PAIJIU_OUTCARDS[uid][i])
            end
        else
            card_panel:removeAllChildren()
            for i = 1,5 do 
                local target_point_x = panelWidth/2 - (3 - i) * OtherCardInterval
                local card = Card.new()
                card:setScale(OtherCardScale)
                card:addTo(card_panel)
                card:setPosition(cc.p(target_point_x,target_point_y))
            end       
        end
    end

end

function Lottery:loadSinglePlayerItemInfoForSituation(icon_url,nickName,total_bet_chip,SINGLE_BET_CHIP,seat_id)

    local lottery_player_clone = self.lottery_player:clone()
    local head = lottery_player_clone:getChildByName("head")
    local name_txt = lottery_player_clone:getChildByName("name_txt")
    local total_bet_txt = lottery_player_clone:getChildByName("total_bet_txt")
    local my_bet_txt = lottery_player_clone:getChildByName("my_bet_txt")

    require("hall.GameCommon"):getUserHead(icon_url, 0, 1, head, 68, false)
    head:setTouchEnabled(true)

    --下注
    head:addTouchEventListener(function(sender,event)
   
        if event == TOUCH_EVENT_ENDED then
            if  GAME_STATE ~= GAME_STATUS_OUTCARD then
                PaiJiuSendHandle:CLI_REQUEST_BET(seat_id,BetCount)
            else
                require("hall.GameTips"):showTips("提示", "", 3, "此阶段停止下注")
            end
        end

    end)

    name_txt:setString(nickName)
    my_bet_txt:setString(SINGLE_BET_CHIP)
    total_bet_txt:setString(total_bet_chip)

    return lottery_player_clone
end

function Lottery:clearBetSituation()
     
    Lottery_Seat_Table = {}

    if  not tolua.isnull(self.lottery_player_list) then
        for _, lottery_player in pairs(self.lottery_player_list:getChildren()) do

            local total_bet_txt = lottery_player:getChildByName("total_bet_txt")
            local my_bet_txt = lottery_player:getChildByName("my_bet_txt")
                  my_bet_txt:setString(0)
                  total_bet_txt:setString(0)

        end
    end

end


-- --广播下注
-- function Lottery:updateBetSituation(bet_seat_id,uid,costCoins)
    
--     if not tolua.isnull(self.lottery_player_list) then

--         local lottery_player = self.lottery_player_list:getChildByTag(bet_seat_id)

--         if  lottery_player then
--             local total_bet_txt = lottery_player:getChildByName("total_bet_txt")
--             local my_bet_txt = lottery_player:getChildByName("my_bet_txt")
         
--             if  uid == USER_INFO["uid"] then
--                 my_bet_txt:setString(tonumber(my_bet_txt:getString()) + costCoins)
--             end

--             total_bet_txt:setString(tonumber(total_bet_txt:getString())+ costCoins)
--         end
        
--         local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
--         local betCount = costCoins/BASE_CHIP
--         if playerType then
--             local oriPos =  PLAYER_HEADS_POSITION_TABLE[playerType] or {x=0,y=0}
--             local targetPos = self.lottery_player_list:convertToWorldSpace(lottery_player:getPosition())
--             self:showBetCoinFly(targetPos,oriPos,betCount)
--         end

--     end

-- end

function Lottery:showBetCoinFly(targetPos,oriPos,betCount)
    local coin_sp = display.newSprite(coin_img_path)
    coin_sp:setPosition(oriPos)
    coin_sp:setScale(0.5)
    SCENENOW["scene"]:addChild(coin_sp, 100)

    local random = betCount * 4

    local delaytime = 0.1 + 0.2 * math.random(random)

    local mb = cc.MoveTo:create(delaytime, targetPos)
    local fo = cc.FadeOut:create(0.5)
    local remove_action = cc.CallFunc:create(function()           
        coin_sp:removeSelf()
    end)

    local seq = cc.Sequence:create(mb, fo, remove_action)
    coin_sp:runAction(seq)
end


function Lottery:setBonusPool(value)

    local lotteryScene = SCENENOW["scene"]:getChildByName("lotteryScene")
    if   lotteryScene then
        local lottery_jiangchi_txt = lotteryScene:getChildByName("lottery_jiangchi_txt")
        lottery_jiangchi_txt:setString(value)
    end
end


function Lottery:showPaper(record_paper)
    
    dump(record_paper,"record_paper")
    self:showBetSituationView(false)

    local WinTrend = cc.CSLoader:createNode(TpackageName.."/csb/WinTrend.csb"):addTo(SCENENOW["scene"])
          WinTrend:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
          WinTrend:setName("WinTrend")

    -- local winTrendScale =  SCREEN_WIDTH/DESIGN_SCREEN_WIDTH
          -- WinTrend:setPosition(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
    local content_ly = WinTrend:getChildByName("content_ly")
          content_ly:setScale(1.4)
    local mask = content_ly:getChildByName("mask")
    mask:addTouchEventListener(
        function(sender,event)

            --触摸结束（检查当前组局状态）
            if  event == TOUCH_EVENT_ENDED then
                self:showBetSituationView(true)
            end
        end) 

           
    local winTrend_bottom = content_ly:getChildByName("winTrend_bottom")
    winTrend_bottom:addTouchEventListener(
        function(sender,event)

            --触摸结束（检查当前组局状态）
            if  event == TOUCH_EVENT_ENDED then
                self:showBetSituationView(true)
            end
        end)

    local winTrend_lv = content_ly:getChildByName("winTrend_lv")

    winTrend_lv:removeAllChildren()
    self.player_win_trend_item = content_ly:getChildByName("player_win_trend_item") 
    
    local total_record_round = #record_paper

    for index = total_record_round - 9, total_record_round do
        if  total_record_round > 0 then

            local data = record_paper[index] or {}

            local uid = data.uid or 0
            if  uid > 0 then
                
                local seat_id = PAIJIU_SEAT_TABLE[uid]
                local icon_url = PAIJIU_USERINFO_TABLE[uid].icon_url or ""
                local nickName = PAIJIU_USERINFO_TABLE[uid].nick or ""

                nickName = require("hall.GameCommon"):formatNick(nickName, 4)

                local single_record_paper = data.single_record_paper
                local player_win_trend_item = self:loadSinglePlayerItemInfoForPaper(icon_url,nickName,single_record_paper,seat_id)
                winTrend_lv:pushBackCustomItem(player_win_trend_item)
            end
        end
    end

    --刷新录纸
    local btn_refresh = content_ly:getChildByName("btn_refresh")
    btn_refresh:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束（检查当前组局状态）
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                PaiJiuSendHandle:CLI_REQUEST_LUZHI()
            end
        end)


end

function Lottery:loadSinglePlayerItemInfoForPaper(icon_url,nickName,single_record_paper,index)

    local player_win_trend_item_clone = self.player_win_trend_item:clone()
    local nick_txt = player_win_trend_item_clone:getChildByName("nick_txt")
    local index_txt = player_win_trend_item_clone:getChildByName("index_txt")
    local head = player_win_trend_item_clone:getChildByName("head")
    require("hall.GameCommon"):getUserHead(icon_url, 0, 1, head, 52, false)

    for round,v in pairs(single_record_paper) do
        
        local balance_txt = cc.Label:createWithTTF(v.balance,TpackageName .."/font/fzcs.ttf",20)
        local niuType_txt = cc.Label:createWithTTF(CardTypeTransLate[v.niuType],TpackageName .."/font/fzcs.ttf",20)
        
        if v.balance > 0 then
            balance_txt:setColor(cc.c3b(255,0,0))
        else
            balance_txt:setColor(cc.c3b(0x0E,0xEF,0x0E))
        end

        player_win_trend_item_clone:addChild(balance_txt)
        player_win_trend_item_clone:addChild(niuType_txt)

        local x = (round - 1)* 111 + 130
        balance_txt:setPosition(cc.p(x,60))
        niuType_txt:setPosition(cc.p(x,18))
        niuType_txt:setColor(cc.c3b(0,0,0))
    end
    
    nick_txt:setString(nickName)
    index_txt:setString(index)

    return player_win_trend_item_clone
end

function Lottery:showBetSituationView(flag)
    
    local WinTrend = SCENENOW["scene"]:getChildByName("WinTrend")
    if  WinTrend then
        WinTrend:removeFromParent(not flag)
    end

   local lotteryScene = SCENENOW["scene"]:getChildByName("lotteryScene")
   if   lotteryScene then
        lotteryScene:setVisible(flag)
   end

end


function Lottery:removeView()
    
   local lotteryScene = SCENENOW["scene"]:getChildByName("lotteryScene")
   if  	lotteryScene then
   		lotteryScene:removeFromParent()
   end

   local WinTrend = SCENENOW["scene"]:getChildByName("WinTrend")
   if   WinTrend then
        WinTrend:removeFromParent()
   end

end

return Lottery