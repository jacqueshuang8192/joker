local HistoryLayer = class("HistoryLayer")

local history_cell
local myRecord_cell
local othersRecord_cell

local history_plane
local myRecord_plane

local isShow = false

local ts = require("hall.roomPlay.transcribe").new()

local selected_level = 0

local _w = nil

local coinData = nil
local friendData = nil

local firstOpen = true
local isDetail = false

local WinColor =  cc.c3b(0x0E, 0xEF, 0x0E)
local LoseColor =  cc.c3b(0xf7,0x07, 0x2e)


local ResultCsb_filePath = "hall/res/csb/history/HistoryLayer.csb"


local ItemDetailCsb = "hall/res/csb/history/item_detail.csb"
local ItemHistoryCsb = "hall/res/csb/history/item_history.csb"

function HistoryLayer:removeScene()

    local s = SCENENOW["scene"]:getChildByName("HistoryLayer")
    if  s then
        s:removeFromParent() --清除界面，内存不减少，专门用cs做的界面
    end
    
    coinData = nil
    friendData = nil 

end

function HistoryLayer:showHistoryLayer(currentPlayMode)
	
	isShow = true

    firstOpen = true
    isDetail = false

	local s = cc.CSLoader:createNode(ResultCsb_filePath):addTo(SCENENOW["scene"])
    s:setName("HistoryLayer")
    
	local layout = s:getChildByName("root_ly") 
	history_plane = layout:getChildByName("history_plane") --滚动开始的查看界面


	myRecord_plane = layout:getChildByName("myRecord_plane")  --玩家战绩显示
	--local findOthersRecord_plane = layout:getChildByName("findOthersRecord_plane")  --回放找回人的
	local othersRecord_plane = layout:getChildByName("othersRecord_plane")  --战绩列表的背景
     
    _w = self:loadChildrenWidget(s) 

    --self:initTable()
    local zhanjiText = s:getChildByName("zhanjiText"):setString("");
    -- zhanjiText:setString("（最多可显示30条战绩）");

    local his_coin_btn = s:getChildByName("his_coin_btn")
    local his_friend_btn = s:getChildByName("his_friend_btn")

    if currentPlayMode == 0 then
        self:getCoinData()
        _w["his_coin_btn"]:setEnabled(false)
        _w["his_friend_btn"]:setEnabled(true)
    else
        self:getFriendData()
        _w["his_coin_btn"]:setEnabled(true)
        _w["his_friend_btn"]:setEnabled(false)
    end

    if  onlyHasRoomCardMode == true then
        _w["his_coin_btn"]:setVisible(false)
        _w["his_friend_btn"]:setPosition(_w["his_coin_btn"]:getPosition())
    elseif  onlyHasGoldMode == true then
        _w["his_friend_btn"]:setVisible(false)
    end

	--myRecord_plane:setVisible(false)
	--findOthersRecord_plane:setVisible(false)
	othersRecord_plane:setVisible(false)

	local back_bt = layout:getChildByName("back_bt")  --返回
	--local findOthersRecord_bt = layout:getChildByName("findOthersRecord_bt") --查看他人找回的控件
	--local commit_bt = findOthersRecord_plane:getChildByName("commit_bt") --确定
	--local cancel_bt = findOthersRecord_plane:getChildByName("cancel_bt") --取消
	--local othersRecord_close_bt = othersRecord_plane:getChildByName("othersRecord_close_bt") 

	--local input_tf = findOthersRecord_plane:getChildByName("input_tf") --输入框


         
	--findOthersRecord_plane.noScale = true
	-- findOthersRecord_plane:onClick(function()
	-- 	findOthersRecord_plane:setVisible(false)
	-- end)

   
        local share_action = s:getChildByName("share_action") 
       share_action:setVisible(false)
      share_action:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                --通知APP分享结果
                if device.platform == "android" then
                    dump("showShareLayer")
                    require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
                elseif device.platform ~= "windows" then
                    require("hall.common.ShareLayer"):shareGroupResultForIOS()
                end

            end
        end)
       

	local function touchButtonEvent(sender, event)

        if event == TOUCH_EVENT_ENDED then

        	require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
        	print("sender" .. sender:getName())

            if sender == back_bt then  --点击返回的时候
            	--if history_plane:isVisible() then  --滚动界面的显示
            		--todo
            	--	isShow = false --一个状态控制
                if isDetail then
                    self:initFriendTable(friendData)
                    isDetail = false
                else  
                    self:removeScene()  
                end
            	-- else
            	-- 	history_plane:setVisible(true) --玩家信息界面显示
            	-- 	myRecord_plane:setVisible(false) --具体对战信息不显示

            	-- end

                
            elseif sender == findOthersRecord_bt then  --点击查看他人找回的控件
                findOthersRecord_plane:setVisible(true)

            
            elseif sender == cancel_bt then
            	print("cancel test")
            	findOthersRecord_plane:setVisible(false)
            elseif sender == othersRecord_close_bt then
            	othersRecord_plane:setVisible(false)
            elseif sender == his_coin_btn then
            	print("his_coin_btn")
                isDetail = false
            	_w["his_coin_btn"]:setEnabled(false)
            	_w["his_friend_btn"]:setEnabled(true)
                if coinData == nuil then
                    self:getCoinData()
                end
                self:initCoinTable(coinData)
            elseif sender == his_friend_btn then
            	print("his_friend_btn......")
            	_w["his_coin_btn"]:setEnabled(true)
            	_w["his_friend_btn"]:setEnabled(false)
                if  firstOpen then
                    self:getFriendData()
                    firstOpen = false
                else
                    self:initFriendTable(friendData)
                end    
            end
        end

    end

    back_bt:addTouchEventListener(touchButtonEvent)
    --findOthersRecord_bt:addTouchEventListener(touchButtonEvent)
    --commit_bt:addTouchEventListener(touchButtonEvent)
    --cancel_bt:addTouchEventListener(touchButtonEvent)
    --othersRecord_close_bt:addTouchEventListener(touchButtonEvent)

    his_coin_btn:addTouchEventListener(touchButtonEvent)
    his_friend_btn:addTouchEventListener(touchButtonEvent)

    --cell
    --history_cell = s:getChildByName("history_cell")  --玩家列表
    --myRecord_cell = s:getChildByName("myRecord_cell") --分享和回放 玩家对战具体
    --othersRecord_cell = s:getChildByName("othersRecord_cell")
    --self.history_cell_5 = s:getChildByName("history_cell_5")

    local history_scroll = history_plane:getChildByName("history_scroll")

    
