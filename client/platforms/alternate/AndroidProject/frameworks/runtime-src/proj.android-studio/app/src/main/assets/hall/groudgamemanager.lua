
local GroudGameManager = class("GroudGameManager")
local PROTOCOL = import(HallProtocol_filePath)

---组局创建操作相关-----------

--重连游戏
function GroudGameManager:reConnectGame(level, tid, activityId, maxPlayer, userId)
	
	USER_INFO["GroupLevel"] = level
    USER_INFO["tid"] = tid
    USER_INFO["activity_id"] = activityId
    USER_INFO["player_nums"] = maxPlayer

    --if tonumber(USER_INFO["tid"]) == 0 then
    --	--当前在金币场某个分场里,退出alloc
    --	--require(HallServer_filePath):logoutAlloc(level)
		--if STATUS_GAME == true then
		--	--require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
		--end
    --	dump("退出alloc", "-----重连处理-----")
    --else
		--其他游戏，发送113登录游戏
		dump("发送113，登录游戏", "-----重连处理-----")
		require(HallServer_filePath):loginGameNew(level, tid, activityId)
    --end

end

--加入组局（包括重连加入组局和使用邀请码加入组局）
function GroudGameManager:join_freegame(user_id, invitationCode, activityId, history, level, reload,configId,isWatch)

	require(NetworkLoadingView_filePath):showLoading("加入游戏中")

	local timeOut = 20

	if  quickEnterRoom == true then   --一键复制加入房间功能时，加入房间后要重置剪切板
		require(GameSetting_filePath):resetClipboard()
	end 

	local hasReceiveCallBack = false

	--请求加入组局结果返回
	local function joinFreeGame_callback(data)

		hasReceiveCallBack = true

		local netData = data.netData
		netData = json.decode(netData)
		dump(netData,"-----请求加入组局结果返回-----")
		if netData.returnCode == "0" then

			local gameId = tonumber(netData["data"]["gameId"])
			local level  = tonumber(netData["data"]["level"])
			local tid    = tonumber(netData["data"]["tableId"])
			local activity_id = tonumber(netData["data"]["gameActivityId"])

			---加入组局成功
			USER_INFO["GroupLevel"] = tonumber(netData["data"]["level"])
			USER_INFO["tid"] = tonumber(netData["data"]["tableId"])
			USER_INFO["activity_id"] = tonumber(netData["data"]["gameActivityId"])
			USER_INFO["enter_mode"] = netData["data"]["gameId"]
			USER_INFO["enter_code"] = netData["data"]["gameCode"]
			USER_INFO["invote_code"] = netData["data"]["inviteCode"]
			USER_INFO["group_chip"] = netData["data"]["oriCoins"]
			USER_INFO["gameConfig"] = netData["data"]["activityDiscription"]
			USER_INFO["player_nums"] = netData["data"]["maxPlayer"]
			USER_INFO["isWatch"] = netData["data"]["isWatch"]

            local club_id = -1
            if USER_INFO["family_id"] then
                club_id = tonumber(USER_INFO["family_id"])
				USER_INFO["club_id"] = {["groupId"] = club_id ,
										["tid"] = USER_INFO["tid"] ,
										["activity_id"] = USER_INFO["activity_id"]
				}
            end


			dump(USER_INFO,"USER_INFO加入组局成功")
			--记录组局创建者
			USER_INFO["group_owner"] = netData["data"]["creatorId"]

			dump("界面选择游戏的 enter_mode:" .. USER_INFO["enter_mode"] .. "，enter_code：" .. USER_INFO["enter_code"], "----------")

			--设置需要检查重连
    		bm.notCheckReload = 0
	    	require(HallServer_filePath):loginGameNew(level,tid,activity_id)

		else
			require("hall.GameCommon"):landLoading(false)

			if netData.error then
                local data = {type = 1, title = "提示", content = netData.error}
				require(CommonTips_filePath):showTips(data)
			else
                local data = {type = 1, title = "提示", content = "未知错误"}
                require(CommonTips_filePath):showTips(data)
			end
 			
		end
		
	end


	SCENENOW["scene"]:performWithDelay(function()
		if hasReceiveCallBack == false then
		    --移除所有加载进度条
		    require("hall.GameCommon"):landLoading(false)
		    require(NetworkLoadingView_filePath):removeView(11)

		end
	end,timeOut)

	--请求加入组局
	local tbl = {}
    tbl["userId"] = user_id
    tbl["invitationCode"] = tostring(invitationCode)
	tbl["configId"] = configId
	tbl["isWatch"] = isWatch or 1

	tbl["type"] =  "P"
    dump(tbl, "-----请求加入组局-----")

   	cct.createHttRq({

        url = HttpAddr .. "/joinFreeGame",
        date = tbl,
        type_ = "POST",
        requestMsg = "加入房间中",
        callBack = joinFreeGame_callback

	})

