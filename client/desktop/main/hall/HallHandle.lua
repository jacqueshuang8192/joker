require("framework.init")

--导入套接字请求处理l
local PROTOCOL = import("hall.HALL_PROTOCOL")

--定义大厅请求处理类
local HallHandle = class("HallHandle")
-- local Control = require("hall.Control")
local eventName = "HallHandle"
function HallHandle:addHandleMgr( )
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._eventHandles = {}
    for k,v in pairs(self.func_) do
        self._eventHandles[eventName..k] = self:addEventListener(eventName..k, handler(self, self.handleEventMgr))
    end
end

function HallHandle:handleEventMgr( event )
    local pack = event.pack
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

function HallHandle:delHandleMgr()   --当场景销毁时应该删除事件 调用此方法
    for name,handler in pairs(self.func_) do
        local eventHandle = self._eventHandles[eventName..name]
        self:removeEventListener(eventHandle)
        self._eventHandles[eventName..name] = nil
    end
end

--[[
	冻结事件协议触发，这个仅为客户端行为，事件数据缓存在客户端，解冻时在触发事件分派行为
	@param protoEvent 要冻结的事件协议
	@param keepLast 对于同一协议，是否只保留最后一次缓存数据
]]
function HallHandle:freezeEvent(cmd, keepLast)
	if self.frozenEvents[cmd] == nil then
		self.frozenEvents[cmd] = {}
    end
	self.frozenEvents[cmd].keepLast = keepLast
end

--[[
	解结事件协议, 解冻后会马上触发已经缓存的事件分派行为
	@param protoEvent 要冻结的事件协议
	@param clear  如果为该值为真，则只会清楚缓存的事件数据，而不会触发事件分派行为
]]
function HallHandle:unfreezeEvent(cmd, clear)
	local item = self.frozenEvents[cmd]
	if item then
		self.frozenEvents[cmd] = nil
		if #item == 0 or clear then
			return
		end
		for _, pack in ipairs(item) do
			if pack == true then
				pack = nil
			end
            local ok, msg = xpcall(function() 
                self:dispatchEvent({ name = eventName..cmd, pack = pack})
            end, debug.traceback)
			if not ok then
				print(msg)
			end
			if item.keepLast then
				break
			end
		end
	end
end

function HallHandle:ctor()
    -- Control:Init()
    self.frozenEvents = {}
	self.func_ = {
        --当前玩家被服务器断网
        [PROTOCOL.SVR_CLOSE_NET] = {handler(self, HallHandle.SVR_CLOSE_NET)},
        --当前玩家被踢下线
        [PROTOCOL.SVR_KICK_OFF] = {handler(self, HallHandle.SVR_KICK_OFF)},
        --服务器返回进入游戏
        [PROTOCOL.SVR_LOGIN_GAME] = {handler(self, HallHandle.SVR_LOGIN_GAME)},  --210
        --登录成功
        [PROTOCOL.SVR_LOGIN_OK] = {handler(self, HallHandle.SVR_LOGIN_OK)}, 
        --进入房间失败
        [PROTOCOL.SVR_ENTER_ROOM_FAIL] = {handler(self, HallHandle.SVR_ENTER_ROOM_FAIL)}, 

        --接收服务器放回的指定用户信息
        [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, HallHandle.SERVER_CMD_HALL_GET_MESSAGE)}, 

        --登录alloc返回
        [PROTOCOL.SERVER_CMD_LOGIN_ALLOC] = {handler(self, HallHandle.SERVER_CMD_LOGIN_ALLOC)},

        --创建桌子返回
        --[PROTOCOL.SERVER_CMD_CREAT_TABLE] = {handler(self, HallHandle.SERVER_CMD_CREAT_TABLE)},



        --用户当前IP
        [PROTOCOL.SERVER_USER_IP] = {handler(self, HallHandle.SERVER_USER_IP)}, 

        --返回联盟桌子信息
        [PROTOCOL.TABLE_DATA] = {handler(self, HallHandle.TABLE_DATA)},
        --更新联盟桌子信息
        [PROTOCOL.TABLE_DATA_CHANGE] = {handler(self, HallHandle.TABLE_DATA_CHANGE)},
        [PROTOCOL.B2A_HALL_GAME_PLAY_TO_SERVER] = {handler(self, HallHandle.B2A_HALL_GAME_PLAY_TO_SERVER)},
        [PROTOCOL.TABLE_DATA_NEW] = {handler(self, HallHandle.TABLE_DATA_NEW)},
        [PROTOCOL.TABLE_DATA_NEW_TEMP] = {handler(self, HallHandle.TABLE_DATA_NEW_TEMP)},
        [PROTOCOL.SERVER_COMMAND_UPDATE_GAME_ROUND] = {handler(self, HallHandle.SERVER_COMMAND_UPDATE_GAME_ROUND)},
        [PROTOCOL.SERVER_COMMAND_ERROR] = {handler(self, HallHandle.SERVER_COMMAND_ERROR)},
        --0x177   --禁用某个玩家玩游戏
        [PROTOCOL.SERVER_DISABLE_USER_GAME] = {handler(self, HallHandle.SERVER_DISABLE_USER_GAME)},
        [PROTOCOL.SERVER_USER_GAME_STATUS] = {handler(self, HallHandle.SERVER_USER_GAME_STATUS)},
        [PROTOCOL.SERVER_CMD_TABLE_COUNT] = {handler(self, HallHandle.SERVER_CMD_TABLE_COUNT)},
        [PROTOCOL.SERVER_COMMAND_ONLINE] = {handler(self, HallHandle.SERVER_COMMAND_ONLINE)},
        [PROTOCOL.SERVER_COMMAND_ONLINE_END] = {handler(self, HallHandle.SERVER_COMMAND_ONLINE_END)},

        [PROTOCOL.SERVER_CMD_ENET_GAME] = {handler(self, HallHandle.SERVER_CMD_ENET_GAME)},
        [PROTOCOL.SERVER_CMD_JOIN_TABLE] = {handler(self, HallHandle.SERVER_CMD_JOIN_TABLE)},
        [PROTOCOL.B2A_HALL_SEND_PLAYER_MSG_TO_SERVER] = {handler(self, HallHandle.B2A_HALL_SEND_PLAYER_MSG_TO_SERVER)},
    }
    -- self:addHandleMgr()
