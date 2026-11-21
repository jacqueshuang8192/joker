--
-- Author: Your Name
-- Date: 2017-09-05 19:20:41
--
local 	GamePlaneOperator = class("GamePlaneOperator")

local  	ControlPlaneOperator = require("xinyu510k.operator.ControlPlaneOperator")
local   CardPlaneOperator = require("xinyu510k.operator.CardPlaneOperator")
local   PlayerPlaneOperator = require("xinyu510k.operator.PlayerPlaneOperator")
local   TablePlaneOperator = require("xinyu510k.operator.TablePlaneOperator")

local 	PLAYER_PLANE_ARRAY = {}

function GamePlaneOperator:init()

	PLAYER_PLANE_ARRAY={[CARD_PLAYERTYPE_MY]    = cardScene:getChildByName("touxiangbufen_1"),
						[CARD_PLAYERTYPE_LEFT]  = cardScene:getChildByName("touxiangbufen_4"),
						[CARD_PLAYERTYPE_RIGHT] = cardScene:getChildByName("touxiangbufen_2"),
						[CARD_PLAYERTYPE_TOP]   = cardScene:getChildByName("touxiangbufen_3")}

    for playerType = 1,4 do 
    	PlayerPlaneOperator:init(playerType,self:getPlayerHeadPlane(playerType))
    end

    ControlPlaneOperator:init()
    CardPlaneOperator:init()
    TablePlaneOperator:init()
    
    local remain_rounds_count_plane = cardScene:getChildByName("remain_rounds_count_plane"):setVisible(false)
    --local room_lb_plane = cardScene:getChildByName("room_lb_plane")  --:setVisible(false)

    self:stopPlayerClock()
    self:clearAllReadyStatus()
end


function GamePlaneOperator:relocate(_type)
    
    if _type == "player" then
        for playerType = 1,XinYu510KRoomInfo.maxSeatCount do 
            self:removePlayer(playerType)
        end
    end
end


function GamePlaneOperator:clearGameDatas()

    CardPlaneOperator:clearGameDatas()

    for playerType = 1,4 do
        PlayerPlaneOperator:clearGameDatas(playerType, self:getPlayerHeadPlane(playerType))
    end

    TablePlaneOperator:clearGameDatas()
end



function GamePlaneOperator:getPlayerHeadPlane(playerType)
	return PLAYER_PLANE_ARRAY[playerType]
end

function GamePlaneOperator:showPlayerInfo(playerType,userInfo)
	return PlayerPlaneOperator:showPlayerInfo(playerType,self:getPlayerHeadPlane(playerType),userInfo)
end

function GamePlaneOperator:clearAllReadyStatus()
    for playerType = 1, 4 do
        local im_ready = (self:getPlayerHeadPlane(playerType)):getChildByName("im_ready")
        im_ready:setVisible(false)
    end
end

--显示玩家掉线情况
function GamePlaneOperator:removePlayer(playerType)
    PlayerPlaneOperator:removePlayer(playerType, self:getPlayerHeadPlane(playerType))
end

--显示玩家掉线情况
function GamePlaneOperator:showNetworkImg(playerType, flag)
	PlayerPlaneOperator:showNetworkImg(self:getPlayerHeadPlane(playerType),flag)
end

function GamePlaneOperator:updateCoin(playerType,value)
	PlayerPlaneOperator:updateCoin(playerType,self:getPlayerHeadPlane(playerType),value)
end

function GamePlaneOperator:updateBombFen(playerType,value)
	PlayerPlaneOperator:updateBombFen(self:getPlayerHeadPlane(playerType),value)
end

function GamePlaneOperator:setReadyStatus(playerType,flag)
    flag = flag or true
	local panel = self:getPlayerHeadPlane(playerType)
	local ready_img = panel:getChildByName("im_ready")
	if ready_img ~= nil then 
		ready_img:setVisible(flag)	 
	end
end

function GamePlaneOperator:clearAllReadyStatus()
	for playerType = 1,4 do
		local panel = self:getPlayerHeadPlane(playerType)
		if panel then
			local ready_img = panel:getChildByName("im_ready")
			ready_img:setVisible(false)
		end
	end
end

function GamePlaneOperator:showLandLord(LandLordplayerType,_type,flag)

	for playerType = 1,4 do

		local  headplane = self:getPlayerHeadPlane(playerType)
		if  flag == "clear" then  --重置所有地主农民标签
			PlayerPlaneOperator:showLandLord(headplane,_,flag)
		else
			if  playerType == LandLordplayerType then
				PlayerPlaneOperator:showLandLord(headplane,"LandLord",flag)
			else
				PlayerPlaneOperator:showLandLord(headplane,"Farmer",flag)
			end
		end
	end

end

--清除特定玩家的桌面
function GamePlaneOperator:clearUserDesk(playerType)
    PlayerPlaneOperator:clearUserDesk(playerType, self:getPlayerHeadPlane(playerType))
end


