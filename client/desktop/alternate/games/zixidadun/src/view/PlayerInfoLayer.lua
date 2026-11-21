--[[
* author:   zwm
* date:     2019-04-11
* describe: 跑得快玩家信息界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local Card = require(TpackageName .. ".src.view.Card") 
CardsAnalysis  = require(TpackageName .. ".src.logic.CardsAnalysis").new()
local zixidadunServer = import(TpackageName .. ".src.protocol.zixidadunServer")

local ViewBaseLayer = require("hall.ViewBaseLayer")
local PlayerInfoLayer = class("PlayerInfoLayer", ViewBaseLayer)
--btn:setEnabled()   --设置按钮禁用状态

local CLICK_CARD_VIOCE = "zixidadun/res/audio/card_click.wav"
local MAX_USER_SIZE = 3 
local POS_CLOCK = { 
                    [1]= cc.p(640*ViewBaseLayer:_getScaleParam2(), 294+120),
                    [2]= cc.p(1000*ViewBaseLayer:_getScaleParam2(),580),
                    [3]= cc.p(280*ViewBaseLayer:_getScaleParam2(),580)
                }

function PlayerInfoLayer:ctor()
    PlayerInfoLayer.super.ctor(self, "zixidadun/res/zixidadunUserInfoLayer.csb")
        GameUtils.setNodeNameBindObj(self._csbNode)
    display.doLayout(self._csbNode)
    self:initUIInfo()
end

function PlayerInfoLayer:initUIInfo()
    self.myUser:setVisible(false)
    self.rightUser:setVisible(false)
    self.leftUser:setVisible(false)
    self.outCardBtnNode:setVisible(false)
    self.beginBtnNode:setVisible(false)
    --self.errorTipsImg:setVisible(false)
    self.outCardBtnNode:setPositionY(self.outCardBtnNode:getPositionY() - 50)
    self.Node_ChiBing:setVisible(false)
    self.text_defen_right:setString("得分:0")
    self.text_defen_left:setString("得分:0")
    self:stopClock()
    self:addTouchEventListenerForCards(self.handCardPanle)
    -- self:addTouchEventListenerForCards(self.outCardBtnNode:getChildByName("outcard_bg"))
   -- self:initQiePaiUI()
    self.CardSize:setVisible(false)
    self.selectCardFold={}
    self.lefthandCard={}
    self.outCardBtnNode:getChildByName("btnTip"):onClick(handler(self, self.onClickBtnTip), true)
    self.outCardBtnNode:getChildByName("btnQuXiao"):onClick(handler(self, self.onClickBtnQuXiao), true)
    self.Node_ChiBing:getChildByName("BtnChiBing"):onClick(handler(self, self.onClickBtnChiBing), true)
    self.Node_ChiBing:getChildByName("BtnNotChiBing"):onClick(handler(self, self.onClickBtnNotChiBing), true)
    self.BtnLiangDun:onClick(handler(self, self.onClickBtnLiangDun), true)
    self.BtnLiangDun:setVisible(false)
    self.handCard_left:setVisible(false)
    self.handCard_right:setVisible(false)
    self.outcard_bg:setVisible(false)
    self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)      --禁用按钮
    self.dunScore_1:setVisible(false)
    self.dunScore_2:setVisible(false)
    self.dunScore_3:setVisible(false)
    self.dunScore_1:setString("")
    self.dunScore_2:setString("")
    self.dunScore_3:setString("")
--[[        self:getChildByName("dunScore_2"):setVisible(false)
        self:getChildByName("dunScore_3"):setVisible(false)--]]
    
    --self.outCardBtnNode:getChildByName("outcard_bg"):setAnchorPoint(cc.p(0,0))
end



function PlayerInfoLayer:setPlayerInfoByViewId(viewId, info)
    g_mainScene.userInfoByViewId[info.uid] = info
    if viewId == 1 then
        g_mainScene.tableLayer:SetnickName(info.name)
        self.myUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.myUser, "zixidadun.src.view.UserInfoNode", info)
        self.myUser:setVisible(true)
        self.myUser:setLeftPlayer(true)
        --新录音位置显示
        local point = cc.p(self.myUser:getAnchorPoint().x * self.myUser:getContentSize().width, self.myUser:getAnchorPoint().y * self.myUser:getContentSize().height)
        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(info.uid, self.myUser:convertToWorldSpace(point))
    elseif viewId == 2 then
        self.rightUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.rightUser, "zixidadun.src.view.UserInfoNode", info)
        self.rightUser:setVisible(true)
        self.rightUser:setLeftPlayer(false)
        --新录音位置显示
        local point = cc.p(self.rightUser:getAnchorPoint().x * self.rightUser:getContentSize().width, self.rightUser:getAnchorPoint().y * self.rightUser:getContentSize().height)

        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(info.uid, self.rightUser:convertToWorldSpace(point))
    elseif viewId == 3 then

        self.leftUser = require("hall.util.CocosUtil"):bindCocosObjToLua(self.leftUser, "zixidadun.src.view.UserInfoNode", info)
        self.leftUser:setVisible(true)
        self.leftUser:setLeftPlayer(true)
        --新录音位置显示
        local point = cc.p(self.leftUser:getAnchorPoint().x * self.leftUser:getContentSize().width, self.leftUser:getAnchorPoint().y * self.leftUser:getContentSize().height)

        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(info.uid, self.leftUser:convertToWorldSpace(point))
    end
end

function  PlayerInfoLayer:addTouchEventListenerForCards(plane)
    
    local selectedCardCount_ex
    local rtSelectCard
    local ptTouchBegin = cc.p(0,0)

    local _card_start_x = 0 
    local _card_start_y = 0 
    local _card_start_h = 0 
    local _card_move_type = 0

    local cardTemp

    -- card.index = i
    -- card.value = v
    
    --折叠展开 要注册不同的点击事件
