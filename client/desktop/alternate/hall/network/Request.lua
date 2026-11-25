
local Request = class("Request")

local cacheAdvertList = {}

cacheGameList = {}

requireNum = 0

hallUpdateRequireNum = 0

isShowZaiXianYq=true   --是否显示在线邀请功能开关

local timerOut=10
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function Request:ctor()

    dump("初始化请求文件", "-----Request-----")

	cct = cct or {}

    --重载网络请求方法
    cct.createHttRq = function(parm)

        local url = parm.url;
        print(url, "-----cct.createHttRq 请求链接-----")
        local interfaceName = parm.interfaceName or ""
        local date = parm.date or parm.data
        date = date or {}
        date.XYToken = token
        date.XYUid = USER_INFO.uid
        local diamondGift = HttpAddr and url == HttpAddr .. "/playerXXX"
        if diamondGift and not date.requestId then
            -- 同一请求发生网络重试时沿用编号。每次新的赠送操作使用独立编号。
            local defaults = cc.UserDefault:getInstance()
            local sequence = defaults:getIntegerForKey("diamondGiftSequence", 0) + 1
            defaults:setIntegerForKey("diamondGiftSequence", sequence)
            defaults:flush()
            date.requestId = crypto.md5(table.concat({tostring(token), tostring(os.time()), tostring(sequence)}, ":"), false)
        end

        local callBack = parm.callBack
        local type_ = parm.type_ or "POST"
        local arg = parm.arg or {}
        local requestMsg = parm.requestMsg   -- or "拼命加载中"
        local isshowfailTip = true
        if parm.isshowfailTip == false then
            isshowfailTip = false
        end

        if requestMsg and requestMsg ~= ""  then
            require(NetworkLoadingView_filePath):showLoading(requestMsg)
        end

        local function reqCallback(event)

            local request = event.request
            --print(event.name, "-----cct.createHttRq name 请求链接-----")
            if event.name ~= "progress" then
                print(event.name, "-----event.name-----")
            end

            --判断请求是否为失败 网络不好的情况下触发
            if event.name == "failed" then
                if parm.onFailure then parm.onFailure(); return end

                require("hall.GameCommon"):landLoading(false)
                print(event.name, "-----failed-----")
                if diamondGift and PURE_JAVA_HALL then
                    require(CommonTips_filePath):showTips({type = 2, title = "赠钻回执待确认",
                        content = "可重试本次赠送，也可在赠送记录中查询结果。",
                        callBackSure = function() cct.createHttRq(parm) end})
                elseif interfaceName == "getUserInfo4GameServer" then
                    local data = {type = 1, title = "提示", content = "当前网络异常，请检查网络后登录..."}
                    require(CommonTips_filePath):showTips(data)
                    require(LoginScene_filePath):show()

                else
                    if isshowfailTip then
                        local data = {type = 1, title = "提示", content = "当前网络异常,请检查网络..."}
                        require(CommonTips_filePath):showTips(data)
                    end
                end
                require(NetworkLoadingView_filePath):removeView(11)
                return
            end

            --判断请求是否已经结束
            local ok = (event.name == "completed")
            if not ok then
                -- print("-----not ok completed-----")
                return
            end

            --请求结束，根据请求码进行操作  请求成功了,后端报错,没有返回200的处理
            local code = request:getResponseStatusCode()
            if code ~= 200 then
                if parm.onFailure then parm.onFailure(); return end
                -- 没有返回 200 响应代码
                print(code, "-----ResponseStatusCode-----")

                if interfaceName == "getUserInfo4GameServer" then
                    local data = {type = 1, title = "提示", content = "请求数据失败 " .. code .. "..."}
                    require(CommonTips_filePath):showTips(data)
                    require(LoginScene_filePath):show()

                else
                    --这类接口，根据接口来确定是否显示网络异常弹框
                    if isshowfailTip then
                        local function callFunc()
                            cct.createHttRq(parm)
                        end
                        local data = {type = 2, title = "提示", content = "操作失败, 点击确定重新请求...", callBackSure = callFunc}
                        require(CommonTips_filePath):showTips(data)
                        -- viewMgr:showTip({text = "操作失败！"})
                        dump(code, "-----错误码")
                    end
                end
                require(NetworkLoadingView_filePath):removeView(11)
                return
            end

            --请求正常

            --重置重新请求计数
            requireNum = 0

            --返回服务端返回内容
            local response = request:getResponseString()
            arg.net = event
            arg.netData = response
            local jres = json.decode(response) or {}
            if tonumber(jres.returnCode) == 106 then--验证错误返回登录页
                require(NetworkLoadingView_filePath):removeView(11)
                require(LoginScene_filePath):show()
                return
            end
            callBack(arg)
            --request:release()
        end

        --get请求则拼接请求链接
        if type_ == "GET" then

            local str = "?"
            for k,v in pairs(date) do
                str = str .. k.. "=" .. v .. "&"
            end
            url = url .. str

        end

        --创建请求
        local request = network.createHTTPRequest(reqCallback, url, type_)
        request:addRequestHeader('Content-Type:application/x-www-form-urlencoded')

        --post请求则传递入参
        if type_ == "POST" then
            for k,v in pairs(date) do
                request:addPOSTValue(k, v)
            end
        end

        --设置超时时间
        request:setTimeout(10)

        --开始请求。当请求完成时会调用reqCallback
        request:start()

    end
    cct.createHttRqNew = function(parm)

        local url = parm.url;
        print(url, "-----cct.createHttRqNew 请求链接-----")
        local interfaceName = parm.interfaceName or ""

        local callBack = parm.callBack
        local type_ = parm.type_ or "POST"
        local arg = parm.arg or {}
        local requestMsg = parm.requestMsg   -- or "拼命加载中"
        local isshowfailTip = true
        if parm.isshowfailTip == false then
            isshowfailTip = false
        end

        if requestMsg and requestMsg ~= ""  then
            require(NetworkLoadingView_filePath):showLoading(requestMsg)
        end

        local function reqCallback(event)

            local request = event.request

            if event.name ~= "progress" then
                print(event.name, "-----event.name-----")
            end

            --判断请求是否为失败 网络不好的情况下触发
            if event.name == "failed" then

                require("hall.GameCommon"):landLoading(false)
                print(event.name, "-----failed-----")
                if interfaceName == "getUserInfo4GameServer" then
                    local data = {type = 1, title = "提示", content = "当前网络异常，请检查网络后登录..."}
                    require(CommonTips_filePath):showTips(data)
                    require(LoginScene_filePath):show()

                else
                    if isshowfailTip then
                        local data = {type = 1, title = "提示", content = "当前网络异常,请检查网络..."}
                        require(CommonTips_filePath):showTips(data)
                    end
                end
                require(NetworkLoadingView_filePath):removeView(11)
                return
            end

            --判断请求是否已经结束
            local ok = (event.name == "completed")
            if not ok then
                -- print("-----not ok completed-----",url)
                return
            end

            --请求结束，根据请求码进行操作  请求成功了,后端报错,没有返回200的处理
            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 没有返回 200 响应代码
                print(code, "-----ResponseStatusCode-----")

                if interfaceName == "getUserInfo4GameServer" then
                    local data = {type = 1, title = "提示", content = "请求数据失败 " .. code .. "..."}
                    require(CommonTips_filePath):showTips(data)
                    require(LoginScene_filePath):show()

                else
                    --这类接口，根据接口来确定是否显示网络异常弹框
                    if isshowfailTip then
                        local function callFunc()
                            cct.createHttRq(parm)
                        end
                        local data = {type = 2, title = "提示", content = "操作失败, 点击确定重新请求...", callBackSure = callFunc}
                        require(CommonTips_filePath):showTips(data)
                        -- viewMgr:showTip({text = "操作失败！"})
                        dump(code, "-----错误码")
                    end
                end
                require(NetworkLoadingView_filePath):removeView(11)
                return
            end

            --请求正常

            --重置重新请求计数
            requireNum = 0

            --返回服务端返回内容
            local response = request:getResponseString()
            arg.net = event
            arg.netData = response
            local jres = json.decode(response) or {}
            if tonumber(jres.returnCode) == 106 then--验证错误返回登录页
                require(NetworkLoadingView_filePath):removeView(11)
                require(LoginScene_filePath):show()
                return
            end
            callBack(arg)
            --request:release()
        end

        --get请求则拼接请求链接
        --if type_ == "GET" then
        --
        --    local str = "?"
        --    for k,v in pairs(date) do
        --        str = str .. k.. "=" .. v .. "&"
        --    end
        --    url = url .. str
        --
        --end

        --创建请求
        local request = network.createHTTPRequest(reqCallback, url, type_)
        request:addRequestHeader('Content-Type:application/json; charset=UTF-8')

        --post请求则传递入参
        --if type_ == "POST" then
        --    for k,v in pairs(date) do
        --        request:addPOSTValue(k, v)
        --    end
        --end

        --设置超时时间
        request:setTimeout(10)

        --开始请求。当请求完成时会调用reqCallback
        request:start()

    end
    --重载网络请求方法
    --cct.createHttRq = function(parm)
    --
    --    local url = parm.url;
    --    print(url, "-----cct.createHttRq 请求链接-----")
    --    dump(url, "-----请求链接-----")
    --    local interfaceName = parm.interfaceName or ""
    --
    --    local date = parm.date or parm.data
    --    date = date or {}
    --    date.XYToken = token
    --    date.XYUid = USER_INFO.uid
    --    --local date = (parm.date or parm.data) or {}
    --
    --    local callBack = parm.callBack
    --    local type_ = parm.type_ or "POST"
    --    local arg = parm.arg or {}
    --    local requestMsg = parm.requestMsg   -- or "拼命加载中"
    --    local isshowfailTip = parm.isshowfailTip or true
    --
    --    if requestMsg and requestMsg ~= ""  then
    --        require(NetworkLoadingView_filePath):showLoading(requestMsg)
    --    end
    --
    --    local function reqCallback(event)
    --
    --        local request = event.request
    --        print(event.name, "-----cct.createHttRq name 请求链接-----")
    --        if event.name ~= "progress" then
    --            dump(event.name, "-----event.name-----")
    --        end
    --
    --        --判断请求是否为失败
    --        if event.name == "failed" then
    --
    --            if requireNum >= 2 then
    --
    --                requireNum = 0
    --
    --                require("hall.GameCommon"):landLoading(false)
    --
    --                if interfaceName == "getUserInfo4GameServer" then
    --                    local data = {type = 1, title = "提示", content = "网络异常，请重新登录"}
    --                    require(CommonTips_filePath):showTips(data)
    --                    require(LoginScene_filePath):show()
    --
    --                elseif interfaceName == "getGameTypeByRoomType" then
    --                    --这类接口，假如请求失败，还是一直进行请求
    --                    print("getGameTypeByRoomType")
    --                    requireNum = requireNum + 1
    --                    --request:release()
    --                    --重新进行当前请求
    --                    cct.createHttRq(parm)
    --
    --                else
    --                    --这类接口，根据接口来确定是否显示网络异常弹框
    --
    --                    if isshowfailTip then
    --                        local data = {type = 1, title = "提示", content = "网络异常，请稍候再试"}
    --                        require(CommonTips_filePath):showTips(data)
    --                    end
    --
    --                end
    --                --request:release()
    --                return
    --
    --            end
    --
    --            bm.SchedulerPool:delayCall(function()
    --                --request:release()
    --                requireNum = requireNum + 1
    --                print("requireNum",requireNum)
    --                --重新进行当前请求
    --                cct.createHttRq(parm)
    --
    --            end, 3)
    --
    --            return
    --
    --        end
    --
    --        --判断请求是否已经结束
    --        local ok = (event.name == "completed")
    --        if not ok then
    --            return
    --        end
    --
    --        --请求结束，根据请求码进行操作
    --        local code = request:getResponseStatusCode()
    --        if code ~= 200 then
    --            -- 没有返回 200 响应代码
    --
    --            dump(code, "-----ResponseStatusCode-----")
    --
    --            if requireNum >= 2 then
    --
    --                requireNum = 0
    --
    --                if interfaceName == "getUserInfo4GameServer" then
    --                    local data = {type = 1, title = "提示", content = "网络异常，请重新登录"}
    --                    require(CommonTips_filePath):showTips(data)
    --                    require(LoginScene_filePath):show()
    --
    --                elseif interfaceName == "getGameTypeByRoomType" then
    --                    --这类接口，假如请求失败，还是一直进行请求
    --
    --                    requireNum = requireNum + 1
    --
    --                    --重新进行当前请求
    --                    cct.createHttRq(parm)
    --
    --                else
    --                    --这类接口，根据接口来确定是否显示网络异常弹框
    --
    --                    if isshowfailTip then
    --                        local data = {type = 1, title = "提示", content = "网络异常，请稍候再试"}
    --                        require(CommonTips_filePath):showTips(data)
    --                    end
    --
    --                end
    --
    --                return
    --
    --            end
    --
    --            bm.SchedulerPool:delayCall(function()
    --
    --                requireNum = requireNum + 1
    --                print("requireNum+++",requireNum)
    --                --重新进行当前请求
    --                cct.createHttRq(parm)
    --
    --            end, 3)
    --
    --            return
    --
    --        end
    --
    --        --请求正常
    --
    --        --重置重新请求计数
    --        requireNum = 0
    --
    --        --隐藏加载圈
    --        --require(NetworkLoadingView_filePath):removeView(1)
    --
    --        --返回服务端返回内容
    --        local response = request:getResponseString()
    --        arg.net = event
    --        arg.netData = response
    --        local jres = json.decode(response) or {}
    --        if tonumber(jres.returnCode) == 106 then--验证错误返回登录页
    --            require(LoginScene_filePath):show()
    --            return
    --        end
    --        callBack(arg)
    --        --request:release()
    --    end
    --
    --    --get请求则拼接请求链接
    --    if type_ == "GET" then
    --
    --        local str = "?"
    --        for k,v in pairs(date) do
    --            str = str .. k.. "=" .. v .. "&"
    --        end
    --        url = url .. str
    --
    --    end
    --
    --    --创建请求
    --    local request = network.createHTTPRequest(reqCallback, url, type_)
    --    request:addRequestHeader('Content-Type:application/x-www-form-urlencoded')
    --
    --    --post请求则传递入参
    --    if type_ == "POST" then
    --        for k,v in pairs(date) do
    --            request:addPOSTValue(k, v)
    --        end
    --    end
    --
    --    --设置超时时间
    --    request:setTimeout(10)
    --
    --    --开始请求。当请求完成时会调用reqCallback
    --    request:start()
    --
    --end

    --重载网络请求方法
    cct.httpReq2 = function(parm)

        local url = parm.url;
        print(url, "-----cct.httpReq2 请求链接-----")

        local date = parm.data or {}
        local callBack = parm.callBack 
        local type_ = parm.type_ or "POST"
        local arg = parm.arg or {}

        local function reqCallback(event)
            print(event.name, "-----cct.httpReq2 name 请求链接-----")
            local request = event.request

            if event.name ~= "progress" then
                print(event.name, "-----event.name-----")
            end

            --判断请求是否为失败
            if event.name == "failed" then

                print(hallUpdateRequireNum, "-----hallUpdateRequireNum-----")

                if hallUpdateRequireNum >= 1 then

                    hallUpdateRequireNum = 0
                    local data = {type = 1, title = "提示", content = "网络异常，请稍候再试"}
                    require(CommonTips_filePath):showTips(data)

                    return

                end

                -- bm.SchedulerPool:delayCall(function()

                --     hallUpdateRequireNum = hallUpdateRequireNum + 1

                --     --重新进行当前请求
                --     cct.httpReq2(parm)

                -- end, 3)

                return

            end
         
            --判断请求是否已经结束
            local ok = (event.name == "completed")
            if not ok then
                print("not ok completed")
                --request:release()
                return
            end
         
            --请求结束，根据请求码进行操作
            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 没有返回 200 响应代码

                print(code, "-----ResponseStatusCode-----")

                if hallUpdateRequireNum >= 1 then

                    hallUpdateRequireNum = 0
                    local data = {type = 1, title = "提示", content = "网络异常，请稍候再试"}
                    require(CommonTips_filePath):showTips(data)
                    --request:release()
                    return

                end

                -- bm.SchedulerPool:delayCall(function()

                --     hallUpdateRequireNum = hallUpdateRequireNum + 1

                --     --重新进行当前请求
                --     cct.httpReq2(parm)

                -- end, 3)
                --request:release()
                return

            end

            --请求正常
         
            --返回服务端返回内容
            local response = request:getResponseString()
            arg.net = event

            local data = json.decode(response)
            if data ~= nil then

                hallUpdateRequireNum = 0

                arg.data = data.data

                callBack(arg)
                --request:release()
            else

                if hallUpdateRequireNum >= 1 then

                    hallUpdateRequireNum = 0
                    local data = {type = 1, title = "提示", content = "网络异常，请稍候再试"}
                    require(CommonTips_filePath):showTips(data)
                    --request:release()
                    return

                end

                -- bm.SchedulerPool:delayCall(function()

                --     hallUpdateRequireNum = hallUpdateRequireNum + 1

                --     --重新进行当前请求
                --     cct.httpReq2(parm)

                -- end, 3)
                --request:release()
                return

            end

        end

        --get请求则拼接请求链接
        if type_ == "GET" then

            local str = "?"
            for k,v in pairs(date) do
                str = str .. k.. "=" .. v .. "&"
            end
            url = url .. str

        end

        --创建请求
        local request = network.createHTTPRequest(reqCallback, url, type_)
        request:addRequestHeader('Content-Type:application/x-www-form-urlencoded')

        --post请求则传递入参
        if type_ == "POST" then
            for k,v in pairs(date) do
                request:addPOSTValue(k, v)
            end
        end

        --设置超时时间
        request:setTimeout(10)

        --开始请求。当请求完成时会调用reqCallbac
        request:start()

    end

    cct.showLoading = function()
	 -- require(NetworkLoadingView_filePath):showLoading("拼命加载中")
	end


	cct.showLoadingTip = function(msg)
		-- require(NetworkLoadingView_filePath):showLoading("拼命加载中")
	end
    g_RequestMgr = self