end


--协议数据返回
function HallHandle:callFunc(pack)
    print("===== HallHandle:callFunc 收到服务器响应 =====")
    print("  cmd:", pack.cmd)
    dump(pack, "完整的响应包:")
    -- self:dispatchEvent({ name = eventName..pack.cmd, pack = pack})
	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        print("  找到对应的处理函数，开始处理...")
        self.func_[pack.cmd][1](pack)
    else
        print("  警告：未找到 cmd", pack.cmd, "对应的处理函数")
    end
    --if pack.cmd == PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE then 
        -- Control:RegisterProtocol("OnSERVERHALLGETMESSAGE" , pack)
    --end
end

function HallHandle:SERVER_DISABLE_USER_GAME(pack)
    local txt = pack.code == 1 and "操作成功！" or "操作失败！"
    viewMgr:showTip({text = txt})
    dump(pack)
end

--接收大厅服务器放回的指定用户信息
function HallHandle:SERVER_CMD_HALL_GET_MESSAGE(pack)

    dump(pack, "-----SERVER_CMD_HALL_GET_MESSAGE-----")

    local uid = pack.uid
    -- if uid == USER_INFO["uid"] then
        local msg = json.decode(pack.msg)
        if msg ~= nil then

            local type = msg.type


            if type == "exchangeGold" then
                        
                --金币数
                local count = msg.count
                USER_INFO["gold"] = USER_INFO["gold"] + count

                -- require("hall.GameScene"):updateGoldAndRoomCard()

            elseif type == "exchangeRoomCard" then
                        
                --金币数
                local count = msg.count
                USER_INFO["cardCount"] = USER_INFO["cardCount"] + count

                -- require("hall.GameScene"):updateGoldAndRoomCard()

            elseif type == "invitePlayerGroup" then   --被邀请加入，刷新消息即可

                -- local clubView = require("hall.view.clubView.clubView")
                -- clubView:requestJoinNews(5)
                -- dump(msg, "-----联盟相关日志1-----")
                if g_hallMainLayer and g_hallMainLayer.FamilyHelpTip then
                    g_hallMainLayer:FamilyHelpTip()
                end
                
            elseif type == "apply4JoinClub" then   -- 申请加入，刷新消息即可
                -- if g_hallMainLayer and g_hallMainLayer.FamilyHelpTip then
                --     g_hallMainLayer:FamilyJoinClub()
                -- end
                if USER_INFO["msgCount"] then
                    USER_INFO["msgCount"] = USER_INFO["msgCount"] + 1
                else
                    USER_INFO["msgCount"] = 1
                end
                
                if g_hallMainLayer and g_hallMainLayer.btnMsgRed then
                    if USER_INFO["msgCount"] and USER_INFO["msgCount"] > 0 then
                        g_hallMainLayer.btnMsgRed:setVisible(true)
                    else
                        g_hallMainLayer.btnMsgRed:setVisible(false)
                    end
                end

            elseif type == "joinPlayerGroup" then   --申请加入，刷新消息即可

                -- local clubView = require("hall.view.clubView.clubView")
                -- clubView:requestJoinNews()
                dump(msg, "-----联盟相关日志1-----")

                -- if  g_hallMainLayer.familyCreateLayer and  g_hallMainLayer.familyCreateLayer.familyMainlayer and 
                --     g_hallMainLayer.familyCreateLayer.familyMainlayer.familyNews 
                --     and g_hallMainLayer.familyCreateLayer.familyMainlayer.familyNews.RushListView then 
                    -- require("hall.familyCircle.FamilyData"):RemoveCommonTip()
                                        -- g_hallMainLayer.familyCreateLayer.familyMainlayer.familyNews:RushListView("join")

                    --require("hall.familyCircle.FamilyFacade"):RushListView("join")

                    -- require("hall.familyCircle.FamilyData"):RemoveCommonTip()
                -- end 

            elseif type == "sure2group" then  --同意加入，刷新消息+刷新联盟列表

                -- local clubView = require("hall.view.clubView.clubView")
                -- clubView:refreshClubList()
                -- local family_obj =  require("hall.familyCircle.FamilyData"):GetFamilyObj()
                -- family_obj:removeFromParent()

                -- local family_list = require("hall.familyCircle.FamilyCreateLayer").new():addTo(g_hallMainLayer)
                -- family_list:ObserFamilyList()
                dump(pack, "同意加入------------------")
                -- if g_hallMainLayer.familyCreateLayer and  g_hallMainLayer.familyCreateLayer.ShowFamilyList then
                --    g_hallMainLayer.familyCreateLayer:ShowFamilyList()
                -- end
                  --
                ---- clubView:requestJoinNews()
                --dump(msg, "-----联盟相关日志2-----")
                if g_hallMainLayer then
                   g_hallMainLayer:loadClub()
                end
            elseif type == "addHhr" then  --成为合伙人，刷新消息+刷新联盟列表
                dump(pack, "成为合伙人------------------")
                if g_hallMainLayer then
                   g_hallMainLayer:loadClub()
                end
            elseif type == "updatePoint" then  --更新积分
                dump(pack, "更新积分------------------")
                if g_hallMainLayer then
                    if g_hallMainLayer.familyMainlayer and msg.groupId == tonumber(g_hallMainLayer.familyMainlayer.family_id) then
                         g_hallMainLayer.familyMainlayer:RequestCludScore()
                        --  FamilyMainLayer:InitGame(family_id)
                        if msg.coins and msg.coins ~= 0 and msg.handNickName then
                            local tip = ''
                            if msg.coins > 0 then
                                tip = '玩家:' .. msg.handNickName .. '(' .. msg.handUid .. ')给你上了:' .. msg.coins/100 .. '积分'
                            else
                                tip = '玩家:' .. msg.handNickName .. '(' .. msg.handUid .. ')给你下了:' .. msg.coins/100 .. '积分'
                            end
                            viewMgr:showTip({text = tip})
                        end
                    end
                 end
            elseif type == "delPlayer4Group" or type == "delMember"
            or type == "jiesanRoom"
            or type == "setManager"
            or type == "transferClubOwner"
            or type == "removeHhr" then  --删除成员，解散联盟,删除合伙人 刷新消息+刷新联盟列表
                dump(pack, "删除成员------------------")
                if g_hallMainLayer then
                   g_hallMainLayer:loadClub()
                   if g_hallMainLayer.familyMainlayer and msg.groupId == tonumber(g_hallMainLayer.familyMainlayer.family_id) then
                        g_hallMainLayer.familyMainlayer:removeSelf()
                   end
                end
            -- elseif type == "removeHhr" then   --解散联盟，刷新联盟列表
            --     --local clubView = require("hall.view.clubView.clubView")
            --     --clubView:refreshClubList()
            --     --dump(msg, "-----联盟相关日志6-----")
            --     dump(pack, "解散联盟------------------")
            --     if g_hallMainLayer then
            --        g_hallMainLayer:loadClub()
            --     end
            elseif type == "notsure2group" then --拒绝加入，刷新消息即可

                --local clubView = require("hall.view.clubView.clubView")
                --clubView:requestJoinNews()
                --dump(msg, "-----联盟相关日志3-----")

            elseif type == "createRoom" then   --创建房间，刷新对应联盟的列表和数据

                --local clubView = require("hall.view.clubView.clubView")
                --clubView:refreshClubRooms(tonumber(msg.groupId))
                --local data = json.decode(msg.data)
                --dump(msg, "-----联盟相关日志4-----")

            elseif type == "closeRoom" then   --删除房间，刷新对应联盟的列表和数据

                --local clubView = require("hall.view.clubView.clubView")
                --clubView:refreshClubRooms(tonumber(msg.groupId))
                --local data = json.decode(msg.data)
                --dump(msg, "-----联盟相关日志5-----")

            elseif type == "updateClubConfig" then --刷新对应联盟的列表和数据
                if g_hallMainLayer then
                    g_hallMainLayer:loadClub()
                    if g_hallMainLayer.familyMainlayer and msg.groupId == tonumber(g_hallMainLayer.familyMainlayer.family_id) then
                        local msg = json.decode(pack.msg)
                        local config = json.decode(msg.data)
                        --  g_hallMainLayer.familyMainlayer:set_bt_items(config)
                         g_hallMainLayer.familyMainlayer:removeSelf()

                    end
                 end
            end

        end

    -- end
