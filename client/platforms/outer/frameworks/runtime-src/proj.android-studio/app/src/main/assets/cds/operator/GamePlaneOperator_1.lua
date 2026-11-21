local   GamePlaneOperator = class("GamePlaneOperator")

local  	ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")
local   PlayerPlaneOperator = require(TpackageName .. ".operator.PlayerPlaneOperator")
local   TablePlaneOperator = require(TpackageName .. ".operator.TablePlaneOperator")


function GamePlaneOperator:init(_type,total_playernum)
    local hall_plane = CDSPanel.hall_plane
    ControlPlaneOperator:init(hall_plane)
	TablePlaneOperator:init()
end

function GamePlaneOperator:downButtonInit()
	if tolua.isnull(CDS_GAME_SCENE) then
		return
	end
    local hall_plane = CDSPanel.hall_plane
	if tolua.isnull(hall_plane) then
		return
	end
	--ControlPlaneOperator:downButtonInit(hall_plane)
end

function GamePlaneOperator:initPlayerPlane(total_playernum)
    PlayerPlaneOperator:init(total_playernum)
end

function GamePlaneOperator:getPlayerPlane(playerType)
	return PlayerPlaneOperator:getPlayerPlane(playerType) 
end

function GamePlaneOperator:setPlayerHeadImg(playerType,userInfo)
	return PlayerPlaneOperator:setPlayerHeadImg(playerType,userInfo)
end

function GamePlaneOperator:relocate(_type)
    
    if _type == "player" then
		for playerType = 1,TOTAL_PLAYERNUM do 
	    	PlayerPlaneOperator:relocate(self:getPlayerPlane(playerType))
	    end
	end
end
function GamePlaneOperator:hidePlayer(_type)
	for playerType = 1,TOTAL_PLAYERNUM do
		PlayerPlaneOperator:hidePlayer(self:getPlayerPlane(playerType))
	end

end
function GamePlaneOperator:showPlayer()
	for v,k in pairs(CDS_PLAYERTYPE_TABLE) do
		if k ~= nil then
			PlayerPlaneOperator:showPlayer(self:getPlayerPlane(k))
			self:clearCardPlane(k)
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
		TablePlaneOperator:setSeatGold(playerType,0)
    end

    --ControlPlaneOperator:clearGameDatas(CDSPanel.hall_plane,stage)
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
function GamePlaneOperator:setTextNmuber(playerType,value)
	PlayerPlaneOperator:setTextNmuber(self:getPlayerPlane(playerType),value)
end


function GamePlaneOperator:showBetEffect(playerType,value)
	PlayerPlaneOperator:showBetEffect(playerType,value)
end

function GamePlaneOperator:removePlayer(playerType)
	PlayerPlaneOperator:removePlayer(playerType)
end
function GamePlaneOperator:clearPlayer()
	PlayerPlaneOperator:clearPlayer()
end
function GamePlaneOperator:hideCardKindTipButton()
	ControlPlaneOperator:hideCardKindTipButton()
end

function GamePlaneOperator:showWaiWeiButton(flag)
	ControlPlaneOperator:showWaiWeiButton(flag)
end

function GamePlaneOperator:loadBetButtons(base,canChooseBases,tuiZhuBase, base_chip)
	ControlPlaneOperator:loadBetButtons(base,canChooseBases,tuiZhuBase, base_chip)
end

function GamePlaneOperator:loadXiaZhu(base,base_chip)
	ControlPlaneOperator:loadXiaZhu(base,base_chip)
end

function GamePlaneOperator:showDiChi(num)
	ControlPlaneOperator:showDiChi(num)
end

function GamePlaneOperator:initDiChi()
	ControlPlaneOperator:initDiChi()
end

function GamePlaneOperator:loadGrabBankerButtons(base,canChooseBases)
	ControlPlaneOperator:loadGrabBankerButtons(base,canChooseBases)
end

function GamePlaneOperator:RemaidStartGame(flag)
   	ControlPlaneOperator:RemaidStartGame(flag)
end