end
function getIPCallback(result, response)
    if result == false then
    else
        local startPos = string.find(response,"{")
        local endPos = string.find(response,"}")
        local jsonStr = string.sub(response,startPos,endPos)
        local tb = json.decode(jsonStr)
        --获取的ip地址
        local ip = tb.cip
        USER_INFO["ip"] = ip
        -- require(HallServer_filePath):CLIENT_COMMAND_USER_INFO()  -- 临时注释，服务器未实现此协议
        print(ip,"response8888")
        --获取归属地
        local cname = tb.cname

    end
end
function Request:getInternetIP()
    print("getInternetIP")
    self:HttpIp("http://pv.sohu.com/cityjson?ie=utf-8", function(result, response)
        getIPCallback(result, response)
    end)
end



function Request:HttpIp(url, callback, data)
    print("getInternetIP  ",url)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)
    local function onReadyStateChanged()
        print("getInternetIP ", xhr.readyState)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
             print("xhr.response ------------  "..xhr.response)

            if callback then
                callback(true, xhr.response);
            end
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is:         ",xhr.status)
            if callback then
                callback(false, xhr.response);
            end
        end

        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChanged)

    if data ~= nil and data ~= "" then
        xhr:send(data);
    else
        xhr:send()
    end

end

--用户登录
function Request:userLogin(uid)
    print("=== userLogin 开始 ===")
    print("uid: " .. tostring(USER_INFO["uid"]))
    cct.createHttRq({
        url = HttpAddr .. "/playerUser/getUserInfo4GameServer",
        requestMsg = "",
        interfaceName = "getUserInfo4GameServer",
        date={
            userId = USER_INFO["uid"]
        },
        requestMsg = "",
        callBack = function(data)
            print("=== 原始返回 ===")
            local responseData = json.decode(data.netData)
            local responseData = json.decode(data.netData)

            --登录失败,弹出登录界面
            if  responseData == nil then
                local data = {type = 1, title = "提示", content = "登录失败"}
                require(CommonTips_filePath):showTips(data)
                require(LoginScene_filePath):show()
                return
            end

            if responseData["returnCode"] == "0" then

                if  responseData["data"]["mtKey"] == nil then
                    local data = {type = 1, title = "提示", content = "登录验证失败"}
                    require(CommonTips_filePath):showTips(data)
                    require(LoginScene_filePath):show()
                    return
                end

                --是否已领取过首登奖励  0，未领取，1，已领取
                USER_INFO["hasReceiveRegisterBonus"] = responseData["data"]["isFirstLogin"]

                --这里记录走马灯的内容
                if responseData["data"]["announcement"] then
                    if responseData["data"]["announcement"][1] 
                        and responseData["data"]["announcement"][1][1]
                        and responseData["data"]["announcement"][1][1].content then
                        if braodComponentDefaulMessage_hall then
                            braodComponentDefaulMessage_hall = responseData["data"]["announcement"][1][1].content or ""
                        end
                    end
                end

                --获取用户个人信息
                local data = responseData["data"]["playerProfile"]

                --假如返回数据为空
                if  data == nil then
                    local data = {type = 1, title = "提示", content = "登录失败，用户数据异常"}
                    require("hall.tips.CommonTips"):showTips(data)
                    require(LoginScene_filePath):show()
                    return
                end

                --记录用户信息
                DOUNIU_ROOM_KEY = responseData["data"]["douniuKey"]
                PURE_JAVA_HALL = responseData["data"]["pureJavaHall"] == true
                USER_INFO["nick"] = data["nickName"]
                USER_INFO["msgCount"] = data["msgCount"]
                USER_INFO["sex"] = tonumber(data["sex"]) or 1
                USER_INFO["icon_url"] = data["photoUrl"] or ""
                USER_INFO["phone"] = data.phone or ""
                --记录玩家ip
                -- USER_INFO["ip"] = data["myIp"]
                USER_INFO["cardCount"] = data["cardCount"] or 0

                local tbData = {}
                -- if data["level"] == nil then
                --     data["level"] = 1
                -- end
                tbData["level"] = data["level"] or 0
                tbData["nickName"] = data["nickName"] or ("玩家" .. USER_INFO["uid"])
                tbData["photoUrl"] = data["photoUrl"] or ""
                tbData["sex"] = data["sex"] or 1
                tbData["money"] = data["coinAmount"] or 0
                USER_INFO["user_info"] = json.encode(tbData)
                print("===== Request.lua 中设置 USER_INFO.user_info =====", USER_INFO["user_info"])
                USER_INFO["phone"] = data["phone"]

                --绑定代理
                USER_INFO["agentId"] = data["agentId"]
                USER_INFO["agentName"] = data["agentName"]

                dump(USER_INFO["agentId"], "-----agentId-----")
                dump(USER_INFO["agentName"], "-----agentName-----")

                --用户签名
                USER_INFO["sign"] = data["sign"]

                -- require("hall.view.chatRoomView.chatroom_layer")
                -- chatroom_layer:getInstance():setUserInfo()

                --获取并记录大厅服务器信息
                local hall = responseData["data"]["hall"]
                hall_ip = hall["ip"]
                hall_port = tonumber(hall["port"])  -- 使用服务端返回的端口

                --if g_hallMainLayer then
                --    g_hallMainLayer:loadHallForRoomCard()
                --end

                --调用接口获取游戏列表：要求取消掉 因为客户端已经levellist写死有哪些游戏了.
                require(Request_filePath):getGameList()
            else

                if responseData["error"] ~= nil and responseData["error"] ~= "" then
                    local data = {type = 1, title = "提示", content = responseData["error"]}
                    print("responseData -------------------------------------- 1")
                    require("hall.tips.CommonTips"):showTips(data)
                else
                    local data = {type = 1, title = "提示", content = "登录失败，未知错误"}
                    require("hall.tips.CommonTips"):showTips(data)--CommonTips_filePath
                end
                print("responseData -------------------------------------- 2")
                require(LoginScene_filePath):show()

            end

        end,
        type="POST"
    })

    local realmNameLst = {}

    return true

