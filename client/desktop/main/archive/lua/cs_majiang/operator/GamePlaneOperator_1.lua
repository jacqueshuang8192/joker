local Card = require("cs_majiang.card.card")
local playerPlaneOperator = require("cs_majiang.operator.PlayerPlaneOperator")
local centerPlaneOperator = require("cs_majiang.operator.CenterPlaneOperator")

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

local CHILD_NAME_KAIGANG_PLANE = "kaigang_plane"

-- local schedulerID

function GamePlaneOperator:init()
	CSMJ_REMAIN_CARDS_COUNT = 56

	playerPlaneOperator:init(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:init(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:init(centerPlane)

	local myPlane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
	myPlane.noScale = true
	myPlane:onClick(function()
			playerPlaneOperator:cancelSelectingCard(myPlane)
		end)

	CSMJ_CARD_POINTER = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_POINTER)
	CSMJ_CARD_POINTER:setVisible(false)
      
	local remain_cards_count_plane = CSMJ_GAME_PLANE:getChildByName("remain_cards_count_plane")
	local remain_cards_count_lb = remain_cards_count_plane:getChildByName("remain_cards_count_lb")

	local remain_rounds_count_plane = CSMJ_GAME_PLANE:getChildByName("remain_rounds_count_plane")
	local remain_rounds_count_lb = remain_rounds_count_plane:getChildByName("remain_rounds_count_lb")
 	local total_rounds_count_lb = remain_rounds_count_plane:getChildByName("total_rounds_count_lb")
 	local txt2 = remain_rounds_count_plane:getChildByName("Text_2")
 	txt2:setVisible(false)

	 local txt_lb = display.newTTFLabel({
                text = content,
                font = "cs_majiang/fonts/fzcs.ttf",
                size = 25,
                color = cc.c3b(166, 59, 6),
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                dimensions = cc.size(txtWidth, 0)
            })

    txt_lb:setAnchorPoint(txt2:getAnchorPoint())
    remain_rounds_count_plane:addChild(txt_lb)
    txt_lb:setPosition(txt2:getPosition())
    txt_lb:setString("/")


 	if GROUP_MODE == GOLD_MODE then
 		remain_rounds_count_plane:setVisible(false)
 	end
	remain_cards_count_lb:setString("0")
	remain_rounds_count_lb:setString("0")
    total_rounds_count_lb:setString("0")

	local card_bx = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	local remark_lb = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)

	if USER_INFO["gameConfig"] then
		remark_lb:setString(GameNameValue ..USER_INFO["gameConfig"])
	else
		remark_lb:setString("正在读取组局信息")
	end

	local kaigang_plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_KAIGANG_PLANE)
	if kaigang_plane then
		--todo
		kaigang_plane:setVisible(false)
	end
end

function GamePlaneOperator:showCenterPlane()
	local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlane:setVisible(true)
end

function GamePlaneOperator:clearGameDatas()
	CSMJ_REMAIN_CARDS_COUNT = 56

	CSMJ_CURRENT_CARDNODE = nil

	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:clearGameDatas(centerPlane)

	local card_bx = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	CSMJ_CARD_POINTER:setPosition(cc.p(-20, -20))

	self:hideTingHuPlane()
	dump(CSMJ_USERINFO_TABLE,"CSMJ_USERINFO_TABLE333")
	for i=0,3 do
		if CSMJ_USERINFO_TABLE[i..""] then
			CSMJ_USERINFO_TABLE[i .. ""].ready_flag = 0
		end
	end
	-- local scheduler = cc.Director:getInstance():getScheduler()

	-- if schedulerID then
	-- 	--todo
	-- 	scheduler:unscheduleScriptEntry(schedulerID)
	-- 	schedulerID = nil
	-- end
end

function GamePlaneOperator:removePlayer(playerType)
	playerPlaneOperator:clearGameDatas(playerType, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:getPlayerPlane(playerType)
	local plane
	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_MY_PLANE)
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_LEFT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_RIGHT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_TOP_PLANE)
	end

	-- --dump(plane, "plane test")
	return plane
end

