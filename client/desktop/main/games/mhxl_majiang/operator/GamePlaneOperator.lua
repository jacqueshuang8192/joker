local Card = require("mhxl_majiang.card.card")
local playerPlaneOperator = require("mhxl_majiang.operator.PlayerPlaneOperator")
local centerPlaneOperator = require("mhxl_majiang.operator.CenterPlaneOperator")

local GamePlaneOperator = class("GamePlaneOperator")

local CHILD_NAME_MY_PLANE = "my_card_plane"
local CHILD_NAME_LEFT_PLANE = "left_card_plane"
local CHILD_NAME_RIGHT_PLANE = "right_card_plane"
local CHILD_NAME_TOP_PLANE = "top_card_plane"

local CHILD_NAME_CENTER_PLANE = "center_plane"
local CHILD_NAME_CARD_POINTER = "card_pointer"
local CHILD_NAME_CARD_BOX = "card_bx"
local CHILD_NAME_REMAIN_CARDS_COUNT_LB = "remain_cards_count_lb"
local CHILD_NAME_REMARK_LB = "remark_lb"
local CHILD_NAME_READY_IMG = "ready_bar"

local CHILD_NAME_LAIZI_PLANE = "laizi_plane"

local CHILD_NAME_BIXIAHU_LB = "bixiahu_lb"

local CHILD_NAME_GRAB_GANG_CARD_PLANE = "grab_gang_card_plane"
local CHILD_NAME_GRAB_GANG_CARD_TITLE = "title_lb"

local CHILD_NAME_MAI_DIAN_PLANE = "maidian_plane"
local CHILD_NAME_MAI_DIAN_JIAN_BT = "jian_bt"
local CHILD_NAME_MAI_DIAN_JIA_BT = "jia_bt"
local CHILD_NAME_MAI_DIAN_VALUE_LB = "value_lb"
local CHILD_NAME_MAI_DIAN_COMMIT_BT = "commit_bt"

function GamePlaneOperator:init()
	XLMH_REMAIN_CARDS_COUNT = 0

	playerPlaneOperator:init(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:init(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:init(centerPlane)

	local myPlane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
	myPlane.noScale = true
	myPlane:onClick(function()
			playerPlaneOperator:cancelSelectingCard(myPlane)
		end)

	XLMH_CARD_POINTER = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_CARD_POINTER)
	XLMH_CARD_POINTER:setVisible(false)
      
	local remain_cards_count_plane = XLMH_GAME_PLANE:getChildByName("remain_cards_count_plane")
	local remain_cards_count_lb = remain_cards_count_plane:getChildByName("remain_cards_count_lb")

	local remain_rounds_count_plane = XLMH_GAME_PLANE:getChildByName("remain_rounds_count_plane")
	local remain_rounds_count_lb = remain_rounds_count_plane:getChildByName("remain_rounds_count_lb")
 	local total_rounds_count_lb = remain_rounds_count_plane:getChildByName("total_rounds_count_lb")

	remain_cards_count_lb:setString("0")
	remain_rounds_count_lb:setString("0")
    total_rounds_count_lb:setString("0")

	local card_bx = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	local grab_gang_card_plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_GRAB_GANG_CARD_PLANE)
	grab_gang_card_plane:setVisible(false)

	local maidian_plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_MAI_DIAN_PLANE)
	maidian_plane:setVisible(false)

	local remark_lb = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)

	if USER_INFO["gameConfig"] then
		remark_lb:setString(XLMH_PRV_GAME_NAME .. "：" ..USER_INFO["gameConfig"])
	else
		remark_lb:setString("正在读取组局信息")
	end

	local laizi_plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_LAIZI_PLANE)
	if laizi_plane then
		--todo
		laizi_plane:setVisible(false)
	end

	local bixiahu_lb = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_BIXIAHU_LB)
	if bixiahu_lb then
		--todo
		bixiahu_lb:setVisible(false)
	end
end

function GamePlaneOperator:showCenterPlane()
	local centerPlane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlane:setVisible(true)
end