end

function Request:getIpFormRealmNameLst()
    self.RealmNameLst = {"https://api.myip.com","https://ip-api.com/json/?lang=zh-CN","https://pv.sohu.com/cityjson"}
    self._realmNameIdx = 1
    self:getUserIP(self._realmNameIdx)

end

function Request:getUserIP(idx)
    local result = true
    cct.createHttRqNew({
        url = g_RequestMgr.RealmNameLst[idx],
        callBack = function(data)
            print("realmName ------------- ", data)
            local responseData = nil
            if type(data.netData) ~= "table" then
                responseData = json.decode(data.netData)
            else
                responseData = data.netData
            end
            local responseData = json.decode(data.netData)
            print("realmName ------------- ", g_RequestMgr.RealmNameLst[idx])
            dump(responseData,"-----getUserIP  -----")
            if  responseData == nil then
                g_RequestMgr._realmNameIdx = 1 + g_RequestMgr._realmNameIdx
                if g_RequestMgr._realmNameIdx > 3 then
                    --local data = {type = 1, title = "提示", content = "获取玩家IP失败"}
                    --require(CommonTips_filePath):showTips(data)
                else
                    g_RequestMgr:getUserIP(g_RequestMgr._realmNameIdx)
                end
            else
                if g_RequestMgr._realmNameIdx == 1 then
                    USER_INFO["ip"] = responseData.ip
                    -- require(HallServer_filePath):CLIENT_COMMAND_USER_INFO()  -- 临时注释
                elseif g_RequestMgr._realmNameIdx == 2 then
                    USER_INFO["ip"] = responseData.query
                    -- require(HallServer_filePath):CLIENT_COMMAND_USER_INFO()  -- 临时注释
                elseif g_RequestMgr._realmNameIdx == 3 then
                    --第3个网站暂时无法使用
                    dump(responseData, '=-------------------')
                end
            end

        end,
        type_="GET",
        isshowfailTip = false
    })

    return result