function GamePlaneOperator:setGuanZhanVisible(flag)
	ControlPlaneOperator:setGuanZhanVisible(flag)
end

function GamePlaneOperator:showSitDownButton(seat, flag)
    --ControlPlaneOperator:showSitDownButton(seat,flag)
end

function GamePlaneOperator:showCheckResultButton(flag)
	ControlPlaneOperator:showCheckResultButton(flag)
end

--------------------------------------------------桌面---------------------------------------------
function GamePlaneOperator:showRandomBankerChoose(playerTypeTbale)
	TablePlaneOperator:showRandomBankerChoose(playerTypeTbale)
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

function GamePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,type,winType)
	TablePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,type,winType)
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
function GamePlaneOperator:showIsButtonXZ(flag)
	TablePlaneOperator:showIsButtonXZ(flag)
end
--设置倒计时时间显示
function GamePlaneOperator:stopTimer()
	TablePlaneOperator:stopTimer()
end


function GamePlaneOperator:showTaiFeiTips(value)
	TablePlaneOperator:showTaiFeiTips(value)
end

-----------------------------------------------头像相关--------------------------------------------
function GamePlaneOperator:showPlayerInfo(playerType,userInfo,seat)
   	return PlayerPlaneOperator:showPlayerInfo(playerType,self:getPlayerPlane(playerType),userInfo,seat)
end

function GamePlaneOperator:showMyPlayerInfo(userInfo,no,pwd)
    return PlayerPlaneOperator:showMyPlayerInfo(CARD_PLAYERTYPE_MY,self:getPlayerPlane(CARD_PLAYERTYPE_MY),userInfo,no,pwd)
end
function GamePlaneOperator:updateTableNoTotal(playerType, chip)
	PlayerPlaneOperator:updateTableNoTotal(self:getPlayerPlane(playerType), chip)
end

function GamePlaneOperator:showHeadSymbol(playerType,_type,flag)
	PlayerPlaneOperator:showHeadSymbol(self:getPlayerPlane(playerType),_type,flag)
end
function GamePlaneOperator:showCardsBack(callback,panel_playerType)
	PlayerPlaneOperator:showCardsBack(self:getPlayerPlane(panel_playerType),callback)
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
    
    dump(playerType,"setReadyStatus_playerType")
    dump(self:getPlayerPlane(playerType),"setReadyStatus_plane")

	PlayerPlaneOperator:setReadyStatus(self:getPlayerPlane(playerType),flag)
end

function GamePlaneOperator:clearAllReadyStatus()

	for playerType = 1,TOTAL_PLAYERNUM do
		self:setReadyStatus(playerType,false)
	end
end

function GamePlaneOperator:updateCoin(playerType,value,orichip)
	PlayerPlaneOperator:updateCoin(self:getPlayerPlane(playerType),value,orichip)
end


function GamePlaneOperator:setCoin(playerType,value)
	PlayerPlaneOperator:setCoin(self:getPlayerPlane(playerType),value)
end

function GamePlaneOperator:setMyCoin(value)
    PlayerPlaneOperator:setMyCoin(self:getPlayerPlane(CARD_PLAYERTYPE_MY),value)
end

-----------------------------------------------手牌相关--------------------------------------------
function GamePlaneOperator:showCards(playerType,cards,flag)
	PlayerPlaneOperator:showCards(playerType,self:getPlayerPlane(playerType),cards,flag)
end