end

--0212
function HallHandle:SVR_ENTER_ROOM_FAIL(pack)
    dump(pack,"SVR_ENTER_ROOM_FAIL")
    require(NetworkLoadingView_filePath):removeView(7)
    require("hall.GameCommon"):landLoading(false)

    local errorTips = {
        [1] = "房间已解散!",
        [2] = "房间人数已满",
        [3] = "房间密码错误",
        [4] = "游戏已开始，无法进入房间",
        [5] = "积分不足!",
        [6] = "您被禁止加入游戏！",
        [7] = "房卡不足！",
        [8] = "距离过短禁止加入！",
        [9] = "相同ip禁止加入！",
        [10]="请创建玩法！",
        [11]="服务器升级中！",
        [12]="您被群主限制与某玩家同桌",
    }

    if  errorTips[pack.errorCode] then
        if pack.errorCode == 1 then
            if SCENENOW["name"] ~= GameScene_filePath then
                local exitFunc = function()
                    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                end
                require("hall.GameTips"):showTips("提示", "", 2, errorTips[pack.errorCode],nil,exitFunc)
            else
                viewMgr:showTip({text = errorTips[pack.errorCode]})
            end
            return
        end
        dump(pack.errorCode,"pack.errorCode")
        dump(STATUS_GAME,"pack.STATUS_GAME")
        if pack.errorCode == 2 then
            if SCENENOW["name"] ~= GameScene_filePath then
                local exitFunc = function()
                    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                end
                require("hall.GameTips"):showTips("提示", "", 2, errorTips[pack.errorCode],nil,exitFunc)
            else
                viewMgr:showTip({text = errorTips[pack.errorCode]})
            end
            return
        end
        if  pack.errorCode == 5 or pack.errorCode == 4 or pack.errorCode ==6 or pack.errorCode == 2  or pack.errorCode == 7 
            or pack.errorCode == 8 or pack.errorCode == 9 or pack.errorCode ==12 or pack.errorCode ==11 then --快速进入房间失败
            viewMgr:showTip({text = errorTips[pack.errorCode]})
        elseif pack.errorCode == 10 then
            if makeroom then
                makeroom.config=makeroom.gameConfig
                makeroom.flag=1
                makeroom.gameConfig = nil
                dump(makeroom,"------makeroom-------")
                g_hallMainLayer.familyMainlayer:CreateGameTable(1, makeroom , nil, 1)
            else
                viewMgr:showTip({text = errorTips[pack.errorCode]})
            end 
        else
            viewMgr:showTip({text = "请稍后再试!"})
        end
    else
        viewMgr:showTip({text = "请稍后再试!"})
    end