end

--获取游戏列表
function Request:getGameList()

    dump("", "-----获取游戏列表-----")

    if  next(cacheGameList) == nil then

        local params = {}
        params["platform"] = "1"
        cct.createHttRq({
            url = HttpAddr .. "/gold/getGameTypeByRoomType", 
            type_="POST",
            interfaceName = "getGameTypeByRoomType",
            callBack = function(data)
                local responseData = data.netData
                if responseData then
                    responseData = json.decode(responseData)
                    -- dump(responseData, "-----获取游戏列表返回1-----")

                    if responseData then

                        bm.gameList = {}
                        bm.gameList_forRoomCard = {}
                        bm.allGameList = {}
                        
                        local gameListdata = responseData["data"]

                        if responseData.returnCode ~= "0" or type(gameListdata) ~= "table" then
                            require(CommonTips_filePath):showTips({
                                type = 1, title = "提示", content = "游戏列表加载失败，点击确定重试",
                                callBackSingleSure = function() self:getGameList() end
                            })
                            return
                        end
                        cacheGameList = gameListdata

                        --添加游戏列表到本地
                        require(GameList_filePath):loadGameList(responseData["data"]["1"])
                        require(GameList_filePath):loadGameList(responseData["data"]["2"])


                        for _,allGameList in pairs(gameListdata) do
                            
                            -- dump(allGameList,"-----------allGameList-----------")

                            if  allGameList["roomType"] == "1" then --金币场

                                for gameId,bigGameList in pairs(allGameList) do
                                    
                                    if type(bigGameList) == "table" then

                                        -- dump(bigGameList["gameTypeList"],"bigGameListgameTypeList")
                                        local tmp = {}
                                        for _, singleGame in pairs(bigGameList["gameTypeList"]) do

                                            local gameList = singleGame.gameList
                                            for gameNum, game in pairs(gameList) do
                                                table.insert(bm.allGameList, game)
                                            end

                                            table.insert(tmp, singleGame)
                                        end

                                        local  gameInfo = {}
                                        gameInfo["gameType"] = bigGameList["gameTypeName"]
                                        gameInfo["gameArr"] = tmp
                                        bm.gameList[gameId] = gameInfo
                                    end
                                
                                end

                            elseif allGameList["roomType"] == "2" then --房卡场  

                                for gameId,bigGameList in pairs(allGameList) do
                                    
                                    if  type(bigGameList) == "table" then

                                        local tmp = {}
                                        for _,singleGame in pairs(bigGameList["gameTypeList"]) do

                                            local gameList = singleGame.gameList
                                            for gameNum, game in pairs(gameList) do
                                                table.insert(bm.allGameList, game)
                                                table.insert(tmp, game)
                                            end

                                        end

                                        local gameInfo = {}
                                        gameInfo["gameType"] = bigGameList["gameTypeName"]
                                        gameInfo["gameArr"] = tmp
                                        bm.gameList_forRoomCard[gameId] = gameInfo

                                    end      
                                
                                end
           
                            end
                                
                        end

                        -- dump(bm.allGameList, "-----所有游戏-----")

                        --游戏列表获取完成，开始连接服务器

                        --设置当前进度为20%
                        require("hall.GameCommon"):setLoadingProgress(20)
                        require("hall.GameCommon"):showLoadingTips("连接游戏服务器")

                        --进行大厅服务器Socket连接
                        require(HallServer_filePath):connectSocket()

                        --显示金币场游戏列表

                        -- --获取玩家组局状态(检查用户游戏状态，进行重连)
                        -- dump("", "-----获取游戏列表成功，检查重连-----")
                        -- require("hall.groudgamemanager"):requestGroupStatus()

                    else

                        --调用接口获取游戏列表
                        require(Request_filePath):getGameList()

                    end

                else

                    --调用接口获取游戏列表
                    require(Request_filePath):getGameList()

                end

            end
        })

    else

        --设置当前进度为20%
        require("hall.GameCommon"):setLoadingProgress(20)
        require("hall.GameCommon"):showLoadingTips("连接游戏服务器")

        --进行大厅服务器Socket连接
        require(HallServer_filePath):connectSocket()

    end

