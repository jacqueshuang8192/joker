local   GamePlaneOperator = class("GamePlaneOperator")

local  	ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")
local   PlayerPlaneOperator = require(TpackageName .. ".operator.PlayerPlaneOperator")
local   TablePlaneOperator = require(TpackageName .. ".operator.TablePlaneOperator")
local   scheduler = require(cc.PACKAGE_NAME .. ".scheduler")


function GamePlaneOperator:init()
	TablePlaneOperator:init()
	PlayerPlaneOperator:init(TOTAL_PLAYERNUM)
	ControlPlaneOperator:init()
	self:addCompCardLayer()
end

function GamePlaneOperator:addCompCardLayer()
	local layer = SCENENOW["scene"]:getChildByName("compCardLayer")
	if layer == nil then
	    local layer = require(TpackageName .. ".view.CompCardLayer").new()

	    layer:addTo(SCENENOW["scene"])
	    layer:setName("compCardLayer")
	    layer:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
	    layer:setZOrder(22)
	end
end

function GamePlaneOperator:downButtonInit()
	if tolua.isnull(BIJI_GAME_SCENE) then
		return
	end

end
function GamePlaneOperator:initPlayerPlane(total_playernum)
    PlayerPlaneOperator:init(total_playernum)
end

function GamePlaneOperator:getPlayerPlane(playerType)
	return PlayerPlaneOperator:getPlayerPlane(playerType) 
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
	for v,k in pairs(BIJI_PLAYERTYPE_TABLE) do
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

    --ControlPlaneOperator:clearGameDatas(BIJI_GAME_SCENE:getChildByName("control_plane"),stage)
    --TablePlaneOperator:clearGameDatas(stage)
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
	self:downButtonInit()
end

--------------------------------------------------桌面---------------------------------------------
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

function GamePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,type)
	TablePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,type)
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
function GamePlaneOperator:showTimes(timeout)
	ControlPlaneOperator:showCardCountDown(timeout)
end
-----------------------------------------------手牌相关--------------------------------------------
function GamePlaneOperator:showCards(playerType, cards)
	PlayerPlaneOperator:showCards(playerType, self:getPlayerPlane(playerType), cards)
	--ControlPlaneOperator:showCardCountDown()
	local gameResultLayer = SCENENOW["scene"]:getChildByName("layout_newGameResultLayer")
	if gameResultLayer ~= nil then
		gameResultLayer:removeSelfAndCancelCountDowm()
	end

	local compCardLayer = SCENENOW["scene"]:getChildByName("compCardLayer")
	if compCardLayer ~= nil then
		compCardLayer:stopAniAndHideSelf()
	end

end

function GamePlaneOperator:showEachPiersCards(pierIndex, cards, cardType)
	dump(cards, "showEachPiersCards")
	PlayerPlaneOperator:showEachPiersCards(pierIndex, cards, cardType)
end

function GamePlaneOperator:showThreePiersCards(playerType, cards, flag)
	PlayerPlaneOperator:showThreePiersCards(playerType, self:getPlayerPlane(playerType), cards, flag)
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

function GamePlaneOperator:outCard(playerType,value)
	PlayerPlaneOperator:outCard(playerType,self:getPlayerPlane(playerType),value)
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

function GamePlaneOperator:clearCardPlane(playerType)
	PlayerPlaneOperator:clearCardPlane(playerType,self:getPlayerPlane(playerType))
end

function GamePlaneOperator:claerHandCardPlane()
	for i = 1,6 do
		PlayerPlaneOperator:claerHandCardPlane(self:getPlayerPlane(i))
	end
end
function GamePlaneOperator:setCardType()
	PlayerPlaneOperator:setCardType()
end
function GamePlaneOperator:startGameTime(time)
	TablePlaneOperator:startGameTime(time)
end

function GamePlaneOperator:getCardLogicValue(card_value)
	local value = bit.band(card_value, 0x0F)
	print("value111",value)
	if value == 1 then
		value = 14
	end
	local color =  bit.band(card_value, 0xF0)
	if color == 0x00 then
		color = 1
	elseif color == 0x10 then
		color = 2
	elseif color == 0x20 then
		color = 3
	elseif color == 0x30 then
		color = 4
	elseif color == 0x40 then
		color = 5
	elseif color == 0x50 then
		color = 6
	end

	return value, color
end

function GamePlaneOperator:sortFunction(a,b)
	if a.value == b.value then
		return a.color < b.color
	else
		if a.value == 0 then
			return true
		elseif b.value == 0 then
			return false
		end
		return a.value > b.value
	end
end

function GamePlaneOperator:outCards(plaeryType,cards, indexData)
	PlayerPlaneOperator:outCards(plaeryType,self:getPlayerPlane(plaeryType),cards, indexData)

end
function GamePlaneOperator:claerAllPlane()
	PlayerPlaneOperator:claerAllPlane()
end

function GamePlaneOperator:showActionTypeCard(plaeryType, data, indexData)
	PlayerPlaneOperator:showActionTypeCard(plaeryType,self:getPlayerPlane(plaeryType),data, indexData)