--清除所有玩家的桌面
function GamePlaneOperator:clearAllUserDesk()
    for seat_id =0,XinYu510KRoomInfo.maxSeatCount-1 do
        local playerType = self:getPlayerType(seat_id) 
        self:clearUserDesk(playerType)
    end    
end

function GamePlaneOperator:showLandLord(playerType, typ, flag)
    PlayerPlaneOperator:showLandLord(self:getPlayerHeadPlane(playerType), typ, flag)
end

--闹钟动画
function GamePlaneOperator:clockAnimation(playerType, leftTime)
    print(leftTime, "leftTime")
    local   leftTime = leftTime or 10

    local   posClock  ={ [0] = cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2),
                         [CARD_PLAYERTYPE_MY]= cc.p(SCREEN_WIDTH/2,310),
                         [CARD_PLAYERTYPE_LEFT]= cc.p(440,430),
                         [CARD_PLAYERTYPE_RIGHT]= cc.p(840,430),
                         [CARD_PLAYERTYPE_TOP]= cc.p(500,600)}

    local   clock = cardScene:getChildByName("clock")
            clock:setVisible(true) 

    local   ponit = posClock[playerType]
            clock:setPosition(ponit)
    local   clock_num = clock:getChildByName("clock_num")
            clock_num:stopAllActions()

    local   showTimerAc = cc.CallFunc:create(function()
             
            leftTime = leftTime - 1

            if leftTime <= 0 then
                clock_num:setString("00")
                clock:setVisible(false) 
                clock_num:stopAllActions()
            end

            if leftTime < 10 then
                clock_num:setString("0"..leftTime)
            else
                clock_num:setString(leftTime .. "")
            end

        end)

    local seqAc = cc.Sequence:create(showTimerAc,cc.DelayTime:create(1))
    clock_num:runAction(cc.RepeatForever:create(seqAc))
end

--停止闹钟动画
function GamePlaneOperator:stopPlayerClock(uid)
    local   clock = cardScene:getChildByName("clock")
    clock:setVisible(false)
end


--设置底分
function GamePlaneOperator:setBaseChip(value)

    local layout = cardScene:getChildByName("p_base_chip")
    if layout then
        local txt = layout:getChildByName("txt_chip")
        if txt then
            txt:setVisible(true)
            txt:setString(tostring(value))
        end
    end
end         


function GamePlaneOperator:setDoubleFlag(playerType, times, flag)
    PlayerPlaneOperator:setDoubleFlag(self:getPlayerHeadPlane(playerType), times, flag)
end

function GamePlaneOperator:drawCoin(tbWin)

    for uid, value in pairs(tbWin) do

        local seatId = DDZ_SEAT_TABLE[uid]
        local playerType = self:getPlayerType(seatId)
        local plane = self:getPlayerHeadPlane(playerType)
        local txtWin = plane:getChildByName("chips")

        if value ~= nil and value ~= 0 then

            local mb = cc.MoveBy:create(1.5,cc.p(0,60))
            local mb2 = cc.MoveBy:create(0.1,cc.p(0,-60))
            local hide = cc.Hide:create()
            local fo = cc.FadeOut:create(0.5)
            local seq = cc.Sequence:create(mb, fo, hide, mb2)

            local str = value > 0 and "+"..tostring(value/100) or tostring(value/100)
            
            txtWin:setString(str)
            txtWin:setVisible(true)
            txtWin:setOpacity(255)
            txtWin:runAction(seq)

        end

        DDZ_USERINFO_TABLE[uid].coins = DDZ_USERINFO_TABLE[uid].coins + value

        SCENENOW["scene"]:performWithDelay(function()
            self:updateCoin(playerType,DDZ_USERINFO_TABLE[uid].coins)
        end,1)
     
    end
end


--设置剩余的排数
function GamePlaneOperator:setRestCardNum(playerType, num, sex, flag)
    --print(playerType, num, sex, flag)
    --print(debug.traceback(),"setRestCardNum")
    --剩下5张牌之后报警
    if num <= 5 then

        PlayerPlaneOperator:showAlarm(self:getPlayerHeadPlane(playerType), true, playerType)

        --if num == 1 or num == 2 then

            sex = sex or 0
            if sex == 1 then--男
                require("hall.GameCommon"):playEffectSound("xinyu510k/audio/new/Man_baojing"..num..".mp3")
            else  --2是女，0保密
                require("hall.GameCommon"):playEffectSound("xinyu510k/audio/new/Woman_baojing"..num..".mp3")
            end

            --require("hall.GameCommon"):playEffectMusic("xinyu510k/audio/new/Audio_after_bomb.mp3")
        --end

    end

    -- if  GAME_CONFIG and GAME_CONFIG["不显示剩余牌数"]==true then
        -- if num>0 and num<=2 then
            -- PlayerPlaneOperator:showRemainCardsNum(self:getPlayerHeadPlane(playerType), num, flag)
        -- end
    -- else
        -- PlayerPlaneOperator:showRemainCardsNum(self:getPlayerHeadPlane(playerType), num, flag)
    -- end
	PlayerPlaneOperator:showRemainCardsNum(self:getPlayerHeadPlane(playerType), num, flag)