end

--获取游戏列表
function Request:getGameType()

    if isiOSVerify then

        bm.gameList = {}
        local gameData = {}
        gameData["gameType"] = "扑克游戏"
        gameData["gameArr"] = {}

        local game = {}
        game["gameId"] = 1
        game["gameType"] = "扑克游戏"
        game["id"] = 43
        game["isShow"] = 1
        game["name"] = "斗地主"
        table.insert(gameData["gameArr"], game)
        table.insert(bm.gameList, gameData)

        local game1 = {}
        game1["gameId"] = 11
        game1["gameType"] = "扑克游戏"
        game1["id"] = 18
        game1["isShow"] = 1
        game1["name"] = "跑得快"
        table.insert(gameData["gameArr"], game1)

        local game2 = {}
        game2["gameId"] = 39
        game2["gameType"] = "扑克游戏"
        game2["id"] = 47
        game2["isShow"] = 1
        game2["name"] = "新三公"
        table.insert(gameData["gameArr"], game2)

        dump(bm.gameList, "-----bm.gameList-----")
        return

    end


    -----------------------------------------------------------------------------------------------------
    local params = {}
    if USER_INFO["saveProvinceId"] == nil then
        USER_INFO["saveProvinceId"] = cc.UserDefault:getInstance():getIntegerForKey("saveProvinceId", 0)
    end
    if USER_INFO["saveProvinceId"] == 0 then
        require("hall.view.mapView.mapView"):showView()
        return
    end
    params["provinceId"] = USER_INFO["saveProvinceId"]
    
    if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" then
        params["agentId"] = USER_INFO["agentId"]
    end

    dump(params, "-----获取游戏分类列表——params-----")

    cct.createHttRq({
        url = HttpAddr .. "/gold/getGameTypeByRoomType",
        type_="POST",
        callBack = function(data)
            local responseData = data.netData
            if responseData then
                local responseData = json.decode(responseData)
                -- dump(responseData, "-----获取游戏分类列表返回123-----")
                bm.gameList = {}

                local list = {}
                local gameNameList = {}
                local gameListdata = responseData["data"]
                if gameListdata ~= nil then
                    
                    -- dump(gameListdata, "-----获取游戏分类列表返回——gameListdata-----")

                    --获取金币场的组句配置

                    for _,allGameList in pairs(gameListdata) do
                         
                        -- dump(allGameList, "-----获取游戏分类列表返回——allGameList-----")
                        
                        for gameId,bigGameList in pairs(allGameList) do
                            
                            -- dump(bigGameList,"-----获取游戏分类列表返回_bigGameList-----")
                             
                            if  type(bigGameList) == "table" then
                                -- dump(bigGameList["gameTypeName"],"gameTypeName")
                               
                                if list[gameId] == nil then
                                    list[gameId] = {}
                                end

                                gameNameList[gameId] = bigGameList["gameTypeName"]

                                for _,singleGame in pairs(bigGameList["gameTypeList"]) do
                                    -- dump(singleGame,"-----获取游戏分类列表返回_singleGame-----")
                                    table.insert(list[gameId], singleGame)
                                end
                            end
                        
                        end

                    end
             
                    --显示热门类
                    -- for k,v in pairs(list) do

                    --     if k == "热门类" then
                    --         local gameInfo = {}
                    --         gameInfo["gameType"] = k
                    --         gameInfo["gameArr"] = v
                    --         table.insert(bm.gameList, gameInfo)
                    --         break
                    --     end

                    -- end

                    for k,v in pairs(list) do

                        if k ~= "热门类" then
                            local gameInfo = {}
                            gameInfo["gameType"] = gameNameList[k]
                            gameInfo["gameArr"] = v
                            bm.gameList[k] = gameInfo
                        end

                    end
                    
                    --调用接口成功后，显示创建组局界面
                    require(CreateGroup_filePath):CreateScene()

                end

            end       
        end
    })