end


--请求金币场数据
function HistoryLayer:getCoinData()
	-- body	
	local params = {}
    params["userId"] = USER_INFO["uid"]
    params["currentPage"] = 1
    params["pageSize"] = 30  --战绩条数
    params["interfaceType"] = "J"
    cct.createHttRq({
       -- url=HttpAddr .. "/freeGame/queryFreeGameRound",
        url=HttpAddr .. "/freeGame/queryGoldActivitiesByUserId",
        date= params,
        type_="POST",

        callBack = function(data)      
            data_netData = json.decode(data["netData"])

            dump(data_netData, "---findRound---")
            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                if sData ~= nil then
                    --todo
                	coinData = sData
	           		self:initCoinTable(coinData)
                end
               
            end              
        end
    })

end



--请求好友场数据
function HistoryLayer:getFriendData()
	-- body
    print("uid............" .. USER_INFO["uid"])
	local params = {}
    params["userId"] = USER_INFO["uid"]
    params["currentPage"] = 1
    params["pageSize"] = 150
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/freeGame/queryCardActivitiesByUserId",
        date= params,
        type_="POST",
        callBack = function(data)

            data_netData = json.decode(data["netData"])
            dump(data_netData,"----房卡场战绩----")

            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                if sData ~= nil  then
                    --todo
                   
                    friendData = sData
                    self:initFriendTable(friendData)

                end

            end   

        end

    })
end


--获取子控件table
function HistoryLayer:loadChildrenWidget(_node, _childrenTable)
	local function func(node, childrenTable)
		if node ~= nil and node:getChildrenCount() <= 0 then return end
		local cTable = node:getChildren()
		for i, v in ipairs(cTable) do
			childrenTable[v:getName()] = v
			func(v, childrenTable)
		end
	end
	if _childrenTable == nil then _childrenTable = {} end
	func(_node, _childrenTable)
	return _childrenTable
end