function GamePlaneOperator:clearGameDatas()
	XLMH_REMAIN_CARDS_COUNT = 0

	XLMH_CURRENT_CARDNODE = nil

	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:clearGameDatas(centerPlane)

	local card_bx = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	local grab_gang_card_plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_GRAB_GANG_CARD_PLANE)
	grab_gang_card_plane:setVisible(false)

	local maidian_plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_MAI_DIAN_PLANE)
	maidian_plane:setVisible(false)

	XLMH_CARD_POINTER:setPosition(cc.p(-20, -20))

	local laizi_plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_LAIZI_PLANE)
	if laizi_plane then
		--todo
		laizi_plane:setVisible(false)
	end

	local bixiahu_lb = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_BIXIAHU_LB)
	if bixiahu_lb then
		--todo
		bixiahu_lb:setVisible(false)
	end

	self:hideTingHuPlane()
end

function GamePlaneOperator:removePlayer(playerType)
	playerPlaneOperator:clearGameDatas(playerType, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:IsHidePlayerPlane( playerType,isShow )
	self:getPlayerPlane(playerType):setVisible(isShow)
end

function GamePlaneOperator:getPlayerPlane(playerType)
	local plane
	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_MY_PLANE)
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_LEFT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_RIGHT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_TOP_PLANE)
	end


	return plane
end

function GamePlaneOperator:removeCard_ZIMO_MENHU()
	playerPlaneOperator:removeCard_ZIMO_MENHU(self:getPlayerPlane(1))
end

function GamePlaneOperator:playCard(playerType, tag, value)
	playerPlaneOperator:playCard(playerType, self:getPlayerPlane(playerType), tag, value)
end

function GamePlaneOperator:showImgAnim(playerType,controlType)
	playerPlaneOperator:showImgAnim(self:getPlayerPlane(playerType),controlType)
end

function GamePlaneOperator:control(playerType, progCards, controlType, removeCards, fromplayerType,value)

	XLMH_CARD_POINTER:stopAllActions()
	XLMH_CARD_POINTER:setVisible(false)
    
	XLMH_CURRENT_CARDNODE = nil

	playerPlaneOperator:control(playerType, self:getPlayerPlane(playerType), progCards,controlType,removeCards,fromplayerType,value)

	if bit.band(CONTROL_TYPE_GANG, controlType) > 0 and playerType == CARD_PLAYERTYPE_MY then
        self:showCards(playerType)
	end
	
	self:beginPlayCard(playerType)
end