end

--再来一局（包括重连加入组局和使用邀请码加入组局）
function GroudGameManager:extend_freegame(user_id, activityId)

	dump("extend_freegame-->" .. user_id .. activityId, '-----xxx')

	require(NetworkLoadingView_filePath):showLoading("加入游戏中")

	local timeOut = 20

	if  quickEnterRoom == true then   --一键复制加入房间功能时，加入房间后要重置剪切板
		require(GameSetting_filePath):resetClipboard()
	end

	local hasReceiveCallBack = false

	--请求加入组局结果返回
	local function extendFreeGame_callback(data)

		hasReceiveCallBack = true

		local netData = data.netData
		netData = json.decode(netData)
		dump(netData,"-----请求再来一局结果返回-----")
		if netData.returnCode == "0" then

			local gameId = tonumber(netData["data"]["gameId"])
			local level  = tonumber(netData["data"]["level"])
			local tid    = tonumber(netData["data"]["tableId"])
			local activity_id = tonumber(netData["data"]["gameActivityId"])

			---加入组局成功
			USER_INFO["GroupLevel"] = tonumber(netData["data"]["level"])
			USER_INFO["tid"] = tonumber(netData["data"]["tableId"])
			USER_INFO["activity_id"] = tonumber(netData["data"]["gameActivityId"])
			USER_INFO["enter_mode"] = netData["data"]["gameId"]
			USER_INFO["enter_code"] = netData["data"]["gameCode"]
			USER_INFO["invote_code"] = netData["data"]["inviteCode"]
			USER_INFO["group_chip"] = netData["data"]["oriCoins"]
			USER_INFO["gameConfig"] = netData["data"]["activityDiscription"]
			USER_INFO["player_nums"] = netData["data"]["maxPlayer"]
			USER_INFO["isWatch"] = netData["data"]["isWatch"]
			local club_id = -1
			if USER_INFO["family_id"] and tonumber(tid) > 0 then
				club_id = tonumber(USER_INFO["family_id"])
				USER_INFO["club_id"] = {["groupId"] = club_id ,
										["tid"] = USER_INFO["tid"] ,
										["activity_id"] = USER_INFO["activity_id"]
				}
			end
			dump(USER_INFO,"USER_INFO再来一局")
			--记录组局创建者
			USER_INFO["group_owner"] = netData["data"]["creatorId"]

			dump("界面选择游戏的 enter_mode:" .. USER_INFO["enter_mode"] .. "，enter_code：" .. USER_INFO["enter_code"], "----------")
			STATUS_GAME = false
			--设置需要检查重连
			bm.notCheckReload = 0
			require(HallServer_filePath):loginGameNew(level,tid,activity_id,1,USER_INFO["isWatch"])
			g_reloadGame = true--退出游戏或者返回大厅的时候清除
		else
			require("hall.GameCommon"):landLoading(false)
			local callFunc = nil
			print("")
			if USER_INFO["enter_mode"] and CLUB_ID then
				callFunc = function ()
					require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
				end
			end

			if netData.error then
				local data = {type = 1, title = "提示", content = netData.error, callBackSure = callFunc}
				require(CommonTips_filePath):showTips(data)
			else
				local data = {type = 1, title = "提示", content = "未知错误", callBackSure = callFunc}
				require(CommonTips_filePath):showTips(data)
			end

		end

	end


	SCENENOW["scene"]:performWithDelay(function()
		if hasReceiveCallBack == false then
			--移除所有加载进度条
			require("hall.GameCommon"):landLoading(false)
			require(NetworkLoadingView_filePath):removeView(12)

		end
	end,timeOut)

	--请求加入组局
	local tbl = {}
	tbl["userId"] = user_id
	tbl["activityId"] = tostring(activityId)

	tbl["type"] =  "P"
	dump(tbl, "-----请求再来一局-----")

	cct.createHttRq({

		url = HttpAddr .. "/freeGame/extendFreeGameByOthers",
		date = tbl,
		type_ = "POST",
		requestMsg = "加入房间中",
		callBack = extendFreeGame_callback

	})

