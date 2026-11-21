local Card = require(TpackageName..".card.card")
local playerPlaneOperator = require(TpackageName..".operator.PlayerPlaneOperator")
local CenterPlaneOperator = require(TpackageName..".operator.CenterPlaneOperator")
local CardBackMgr = require(TpackageName .. ".2DMahjongCard.CardBackMgr")
local GamePlaneOperator = class("GamePlaneOperator")

function GamePlaneOperator:init()
	HZMJ_REMAIN_CARDS_COUNT = HZMJ_CARDS_LESS_INIT
	-- playerPlaneOperator:initUI(HZMJ_SCENE)
	playerPlaneOperator:init(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:init(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))
	CardBackMgr:setScene( HZMJ_SCENE )
	CardBackMgr:clearGameNodes()
	self:clearAllReadyStatus()
	local centerPlane = HZMJ_SCENE.players:getChildByName("center_plane")
	CenterPlaneOperator:init(centerPlane)

	local myPlane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
	myPlane.noScale = true
	-- myPlane:onClick(function()
	-- 	end)

	HZMJ_CARD_POINTER = HZMJ_SCENE.players:getChildByName("card_pointer")
	HZMJ_CARD_POINTER:setVisible(false)
	HZMJ_SCENE.hall.remain_card_lb:setString("")
    HZMJ_SCENE.zhama_vw:hide()

end

function GamePlaneOperator:showCenterPlane()
	local centerPlane = HZMJ_SCENE.players:getChildByName("center_plane")
	if HZMJ_GAME_STATUS == 1 or HZMJ_GAME_STATUS == 3 then
		centerPlane:setVisible(true)
	end
end

function GamePlaneOperator:initUI_CardBackMgr(data, shaizi)
	CardBackMgr:initUI(data, shaizi)
end

function GamePlaneOperator:clearGameDatas()
	HZMJ_REMAIN_CARDS_COUNT = HZMJ_CARDS_LESS_INIT

	HZMJ_CURRENT_CARDNODE = nil

	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = HZMJ_SCENE.players:getChildByName("center_plane")
	CenterPlaneOperator:clearGameDatas(centerPlane)



	HZMJ_CARD_POINTER:setPosition(cc.p(-20, -20))

	-- local scheduler = cc.Director:getInstance():getScheduler()

	-- if schedulerID then
	-- 	--todo
	-- 	scheduler:unscheduleScriptEntry(schedulerID)
	-- 	schedulerID = nil
	-- end
end