function GamePlaneOperator:showPlayerInfo(playerType, userInfo)
	return playerPlaneOperator:showPlayerInfo(userInfo, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showZhuang(playerType)
	playerPlaneOperator:showZhuang(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:setMySlefCardIsMenPai(playerType,isMenPai)
	playerPlaneOperator:setMySlefCardIsMenPai(playerType, self:getPlayerPlane(playerType),isMenPai)
end

function GamePlaneOperator:getAllTingCardNode(playerType)
	dump(self:getPlayerPlane(playerType),"==tempNodeCardParents====")
	playerPlaneOperator:getAllTingCardNode(playerType, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showCards(playerType,tingSeq)
	playerPlaneOperator:showCards(playerType, self:getPlayerPlane(playerType),tingSeq)

	local seatId = XLMH_SEAT_TABLE_BY_TYPE[playerType .. ""]
	XLMH_GAMEINFO_TABLE[seatId ..""].isShowCards = false
end

function GamePlaneOperator:getNewCard(playerType, value,tingSeq)
	playerPlaneOperator:getNewCard(playerType, self:getPlayerPlane(playerType), value,tingSeq)
	-- playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	self:beginPlayCard(playerType)
end

function GamePlaneOperator:showControlPlane(controlTable)
	XLMH_CONTROL_TABLE = controlTable
	-- dump(XLMH_CONTROL_TABLE,"=====XLMH_CONTROL_TABLE======")

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
	local remain_cards_count_plane = XLMH_GAME_PLANE:getChildByName("remain_cards_count_plane")
	local remain_cards_count_lb = remain_cards_count_plane:getChildByName("remain_cards_count_lb")


	local remain_rounds_count_plane = XLMH_GAME_PLANE:getChildByName("remain_rounds_count_plane")
	local remain_rounds_count_lb = remain_rounds_count_plane:getChildByName("remain_rounds_count_lb")
 	local total_rounds_count_lb = remain_rounds_count_plane:getChildByName("total_rounds_count_lb")


    local remark_lb = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)
    
	if remain_cards_count_lb then

		local content = XLMH_REMAIN_CARDS_COUNT
		remain_cards_count_lb:setString(content)

		if XLMH_ROUND then

			if USER_INFO["gameConfig"] then
				remark_lb:setString(XLMH_PRV_GAME_NAME .. "：" ..USER_INFO["gameConfig"])
			end	
            remain_rounds_count_lb:setString(XLMH_ROUND+1)
		    total_rounds_count_lb:setString(XLMH_TOTAL_ROUNDS)
		end


	end
end

function GamePlaneOperator:beginPlayCard(playerType)
	local centerPlane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

	if centerPlane then
		--todo
		centerPlaneOperator:beginPlayCard(playerType, centerPlane)
	end
   
    for playerType = 1,4 do 
    	playerPlaneOperator:beginPlayCard(self:getPlayerPlane(playerType),false)
    end

	playerPlaneOperator:beginPlayCard(self:getPlayerPlane(playerType),true)
end

function GamePlaneOperator:redrawGameInfo(playerType, data)
	playerPlaneOperator:redrawGameInfo(playerType, self:getPlayerPlane(playerType), data)
end


function GamePlaneOperator:jiShow(type,card,playerType)
	print("======type,card,playerType=====",type,card,playerType)
	playerPlaneOperator:jiShow(type,card,self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showTingCards(tingSeq)
	playerPlaneOperator:showTingCards(self:getPlayerPlane(CARD_PLAYERTYPE_MY), tingSeq)
end

function GamePlaneOperator:removeLatestOutCard(playerType, card)
	-- SZKWX_CURRENT_CARDNODE:removeFromParent() 
	return playerPlaneOperator:removeLatestOutCard(self:getPlayerPlane(playerType), card)	
end

function GamePlaneOperator:didSelectOutCard(card)
	playerPlaneOperator:didSelectOutCard(self:getPlayerPlane(CARD_PLAYERTYPE_MY), card)
end

function GamePlaneOperator:showLgSelectBox(lgCards)
	playerPlaneOperator:showLgSelectBox(self:getPlayerPlane(CARD_PLAYERTYPE_MY), lgCards)
end

function GamePlaneOperator:showTingHuPlane(playerType, tingHuCards)
	playerPlaneOperator:showTingHuPlane(playerType, self:getPlayerPlane(playerType), tingHuCards)
end

function GamePlaneOperator:hideTingHuPlane()
	playerPlaneOperator:hideTingHuPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:showCardsForHu(playerType, cardDatas, huCard)
	playerPlaneOperator:showCardsForHu(playerType, self:getPlayerPlane(playerType), cardDatas, huCard)

	local seatId = XLMH_SEAT_TABLE_BY_TYPE[playerType .. ""]
	XLMH_GAMEINFO_TABLE[seatId ..""].isShowCards = true
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
local centerPlane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

	centerPlaneOperator:rotateTimer(zhuang_index,centerPlane)
end
--[[
	@brief:设置玩家准备状态
	@param:_playerType 座位id
	@author:Jhao.
]]
function GamePlaneOperator:setReadyStatus(playerType)
	local panel = self:getPlayerPlane(playerType)
	if panel == nil then return end

	local ready_img = panel:getChildByName(CHILD_NAME_READY_IMG)
	if ready_img ~= nil then 
		ready_img:setVisible(true)	 
	end

	--将冲锋鸡、责任鸡这些
	playerPlaneOperator:hideJiImg(panel)

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
		local ready_img = panel:getChildByName(CHILD_NAME_READY_IMG)
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
  
   local  distance_bt = XLMH_GAME_PLANE:getParent():getChildByName("menu_ly"):getChildByName("menu_plane"):getChildByName("distance_bt")
   distance_bt:setVisible(true)
   distance_bt:addTouchEventListener(
    function(sender,event)
        --触摸开始
        if event == TOUCH_EVENT_ENDED then
            self:showDistanceAgain()
        end
        
    end
    )

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

    local distance = (XLMH_GAME_PLANE:getChildByName("my_card_plane")):getChildByName("distance")
    local left_top_lb = distance:getChildByName("left_top_lb")
    local left_right_lb = distance:getChildByName("left_right_lb")
    local right_top_lb = distance:getChildByName("right_top_lb")
    
    local flag = flag or false
    distance:setVisible(flag)
    distance:performWithDelay(function() distance:setVisible(false) end,3)

   local  left = LocaArrayByPlayerType[2] or {0,0}
   local  right = LocaArrayByPlayerType[3] or {0,0}
   local  top =  LocaArrayByPlayerType[4] or {0,0}

    if PLAYERNUM == 4 then 
        
       -- [1]是longitude,[2]是latitude
       local left_right_txt = getDistance(left[2],  left[1],  right[2], right[1],  left_right_lb)
       local left_top_txt   = getDistance(left[2],  left[1],  top[2],   top[1],    left_top_lb)
       local right_top_txt  = getDistance(right[2], right[1], top[2],   top[1],    right_top_lb)

    elseif  PLAYERNUM == 3 then 

       local left_right_txt = getDistance(left[2],  left[1],  right[2], right[1],  left_right_lb)

    end
end

function GamePlaneOperator:showDistanceAgain()
	local distance = (XLMH_GAME_PLANE:getChildByName("my_card_plane")):getChildByName("distance")
	distance:setVisible(true)
    distance:performWithDelay(function() distance:setVisible(false) end,3)
end

function GamePlaneOperator:showCardsForQiShouHu(playerType, cardDatas, _liangCards)
	playerPlaneOperator:showCardsForQiShouHu(playerType, self:getPlayerPlane(playerType), cardDatas, _liangCards)

	local seatId = XLMH_SEAT_TABLE_BY_TYPE[playerType .. ""]
	XLMH_GAMEINFO_TABLE[seatId ..""].isShowCards = true
end

function GamePlaneOperator:kaigang(card1, card2)
	local plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_KAIGANG_PLANE)

	if plane then
		--todo
		plane:removeAllChildren()

		plane:setVisible(true)

		local n1 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, card1)
		local n2 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, card2)

		local scale = (plane:getContentSize().height - 20) / (n1:getContentSize().height)

		n1:setScale(scale)
		n2:setScale(scale)

		local oriX = 30

		plane:addChild(n1)
		plane:addChild(n2)

		n1:setPosition(cc.p(oriX + n1:getContentSize().width * scale / 2, n1:getContentSize().height * scale / 2))

		oriX = oriX + n1:getContentSize().width * scale + 10

		n2:setPosition(cc.p(oriX + n2:getContentSize().width * scale / 2, n2:getContentSize().height * scale / 2))

		oriX = oriX + n2:getContentSize().width * scale + 30

		plane:setSize(cc.size(oriX, plane:getSize().height))

		local seqAc = cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
				plane:setVisible(false)
			end))

		plane:runAction(seqAc)
	end