end


--大厅Socket连接成功
function HallHandle:SVR_LOGIN_OK(pack)

    dump(pack, "-----大厅Socket连接成功-----")

    USER_INFO["saveProvinceId"] = cc.UserDefault:getInstance():getIntegerForKey("saveProvinceId", 0)

    if  isSingleCityMode then
        USER_INFO["saveProvinceId"] = 440000
    end

    if  isiOSVerify then
        USER_INFO["saveProvinceId"] = 510000
    end

    if  pack then

        if pack["Ver"] == 1 then

            print("", "-----Socket返回登录成功，当前是否为断线重连-----", bm.netdisConnect)

            if  bm.netdisConnect then
                dump("断线重连")
                
                --网络重连成功，请求组局历史记录，重连游戏
                bm.netdisConnect = false
                bm.notCheckReload = 0

                print("----------bm.isInGame----------次进入",bm.isInGame)
                require(HallServer_filePath):cliUserGameStatus()
                --[[
                if bm.isInGame then
                    if  SCENENOW["name"] == GameScene_filePath or SCENENOW["name"] == "hall.hallScene" then
                        -- display_scene(GameScene_filePath, 1)

                        require("hall.groudgamemanager"):requestGroupStatus()
                    else

                        --local callback = function ()
                        --    --package.loaded[GameScene_filePath] = nil
                        --    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        --end
                        require("hall.groudgamemanager"):requestGroupStatus()
                    end
                
                else
                    --local callback = function ()
                    --    package.loaded[GameScene_filePath] = nil
                    --    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                    --end
                    if is_club_scene then
                        dump("进入大厅")
                        SCENENOW["scene"]:loadClubForRoom()
                    end
                    require("hall.groudgamemanager"):requestGroupStatus()
                end
                --]]
                if is_club_scene and SCENENOW["scene"].loadClubForRoom then
                    dump("进入大厅")
                    SCENENOW["scene"]:loadClubForRoom()
                end
            else
                dump("第一次连接大厅，进入大厅界面")
                --第一次连接大厅，进入大厅界面
                require("hall.GameCommon"):landLoading(false)
                require("hall.GameCommon"):setLoadingProgress(100)

                USER_INFO["saveProvinceId"] = cc.UserDefault:getInstance():getIntegerForKey("saveProvinceId", 0)

                if  isSingleCityMode then
                    USER_INFO["saveProvinceId"] = 440000
                end

                if  isControl then
                    USER_INFO["saveProvinceId"] = 440000
                end

                if  isiOSVerify then
                    -- USER_INFO["saveProvinceId"] = 510000

                    USER_INFO["saveProvinceId"] = 440000
                    
                end
                --package.loaded[GameScene_filePath] = nil
                display_scene(GameScene_filePath, 1)
            end

        end

    end

