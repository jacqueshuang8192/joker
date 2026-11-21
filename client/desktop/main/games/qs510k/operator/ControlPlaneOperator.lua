--
-- Author: Your Name
-- Date: 2017-09-05 19:57:03
local   ControlPlaneOperator = class("ControlPlaneOperator")

local   ddzServer = require("qs510k.ddzServer")
local   unpack = table.unpack or unpack
local   CardAnalysis, CARDTYPE = unpack(require("qs510k.CardAnalysis"))
local   Card  = require("qs510k.Card")
local   CardPlaneOperator = require("qs510k.operator.CardPlaneOperator")


function ControlPlaneOperator:init()

    local CardPlaneOperator = require("qs510k.operator.CardPlaneOperator")

    layout_ui = cardScene:getChildByName("layout_ui")

    self.btn_showGroupResult = layout_ui:getChildByName("btn_showGroupResult"):setVisible(false)
    self.btn_returnToHall = layout_ui:getChildByName("btn_returnToHall"):setVisible(false)
    
    local checkGroupResult = function(sender,event)

        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            if sender == self.btn_showGroupResult then

                local GameResult = SCENENOW["scene"]:getChildByName("gameresultScene")
                if  GameResult then
                    GameResult:setVisible(true)
                end

            elseif sender == self.btn_returnToHall then

                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                
                if SCENENOW["scene"].initData then
                    SCENENOW["scene"]:initData("release")
                end

            end

        end

    end

    self.btn_showGroupResult:addTouchEventListener(checkGroupResult)
    self.btn_returnToHall:addTouchEventListener(checkGroupResult)

    ------------------------
    self.btn_sit = layout_ui:getChildByName("btn_sit"):setVisible(false)
    self.btn_stand = layout_ui:getChildByName("btn_stand"):setVisible(false)
    self.btn_startGame = layout_ui:getChildByName("btn_startGame"):setVisible(false)
    self.btn_ready = layout_ui:getChildByName("btn_ready"):setVisible(false)

    local startGameFunc = function(sender,event)
        
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            require("hall.GameCommon"):playEffectSound("qs510k/audio/Audio_Button_Click.mp3")
            
            if sender == self.btn_ready then
                ddzServer:CLI_READY_GAME(1)
            elseif sender == self.btn_startGame then 
            end

        end
    end
    
    self.btn_sit:addTouchEventListener(startGameFunc)
    self.btn_stand:addTouchEventListener(startGameFunc)
    self.btn_startGame:addTouchEventListener(startGameFunc)
    self.btn_ready:addTouchEventListener(startGameFunc)

    -------------------------------
    self.operate_btns = layout_ui:getChildByName("operate_btns"):setVisible(false)

    self.team_btns = layout_ui:getChildByName("team_btns"):setVisible(false)

    self.btn_duda = self.team_btns:getChildByName("btn_duda")
	local txt = self.btn_duda:getChildByName("txt")
    --txt:setColor(cc.c3b(140,140,140))
    txt:setString("选叫边牌")
    self.btn_duda:setVisible(false)
	
    self.btn_bududa = self.team_btns:getChildByName("btn_bududa")
	self.btn_bududa:setVisible(false)

    self.btn_pass = self.operate_btns:getChildByName("btn_pass")
    self.btn_tip = self.operate_btns:getChildByName("btn_tip")
    self.btn_discard = self.operate_btns:getChildByName("btn_discard")
    --self.btn_discard:setBright(false)  

   --  local function teamBtnFunc(sender,event)
        
   --      if event == TOUCH_EVENT_BEGAN then
   --          sender:setScale(0.9)
   --      end

   --      if event == TOUCH_EVENT_CANCELED then
   --          sender:setScale(1)
   --      end

   --      if event == TOUCH_EVENT_ENDED then
   --          sender:setScale(1)
			
			-- local cards = {}
			-- local c  = Card.new()
			-- local outCards = {}
   --          for i,cardNode in ipairs(Mycard_layout:getChildren()) do

   --              if  cardNode.selected == 1 then
   --                  local cardvalue =  Card:restoreCard(cardNode._kind, cardNode._value)
   --                  table.insert(cards,cardvalue)
   --              end
   --          end
			-- dump(cards, 'cards')
			-- print('----call ass -----')
   --          if #cards ~= 1 then
			-- 	require("qs510k.operator.ControlPlaneOperator"):showErrorTips("kind_error")
			-- 	return
   --          end
			-- dump(PartnerCards,'PartnerCards')
			-- print(cards[1])
			-- if CardAnalysis:IsCallAssCard(PartnerCards, cards[1]) == false  then
			-- 	require("qs510k.operator.ControlPlaneOperator"):showErrorTips("kind_error")
			-- 	return
			-- end
			-- print('---true--')
			-- --叫边
			-- ddzServer:CLI_CALL_ASS(cards[1])
			-- --隐藏按钮
			-- self:showControlButtons(2,false)
   --          --ddzServer:CLI_CHOOSETEAM(sender == self.btn_duda and 0 or 1)
   --          --self:showControlButtons(4,false)
   --      end
   --  end

   --  self.btn_duda:addTouchEventListener(teamBtnFunc)
   --  self.btn_bududa:addTouchEventListener(teamBtnFunc)

    self.btn_pass:addTouchEventListener(function(sender,event)
        
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)
			
			ddzServer:CLI_PASS()
            --选的牌收回
            CardPlaneOperator:resetCards()
            --消息发送隐藏按钮
            self:showControlButtons(4,false)
        end
    end)
    
    self.btn_tip:addTouchEventListener(function(sender,event)

        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)
            require("hall.GameCommon"):playEffectSound("qs510k/audio/Audio_Button_Click.mp3")
			
			local tipCards = CardAnalysis:GetTipCard()
			if #tipCards == 0 then
				-- ddzServer:CLI_PASS()
				-- --选的牌收回
				-- --CardPlaneOperator:resetCards()
				-- --消息发送隐藏按钮
				-- self:showControlButtons(4,false)
			
				-- --self:showErrorTips("no_match")
			else
				CardPlaneOperator:popCard(tipCards)
			end
			--[=[
            if _getSuit == 0 then
                _hasselect = {}
            end

            local tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],_hasselect)

            dump(tt, "getSuitCard11111")
            dump(main_card, "getSuitCard11111")

            if tt and _hasselect[main_card] ~= 1 then

                _getSuit = 1
                CardPlaneOperator:popCard(tt)
                _hasselect[main_card] = 1
                --self:chuIfLight()

            else
                --重置循环提示
                if _getSuit == 1 then
                    _hasselect = {}
                    tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],_hasselect) 
                    if tt then
                        CardPlaneOperator:popCard(tt)
                        _hasselect[main_card] = 1
                        --self:chuIfLight()
                        return
                    end
                end

                if not tbPlayCardInfo["card_type"] then
                    local card   = CardAnalysis:getLitleCard(_notice)
                    if card then
                        _notice[card[1][1]] =  1  
                        if card[1][1] ==  USER_INFO["cards"][1][1] then
                            _notice = {}
                        end
                        CardPlaneOperator:popCard(card)
                        --self:chuIfLight()
                    end
                    
                else

                    self:showErrorTips("no_match")
                --     ddzServer:CLI_PASS()
                --     --选的牌收回
                --     CardPlaneOperator:resetCards()
                --     --消息发送隐藏按钮
                --     self:showControlButtons(4,false)
                end
            end
			--]=]
        end
    end)

    self.btn_discard:addTouchEventListener(function(sender,event)

        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end      

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            require("hall.GameCommon"):playEffectSound("qs510k/audio/Audio_Button_Click.mp3")
            ---------------- check cards type ----------------
            if  CardPlaneOperator:checkPlayCard(false) == false then   --false表示不拦截，true表示拦截
                --KIND_ERROR = true
            end
            --------------------------------------------- ---- 
            if CardPlaneOperator.moreCount and CardPlaneOperator.moreCount > 1 then  --癞子变牌有多个选择
                self:showPanelMagic()
                return
            end
            
            --dump(CardPlaneOperator.magicCard)  
            local count = 1
            self:outDisCards(count)
        end
    end)

