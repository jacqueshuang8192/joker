local   GamePlaneOperator = class("GamePlaneOperator")

local  	ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")
local   PlayerPlaneOperator = require(TpackageName .. ".operator.PlayerPlaneOperator")
local   TablePlaneOperator = require(TpackageName .. ".operator.TablePlaneOperator")


function GamePlaneOperator:init(_type,total_playernum)
    
    if _type == nil then

	    ControlPlaneOperator:init(NIUNIU_GAME_SCENE:getChildByName("control_plane"))
	    TablePlaneOperator:init()
	    -- PlayerPlaneOperator:initLayout()

	    -- self:initPlayerPlane(total_playernum)

	elseif _type == "player" then

		self:initPlayerPlane(total_playernum)
	end

end

function GamePlaneOperator:clearBankerFlag()
	
	for playerType = 1,TOTAL_PLAYERNUM do
		self:showHeadSymbol(playerType,"banker",false)  
	end

end

function GamePlaneOperator:setVisible( state )
	-- body
	ControlPlaneOperator:setVisible( state )
end

function GamePlaneOperator:SetAllNode(playerType , card)
    PlayerPlaneOperator:SetAllNode(playerType , card)
end 

function GamePlaneOperator:SetLoadValue( value1 , value2 )
    -- body
   	ControlPlaneOperator:SetLoadValue( value1 , value2 )
end

function GamePlaneOperator:initPlayerPlane(total_playernum)
    PlayerPlaneOperator:init(total_playernum)
end

function GamePlaneOperator:getPlayerPlane(playerType)
	return PlayerPlaneOperator:getPlayerPlane(playerType) 
end

function GamePlaneOperator:getSeatBtnPlane(playerType)
	return PlayerPlaneOperator:getSeatBtnPlane(playerType) 
end

function GamePlaneOperator:relocate(_type)
    
    if _type == "player" then
		for playerType = 1,TOTAL_PLAYERNUM do 
	    	PlayerPlaneOperator:relocate(self:getPlayerPlane(playerType))
	    end
	end
end


function GamePlaneOperator:switchMode(_type)

	if  _type == 1 then
		self:showWaiWeiButton(true)
		BET_MODE = true
	elseif  _type == 2 then
		self:showWaiWeiButton(false)
		BET_MODE = false
	end

	for playerType = 1,MAX_PLAYERNUM do  
		PlayerPlaneOperator:switchMode(self:getPlayerPlane(playerType),_type)
	end
	
end

function GamePlaneOperator:switchImg(_type,typeIndex)

	if  _type == "tableImg" then
		TablePlaneOperator:switchTableImg(typeIndex)
	elseif  _type == "cardBackImg" then
		PlayerPlaneOperator:swtichCardBackImg(typeIndex)
	end

end


function GamePlaneOperator:swtichCardBackImg(typeIndex)
	PlayerPlaneOperator:swtichCardBackImg(typeIndex)
end


function GamePlaneOperator:clearGameDatas(stage)
    
    for playerType = 1,TOTAL_PLAYERNUM do 
    	PlayerPlaneOperator:clearGameDatas(playerType,self:getPlayerPlane(playerType),stage)
    end

    ControlPlaneOperator:clearGameDatas(NIUNIU_GAME_SCENE:getChildByName("control_plane"),stage)
    TablePlaneOperator:clearGameDatas(stage)
end

function GamePlaneOperator:updateWaiWeiButton()
	ControlPlaneOperator:updateWaiWeiButton()
end

function GamePlaneOperator:setBetChip(playerType,value,flag)
	PlayerPlaneOperator:setBetChip(self:getPlayerPlane(playerType),value,flag)
end

function GamePlaneOperator:setTotalBetChip(playerType,value,flag)
	PlayerPlaneOperator:setTotalBetChip(self:getPlayerPlane(playerType),value,flag)
end

function GamePlaneOperator:showBetEffect(playerType,value)
	PlayerPlaneOperator:showBetEffect(playerType,value)
end

function GamePlaneOperator:removePlayer(playerType)
	PlayerPlaneOperator:removePlayer(playerType)
end

function GamePlaneOperator:hideCardKindTipButton()
	ControlPlaneOperator:hideCardKindTipButton()
end

function GamePlaneOperator:showControlButtons(game_state)
	ControlPlaneOperator:showControlButtons(game_state)
end

function GamePlaneOperator:SetHeadValue(value , func)
	ControlPlaneOperator:SetHeadValue(value , func)