end

function GamePlaneOperator:showLaiziPlane(fanCard, laiziCard)
	if fanCard == 0 then
		return
	end
	local plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_LAIZI_PLANE)

	if plane then
		--todo
		plane:removeAllChildren()

		plane:setVisible(true)

		-- local n1 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, fanCard)
		local n2 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, laiziCard)

		local scale = (plane:getContentSize().height - 10) / (n2:getContentSize().height)

		-- n1:setScale(scale)
		n2:setScale(scale)

		local oriX = 10

		-- plane:addChild(n1)
		plane:addChild(n2)

		-- n1:setPosition(cc.p(oriX + n1:getContentSize().width * scale / 2, plane:getSize().height / 2))

		-- oriX = oriX + n1:getContentSize().width * scale + 10

		n2:setPosition(cc.p(oriX + n2:getContentSize().width * scale / 2, plane:getSize().height / 2))

		oriX = oriX + n2:getContentSize().width * scale + 10

		plane:setSize(cc.size(oriX, plane:getSize().height))
	end
end

function GamePlaneOperator:buHua(playerType)
    playerPlaneOperator:buHua(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:playHuaCard(playerType,value)
	playerPlaneOperator:playHuaCard(playerType,self:getPlayerPlane(playerType),value)
end

function GamePlaneOperator:changeCoin(playerType, value)
	playerPlaneOperator:changeCoin(self:getPlayerPlane(playerType), value)
end

function GamePlaneOperator:showBixiahu(isShow)
	-- body
	local bixiahu_lb = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_BIXIAHU_LB)
	if bixiahu_lb then
		--todo
		bixiahu_lb:setVisible(isShow)
	end