function GamePlaneOperator:reSetPlayerPlane()
    self:clearAllReadyStatus()
    playerPlaneOperator:init(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
    playerPlaneOperator:init(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
    playerPlaneOperator:init(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
    playerPlaneOperator:init(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

end

function GamePlaneOperator:removePlayer(playerType, flag)
    dump("----------- removePlayer ---------------")
    playerPlaneOperator:init(playerType, self:getPlayerPlane(playerType), flag)
    self:setReadyStatus(playerType, false)
end


--[[function GamePlaneOperator:removePlayer(playerType)
	playerPlaneOperator:clearGameDatas(playerType, self:getPlayerPlane(playerType))
end--]]

function GamePlaneOperator:getPlayerPlane(playerType)
	local plane
	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		plane = HZMJ_SCENE.players:getChildByName("my_card_plane")
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		plane = HZMJ_SCENE.players:getChildByName("left_card_plane")
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		plane = HZMJ_SCENE.players:getChildByName("right_card_plane")
	elseif playerType == CARD_PLAYERTYPE_TOP then
		plane = HZMJ_SCENE.players:getChildByName("top_card_plane")
	end

	-- --dump(plane, "plane test")
	return plane
end

function GamePlaneOperator:playCard(playerType, tag, value)
	playerPlaneOperator:playCard(playerType, self:getPlayerPlane(playerType), tag, value)
end

function GamePlaneOperator:control(playerType, progCards, controlType, tingSeq,removeCards,fromplayerType,reloginFlage)

	HZMJ_CARD_POINTER:stopAllActions()
	HZMJ_CARD_POINTER:setVisible(false)

	HZMJ_CURRENT_CARDNODE = nil

	playerPlaneOperator:control(playerType, self:getPlayerPlane(playerType), progCards,controlType,tingSeq,removeCards,fromplayerType,reloginFlage)
	self:beginPlayCard(playerType)
end

function GamePlaneOperator:showPlayerInfo(playerType, userInfo)
	return playerPlaneOperator:showPlayerInfo(userInfo, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showZhuang(playerType)
	playerPlaneOperator:showZhuang(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showCards(playerType,tingSeq)
	playerPlaneOperator:showCards(playerType, self:getPlayerPlane(playerType),tingSeq)
end
function GamePlaneOperator:redrawGameInfoForOperate(playerType, data,curGradCard)
	playerPlaneOperator:redrawGameInfoForOperate(playerType, self:getPlayerPlane(playerType), data,curGradCard)
	if curGradCard > 0 then
		self:beginPlayCard(playerType)
	end
end

function GamePlaneOperator:getNewCard(playerType, value, tingSeq)
	playerPlaneOperator:getNewCard(playerType, self:getPlayerPlane(playerType), value,tingSeq)
	-- playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	self:beginPlayCard(playerType)
end

function GamePlaneOperator:showControlPlane(controlTable)
	HZMJ_CONTROL_TABLE = controlTable

	local controlType = controlTable["type"]

	if controlType == CONTROL_TYPE_NONE then
		--todo
		return
	end

	playerPlaneOperator:showControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), controlType)
end

function GamePlaneOperator:hideControlPlane()
	playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:showRemainCardsCount()

	local round = HZMJ_ROUND or 0
	local tround = HZMJ_TOTAL_ROUNDS or 0
	HZMJ_SCENE.hall.round_lb:setString(round.."/"..tround.."局")

	local cont = HZMJ_REMAIN_CARDS_COUNT or 1
	HZMJ_SCENE.hall.remain_card_lb:setString("剩余："..cont.."张")

	CardBackMgr:removeTableCrad(cont)
end

function GamePlaneOperator:beginPlayCard(playerType)
	local centerPlane = HZMJ_SCENE.players:getChildByName("center_plane")

	if centerPlane then
		--todo
		CenterPlaneOperator:beginPlayCard(playerType, centerPlane)
	end

    for playerType = 1,4 do
    	playerPlaneOperator:beginPlayCard(self:getPlayerPlane(playerType),false)
    end

	playerPlaneOperator:beginPlayCard(self:getPlayerPlane(playerType),true)
end

function GamePlaneOperator:redrawGameInfo(playerType, data)
	playerPlaneOperator:redrawGameInfo(playerType, self:getPlayerPlane(playerType), data)
end

function GamePlaneOperator:showTingCards(tingSeq)
	playerPlaneOperator:showTingCards(self:getPlayerPlane(CARD_PLAYERTYPE_MY), tingSeq)
end

function GamePlaneOperator:removeLatestOutCard(playerType, card)
	return playerPlaneOperator:removeLatestOutCard(self:getPlayerPlane(playerType), card)
end

function GamePlaneOperator:didSelectOutCard(card)
	playerPlaneOperator:didSelectOutCard(self:getPlayerPlane(CARD_PLAYERTYPE_MY), card)
end

function GamePlaneOperator:showHupai_vw(card)
	playerPlaneOperator:showHupai_vw(card)
end

function GamePlaneOperator:setTingNodeVisible(flag)
	playerPlaneOperator:setTingNodeVisible(flag)
end

function GamePlaneOperator:showLgSelectBox(lgCards)
	playerPlaneOperator:showLgSelectBox(self:getPlayerPlane(CARD_PLAYERTYPE_MY), lgCards)
end

function GamePlaneOperator:showTingHuPlane(playerType, tingHuCards)
	playerPlaneOperator:showTingHuPlane(self:getPlayerPlane(playerType), tingHuCards)
end

function GamePlaneOperator:hideTingHuPlane()
	playerPlaneOperator:hideTingHuPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:showCardsForHu(playerType, cardDatas,hucard)
	playerPlaneOperator:showCardsForHu(playerType, self:getPlayerPlane(playerType), cardDatas,hucard)
end

function GamePlaneOperator:getHeadNode(playerType)
	return playerPlaneOperator:getHeadNode(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showNetworkImg(playerType, flag)
	playerPlaneOperator:showNetworkImg(self:getPlayerPlane(playerType), flag)
end

function GamePlaneOperator:showJiapiaoPlane(flag)
	playerPlaneOperator:showJiapiaoPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), flag)
end

function GamePlaneOperator:showPiaoImg(playerType, piao, flag)
	playerPlaneOperator:showPiaoImg(self:getPlayerPlane(playerType), piao, flag)
end

function GamePlaneOperator:showPiaoPlane(playerType, piao, flag)
	playerPlaneOperator:showPiaoPlane(self:getPlayerPlane(playerType), piao, flag)
end

function GamePlaneOperator:clearPiaoImg()
	self:showPiaoImg(CARD_PLAYERTYPE_MY, 0, false)
	self:showPiaoImg(CARD_PLAYERTYPE_LEFT, 0, false)
	self:showPiaoImg(CARD_PLAYERTYPE_RIGHT, 0, false)
	self:showPiaoImg(CARD_PLAYERTYPE_TOP, 0, false)
end

function GamePlaneOperator:HuiPai(playerType,huipai)
	playerPlaneOperator:HuiPai(self:getPlayerPlane(playerType),huipai)
end

--旋转中央方向指示器
function GamePlaneOperator:rotateTimer(zhuang_index)
	local centerPlane = HZMJ_SCENE.players:getChildByName("center_plane")
	CenterPlaneOperator:rotateTimer(zhuang_index,centerPlane)
end
--[[
	@brief:设置玩家准备状态
	@param:_playerType 座位id
	@author:Jhao.
]]
function GamePlaneOperator:setReadyStatus(playerType, flag)
	local panel = self:getPlayerPlane(playerType)
	if panel == nil then return end

	local ready_img = panel:getChildByName("ready_bar")
	if ready_img ~= nil then
        if flag ~= nil then
            ready_img:setVisible(flag)
        else
		  ready_img:setVisible(true)
        end
	end
	-- --dump(playerType,"看看是否执行到这了")
end

--[[
	@brief:清除所有玩家的准备状态
	@author:Jhao.
]]
function GamePlaneOperator:clearAllReadyStatus()
	local tbPlayerType = {CARD_PLAYERTYPE_MY,
							CARD_PLAYERTYPE_LEFT,
							CARD_PLAYERTYPE_RIGHT,
							CARD_PLAYERTYPE_TOP,}

	for key, playerType in pairs(tbPlayerType) do
		local panel = self:getPlayerPlane(playerType)
		local ready_img = panel:getChildByName("ready_bar")
		if ready_img ~= nil then ready_img:setVisible(false) end
	end
end

--显示与点击的牌相同的已出的牌
function GamePlaneOperator:showSameCard(value)
    for playerType = 1,4 do
    	playerPlaneOperator:showSameCard(self:getPlayerPlane(playerType),value)
    end
end

function GamePlaneOperator:hideSameCard()
    playerPlaneOperator:hideSameCard()
end


function GamePlaneOperator:putCard()
    playerPlaneOperator:putCard()
end


function GamePlaneOperator:showDistance(LocaArrayByPlayerType,flag)


    local function getDistance(latitude,longitude,b_latitude,b_longitude,lb)
       if  (latitude == 0 or latitude == nil) or (b_latitude == 0 or b_latitude == nil)  then   --距离数据不存在
           lb:setString("距离未知")
       else
            local s = require("hall.util.LocationUtil"):getDistance(latitude, longitude, b_latitude, b_longitude)
            if s >= 0 then

                if s < 1000 then
                    lb:setString(tostring(s) .. "米")
                else
                    s = s / 1000
                    s = math.floor(s)
                    lb:setString(tostring(s) .. "公里")
                end
            end
       end
    end

    local distance = (HZMJ_SCENE.players:getChildByName("my_card_plane")):getChildByName("distance")
    local left_top_lb = distance:getChildByName("left_top_lb")
    local left_right_lb = distance:getChildByName("left_right_lb")
    local right_top_lb = distance:getChildByName("right_top_lb")

    local flag = flag or false
    distance:setVisible(flag)
    distance:performWithDelay(function() distance:setVisible(false) end,3)

   local  left = LocaArrayByPlayerType[2] or {0,0}
   local  right = LocaArrayByPlayerType[3] or {0,0}
   local  top =  LocaArrayByPlayerType[4] or {0,0}

    if HZ_PLAYER_COUNT == 4 then

       -- [1]是longitude,[2]是latitude
       local left_right_txt = getDistance(left[2],  left[1],  right[2], right[1],  left_right_lb)
       local left_top_txt   = getDistance(left[2],  left[1],  top[2],   top[1],    left_top_lb)
       local right_top_txt  = getDistance(right[2], right[1], top[2],   top[1],    right_top_lb)

    elseif  HZ_PLAYER_COUNT == 3 then

       local left_right_txt = getDistance(left[2],  left[1],  right[2], right[1],  left_right_lb)

    end
end

function GamePlaneOperator:showDistanceAgain()
	local distance = (HZMJ_SCENE.players:getChildByName("my_card_plane")):getChildByName("distance")
	distance:setVisible(true)
    distance:performWithDelay(function() distance:setVisible(false) end,3)
end

function GamePlaneOperator:updateRoundResult(playerType, changeCoins)
    playerPlaneOperator:updateRoundResult(self:getPlayerPlane(playerType), changeCoins)
end

function GamePlaneOperator:updateUserCoins(playerType, coins)
	playerPlaneOperator:updateUserCoins(self:getPlayerPlane(playerType), coins)
end

function GamePlaneOperator:showTaiFeiTxt(changeCoins)
	if changeCoins == 0 or changeCoins == nil then
		return
	end

	local change_chip_text = cc.Label:createWithTTF("扣除台费"..changeCoins, TpackageName.."/res/fonts/systemFont.TTF", 30)
	change_chip_text:setColor(cc.c3b(125, 125, 125))
	change_chip_text:setPosition(cc.p(640,220))
    HZMJ_SCENE.players:addChild(change_chip_text, 999)
	local func = cc.CallFunc:create(function ()
		change_chip_text:removeSelf()
	end)
	local seq = cc.Sequence:create(cc.FadeIn:create(0.2),cc.DelayTime:create(0.2), cc.FadeOut:create(0.2), cc.DelayTime:create(0.2), func)
	change_chip_text:runAction(seq)

end

function GamePlaneOperator:setDianNodeBytingpai()
	playerPlaneOperator:setDianNodeBytingpai(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:hideDianNodeBytingpai()
	playerPlaneOperator:hideDianNodeBytingpai(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:setAndShow_zhama_vw(cards)
	if #cards <= 0 then
		return 0
	end
	table.sort(cards, function(a,b)
        return a.card < b.card
    end)
    local zhama_vw = HZMJ_SCENE.zhama_vw
    local cards_vw = zhama_vw.cards_vw
    zhama_vw:show()
	cards_vw:removeAllChildren()
	local Card = require(TpackageName .. ".2DMahjongCard.Card")
    local card = Card:setMyInHandCardBack()
    local size = cards_vw:getContentSize()
    local scale = 1
    local pool_col_space = 8
    local number_2 = #cards
    local cardHeight = card:getSize().height * scale
    local cardWidth = card:getSize().width * scale + pool_col_space
    local oriX = (size.width - number_2 * cardWidth) / 2 + cardWidth / 2
    local oriY = size.height / 2
    for idx,card in ipairs(cards) do
        local node = Card:setMyInHandCardBack()
        local x = oriX + ((idx - 1) * cardWidth)
        node:setPosition(cc.p(x, oriY))
        cards_vw:addChild(node)
    end
    local time = 0.5
    local inittime = 0.5
    local chids = cards_vw:getChildren()
    cards_vw:stopAllActions()
    for idx,cardtal in ipairs(cards) do
        time = inittime * idx
        cards_vw:performWithDelay(function()
            local node = chids[idx]
            node:setMyInHandCard(cardtal.card)
            if cardtal.position == 1 then
                node:setZhongMaAnima()
            end
        end, time)
    end
    time = time + inittime

    cards_vw:performWithDelay(function()
        zhama_vw:hide()
	end, time)
	return time
end


function GamePlaneOperator:showJiapiaoPlane(flag)
	playerPlaneOperator:showJiapiaoPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), flag)
end

function GamePlaneOperator:showPiaoImg(playerType, piao, flag)
	playerPlaneOperator:showPiaoImg(self:getPlayerPlane(playerType), piao, flag)
end

function GamePlaneOperator:showPiaoPlane(playerType, piao, flag)
	playerPlaneOperator:showPiaoPlane(self:getPlayerPlane(playerType), piao, flag)
end

function GamePlaneOperator:clearGameTableCards()
	CardBackMgr:clearGameNodes()
end

return GamePlaneOperator