end

function GamePlaneOperator:showWaiWeiButton(flag)
	ControlPlaneOperator:showWaiWeiButton(flag)
end

function GamePlaneOperator:loadBetButtons(base,canChooseBases,tuiZhuBase)
	ControlPlaneOperator:loadBetButtons(base,canChooseBases,tuiZhuBase)
end

function GamePlaneOperator:loadGrabBankerButtons(base,canChooseBases)
	ControlPlaneOperator:loadGrabBankerButtons(base,canChooseBases)
end

function GamePlaneOperator:RemaidStartGame(flag)
   	ControlPlaneOperator:RemaidStartGame(flag)
end

function GamePlaneOperator:showSitDownButton(flag)
    ControlPlaneOperator:showSitDownButton(flag)
end

function GamePlaneOperator:showCheckResultButton(flag)
	ControlPlaneOperator:showCheckResultButton(flag)
end

--------------------------------------------------桌面---------------------------------------------
function GamePlaneOperator:showAudienceBrand(flag)
	TablePlaneOperator:showAudienceBrand(flag)
end

function GamePlaneOperator:showRandomBankerChoose(playerTypeTbale)
	TablePlaneOperator:showRandomBankerChoose(playerTypeTbale)
end

function GamePlaneOperator:loadRulePlane()
	TablePlaneOperator:loadRulePlane()
end

function GamePlaneOperator:showBankerChoose(uid)
	TablePlaneOperator:showBankerChoose(uid)
end

function GamePlaneOperator:showNumCount(value,index,flag)
	TablePlaneOperator:showNumCount(value,index,flag)
end

function GamePlaneOperator:showCardNumCountEffect(arg)
	TablePlaneOperator:showCardNumCountEffect(arg)
end

function GamePlaneOperator:hideCardNumCountEffect()
	TablePlaneOperator:hideCardNumCountEffect()
end

function GamePlaneOperator:showStartAnimation()
	TablePlaneOperator:showStartAnimation()
end

function GamePlaneOperator:showGameEndAnimation(isWin)
	TablePlaneOperator:showGameEndAnimation(isWin)
end

function GamePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,changedMoneyArr,type)
	TablePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,changedMoneyArr,type)
end

function GamePlaneOperator:waiWeiCoinFly(playerType,pos,score,chip,finalPos)
	TablePlaneOperator:waiWeiCoinFly(playerType,pos,score,chip,finalPos)
end

function GamePlaneOperator:showAutoPlayTip(flag)
	TablePlaneOperator:showAutoPlayTip(flag)
end

--设置倒计时时间显示
function GamePlaneOperator:showStageTxt(info)
	TablePlaneOperator:showStageTxt(info)
end

--设置倒计时时间显示
function GamePlaneOperator:startTimer(time,stage)
	TablePlaneOperator:startTimer(time,stage)
end

function GamePlaneOperator:SetBtnTxt( card_type )
	-- body
	ControlPlaneOperator:SetBtnTxt(card_type)
end

function GamePlaneOperator:SetChooseBtn( state )
	-- body
	ControlPlaneOperator:SetChooseBtn(state)
end

function GamePlaneOperator:ShowShuiYuButton( txt , value)
	-- body
	ControlPlaneOperator:ShowShuiYuButton(txt , value)
end

function GamePlaneOperator:ShowShuiYuButtonState( state )
    -- body
	ControlPlaneOperator:ShowShuiYuButtonState(state)
end


function GamePlaneOperator:SetBtnJia(  )
	-- body
	ControlPlaneOperator:SetBtnJia()
end


--设置倒计时时间显示
function GamePlaneOperator:stopTimer()
	TablePlaneOperator:stopTimer()
end


function GamePlaneOperator:showTaiFeiTips(value)
	TablePlaneOperator:showTaiFeiTips(value)
end

-----------------------------------------------头像相关--------------------------------------------
function GamePlaneOperator:showPlayerInfo(playerType,userInfo)
   	return PlayerPlaneOperator:showPlayerInfo(playerType,self:getPlayerPlane(playerType),userInfo)
end

function GamePlaneOperator:showHeadSymbol(playerType,_type,flag)
	PlayerPlaneOperator:showHeadSymbol(self:getPlayerPlane(playerType),_type,flag)
end

function GamePlaneOperator:setEffectFrame(playerType,_type,flag)
	PlayerPlaneOperator:setEffectFrame(playerType,self:getPlayerPlane(playerType),_type,flag)
