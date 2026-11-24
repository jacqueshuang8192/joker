
local GameSetting  = class("GameSetting")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
jni_scheduler = nil
jni_paramList = {}
local voice_send_msg_list = {}
local voice_start_list = {}
local voice_finish_list = {}

--初始化原生与lua交互方法
function GameSetting:InitData()
    self:regBridgeHandler()
    self:regBridgeHandlerForDict()
    
    self:regedisCapture()
    self:regedisVedioUrl();

    -- self:regedisBackClick();

	if jni_scheduler == nil then
		jni_scheduler = cc.Director:getInstance():getScheduler()
		jni_scheduler:scheduleScriptFunc(GameSetting.jniUpdate, 1, false)
	end
end

function GameSetting.jniUpdate()
--	print("wtf GameSetting.jniUpdate #jni_paramList:"..#jni_paramList)
	if jni_paramList ~= nil and #jni_paramList > 0 then
		local paramStr = jni_paramList[1]
		table.remove(jni_paramList, 1)
		
		local function callbackLua(param)
			if param == nil then
				print("wtf callbackLua param == nil !!!!!!!!!!!!!! 2")
				return 
			end
			
            print("callBack",param)
            if "reload" == param then
                print("java call back success")
                -- self:onEnter()   
                -- require("app.MyApp").new():run()
            elseif "applyGameAwardPool" == param then
                self:applyGameAwardPool()

            elseif "endGameAwardPool" == param then
                self:endGameAwardPool()

            elseif "exitGameDouniu" == param then
                --nenggou推出
                audio.stopMusic()
                audio.stopAllSounds()
                print("exit dou niu success")
                _G.runScene:onexitDN()
                _G.runScene:removeSelf()
                _G.runScene=nil
            elseif "goldUpdate"==param then
                if USER_INFO["enter_mode"] > 0 then
                    local next = require("src.app.scenes.MainScene").new()
                    SCENENOW["scene"] = next
                    SCENENOW["name"] = "app.scenes.MainScene"
                    display.replaceScene(next)
                    return
                end
                
               --获取本地金币数据
                require("hall.HallHttpNet"):viewAccount()
            elseif "loginSuccess" == param then--app登录成功

                local  ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                    -- SCENENOW["scene"]:initFinished()
                    require("hall.hallScene"):initFinished()
                end
                ))
                SCENENOW["scene"]:runAction(ac)

                -- require("hall.hallScene"):initFinished()
            elseif "loginFail" == param then--app登录失败
                
                local  ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                    -- SCENENOW["scene"]:initFinished()
                    require(LoginScene_filePath):show()
                end
                ))
                SCENENOW["scene"]:runAction(ac)
            elseif "loginFailNew" == param then--app登录失败
                require(NetworkLoadingView_filePath):removeView()
            elseif "rechargeSuccess" == param then
                --获取本地金币数据
                require("hall.HallHttpNet"):viewAccount()

            elseif "rechargeFail" == param then

                local  ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                        local data = {type = 1, title = "提示", content = "充值失败!"}
                        require("hall.tips.CommonTips"):showTips(data)
                    end))

                SCENENOW["scene"]:runAction(ac)

            elseif "shareSuccess" == param then

               
                scheduler.performWithDelayGlobal(function()
                    local data = {type = 1, title = "提示", content = "分享成功!"}
                    equire("hall.tips.CommonTips"):showTips(data)
                end, 1)
            elseif "shareCancel" == param then

                scheduler.performWithDelayGlobal(function()
                    require(NetworkLoadingView_filePath):removeView(8)
                end, 1)

            elseif "YaYaLoginRoomSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):LoginRoomSuccess()

            elseif "YaYaLogoutRoomSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end
                scheduler.performWithDelayGlobal(function()
                    require("hall.util.YaYaVoiceServerUtil"):LogoutRoomSuccess()
                end, 2)
            elseif "micUpSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):micUpSuccess()

            elseif "micDownSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):micDownSuccess()

            elseif "payRoomCardSuccess" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardSuccess()

                        if  EnterAgentPayPage == true then
                            require("hall.scene.market.agentRechargeAd"):openRegisterPage()
                        end

                    end
                ))
                SCENENOW["scene"]:runAction(ac)


            elseif "payRoomCardFail" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardFail()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardCancel" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardCancel()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardInvalid" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardInvalid()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "playing" == param then
                --录音开始播放

            elseif "playfinish" == param then
                --录音播放完成
                print("android voice playfinish !")
                voice_finish_list[#voice_finish_list + 1] = 100
                
            else

                local content = json.decode(param)
                if content == nil then
                    return
                end

                local type = content.type
                if type == nil then
                    return
                end

                if type == "game" then
                    --加入组局

                    local gameInfo = content.gameInfo
                    local invitationCode = gameInfo.invitationCode
                    dump(invitationCode, "-----invitationCode-----")
                    local activityId = gameInfo.activityId
                    local level = gameInfo.level

                    if invitationCode == "agent" then

                        local table = {}
                        table["userId"] = USER_INFO["uid"]
                        table["agentId"] = activityId
                        cct.createHttRq({
                            url = HttpAddr .. "/userBindingAgentByGold",
                            date = table,
                            type_= "POST",
                            requestMsg = "正在绑定代理",
                            callBack = function(data)

                                local responseData = data.netData
                                if responseData ~= nil then

                                    responseData = json.decode(responseData)
                                    dump(responseData, "-----绑定代理-----")
                                    
                                    local returnCode = responseData.returnCode
                                    if returnCode == "0" then
                                        local data = {tpye = 1, title = "提示", content = "绑定代理成功！"} 
                                        require(CommonTips_filePath):showTips(data)

                                        if SCENENOW["name"] == GameScene_filePath then

                                            local btn_bindagent = SCENENOW["scene"]._scene:getChildByName("top_base"):getChildByName("btn_bindagent")
                                            btn_bindagent:setVisible(false)

                                        end

                                    else
                                        local data = {tpye = 1, title = "提示", content = responseData.error} 
                                        require(CommonTips_filePath):showTips(data)
                                        

                                    end

                                else
                                    local data = {tpye = 1, title = "提示", content = "未知错误，绑定失败"} 
                                    require(CommonTips_filePath):showTips(data)

                                end
                                
                            end
                        })
                    
                    else

                        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], invitationCode, "", false, level, false)
                    end

                elseif type == "msg" then

                    --转发消息
                    local data = content.data
                    local url = data.url
                    if url ~= nil and url ~= "" then
                        local userData = {}
                        userData["uid"] = USER_INFO["uid"]
                        userData["nickName"] = USER_INFO["nick"]
                        userData["invote_code"] = USER_INFO["invote_code"]
                        userData["msgType"] = data.msgType
                        if data.msgType == "voice" then
                            userData["voiceTime"] = data.voiceTime
                        end
                        userData["url"] = url
                        voice_send_msg_list[#voice_send_msg_list + 1] = userData
                    end

                    
				elseif type == "recvChatRoomMsg" then
					--require("hall.view.chatRoomView.chatroom_layer"):recvChatRoomMsg(content)	--content is table
					chatroom_layer:getInstance():recvChatRoomMsg(content)

                elseif type == "share" then

                    local data = content.data
                    local shareType = data.shareType
                    if shareType == "wx" then
                        print("shareType:wx")

                    elseif shareType == "pyq" then
                        print("shareType:pyq")
                    end

                    if isSharePyqGiftRoomCard and bm.isInGame == false then
                        --分享朋友圈，每日送卡
                        require(Request_filePath):giftRoomCardEveryDay()

                    end

                end

            end

        end
		
		callbackLua(paramStr)
		
	end

    for i, k in pairs(voice_send_msg_list) do
        if k ~= nil then
            local PROTOCOL = import("hall.HALL_PROTOCOL")
            if PROTOCOL ~= nil then
                local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                            :setParameter("level", USER_INFO["GroupLevel"])
                            :setParameter("msg", json.encode(k))
                            :build()
                if pack ~= nil then
                    bm.server:send(pack)
                end
            end
        end
        print("send voice msg !!! ")
        print(k)
    end
    voice_send_msg_list = {}

    for i, k in ipairs(voice_finish_list) do
        require("hall.view.voicePlayView.voiceListView"):finishPlayCallFunc()
        print("clear voice_finish_list userId:"..k)
    end
    voice_finish_list = {}

end

function GameSetting:regBridgeHandler()

    -- body
    if device.platform == "android" then
        local className = luaJniClass
		
        local function callbackLua(param)
			-- print("wtf table.insert(jni_paramList, param)")
			if param == nil then
				print("wtf callbackLua param == nil !!!!!!!!!!!!!!")
                    
            elseif type(param) == "string" then
                
                local content = json.decode(param)
                if content == nil then
                    table.insert(jni_paramList, param)
                else

                    local type = content.type
                    if type == "app" then

                        local data = content.data
                        local state = data.state
                        if state == "foreground" then
                            print("安卓foreground")
                            if bm.SocketFirstConnectSuccess then
                                --SCENENOW["scene"]:performWithDelay(function()
                                    if bm.server.isConnectedCheck == false then
                                        bm.netdisConnect = true
                                        if device.platform ~= "windows" and IS_TONGC_DUN == 1 then
                                            local sigs = "Ljava/lang/String;"
                                            HttpAddr = resolveGameApiAddress(cct.getDateForApp("getHttpAddr",{},sigs))
                                        end
                                        bm.server:reloginFunc()
                                    end
                                    --恢复背景音乐
                                    -- audio.playMusic(HallBgm_filePath, true)

                                    --应用进入前端，假如当前是在大厅，通知原生当前正在大厅，触发魔窗检测，进行加入组局或者绑定代理操作
                                    --if SCENENOW["name"] == GameScene_filePath then
                                    --
                                    --    if  quickEnterRoom == true then
                                    --        require("hall.util.GameMenu"):checkEnterRoomClipText()
                                    --    end
                                    --
                                    --    --通知原生已进入大厅
                                    --    --cct.getDateForApp("nowInHall", {}, "V")
                                    --
                                    --end

                                --end,1)
                            end


                        elseif state == "background" then
                            dump("安卓background")
                            -- audio.stopMusic()
                        else
                            table.insert(jni_paramList, param)

                        end

                    elseif type == "overtime" then
                        local data = content.data.data
                        print("datannnnn",data)
                        if  tonumber(data) == 0 then
                            bm.server.isConnectedCheck = false
                            bm.server:disconnect()
                        elseif data == 1 then
                            if bm.SocketFirstConnectSuccess then
                                if bm.server.isConnectedCheck == false then
                                    bm.server:reloginFunc()
                                end
                            end
                        end

                        --local data = content.data
                        print("超时")

                    else
                        table.insert(jni_paramList, param)

                    end
                    if type == "formatted_address" then
                        local data = content.data
                        print("uid+=",data.uid)
                        print("address+=",data.address)
                        local uid = tonumber(data.uid)
                        g_hall_addresss[uid] = data.address
                    end
                    if type == "imgUpLoad" then
                        local data = content.data
                        GameEvent:dispatch("HeadImgUpLoadOK", data)
                    end
                end
				
			end

		end
		
        args = { "callbacklua", callbackLua }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"callbackLua",args,sigs)
        if not ok then
            print("call callback errosr")
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        
        local luaoc = require "cocos.cocos2d.luaoc"
        local function reLoadGame(param,param2)
            print("ocpartemp2")
            print(param,"ocpartemp",param2)

            if "reload" == param then
                print("object c call back success")
                -- self:onEnter()   
                -- require("app.MyApp").new():run()
            elseif "applyGameAwardPool" == param then
                self:applyGameAwardPool()
            elseif "endGameAwardPool" == param then
                self:endGameAwardPool()
            elseif "exitGameDouniu" == param then
                --nenggou推出
                audio.stopMusic()
                audio.stopAllSounds()
                print("exit dou niu success")
                _G.runScene:onexitDN()
                _G.runScene:removeSelf()
                _G.runScene=nil
            elseif "goldUpdate"==param then
                if USER_INFO["enter_mode"] > 0 then
                    local next = require("src.app.scenes.MainScene").new()
                    SCENENOW["scene"] = next
                    SCENENOW["name"] = "app.scenes.MainScene"
                    display.replaceScene(next)
                    return
                end
               --获取本地金币数据
                require("hall.HallHttpNet"):viewAccount()
            elseif "loginSuccess" == param then

                --app登录成功
                -- SCENENOW["scene"]:initFinished()
                require("hall.hallScene"):initFinished()

            elseif "loginFail" == param then--app登录失败
                require(LoginScene_filePath):show()
            elseif "loginFailNew" == param then--app登录失败
                require(NetworkLoadingView_filePath):removeView()
                --require(LoginScene_filePath):show()
            elseif "rechargeSuccess" == param then
                require("hall.HallHttpNet"):viewAccount()

            elseif "rechargeFail" == param then
                local data = {type = 1, title = "提示", content = "充值失败!"}
                require(CommonTips_filePath):showTips(data)

            elseif "shareSuccess" == param then
                local data = {type = 1, title = "提示", content = "充值失败!"}
                require(CommonTips_filePath):showTips(data)

            elseif "shareCancel" == param then
                require(NetworkLoadingView_filePath):removeView(9)

            elseif "YaYaLoginRoomSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):LoginRoomSuccess()

            elseif "YaYaLogoutRoomSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                local ac=cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
                        require("hall.util.YaYaVoiceServerUtil"):LogoutRoomSuccess()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "micUpSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):micUpSuccess()

            elseif "micDownSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):micDownSuccess()

            elseif "payRoomCardSuccess" == param then

                print("-----pinghu++-----:".. param)

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardSuccess()
                        
                        if  EnterAgentPayPage == true then
                            require("hall.scene.market.agentRechargeAd"):openRegisterPage()
                        end

                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardFail" == param then

                print("-----pinghu++-----:" .. param)

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardFail()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardCancel" == param then

                print("-----pinghu++-----:" .. param)

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardCancel()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardInvalid" == param then

                print("-----pinghu++-----:" .. param)

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardInvalid()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

			else
				--特殊处理,传过来也许是一段数据
				local content = json.decode(param)
				local key = content["type"]
				if key == "recvChatRoomMsg" then
					chatroom_layer:getInstance():recvChatRoomMsg(content)
				end
				
            end
        end
        luaoc.callStaticMethod("LuaObjectCBridge","registerScriptHandler", {scriptHandler = reLoadGame } )
    else

    end
