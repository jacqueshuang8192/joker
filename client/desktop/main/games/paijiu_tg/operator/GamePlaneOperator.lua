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

function GamePlaneOperator:showSitDownButton(flag)
    ControlPlaneOperator:showSitDownButton(flag)
end

function GamePlaneOperator:showCheckResultButton(flag)
	ControlPlaneOperator:showCheckResultButton(flag)
end

--------------------------------------------------桌面---------------------------------------------
function GamePlaneOperator:showRandomBankerChoose(grabBankerCount, grabBankerArray)
	TablePlaneOperator:showRandomBankerChoose(grabBankerCount, grabBankerArray)
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

function GamePlaneOperator:updateCoin(playerType, value, orichip,uid)
	PlayerPlaneOperator:updateCoin(self:getPlayerPlane(playerType), value, orichip,uid)
end


function GamePlaneOperator:setCoin(playerType,value)
	PlayerPlaneOperator:setCoin(self:getPlayerPlane(playerType),value)
end

-----------------------------------------------手牌相关--------------------------------------------
function GamePlaneOperator:showCards(playerType,cards,flag)
	PlayerPlaneOperator:showCards(playerType,self:getPlayerPlane(playerType),cards,flag)
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

function GamePlaneOperator:initPlayerDaoPanel()
    for playerType=1, TOTAL_PLAYERNUM do
        PlayerPlaneOperator:initDaoPanel(self:getPlayerPlane(playerType), 0)
    end
end

function GamePlaneOperator:showPlayerDaoPanel(playerType, flag)
    PlayerPlaneOperator:showDaoPanel(self:getPlayerPlane(playerType), flag)
end

function GamePlaneOperator:setDao(playerType, order, value,pos)
    PlayerPlaneOperator:setDao(self:getPlayerPlane(playerType), order, value,pos)
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


function GamePlaneOperator:showShiziAnimotion(shaiziCount, shaiziArray, shaiziTimeOut)
    TablePlaneOperator:showShiziAnimotion(shaiziCount, shaiziArray, shaiziTimeOut)
end

function GamePlaneOperator:showCardsOnResultCsb(playerType, panel, cardGroups)
    PlayerPlaneOperator:showCardsOnResultCsb(playerType, panel, cardGroups)
end

function GamePlaneOperator:showGrabBankerAnim(grabBankerCount, grabBankerArray, grabBankerTimeOut)
    dump("showGrabBankerAnim -- start --")
    -- 抢庄动画
    local i = 0
    local actiontime = 0.2
    local count = grabBankerTimeOut/actiontime
    --[[    if next(grabBankerArray) == nil then
            self:showBankerAni(grabBankerTimeOut)
            return
        end--]]
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
            --SoundUtils:playEffect(8)
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

    dump("showGrabBankerAnim -- end --")
end

function GamePlaneOperator:showBankerAni(timout)
    -- body
    -- 定庄动画
    local playerType = PAIJIU_PLAYERTYPE_TABLE[BANKER_UID]
    for _, user_playerType in pairs(PAIJIU_PLAYERTYPE_TABLE) do
        PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(user_playerType), false)
    end
    PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(playerType), true)
	SoundUtils:playEffect("定庄特效")

    self:showHeadSymbol(playerType, "banker", true)
end

function GamePlaneOperator:showBankerFrame(playerType, flag)
    PlayerPlaneOperator:showBankerFrame(self:getPlayerPlane(playerType), flag)
end

-- 大牌九开牌动画
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
    self:showCardsType(playerType, cardType, tag, cards)
    -- 播放牌型声效
    SoundUtils:playCardKindEffect(uid, str_cardType)
    table.remove(actionTab, 1)
end

function GamePlaneOperator:showCardsType(playerType, _type, tag, cards)
    PlayerPlaneOperator:showCardsType(self:getPlayerPlane(playerType), _type, tag, cards)

end

function GamePlaneOperator:showIpCheck(isShow)
    ControlPlaneOperator:showIpCheck(isShow)
end

function GamePlaneOperator:showGuoChoosePanel(isShow, _type)
    -- type:
    -- 0：切锅与续锅
    -- 1：切锅与不切
    ControlPlaneOperator:showGuoChoosePanel(isShow, _type)

end

function GamePlaneOperator:callGuoPanel(is_show, guoBetLimit)
    ControlPlaneOperator:callGuoPanel(is_show, guoBetLimit)
end

function GamePlaneOperator:addGuoNumber(number)
    ControlPlaneOperator:addGuoNumber(number)
end

function GamePlaneOperator:showGuoDi(number)
    ControlPlaneOperator:showGuoDi(number)
end