function GamePlaneOperator:playCard(playerType, tag, value)
	playerPlaneOperator:playCard(playerType, self:getPlayerPlane(playerType), tag, value)

	-- local card_bx = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)

	-- card_bx:setVisible(true)

	-- card_bx:removeAllChildren()

	-- local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, value)

	-- local size = card:getSize()

	-- local scale = (card_bx:getSize().height - 20) / size.height

	-- card:setScale(scale)

	-- card:setPosition(cc.p(card_bx:getSize().width / 2, card_bx:getSize().height / 2))

	-- card_bx:addChild(card)

	-- local wait = cc.DelayTime:create(1)
	-- local hide = cc.Hide:create()

	-- local seqAction = cc.Sequence:create(wait, hide)

	-- card_bx:runAction(seqAction)


	-- local scheduler = cc.Director:getInstance():getScheduler()  

	-- schedulerID = scheduler:scheduleScriptFunc(function()  
		   
	-- 	   card_bx:setVisible(false)

	-- 	   scheduler:unscheduleScriptEntry(schedulerID)

	-- 	   schedulerID = nil
	-- 	end, 1, false)
end

function GamePlaneOperator:control(playerType, progCards, controlType, tingSeq,removeCards,fromplayerType)

	CSMJ_CARD_POINTER:stopAllActions()
	CSMJ_CARD_POINTER:setVisible(false)
    
	CSMJ_CURRENT_CARDNODE = nil
    
	playerPlaneOperator:control(playerType, self:getPlayerPlane(playerType), progCards,controlType,tingSeq,removeCards,fromplayerType)
	
    if bit.band(CONTROL_TYPE_GANG, controlType) > 0 and playerType == CARD_PLAYERTYPE_MY then
        self:showCards(playerType)
	end

	self:beginPlayCard(playerType)

end

function GamePlaneOperator:showPlayerInfo(playerType, userInfo)
	local plane = self:getPlayerPlane(playerType)
	plane:setVisible(true)
	return playerPlaneOperator:showPlayerInfo(userInfo, plane)
end

function GamePlaneOperator:hidePlayerInfo(playerType)
	local plane = self:getPlayerPlane(playerType)
	plane:setVisible(false)
end

function GamePlaneOperator:showZhuang(playerType)
	playerPlaneOperator:showZhuang(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showCards(playerType,tingSeq)
	playerPlaneOperator:showCards(playerType, self:getPlayerPlane(playerType),tingSeq)

	local seatId = CSMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]
	CSMJ_GAMEINFO_TABLE[seatId ..""].isShowCards = false
end

function GamePlaneOperator:getNewCard(playerType, value,tingSeq)
	playerPlaneOperator:getNewCard(playerType, self:getPlayerPlane(playerType), value,tingSeq)
	-- playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	self:beginPlayCard(playerType)
end

function GamePlaneOperator:showControlPlane(controlTable)
	CSMJ_CONTROL_TABLE = controlTable

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
	local remain_cards_count_plane = CSMJ_GAME_PLANE:getChildByName("remain_cards_count_plane")
	local remain_cards_count_lb = remain_cards_count_plane:getChildByName("remain_cards_count_lb")


	local remain_rounds_count_plane = CSMJ_GAME_PLANE:getChildByName("remain_rounds_count_plane")
	local remain_rounds_count_lb = remain_rounds_count_plane:getChildByName("remain_rounds_count_lb")
 	local total_rounds_count_lb = remain_rounds_count_plane:getChildByName("total_rounds_count_lb")


    local remark_lb = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)
    
	if remain_cards_count_lb then

		local content = CSMJ_REMAIN_CARDS_COUNT	
		remain_cards_count_lb:setString(content)

		if CSMJ_ROUND then

			if USER_INFO["gameConfig"] then
				remark_lb:setString(GameNameValue ..": " .. "第"..CSMJ_ROUND.."/"..USER_INFO["gameConfig"])
			end	
			if CSMJ_ROUND > CSMJ_TOTAL_ROUNDS then
				CSMJ_ROUND = CSMJ_TOTAL_ROUNDS
			end
            remain_rounds_count_lb:setString(CSMJ_ROUND)
		    total_rounds_count_lb:setString(CSMJ_TOTAL_ROUNDS)
		end


	end
