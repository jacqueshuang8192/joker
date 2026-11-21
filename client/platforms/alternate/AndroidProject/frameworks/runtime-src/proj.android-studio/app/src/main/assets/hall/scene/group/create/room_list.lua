room_list = class("room_list")

local _w = nil
local isShow = false
local s = nil
local itype = 1

function room_list:ctor()
	room_list.super.ctor(self)
end

function room_list:show(_isShow)
	-- body
	_isShow = _isShow or true
	
	if SCENENOW["scene"] then
		--释放之前的
        s = SCENENOW["scene"]:getChildByName("room_list")
        if s then
            s:removeSelf()
        end

        --添加新场景
        if device.platform == "ios" then
            if isiOSVerify then
                s = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/group/create/room_list.csb")
            else
                s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/scene/res/" .. resFolder .."/group/create/room_list.csb")
            end
        else
            s = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/group/create/room_list.csb")
        end
		s:setName("room_list")
		
		SCENENOW["scene"]:addChild(s, 9999)
		s:setVisible(_isShow)
		isShow = false
		itype = 1
		self:init(s)
		self:queryRoomList()
	end
	
end	

--获取子控件table
function room_list:loadChildrenWidget(_node, _childrenTable)
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

function room_list:init(_root)
	
	_w = self:loadChildrenWidget(_root)
	_w["refresh_bt"]:addTouchEventListener(room_list.touchEvent)
	_w["close_bt"]:addTouchEventListener(room_list.touchEvent)
	_w["select_bt"]:addTouchEventListener(room_list.touchEvent)
	
end

function room_list.touchEvent(sender, event)
	local name = sender:getName()
	if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.9)
    end
    if event == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end
	if event == TOUCH_EVENT_ENDED then
		sender:setScale(1.0)
		if name == "refresh_bt" then   --刷新
			if itype == 1 then 
				room_list:queryRoomList()
			elseif itype == 2 then 	
				room_list:RecordRoomList()
			end	
		elseif name == "close_bt" then		--关闭
			s:removeSelf()

            --刷新用户当前房卡数
            require("hall.gameScene"):queryRoomCardCount()

		elseif name == "select_bt" then		--切换页签
			if itype == 1 then		
				_w["select_bt"]:loadTextureNormal("hall/scene/res/" .. resFolder .."/image/group/room/title02.png")
				_w["select_bt"]:loadTexturePressed("hall/scene/res/" .. resFolder .."/image/group/room/title02.png")
				room_list:RecordRoomList()
				itype = 2
			elseif itype == 2 then
				_w["select_bt"]:loadTextureNormal("hall/scene/res/" .. resFolder .."/image/group/room/title01.png")
				_w["select_bt"]:loadTexturePressed("hall/scene/res/" .. resFolder .."/image/group/room/title01.png")
				room_list:queryRoomList()
				itype = 1
			end	
			
		end
	end	
end

