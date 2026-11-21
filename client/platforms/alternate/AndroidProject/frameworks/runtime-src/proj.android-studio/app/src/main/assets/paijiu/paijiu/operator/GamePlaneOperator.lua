local GamePlaneOperator = class("GamePlaneOperator")

local  	ControlPlaneOperator = require(TpackageName .. ".operator.ControlPlaneOperator")
local   PlayerPlaneOperator = require(TpackageName .. ".operator.PlayerPlaneOperator")
local   TablePlaneOperator = require(TpackageName .. ".operator.TablePlaneOperator")

local 	PLAYER_PLANE_TABLE = {}

function GamePlaneOperator:init(_type)
    
    if _type == nil then

		PLAYER_PLANE_TABLE={
							[CARD_PLAYERTYPE_MY]     =  PAIJIU_GAME_SCENE:getChildByName("player_panel_1"),
							[CARD_PLAYERTYPE_LEFT]	 =  PAIJIU_GAME_SCENE:getChildByName("player_panel_2"),
                            [CARD_PLAYERTYPE_TOP]    =  PAIJIU_GAME_SCENE:getChildByName("player_panel_3"),
                            [CARD_PLAYERTYPE_RIGHT]  =  PAIJIU_GAME_SCENE:getChildByName("player_panel_4")
--[[							[CARD_PLAYERTYPE_LEFT1]  = PAIJIU_GAME_SCENE:getChildByName("player_panel_2"),
							[CARD_PLAYERTYPE_LEFT1]  = PAIJIU_GAME_SCENE:getChildByName("player_panel_2"),
							[CARD_PLAYERTYPE_LEFT2]  = PAIJIU_GAME_SCENE:getChildByName("player_panel_3"),
							[CARD_PLAYERTYPE_LEFT3]  = PAIJIU_GAME_SCENE:getChildByName("player_panel_4"),

							[CARD_PLAYERTYPE_TOP1]   = PAIJIU_GAME_SCENE:getChildByName("player_panel_5"),
							[CARD_PLAYERTYPE_TOP2]   = PAIJIU_GAME_SCENE:getChildByName("player_panel_6"),
							[CARD_PLAYERTYPE_TOP3]   = PAIJIU_GAME_SCENE:getChildByName("player_panel_7"),

							[CARD_PLAYERTYPE_RIGHT1] = PAIJIU_GAME_SCENE:getChildByName("player_panel_8"),
							[CARD_PLAYERTYPE_RIGHT2] = PAIJIU_GAME_SCENE:getChildByName("player_panel_9"),
							[CARD_PLAYERTYPE_RIGHT3] = PAIJIU_GAME_SCENE:getChildByName("player_panel_10")]]
		}

	    for playerType = 1, MAX_PLAYERNUM do
	    	PlayerPlaneOperator:init(playerType, self:getPlayerPlane(playerType))
	    end

	    ControlPlaneOperator:init(PAIJIU_GAME_SCENE:getChildByName("control_panel"))
	    TablePlaneOperator:init(PAIJIU_GAME_SCENE:getChildByName("control_panel"))

	elseif _type == "player" then
	    for playerType = 1, MAX_PLAYERNUM do
	    	PlayerPlaneOperator:init(playerType, self:getPlayerPlane(playerType))
	    end

	end

end


function GamePlaneOperator:relocate(_type)
    if _type == "player" then
		for playerType = 1, MAX_PLAYERNUM do
	    	PlayerPlaneOperator:relocate(self:getPlayerPlane(playerType))
	    end
	end
end

function GamePlaneOperator:switchMode(_type)

	if  _type == 1 then
		self:showWaiWeiButton(true)
		-- self:showStageTxt(true)
		BET_MODE = true
	elseif  _type == 2 then
		self:showWaiWeiButton(false)
	    -- self:showStageTxt(false)
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

    ControlPlaneOperator:clearGameDatas(stage)
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
	PlayerPlaneOperator:showBetEffect(self:getPlayerPlane(playerType),value)
end

function GamePlaneOperator:getPlayerPlane(playerType)
	return PLAYER_PLANE_TABLE[playerType]
end

function GamePlaneOperator:removePlayer(playerType)
	PlayerPlaneOperator:init(playerType,self:getPlayerPlane(playerType))