end

--获取VIP房间游戏列表
function Request:getGameTypeForVip()

    if isiOSVerify then

        bm.vipGameList = {}
        local gameData = {}
        gameData["gameType"] = "扑克游戏"
        gameData["gameArr"] = {}

        local game = {}
        game["gameId"] = 1
        game["gameType"] = "扑克游戏"
        game["id"] = 43
        game["isShow"] = 1
        game["name"] = "斗地主"
        table.insert(gameData["gameArr"], game)
        table.insert(bm.vipGameList, gameData)

        local game1 = {}
        game1["gameId"] = 11
        game1["gameType"] = "扑克游戏"
        game1["id"] = 18
        game1["isShow"] = 1
        game1["name"] = "跑得快"
        table.insert(gameData["gameArr"], game1)

        local game2 = {}
        game2["gameId"] = 39
        game2["gameType"] = "扑克游戏"
        game2["id"] = 47
        game2["isShow"] = 1
        game2["name"] = "新三公"
        table.insert(gameData["gameArr"], game2)

        dump(bm.vipGameList, "-----bm.vipGameList-----")
        return

    end

    local params = {}
    if USER_INFO["saveProvinceId"] == nil then
        USER_INFO["saveProvinceId"] = cc.UserDefault:getInstance():getIntegerForKey("saveProvinceId", 0)
    end
    if USER_INFO["saveProvinceId"] == 0 then
        require("hall.view.mapView.mapView"):showView()
        return
    end
    params["provinceId"] = USER_INFO["saveProvinceId"]
    
    if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" then
        params["agentId"] = USER_INFO["agentId"]
    end

    dump(params, "-----获取游戏分类列表-----")

    cct.createHttRq({
        url = HttpAddr .. "/game/queryGameTypeByGold",
        date = params,
        type_="POST",
        requestMsg = "",
        callBack = function(data)
            local responseData = data.netData
            if responseData then
                local responseData = json.decode(responseData)
                dump(responseData, "-----获取游戏分类列表返回-----")

                bm.vipGameList = {}

                local list = {}
                local index = 2
                local gameListdata = responseData["data"]
                if gameListdata ~= nil then
                    
                    for k,v in pairs(gameListdata) do

                        if v["gameType"] == nil then
                            v["gameType"] = "棋牌类"
                        end

                        if list[v["gameType"]] == nil then
                            list[v["gameType"]] = {}
                        end

                        table.insert(list[v["gameType"]], v)

                    end

                    for k,v in pairs(list) do

                        if k == "热门类" then
                            local gameInfo = {}
                            gameInfo["gameType"] = k
                            gameInfo["gameArr"] = v
                            table.insert(bm.vipGameList, gameInfo)
                            break
                        end

                    end

                    for k,v in pairs(list) do

                        if k ~= "热门类" then
                            local gameInfo = {}
                            gameInfo["gameType"] = k
                            gameInfo["gameArr"] = v
                            table.insert(bm.vipGameList, gameInfo)
                        end

                    end

                end

                dump(bm.vipGameList, "-----bm.vipGameList-----")
            end       
        end
    })