end

--服务器返回登录游戏成功，检查游戏版本，进入游戏 0210
function HallHandle:SVR_LOGIN_GAME(pack)

    dump(pack, "-----进入游戏，113返回的210协议-----")

    --require(NetworkLoadingView_filePath):removeView()
    -- require("hall.GameCommon"):landLoading(false)
    --记录tid
    --if  USER_INFO["tid"] ~= pack.Tid and USER_INFO["tid"] and USER_INFO["tid"] ~= 0 then
    --    local data = {type = 1, title = "提示", content = "您有未结束的组局"}
    --    require("hall.tips.CommonTips"):showTips(data)
    --end
    dump(STATUS_GAME,"STATUS_GAME==")
    if STATUS_GAME  then
        if pack.Tid <= 0 then
            local exitFunc = function()
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
            end

            require("hall.GameTips"):showTips("提示", "", 2, "房间已经解散!",nil,exitFunc)

            return
        end
    end

    USER_INFO["tid"] = pack.Tid
    USER_INFO["activity_id"] = tonumber(pack.activityId or USER_INFO["activity_id"])
    USER_INFO["player_nums"] = pack.player_nums
    USER_INFO["Res"] = pack.Res
    USER_INFO["isWatch"] = pack.isWatch
    USER_INFO["roomPassword"] = pack.roomPassword   --密码房的房间密码
    USER_INFO["level"] = pack.level   --记录游戏id
    is_club_scene = false
    if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
        g_hallMainLayer.familyMainlayer = nil
    end
    dump(USER_INFO,"USER_INFO_club")
    --非上架，检查本地版本号
    if pack.level == 2 then

        USER_INFO["enter_code"] = "caiquan"
        -- USER_INFO["GroupLevel"] = 2

        bm.isInGame = true

        --通知本地退出房间
        require("hall.util.GameUtil"):LogoutRoom()

        --标记呀呀语音进入房间
        require("hall.util.YaYaVoiceServerUtil"):LoginRoom()

        --通知本地加入房间
        require("hall.util.GameUtil"):LoginRoom(USER_INFO["invote_code"])

        TpackageName = USER_INFO["enter_code"]

        --本地游戏可用，直接进入游戏
        if require("hall.GameCommon"):getGameVersion(USER_INFO["enter_code"]) == "" then
            --本地没有游戏
            dump("本地没有游戏")
            if require("hall.GameUpdate"):getUpdateStatus() == 0 then
                require("hall.GameUpdate"):queryVersionInJoinGame(2, USER_INFO["enter_code"], 1, USER_INFO["joinGameName"])
            end

        elseif require("hall.GameData"):compareLocalVersion(USER_INFO["enter_code_version"], USER_INFO["enter_code"]) > 0 then
            --本地游戏版本低
            dump("本地游戏版本低")
            if  require("hall.GameUpdate"):getUpdateStatus() == 0 then
                require("hall.GameUpdate"):queryVersionInJoinGame(2, USER_INFO["enter_code"], 1, USER_INFO["joinGameName"])
            end

        else

            require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
            return
        end
    end

    local gameList = bm.allGameList
    if  gameList == nil then
        local level = USER_INFO["GroupLevel"] or 0
        local msg = "SVR_LOGIN_GAME时gameList为空"
        require(Request_filePath):upLoadAppMessage(1, "当前level：" .. level .. ",当前错误信息：" .. msg)
        return
    end

    for k,v in pairs(gameList) do
        if v.level == pack.level then
            USER_INFO["joinGameName"] = v.name
            USER_INFO["enter_mode"] = v.gameId
            USER_INFO["enter_code"] = v.code
            USER_INFO["enter_code_version"] = v.version
            USER_INFO["GroupLevel"] = pack.level

            if  USER_INFO["gameConfig"] == nil or USER_INFO["gameConfig"] == "" then
                USER_INFO["gameConfig"] = pack.shortGameConfig
            end

            bm.isInGame = true

            --通知本地退出房间
            require("hall.util.GameUtil"):LogoutRoom()

            --标记呀呀语音进入房间
            require("hall.util.YaYaVoiceServerUtil"):LoginRoom()

            --通知本地加入房间
            require("hall.util.GameUtil"):LoginRoom(USER_INFO["invote_code"])



            TpackageName = USER_INFO["enter_code"]
            if STATUS_GAME and  SCENENOW["scene"].LoginRoom then
                STATUS_GAME = true
                SCENENOW["scene"]:LoginRoom()
 
                break
            end
            STATUS_GAME = true
            if isCheckControl then
                --查询游戏控制情况,这里面加入了判断
                require(Request_filePath):getGameControl()

            end

            -- if isiOSVerify then
            --     --上架版，直接加入游戏
            --     dump("上架版，直接加入游戏")
            --     if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
            --         g_hallMainLayer.familyMainlayer = nil
            --     end
            --     require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])

            -- else
            --     --非上架，检查本地版本号
            --     dump("非上架，检查本地版本号")
            --     local bShowMash = 0
            --     if v.name ~= "-1"  then

            --         if v.code ~= nil then

            --             if require("hall.GameCommon"):getGameVersion(USER_INFO["enter_code"]) == "" then
            --                 --本地没有游戏
            --                 -- dump("本地没有游戏")
            --                 if require("hall.GameUpdate"):getUpdateStatus() == 0 then
            --                     require("hall.GameUpdate"):queryVersionInJoinGame(USER_INFO.enter_mode, USER_INFO.enter_code, 1, USER_INFO.joinGameName)
            --                 end
            --             else

            --                 -- dump("本地游戏版本低")
            --                 if  require("hall.GameUpdate"):getUpdateStatus() == 0 then
            --                     require("hall.GameUpdate"):queryVersionInJoinGame(USER_INFO.enter_mode, USER_INFO["enter_code"], 1, USER_INFO["joinGameName"])
            --                 end
            --             end

            --         end
            --     end
            -- end


            break
        end
    end