end

function GamePlaneOperator:hideCardKindTipButton()
	ControlPlaneOperator:hideCardKindTipButton()
end

function GamePlaneOperator:showControlButtons(game_state)
	ControlPlaneOperator:showControlButtons(game_state)
end

function GamePlaneOperator:showWaiWeiButton(flag)
	ControlPlaneOperator:showWaiWeiButton(flag)
end

function GamePlaneOperator:loadBetButtons(base,canChooseBases,tuiZhuBase)
	ControlPlaneOperator:loadBetButtons(base,canChooseBases,tuiZhuBase)
end

function GamePlaneOperator:loadZhuangPanel(flag)
	ControlPlaneOperator:loadZhuangPanel(flag)
end

function GamePlaneOperator:RemaidStartGame(flag)
   	ControlPlaneOperator:RemaidStartGame(flag)
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

function GamePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,oriChipTable,type)
	TablePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,oriChipTable,type)
end

function GamePlaneOperator:waiWeiCoinFly(playerType,pos,score,chip,finalPos)
	TablePlaneOperator:waiWeiCoinFly(playerType,pos,score,chip,finalPos)
end

function GamePlaneOperator:showAutoPlayTip(flag)
	TablePlaneOperator:showAutoPlayTip(flag)
end

--设置倒计时时间显示
function GamePlaneOperator:showStageTxt(flag)
	TablePlaneOperator:showStageTxt(flag)
end

--设置倒计时时间显示
function GamePlaneOperator:startTimer(time,stage)
	TablePlaneOperator:startTimer(time,stage)
end

--设置倒计时时间显示
function GamePlaneOperator:stopTimer()
	TablePlaneOperator:stopTimer()
end

function GamePlaneOperator:showTaiFeiTips(value)
	TablePlaneOperator:showTaiFeiTips(value)
end

-----------------------------------------------头像相关--------------------------------------------
function GamePlaneOperator:showPlayerInfo(playerType,userInfo,showBuyGoldButton)
   	return PlayerPlaneOperator:showPlayerInfo(playerType,self:getPlayerPlane(playerType),userInfo,showBuyGoldButton)
end

function GamePlaneOperator:showHeadSymbol(playerType, _type, flag)
	PlayerPlaneOperator:showHeadSymbol(self:getPlayerPlane(playerType), _type,flag)
end

function GamePlaneOperator:setEffectFrame(playerType,_type,flag)
	PlayerPlaneOperator:setEffectFrame(playerType,self:getPlayerPlane(playerType),_type,flag)
end

function GamePlaneOperator:clearEffectFrame()

	for playerType = 1,TOTAL_PLAYERNUM do
		self:setEffectFrame(playerType,_,false)
	end

end

function GamePlaneOperator:setBetTimes(playerType,flag,times)
	if  flag == nil then 
        flag = true
    end
    
    PlayerPlaneOperator:setBetTimes(self:getPlayerPlane(playerType),flag,times)
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

    PlayerPlaneOperator:setGrabBankerTimes(self:getPlayerPlane(playerType),times, flag)
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

	for playerType = 1, TOTAL_PLAYERNUM do
		self:showZhuangAttitude(playerType,0)
	end

end

function GamePlaneOperator:setReadyStatus(playerType, flag)
    dump(playerType,"setReadyStatus")
	PlayerPlaneOperator:setReadyStatus(self:getPlayerPlane(playerType), flag)
end

function GamePlaneOperator:clearAllReadyStatus()

	for playerType = 1,TOTAL_PLAYERNUM do
		self:setReadyStatus(playerType,false)
	end
end

function GamePlaneOperator:updateCoin(playerType, value, orichip)
	PlayerPlaneOperator:updateCoin(self:getPlayerPlane(playerType), value, orichip)
end


function GamePlaneOperator:setCoin(playerType,value)
	PlayerPlaneOperator:setCoin(self:getPlayerPlane(playerType),value)
end

-----------------------------------------------手牌相关--------------------------------------------
function GamePlaneOperator:showCards(playerType,cards,flag)
	PlayerPlaneOperator:showCards(playerType,self:getPlayerPlane(playerType),cards,flag)
end