end

function GamePlaneOperator:clearEffectFrame()

	for playerType = 1,TOTAL_PLAYERNUM do
		self:setEffectFrame(playerType,_,false)
	end

end

function GamePlaneOperator:setBetTimes(playerType,times,flag)
	if  flag == nil then 
        flag = true
    end
    
    self:setEffectFrame(playerType,3)
    PlayerPlaneOperator:setBetTimes(self:getPlayerPlane(playerType),times,flag)
end

--隐藏加倍标记
function GamePlaneOperator:clearBetTimes()
    
    self:clearEffectFrame()
	-- for playerType = 1,TOTAL_PLAYERNUM do
	-- 	self:setEffectFrame(playerType,_,false)
	-- end

end

function GamePlaneOperator:setGrabBankerTimes(playerType,times,flag)
	if  flag == nil then 
        flag = true
    end

    PlayerPlaneOperator:setGrabBankerTimes(self:getPlayerPlane(playerType),times,flag)
end

function GamePlaneOperator:setGrabBankerSymbol(playerType,flag)
	if  flag == nil then 
        flag = true
    end
    
    self:setEffectFrame(playerType,1,flag)
    -- PlayerPlaneOperator:setGrabBankerSymbol(self:getPlayerPlane(playerType),flag)
end

--隐藏抢庄标记
function GamePlaneOperator:clearGrabBankerSymbol()

	for playerType = 1,TOTAL_PLAYERNUM do
		self:setGrabBankerSymbol(playerType,false)
	end

end

function GamePlaneOperator:setReadyStatus(playerType,flag)

	if  flag == nil then 
        flag = true
    end
    
	PlayerPlaneOperator:setReadyStatus(self:getPlayerPlane(playerType),flag)
end

function GamePlaneOperator:clearAllReadyStatus()

	for playerType = 1,TOTAL_PLAYERNUM do
		self:setReadyStatus(playerType,false)
	end
end

function GamePlaneOperator:updateCoin(playerType,value,changedMoneyArr,orichip)
	print("===3333333333==playerType=",playerType)
	PlayerPlaneOperator:updateCoin(self:getPlayerPlane(playerType),value,changedMoneyArr,orichip)
end


function GamePlaneOperator:setCoin(playerType,value)
	PlayerPlaneOperator:setCoin(self:getPlayerPlane(playerType),value)
end

-----------------------------------------------手牌相关--------------------------------------------
function GamePlaneOperator:showCards(playerType,cards,flag,isRelogin , status , card_state)
	PlayerPlaneOperator:showCards(playerType,self:getPlayerPlane(playerType),cards,flag,isRelogin , status , card_state)
end

function GamePlaneOperator:turnCards()
	PlayerPlaneOperator:turnCards(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end


function GamePlaneOperator:showDealCardsAnimation(playerType,cards,cardEndIndex,isRelogin, cardState,cardIndex , status)
	PlayerPlaneOperator:showDealCardsAnimation(playerType,self:getPlayerPlane(playerType),cards,cardEndIndex,isRelogin, cardState,cardIndex , status)
end

function GamePlaneOperator:GetAllNode(playerType)
	return PlayerPlaneOperator:GetAllNode(playerType)
end
--
function GamePlaneOperator:showCardKind(playerType,cardKind1,cardKind2)
	PlayerPlaneOperator:showCardKind(playerType,self:getPlayerPlane(playerType),cardKind1,cardKind2)
end

function GamePlaneOperator:foldCard(playerType,cards)
	PlayerPlaneOperator:foldCard(playerType,self:getPlayerPlane(playerType),cards)
end

function GamePlaneOperator:outCard(playerType,cards)
	PlayerPlaneOperator:outCard(playerType,self:getPlayerPlane(playerType),cards)
end

function GamePlaneOperator:openCards(playerType)
	PlayerPlaneOperator:openCards(playerType,self:getPlayerPlane(playerType))
end

function GamePlaneOperator:countFanAndShow(playerType)
	local playerType = playerType or CARD_PLAYERTYPE_MY
 	PlayerPlaneOperator:countFanAndShow(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showControlButtons(stage,flag)
	ControlPlaneOperator:showControlButtons(stage,flag)
end

function GamePlaneOperator:showCuoPai(cards,flag)
	PlayerPlaneOperator:showCuoPai(cards,self:getPlayerPlane(CARD_PLAYERTYPE_MY),flag)
end


return  GamePlaneOperator