--创建金币场战绩列表
function HistoryLayer:initCoinTable(data)
	-- body
	dump(data,"------------金币场战绩----------------")

    if  tolua.isnull(_w["myRecord_scroll"]) or data == nil then
        return
    end

    _w["myRecord_scroll_detail"]:setVisible(false)
    _w["myRecord_scroll"]:setVisible(true)
    _w["myRecord_scroll_friend"]:setVisible(false)
    local history_background = _w["history_plane"]:getChildByName("history_background")
    history_background:setVisible(true)
    if tolua.isnull(_w["myRecord_scroll"]:getChildren()[1]) == false then
        return
    end

	_w["myRecord_scroll"]:removeAllChildren()
	--_w["myRecord_scroll"]:setVisible(true)
	for k,v in pairs(data) do 

        if v["content"] then

    		-- local historycell = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/result/item_coin_histroy.csb")
            local itemLayout = _w["itemLayout"]:clone()   
            local _itemW = self:loadChildrenWidget(itemLayout)
            -- itemLayout:removeFromParent()
            --dump(v["content"],"------------金币场战绩1----------------")
            itemLayout:setVisible(true)
        	local userinfo = json.decode(v["content"])
            local gameName = userinfo["gameName"]
            local roomNumb = userinfo["roomNumb"] 
        		  userinfo = userinfo["userinfos"]
             
            _itemW["room_id"]:setString(gameName.."    房间号："..roomNumb)  
        	--dump(userinfo,"------------金币场战绩2----------------")
        	for o,p in pairs(userinfo) do 
        		if p["uid"] == USER_INFO["uid"] then
                    local nickName = require("hall.GameCommon"):formatNick(p["nickName"], 6)
        			_itemW["player_nick"]:setString(nickName)
        			require("hall.GameCommon"):getUserHead(p["photoUrl"], "", "", _itemW["player_head"], 60, false, p["nickName"])
        			local score = p["score"]

        			if score > 0 then
                        score = require(GameCommon_filePath):formatGold(score)
        				score = "+"..score
        				_itemW["player_score"]:setColor(WinColor)
        			elseif score < 0 then
                        score = require(GameCommon_filePath):formatGold(score)
        				_itemW["player_score"]:setColor(LoseColor)
        			end

        			_itemW["player_score"]:setString(score)
                    
        		end
        	end	
    		        

            _w["myRecord_scroll"]:pushBackCustomItem(itemLayout)
            _w["myRecord_scroll"]:jumpToTop()
            if k == 30 then
                break
            end

        end
        
	end	
end


--创建好友场战绩列表
function HistoryLayer:initFriendTable(data)
	-- body
	 dump(data,"------------好友场战绩----------------")
    if  tolua.isnull(_w["myRecord_scroll_friend"]) or data == nil then
        return
    end

    _w["myRecord_scroll_detail"]:setVisible(false)
    _w["myRecord_scroll"]:setVisible(false)
    _w["myRecord_scroll_friend"]:setVisible(true)

    if tolua.isnull(_w["myRecord_scroll_friend"]:getChildren()[1]) == false then
        return
    end

	_w["myRecord_scroll_friend"]:removeAllChildren()
	--_w["myRecord_scroll_friend"]:setVisible(true)
	for k,v in pairs(data) do 

        if v["content"] then

    		local historycell = cc.CSLoader:createNode(ItemHistoryCsb)
    		local itemLayout = historycell:getChildByName("itemLayout")
            local _itemW = self:loadChildrenWidget(itemLayout)
            itemLayout:removeFromParent()
            -- dump(v["content"],"------------金币场战绩1----------------")
            _itemW["num_lb"]:setString(k)
        	local userinfo = json.decode(v["content"])
            local gameName = userinfo["gameName"]
            --print("gameName...."..gameName)
            local roomNum = userinfo["roomNum"] 
            local gameTime = userinfo["gameTime"]
            local time_str = os.date("%Y-%m-%d %H:%M:%S", gameTime)

            _itemW["roomName_lb"]:setString(roomNum)  
            _itemW["roomName_yx"]:setString(gameName)
            _itemW["time_lb"]:setString(time_str)
            
        		userinfo = userinfo["userinfos"]
        	--dump(userinfo,"------------金币场战绩2----------------")

            for i=1,10 do
                _itemW["player_"..i]:setVisible(false)
            end    

        	for o,p in pairs(userinfo) do

                -- dump(o,"initFriendTable_o")
                
                if o <= 10 then
        		    _itemW["player_"..o]:setVisible(true)
                    local nickName = require("hall.GameCommon"):formatNick(p["nickName"], 6)
        			_itemW["playername_"..o]:setString(nickName)
        			--require("hall.GameCommon"):getUserHead(p["photoUrl"], "", "", _itemW["player_head"], 80, false, p["nickName"])
        			local score = p["score"]
        			if score >0 then
        				score = "+"..score
        				_itemW["score_"..o]:setColor(WinColor)
        			elseif score < 0 then
        				_itemW["score_"..o]:setColor(LoseColor)
        			end
        			_itemW["score_"..o]:setString(score)
                end
        		
        	end	

            _itemW["detail_btn"]:addTouchEventListener(
                function(sender,event)
                    if event == TOUCH_EVENT_ENDED then
                        print("activityId..." .. v["activityId"])
                        isDetail = true
                        self:getRoundDetailTable(v["activityId"])
                    end   

                end
                )
    		        

            _w["myRecord_scroll_friend"]:pushBackCustomItem(itemLayout)
            _w["myRecord_scroll_friend"]:jumpToTop()
            if k == 30 then
                break
            end

        end
        
	end	