end

function ControlPlaneOperator:outDisCards(count)
    local ChangeCards = {}  --转换后的牌
    local cards = {}
    local c  = Card.new()
    local outCards = {}

    for i,cardNode in ipairs(Mycard_layout:getChildren()) do
        if  cardNode.selected == 1 then
            print(" 000000000000000 ================== ：",cardNode._kind)
            print(" 111111111111111 ================== ：",cardNode._value)

            local cardvalue =  Card:restoreCard(cardNode._kind, cardNode._value)
            if cardNode._value == 18 then
                table.insert(cards,{["card"]=cardvalue})
                cardvalue =  Card:restoreCard(0, CardPlaneOperator.magicCard[count])
                table.insert(ChangeCards,{["card"]=cardvalue})
                count = count + 1
            else
                table.insert(ChangeCards,{["card"]=cardvalue})
                table.insert(cards,{["card"]=cardvalue})
            end

            c:init(cardvalue)
            table.insert(outCards,{c._value, c._kind})
        end
    end

    if #cards == 0 then
        return
    end
    dump(outCards," aaaaaaaaaaaaaa  ====================")
    dump(ChangeCards," bbbbbbbbbbbbbb  ====================")
    dump(cards," cccccccccccccc  ====================")
    print('-----------cout card----', tbPlayCardInfo["owner"], MY_SEAT_ID, tbPlayCardInfo["last_cards"])
    if tbPlayCardInfo["last_cards"] and tbPlayCardInfo["owner"] ~= MY_SEAT_ID then
        dump(tbPlayCardInfo["last_cards"])
        local outMagicCards = CardAnalysis:AnalyseMagicData(outCards)
        if CardAnalysis:CompareCard(outMagicCards, tbPlayCardInfo["last_cards"]) then
            --出牌
            ddzServer:CLI_OUT_CARD(#cards,ChangeCards,cards)
            --隐藏按钮
            self:showControlButtons(4,false)
        else
            print('-----out error----')
        end
    else
        --出牌
        ddzServer:CLI_OUT_CARD(#cards,ChangeCards,cards)
        --隐藏按钮
        self:showControlButtons(4,false)
    end
end
                                                
function ControlPlaneOperator:showPanelMagic()
    dump(CardPlaneOperator:tobeChuCards()," aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    dump(CardPlaneOperator.magicCard," bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
    local cards = CardPlaneOperator:tobeChuCards()
    local count = 1
    local tCount = 1
    local magicArr = {}
    local cardTemp = {}
    local tempCard = {}
    local magictemp = {{},{1,3,5,7,9,11,13,15},{1,4,7,10,13,16,19,22},{1,5,9,13,17,21,25,29}}
    local PanelMagic = cardScene:getChildByName("Panel_magic")
    local Button_gb = PanelMagic:getChildByName("Button_gb")
    PanelMagic:setVisible(true)
    local checkButton_gb = function(sender,event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.4)
        end
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(0.5)
        end
        if event == TOUCH_EVENT_ENDED then
            sender:setScale(0.5)
            PanelMagic:setVisible(false)
        end
    end
    Button_gb:addTouchEventListener(checkButton_gb)

    local ButtonCard = {}
    for i=1,8 do
        ButtonCard[i] = PanelMagic:getChildByName("ButtonCard_" .. i)
        local checkButton_card = function(sender,event)
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1)
            end
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1)

                self:outDisCards(magictemp[cards.cbMagicCardCount][i])
                PanelMagic:setVisible(false)
            end
        end
        ButtonCard[i]:addTouchEventListener(checkButton_card)
        ButtonCard[i]:removeAllChildren()
        ButtonCard[i]:setVisible(false)
    end

    --拆分 合并牌组     
    for i=1,#CardPlaneOperator.magicCard / cards.cbMagicCardCount do
        magicArr[i] = {}
    end
    for i,v in ipairs(CardPlaneOperator.magicCard) do
        cardTemp = {}
        cardTemp[1] = v
        cardTemp[2] = 6
        magicArr[tCount][count] = cardTemp

        if i / cards.cbMagicCardCount == tCount and i % cards.cbMagicCardCount == 0 then
            tCount = tCount + 1
        end

        count = count + 1
        if count > cards.cbMagicCardCount then
            count = 1
        end
    end
    
    for i=1,#magicArr do
        tempCard[i] = {}
        for j=1,cards.cbNormalCardCount do
            tempCard[i][j] = clone(cards.cbNormalCard[j])
            table.insert(magicArr[i],tempCard[i][j])
            table.sort(magicArr[i],function(a,b) return a[1] < b[1] end )
        end
    end
    dump(magicArr)

    --牌绘制到面板
    local _pos = 30
    local _pos_x = 30
    local _ii = 0
    for i=1,#magicArr do
        if i < 9 then
            ButtonCard[i]:setVisible(true)
            for j,v in ipairs(magicArr[i]) do
                local img = nil
                img = Card:getCard(v[1],v[2])
                img:addTo(ButtonCard[i])
                img:setScale(0.45)
                _ii = i
                if i > 4 then
                    _ii = i - 4
                end
                img:setPosition(cc.p(_pos_x + (j-1)*_pos,40 - (_ii - 1)*3))
            end
        end
    end
end

function ControlPlaneOperator:showCheckResultButton(flag)

    self.btn_returnToHall:setVisible(flag)
    self.btn_showGroupResult:setVisible(flag)

    if flag == true then
        self:clearGameDatas()
    end
end

function  ControlPlaneOperator:clearGameDatas()
    self:showControlButtons(1,false)
end

--state qiang","noqiang","nojiao","jiao","noyao"
function  ControlPlaneOperator:disPlayChoice(seat,state)

    local   playerType = self:getPlayerType(seat)

    local   spTT = layout_ui:getChildByName("tt"..tostring(playerType))
    if spTT then
        spTT:removeSelf()
    end

    local   v_pos_effect ={ [CARD_PLAYERTYPE_MY]=cc.p(SCREEN_WIDTH/2,250),
                            [CARD_PLAYERTYPE_LEFT]= cc.p(230,400),
                            [CARD_PLAYERTYPE_RIGHT]= cc.p(1040,400),
                            [CARD_PLAYERTYPE_TOP]=cc.p(SCREEN_WIDTH/2,550)
                          }

    local   img_array = {  
                            ["noyao"] = "qs510k/images/ddz_text_buchu.png"
                        }

    local   music_array ={  ["qiang"] ={"qs510k/audio/CallLandlord_QDZ_M.mp3","qs510k/audio/CallLandlord_QDZ_W.mp3"},
                            ["noqiang"] = { "qs510k/audio/CallLandlord_BQDZ_M.mp3","qs510k/audio/CallLandlord_BQDZ_W.mp3"},
                            ["nojiao"] ={ "qs510k/audio/CallLandlord_BJDZ_M.mp3","qs510k/audio/CallLandlord_BJDZ_W.mp3"},
                            ["jiao"] = {"qs510k/audio/CallLandlord_JDZ_M.mp3","qs510k/audio/CallLandlord_JDZ_W.mp3"},
                            ["noyao"] = { "qs510k/audio/Audio_Pass1_M.mp3","qs510k/audio/Audio_Pass1_W.mp3"},
                          }

    --不要的音效随机生成
    if  state == "noyao" then
        math.randomseed(socket.gettime())
        local   rnd = math.random(1,3)
        local   music_tb = {    [1] = { "qs510k/audio/Audio_Pass1_M.mp3","qs510k/audio/Audio_Pass1_M.mp3"},
                                [2] = { "qs510k/audio/Audio_Pass3_M.mp3","qs510k/audio/Audio_Pass3_M.mp3"},
                                [3] = { "qs510k/audio/Audio_Pass2_M.mp3","qs510k/audio/Audio_Pass2_M.mp3"},
                                --[4] = { "qs510k/audio/Audio_Pass2_M.mp3","qs510k/audio/Audio_Pass2_W.mp3"}
                                --[5] = { "qs510k/audio/new/Audio_Pass5_W.mp3","qs510k/audio/new/Audio_Pass5_W.mp3"}

                            }
        music_array["noyao"] = music_tb[rnd]
    end

    --图片
    local   img_path = img_array[state]
    local   sp = display.newSprite(img_path)
            sp:setName("tt"..tostring(playerType))
            sp:setPosition(v_pos_effect[playerType])
            layout_ui:addChild(sp)
    
    --音效
    local   music = music_array[state]
    local   _sex = DDZ_USERINFO_TABLE[SEAT2USERID[seat]].sex

    require("hall.GameCommon"):playEffectSound(music[tonumber(_sex)])
end

---------------------------------------------------------------------
function ControlPlaneOperator:showSitDownButton(flag)
    
    dump(flag,"开关showSitDownButton")

    if  isGoldGame == 0  then
        if  flag == true and GAME_STATE == STATUS_STOP then  --游戏停止状态下才能坐下
            self.btn_sit:setVisible(true)  
            self.btn_sit:setPositionX(self.btn_sit:getParent():getContentSize().width/2)
        else
            self.btn_sit:setVisible(false)  
        end
    end

end


--打牌的3个按钮（不出，提示， 出牌）
function  ControlPlaneOperator:showFourButton(a,b,c)

    _notice = {}
    _hasselect = {}
    _getSuit   = 0
    tbTipsCards["card_type"] = nil
    tbTipsCards["last_cards"] = nil

    local bshow = true
    self.operate_btns:setVisible(bshow)
	
	if a == 1 then
		self.btn_pass:setVisible(true)
	else
		self.btn_pass:setVisible(false)
	end
	self.btn_tip:setVisible(true)
	if c == 1 then
		self.btn_discard:setVisible(true)
	else
		self.btn_discard:setVisible(false)
	end
end

--  游戏操作按钮
function ControlPlaneOperator:showControlButtons(stage, flag, ...)
      
    dump(stage," ======== 【 当前游戏阶段 】")
    dump(flag,"  ======== 【 显示标记 】 ")

    if  flag == false then
        self.btn_ready:setVisible(false)
        self.btn_stand:setVisible(false)

        self.team_btns:setVisible(false)
        self.operate_btns:setVisible(false)   --游戏操作按钮
        return
    end
    
    if  stage == 1 then   --准备阶段

        self.btn_ready:setVisible(true)
        -- self.btn_stand:setVisible(true)

        if  isGoldGame == 1 then
            self.btn_stand:setVisible(false)
            --self.btn_ready:setPositionX(self.btn_ready:getParent():getContentSize().width / 2)
        end

        self.team_btns:setVisible(false)
        self.operate_btns:setVisible(false)

    elseif  stage == 2 then   --选搭伙阶段

        self.btn_ready:setVisible(false)
        self.btn_stand:setVisible(false)

        self.team_btns:setVisible(false)
        self.operate_btns:setVisible(false) 

        local per_id = ...

        dump(per_id,"showControlButtons_2_per_id")

    elseif  stage == 4 then  --游戏操作

        self.btn_ready:setVisible(false)
        self.btn_stand:setVisible(false)
        self.team_btns:setVisible(false)
        self.operate_btns:setVisible(true)

        self:showFourButton( ... )
    end

end

--------------------------------------------------------------

--计算出牌是否点亮
function ControlPlaneOperator:chuIfLight(cards)

    if true then
        --self.btn_discard:setBright(true) 
        self.btn_discard:setTouchEnabled(true)     
        --local txt = self.btn_discard:getChildByName("txt")
        --txt:setColor(cc.c3b(255,255,255))
        return
    end

    --点亮出牌
    local selectedCard = {}
    
    for i,cardNode in ipairs(Mycard_layout:getChildren()) do
        if cardNode.selected == 1  then
            table.insert(selectedCard,cardNode._value)
            -- return  
        end
    end
    
    if next(selectedCard) then

        if CardPlaneOperator:checkPlayCard(false) == false then   --false表示不拦截，true表示拦截
        else
            self.btn_discard:setBright(true) 
            self.btn_discard:setTouchEnabled(true)     
            --local txt = self.btn_discard:getChildByName("txt")
            --txt:setColor(cc.c3b(255,255,255))
            return  
        end 
    end

    -- self.btn_discard:setTouchEnabled(false)
    self.btn_discard:setBright(false)
    --local txt = self.btn_discard:getChildByName("txt")
    --txt:setColor(cc.c3b(140,140,140))
    
end

function ControlPlaneOperator:AutoPlayCard()
       
    local _hasselect ={}
    local tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],_hasselect)
    if tt and _hasselect[main_card] ~= 1 then

        CardPlaneOperator:popCard(tt)
        _hasselect[main_card] = 1
        --self:chuIfLight()

    else
        if not tbPlayCardInfo["card_type"] then
            local card   = CardAnalysis:getLitleCard(_notice)
            if card then
                _notice[card[1][1]] =  1  
                if card[1][1] ==  USER_INFO["cards"][1][1] then
                    _notice = {}
                end
                CardPlaneOperator:popCard(card)
                --self:chuIfLight()
            end
            
        else

            self:showErrorTips("no_match")
            ddzServer:CLI_PASS()
            --选的牌收回
            CardPlaneOperator:resetCards()
            --消息发送隐藏按钮
            self:showControlButtons(4,false)
        end
    end

    ---------------- check cards type ----------------
    if  CardPlaneOperator:checkPlayCard(true) == false then   --false表示不拦截，true表示拦截
        --KIND_ERROR = true
    end
    --------------------------------------------- ---- 

    local cards = {}

    for i,cardNode in ipairs(Mycard_layout:getChildren()) do

        if  cardNode.selected == 1 then
            local cardvalue = cardNode._value + cardNode._kind*16
            cardvalue = Card:Encode(cardvalue)
            table.insert(cards,{["card"]=cardvalue})
        end
    end

    if #cards == 0 then
        return
    end

    --出牌
    --ddzServer:CLI_OUT_CARD(#cards,cards)
    --隐藏按钮
    self:showControlButtons(4,false)

end

--显示不出的按钮
function ControlPlaneOperator:showNot2Play()
    -- layout_ui:setTouchEnabled(true)
    self:showErrorTips("no_match")
end

--出牌错误内容
function ControlPlaneOperator:showErrorTips(errCode)

    if layout_ui:getChildByName("card_error_msg") then
        layout_ui:removeChildByName("card_error_msg")
    end

    dump(errCode, "出牌错误errCode")
    display.addSpriteFrames("qs510k/images/msg.plist", "qs510k/images/msg.png")
    local str = ""
    if errCode == "no_match" then  --牌值小于
        str = "#qs510k/images/txt_no_match.png"
    elseif errCode == "kind_error" then   --牌型不对
        str = "#qs510k/images/txt_illegal.png"
    else
        return
    end

    local sp = display.newSprite(str)
   
    -- sp:addTo(layout_ui)
    -- sp:setPosition(cc.p(SCREEN_WIDTH/2,100))

    local fullRect = cc.rect(0,0,sp:getContentSize().width+200,sp:getContentSize().height+30)
    local imageView = ccui.ImageView:create()
    imageView:setScale9Enabled(true)
    imageView:loadTexture("qs510k/images/gold_box.png")
    imageView:setContentSize(cc.size(fullRect.width,fullRect.height))
    imageView:setPosition(SCREEN_WIDTH/2,80)
    imageView:setName("card_error_msg")

    layout_ui:addChild(imageView,101)
    sp:addTo(imageView,10)
    sp:setPosition(fullRect.width/2, fullRect.height/2)

    imageView:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.Hide:create()))
    if errCode == "kind_error" then
        CardPlaneOperator:resetCards()
    end