end

function GameSetting:regBridgeHandlerForDict()

    -- body
    if device.platform == "android" then

        local className = luaJniClass
        local function callbackLuaForDict(param)

            dump(param, "-----regBridgeHandlerForDict-----")

            if param == "recordDidClose" then
                require("hall.recordUtils.RecordUtils"):didClose()
            end

            local data = json.decode(param)
            local tbData = data[1][1]

            local callbackType = tbData["type"]

            if callbackType == "showAlert" then
                local data = {type = 1, title = "提示", content = tbData["message"]}
                require(CommonTips_filePath):showTips(data)

            elseif callbackType == "recordDidClose" then
                require("hall.recordUtils.RecordUtils"):didClose()

            end

        end
        args = { "callbackLuaForDict", callbackLuaForDict }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"callbackLuaForDict",args,sigs)
        if not ok then
            print("call callback errosr")
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        
        local luaoc = require "cocos.cocos2d.luaoc"
        local function callbackLuaForDictOC(param)

            local data = json.decode(param)
            local tbData = data[1][1]

            local callbackType = tbData["type"]

            if callbackType == "showAlert" then
                local data = {type = 1, title = "提示", content = tbData["message"]}
                require(CommonTips_filePath):showTips(data)


            elseif callbackType == "recordDidClose" then
                require("hall.recordUtils.RecordUtils"):didClose()
            elseif callbackType == "setLocation" then
                userInfo["Longitude"] = tbData["Longitude"]
                userInfo["Latitude"] = tbData["Latitude"]
                print("经度：" .. userInfo["Longitude"])
                print("纬度" .. userInfo["Latitude"])
            elseif callbackType == "joinGame" then
                local invitationCode = tbData["invitationCode"]
                local activityId = tbData["activityId"]
                local level = tbData["level"]
                if invitationCode ~= nil and activityId ~= nil and level ~= nil then
                    if invitationCode == "agent" then

                        local table = {}
                        table["userId"] = USER_INFO["uid"]
                        table["agentId"] = activityId
                        cct.createHttRq({
                            url = HttpAddr .. "/userBindingAgentByGold",
                            date = table,
                            type_= "POST",
                            requestMsg = "正在绑定代理",
                            callBack = function(data)

                                local responseData = data.netData
                                if responseData ~= nil then

                                    responseData = json.decode(responseData)
                                    dump(responseData, "-----绑定代理-----")

                                    local returnCode = responseData.returnCode
                                    if returnCode == "0" then
                                        local data = {type = 1, title = "提示", content = "绑定代理成功！"}
                                        require(CommonTips_filePath):showTips(data)

                                        if SCENENOW["name"] == GameScene_filePath then

                                            local btn_bindagent = SCENENOW["scene"]._scene:getChildByName("top_base"):getChildByName("btn_bindagent")
                                            btn_bindagent:setVisible(false)

                                        end

                                    else
                                        local data = {type = 1, title = "提示", content = responseData.error}
                                        require(CommonTips_filePath):showTips(data)

                                    end

                                else
                                    local data = {type = 1, title = "提示", content = "未知错误，绑定失败!"}
                                    require("hall.tips.CommonTips"):showTips(data)

                                end

                            end
                        })

                    else
                        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], invitationCode, "", false, level, false)
                    end
                end

            elseif callbackType == "voice" then
                local url = tbData["url"]
                if url ~= nil and url ~= "" then
                    local userData = {}
                    userData["uid"] = USER_INFO["uid"]
                    userData["nickName"] = USER_INFO["nick"]
                    userData["invote_code"] = USER_INFO["invote_code"]
                    userData["msgType"] = "voice"
                    userData["voiceTime"] = tbData[voiceTime]
                    userData["url"] = url
                    voice_send_msg_list[#voice_send_msg_list + 1] = userData
                end
            elseif callbackType == "video" then
                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                        function()

                            local url = tbData["url"]
                            if url ~= nil and url ~= "" then

                                local userData = {}
                                userData["uid"] = USER_INFO["uid"]
                                userData["nickName"] = USER_INFO["nick"]
                                userData["invote_code"] = USER_INFO["invote_code"]
                                userData["msgType"] = "video"
                                userData["url"] = url

                                if userData ~= nil then
                                    local PROTOCOL = import("hall.HALL_PROTOCOL")
                                    if PROTOCOL ~= nil then
                                        local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                                                       :setParameter("level", USER_INFO["GroupLevel"])
                                                       :setParameter("msg", json.encode(userData))
                                                       :build()
                                        if pack ~= nil then
                                            bm.server:send(pack)
                                        end
                                    end
                                end

                            end

                        end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif callbackType == "recvChatRoomMsg" then
                chatroom_layer:getInstance():recvChatRoomMsg(tbData)


            elseif callbackType == "share" then

                local shareType = tbData["shareType"]
                if shareType == "wx" then
                    print("shareType:wx")
                    local data = {type = 1, title = "提示", content = "分享成功"}
                    require(CommonTips_filePath):showTips(data)

                elseif shareType == "pyq" then
                    print("shareType:pyq")
                    local data = {type = 1, title = "提示", content = "分享成功"}
                    require(CommonTips_filePath):showTips(data)
                end

                if isSharePyqGiftRoomCard and bm.isInGame == false then
                    --分享朋友圈，每日送卡
                    require(Request_filePath):giftRoomCardEveryDay()
                end

            elseif callbackType == "playing" then
                --开始播放语音
                -- local userId = tonumber(tbData["uid"])
                -- voice_start_list[#voice_start_list + 1] = userId
                -- print("ios playing============ userId:"..userId)

            elseif callbackType == "playfinish" then
                --播放完成
                print("ios playfinish============")
                voice_finish_list[#voice_finish_list + 1] = 200
                -- require("hall.view.voicePlayView.voicePlayView"):removeView()

            elseif callbackType == "app" then

                local state = tbData["state"]
                if state == "foreground" then
                    if bm.SocketFirstConnectSuccess then
                        --SCENENOW["scene"]:performWithDelay(function()
                        if bm.server.isConnectedCheck == false then
                            bm.netdisConnect = true
                            if device.platform ~= "windows" and IS_TONGC_DUN == 1 then
                                local sigs = "Ljava/lang/String;"
                                HttpAddr = resolveGameApiAddress(cct.getDateForApp("getHttpAddr",{},sigs))
                            end
                            bm.server:reloginFunc()
                        end
                        --恢复背景音乐
                        -- audio.playMusic(HallBgm_filePath, true)

                        --应用进入前端，假如当前是在大厅，通知原生当前正在大厅，触发魔窗检测，进行加入组局或者绑定代理操作
                        --if SCENENOW["name"] == GameScene_filePath then
                        --
                        --    if  quickEnterRoom == true then
                        --        require("hall.util.GameMenu"):checkEnterRoomClipText()
                        --    end
                        --
                        --    --通知原生已进入大厅
                        --    --cct.getDateForApp("nowInHall", {}, "V")
                        --
                        --end

                        --end,1)

                    end

                    ----ios应用进入前端，假如当前是在大厅，通知原生当前正在大厅，触发魔窗检测，进行加入组局或者绑定代理操作
                    --if SCENENOW["name"] == GameScene_filePath then
                    --
                    --    if  quickEnterRoom == true then
                    --        require("hall.util.GameMenu"):checkEnterRoomClipText()
                    --    end
                    --
                    --    --通知原生已进入大厅
                    --    cct.getDateForApp("nowInHall", {}, "V")
                    --
                    --end

                elseif state == "background" then

                end
            elseif callbackType == "overtime" then
                    local data = tbData.data
                    print("datannnnn",data)
                    if  tonumber(data) == 0 then
                        bm.server.isConnectedCheck = false
                        bm.server:disconnect()
                    elseif data == 1 then
                        if bm.SocketFirstConnectSuccess then
                            if bm.server.isConnectedCheck == false then
                                bm.server:reloginFunc()
                            end
                        end
                    end
                    --local data = content.data
                    print("超时")
            elseif callbackType == "formatted_address" then

                print("uid+=",tbData.uid)
                print("address+=",tbData.address)
                local uid = tonumber(tbData.uid)
                g_hall_addresss[uid] = tbData.address
            elseif callbackType == "imgUpLoad" then
                --local data = content.data
                print("tbData",tbData.url)
                GameEvent:dispatch("HeadImgUpLoadOK", tbData)
            end
        end

        luaoc.callStaticMethod("LuaObjectCBridge","registerScriptHandler1", {scriptHandler = callbackLuaForDictOC })

    else

    end
    
end

--这里注册了一个复制游戏内文本到剪贴板的方法
function GameSetting:copyToClipboard(wait_copy_card_info)

    if type(wait_copy_card_info) == "string" or type(wait_copy_card_info) == "number" then

        if device.platform=="android" then
            local data = {}
            table.insert(data, wait_copy_card_info)
            cct.getDateForApp("copyToClipboard", data, "V")
        else
            local data = {}
            data["msg"] = wait_copy_card_info
            cct.getDataForApp("copyToClipboard", data, "V")
        end
        local data = {type = 1, title = "提示", content = "复制成功"}
        -- require(CommonTips_filePath):showTips(data)
        viewMgr:showTip({text = "复制成功"})

    else
        local data = {type = 1, title = "提示", content = "复制的内容有误"}
        -- require(CommonTips_filePath):showTips(data)
        viewMgr:showTip({text = "复制的内容有误"})

    end

end

function GameSetting:resetClipboard()
    if device.platform=="android" then
        local data = {}
        table.insert(data, "")
        cct.getDateForApp("copyToClipboard", data, "V")
    else
        local data = {}
        data["msg"] = ""
        cct.getDataForApp("copyToClipboard", data, "V")
    end
end

--这里注册了一个切屏的方法
function GameSetting:regedisCapture()
    
    --todo
    if device.platform == "android" then
        local className = luaJniClass
        local function callbackLuaCap(param)
            --cc.Director:getIntense():resume()
            print("callCapturesuccess")
            scheduler.performWithDelayGlobal(function()
                    print("callCapturesuccess2")
                    cct.getScreenPic(param)
                end, 1)
            
        end
        args = { "callbackLuaCap", callbackLuaCap }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"callbackLuaCap",args,sigs)
        if not ok then
            print("call callback errosr")
        end
    end
end

--这里注册了一个视频的方法
function GameSetting:regedisVedioUrl()
    if device.platform == "android" then
        local className = luaJniClass
        local function setVideoAddr(param)
            print("-----regedisVedioUrl()-----",param)
            --cc.Director:getInstance():resume()
            scheduler.performWithDelayGlobal(function()
                    --param="http://jsdx.sc.chinaz.com/Files/DownLoad/sound1/201606/7449.wav"
                    bm.chat_server:sendVideo(self:getPlayerUid() or {},param)
                end, 1)   
        end
        args = { "setVideoAddr", setVideoAddr }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"setVideoAddr",args,sigs)
        if not ok then
            print("call callback errosr")
        end
    elseif device.platform=="ios" or device.platform=="iphone" then
        local luaoc = require "cocos.cocos2d.luaoc"
        local function callbackLuaForDictOC(param)
            cc.Director:getInstance():resume()
            scheduler.performWithDelayGlobal(function()
                    bm.chat_server:sendVideo(self:getPlayerUid() or {},param)
                end, 1)
            
        end
        luaoc.callStaticMethod("LuaObjectCBridge","registRecordCallback", {scriptHandler = callbackLuaForDictOC } )
    end
   
end

function GameSetting:getPlayerUid()
    return self.uidlist
end

function GameSetting:setPlayerUid(uidlist)
    self.uidlist=uidlist
end

function GameSetting:getPos(uid)
    print("getSeatid",tonumber(uid))
    if uid and SCENENOW["scene"].getPosforSeat  then
        return SCENENOW["scene"]:getPosforSeat(tonumber(uid))
    end

    return {x=0,y=0};
end

function GameSetting:UrlGetPic(url)
    -- body
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    local strPic = nil
    if nPos then
        strPic = string.sub(strUrl,1,nPos-1)
    else
        strPic = strUrl
    end
    strPic = string.reverse(strPic)
    print(strPic)
    return strPic
end

--http获取图片
function GameSetting:PicHttpRequest(url,sp)
	-- body
    local file = nil
    local fileErr = nil
    --链接空，载入默认头像
    if url == nil or url == "" then
        return
    end
    --先在本地获取
    local strHead = self:UrlGetPic(url)
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then
        sp:setTexture(imgFullPath)
    else
        local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end


            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            print(response)
            
            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            print("savedata:"..filename)
            while (not request:saveResponseData(filename)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时

            if tolua.isnull(sp) == false then
                sp:setTexture(imgFullPath)
            end
        end
        local request = network.createHTTPRequest(function (event)
            -- body
            if event.name == "completed" then
                onRequestFinished(event,imgFullPath)
            end
        end,url,"GET")
        request:start()
    end
end

function GameSetting:urlPicture(url,button)
    -- body
    local file = nil
    local fileErr = nil
    --链接空，载入默认头像
    if url == nil or url == "" then
        return ""
    end
    --先在本地获取
    local strHead = self:UrlGetPic(url)
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then
        if tolua.isnull(button) == false then
            button:loadTextures(imgFullPath,nil,nil)
        end
        return imgFullPath
    else
        local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return ""
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return ""
            end


            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            print(response)
            
            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            print("savedata:"..filename)
            while (not request:saveResponseData(filename)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时

            if tolua.isnull(button) == false then
                button:loadTextures(imgFullPath,nil,nil)
            end

            return imgFullPath
        end
        local request = network.createHTTPRequest(function (event)
            -- body
            if event.name == "completed" then
                onRequestFinished(event,imgFullPath)
            end
        end,url,"GET")
        request:start()
    end
end

function GameSetting:urlPictureSprite(url,sp)
    -- body
    local file = nil
    local fileErr = nil
    --链接空，载入默认头像
    if url == nil or url == "" then
        return ""
    end
    --先在本地获取
    local strHead = self:UrlGetPic(url)
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then
        if tolua.isnull(sp) == false then
            sp:setTexture(imgFullPath)
        end
        return imgFullPath
    else
        local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return ""
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return ""
            end


            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            print(response)
            
            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            print("savedata:"..filename)
            while (not request:saveResponseData(filename)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时

            if tolua.isnull(sp) == false then
                sp:setTexture(imgFullPath)
            end

            return imgFullPath
        end
        local request = network.createHTTPRequest(function (event)
            -- body
            if event.name == "completed" then
                onRequestFinished(event,imgFullPath)
            end
        end,url,"GET")
        request:start()
    end
end

--创建http请求
function GameSetting:create(strUrl,content,callback)
	print("content size:"..table.getn(content))
	print_lua_table(content)
	local idx = 1
	for key,value in pairs(content) do
		if idx == 1 then
			strUrl = strUrl.."?"..key.."="..value
		else
			strUrl = strUrl.."&"..key.."="..value
		end
		print(strUrl)
		idx = idx + 1
	end

	local req = network.createHTTPRequest(callback,strUrl,"GET")

	req:setTimeout(30)
	req:start()
end

--修改自由场游戏次数
function GameSetting:HttpAddFreeGame()
	
end

--让原生那边切换用户(现改成通知lua登录失败)
function GameSetting:applyChangeUser()

    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
         cc.Director:getInstance():purgeCachedData();
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        -- local ok,ret  = luaj.callStaticMethod(className,"applyChangeUser")
        local ok,ret  = luaj.callStaticMethod(className,"loginFail")
        if not ok then
            print("exitGame luaj error:", ret)
        else
            print("exitGame PLATFORM_OS_ANDROID")
        end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"
         local ok,ret  = luaoc.callStaticMethod(className,"applyChangeUser")
        --local ok,ret  = luaoc.callStaticMethod(className,"loginFail")
        if not ok then
            cc.Director:getInstance():resume()
            print("exitGame PLATFORM_OS_IPHONE failed")
        else
            print("exitGame PLATFORM_OS_IPHONE")
        end
    else
        local next = require("src.app.scenes.MainScene").new()
        SCENENOW["scene"] = next
        SCENENOW["name"] = "app.scenes.MainScene"
        display.replaceScene(next)
    end

end

function GameSetting:showGameAwardPool()

end
--结束奖池比赛报名
function GameSetting:endGameAwardPool()
    -- body
    bShowGameAwardPool = false
    if SCENENOW["scene"] then
        if SCENENOW["scene"]:getChildByName("btn_lottery") then
            SCENENOW["scene"]:removeChildByName("btn_lottery")
        end
        if SCENENOW["scene"]:getChildByName("sp_lottery") then
            SCENENOW["scene"]:removeChildByName("sp_lottery")
        end
        local data = {type = 1, title = "提示", content = "彩池活动已结束"}
        require(CommonTips_filePath):showTips(data)
    end
end
--开始报名奖池
function GameSetting:applyGameAwardPool()
    -- body
    bShowGameAwardPool = true
    self:showGameAwardPool()
end


--比赛中报名
--gameid：游戏ID
--uid：用户ID
function GameSetting:PostApplyGameAwardPool()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/game/applyGameAwardPool"
    xhr:open("POST", httpurl)
    -- xhr:open("POST", "http://192.168.100.118/hbiInterface/game/applyGameAwardPool")
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "gameId=1".."&userId="..USER_INFO["uid"].."&userType="..USER_INFO["type"]
    xhr:send(strPost)
    print("applyGameAwardPool ==>"..strPost)
end

--进入比赛
function GameSetting:enterMatch(gid)
    -- body
    USER_INFO["match_game_id"] = gid
end

return GameSetting