end

--获取组局配置
function Request:getCreateGroupGameConfig()

    local params = {}
    params["provinceId"] = USER_INFO["saveProvinceId"]
    if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" then
        params["agentId"] = USER_INFO["agentId"]
    end

    dump(params, "-----获取组局配置-----")

    cct.createHttRq({
        url = HttpAddr .. "/game/queryGameConfig",
        date = params,
        type_= "GET",
        requestMsg = "",
        callBack = function(data)
            local responseData = data.netData
            if responseData then
                responseData = json.decode(responseData)
                if responseData ~= nil then

                    local cacheData = responseData.data
                    if cacheData then
                        bm.groupGameConfig = cacheData
                        dump(bm.groupGameConfig, "-----获取组局配置返回-----")
                    end

                    local createGroupCsb = SCENENOW["scene"]:getChildByName("createGroupCsb")
                    if createGroupCsb ~= nil then
                        createGroupCsb:removeSelf()
                        require(CreateGroup_filePath):CreateScene()
                    end

                    -- if cacheData then
                    --     local content = cacheData.content
                    --     if content then
                    --         local decodeData = json.decode(content)
                    --         bm.groupGameConfig = decodeData
                    --         dump(content, "-----获取组局配置返回-----")
                    --     end
                    -- end

                end
            end
        end
    })

end

--获取组局配置
function Request:getSelectGameConfig(params, handlerCallBack)

    cct.createHttRq({
        url = HttpAddr .. "/selectGameConfig",
        date = params,
        type_= "POST",
        requestMsg = "",
        callBack = function(data)
            local responseData = data.netData
            if responseData then
                responseData = json.decode(responseData)
                if responseData ~= nil then

                    -- dump(responseData, "-----getCreateGroupGameConfigForGoldGame_responseData-----")

                    local cacheData = responseData.data
                    local returnCode = responseData.returnCode
                    if  returnCode == "0" then
                        local gameConfigData ={}
                        gameConfigData.gameConfig = json.decode(cacheData[1].config)

                        handlerCallBack(gameConfigData)
                        -- require(CreateGroup_filePath):setSingleGameView(gameConfigData)
                    else
                        local data = {type = 1, title = "提示", content = "读取游戏配置失败"}
                        require(CommonTips_filePath):showTips(data)
                    end
                end
            end
        end})

end

--获取组局配置
function Request:getCreateGroupGameConfigForGoldGame(level, handlerCallBack)
    local params = {}
    params["level"] = level

    cct.createHttRq({
        url = HttpAddr .. "/gold/getGameConfigByLevelAndGold",
        date = params,
        type_= "POST",
        requestMsg = "",
        callBack = function(data)
            local responseData = data.netData
            if responseData then
                responseData = json.decode(responseData)
                if responseData ~= nil then
                    
                    -- dump(responseData, "-----getCreateGroupGameConfigForGoldGame_responseData-----")

                    local cacheData = responseData.data
                    local returnCode = responseData.returnCode
                    if  returnCode == "0" then
                        local gameConfigData = json.decode(cacheData)
                        handlerCallBack(gameConfigData)
                        -- require(CreateGroup_filePath):setSingleGameView(gameConfigData)
                    else
                        local data = {type = 1, title = "提示", content = "读取游戏配置失败"}
                        require(CommonTips_filePath):showTips(data)
                    end
                end
            end
        end})

end

--上传应用信息
function Request:upLoadAppMessage(type, msg)

    print(msg, "-----upLoadAppMessage1-----")

    local params = {}
    if USER_INFO["type"] == nil then
        params["type"] = 1
    else
        params["type"] = type
    end

    params["uid"] = USER_INFO["uid"]

    if USER_INFO["GroupLevel"] == nil then
        params["level"] = 0
    else
        params["level"] = USER_INFO["GroupLevel"]
    end

    params["msg"] = msg
    
     cct.createHttRq({
         url = HttpAddr .. "/GameMessage/uploadGameMessage",
         date = params,
         type_ = "POST",
         requestMsg = "",
         callBack = function(data)

         end
     })
    
end

--获取当前游戏控制情况
function Request:getGameControl()

    if USER_INFO["GroupLevel"] == nil or USER_INFO["GroupLevel"] == 0 then
        isShowVerifyBt = false
        isOpenControl = false
        return
    end

    if not bm.isInGame then
        isShowVerifyBt = false
        isOpenControl = false
        return
    end


    local params = {}
    params["level"] = USER_INFO["GroupLevel"]

    cct.createHttRq({
        url = HttpAddr .. "/limit/getDataByUidOrLevel",
        date = params,
        type_= "GET",
        requestMsg = "",
        callBack = function(data)

            local responseData = data.netData
            if responseData then

                responseData = json.decode(responseData)
                dump(responseData, "-----情况返回-----")

                local returnCode = responseData.returnCode
                if returnCode == "0" then

                        local cacheData = responseData.data.testList or {}
                        if cacheData ~= nil and #cacheData > 0 then
                            for k,v in pairs(cacheData) do
                                local userid = v.userid
                                if userid == USER_INFO["uid"] then
                                    isShowVerifyBt = true
                                end
                            end
                        end

                         --合并借口
                        if isiOSVerify then
                            --上架版，直接加入游戏
                            dump("上架版，直接加入游戏")
                            if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
                                g_hallMainLayer.familyMainlayer = nil
                            end
                            require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])

                        else
                            
                            if require("hall.GameCommon"):getGameVersion(USER_INFO["enter_code"]) == "" then
                                --本地没有游戏
                                if require("hall.GameUpdate"):getUpdateStatus() == 0 then
                                    self:getVersionCallback(responseData.data.version)
                                end
                            else

                                -- dump("本地游戏版本低")
                                if require("hall.GameUpdate"):getUpdateStatus(responseData.data.version) == 0 then
                                   self:getVersionCallback(responseData.data.version)
                                end
                            end
                        end
                    end

                end


            end
    })
    