end

function GamePlaneOperator:beginPlayCard(playerType)
	local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

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

function GamePlaneOperator:showTingHuPlane(tingHuCards)
	playerPlaneOperator:showTingHuPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), tingHuCards)
end

function GamePlaneOperator:hideTingHuPlane()
	playerPlaneOperator:hideTingHuPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:showCardsForHu(playerType, cardDatas, huCard)
	playerPlaneOperator:showCardsForHu(playerType, self:getPlayerPlane(playerType), cardDatas, huCard)

	local seatId = CSMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]
	CSMJ_GAMEINFO_TABLE[seatId ..""].isShowCards = true
end

function GamePlaneOperator:getHeadNode(playerType)
	return playerPlaneOperator:getHeadNode(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showNetworkImg(playerType, flag)
	playerPlaneOperator:showNetworkImg(self:getPlayerPlane(playerType), flag)
end

--[[function GamePlaneOperator:showJiapiaoPlane(flag)
	playerPlaneOperator:showJiapiaoPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), flag)
end

function GamePlaneOperator:showPiaoImg(playerType, piao, flag)
	playerPlaneOperator:showPiaoImg(self:getPlayerPlane(playerType), piao, flag)
end--]]

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
local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

	centerPlaneOperator:rotateTimer(zhuang_index,centerPlane)
end
--[[
	@brief:设置玩家准备状态
	@param:_playerType 座位id
	@author:Jhao.
]]
function GamePlaneOperator:setReadyStatus(playerType,flag)
	if flag == nil then
		flag = true
	end
	
	local panel = self:getPlayerPlane(playerType)
	if panel == nil then return end

	local ready_img = panel:getChildByName(CHILD_NAME_READY_IMG)
	if ready_img ~= nil then 
		ready_img:setVisible(flag)	 
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
  
   local  distance_bt = CSMJ_GAME_PLANE:getParent():getChildByName("menu_ly"):getChildByName("menu_plane"):getChildByName("distance_bt")
   
   if distance_bt:isVisible() then
   	  return 
   end

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

    local distance = (CSMJ_GAME_PLANE:getChildByName("my_card_plane")):getChildByName("distance")
    local left_top_lb = distance:getChildByName("left_top_lb")
    local left_right_lb = distance:getChildByName("left_right_lb")
    local right_top_lb = distance:getChildByName("right_top_lb")
    
    local flag = flag or false
    distance:setVisible(flag)
    distance:performWithDelay(function() distance:setVisible(false) end,3)

   local  left = LocaArrayByPlayerType[2] or {0,0}
   local  right = LocaArrayByPlayerType[3] or {0,0}
   local  top =  LocaArrayByPlayerType[4] or {0,0}

    -- if PLAYERNUM == 4 then 
        
       -- [1]是longitude,[2]是latitude
       local left_right_txt = getDistance(left[2],  left[1],  right[2], right[1],  left_right_lb)
       local left_top_txt   = getDistance(left[2],  left[1],  top[2],   top[1],    left_top_lb)
       local right_top_txt  = getDistance(right[2], right[1], top[2],   top[1],    right_top_lb)

    -- elseif  PLAYERNUM == 3 then 

    --    local left_right_txt = getDistance(left[2],  left[1],  right[2], right[1],  left_right_lb)

    -- end
end

function GamePlaneOperator:showDistanceAgain()
	local distance = (CSMJ_GAME_PLANE:getChildByName("my_card_plane")):getChildByName("distance")
	distance:setVisible(true)
    distance:performWithDelay(function() distance:setVisible(false) end,3)
end

function GamePlaneOperator:showCardsForQiShouHu(playerType, cardDatas, _liangCards)
	playerPlaneOperator:showCardsForQiShouHu(playerType, self:getPlayerPlane(playerType), cardDatas, _liangCards)

	local seatId = CSMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]
	CSMJ_GAMEINFO_TABLE[seatId ..""].isShowCards = true
end

function GamePlaneOperator:kaigang(card1, card2)
	local plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_KAIGANG_PLANE)

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