end

function GamePlaneOperator:showChutong(playerType, card)
	playerPlaneOperator:showChutong(self:getPlayerPlane(playerType), card)
end

function GamePlaneOperator:showGrabGangCardPlane(card1, card2)
	if card1 == 0 and card2 == 0 then
		--todo
		return
	end

	local grab_gang_card_plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_GRAB_GANG_CARD_PLANE)

	if not grab_gang_card_plane then
		--todo
		return
	end

	local cardNode = grab_gang_card_plane:getChildByTag(1)
	if cardNode then
		--todo
		cardNode:removeFromParent()
	end
	cardNode = grab_gang_card_plane:getChildByTag(2)
	if cardNode then
		--todo
		cardNode:removeFromParent()
	end

	local bt_callback = function(sender, event)
		if event == TOUCH_EVENT_ENDED then
			grab_gang_card_plane:setVisible(false)
			XLMH_CONTROLLER:sendGrabGangCard(sender.m_value)
		end
	end

	grab_gang_card_plane:setVisible(true)

	local title_lb = grab_gang_card_plane:getChildByName(CHILD_NAME_GRAB_GANG_CARD_TITLE)

	local cardHeight = title_lb:getPosition().y - title_lb:getSize().height / 2 - 10 - 10

	local oriX = 20

	if card1 > 0 then
		--todo
		local n1 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, card1)

		local scale = cardHeight / n1:getSize().height

		n1:setScale(scale)

		n1:setTag(1)

		n1:setPosition(cc.p(oriX + n1:getSize().width * scale / 2, 10 + cardHeight / 2))

		grab_gang_card_plane:addChild(n1)

		oriX = oriX + n1:getSize().width * scale + 20

		n1:addTouchEventListener(bt_callback)
	end

	if card2 > 0 then
		--todo
		local n2 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, card2)

		local scale = cardHeight / n2:getSize().height

		n2:setScale(scale)

		n2:setTag(2)

		n2:setPosition(cc.p(oriX + n2:getSize().width * scale / 2, 10 + cardHeight / 2))

		grab_gang_card_plane:addChild(n2)

		oriX = oriX + n2:getSize().width * scale + 20

		n2:addTouchEventListener(bt_callback)
	end

	grab_gang_card_plane:setSize(cc.size(oriX, grab_gang_card_plane:getSize().height))
	title_lb:setPosition(cc.p(oriX / 2, title_lb:getPosition().y))
end

function GamePlaneOperator:showGangCardPlane(card1, card2, card3)
	if card1 == 0 and card2 == 0 then
		--todo
		return
	end

	local plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_LAIZI_PLANE)

	if plane then
		--todo
		plane:removeAllChildren()

		plane:setVisible(true)

		local oriX = 10

		if card3 > 0 then
			--todo
			local n3 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, card3)

			local scale = (plane:getContentSize().height - 10) / (n3:getContentSize().height)

			n3:setScale(scale)

			n3:setColor(cc.c3b(180, 180, 180))

			plane:addChild(n3)

			n3:setPosition(cc.p(oriX + n3:getContentSize().width * scale / 2, plane:getSize().height / 2))

			oriX = oriX + n3:getContentSize().width * scale + 10
		end
		
		if card1 > 0 then
			--todo
			local n1 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, card1)

			local scale = (plane:getContentSize().height - 10) / (n1:getContentSize().height)

			n1:setScale(scale)

			plane:addChild(n1)

			n1:setPosition(cc.p(oriX + n1:getContentSize().width * scale / 2, plane:getSize().height / 2))

			oriX = oriX + n1:getContentSize().width * scale + 10
		end
		
		if card2 > 0 then
			--todo
			local n2 = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, card2)

			local scale = (plane:getContentSize().height - 10) / (n2:getContentSize().height)

			n2:setScale(scale)

			plane:addChild(n2)

			n2:setPosition(cc.p(oriX + n2:getContentSize().width * scale / 2, plane:getSize().height / 2))

			oriX = oriX + n2:getContentSize().width * scale + 10
		end

		plane:setSize(cc.size(oriX, plane:getSize().height))
	end
end