end


--退出组局，（不是散组局）
function GroudGameManager:exitFreeGame(userId,invitationCode)
	-- body
	local tbl = {}
	tbl["type"] =  "P"
	tbl["userId"] = userId
	tbl["invitationCode"] = invitationCode

	cct.createHttRq({

        url=HttpAddr .. "/exitFreeGame",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
        date=tbl,
        type_="POST",
        callBack = function ( data )
        	-- body
        	dump(data,"exitFreeGame")
            local netData = data.netData
            netData = json.decode(netData)
        	if netData.returnCode == "0" then
        	print("-------exitFreeGame-----------------")
        	--退出组局成功
        	end
        end

    })

end

--解散组局
function GroudGameManager:closeFreeGame(inviteCode,activityId,rounds)
	-- body
	local tbl = {}
	tbl["inviteCode"] =  inviteCode
	tbl["activityId"] = activityId
	tbl["rounds"] = rounds

	cct.createHttRq({

        url=HttpAddr .. "/closeFreeGame",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
        date=tbl,
        type_="POST",
        callBack = function ( data )
        	-- body
        	dump(data,"closeFreeGame")
            local netData = data.netData
            netData = json.decode(netData)
        	if netData.returnCode == "0" then
        		print("-------exitFreeGame-----------------")
        		--解散组局
        	end
        end

    })

end