function GamePlaneOperator:setCardsValue(playerType,cards,flag)
	PlayerPlaneOperator:setCardsValue(playerType,self:getPlayerPlane(playerType),cards,flag)
end

function GamePlaneOperator:showDealCardsAnimation(playerType,cards,cardEndIndex)
	PlayerPlaneOperator:showDealCardsAnimation(playerType,self:getPlayerPlane(playerType),cards,cardEndIndex)
end

--
function GamePlaneOperator:showCardKind(playerType,cardKind)
	PlayerPlaneOperator:showCardKind(playerType,self:getPlayerPlane(playerType),cardKind)
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

function GamePlaneOperator:showControlButtons(stage, flag)
	ControlPlaneOperator:showControlButtons(stage ,flag)
end

function GamePlaneOperator:showCuoPai(cards,flag)
	PlayerPlaneOperator:showCuoPai(cards,flag)
end

function GamePlaneOperator:showInviteReadyExitBtn(tag, flag)
    ControlPlaneOperator:showInviteReadyExitBtn(tag, flag)
end

function GamePlaneOperator:showInviteBtnText(flag)
    ControlPlaneOperator:showInviteBtnText(flag)
end

function GamePlaneOperator:showZhuangAttitude(playerType, flag)
    PlayerPlaneOperator:showZhuangAttitude(self:getPlayerPlane(playerType), flag)
end

function GamePlaneOperator:loadCallTimesPanel(flag, timesCount, timesFenArray)
    ControlPlaneOperator:loadCallTimesPanel(flag, timesCount, timesFenArray)
end


function GamePlaneOperator:showPlayerDaoPanel(playerType, flag)
end

function GamePlaneOperator:setDao(playerType, order, value,pos, countValue)
end

function GamePlaneOperator:startTimer(time, stage)
    TablePlaneOperator:startTimer(time, stage)
end

function GamePlaneOperator:showPoolCards(showCards)
	TablePlaneOperator:showPoolCards(showCards)
end

function GamePlaneOperator:showRemainCards(remainCount)
	TablePlaneOperator:showRemainCards(remainCount)
end

function GamePlaneOperator:showCardGroups(isShow)
	ControlPlaneOperator:showCardGroups(PAIJIU_GAME_SCENE:getChildByName("control_panel"), isShow)
end

function GamePlaneOperator:showOutCardButtons(isShow)
    ControlPlaneOperator:showOutCardButtons(isShow)
end

function GamePlaneOperator:openCards(playerType, cardGroups)
	PlayerPlaneOperator:openCards(playerType, self:getPlayerPlane(playerType), cardGroups)
end

function GamePlaneOperator:openAllcall(playerType, cardGroups, index)
    PlayerPlaneOperator:openAllcall(playerType, self:getPlayerPlane(playerType), cardGroups, index)
end
        
        
function GamePlaneOperator:showShiziAnimotion(data)
    TablePlaneOperator:showShiziAnimotion(data)
end

function GamePlaneOperator:showCardsOnResultCsb(playerType, panel, cardGroups)
    PlayerPlaneOperator:showCardsOnResultCsb(playerType, panel, cardGroups)
end

function GamePlaneOperator:showGrabBankerAnim(grabBankerCount, grabBankerArray, grabBankerTimeOut)
    dump("-- 抢庄动画")
    -- 抢庄动画
    local i = 0
    local actiontime = 0.2
    local count = grabBankerTimeOut/actiontime

    if grabBankerCount == 0 or grabBankerCount == 1 then
    	self:showBankerAni(grabBankerTimeOut)
    	return
    end
    local callfunc = cc.CallFunc:create(function()
    	i = i+1
        local uid = tonumber(grabBankerArray[i%grabBankerCount+1])
        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        local callfunc1 = cc.CallFunc:create(function ()
            PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(playerType), true)
            SoundUtils:playEffect(8)
        end)
        local callfunc2 = cc.CallFunc:create(function ()
            PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(playerType), false)
        end)

        local seq = cc.Sequence:create(callfunc1, cc.DelayTime:create(actiontime), callfunc2)
        SCENENOW["scene"]:runAction(seq)
        if i == count then
        	SCENENOW["scene"]:stopAllActions()
        	 -- 定庄
			self:showBankerAni(actiontime)
        	return
        end
    end)
    local seqAc = cc.Sequence:create(callfunc, cc.DelayTime:create(actiontime))

    SCENENOW["scene"]:runAction(cc.RepeatForever:create(seqAc))
   	