--[[    if  g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then
        --折叠
    else
        --展开
    end
--]]
    local function onTouchBegan(touch, event)
        print("onTouchBegan1 ------------------------------- afdasdf")
        cardTemp = nil
        cardOutTemp=nil
        local beganPosition = touch:getLocation()
        local children = plane:getChildren()
        local childrenOut=self.outcard_bg:getChildren()
        
        if #self.lefthandCard==0 and #self.selectCardFold~=#g_mainScene.myHandlerCards then
            for i=1,#g_mainScene.myHandlerCards do
                self.lefthandCard[i]={}
                self.lefthandCard[i][1]=g_mainScene.myHandlerCards[i][1]
                self.lefthandCard[i][2]=g_mainScene.myHandlerCards[i][2]
            end
        end
        
        for k,v in pairs(children) do
            local locationInNode = v:convertToNodeSpace(beganPosition)

            local s = v:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height+5)
            if  cc.rectContainsPoint(rect, locationInNode) then
                cardTemp = v
            end
        end


        for k,v in pairs(childrenOut) do
            local locationInNode = v:convertToNodeSpace(beganPosition)

            local s = v:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height+5)
            if  cc.rectContainsPoint(rect, locationInNode) then
                cardOutTemp = v
            end
        end

        if  g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then

            if cardTemp then
                require("hall.GameCommon"):playEffectSound(CLICK_CARD_VIOCE)
                self.outcard_bg:setVisible(true)
                    for _,vv in ipairs(cardTemp.value) do
                        table.insert(self.selectCardFold,vv)
                        for j,k in ipairs(self.lefthandCard) do
                            if k[1]==vv[1] and k[2]==vv[2] then
                            --self.lefthandCard:remove(vv)
                            table.remove(self.lefthandCard,j)
                            break
                        end
                        end
                    end
                    --table.insert(self.selectCardFold,cardTemp.value)
                    self:SetOutCardLayer(self.selectCardFold)   --放入出牌layer
                    cardTemp:removeSelf()
                    local outCards = self:getSelectCards()
                    if CardsAnalysis:compareCard(outCards) then
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(true)
                    else
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
                    end
                end
                if cardOutTemp then
                    require("hall.GameCommon"):playEffectSound(CLICK_CARD_VIOCE)
                   -- cardOutTemp:retain()  --本身是有父节点的
                   -- cardOutTemp:removeFromParent()
                   --self.outcard_bg:setVisible(true)
                   local tab={}

                    table.insert(self.lefthandCard,cardOutTemp.value)
                    for i,v in ipairs(self.selectCardFold) do
                        if cardOutTemp.value[1]==v[1] and cardOutTemp.value[2]==v[2] then
                            table.remove(self.selectCardFold,i)
                            break
                        end
                    end
                    cardOutTemp:removeFromParent()
                    dump(self.lefthandCard,"self.lefthandCard")
                    Card:sortCard(self.lefthandCard)
                    g_mainScene.myHandlerCardsZD = CardsAnalysis:analysisFoldingCards(self.lefthandCard)
                    self:foldingCards()
                    local outCards = self:getSelectCards()
                    if #outCards==0 then
                        self.outcard_bg:setVisible(false)
                    end
                    if CardsAnalysis:compareCard(outCards) then
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(true)
                        else
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
                    end
                    --self.m_Label_SkiDepict:release()
                end
            
            return false
        else
            if cardTemp then
                require("hall.GameCommon"):playEffectSound(CLICK_CARD_VIOCE)
                _card_start_x   = cardTemp:getPositionX()  
                --_card_start_y   = cardTemp:getPositionY()
                _card_start_y = cardTemp.oriPosition.y
                _card_start_h   = cardTemp:getContentSize().height
                ptTouchBegin.x  = beganPosition.x
                ptTouchBegin.y  = beganPosition.y
                _card_move_type = 0 
                cardTemp:toBlack()

                return true
            else
                -- print("onTouchBegan3 ------------------------------- afdasdf")
                -- 退牌
                for k,v in pairs(children) do
                    if v.selected == 1 then
                        v.selected = 0
                        v:toDown()
                    end 

                end
            end
        end

        return false
    end

    local function onTouchCancell(touch, event)
        print("onTouchCancell -------------------------------")
        _card_start_x   = 0 
        _card_start_y   = 0 
        _card_move_type = 0
        rtSelectCard = nil
    end

    local function onTouchMoved(touch, event)
        print("onTouchMoved -------------------------------")
        local endPosition = touch:getLocation()
        local endX = endPosition.x
        local endY = endPosition.y
        if  (math.abs(endX - _card_start_x)) > 4  then-- and (math.abs(endY - _card_start_y)  / math.abs(endX - _card_start_x) ) < 0.5 )
            _card_move_type  = 1
            local startx_t
            local width
            if  endX  > _card_start_x then
                startx_t = _card_start_x
                -- width = endX - _card_start_x 
                width = endX - _card_start_x + 70
            else
                startx_t = endX
                width = _card_start_x -  endX 
            end

            -- local pY = 0
            -- local rtHeight = 124
            -- if endY > 124 then
            --     pY = 50
            --     rtHeight = 203
            -- end
            rtSelectCard  =    cc.rect(startx_t, _card_start_y, width, _card_start_h)
            -- dump(rtSelectCard)
            local selectedCardCount = self:touchAreaCard(rtSelectCard)
            -- if selectedCardCount_ex ~= selectedCardCount then
            --     cc.SimpleAudioEngine:getInstance():playEffect(CLICK_CARD_VIOCE, false)
            -- end
            -- selectedCardCount_ex = selectedCardCount
            return
        end
        if math.abs(endX - ptTouchBegin.x) > g_zxddGameData.cardInterval  then
            _card_move_type = 1 --左右选择
            return
        end
    end

    local function onTouchEnded(touch, event)
        print("onTouchEnded -------------------------------",_card_move_type)
        if _card_move_type == 0 then --点选
            if tolua.isnull(cardTemp)then 
                return 
            end
            cardTemp.selected = 1 - tonumber(cardTemp.selected or "0") 
            if cardTemp.selected == 1 then
                cardTemp:toUp()
                                    local outCards = self:getSelectCards()
                    if CardsAnalysis:compareCard(outCards) then
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(true)
                        else
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
                    end
            else
                cardTemp:toDown()
                local outCards = self:getSelectCards()
                    if CardsAnalysis:compareCard(outCards) then
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(true)
                    else
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
                    end
            end
            cardTemp:toWhite()
        elseif  _card_move_type == 1 then --拉选
            dump(rtSelectCard)
            local tbCards = self:touchSelectCard(rtSelectCard)
            dump(tbCards)

            if tbCards then
                self:setCardOther(tbCards)
                                    local outCards = self:getSelectCards()
                    if CardsAnalysis:compareCard(outCards) then
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(true)
                        else
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
                    end

                -- local tbAICards = CardsAnalysis:getSuitCardsForSelectCards(tbCards)--CardsAnalysis:getSelectCardsForSingleShunzi(tbCards)
                -- dump(tbAICards, "tbAICards -----------")
                -- if #tbAICards == 0 then
                --     --拉选后弹出牌
                --     for i, SelectedCardNode in ipairs(tbCards) do
                --         -- dump(SelectedCardNode)
                --         SelectedCardNode.selected = 1 - tonumber(SelectedCardNode.selected or "0")        
                --     end
                --     self:setCardOther(tbCards)
                -- else
                --     for i, SelectedCardNode in ipairs(tbCards) do
                --         SelectedCardNode:toWhite()  
                --     end
                --     --拉选后弹出牌
                --     for i, SelectedCardNode in ipairs(tbAICards) do
                --         -- dump(SelectedCardNode)
                --         SelectedCardNode.selected = 1 - tonumber(SelectedCardNode.selected or "0")        
                --     end
                --     self:setCardOther(tbAICards)
                -- end
            end
        end
       
        _card_start_x   = 0
        _card_start_y   = 0
        _card_move_type = 0

        rtSelectCard = nil

    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener1:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )
    
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, plane)
end


function PlayerInfoLayer:SetDeFen(uid,score)
        local view=self:getViewIdByUId(uid)
        if view==2 then
            self.text_defen_right:setString("得分:"..score )
        elseif view==3 then
            self.text_defen_left:setString("得分:"..score)
        end
end

function PlayerInfoLayer:Select510K()
    local Count5=0
    local Count10=0
    local CountK=0
    for i,v in ipairs(g_mainScene.myHandlerCards) do
        if v[1]==5 then
            Count5=Count5+1
        elseif v[1]==10 then
            Count10=Count10+1
        elseif v[1]==13 then
            CountK=CountK+1
        end
    end
    local min=0
    if Count5>=3 and Count10>=3 and CountK>=3 then
        min=Count5
        if min>Count10 then
            min=Count10
        end
        if min>CountK then
            min=CountK
        end
    else
        --发送没有510k提示
    end
    if min>=3 then
        self.selectCardFold={}            --新建一个表来储存手中的510k
            local Save5=0
            local Save10=0
            local SaveK=0
            for i,v in ipairs(g_mainScene.myHandlerCards) do
                if v[1]==5 and Save5<min then
                    table.insert(self.selectCardFold,v)
                    Save5=Save5+1
                elseif v[1]==10 and Save10<min then
                    table.insert(self.selectCardFold,v)
                    Save10=Save10+1
                elseif v[1]==13 and SaveK<min then
                    table.insert(self.selectCardFold,v)
                    SaveK=SaveK+1
                end
            end

        if  g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then
            --self.lefthandCard=g_mainScene.myHandlerCards
           for i=1,#g_mainScene.myHandlerCards do
                self.lefthandCard[i]={}
                self.lefthandCard[i][1]=g_mainScene.myHandlerCards[i][1]
                self.lefthandCard[i][2]=g_mainScene.myHandlerCards[i][2]
            end
            for j,k in ipairs(self.selectCardFold) do 
                for i,v in ipairs(self.lefthandCard) do               
                    if v[1]==k[1] and v[2]==k[2] then
                        table.remove(self.lefthandCard,i)
                        break
                    end
                end
            end
            --更新折叠手牌
            Card:sortCard(self.lefthandCard)
            g_mainScene.myHandlerCardsZD = CardsAnalysis:analysisFoldingCards(self.lefthandCard)
            self:foldingCards()
            --510K放入出牌layer中
            self:SetOutCardLayer(self.selectCardFold)
        else
            local children=self.handCardPanle:getChildren()
            for i,v in ipairs(children) do
                if v.selected == 1 then
                    v.selected = 0
                    v:toDown()
                end
            end
            for j,k in ipairs(self.selectCardFold) do
            for i,v in ipairs(children) do
                    if v.value[1]==k[1] and v.value[2]==k[2]  and v.selected == 0 then
                        v.selected=1
                        v:toUp()
                        break
                    end
                end
            end
        end
    end
        if g_zxddGameData.curOutCardUser==USER_INFO["uid"] then
            local outCards = self:getSelectCards()
            if CardsAnalysis:compareCard(outCards) then
                self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(true)
            else
                self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
            end
        end

end

function PlayerInfoLayer:JustShowOutLayer(flag)
    self.outcard_bg:setVisible(flag)
end

function PlayerInfoLayer:returnHanCardData( ... )
    local children=self.outcard_bg:getChildren()
--[[    for i,v in ipairs(children) do
      table.insert(g_mainScene.myHandlerCards,v.value)
    end--]]
--[[    dump(self.selectCardFold,"self.selectCardFold")
   for i,v in ipairs(self.selectCardFold) do
        local tav={}
        tav[1]=v[1]
        tav[2]=v[2]
        table.insert(g_mainScene.myHandlerCards,tav)
        
    end--]]

end

--触摸区域显示牌
function PlayerInfoLayer:touchAreaCard(rect)
    -- _card_start_y
    local selectedCardCount = 0
    for i,cardNode in ipairs(self.handCardPanle:getChildren()) do
        if rect.y == cardNode.oriPosition.y then
            local flag = cc.rectContainsPoint(rect, cardNode.oriPosition)
            if flag then
                cardNode:toBlack()
                selectedCardCount = selectedCardCount + 1
            else
                cardNode:toWhite()
            end
        end
    end

    return selectedCardCount