--查看组局记录（检查重连）
function GroudGameManager:requestGroupStatus(callback)

 	local isCallback = callback
	require(NetworkLoadingView_filePath):showLoading("加入游戏中")
 	--查看组局记录返回
	local function viewReganizeHistory_callback(data)
		require(NetworkLoadingView_filePath):removeView(888)
		dump(data, "-----检查重连返回-----")
		--验证返回数据
		local data_netData = data.netData
	    if  data_netData == nil then
	        return
	    end

	    --检查是否有未结束组局
	    local tbHistory = {}
	    data_netData = json.decode(data_netData)
		if tonumber(data_netData.returnCode) ~= 0 then
			viewMgr:showTip({text = data_netData.error})
			return
		end
	 	dump(data_netData.data, "-----当前用户未结束的组局-----")
	 	if next(data_netData.data) == nil then
	 		dump("没有未结束的组局，进行没有组局的操作", "-----检查重连-----")
	 		if isCallback ~= nil then
	 			isCallback()
	 		end
	 		return 
	 	end	

	 	--有重连数据
	 	local level = tonumber(data_netData.data["level"])
	 	local club_id = data_netData.data["groupId"]
		local tid = data_netData.data["tid"] or 0
	 	local maxPlayer = data_netData.data["maxPlayer"]
	 	local userId = data_netData.data["userId"]
		local activityId = data_netData.data["activityId"] or 0
		local is_chat = data_netData.data["is_chat"]
		USER_INFO["activity_id"] = tonumber(activityId)
		USER_INFO["tid"] = tonumber(tid)
		if is_chat then
			is_chat = tonumber(is_chat) == 1
			g_family_is_chat = is_chat
		end
		dump(tid,"tid=USER_I666NFO加入组局成功")
		dump(activityId,"activityId=USER_I666NFO加入组局成功")
		dump(club_id,"club_id=USER_I666NFO加入组局成功")
		if tonumber(club_id) and tonumber(club_id)  > 0 and tonumber(activityId) and tonumber(activityId) > 0 then

			USER_INFO["family_id"] = tonumber(club_id)

			club_id = tonumber(USER_INFO["family_id"])
			USER_INFO["club_id"] = {["groupId"] = club_id ,
									["tid"] = USER_INFO["tid"] ,
									["activity_id"] = USER_INFO["activity_id"]
			}
		end
		dump(USER_INFO,"fgeg------777777-----")

        --重连游戏
        --if STATUS_GAME then
			--if  SCENENOW["scene"].LoginRoom then
			--	SCENENOW["scene"]:LoginRoom()
			--else
		if USER_INFO["tid"] > 0 then
			self:reConnectGame(level, tid, activityId, maxPlayer, userId)
		else
			if STATUS_GAME then
				--local exitFunc = function()
					require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
				--end
				--require("hall.GameTips"):showTips("提示", "", 2, "房间已解散！",nil,exitFunc)
			end
		end

		--	end
		--else
		--	self:reConnectGame(level, tid, activityId, maxPlayer, userId)
		--end

	   
	end

	--查询当前用户组局历史记录
	dump("-----检查重连-----")
	cct.createHttRq({  
		url = HttpAddr .. "/queryUserGameStatus",
		date={
			userId = USER_INFO["uid"]
		},
		type_="POST",
		isshowfailTip = false,
		callBack = viewReganizeHistory_callback
	})

end

--创建组局
function GroudGameManager:createfreegame(user_id, create_freegame_tbl)

	--创建组局
    dump("-----创建组局-----")
	self:FreeGame(create_freegame_tbl)

end

--请求创建组局
function GroudGameManager:FreeGame(tbl)

	dump(tbl,"------请求创建组局FreeGame------")

	cct.createHttRq({
       	-- url = HttpAddr .. "/freeGame/createFreeGame",
       	url = HttpAddr .. "/freeGame/createFreeGameByOthers",
       	date = tbl,
       	type_ = "POST",
       	callBack = function(data)

       		dump(data,"-----请求创建组局返回-----")

       		self:FreeGame_callback(data)
       		
		end
	})
end

--请求创建组局返回
function GroudGameManager:FreeGame_callback(data)

	require(JoinGroup_filePath):removeInputPasswordScene()

	local data_netData = data.netData
    if data_netData == nil then
        return
    end
    data_netData = json.decode(data_netData)

    if data_netData.returnCode == "0" then
    	--创建成功的话，直接进游戏
    	dump(data_netData["data"]["gameActivityId"],"FreeGame_callback_activityId")

    	local activityId = tonumber(data_netData["data"]["activityId"] or data_netData["data"]["gameActivityId"])
		self:join_freegame(USER_INFO["uid"], data_netData["data"]["inviteCode"], activityId, true, data_netData["data"]["level"],true)
 	else
 		require("hall.GameCommon"):landLoading(false)

 		if data_netData["error"] == "房卡不足" then

	 		local jumpToBuyCard = function()
	 			require("hall.shop.ShopLayer"):showShop()
 			end
            local data = {type = 1, title = "提示", content = data_netData["error"], callBackSingleSure = handler(self, self.jumpToBuyCard)}
 			require(CommonTips_filePath):showTips(data)
 		else
            local data = {type = 1, title = "提示", content = data_netData["error"]}
 			require(CommonTips_filePath):showTips(data)
 		end

    end
    
end

function GroudGameManager:jumpToBuyCard()
    require("hall.shop.ShopLayer"):showShop()
end