function GamePlaneOperator:showMaidianPlane()
	local maidian_plane = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_MAI_DIAN_PLANE)

	if not maidian_plane then
		--todo
		return
	end

	maidian_plane:setVisible(true)

	local value = 5

	local value_lb = maidian_plane:getChildByName(CHILD_NAME_MAI_DIAN_VALUE_LB)
	local jian_bt = maidian_plane:getChildByName(CHILD_NAME_MAI_DIAN_JIAN_BT)
	local jia_bt = maidian_plane:getChildByName(CHILD_NAME_MAI_DIAN_JIA_BT)
	local commit_bt = maidian_plane:getChildByName(CHILD_NAME_MAI_DIAN_COMMIT_BT)

	value_lb:setString(value .. "")

	local bt_callback = function(sender, event)
		if event == TOUCH_EVENT_ENDED then
			if sender == jian_bt then
				--todo
				if value > 0 then
					--todo
					value = value - 1

					value_lb:setString(value .. "")
				end
			elseif sender == jia_bt then
				if value < 10 then
					--todo
					value = value + 1

					value_lb:setString(value .. "")
				end
			elseif sender == commit_bt then
				XLMH_CONTROLLER:requestJiapiao(value)
				maidian_plane:setVisible(false)
			end
		end
	end

	jian_bt:addTouchEventListener(bt_callback)
	jia_bt:addTouchEventListener(bt_callback)
	commit_bt:addTouchEventListener(bt_callback)
end
function GamePlaneOperator:playPanelRes()
	playerPlaneOperator:playPanelRes(self:getPlayerPlane(CARD_PLAYERTYPE_MY), CARD_PLAYERTYPE_MY)
	playerPlaneOperator:playPanelRes(self:getPlayerPlane(CARD_PLAYERTYPE_TOP), CARD_PLAYERTYPE_TOP)
end

function GamePlaneOperator:set_game_config(game_config)
	

    local gameConfigtbl = json.decode(game_config)
    local gameConfigStr = ""
    for k, v in pairs(gameConfigtbl) do
        if k == "wanfa" then
            gameConfigStr = gameConfigStr .. "玩法："
            if v == 6 then
                gameConfigStr = gameConfigStr .. "钓6条鱼 "
            elseif v == 8 then
                gameConfigStr = gameConfigStr .. "钓8条鱼 "
            elseif v == 12 then
                gameConfigStr = gameConfigStr .. "钓12条鱼 "
            end
        elseif k == "maxSeatCount" then
            gameConfigStr = gameConfigStr .. "人数："
            if v == 4 then
                gameConfigStr = gameConfigStr .. "4人 "
            elseif v == 3 then
                gameConfigStr = gameConfigStr .. "3人 "
            elseif v == 2 then
                gameConfigStr = gameConfigStr .. "2人 "
            end
        elseif k == "diaoyu" then
            gameConfigStr = gameConfigStr .. "钓鱼："
            if v == 0 then
                gameConfigStr = gameConfigStr .. "一五九钓鱼 "
            elseif v == 2 then
                gameConfigStr = gameConfigStr .. "爆炸鱼 "
            end
        elseif k == "maxFan" then
            gameConfigStr = gameConfigStr .. "封顶："
            if v == 4 then
                gameConfigStr = gameConfigStr .. "自摸4封 "
            elseif v == 6 then
                gameConfigStr = gameConfigStr .. "自摸6封 "
            elseif v == 100000 then
                gameConfigStr = gameConfigStr .. "无限番 "
            end

        elseif k == "menqing" then
            gameConfigStr = gameConfigStr .. "可选："
            local canPickStr= string.split(v, ",")
            for _, x in pairs(canPickStr) do
                if x == '1' then
                    gameConfigStr = gameConfigStr .. "门清 "
                elseif x == '2' then
                    gameConfigStr = gameConfigStr .. "带字 "
                end
            end
        end
    end

	
	local wanfa = gameConfigStr
	USER_INFO["gameConfig"] = wanfa
	local remark_lb = XLMH_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)

	if USER_INFO["gameConfig"] then
		remark_lb:setString(XLMH_PRV_GAME_NAME .. "："..USER_INFO["gameConfig"])
	else
		remark_lb:setString("正在读取组局信息")
	end
end

return GamePlaneOperator