end

--
function Request:getVersionCallback(version)
    dump(version,"version======")
    --假如配置中记录不需要更新，则直接进入游戏
    local code = USER_INFO["enter_code"]
    local gid = USER_INFO["enter_mode"]

    if not needUpdate then
        require("hall.GameUpdate"):enterGroup(code)
                dump("OnineYaoQingLayer--2222")
                if isShowZaiXianYq then
                local OnineYaoQing=require("hall.roomCommonUI.zaixianyaoqingLayer").new()
                OnineYaoQing:setName("OnineYaoQingLayer")
                OnineYaoQing:addTo(SCENENOW["scene"],SCENENOW["scene"]:getChildrenCount() + 10)
            end
               -- SCENENOW["scene"].zaixianyaoqingLayer=SCENENOW["scene"]:loadLayerByName("hall.roomCommonUI.zaixianyaoqingLayer")
        return
    end

    if not version then
        local data = {type = 1, title = "提示", content = "游戏版本不存在"}
        require(CommonTips_filePath):showTips(data)
        return
    end

    local h
    local data = version
    if data then
        self:unscheduleGlobal(h)
        local Manual = data["isManual"]
        local url = data["updateUrl"]
        local ver = data["version"]

        dump(ver,"ver==>")
        dump(code,"code==>")

        if require("hall.GameData"):compareLocalVersion(ver,code) > 0 then
            --更新游戏
            require("hall.GameUpdate"):updateGameInJoinGame(url,ver,gid,code)
        else
            require("hall.GameUpdate"):enterGroup(code)
            if isShowZaiXianYq then
                            local OnineYaoQing=require("hall.roomCommonUI.zaixianyaoqingLayer").new()
                OnineYaoQing:setName("OnineYaoQingLayer")
                OnineYaoQing:addTo(SCENENOW["scene"],SCENENOW["scene"]:getChildrenCount() + 10)
            end
     -- SCENENOW["scene"].zaixianyaoqingLayer=SCENENOW["scene"]:loadLayerByName("hall.roomCommonUI.zaixianyaoqingLayer")
        end

    else
        --重新获取游戏版本
        self:getGameControl()
        return
    end


end

function Request:unscheduleGlobal( h )
    if type(h) == "number" then
        scheduler.unscheduleGlobal(h)
    end
end


--每日送卡
function Request:giftRoomCardEveryDay()

    local params = {}
    params["userId"] = USER_INFO["uid"]

    cct.createHttRq({
        url = HttpAddr .. "/roomCard/giftRoomCardEveryDay",
        date = params,
        type_= "POST",
        requestMsg = "",
        callBack = function(data)

            local responseData = data.netData
            if responseData then

                responseData = json.decode(responseData)
                dump(responseData, "-----每日送卡返回-----")

                local returnCode = responseData.returnCode
                if returnCode == "0" then

                    local cardCount = responseData["data"].cardCount
                    local goldCount = responseData["data"].goldCount

                    local msg = "分享成功，已获得奖励！"

                    if  tonumber(cardCount) and tonumber(cardCount) > 0 then
                        msg = msg .. "房卡x".. cardCount .. "!  "
                    end

                    if  tonumber(goldCount)  and tonumber(goldCount) > 0 then
                        msg = msg .. "钻石x".. goldCount .. "!  "
                    end  
                    local data = {type = 1, title = "提示", content = msg}
                    require(CommonTips_filePath):showTips(data)

                    --更新用户房卡数量
                    require(GameScene_filePath):queryRoomCardCount()

                elseif returnCode == "2" or returnCode == "3" then
                    local data = {type = 1, title = "提示", content = "今天已领取，请明天再来~"}
                    require(CommonTips_filePath):showTips(data)

                end

            end

        end

    })
    
end

--校验
function Request:verifyByUid(verify)

    if USER_INFO["GroupLevel"] == nil or USER_INFO["GroupLevel"] == 0 then
        isShowVerifyBt = false
        isOpenControl = false
        return
    end

    if not bm.isInGame then
        isShowVerifyBt = false
        isOpenControl = false
        return
    end

    local params = {}
    params["uid"] = USER_INFO["uid"]
    params["level"] = USER_INFO["GroupLevel"]
    params["verify"] = verify

    cct.createHttRq({
        url = HttpAddr .. "/limit/verify",
        date = params,
        type_= "GET",
        requestMsg = "",
        callBack = function(data)

            --移除检验界面
            require(Verify_filePath):removeScene()

            local responseData = data.netData
            if responseData then
                
                responseData = json.decode(responseData)
                dump(responseData, "-----校验返回-----")

                local returnCode = responseData.returnCode
                if returnCode == "0" then

                    isOpenControl = true
                    local data = {type = 1, title = "提示", content = "校验成功"}
                    require(CommonTips_filePath):showTips(data)

                else

                    isOpenControl = false
                    local data = {type = 1, title = "提示", content = "校验失败"}
                    require(CommonTips_filePath):showTips(data)

                end

            end

        end
    })
    
end

--获取广告轮播图
function Request:getAdvertList()

    if  next(cacheAdvertList)  then
        require(GameScene_filePath):showAdvert(cacheAdvertList)
    else

        local params = {}

        cct.createHttRq({
            url = HttpAddr .. "/fortune/getAdvertList",
            date = params,
            type_= "POST",
            requestMsg = "",
            callBack = function(data)

                local responseData = data.netData
                if responseData then

                    responseData = json.decode(responseData)
                    dump(responseData, "-----获取广告轮播图返回-----")

                    local returnCode = responseData.returnCode
                    if returnCode == "0" then

                        local cacheData = responseData.data
                        if cacheData ~= nil then

                            cacheData = json.decode(cacheData)

                            cacheAdvertList = cacheData
                            require(GameScene_filePath):showAdvert(cacheData)

                        end

                    end

                end

            end
        })

    end

end

return Request