--代开组局
function GroudGameManager:createAgentGame(create_agentgame_tbl, joinCallback)
	--代开组局

	dump(create_agentgame_tbl,"------请求代开组局------")
	cct.createHttRq({
       	url = HttpAddr .. "/freeGame/createFreeGameByOthers",
       	date = create_agentgame_tbl,
       	type_ = "POST",
       	callBack = function(data)

       		dump(data,"-----请求代开组局返回-----")

       		self:AgentGame_callback(data, joinCallback)
		end
	})
end

--请求代开组局返回
function GroudGameManager:AgentGame_callback(data, joinCallback)

	require(JoinGroup_filePath):removeInputPasswordScene()

	if data == nil then
        local data = {type = 1, title = "数据异常", content = "用户游戏状态异常，请稍候再试"} 
		require(CommonTips_filePath):showTips(data)
        return
	end
	
	-- dump(data,"代开组局数据")
	local data_netData = data.netData
    if 	data_netData == nil then
        return
    end

    data_netData = json.decode(data_netData)
   
	dump(data_netData,"代开组局数据")

    if data_netData.returnCode == "0" then
    	--代开成功的话
		--require(CommonTips_filePath):showTips("提示", "", 3, "创建桌子成功")
		--require("hall.GameCommon"):landLoading(true)
		--require(NetworkLoadingView_filePath):showLoading("加入房间中")
		local roominfo = data_netData.data
		if roominfo ~= nil then

       		if joinCallback and type(joinCallback) == "function" then
       			joinCallback(roominfo)
       		end

			if roominfo["isGold"] == 1 and roominfo.level ~= 2 then  --金币场

			elseif 	roominfo["isGold"] == 2 then  --房卡场
				print("open_game")
				--刷新用户当前房卡数
				--require("hall.gameScene"):queryRoomCardCount()
			
			elseif roominfo.level == 2 then    -- 猜拳

				USER_INFO["tid"] = roominfo.tableId
				USER_INFO["invote_code"] = roominfo.inviteCode
				USER_INFO["enter_code"] = "caiquan"
				USER_INFO["GroupLevel"] = roominfo.level
				USER_INFO["activity_id"] = roominfo.gameActivityId
				--print("进入猜拳.."..USER_INFO["tid"])

				local cqVersion = ""
				local tbl = {}
				tbl["gameId"] = 2
				tbl["interfaceType"] = "J"
				
				cct.createHttRq({
		            url = HttpAddr .. "/freeGame/queryFreeGameVersion",
		            date = tbl,
		            type_ = "POST",
		            
		            callBack = function(data)
		            	-- body
		            	dump(data,"请求猜拳版本")
			            local netData = data.netData
			            netData = json.decode(netData)
		            	if netData.returnCode == "0" then
		            		--print("#@!$%@##@@")
		            		cqVersion = netData.data.version
		            		--print("猜拳版本3.."..cqVersion)

		            		if require("hall.GameCommon"):getGameVersion("caiquan") == "" then
			                    --本地没有游戏
			                    if require("hall.GameUpdate"):getUpdateStatus() == 0 then
							        require("hall.GameUpdate"):queryVersionInJoinGame(2, "caiquan", 1, "猜拳")
							    end
			                elseif require("hall.GameData"):compareLocalVersion(cqVersion,"caiquan") > 0 then
			                    --本地游戏版本低
			                    print("猜拳更新2")
			                    if require("hall.GameUpdate"):getUpdateStatus() == 0 then
							        require("hall.GameUpdate"):queryVersionInJoinGame(2, "caiquan", 1, "猜拳")
							    end
			                else		
			                	require(HallServer_filePath):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"],USER_INFO["activity_id"])
					    	end	

		            	end
		            end
		 		})

			end

		end	 

		require(CreateGroup_filePath):removeScene()


 	else
 		print(" open room error ")
 		require("hall.GameCommon"):landLoading(false)
        local data = {type = 1, title = "提示", content = data_netData["error"]} 
 		-- require(CommonTips_filePath):showTips(data)
		viewMgr:showTip({text = data.content})

    end
    
end

return GroudGameManager