end

--客户端socket被断
function HallHandle:SVR_CLOSE_NET(pack)

    dump(pack, "-----SVR_CLOSE_NET-----")
    local data = {type = 1, title = "提示", content = "网络异常，请检查网络", callBackSingleSure = handler(self, self.goToMainScene)} 
    require("hall.tips.CommonTips"):showTips(data)
end

function HallHandle:goToMainScene()
    local nextScene = require("src.app.scenes.MainScene").new()
    SCENENOW["scene"] = nextScene
    SCENENOW["name"] = "app.scenes.MainScene"
    display.replaceScene(nextScene)
end

--客户端被踢
function HallHandle:SVR_KICK_OFF(pack)

    dump(pack, "-----SVR_KICK_OFF-----")
    local data = {type = 1, title = "提示", content = "小爱为您更好的体验游戏，请重新登入！"} 
    require("hall.tips.CommonTips"):showTips(data)

    --显示登录页
    require("hall.login.LoginLayer"):show()

end


--用户当前IP
function HallHandle:SERVER_CMD_LOGIN_ALLOC(pack)
    require("hall.scene.group.join.table_list"):updateTableData(pack, "allroom")
end

function HallHandle:SERVER_USER_IP(pack)

    dump(pack, "-----SERVER_USER_IP-----")

    --更新用户IP地址
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(USER_INFO["uid"],{ip = pack.IP},"ip")