end
function GamePlaneOperator:showActionChips(plaeryType, chip, indexData)
	PlayerPlaneOperator:showActionChips(plaeryType,self:getPlayerPlane(plaeryType),chip, indexData)
end

function GamePlaneOperator:operationCardZhong(plaeryType, flag, isOpen)
	PlayerPlaneOperator:operationCardZhong(plaeryType,self:getPlayerPlane(plaeryType), flag, isOpen)
end

function GamePlaneOperator:resetAllTipStatus(flag)

	for playerType = 1,TOTAL_PLAYERNUM do
		self:operationCardZhong(playerType,flag, 0)
	end
end

-- function GamePlaneOperator:showReadyCountDown()
-- 	self.desCountDown = BIJI_GAME_SCENE:getChildByName("ready_btn"):getChildByName("txt_btn_description")
-- 	self.beginTime = 5
-- 	self.desCountDown:setString(string.format("准备 (%s)", self.beginTime))
-- 	self.readyCountDowmHandler = scheduler.scheduleGlobal(handler(self, self.playCountDown), 1.0)
-- end

-- function GamePlaneOperator:playCountDown()
-- 	self.beginTime = self.beginTime - 1
-- 	if self.beginTime == 0 then
-- 		scheduler.unscheduleGlobal(self.readyCountDowmHandler)
-- 		self.readyCountDowmHandler = nil
-- 		BiJiSendHandle:CLI_READYNOW_ROOM()
-- 	else
-- 		if self.desCountDown ~= nil then
-- 			self.desCountDown:setString(string.format("准备 (%s)", self.beginTime))
-- 		end
-- 	end
-- end

function GamePlaneOperator:showSingleResult(info)
	-- info = {                                   
	--      userinfos = {
	--         {
	--             chip_list = {-1,1,1},
	--             chip_list_size = 3,
	--             clearanceScore = 0,
	--             gold           = 1,
	--             guding         = 0,
	--             icon_url       = "http://thirdwx.qlogo.cn/mmopen/vi_32/8hAib3LaXCPcnXqQuKXl9DbIN10BsSUdAI1f495kvvmwejxwE4vBwyuYibb1CE3OqEAzernluoPxNVoT500CEK3Q/132",
	--             lianshun       = 0,
	--             m_chips        = 1,
	--             nickName       = "火特游戏Jerry张权",
	--              openCard = { {open_type = 1,son_card = {3,37,7},son_card_size = 3},
	-- 			              {open_type = 1,son_card = {55,40,57},son_card_size = 3},
	-- 			              {open_type = 1,son_card = {17,33,49},son_card_size = 3},
	-- 			          },
	--             openCardSize   = 3,
	--             quanhei        = 0,
	--             quanhong       = 0,
	--             quansantiao    = 0,
	--             sanqin        = 0,
	--             sanshunzi      = 0,
	--             shuangsantiao  = 0,
	--             shuangshunqing = 0,
	--             sitou          = 0,
	--             turngold       = 1,
	--             uid            = 15038,
	--         }
	--     }
	-- }

	local layer = SCENENOW["scene"]:getChildByName("compCardLayer")
	if layer == nil then
	    local layer = require(TpackageName .. ".view.CompCardLayer").new()

	    layer:addTo(SCENENOW["scene"])
	    layer:setName("compCardLayer")
	    layer:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
	    layer:init(info)
	    layer:showOpenCard(info)
	else
		layer:setVisible(true)
		layer:showOpenCard(info)
	end
end

function GamePlaneOperator:openTotalResult(pack,time)
	self.totalRankingPack = pack

	--local time = 1
	self.delayHandler = scheduler.performWithDelayGlobal(handler(self, self.delayOpenTotalResult), time)
end

function GamePlaneOperator:delayOpenTotalResult()
	self.delayHandler = nil
	if SCENENOW['scene']:getChildByName("cardLayer") ~= nil then
        SCENENOW['scene']:removeChildByName("cardLayer")
    end
    if SCENENOW['scene'] and SCENENOW['scene'].onNetRanking then
		SCENENOW['scene']:onNetRanking(self.totalRankingPack)
	end
end

function GamePlaneOperator:openNetRanking()
	if self.totalRankingPack ~= nil and self.delayHandler ~= nil then
		scheduler.unscheduleGlobal(self.delayHandler)
		self.delayHandler = nil
		if SCENENOW['scene']:getChildByName("cardLayer") ~= nil then
	        SCENENOW['scene']:removeChildByName("cardLayer")
	    end
		SCENENOW['scene']:onNetRanking(self.totalRankingPack)
		self.totalRankingPack = nil
	end
end

function GamePlaneOperator:showCheatSurpCards(cards)
	PlayerPlaneOperator:showCheatSurpCards(cards)
end

function GamePlaneOperator:onExit()
	scheduler.unscheduleGlobal(self.readyCountDowmHandler)
	self.readyCountDowmHandler = nil
end

return  GamePlaneOperator