end

--触摸区选牌
function PlayerInfoLayer:touchSelectCard(rect)
    if rect == nil then
        return
    end
  
    local tbSelectCards = {}

    for i,cardNode in ipairs(self.handCardPanle:getChildren()) do
        if rect.y == cardNode.oriPosition.y then
            local flag = cc.rectContainsPoint(rect, cardNode.oriPosition)
            if flag  then   
                table.insert(tbSelectCards,cardNode)      
            end
        end
    end

    return tbSelectCards
end

function  PlayerInfoLayer:setCardOther(tbSelectCards)
    for i,cardNode in ipairs(tbSelectCards) do
        if not tolua.isnull(cardNode) then
            -- if  g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then
            --     self:SetOutCardLayer(cardNode.value)
            -- else
                local px  = cardNode:getPositionX()
                local py  = cardNode:getPositionY()

                if cardNode.selected == 0 then
                    cardNode.selected = 1
                    cardNode:toUp()
                else
                    cardNode.selected = 0
                    cardNode:toDown()
                end
           
                cardNode:toWhite()
          --  end
        end

    end
end

function  PlayerInfoLayer:SetOutCardLayer(tbSelectCards)
    --遍历数组把牌加入layer  位置居中
    self.outcard_bg:removeAllChildren()
    local Jiange=50*(158/220)
    local  beginPos = self:getBeginPosInOutLayer(#tbSelectCards)
    for i,v in ipairs(tbSelectCards) do
        local Ocard=Card:getCard(v,1)
        Ocard:setAnchorPoint(cc.p(0,0))
        Ocard:setScale(158/220)
        Ocard:setPosition(beginPos.x+Jiange*(i-1),beginPos.y)
        Ocard:addTo(self.outcard_bg)
    end

end

function  PlayerInfoLayer:getBeginPosInOutLayer(size)
   -- 594  178
   --178   220
   local scale=158/220
   local Jiange=50*(158/220)
   --[[
        return {
            x = 297-math.floor((178*scale*size-Jiange*(size-1))/2),
            y = 10,
        }--]]
        
        return {
            x = 297 - Jiange*math.floor(size/2)-60,
            y = 10,
        }

end

--参数：state  1、只显示开始游戏按钮, 2、显示开始游戏和邀请好友按钮，
function PlayerInfoLayer:showBeginBtnByState(state)
    self.beginBtnNode:setVisible(true)
    local state = state == nil and 1 or state
    
    if state == 1 then
        self.btnInvite:setVisible(false)
        self.btnCopyRoomnum:setVisible(false)
        self.btnReady:setPositionX(0)
    elseif state == 2 then
        self.btnInvite:setVisible(true)
        self.btnCopyRoomnum:setVisible(true)
        self.btnReady:setPositionX(0)
    end
end


function PlayerInfoLayer:showOutCardBtn()
    print("showOutCardBtn -------------------------", debug.traceback())
    self.outCardBtnNode:setVisible(true)
    self.outCardBtnNode:getChildByName("btnOutCard"):setVisible(true)
    self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
end

--参数：viewId 本地座位号，1、表示自己
function PlayerInfoLayer:showClockByViewId(viewId, times)
    if viewId ~= nil and viewId >= 1 and viewId <= MAX_PLAYER_SIZE then
        local position = POS_CLOCK[viewId]
        self.clockBg:setVisible(true)
        self.clockBg:setPosition(position)
        self.timeFont:stopAllActions()
        local ani = self:getClockAnimation(times)
        self.timeFont:runAction(ani)
    end
end

--闹钟动画
function PlayerInfoLayer:getClockAnimation(times)
    local showTimerAc = cc.CallFunc:create(function()
            
            if times <= 0 then
                self.timeFont:setString("00")
                self.clockBg:setVisible(false) 
                self.timeFont:stopAllActions()
            end
            self.timeFont:setString(string.format("%02d", times))
            times = times - 1
        end)

    local seqAc = cc.Sequence:create(showTimerAc, cc.DelayTime:create(1))
    
    return cc.RepeatForever:create(seqAc)
end

--停止闹钟动画
function PlayerInfoLayer:stopClock()
    self.clockBg:setVisible(false)
end

function PlayerInfoLayer:SetLiangDunBtn(flag)
    -- body
    self.BtnLiangDun:setVisible(flag)
end


function PlayerInfoLayer:showOtherHandCard(data)
    dump(data,"65656565")
    for i,v in ipairs(data.playerList) do 
        dump(v,"dgdhfdgh")
        local viId=self:getViewIdByUId(v.Uid)
        if viId==2 then
            self.handCard_right:setVisible(true)
            local indeX=15
            local indeY=225
            local CardData=self:exchangeCardsValue(v["leftHandCard"])
            dump(CardData,"****dgdhfdgh")
            for i,j in ipairs(CardData) do
                --这里根据牌值加载不同图片
                local card=Card:getEndCard(j,1)
                card:setAnchorPoint(cc.p(0,0))
                card:setPosition(indeX,indeY)
                card:addTo(self.handCard_right)
                indeX=indeX+26
                if i%15==0 then
                    indeY=indeY-50
                    indeX=15
                end
            end
        elseif viId==3 then
            self.handCard_left:setVisible(true)
                   local indeX=15
            local indeY=225
            local CardData=self:exchangeCardsValue(v["leftHandCard"])
            dump(CardData,"****dgdhfdgh")
            for i,v in ipairs(CardData) do
                --这里根据牌值加载不同图片
                local card=Card:getEndCard(v,1)
                card:setAnchorPoint(cc.p(0,0))
                card:setPosition(indeX,indeY)
                card:addTo(self.handCard_left)
                indeX=indeX+26
                if i%15==0 then
                    indeY=indeY-50
                    indeX=15
                end
            end
        end
    end
end

function PlayerInfoLayer:SetBiDunBtn(isChibing,isBidun)
    self.outCardBtnNode:setVisible(false)
    self.Node_ChiBing:setVisible(isChibing)
    self.BtnLiangDun:setVisible(isBidun)
end

function PlayerInfoLayer:reSetPlayerInfo()
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    local players = {} 
    --先把原来的数据去出来
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if (info.seatId or -1) >= 0 and (info.seatId or -1) < MAX_PLAYER_SIZE then
                table.insert(players, info)
            end
        end
    end

    for i, v in ipairs( players ) do
        local viewId = self:getViewIdBySeatId(v.seatId)
        if viewId == 2 then
            v.isLeftPlayer = false
        else
            v.isLeftPlayer = true
        end
        self:setPlayerInfoByViewId(viewId, v)
    end
    
end

function PlayerInfoLayer:getViewIdBySeatId(seatId)   --seatId为服务器座位号
        
    if seatId == nil or seatId < 0 then return nil end

    local other_index = seatId - MY_SEAT_ID
    local viewId = 0

    if other_index < 0 then
       other_index = other_index + MAX_PLAYER_SIZE
    end
     
    viewId =  other_index + 1  -- otherIndex2playerType[other_index]

    return viewId
end

function PlayerInfoLayer:setReadyStateByUId(uid)
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                self[nodeName[i]]:setReadyVisible(true)
            end
        end
    end

    if USER_INFO.uid == uid then
        self.beginBtnNode:setVisible(false)
        require("hall.GameCommon"):playEffectSound(TpackageName .. "/res/audio/on_turn.mp3")
    end
end

function PlayerInfoLayer:setFangZhuFlag( uid )
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                self[nodeName[i]]:setFangZhuFlag(true)
            end
        end
    end
end

function PlayerInfoLayer:setZhuangFlag( uid )
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                self[nodeName[i]]:setZhuangFlag(true)
            end
        end
    end
end

function PlayerInfoLayer:HideZhuangFlag( ... )
    -- body
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].setZhuangFlag then
            self[nodeName[i]]:setZhuangFlag(false)
        end
    end
end

function PlayerInfoLayer:hideAllPlayerReady()
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE  do
        if self[nodeName[i]].getUserInfo then
           self[nodeName[i]]:setReadyVisible(false)
        end
    end
    --for i, v in ipairs( nodeName ) do
    --   self[v]:setReadyVisible(false)
    --end
end

function PlayerInfoLayer:showHandlCards(cards, outUid, relogin,isChiBing)
    g_mainScene.myHandlerCards = self:exchangeCardsValue(cards)
    --self:addCardsToPlane(g_mainScene.myHandlerCards, outUid, relogin,isChiBing)
    self:SetCardZD(true)
    g_zxddGameData.placeCardType = g_zxddGameData.placeCardType_fold
    g_mainScene.tableLayer:SetBtnWeizhi(true)
    
            if outUid == USER_INFO.uid and not isChiBing then
                self:showOutCardBtn()
            end
end