function GamePlaneOperator:showGrabBankerAnim(grabBankerCount, grabBankerArray, grabBankerTimeOut)
    dump("showGrabBankerAnim -- start --")
    -- 抢庄动画
    local i = 0
    local actiontime = 0.15
    local count = grabBankerTimeOut/actiontime
    if grabBankerCount == 0 or grabBankerCount == 1 then
        self:showBankerAni(grabBankerTimeOut)
        return
    end
    local callfunc = cc.CallFunc:create(function()
        dump(i%grabBankerCount+1,"201821011111")
        dump(grabBankerArray,"grabBankerArray2018210")
        dump(PAIJIU_PLAYERTYPE_TABLE,"PAIJIU_PLAYERTYPE_TABLE")
        local uid = tonumber(grabBankerArray[i%grabBankerCount+1])

        i = i+1
        local playerType = PAIJIU_PLAYERTYPE_TABLE[uid]
        local callfunc1 = cc.CallFunc:create(function ()
            dump(playerType,"callfunc1_playerType1")
            PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(playerType), true)
            --SoundUtils:playEffect(8)
        end)
        local callfunc2 = cc.CallFunc:create(function ()
            dump(playerType,"callfunc1_playerType2")
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
        --self:runAction(seq)
    end)
    local seqAc = cc.Sequence:create(callfunc, cc.DelayTime:create(actiontime))

    --SCENENOW["scene"]:runAction(cc.RepeatForever:create(seqAc))
    SCENENOW["scene"]:runAction(cc.RepeatForever:create(seqAc))

    --self:runAction(cc.RepeatForever:create(seqAc))
    dump("showGrabBankerAnim -- end --")
end

function GamePlaneOperator:showBankerAni(timout)
    -- body
    -- 定庄动画
    local playerType = PAIJIU_PLAYERTYPE_TABLE[BANKER_UID]
    for _, user_playerType in pairs(PAIJIU_PLAYERTYPE_TABLE) do
        PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(user_playerType), false)
    end
    PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(playerType), true)
    SoundUtils:playEffect("定庄特效")
    self:showHeadSymbol(playerType, "banker", true)

    --[[dump(BANKER_UID, "-------- showBankerAni_BANKER_UID ---------")
    dump(playerType, "-------- showBankerAni_PLAYERTYPE ---------")
    local callfunc = cc.CallFunc:create(function()
        i = i + 1
        local callfunc1 = cc.CallFunc:create(function ()
            PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(playerType), true)
            SoundUtils:playEffect(8)
        end)
        local callfunc2 = cc.CallFunc:create(function ()
            PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(playerType), false)
        end)

        local seq = cc.Sequence:create(callfunc1, cc.DelayTime:create(0.5), callfunc2)
        SCENENOW["scene"]:runAction(seq)
        if i == 3 then
            SCENENOW["scene"]:stopAllActions()
            for _, user_playerType in pairs(PAIJIU_PLAYERTYPE_TABLE) do
                PlayerPlaneOperator:showGrabBankerFrame(self:getPlayerPlane(user_playerType), false)
            end
            self:showHeadSymbol(playerType,"banker", true)
            return
        end
        --self:runAction(seq)
    end)
    local seqAc = cc.Sequence:create(callfunc, cc.DelayTime:create(0.5))

    SCENENOW["scene"]:runAction(cc.RepeatForever:create(seqAc))
    --
    --self:runAction(cc.RepeatForever:create(seqAc))
    dump("showBanker -- end --")--]]
end

function GamePlaneOperator:showPromptCards(playerType)
    PlayerPlaneOperator:showPromptCards(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showBuyCoinBotton(isShow)
    ControlPlaneOperator:showBuyCoinBotton(isShow)
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

function GamePlaneOperator:joinchip(panel,txt_chips)
	PlayerPlaneOperator:joinchip(panel,txt_chips)
end

function GamePlaneOperator:deletechip(playerType,chips,pos)
    local panel=self:getPlayerPlane(playerType)
    if panel then
        PlayerPlaneOperator:deletechip(panel,chips,pos)
    end
end

function GamePlaneOperator:showQieguo()
	ControlPlaneOperator:showQieguo()
end

function GamePlaneOperator:moveGuo(flag)
	ControlPlaneOperator:moveGuo(flag)
end

function GamePlaneOperator:connectClear()
    self:clearGameDatas(2)
    for playerType = 1, MAX_PLAYERNUM do
        PlayerPlaneOperator:relocate(self:getPlayerPlane(playerType))
        self:deletechip(playerType,0)
        self:showPlayerDaoPanel(playerType, false)
        PlayerPlaneOperator:showkaipai(self:getPlayerPlane(playerType),false)
    end
end

function GamePlaneOperator:guoPos()
    if BANKER_UID<1 then
        self:moveGuo(1)
        return
    end
    local plane=self:getPlayerPlane(PAIJIU_PLAYERTYPE_TABLE[BANKER_UID])
    if not plane then
        return
    end
    plane:getChildByName("head_panel"):getChildByName("img_banker"):setVisible(true)
    local chips_panel_pos=plane:convertToWorldSpace(plane:getChildByName("chips_panel"):getPosition())
    chips_panel_pos=(img_guo:getParent()):convertToNodeSpace(chips_panel_pos)
    img_guo:stopAllActions()
    img_guo:setPosition(cc.p(chips_panel_pos.x,chips_panel_pos.y-40))
    GUO_POS=plane:convertToWorldSpace(cc.p(chips_panel_pos.x,chips_panel_pos.y-40))
end

function GamePlaneOperator:showShizi()
    TablePlaneOperator:showShizi()
end

function GamePlaneOperator:joinCards(plane)
    if plane then
        PlayerPlaneOperator:joinCards(self:getPlayerPlane(plane),1)
    else
        for playerType = 1, MAX_PLAYERNUM do
            local plane=self:getPlayerPlane(playerType)
            PlayerPlaneOperator:joinCards(plane)
        end
    end
end

function GamePlaneOperator:setCardRecover()
    PlayerPlaneOperator:setCardRecover()
end

return  GamePlaneOperator