end

--检查是否最后一张牌，是--自动出牌(暂时屏蔽这个功能)
function ControlPlaneOperator:checkLastCard()
end

function ControlPlaneOperator:getPlayerType(seatId)   --seatId为服务器座位号
    print('getPlayerType  ', seatId, XinYu510KRoomInfo, XinYu510KRoomInfo and XinYu510KRoomInfo.maxSeatCount)    
    if seatId == nil or seatId < 0 then return nil end
	print('f1')
	if not XinYu510KRoomInfo then
		print('ddzSettings:getPlayerType error', debug.traceback())
		return nil
	end
	print('f2')
	local playerType = CARD_PLAYERTYPE_MY
	if XinYu510KRoomInfo.maxSeatCount == 2 then
		if seatId == MY_SEAT_ID then
			playerType = CARD_PLAYERTYPE_MY
		else
			playerType = CARD_PLAYERTYPE_TOP
		end
		
		-- local other_index = seatId - MY_SEAT_ID

		-- if other_index < 0 then
		   -- other_index = other_index + XinYu510KRoomInfo.maxSeatCount
		-- end
		 
		-- playerType =  other_index+1  -- otherIndex2playerType[other_index]
		-- if playerType > 4 then
			-- playerType = 4
		-- end
	else
		local other_index = seatId - MY_SEAT_ID

		if other_index < 0 then
		   other_index = other_index + XinYu510KRoomInfo.maxSeatCount
		end
		 
		playerType =  other_index+1  -- otherIndex2playerType[other_index]
		if playerType > 4 then
			playerType = 4
		end
	end

    print('f3',playerType)
    return playerType
end

return ControlPlaneOperator