function PlayerInfoLayer:SetCardZD( isSort)
    if isSort then
        Card:sortCard(g_mainScene.myHandlerCards)
    end
    g_mainScene.myHandlerCardsZD=CardsAnalysis:analysisFoldingCards(g_mainScene.myHandlerCards)
    self:foldingCards()
    g_mainScene.tableLayer.btn_layer:getChildByName("Button_zhankai"):setVisible(true)
    g_mainScene.tableLayer.btn_layer:getChildByName("Button_fold"):setVisible(false)
end

function  PlayerInfoLayer:showBtnLiangDun()
    self.BtnLiangDun:setVisible(true)
end

function PlayerInfoLayer:addCardsToPlane(structCards, outUid, relogin,isChiBing,isSort)
    g_zxddGameData.placeCardType = g_zxddGameData.placeCardType_disperse
    if not isSort then
        Card:sortCard(structCards)
    end

    self.handCardPanle:removeAllChildren()
    local beginPos = self:getBeginPos(#structCards)

    local indexCardPos = nil
    for i , v in ipairs(structCards or {}) do 
        local card = Card:getCard(v, 1 , not relogin)
        if not tolua.isnull(card) then
            card.selected = 0
            card:stopAllActions()
            card:setRotation(0)
            indexCardPos = self:getIndexHandCardPos(i,beginPos,#structCards)
            if relogin then 
                --card:setPosition(cc.p(beginPos + g_zxddGameData.cardInterval*(i-1), g_zxddGameData.cardOriginY))
                card:setPosition(cc.p(indexCardPos.x, indexCardPos.y))
            else
                card:setPosition(cc.p(indexCardPos.x, indexCardPos.y))
                local flag = (i == #structCards) and (outUid == USER_INFO.uid)
                self:SendAnimation(card, beginPos, i, flag,indexCardPos,isChiBing)
            
            end
            card.index = i
            card.value = v
            card.oriPosition = cc.p(indexCardPos.x, indexCardPos.y)
            card:addTo(self.handCardPanle)
        end
    end
end


function PlayerInfoLayer:cleanMyHandsCards()
    self.handCardPanle:removeAllChildren()
end

function PlayerInfoLayer:cleanOtherlayer( )
    self.handCard_left:setVisible(false)
    self.handCard_right:setVisible(false)
    self.handCard_left:removeAllChildren()
    self.handCard_right:removeAllChildren()
end
--发牌动画
function PlayerInfoLayer:SendAnimation( card, beginPos, index, toShowOutBtn,indexCardPos,isChiBing)
    -- body
   card:setPosition(g_mainScene:getContentSize().width / 2, g_mainScene:getContentSize().height / 2 + 170)
    local xy = cc.p(indexCardPos.x, indexCardPos.y)
    card:runAction(transition.sequence({
        cc.DelayTime:create(index * 0.02),
        cc.MoveTo:create(0.15 , xy),
        cc.CallFunc:create(function()
            card:toRotation()
            dump(isChiBing,"-----isChiBing----isChiBing")
            if toShowOutBtn and not isChiBing then
                self:showOutCardBtn()
            end
    end),
    }))

end

--把从服务器发过来的牌（数组），转换成{{[1]= value, [2] = color},...}
function PlayerInfoLayer:exchangeCardsValue(cards)
    local result = {}
    for i, v in ipairs( cards or {} ) do
        local logicValue = Card:Decode(v)
        local value, color = Card:init(logicValue)
        local tmp = {[1] = value, [2] = color} 
        table.insert(result, tmp)
    end

    return clone(result)
end

function PlayerInfoLayer:getBeginPos(size)
    if g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_disperse then
        if size <= g_zxddGameData.cardLineMax then
            return {
                x = 640 - g_zxddGameData.cardInterval*math.floor(size/2) + 30,
                y = g_zxddGameData.cardOriginY,
            }
        else
            self.lastCardX = 640 - g_zxddGameData.cardInterval*math.floor(g_zxddGameData.cardLineMax/2) + 30 + g_zxddGameData.cardInterval*(g_zxddGameData.cardLineMax-1)
            self.firstCardX = self.lastCardX - (g_zxddGameData.cardLineMax - 1)*g_zxddGameData.cardInterval
            return {
                x = self.lastCardX - g_zxddGameData.cardInterval*(size%g_zxddGameData.cardLineMax - 1),
                y = g_zxddGameData.cardOriginY + g_zxddGameData.cardHigher*math.floor(size/g_zxddGameData.cardLineMax),
            }
        end
    elseif g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then
        size = #g_mainScene.myHandlerCardsZD
        return {
            x = 640 - g_zxddGameData.cardInterval*math.floor(size/2) + 30,
            y = g_zxddGameData.cardOriginY,
        }
    end
    -- local surSize = math.mod(size, 2)
    -- if surSize == 0 then
    --     return 640 - g_zxddGameData.cardInterval*(math.floor(size/2) - 1) - g_zxddGameData.cardInterval/2 + 30
    -- else
    --     return 640 - g_zxddGameData.cardInterval*math.floor(size/2) + 30
    -- end
end

function PlayerInfoLayer:getIndexHandCardPos(index,beginPos,allNum)
    -- 最上面一排有多少个
    if allNum <= g_zxddGameData.cardLineMax then 
        return {
            x = beginPos.x + g_zxddGameData.cardInterval*(index-1),
            y = beginPos.y,
        }
    elseif index <= allNum%g_zxddGameData.cardLineMax then
        return {
            x = beginPos.x + g_zxddGameData.cardInterval*(index-1),
            y = beginPos.y,
        }
    else
        local leftIndex = (index - allNum%g_zxddGameData.cardLineMax - 1)%g_zxddGameData.cardLineMax
        -- dump(leftIndex)
        -- dump(self.firstCardX)
        -- dump(self.lastCardX - (g_zxddGameData.cardLineMax - 1)*g_zxddGameData.cardInterval)
        
        return {
            x = self.firstCardX + leftIndex*g_zxddGameData.cardInterval,
            y = beginPos.y - math.ceil((index - allNum%g_zxddGameData.cardLineMax)/g_zxddGameData.cardLineMax)*g_zxddGameData.cardHigher,
        }
    end
end

function PlayerInfoLayer:setInviteVisible(b)
    self.btnInvite:setVisible(b)
    self.btnCopyRoomnum:setVisible(b)
end

function PlayerInfoLayer:processBeinOutCard(uid,outTime)
    self:showOutCardBtnByUId(uid)
    self:showClock(uid,outTime)
end

function PlayerInfoLayer:initCardPanel()
        self.dunScore_1:setVisible(false)
    self.dunScore_2:setVisible(false)
    self.dunScore_3:setVisible(false)
    self.dunScore_1:setString("")
    self.dunScore_2:setString("")
    self.dunScore_3:setString("")
    if g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then
        self:initOutCardLayer(false)
        self.outcard_bg:removeAllChildren()
        g_mainScene.myHandlerCardsZD=CardsAnalysis:analysisFoldingCards(g_mainScene.myHandlerCards)
        self:foldingCards()
    else
        local children=self.handCardPanle:getChildren()
        for i,v in ipairs(children) do
            if v.selected==1 then
                v:toDown()
                v.selected=0
            end
        end
    end
end

function PlayerInfoLayer:showOutCardBtnByUId(uid)
    print("showOutCardBtn -------------------------", uid, USER_INFO.uid, debug.traceback())
    if USER_INFO.uid == uid then
        self:initCardPanel()
        self.outCardBtnNode:setVisible(true)
        self.outCardBtnNode:getChildByName("btnOutCard"):setVisible(true)
        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
    end
end

function PlayerInfoLayer:showClock(uid, times)
    local viewId = self:getViewIdByUId(uid)
    self:showClockByViewId(viewId, (times or OUT_CARD_TIMES))
end

function PlayerInfoLayer:getViewIdByUId(uid)
    local viewId = 0
    local nodeName = {[1] = "myUser", [2] = "rightUser", [3] = "leftUser"}
    for i = 1, MAX_PLAYER_SIZE do
        if self[nodeName[i]].getUserInfo then
            local info = self[nodeName[i]]:getUserInfo()
            if info.uid == uid then
                viewId = self:getViewIdBySeatId(info.seatId)
                return viewId
            end
        end
    end

    return viewId
end

function PlayerInfoLayer:getSelectCards()
    local result = {}
    if g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_disperse then
        local children = self.handCardPanle:getChildren()
        for i, v in ipairs( children or {} ) do
            if v.selected == 1 then-- and v.value > 0 
                print("getSelectCards ---------------", v.value)
                table.insert(result, v.value)
            end
        end
    else
        local children = self.outcard_bg:getChildren()
            for i, v in ipairs( children or {} ) do               
                    print("getSelectCards ---------------", v.value)
                    table.insert(result, v.value)
            end
    end

    return clone(result)
end

--[[--出牌layer注册触摸
function PlayerInfoLayer:addTouchEventListenerForFoldOutCard(plane)
    dump("addTouchEventListenerForFoldOutCard----1")
    local children=plane:getChildren()
    function onTouchBegan(touch, event)
        dump("addTouchEventListenerForFoldOutCard----2")
                cardTemp = nil
        local beganPosition = touch:getLocation()
        local children = plane:getChildren()

        for k,v in pairs(children) do
            local locationInNode = v:convertToNodeSpace(beganPosition)

            local s = v:getContentSize()
            local rect = cc.rect(0, -5, s.width, s.height + 5)
            if  cc.rectContainsPoint(rect, locationInNode) then
                cardTemp = v
            end
        end
        if cardTemp then
            cardTemp:removeSelf()
            insert(g_mainScene.myHandlerCards,cardTemp)
            Card:sortCard(g_mainScene.myHandlerCards)
            g_mainScene.myHandlerCardsZD = CardsAnalysis:analysisFoldingCards(g_mainScene.myHandlerCards)
            self.playerInfoLayer:foldingCards()
        end
        return false
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
--[[    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
   --[[ listener1:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )
    
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, plane)
end--]]

function PlayerInfoLayer:exchangeForOutCards(cards)
    local result = {}
    for i, v in ipairs( cards or {} ) do
        local value = Card:Encode(v[1]+16*v[2])
        table.insert(result, {["card"]=value})
    end 

    return result
end

function PlayerInfoLayer:processUserOutHandCards(info)
    g_mainScene.prevOutCards = self:exchangeCardsValue(info.Cardbuf)
    g_mainScene.prevOutCardType = info.Cardtype
    if info.nPreOutUserId == USER_INFO.uid then
        self:removeOutHandCards( info.Cardbuf )
        self.outCardBtnNode:setVisible(false)
        self.outcard_bg:removeAllChildren()
    else
        --重新显示牌数
        local user = self:getUserByUserId(info.nPreOutUserId)
        user:reduceCardSize(info.Cardcount)
    end
    --播放音效
    self:PlayMusic(info)
    g_mainScene.tableLayer:clearTableOutCardsByViewId(info.nNextOutUserId) --清理前面的出的牌
    g_mainScene.tableLayer:showOutCardsInTable(info.nPreOutUserId, info.Cardtype)
end


local CT_INVALID                  = 0        --错误类型
local CT_SINGLE                   = 1        --单牌类型
local CT_DOUBLE                   = 2        --对牌类型
local CT_THREE                    = 6        --三条类型
local CT_ONE_LINE                 = 4        --单连类型
local CT_DOUBLE_LINE              = 3        --对连类型
local CT_THREE_TAKE_ONE           = 6        --三带一单
local CT_THREE_TAKE_TOW           = 5        --三带二
local CT_PANEL                    = 7        --飞机
local CT_PANEL_LACK               = 8        --飞机
local CT_BOMB_CARD                = 12       --炸弹类型
local CT_3A_BOMB                  = 12       --3个A算特殊炸弹
local CT_BOMB_TAKE                = 9      --四带3
local CT_FOUR_TAKE_TWO = 10 --四带二
local CT_FOUR_TAKE_ONE = 11 --四带一
local CT_CHECP_TIP                = 14      --报单音乐
local CT_PASS                     = 15      --要不起音乐
local CT_WIN                      = 16      --赢得音乐
local CT_LOSE                     = 17      --输得音乐
local CT_SEND_CARD                = 18      --发牌音乐


function PlayerInfoLayer:PlayMusic( info )
    -- body
    local user = self:getUserByUserId(info.nPreOutUserId)
    if user == nil then return end
    
    local sex = user:getUserInfo().sex
    local sex_path = 1 == sex and "man" or "woman"
    local music_path = TpackageName .. "/res/audio/" .. sex_path .. "/"
    local card_type = info.Cardtype
    --1.单牌类型音乐
    if CT_SINGLE == card_type then 
        local music_value = info.Cardbuf[1] % 16
        music_path = music_path .. "poker_1_" .. music_value .. ".mp3"
    elseif CT_DOUBLE == card_type then 
        local music_value = info.Cardbuf[1] % 16
        music_path = music_path .. "poker_3_" .. music_value .. ".mp3"
    elseif CT_ONE_LINE == card_type then 
        music_path = music_path .. "poker_2_0.mp3"
    elseif CT_DOUBLE_LINE == card_type then 
        music_path = music_path .. "poker_4_0.mp3"
    elseif CT_THREE_TAKE_TOW == card_type then 
        music_path = music_path .. "poker_7_0.mp3"
    elseif CT_THREE == card_type then 
        music_path = music_path .. "poker_7_1.mp3"
    elseif CT_THREE_TAKE_ONE == card_type then 
        music_path = music_path .. "poker_7_2.mp3"
    elseif CT_PANEL == card_type or CT_PANEL_LACK == card_type then 
         music_path = music_path .. "poker_9_0.mp3"
    elseif  card_type>=23 then 
        music_path = music_path .. "poker_14_0.mp3"
    elseif CT_CHECP_TIP == card_type then 
        music_path = music_path .. "poker_only_1.mp3"
    elseif CT_PASS == card_type then 
        math.randomseed(socket.gettime())
        local random = math.random(1,4)
        music_path = music_path .. "pass_" .. random .. ".mp3"
    elseif CT_WIN == card_type then 
        music_path = TpackageName .. "/res/audio/win.mp3"
    elseif CT_LOSE == card_type then 
        music_path = TpackageName .. "/res/audio/lose.mp3"
    elseif CT_FOUR_TAKE_TWO == card_type then 
        music_path = music_path .. "sidaier.mp3"
    elseif CT_SEND_CARD == card_type then 
        music_path = TpackageName .. "/res/audio/fapai.mp3"
    else
        music_path = nil
    end

    --require("hall.GameCommon"):playEffectSound(music_path)
    if music_path ~= nil then
        require("hall.GameCommon"):play2d(music_path)
    end
    
end

function PlayerInfoLayer:processUserOutCardsError(info)
    local seq = cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function ( ... )
                self.errorTipsImg:setVisible(false)
            end))

    self.errorTipsImg:setVisible(true)
    self.errorTipsImg:runAction(seq)
end

function PlayerInfoLayer:removeOutHandCards( cards )
    
    for i, v1 in ipairs( g_mainScene.prevOutCards ) do
        for j, v2 in ipairs( g_mainScene.myHandlerCards ) do
            if v1[1] == v2[1] and v1[2] == v2[2] then
                table.remove(g_mainScene.myHandlerCards, j)
                break
            end
        end
    end
    if g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_disperse then
        self:addCardsToPlane(g_mainScene.myHandlerCards, nil, true,false)
    else
        Card:sortCard(g_mainScene.myHandlerCards)
        g_mainScene.myHandlerCardsZD=CardsAnalysis:analysisFoldingCards(g_mainScene.myHandlerCards)
        self:foldingCards()
    end
end

function PlayerInfoLayer:processUserPass(info)
    g_mainScene.tableLayer:clearTableOutCardsByViewId(info.nPassUserId)
    self:showPassFontByUId(info.nPassUserId)
    self:stopClock()
    self.outCardBtnNode:setVisible(false)
end

function PlayerInfoLayer:processUserAlert(info)
    --self:showAlertFlagByUId(info.userId)
end

function PlayerInfoLayer:processSingleGameOver( info )
    self.single_tip = nil
    self:stopClock()
    local hasChuntian = false
    for i, v in ipairs( info.playerList ) do
        -- print("====i===v==",v.Turningscore)
        -- self:showResultScore(v.Uid, v.Turningscore)
        self:exchangeUserScore(v.Uid, v.Totalscore / 100)
        local userNode = self:getUserNodeByUid(v.Uid)
--[[        if userNode then
            userNode:clearUserAni()
        end--]]
--[[        if v.isChunTian > 0 then
            hasChuntian = true
        end--]]
    end
    self:clearGameingData()
    if hasChuntian then
        g_mainScene.tableLayer:showChuntianAni(handler(self, self.showSingleResultLayer), info)
    else
        self:showSingleResultLayer(info)
    end
    -- self:showBeginBtnByState(1)
end

function PlayerInfoLayer:getUserNodeByUid( uid)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        return self.myUser
    elseif viewId == 2 then
        return self.rightUser
    elseif viewId == 3 then
        return self.leftUser
    end
end

function PlayerInfoLayer:showSingleResultLayer(info)
    local singleLayer = require("zixidadun.src.view.SingleResultLayer").new(info)
    if singleLayer then
        singleLayer:setName("singleResultLayer")
        singleLayer:setLocalZOrder(20)
        g_mainScene:addChild(singleLayer)
    end
end

function PlayerInfoLayer:showResultScore(uid, score)
    local viewId = self:getViewIdByUId(uid)
    print("====uid==viewId=score=",uid,viewId,score)
    if viewId == 1 then
        self.myUser:showResutlScore(score)
    elseif viewId == 2 then
        self.rightUser:showResutlScore(score)
    elseif viewId == 3 then
        self.leftUser:showResutlScore(score)
    end
    if uid == USER_INFO["uid"] then
        local status = score > 0 and CT_WIN or CT_LOSE
        local info = {nPreOutUserId = uid , Cardtype = status}
        self:PlayMusic(info)
    end
end

function PlayerInfoLayer:showCheckTip(uid)
    if uid == USER_INFO["uid"] then 
        return
    end
    local viewId = self:getViewIdByUId(uid)
    print("====uid==viewId=",uid,viewId)
    if viewId == 1 then
        self.myUser:showCheckTip()
    elseif viewId == 2 then
        self.rightUser:showCheckTip()
    elseif viewId == 3 then
        self.leftUser:showCheckTip()
    end

    self.single_tip = true
    local info = {nPreOutUserId = uid , Cardtype = CT_CHECP_TIP}
    self:PlayMusic(info)
end

function PlayerInfoLayer:exchangeUserScore(uid, score)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        self.myUser:exchangeForSingleScore(score)
    elseif viewId == 2 then
        self.rightUser:exchangeForSingleScore(score)
    elseif viewId == 3 then
        self.leftUser:exchangeForSingleScore(score)
    end
end

function PlayerInfoLayer:getUserScore(uid)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        return self.myUser:getUserScore()
    elseif viewId == 2 then
        return self.rightUser:getUserScore()
    elseif viewId == 3 then
        return self.leftUser:getUserScore()
    end
    return 0
end

function PlayerInfoLayer:clearAllUserInfo()
    self.outCardBtnNode:setVisible(false)
    self.beginBtnNode:setVisible(false)
    self:stopClock()
end

function PlayerInfoLayer:clearGameingData()
    g_mainScene.myHandlerCards = {}
    g_mainScene.prevOutCards = {} 
    g_mainScene.prevOutCardType = 0
end

function PlayerInfoLayer:showPassFontByUId(uid)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        self.myUser:showPassAni()
    elseif viewId == 2 then
        self.rightUser:showPassAni()
    elseif viewId == 3 then
        self.leftUser:showPassAni()
    end
    local info = {nPreOutUserId = uid , Cardtype = CT_PASS}
    self:PlayMusic(info)
end

--[[function PlayerInfoLayer:showAlertFlagByUId(uid)
    local viewId = self:getViewIdByUId(uid)
    if viewId == 1 then
        self.myUser:setAlertVisible(true)
    elseif viewId == 2 then
        self.rightUser:setAlertVisible(true)
    elseif viewId == 3 then
        self.leftUser:setAlertVisible(true)
    end

    -- 添加报单语音
    -- local info = {nPreOutUserId = uid , Cardtype = CT_PASS}
    -- self:PlayMusic(info)
end--]]

--牌局进行中的重连收的消息
function PlayerInfoLayer:processReloadRoom(info)
    g_mainScene.roomCommonLayer:setRoomNum(info.inviteCode)
    -- 设置牌子上的玩家信息
    self:setPlayerListInfo(info.playerlist)
    if 0 == info.GAME_STATE then 
        for k , v in pairs(info.playerlist) do 
            if v.if_ready ~= 1 and v.uid == USER_INFO["uid"] then
                g_mainScene.playerInfoLayer:showBeginBtnByState(2)
                return
            end
        end
        return 
    end

    --重连牌的设置
    local rSize = 0
    local lSize = 0
    local outCardSeatId = -1
    for i, v in ipairs( info.playerlist ) do
        local viewId = self:getViewIdByUId(v.uid)
        if viewId == 2 then
            rSize = v.HandCardCount
        elseif viewId == 3 then
            lSize = v.HandCardCount
        end 
        if v.uid == info.OutCardUserId then
            outCardSeatId = v.seat_id
        end
    end
    self:setVisibleAllUserReady(false)
    self:setHandCardsAndOtherCardSize(info.HandCardDatas, rSize, lSize , nil,  true)

    self:showClock(info.OutCardUserId, info.LeftTime)
    if info.OutCardUserId == USER_INFO.uid then
        self:showOutCardBtn()
    end

    --if info.lastOutUserId == info.OutCardUserId then
        self.prevOutCards = info.turnCards--{} -- 保存上次的出牌
        self.prevOutCardType = info.turnCardType--0
    --end
    local lastSeatId = info.turnCardSeatId--self:findLastOutCardSeatId(info.LastCarddata, outCardSeatId)
    local viewId = self:getViewIdBySeatId(lastSeatId)
    local turnCards = self:exchangeCardsValue(info.turnCards)
    g_mainScene.tableLayer:showOutCardsByViewId(viewId, turnCards, cardType, true)
end

function PlayerInfoLayer:findLastOutCardSeatId(cards, outCardSeatId)
    for i = 1, #cards do
        local prevSeatId = outCardSeatId - i < 0 and MAX_PLAYER_SIZE -1 or outCardSeatId - i
        if cards[prevSeatId+1].CardCount ~= 0 then
            return prevSeatId
        end
    end

    return -1
end

function PlayerInfoLayer:setPlayerListInfo(lst)
    -- 设置牌子上的玩家信息
    for i, v in ipairs( lst ) do
        if v.uid == USER_INFO.uid then 
            MY_SEAT_ID = v.seat_id
        end
    end
    for i, v in ipairs( lst ) do
        local playerInfo = self:getUserHeadInfo(v)
        local viewId = self:getViewIdBySeatId(v.seat_id)
        if viewId == 2 then
            playerInfo.isLeftPlayer = false
        else
            playerInfo.isLeftPlayer = true
        end
        self:setPlayerInfoByViewId(viewId, playerInfo)
    end
end

--relogin 用来作重连动画.以及发牌动画
function PlayerInfoLayer:setHandCardsAndOtherCardSize(cards, rSize, lSize , outUid, relogin,isChiBing)
    self:showHandlCards(cards, outUid, relogin,isChiBing)
    if  self.rightUser.setSurplusCardSize then
        self.rightUser:setSurplusCardSize(rSize)
    end
    if self.leftUser.setSurplusCardSize  then
        self.leftUser:setSurplusCardSize(lSize)
    end
    if not relogin then 
        local info = {nPreOutUserId = USER_INFO["uid"] , Cardtype = CT_SEND_CARD}
        self:PlayMusic(info)
    end
end

function PlayerInfoLayer:setVisibleAllUserReady(b)
    local nodeName = {"myUser", "rightUser", "leftUser"}
    for i = 1, MAX_PLAYER_SIZE  do
        if self[nodeName[i]].getUserInfo then
            self[nodeName[i]]:setReadyVisible(b)
        end
    end
    --for i, v in ipairs( nodeName ) do
    --    self[v]:setReadyVisible(b)
    --end
end

function PlayerInfoLayer:getUserHeadInfo(info)
    local result = {}
    result.name = info.nickName
    result.score = info.user_gold / 100
    result.icon_url = info.portrait
    result.uid = info.uid
    result.sex = info.sex
    result.seatId = info.seat_id
    result.isReady = info.if_ready > 0
    result.isOnline = info.if_online > 0
    result.isAlert = tonumber(info.if_alert or "0") > 0
    result.ip = info.ip
    result.latitude = info.latitude
    result.longitude = info.longitude
    result.otherInfo = info.otherInfo

    local otherInfo = json.decode(info.otherInfo) or {}
    result.city = otherInfo.city
    if otherInfo.ip then
        result.ip = otherInfo.ip
    end
    if not result.addres or result.addres == "" then
        ReqMgr:getAddress( result.latitude, result.longitude, result.uid)
    end

    return clone(result)
end

function PlayerInfoLayer:processRevcDisbandInfo( info )
    if info.agreeNum == 0 then
        if g_mainScene.roomCommonLayer.disbandLayer == nil then
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            g_mainScene.roomCommonLayer:processRevcRequestDisband(playerLst)
        end
    else
        if g_mainScene.roomCommonLayer.disbandLayer == nil then
            local playerLst = self:getUserInfoLstToDisband(info.applyId)
            g_mainScene.roomCommonLayer:processRevcRequestDisband(playerLst)
        end
        for i, v in ipairs( info.agreeMember_arr ) do
            g_mainScene.roomCommonLayer:exchangeStateBySel(v, 1)
        end
    end
end

function PlayerInfoLayer:getUserInfoLstToDisband(applyId)
    --{state = 1,userId = 12345, userName = "asdf", userUrl = "" }
    local nodeName = {"myUser", "rightUser", "leftUser"}
    local result = {}
    for i = 1, MAX_PLAYER_SIZE  do
        if self[nodeName[i]].getUserInfo then
            local info =  self[nodeName[i]]:getUserInfo()
            local tmp = {}
            tmp.state = info.uid == applyId and 3 or 2
            tmp.userId = info.uid
            tmp.userName = info.name
            tmp.userUrl = info.icon_url
            table.insert(result, tmp)
        end
    end
    --for i, v in ipairs( nodeName ) do
    --    if self[v].getUserInfo then
    --        local info = self[v]:getUserInfo()
    --        local tmp = {}
    --        tmp.state = info.uid == applyId and 3 or 2
    --        tmp.userId = info.uid
    --        tmp.userName = info.name
    --        tmp.userUrl = info.icon_url
    --
    --        table.insert(result, tmp)
    --    end
    --end

    return result
end

function PlayerInfoLayer:processRevcRejectDisband( info )
    g_mainScene.roomCommonLayer:clearDisbandLayer()
    local userLst = self:getUserInfoLstToDisband(0)
    local name = ""
    for i, v in ipairs( userLst ) do
        if info.rejectId == v.userId then
            name = v.userName
        end
    end
    local paras = {}
    paras.type = 1
    paras.title = "提示"
    paras.content = string.format("解散房间失败,玩家[%s]拒绝解散!", name)
    require("hall.tips.CommonTips"):showTips(paras)
    --g_mainScene.roomCommonLayer:exchangeStateBySel(info.rejectId, 0)
end

function PlayerInfoLayer:processRevcDisbandRoomSucc()
    -- 清理桌面数据
    bm.isDisbandSuccess = true
    g_mainScene.roomCommonLayer:clearDisbandLayer()
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
end

function PlayerInfoLayer:processUserStandUp(info)
    local user = self:getUserByUserId(info.uid)
    user:initUserInfo({})
    user:setVisible(false)
    -- require("hall.tips.CommonTips"):_gameToHall()
end

function PlayerInfoLayer:getUserByUserId(uid)
    local viewId = self:getViewIdByUId(uid)
    dump("viewId",viewId)
    if viewId == 1 then
        return self.myUser
    elseif viewId == 2 then
        return self.rightUser
    elseif viewId == 3 then
        return self.leftUser
    end
end

function PlayerInfoLayer:processFaceAndTxt(info)
    local user = self:getUserByUserId(info.uid)

    user:showFaceAndTxtByIndex(info.type)
end

function PlayerInfoLayer:onClickBtnTip(sender, event)

    if g_zxddGameData.LastType==0 then
            return
    end
    self:onClickBtnQuXiao()
    if #self.lefthandCard==0 then
          self.lefthandCard=clone(g_mainScene.myHandlerCards)  
    end

    local tab_tip=CardsAnalysis:getTipCards()
    if #tab_tip==0 then
        return
    end
    
    dump(tab_tip,"----tab_tip---")
    local CardValue=clone(tab_tip[g_zxddGameData.TipIndex][2])
    if  g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then 
        self.outcard_bg:setVisible(true)
      for i,v in ipairs(CardValue) do
            table.insert(self.selectCardFold,v)
            for j,k in ipairs(self.lefthandCard) do
                    if k[1]==v[1] and k[2]==v[2] then
                        table.remove(self.lefthandCard,j)
                    end
            end
      end
      self:SetOutCardLayer(self.selectCardFold)
    Card:sortCard(self.lefthandCard)
        g_mainScene.myHandlerCardsZD = CardsAnalysis:analysisFoldingCards(self.lefthandCard)
    self:foldingCards()


  else
        for i,v in ipairs(CardValue) do
        for j,k in ipairs(self.handCardPanle:getChildren() ) do

                if k.value[1]==v[1] and k.value[2]==v[2]  then
                    if k.selected~=1 then 
                       k:toUp()
                       k.selected=1
                   end

                end
        end
    end
    end
                local outCards = self:getSelectCards()
                    if CardsAnalysis:compareCard(outCards) then
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(true)
                        else
                        self.outCardBtnNode:getChildByName("btnOutCard"):setEnabled(false)
                    end
    if g_zxddGameData.TipIndex==#tab_tip then
            g_zxddGameData.TipIndex=1
            return
    end
    g_zxddGameData.TipIndex=g_zxddGameData.TipIndex+1

end





function PlayerInfoLayer:onClickBtnLiangDun(sender, event)
    self.BtnLiangDun:setVisible(false)
    zixidadunServer:CLI_PLAYER_LIANGDUN()
end

function PlayerInfoLayer:onClickBtnChiBing(sender, event)
    zixidadunServer:CLI_PLAYER_CHIBING(1)
    self.Node_ChiBing:setVisible(false)
end

function PlayerInfoLayer:onClickBtnNotChiBing(sender, event)
    self.Node_ChiBing:setVisible(false)
    zixidadunServer:CLI_PLAYER_CHIBING(0)
end


function PlayerInfoLayer:showBtnChiBing()
    --self.Node_ChiBing:setVisible(false)
    self.Node_ChiBing:setVisible(true)
end

function PlayerInfoLayer:showTipsCards(cards)
    self:clearHandlerCardsSelect()
    local childCards = self.handCardPanle:getChildren()
    dump( cards,"numbershowTipsCards ---------------------")
    if cards == nil then
        --提示出牌
        self:TipsAutoCard()
        return
    end
    if type(cards[1]) == "number" then
        cards={
            cards
        }
    end
    for i, v in ipairs( cards or {} ) do
        for j, v2 in pairs( self.handCardPanle:getChildren() or {} ) do
            if v[1] ==  v2.value[1] and v[2] == v2.value[2] then
                if v2.selected ~= 1 then
                    v2:toUp()
                end
                v2.selected = 1
            end

        end
    end
end

function PlayerInfoLayer:TipsAutoCard()
--[[    local small_value = 100
    local small_index = 0
    local second_index
    local second_value
    local big_value = -1
    local big_index = -1

    local big_state = false
    if self.rightUser and self.rightUser.leftCardSize and 1 == tonumber(self.rightUser.leftCardSize:getString()) then 
        big_state = true
    end

    for k , v in ipairs(self.handCardPanle:getChildren() or {}) do
        -- dump(v.value , "TipsAutoCard")
        if v.value[1] == small_value then 
            second_index = k
            second_value = v.value[1]
        end

        if v.value[1] < small_value then 
            small_value = v.value[1]
            small_index = k
        end
        if v.value[1] > big_value then 
            big_value = v.value[1]
            big_index = k
        end
    end

    for k, v in ipairs( self.handCardPanle:getChildren() or {} ) do
        if big_state and k == big_index then 
            if v.selected ~= 1 then
                v:toUp()
            end
            v.selected = 1
            break
        end
        if k == small_index or (second_index and k == second_index and small_value == second_value) then 
            if v.selected ~= 1 then
                v:toUp()
            end
            v.selected = 1
        end
    end--]]
end

function PlayerInfoLayer:clearHandlerCardsSelect()
    for i, v in ipairs( self.handCardPanle:getChildren() or {} ) do
        if v.selected == 1 then
            v:toDown()
        end
        v.selected = 0
    end
end

function PlayerInfoLayer:onClickBtnOutCard(sender, event)


    if  g_zxddGameData.testData then
        self:testOutCards()
    else
        local outCards=self:getSelectCards()
        if #outCards > 0 then
            self._onClickTipIdx = 0
            self._tipCards = {}
            local cards = self:exchangeForOutCards(outCards)
            dump(cards,"====玩家出牌====")
            dump(g_zxddGameData.laiziList,"---g_zxddGameData.laiziList---")
            local tab=self:exchangeForOutCards(g_mainScene.laiziList) 
            dump(tab,"---tab---")  
            zixidadunServer:CLI_PLAYER_CARD(#cards, cards,#tab,tab)
            g_mainScene.laiziList={}
        end
    end
        --self:returnHanCardData()
    --self:initOutCardLayer(true)

end

function PlayerInfoLayer:initOutCardLayer(isShow )
    --self.outCardBtnNode:getChildByName("outcard_bg"):removeAllChildren()
    self.lefthandCard={}
    self.selectCardFold={}
   self.outcard_bg:setVisible(isShow)
end


function PlayerInfoLayer:onClickBtnQuXiao(sender, event)

    if  g_zxddGameData.placeCardType == g_zxddGameData.placeCardType_fold then
       -- self:returnHanCardData()
        --local cards=self:getSelectCards()
        self:initOutCardLayer(false)
         self.outcard_bg:removeAllChildren()
        --Card:sortCard(g_mainScene.myHandlerCards)
        
        --self.myHandlerCardsZD=self.SaveZD
        dump(g_mainScene.myHandlerCards,"g_mainScene.myHandlerCards")
        dump(self.myHandlerCardsZD,"self.myHandlerCardsZD")
        self:testOutCards()
    else    
        local children=self.handCardPanle:getChildren()
        for i,v in ipairs(children) do
            if v.selected==1 then
                v.selected=0
                v:toDown()
            end
        end
    end
end

function PlayerInfoLayer:onClickBtnInvite(sender, event)
    -- body
    local paras = {}
    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
    paras["imagePath"] = "url"
    paras["name"] = "资溪打盾，房号：" .. USER_INFO["invote_code"]
    paras["showType"] = 2;
    paras["url"] = appDownLoadAddress

    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"],9999999)
    end
end

function PlayerInfoLayer:onClickBtnReady(sender, event)
    if  g_zxddGameData.testData then
        self:testCards()
    else
        zixidadunServer:CLI_READY_GAME(1)
    end
end

function PlayerInfoLayer:onClickBtnCopyRoomnum(sender, event)
    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"], 4)
    local shareInfo = "玩家"..strNick.."邀请你加入跑得快游戏，房间号【"..USER_INFO["invote_code"].."】。"
    require(GameSetting_filePath):copyToClipboard(shareInfo)
end

------------------------------切牌--------------------------------
--[[function PlayerInfoLayer:initQiePaiUI()

    --self.qiepai_vw:setVisible(false)
    local cardPath = "zixidadun/res/image/cards" 
   -- self.btn_shouzhiPos = self.btn_shouzhi:getPosition()
 
    local size = self.qiepai:getContentSize()
    local startPos = 0

    for i=1,54 do
        -- display.newSprite("#Adobe.png",100,100):addTo(self)
        -- local cardImg = cc.Sprite:createWithSpriteFrameName("card_back.png")
        local cardImg = display.newSprite("#card_back.png")
        cardImg:setPosition(cc.p(startPos + i * 20, size.height*0.5))
        cardImg:setAnchorPoint(cc.p(0.5,0.5))
        cardImg:addTo(self.qiepai)
    end

    self.qiepai:onTouch(handler(self, self.onClickHandCard))
    self.btn_shouzhi:onTouch(handler(self, self.onClickShouZhi))
    self.btn_sure:onClick(handler(self, self.onClickQiepaiSure))
end--]]

function PlayerInfoLayer:setQiePaiPanelVisible(flag)
    --self.qiepai_vw:setVisible(flag)
end

function PlayerInfoLayer:resetQiePai()
   -- self.btn_shouzhi:setPosition(self.btn_shouzhiPos)

    local nodes = self.qiepai:getChildren()
    for i,node in ipairs(nodes) do
        local pos = node:getPosition()
        node:setColor(cc.c3b(255,255,255))
    end
end

function PlayerInfoLayer:showQiepai(time)
    self:resetQiePai()
    --self.qiepai_vw:setVisible(true)
    self:showClock(USER_INFO["uid"],time)
end

function PlayerInfoLayer:onClickQiepaiSure(event)
    local target = event.target
    if event.name == "ended" then
        zixidadunServer:CLI_QIEPAI()
       -- self.qiepai_vw:setVisible(false)
        self:resetQiePai()
    end
end

function PlayerInfoLayer:onClickShouZhi(event)
    local target = event.target
    if event.name == "moved" or event.name == "began" then
        local x, y = event.x, event.y
        local pos = cc.p(x, y)
        local nodePos = target:convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        local parentPos = target:getParent():convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        self:change_btn_shouzhi_pos(parentPos)
    end
end

function PlayerInfoLayer:onClickHandCard(event)
    --local target = self.qiepai
    if event.name == "moved" or event.name == "began" then
        local x, y = event.x, event.y
        local pos = cc.p(x, y)
        local nodePos = target:convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        local parentPos = target:getParent():convertToNodeSpace(pos) --这样写是为了贴近函数的原始用法
        self:change_btn_shouzhi_pos(parentPos)
    end
end

function PlayerInfoLayer:change_btn_shouzhi_pos(parentPos)
    if parentPos.x < 200 or parentPos.x > 1280 then
        return 
    end
    self.btn_shouzhi:setPositionX(parentPos.x)
    local worldpoint = (self.btn_shouzhi:getParent()):convertToWorldSpace(self.btn_shouzhi:getPosition()) --这样写是为了贴近函数的原始用法
    --local pos = self.qiepai:convertToNodeSpace(worldpoint) --这样写是为了贴近函数的原始用法
    self:changeColorByPos(pos.x)
end

function PlayerInfoLayer:changeColorByPos(x)
   -- local nodes = self.qiepai:getChildren()
    for i,node in ipairs(nodes) do
        local pos = node:getPosition()
        if pos.x < x then
            node:setColor(cc.c3b(255,255,255))
        else
            node:setColor(cc.c3b(255,255,0))
        end
    end
end

function PlayerInfoLayer:onExit()
    -- body
end

function PlayerInfoLayer:random_table(t, num)
    math.randomseed(socket.gettime())
    for i,v in pairs(t) do
        local r = math.random(#t)
        local temp = t[i]
        t[i] = t[r]
        t[r] = temp
    end
    num = num or #t
    for i = #t,num+1, -1 do
        t[i] = nil
    end
    return t
end

function PlayerInfoLayer:testCards()
   -- g_mainScene.cardsAnalysis:isLiandui()
   --CardsAnalysis.laiziList=nil
    self:clearAllUserInfo()

    -- 随机73张牌
    local size_AllCards = {
        0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,
        0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
        0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
        0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,
        0x41,0x42,
        0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,
        0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
        0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
        0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,
        0x41,0x42,
        0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,
        0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
        0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
        0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,
        0x41,0x42,
        0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,
        0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,
        0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,
        0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,
        0x41,0x42,
        0x51,0x51,0x51, -- 癞子牌
    }

    self:random_table(size_AllCards,73)
    -- self:random_table(size_AllCards,2)
    -- dump(size_AllCards)
    self:setHandCardsAndOtherCardSize(size_AllCards, #size_AllCards, #size_AllCards, USER_INFO["uid"])

    -- 
    self.outCardBtnNode:setVisible(true)
    self.btnTip:setVisible(false)
    -- self.skipCard:setVisible(false)
    self.btnOutCard:setPositionX(0)
    self.outCardBtnNode:setPositionY(460)
end

function PlayerInfoLayer:testOutCards()
    -- 测试折叠牌
    g_mainScene.myHandlerCardsZD = CardsAnalysis:analysisFoldingCards(g_mainScene.myHandlerCards)
--[[    self.SaveZD={}
    for i=1,#g_mainScene.myHandlerCardsZD do
        self.SaveZD[i]={}
        for j,v in ipairs(g_mainScene.myHandlerCardsZD[i]) do
            self.SaveZD[i][j]={}
            self.SaveZD[i][j][1]=g_mainScene.myHandlerCardsZD[i][j][1]
            self.SaveZD[i][j][2]=g_mainScene.myHandlerCardsZD[i][j][2]
        end
    end--]]
    self:foldingCards()
    
    -- local outCardsList = {}
    -- for k,v in pairs(self.handCardPanle:getChildren()) do
    --     if v.selected == 1 then
    --         dump(v.value)
    --         table.insert(outCardsList, v.value)
    --     end
    -- end
    -- dump(outCardsList)
    -- outCardsList = {{1,5},{1,5},{1,5},{4,2},{6,2},{7,1}}
    -- 测试牌型检测
    -- CardsAnalysis:getType(outCardsList)
    -- CardsAnalysis:analysisLastOutCards(outCardsList,huacards,outCardsType)
end


function PlayerInfoLayer:foldingCards()
    self.handCardPanle:removeAllChildren()
    
    g_zxddGameData.placeCardType = g_zxddGameData.placeCardType_fold

    local beginPos = self:getBeginPos()

    local indexCardPos = nil
    for i , v in ipairs(g_mainScene.myHandlerCardsZD or {}) do 
        local card = Card:getCard(v[1], 1 , not relogin)
        if not tolua.isnull(card) then
            card.selected = 0
            card:stopAllActions()
            card:setRotation(0)
            indexCardPos = self:getIndexHandCardPos(i,beginPos,#g_mainScene.myHandlerCardsZD)
            card:setPosition(cc.p(indexCardPos.x, indexCardPos.y))
            card.index = i
            card.value = v
            card.oriPosition = cc.p(indexCardPos.x, indexCardPos.y)
            local size=self.CardSize:clone()
            size:setName("card_size")
            if v[1][1]==15 then
                dump(v,"2-------------")
            end
            size:setString(#v)
            size:setScale(0.8)
            size:setPosition(20,30)
            size:setVisible(true)
            card:addChild(size)
            card:addTo(self.handCardPanle)
        end
    end
end

function PlayerInfoLayer:ShowDunScoreByUid(UID,DunScore)
    dump(UID,"-----UID")
    dump(DunScore,"-----DunScore")
    local view=self:getViewIdByUId(UID)
    local text
    if view==1 then
        text=self.dunScore_1
    elseif view==2 then
        text=self.dunScore_2
    elseif view==3 then
        text=self.dunScore_3

    end
    text:setVisible(true)
    text:setString(DunScore)
end

function PlayerInfoLayer:foldingCardsByScore()
    local tab=g_mainScene.myHandlerCardsZD
    for i=1,#g_mainScene.myHandlerCardsZD  do
        for j=1,#g_mainScene.myHandlerCardsZD-1  do
            if #tab[j]<#tab[j+1] then
                local tab1=clone(tab[j])
                local tab2=clone(tab[j+1])
                tab[j]=tab2
                tab[j+1]=tab1
            end
        end
    end
    --self:foldingCards()
end

return PlayerInfoLayer