end



local startCollectData = false 
local tableData = {} 

---返回联盟桌子信息
function HallHandle:TABLE_DATA(pack)
    dump(pack)
    print("----g_hallMainLayer",g_hallMainLayer)
    if g_hallMainLayer then
        print("----g_hallMainLayer.familyMainlayer",g_hallMainLayer.familyMainlayer)
        if g_hallMainLayer.familyMainlayer then
            print("----g_hallMainLayer.familyMainlayer.TestData_News",g_hallMainLayer.familyMainlayer.TestData_News)
        end
    end
    --is_end 是代表数据是否结束 0 是还未结束还会继续发，1是结束不会继续发过来
    if g_hallMainLayer and g_hallMainLayer.familyMainlayer and  g_hallMainLayer.familyMainlayer.TestData_News then
        print("----TABLE_DATA")
        local familyMainlayer = g_hallMainLayer.familyMainlayer
        local tableData = pack.table_data or {}
        for _, tableInfo in ipairs(tableData) do
            if tonumber(familyMainlayer.family_id) == tonumber(tableInfo.club_id) then
                familyMainlayer:TestData_News(tableInfo)
            end
        end
        if tonumber(pack.is_end) == 1 then
            familyMainlayer:isEndSendData()
        end
    end
end

--更新联盟桌子信息

function HallHandle:TABLE_DATA_CHANGE(pack)
    pack.user_list = pack.user_list or {}
    if g_hallMainLayer and g_hallMainLayer.familyMainlayer and  g_hallMainLayer.familyMainlayer.DelarWith then
        if tonumber(g_hallMainLayer.familyMainlayer.family_id) == tonumber(pack.club_id) then
            dump( pack,"-----TABLE_DATA_CHANGE-----173")
            g_hallMainLayer.familyMainlayer:DelarWith(pack , pack.type)
        end
    end
end

function HallHandle:TABLE_DATA_NEW(pack)
    if g_hallMainLayer and g_hallMainLayer.familyMainlayer and  g_hallMainLayer.familyMainlayer.TestData_News then
        if tonumber(g_hallMainLayer.familyMainlayer.family_id) == tonumber(pack.club_id) then
            dump(pack)
            g_hallMainLayer.familyMainlayer:TestData_News(pack)
        end
    end
end

function HallHandle:TABLE_DATA_NEW_TEMP(pack)
    if g_hallMainLayer and g_hallMainLayer.familyMainlayer and  g_hallMainLayer.familyMainlayer.TABLE_DATA_NEW_TEMP then
        if tonumber(g_hallMainLayer.familyMainlayer.family_id) == tonumber(pack.club_id) then
            g_hallMainLayer.familyMainlayer:TABLE_DATA_NEW_TEMP(pack)
        end
    end
end

function HallHandle:B2A_HALL_GAME_PLAY_TO_SERVER(pack)

    local  config = {}
    if type(pack.table_info) == "string" then
        config = json.decode(pack.table_info)
    elseif type(pack.table_info) == "table" then
        config = pack.table_info
    end

    print(config,"B2A_HALL_GAME_PLAY_TO_SERVERconfig")

    if g_hallMainLayer and g_hallMainLayer.familyMainlayer and  g_hallMainLayer.familyMainlayer.addConfigData then
        if tonumber( g_hallMainLayer.familyMainlayer.family_id) == tonumber(pack.club_id)  then
            if pack.type == 2 or pack.type == 1 then
                if next(config) then
                    local FloorData = {}
                    FloorData.name = pack.name
                    FloorData.gameName = pack.name
                    FloorData.gameLevel = config.level
                    FloorData.level = config.level
                    FloorData.gameType = pack.gameType
                    FloorData.id = pack.configId
                    FloorData.gameConfig = config
                    FloorData.gameConfig.name = pack.name
                    FloorData.gameConfig.id = pack.configId
                    dump(pack.club_id,"pack.club_id")
                    FloorData.gameConfig.tempGameType = pack.gameType
                    g_hallMainLayer.familyMainlayer:addConfigData(FloorData)
                end

            elseif pack.type == 3 then
                g_hallMainLayer.familyMainlayer:delConfigData(pack.gameType, pack.configId)
            end
        end

    end

