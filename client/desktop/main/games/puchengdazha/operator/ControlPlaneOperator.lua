--
-- Author: Your Name
-- Date: 2017-09-05 19:57:03
local   ControlPlaneOperator = class("ControlPlaneOperator")

local   ddzServer = require("puchengdazha.ddzServer")
local   unpack = table.unpack or unpack
local   CardAnalysis, CARDTYPE = unpack(require("puchengdazha.CardAnalysis"))
local   Card  = require("puchengdazha.Card")
local   CardPlaneOperator = require("puchengdazha.operator.CardPlaneOperator")


function ControlPlaneOperator:init()

    local CardPlaneOperator = require("puchengdazha.operator.CardPlaneOperator")

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

            require("hall.GameCommon"):playEffectSound("puchengdazha/audio/Audio_Button_Click.mp3")
            
            if sender == self.btn_ready then
                ddzServer:CLI_READY_GAME(1)
            elseif sender == self.btn_sit then 
                ddzServer:sitDown()
            elseif sender == self.btn_stand then 
                ddzServer:standUp()
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
    self.btn_bududa = self.team_btns:getChildByName("btn_bududa")

    self.btn_pass = self.operate_btns:getChildByName("btn_pass")
    self.btn_tip = self.operate_btns:getChildByName("btn_tip")
    self.btn_discard = self.operate_btns:getChildByName("btn_discard")
    self.btn_discard:setBright(false)  

    local function teamBtnFunc(sender,event)
        
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            ddzServer:CLI_CHOOSETEAM(sender == self.btn_duda and 0 or 1)
            self:showControlButtons(4,false)
        end
    end

    self.btn_duda:addTouchEventListener(teamBtnFunc)
    self.btn_bududa:addTouchEventListener(teamBtnFunc)

    self.btn_pass:addTouchEventListener(function(sender,event)
        
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            if self.btn_pass.state == 1 then
                --PASS
                ddzServer:CLI_PASS()
                --选的牌收回
                CardPlaneOperator:resetCards()
                --消息发送隐藏按钮
                self:showControlButtons(4,false)

            elseif self.btn_pass.state == 2  then
                 ddzServer:CLI_COMMON_MINGPAI()
                 self:showFourButton(0,1,1,0)
            end
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
            require("hall.GameCommon"):playEffectSound("puchengdazha/audio/Audio_Button_Click.mp3")
      
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
                self:chuIfLight()

            else
                --重置循环提示
                if _getSuit == 1 then
                    _hasselect = {}
                    tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],_hasselect) 
                    if tt then
                        CardPlaneOperator:popCard(tt)
                        _hasselect[main_card] = 1
                        self:chuIfLight()
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
                        self:chuIfLight()
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
        end
    end)

    self.btn_discard:addTouchEventListener(function(sender,event)

        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end      

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            require("hall.GameCommon"):playEffectSound("puchengdazha/audio/Audio_Button_Click.mp3")
            ---------------- check cards type ----------------
            if  CardPlaneOperator:checkPlayCard(false) == false then   --false表示不拦截，true表示拦截
                KIND_ERROR = true
            end
            --------------------------------------------- ---- 

            local cards = {}

            for i,cardNode in ipairs(Mycard_layout:getChildren()) do

                if  cardNode.selected == 1 then
                    local cardvalue =  Card:restoreCard(cardNode._kind, cardNode._value)
                    table.insert(cards,{["card"]=cardvalue})
                end
            end

            if #cards == 0 then
                return
            end

            --出牌
            ddzServer:CLI_PLAYER_CARD(#cards,cards)
            --隐藏按钮
            self:showControlButtons(4,false)
        end
    end)

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

    local   playerType = ddzSettings:getPlayerType(seat)

    local   spTT = layout_ui:getChildByName("tt"..tostring(playerType))
    if spTT then
        spTT:removeSelf()
    end

    local   v_pos_effect ={ [CARD_PLAYERTYPE_MY]=cc.p(SCREEN_WIDTH/2,300),
                            [CARD_PLAYERTYPE_LEFT]= cc.p(300,400),
                            [CARD_PLAYERTYPE_RIGHT]= cc.p(1050,400),
                            [CARD_PLAYERTYPE_TOP]=cc.p(SCREEN_WIDTH/2,550)
                          }

    local   img_array = {   ["qiang"] ="puchengdazha/images/ddz_text_qiangdizhu.png",
                            ["noqiang"] = "puchengdazha/images/ddz_text_buqiang.png",
                            ["nojiao"] ="puchengdazha/images/ddz_text_bujiao.png",
                            ["jiao"] = "puchengdazha/images/ddz_text_jiaodizhu.png",
                            ["noyao"] = "puchengdazha/images/ddz_text_buchu.png"
                        }

    local   music_array ={  ["qiang"] ={"puchengdazha/audio/CallLandlord_QDZ_M.mp3","puchengdazha/audio/CallLandlord_QDZ_W.mp3"},
                            ["noqiang"] = { "puchengdazha/audio/CallLandlord_BQDZ_M.mp3","puchengdazha/audio/CallLandlord_BQDZ_W.mp3"},
                            ["nojiao"] ={ "puchengdazha/audio/CallLandlord_BJDZ_M.mp3","puchengdazha/audio/CallLandlord_BJDZ_W.mp3"},
                            ["jiao"] = {"puchengdazha/audio/CallLandlord_JDZ_M.mp3","puchengdazha/audio/CallLandlord_JDZ_W.mp3"},
                            ["noyao"] = { "puchengdazha/audio/Audio_Pass1_M.mp3","puchengdazha/audio/Audio_Pass1_W.mp3"},
                          }

    --不要的音效随机生成
    if  state == "noyao" then
        math.randomseed(socket.gettime())
        local   rnd = math.random(1,4)
        local   music_tb = {    [1] = { "puchengdazha/audio/Audio_Pass1_M.mp3","puchengdazha/audio/Audio_Pass1_W.mp3"},
                                [2] = { "puchengdazha/audio/Audio_Pass3_M.mp3","puchengdazha/audio/Audio_Pass3_W.mp3"},
                                [3] = { "puchengdazha/audio/Audio_Pass2_M.mp3","puchengdazha/audio/Audio_Pass2_W.mp3"},
                                [4] = { "puchengdazha/audio/Audio_Pass2_M.mp3","puchengdazha/audio/Audio_Pass2_W.mp3"}
                                --[5] = { "puchengdazha/audio/new/Audio_Pass5_W.mp3","puchengdazha/audio/new/Audio_Pass5_W.mp3"}

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


--打牌的四个按钮
function  ControlPlaneOperator:showFourButton(a,b,c,d)

    _notice = {}
    _hasselect = {}
    _getSuit   = 0
    tbTipsCards["card_type"] = nil
    tbTipsCards["last_cards"] = nil

    local bshow = true
    self.operate_btns:setVisible(bshow)

    if a==1 then

        self.btn_pass:setEnabled(bshow)
        -- self.btn_pass:setBright(1)
        local txt = self.btn_pass:getChildByName("txt")
        txt:setColor(cc.c3b(255,255,255))
        txt:setString("不出")
        self.btn_pass.state = 1

    elseif a == 0 then
        self.btn_pass:setEnabled(false)
        -- self.btn_pass:setBrightStyle(0)
        local txt = self.btn_pass:getChildByName("txt")
        txt:setColor(cc.c3b(140,140,140))
        txt:setString("不出")
        self.btn_pass.state = 0

    elseif a == 2 then --变成明牌按钮
        self.btn_pass:setEnabled(true)
        -- self.btn_pass:setBright(true)
        local txt = self.btn_pass:getChildByName("txt")
        txt:setColor(cc.c3b(255,255,255))
        txt:setString("明牌")
        self.btn_pass.state = 2

    end

    if c==1 then
        self.btn_tip:setTouchEnabled(bshow)
    else
        self.btn_tip:setTouchEnabled(false)
    end

    if  d==1 then
        self.btn_discard:setTouchEnabled(bshow)
    else
        self.btn_discard:setTouchEnabled(false)
    end
    
    if  AUTO_OUT_CARD == true then
        self:AutoPlayCard()
    end

end

--准备，（抢庄）（加倍）（摊牌，提示，搓牌）  游戏操作按钮
function ControlPlaneOperator:showControlButtons(stage, flag, ...)
      
    dump(stage,"游戏阶段")
    dump(flag,"显示标记")

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

        self.team_btns:setVisible(true)
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
        self.btn_discard:setBright(true) 
        self.btn_discard:setTouchEnabled(true)     
        local txt = self.btn_discard:getChildByName("txt")
        txt:setColor(cc.c3b(255,255,255))
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
            local txt = self.btn_discard:getChildByName("txt")
            txt:setColor(cc.c3b(255,255,255))
            return  
        end 
    end

    -- self.btn_discard:setTouchEnabled(false)
    self.btn_discard:setBright(false)
    local txt = self.btn_discard:getChildByName("txt")
    txt:setColor(cc.c3b(140,140,140))
    
end

function ControlPlaneOperator:AutoPlayCard()
       
    local _hasselect ={}
    local tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],_hasselect)
    if tt and _hasselect[main_card] ~= 1 then

        CardPlaneOperator:popCard(tt)
        _hasselect[main_card] = 1
        self:chuIfLight()

    else
        if not tbPlayCardInfo["card_type"] then
            local card   = CardAnalysis:getLitleCard(_notice)
            if card then
                _notice[card[1][1]] =  1  
                if card[1][1] ==  USER_INFO["cards"][1][1] then
                    _notice = {}
                end
                CardPlaneOperator:popCard(card)
                self:chuIfLight()
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
        KIND_ERROR = true
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
    ddzServer:CLI_PLAYER_CARD(#cards,cards)
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
    display.addSpriteFrames("puchengdazha/images/msg.plist", "puchengdazha/images/msg.png")
    local str = ""
    if errCode == "no_match" then  --牌值小于
        str = "#puchengdazha/images/txt_no_match.png"
    elseif errCode == "kind_error" then   --牌型不对
        str = "#puchengdazha/images/txt_illegal.png"
    else
        return
    end

    local sp = display.newSprite(str)
   
    -- sp:addTo(layout_ui)
    -- sp:setPosition(cc.p(SCREEN_WIDTH/2,100))

    local fullRect = cc.rect(0,0,sp:getContentSize().width+200,sp:getContentSize().height+30)
    local imageView = ccui.ImageView:create()
    imageView:setScale9Enabled(true)
    imageView:loadTexture("puchengdazha/images/gold_box.png")
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

return ControlPlaneOperator