end

function GamePlaneOperator:beginPlayCard(playerType, leftTime)
    for _playerType = 1,4 do
		local plane = self:getPlayerHeadPlane(_playerType)
        PlayerPlaneOperator:beginPlayCard(plane,false)
    end
    self:clockAnimation(playerType, leftTime)
    PlayerPlaneOperator:beginPlayCard(self:getPlayerHeadPlane(playerType),true)
end

function GamePlaneOperator:addScore(playerType, typ, score)
    PlayerPlaneOperator:addScore(self:getPlayerHeadPlane(playerType), typ, score)
end

function GamePlaneOperator:setScore(playerType, typ, score)
    PlayerPlaneOperator:setScore(self:getPlayerHeadPlane(playerType), typ, score)
end

function GamePlaneOperator:showTaiFeiTips(value)
    TablePlaneOperator:showTaiFeiTips(value)
end

function GamePlaneOperator:showDeicideCard(value, callBack)
    TablePlaneOperator:showDeicideCard(value, callBack)
end

function GamePlaneOperator:showDistance(LocaArrayByPlayerType,flag)
  
   local    distance_bt = cardScene:getChildByName("distance_bt")
            
            if  distance_bt:isVisible() then
                return
            end
            
            distance_bt:setVisible(flag)
            distance_bt:addTouchEventListener(

            function(sender,event)

                if event == TOUCH_EVENT_ENDED then
                    self:showDistanceAgain()
                end
        
            end)

                        

    local   function    getDistance(latitude,longitude,b_latitude,b_longitude,lb)
          
        print(latitude,longitude,b_latitude,b_longitude,"gohere")
        if  (latitude == 0 or latitude == nil) or (b_latitude == 0 or b_latitude == nil)  then   --距离数据不存
            lb:setString("距离未知")
        else    
            local s = require("hall.util.LocationUtil"):getDistance(latitude, longitude, b_latitude, b_longitude)
            s = math.abs(s)
            if s < 1000 then
                lb:setString(tostring(s) .. "米")
            else
                s = s / 1000
                s = string.format("%0.1f", s)
                lb:setString(tostring(s) .. "公里")
            end 
        end

    end

    local  distance_plane = cardScene:getChildByName("distance_plane")
    local  left_top_lb = distance_plane:getChildByName("left_top_lb")
    local  left_right_lb = distance_plane:getChildByName("left_right_lb")
    local  right_top_lb = distance_plane:getChildByName("right_top_lb")
    
    local  flag = flag or false
           distance_plane:setVisible(flag)
           distance_plane:performWithDelay(function() distance_plane:setVisible(false) end,3)
     
    dump(LocaArrayByPlayerType,"LocaArrayByPlayerType")
    local  left = LocaArrayByPlayerType[2] or {0,0}
    local  right = LocaArrayByPlayerType[3] or {0,0}
    local  top =  LocaArrayByPlayerType[4] or {0,0}

   -- [1]是longitude,[2]是latitude
    local left_right_txt = getDistance(left[2],  left[1],  right[2], right[1],  left_right_lb)
    local left_top_txt   = getDistance(left[2],  left[1],  top[2],   top[1],    left_top_lb)
    local right_top_txt  = getDistance(right[2], right[1], top[2],   top[1],    right_top_lb)

end

function GamePlaneOperator:showDistanceAgain()
    
    local   distance_plane = cardScene:getChildByName("distance_plane")
            distance_plane:setVisible(true)
            distance_plane:performWithDelay(function() distance_plane:setVisible(false) end,3)
end

function GamePlaneOperator:getPlayerType(seatId)   --seatId为服务器座位号
    print('getPlayerType  ', seatId, XinYu510KRoomInfo, XinYu510KRoomInfo and XinYu510KRoomInfo.maxSeatCount)    
    if seatId == nil or seatId < 0 then return nil end
	print('f1')
	if not XinYu510KRoomInfo then
		print('ddzSettings:getPlayerType error', debug.traceback())
		return nil
	end
	print('f2')
	local playerType = CARD_PLAYERTYPE_MY
	if XinYu510KRoomInfo.maxSeatCount == 2 then
		if seatId == MY_SEAT_ID then
			playerType = CARD_PLAYERTYPE_MY
		else
			playerType = CARD_PLAYERTYPE_TOP
		end
		
		-- local other_index = seatId - MY_SEAT_ID

		-- if other_index < 0 then
		   -- other_index = other_index + XinYu510KRoomInfo.maxSeatCount
		-- end
		 
		-- playerType =  other_index+1  -- otherIndex2playerType[other_index]
		-- if playerType > 4 then
			-- playerType = 4
		-- end
	else
		local other_index = seatId - MY_SEAT_ID

		if other_index < 0 then
		   other_index = other_index + XinYu510KRoomInfo.maxSeatCount
		end
		 
		playerType =  other_index+1  -- otherIndex2playerType[other_index]
		if playerType > 4 then
			playerType = 4
		end
	end

    print('f3',playerType)
    return playerType
end

return GamePlaneOperator