end

function GamePlaneOperator:showBankerAni(timout)
	-- body
	-- 定庄动画
	local playerType = PAIJIU_PLAYERTYPE_TABLE[BANKER_UID]
	self:showHeadSymbol(playerType, "banker", true)
	-- for k,userInfo in pairs(PAIJIU_USERINFO_TABLE) do
    --     local uid = userInfo.uid
    --     if uid ~= uid then
    --         local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
    --         GamePlaneOperator:setBetTimes(playerType,true, 0)
    --     end
	-- end
	
	for k,userInfo in pairs(PAIJIU_USERINFO_TABLE) do
        local uid = userInfo.uid
        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
		PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(playerType), false)
	end
end

function GamePlaneOperator:showBankerFrame(playerType, flag)
    PlayerPlaneOperator:showBankerFrame(self:getPlayerPlane(playerType), flag)
end

-- 开牌动画
function GamePlaneOperator:showAni4Big(playerType, cardsGroup)
    PlayerPlaneOperator:showAni4Big(playerType, self:getPlayerPlane(playerType), cardsGroup)
end


function GamePlaneOperator:showOpenAllCardsAni(firstAction, secondAction)
	if #secondAction > 0 then
        if #firstAction > 0 then
            self:runResultAction(firstAction, "right")
            return
        end
        if #secondAction > 0 then
            self:runResultAction(secondAction, "left")
            return
        end
    else
        if #firstAction > 0 then
            self:runResultAction(firstAction, "mid")
            return
        end
    end
end


function GamePlaneOperator:runResultAction(actionTab, tag)
	-- tag：大牌九：left-左侧两张，right-右侧两张,
	-- tag: 小牌九：mid


	local item = actionTab[1]
	local uid = item.uid
	local playerType = item.playerType
	local cards = item.cards
	local cardType = item.type
	local str_cardType = item.cardType
	
	if uid ~= USER_INFO["uid"] then
		-- 展示牌值
		PlayerPlaneOperator:showCardsInResult(cards, self:getPlayerPlane(playerType), tag)
	end
	-- 展示牌型
	----------------添加一个参数 cards-------------------------------
	self:showCardsType(playerType, cardType, tag, cards)
	-- 播放牌型声效
	----------------添加一个参数 cards-------------------------------
	SoundUtils:playCardKindEffect(uid, str_cardType, cardType, cards)
	dump(cards,"991")

	table.remove(actionTab, 1)
end

----------------添加一个参数 cards-------------------------------
function GamePlaneOperator:showCardsType(playerType, _type, tag, cards)

    PlayerPlaneOperator:showCardsType(self:getPlayerPlane(playerType), _type, tag, cards)

end

function GamePlaneOperator:showIpCheck(isShow)
    ControlPlaneOperator:showIpCheck(isShow)
end

function GamePlaneOperator:initCallTimesPanel()
	-- body
	ControlPlaneOperator:initCallTimesPanel()
end

function GamePlaneOperator:showPromptCards(playerType)
	PlayerPlaneOperator:showPromptCards(self:getPlayerPlane(playerType))
end


function GamePlaneOperator:showTestCards(cards)
	PlayerPlaneOperator:showTestCards(cards)
end

function GamePlaneOperator:showend(playerType,chip)
	PlayerPlaneOperator:showend(self:getPlayerPlane(playerType),chip)
end

function GamePlaneOperator:showchip()
	for i=1,4 do
		PlayerPlaneOperator:showchip(self:getPlayerPlane(i),false)
	end
end

function GamePlaneOperator:deletechip(playerType,chips,pos)
    local panel=self:getPlayerPlane(playerType)
    if panel then
        PlayerPlaneOperator:deletechip(panel,chips,pos)
    end
end

function GamePlaneOperator:getUidBySeatId(seatId)
	for uid,seat in pairs(PAIJIU_SEAT_TABLE) do
		if seat == seatId then
			return uid
		end
	end
end

return  GamePlaneOperator