function GamePlaneOperator:turnCards()
	PlayerPlaneOperator:turnCards(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:showAllCards(playerType,cards,cardEndIndex,flag,cardType)
	PlayerPlaneOperator:showAllCards(playerType,self:getPlayerPlane(playerType),cards,cardEndIndex,flag,cardType)
end
function GamePlaneOperator:showDealCardsAnimation(playerType,cards,cardEndIndex)
	PlayerPlaneOperator:showDealCardsAnimation(playerType,self:getPlayerPlane(playerType),cards,cardEndIndex)
end
function GamePlaneOperator:restartMoveCard()
	PlayerPlaneOperator:restartMoveCard()
end

function GamePlaneOperator:setSeatGold(playerType,value)
	TablePlaneOperator:setSeatGold(playerType, value)
end
--
function GamePlaneOperator:showCardKind(playerType,cardKind,type,isSound)
	PlayerPlaneOperator:showCardKind(playerType,self:getPlayerPlane(playerType),cardKind, type,isSound)
end


function GamePlaneOperator:foldCard(playerType,cards)
	PlayerPlaneOperator:foldCard(playerType,self:getPlayerPlane(playerType),cards)
end

function GamePlaneOperator:outCard(playerType,cards)
	PlayerPlaneOperator:outCard(playerType,self:getPlayerPlane(playerType),cards)
end

function GamePlaneOperator:countFanAndShow(playerType)
	local playerType = playerType or CARD_PLAYERTYPE_MY
 	PlayerPlaneOperator:countFanAndShow(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showControlButtons(stage,flag)
	ControlPlaneOperator:showControlButtons(stage,flag)
end

function GamePlaneOperator:showCuoPai(cards,flag)
	-- PlayerPlaneOperator:showCuoPai(cards,self:getPlayerPlane(CARD_PLAYERTYPE_MY),flag)
end

function GamePlaneOperator:clearCardPlane(playerType)
	PlayerPlaneOperator:clearCardPlane(playerType,self:getPlayerPlane(playerType))
end


--产生筹码
function GamePlaneOperator:onXiaZhu(data)
	if not data then
		return
	end

	local tabs = {}

	for i,v in ipairs(TablePlaneOperator.xiazhuMoneyTabs) do
		tabs[v] = i
	end

	for i,v in ipairs(data) do
		local temp = tabs[v.number]  
		if not tabs[v.number] then --如果没有对应金额
			temp = 1
		end
		TablePlaneOperator:createChouMa(temp,v.type+1,v.number)
	end
end

function GamePlaneOperator:onXiaZhuByChongLian(data)
	if not data then
		return
	end

	local tabs = {}

	for i,v in ipairs(TablePlaneOperator.xiazhuMoneyTabs) do
		tabs[v] = i
	end

	for i,v in ipairs(data) do
		local temp = tabs[v.number]  
		if not tabs[v.number] then --如果没有对应金额
			temp = 1
		end

		TablePlaneOperator:createChouMaByChongLian(temp,v.type+1,v.number)
	end
end

--取消下注
function GamePlaneOperator:onDeleteChouMa(data)
	TablePlaneOperator:onDeleteChouMa()
end

function GamePlaneOperator:showTotalXiaZhu(data)
	if not data then
		return
	end

	for i,v in ipairs(data) do
		TablePlaneOperator:setXiaZhuSumTxt(i,v)
	end

end

function GamePlaneOperator:showMyTotalXiaZhu(data)
	if not data or #data == 0 then

		for i=1,6 do
			TablePlaneOperator:setXiaZhuMySumTxt(i,0)
		end

		return
	end

	for i,v in ipairs(data) do
		TablePlaneOperator:setXiaZhuMySumTxt(i,v)
	end

end

function GamePlaneOperator:showShaiziAnimation(shaizi_1,shaizi_2,shaiziPos)
	if not shaizi_1 then
        shaizi_1 = 1
    end

    if not shaizi_2 then
        shaizi_1 = 1
    end
    
    TablePlaneOperator:showShaiziAnimation(shaizi_1,shaizi_2,shaiziPos)
end

function GamePlaneOperator:showYaoShaiziAnimation()
    TablePlaneOperator:showYaoShaiziAnimation()
end


function GamePlaneOperator:initXiaZhuPanel()
	TablePlaneOperator:initXiaZhuPanel()
end

function GamePlaneOperator:initZhanJiPanel(resultData)
	TablePlaneOperator:initZhanJiPanel(resultData)
end

function GamePlaneOperator:showKouPanZi(isvisible)
	TablePlaneOperator:showKouPanZi(isvisible)
end


return  GamePlaneOperator