end

function HallHandle:SERVER_COMMAND_UPDATE_GAME_ROUND(pack)
    if g_hallMainLayer and g_hallMainLayer.familyMainlayer and  g_hallMainLayer.familyMainlayer.setTableNodeRundByTableId then
        g_hallMainLayer.familyMainlayer:setTableNodeRundByTableId(pack)
    end
end

function HallHandle:SERVER_USER_GAME_STATUS(pack)
    dump(pack, "=========SERVER_USER_GAME_STATUS===收到重连状态数据========")
    local level = tonumber(pack.Level) or 0
    local tid = tonumber(pack.tid) or 0
    local activityId = tonumber(pack.activity_id) or 0

    USER_INFO["activity_id"] = activityId
    USER_INFO["tid"] = tid
    USER_INFO["GroupLevel"] = level
    if isOffGame then
        return
    end
    if tid > 0 then
		require(HallServer_filePath):loginGameNew(level, tid, activityId, pack.baseChip, pack.isWatch)
    else
        print("----gExitGroupGame", STATUS_GAME)
        if STATUS_GAME then

            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
        end
    end

    GameEvent:dispatch("ReceiveUserGameStatus", pack)
end
function HallHandle:SERVER_CMD_TABLE_COUNT(pack)

end
function HallHandle:SERVER_COMMAND_ONLINE(pack)
    dump(pack,"SERVER_COMMAND_ONLINE")
    SCENENOW["scene"]:getChildByName("OnineYaoQingLayer"):SetUserInfo(pack)
end

function HallHandle:SERVER_COMMAND_ONLINE_END( pack )
    SCENENOW["scene"]:getChildByName("OnineYaoQingLayer"):ShowViewItem(pack)
end


function HallHandle:SERVER_CMD_ENET_GAME( pack )
    local InvitationLayer = require("hall.familyCircle.TheInvitationLayer").new(pack)
    InvitationLayer:addTo(SCENENOW["scene"])
end

function HallHandle:B2A_HALL_SEND_PLAYER_MSG_TO_SERVER( pack )
    dump(pack,"B2A_HALL_SEND_PLAYER_MSG_TO_SERVER--->>>")
    if pack then

        --str 的格式 {groupId:11, type:xx, data:"xx"}
        local club_id = pack.club_id
        local str = pack.str

        if club_id > 0 and str ~= '' and str ~= nil then
            local configJson = json.decode(str)

            local type = configJson.type
            if type == "updateClubConfig" then --刷新对应联盟的列表和数据
                if g_hallMainLayer then
                    g_hallMainLayer:loadClub()
                    if g_hallMainLayer.familyMainlayer and club_id == tonumber(g_hallMainLayer.familyMainlayer.family_id) then
                        g_hallMainLayer.familyMainlayer:set_bt_items(json.decode(configJson.data))
                        g_hallMainLayer.familyMainlayer:initUI()
                    end
                end

            elseif  type == "gameLimits" then 
                local gameType = configJson.data
                if g_hallMainLayer then
                    if g_hallMainLayer.familyMainlayer and club_id == tonumber(g_hallMainLayer.familyMainlayer.family_id) then
                        local strs = string.split(gameType, "-")
                        g_hallMainLayer.familyMainlayer.chooseWanFaType = strs
                        g_hallMainLayer.familyMainlayer:InitGameAfterChoose(club_id)

                    end
                end
            end
        end        
    end
end
function HallHandle:SERVER_CMD_JOIN_TABLE(pack) 
    dump(pack,"SERVER_CMD_JOIN_TABLE")
    if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
        local FamilyMainLayer = g_hallMainLayer.familyMainlayer
        local wanfa = FamilyMainLayer:getWanFaData1()
        for i,data in ipairs(wanfa) do
            if tonumber(FamilyMainLayer.family_id) == pack.club_id and data.config.level == pack.level and data.config.id == pack.configId then
                FamilyMainLayer:CreateGameTable(1 , data , nil, 0)
                break
            end
        end
    end

end
return HallHandle