end


--获取单场游戏每局战绩详情数据

function HistoryLayer:getRoundDetailTable(activityId)
    -- body
    print("activityId............" .. activityId)
    local params = {}
    params["userId"] = USER_INFO["uid"]
    params["activityId"] = activityId
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/freeGame/queryCardActivities2RoundByUserId",
        date= params,
        type_="POST",
        callBack = function(data)

        
            data_netData = json.decode(data["netData"])
            dump(data_netData,"----每局战绩数据----")

            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                if sData ~= nil  then
                    --todo
                   
                    self:initRoundDetailTable(sData,activityId)

                end

            end   

        end

    })

end


--创建单场游戏每局战绩详情列表

function HistoryLayer:initRoundDetailTable(data,activityId)
    -- body
    dump(data,"------------单局战绩数据----------------")

    _w["myRecord_scroll_detail"]:removeAllChildren()

    _w["myRecord_scroll_detail"]:setVisible(true)
    _w["myRecord_scroll"]:setVisible(false)
    _w["myRecord_scroll_friend"]:setVisible(false)

    for k,v in pairs(data) do
        local  NickNameTable = {}
        local historycell = cc.CSLoader:createNode(ItemDetailCsb)
        local itemLayout = historycell:getChildByName("itemLayout")   
         
        local _itemW = self:loadChildrenWidget(itemLayout)
        itemLayout:removeFromParent()
        --dump(v["content"],"------------金币场战绩1----------------")
        _itemW["num_lb"]:setString("第"..v["roundIndex"] .."局")
        local userinfo = json.decode(v["content"])
        local gameName = userinfo["gameName"]
        userinfo = userinfo["userinfos"]
        --dump(userinfo,"------------金币场战绩2----------------")

        for i=1,10 do
            _itemW["player_"..i]:setVisible(false)
        end    

        for o,p in pairs(userinfo) do 
            _itemW["player_"..o]:setVisible(true)
            local nickName = p["nickName"] --require("hall.GameCommon"):formatNick(p["nickName"], 6)
            NickNameTable[p["uid"]] = p["nickName"]
            _itemW["playername_"..o]:setString(nickName)
            --require("hall.GameCommon"):getUserHead(p["photoUrl"], "", "", _itemW["player_head"], 80, false, p["nickName"])
            local score = p["score"]
            if score >0 then
                score = "+"..score
                _itemW["score_"..o]:setColor(WinColor)
            elseif score < 0 then
                _itemW["score_"..o]:setColor(LoseColor)
            end

            dump(o, "initRoundDetailTable")
            dump(p, "initRoundDetailTable")
            _itemW["score_"..o]:setString(score)
        end

        local itempanel = itemLayout:getChildByName("itempanel")
        local playback_btn = itempanel:getChildByName("playback_btn")
        _w["myRecord_scroll_detail"]:pushBackCustomItem(itemLayout)
        _w["myRecord_scroll_detail"]:jumpToTop()
        if gameName and (string.find(gameName,"快乐麻将")  or string.find(gameName,"斗地主") or string.find(gameName,"跑得快")or string.find(gameName,"柳州麻将"))   then 
            playback_btn:setVisible(true)
            -- num_lb:setPosition(cc.p(9.41,129.80))
        else
            _itemW["num_lb"]:setPosition(cc.p(9.41,400.80))
            _itemW["playback_btn"]:setVisible(false)
        end
        playback_btn:addTouchEventListener(function(sender,event)
            if event == TOUCH_EVENT_ENDED then
                ts:getData(activityId,v["roundIndex"],NickNameTable)
                dump(NickNameTable,"NickNameTable")
            end
        end)
    end 
end





return HistoryLayer