--查询所有代开房间信息
function room_list:queryRoomList()
	-- body

	_w["title_player_txt"]:setPosition(cc.p(750,547))
	_w["title_opera_txt"]:setVisible(true)
	print("######init room list######")
	_w["room_list"]:removeAllChildren()
	local table = {}
    table["userId"] = USER_INFO["uid"]
    table["interfaceType"] = "J"
    require(NetworkLoadingView_filePath):showLoading("拼命加载中")
    cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameByOwner",
        date = table,
        type_= "GET",
        requestMsg = "",
        callBack = function(data)

            dump(data, "-----代开房间数据-----")

            local responseData = data.netData
            if responseData then
            	responseData = json.decode(responseData)
            	local roomlist = responseData.data
            		if roomlist  then
            			if #roomlist > 0 then
            				if SCENENOW["scene"] ~= nil then
            					if SCENENOW["scene"]._scene ~= nil then
        					 		--local room_list = room_panel:getChildByName("room_list")
        					 		--local content_ly = room_list:getChildByName("content_ly")
        					 		
        					 		--local _wy = self:loadChildrenWidget(roomCell)

        					 		for k,v in pairs(roomlist) do
        					 			local roomCell = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/group/create/room_layer.csb")
        					 			
        					 			--roomCell:setPosition(0, k * 130.00 * -1)
										--_w["content_ly"]:addChild(roomCell)

										local itemLayout = roomCell:getChildByName("itemLayout")
                                        --itemLayout:setTouchEnabled(false)
                                       	itemLayout:removeFromParent()
										item = itemLayout
										item:setVisible(true)

										local _itemW = room_list:loadChildrenWidget(item)

                                        local room_id = itemLayout:getChildByName("room_id")
                                        if v["inviteCode"] ~= nil then
                                        	room_id:setString(v["inviteCode"])
                                        end	

                                        local room_des = itemLayout:getChildByName("room_des")

                                        if  v["gameName"] == "抢庄牛牛" then
                                            v["gameName"] = "牛牛"   
                                        end

                                        if v["cards"] ~= nil and v["discription"] ~= nil then
                                        	room_des:setString("玩法:"..v["gameName"]..","..v["discription"]..",预扣房卡"..v["cards"].."张")
                                        elseif 	v["cards"] ~= nil and v["discription"] == nil then
                                        	room_des:setString("玩法:"..v["gameName"]..",预扣房卡"..v["cards"].."张")
                                        elseif v["cards"] == nil and v["discription"] == nil then
                                       		room_des:setString("玩法:"..v["gameName"]..",预扣房卡0张")
                                       	end                                  
                                        local room_ctime = itemLayout:getChildByName("room_ctime")
                                        if v["startDate"] ~= nil then
                                        	room_ctime:setString(os.date("%Y-%m-%d \n %H:%M:%S", v["startDate"] / 1000))
                                        end	

                                        --玩家信息
                                        local playTab = v["players"]
                                        if playTab ~= nil then
	                                        for i,j in pairs(playTab) do
	                                        	local playerpanel = itemLayout:getChildByName("player_panel" .. i)
	                                        	playerpanel:setVisible(true)

	                                        	local player_img = playerpanel:getChildByName("player_img" .. i)
	                                        	if j["photo"] ~= nil and j["nickname"] ~= nil then
	                                        		require("hall.GameCommon"):getUserHead(j["photo"], "", "", player_img, 46, false, j["nickname"])
	                                        	end
	                                        	local player_name = playerpanel:getChildByName("player_name" .. i)
	                                        	if j["nickname"] ~= nil then
	                                        		player_name:setString(require("hall.GameCommon"):formatNickToLaction(tostring(j["nickname"]), 4))
	                                        	end
	                                        end	
	                                    end    

                                        --解散房间
                                        local disband_btn = itemLayout:getChildByName("disband_btn")
                                        disband_btn:setTag(v["inviteCode"])

                                        disband_btn:addTouchEventListener(
                                        	function(sender,event)
                                        	--	local data = sender:getTag()
	                                        	if event == TOUCH_EVENT_ENDED then
	                                        		print("userData is " .. v["inviteCode"])
	                                        		local tbl = {}
													
													tbl["inviteCode"] = v["inviteCode"]
													tbl["activityId"] = tostring(v["activityId"])

													tbl["interfaceType"] = "J"

													cct.createHttRq({
												            url=HttpAddr .. "/freeGame/closeGroupGameByOwner",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
												            date=tbl,
												            type_="POST",
												            callBack = function ( data )
												            	-- body
												            	dump(data,"closeGroupGameByOwner")
													            local netData = data.netData
													            netData = json.decode(netData)
												            	if netData.returnCode == "0" then
												            		print("-------解散房间-----------------")
												            		--解散组局
												            		require(CommonTips_filePath):showTips("提示", "", 3, "解散房间成功")
												            		room_list:queryRoomList()
												            	else
												            		print("-------error-----------------")	
												            		require(CommonTips_filePath):showTips("提示", "", 3, "游戏已开始，不能解散")
												            	end
												            end
												    })
												end    
                                        	end
                                        	)

                                        --分享好友
                                        local share_btn = itemLayout:getChildByName("share_btn")

                                        share_btn:addTouchEventListener(
                                        	function (sender,event)
                                        		-- body
                                        		if event == TOUCH_EVENT_ENDED then
                                        			print("###### 分享 ###### " .. v["gameName"] .. " "..v["inviteCode"].. " "..v["activityId"].. " "..v["level"])
                                        			require("hall.common.ShareLayer"):showShareLayerWithDaiKai(v["gameName"]..",房间号:"..v["inviteCode"],v["inviteCode"], v["activityId"], v["level"],"url",v["discription"])
                                        		end	
                                        	end
                                        	)
       									

       									--复制房间信息，暂时先做成加入房间
       									local copy_btn = itemLayout:getChildByName("copy_btn")
       									copy_btn:addTouchEventListener(
       										function (send,event)
       											if event == TOUCH_EVENT_ENDED then
       												print("############ 加入房间 #############")
       												require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], false, v["level"], false)
       											end
       										end
       										)

       									_w["room_list"]:pushBackCustomItem(item)
										_w["room_list"]:jumpToTop()
        					 		end	
        					 		require(NetworkLoadingView_filePath):removeView(14)
        					 		-- _w["room_list"]:setCascadeOpacityEnabled(true)
                --                     _w["room_list"]:setInnerContainerSize(cc.size(1120.00, 130 * #roomlist ))
                --                     if #roomlist > 3 then
                --                         _w["content_ly"]:setPosition(0, 130 * #roomlist )
                --                     end
            					 	
            					end	
            				end	
            			end	
            		end	
            end	

        end    

    })        
end

--代开记录，暂时没接口，先用已开房间的接口
function room_list:RecordRoomList()
	_w["title_player_txt"]:setPosition(cc.p(850,547))
	_w["title_opera_txt"]:setVisible(false)
	--print("######init room list######")
	_w["room_list"]:removeAllChildren()
	local table = {}
    table["userId"] = USER_INFO["uid"]
    table["interfaceType"] = "J"
    require(NetworkLoadingView_filePath):showLoading("拼命加载中")
    cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryActivitiesByOwner",
        date = table,
        type_= "GET",
        requestMsg = "",
        callBack = function(data)

            dump(data, "-----代开记录数据-----")

            local responseData = data.netData
            if responseData then
            	responseData = json.decode(responseData)
            	local roomlist = responseData.data
            		if roomlist  then
            			if #roomlist > 0 then
            				if SCENENOW["scene"] ~= nil then
            					if SCENENOW["scene"]._scene ~= nil then

            						for k,v in pairs(roomlist) do
        					 			local roomCell = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/group/create/room_layer2.csb")
        			
        		-- 			 			roomCell:setPosition(0, k * 130.00 * -1)
										-- _w["content_ly"]:addChild(roomCell)

										local itemLayout = roomCell:getChildByName("itemLayout")
                                        --itemLayout:setTouchEnabled(false)

                                        itemLayout:removeFromParent()
										item = itemLayout
										item:setVisible(true)

										local _itemW = room_list:loadChildrenWidget(item)

                                        local tmpstr = v["content"]
                                        local content = json.decode(tmpstr)


                                        local room_id = itemLayout:getChildByName("room_id")
                                        if content["roomNum"] ~= nil then
                                        	room_id:setString(content["roomNum"])
                                        end	

                                        local room_des = itemLayout:getChildByName("room_des")
                                        if v["name"] ~= nil and v["discription"] ~= nil  then
                                        	room_des:setString("玩法:"..v["name"]..","..v["discription"])
                                        elseif v["name"] ~= nil and v["discription"] == nil  then
                                        	room_des:setString("玩法:"..v["name"])
                                        end	

                                        local room_ctime = itemLayout:getChildByName("room_ctime")
                                        if v["endDate"] ~= nil then
                                        	room_ctime:setString(os.date("%Y-%m-%d \n %H:%M:%S", v["endDate"] / 1000))
                                        end	

                                        	

                                        --玩家信息
                                        local playTab = content["userinfos"]
                                        if playTab ~= nil then
	                                        for i,j in pairs(playTab) do
	                                        	local playerpanel = itemLayout:getChildByName("player_panel" .. i)
	                                        	playerpanel:setVisible(true)

	                                        	local player_img = playerpanel:getChildByName("player_img" .. i)
	                                        	if j["photo_url"] ~= nil and j["nickName"] ~= nil then
	                                        		require("hall.GameCommon"):getUserHead(j["photo_url"], "", "", player_img, 46, false, j["nickName"])
	                                        	end
	                                        	local player_name = playerpanel:getChildByName("player_name" .. i)
	                                        	if j["nickName"] ~= nil then
	                                        		player_name:setString(require("hall.GameCommon"):formatNickToLaction(tostring(j["nickName"]), 4)) 
	                                        	end
	                                        	local player_score = playerpanel:getChildByName("player_score" .. i)
	                                        	if j["score"] ~= nil then
	                                        		player_score:setString("("..tostring(j["score"]).."分)")
	                                        	end
	                                        end	
	                                    end    
                                        _w["room_list"]:pushBackCustomItem(item)
										_w["room_list"]:jumpToTop()
                                    end   
                                    require(NetworkLoadingView_filePath):removeView(15)
                                    -- _w["room_list"]:setCascadeOpacityEnabled(true)
                                    -- _w["room_list"]:setInnerContainerSize(cc.size(1120.00, 130 * #roomlist ))
                                    -- if #roomlist > 4 then
                                    --     _w["content_ly"]:setPosition(0, 130 * #roomlist )
                                    -- end
                                end
                            end
                        end                
                    end
            end

        end
    })
end	

return room_list