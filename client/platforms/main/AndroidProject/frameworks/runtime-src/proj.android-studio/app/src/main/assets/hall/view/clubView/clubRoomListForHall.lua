function clubView:requestAllRooms(room_list_lv,room_list_item,roomType)

	local function loadRoomList(data)

		if tolua.isnull(room_list_lv) then
			dump("控件不存在！")
			return
		end

		room_list_lv:removeAllChildren()

    	for i,room_info in pairs(data) do

    		-- local room_info = json.decode(room_info)

    		dump(room_info,"room_info")

    		if  tolua.isnull(room_list_item) then
    			break
    		end

    		local activityId = room_info["activityId"]

        	local room_list_item = room_list_item:clone()
        	room_list_item:setVisible(true)
        	local gameType_txt = room_list_item:getChildByName("gameType_txt")
        	local table_index_txt = room_list_item:getChildByName("table_index_txt")
       		local baseChip_txt = room_list_item:getChildByName("baseChip_txt")
       		local playerNum_txt = room_list_item:getChildByName("playerNum_txt")
       		local totalRound_txt = room_list_item:getChildByName("totalRound_txt")
       		local invite_bt = room_list_item:getChildByName("invite_bt")
        		local invite_bt_text = invite_bt:getChildByName("Text")

       		local gameConfig = json.decode(room_info.json) or {}
       		dump(gameConfig,"requestAllRooms_gameConfig")
	    	local encrypt_flag = room_list_item:getChildByName("encrypt_flag")
	    	if encrypt_flag then
	    		local password = gameConfig["password"]
		        encrypt_flag:setVisible(password and password ~= "")
		    end

       		local round = gameConfig["round"] or 0
       		local maxPlayer = #room_info.players or 0
        	gameType_txt:setString(room_info.gameName)
        	table_index_txt:setString(room_info.inviteCode)
        	totalRound_txt:setString( round.. "局")
        	playerNum_txt:setString(maxPlayer.. "人")
        	baseChip_txt:setString(gameConfig["times"])
        	invite_bt_text:setString("加入")

        	invite_bt_text:setTouchEnabled(false)
        	invite_bt:addTouchEventListener(function(sender,event)

    			if 	event == TOUCH_EVENT_ENDED then
    				dump("请求加入")

    				local joinFunc = function()

	    				if  room_info.isGold == 1 then
	    					require(HallServer_filePath):loginGameNew(room_info["level"],room_info["tableId"],room_info["gameActivityId"])
	    				else
	    					require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], room_info["inviteCode"], room_info["gameActivityId"], true, room_info["level"], false)
	    				end

	    			end

            		local txts = {}
				    txts["title"] = "提示"
				    txts["sureBt_txt"]  = "确定"
				    txts["cancelBt_txt"] =  "取消"
				    txts["msg"] = "是否加入?"

            		local customfunc = {}
					customfunc["cancel_func"] = function() end
				    customfunc["sure_func"]  = joinFunc

        			require("hall.GameTips"):showCustomTips(txts,customfunc,1)

    			end

    		end)

        	room_list_lv:pushBackCustomItem(room_list_item)

        end

    end

    --房卡场
	if  roomType == 1 then

		room_list_lv:performWithDelay(function()
			dump("重置请求接口限制")
			forbitfrequentRequests_friendRoom = false
		end,2)

		if  forbitfrequentRequests_friendRoom == true and next(friendRoomListCache) then
			loadRoomList(friendRoomListCache)
			return
		end

		forbitfrequentRequests_friendRoom = true


	--联盟
	elseif  roomType == 2 then

		SCENENOW["scene"]:performWithDelay(function()
			dump("重置请求接口限制")
			forbitfrequentRequests_clubRoom = false
		end,2)

		if  forbitfrequentRequests_clubRoom == true and next(clubRoomsCache) then
			loadRoomList(clubRoomsCache)
			return
		end

		forbitfrequentRequests_clubRoom = true
	end

	cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameByOwner",
        date={
            userId = USER_INFO["uid"],
            roomType = roomType
        },
        type_="GET",
        callBack = function(data)

        local responseData = data.netData

        if responseData then
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            if 	returnCode == "0" then
            	dump(responseData.data,"requestAllRooms")
            	loadRoomList(responseData.data)

            	if  roomType == 1 then
            		friendRoomListCache = responseData.data
            	elseif  roomType == 2 then
					clubRoomsCache = responseData.data
            	end

            end
        end

	end})

end