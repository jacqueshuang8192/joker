

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local HallUpdate  = class("HallUpdate")

local timerOut=10
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

hallUpdateRequireNum = 0

--获取remote更新版本
function HallUpdate:queryVersion(type)

    --重载网络请求方法
    cct.httpReq2 = function(parm)

        local url = parm.url;
        dump(url, "-----请求链接-----")

        local date = parm.data or {}
        local callBack = parm.callBack 
        local type_ = parm.type_ or "POST"
        local arg = parm.arg or {}

        local function reqCallback(event)

            local request = event.request

            if event.name ~= "progress" then
                dump(event.name, "-----event.name-----")
            end

            --判断请求是否为失败
            if event.name == "failed" then

                dump(hallUpdateRequireNum, "-----hallUpdateRequireNum-----")

                if hallUpdateRequireNum == 3 then

                    hallUpdateRequireNum = 0

                    self:showTips("提示", "", 3, "网络异常，请稍候再试", cct.httpReq2(parm))

                    return

                end

                bm.SchedulerPool:delayCall(function()

                    hallUpdateRequireNum = hallUpdateRequireNum + 1

                    --重新进行当前请求
                    cct.httpReq2(parm)

                end, 3)

                return

            end
         
            --判断请求是否已经结束
            local ok = (event.name == "completed")
            if not ok then
                return
            end
         
            --请求结束，根据请求码进行操作
            local code = request:getResponseStatusCode()
            if code ~= 200 then
                dump(code, "-----ResponseStatusCode-----")
                return
            end

            --请求正常
         
            --返回服务端返回内容
            local response = request:getResponseString()
            arg.net = event

            local data = json.decode(response)
            if data ~= nil then

                arg.data = data.data
                callBack(arg)

            else

                if hallUpdateRequireNum == 3 then

                    hallUpdateRequireNum = 0

                    self:showTips("提示", "", 3, "网络异常，请稍候再试", cct.httpReq2(parm))

                    return

                end

                bm.SchedulerPool:delayCall(function()

                    hallUpdateRequireNum = hallUpdateRequireNum + 1

                    --重新进行当前请求
                    cct.httpReq2(parm)

                end, 3)

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

        --开始请求。当请求完成时会调用reqCallback
        request:start()

    end

    local code = codr or "hall";
    cct.httpReq2({

        url = HttpAddr .. "/version/queryVersion",
        data = {
            type = tostring(type)
        },
        callBack = function(data)

            dump(data,"-----请求大厅版本返回-----")

            local data = data.data
            dump(data,"-----请求大厅版本返回-----")
            if not data then

                self:showLoadingTips("请求大厅版本异常, 即将重试")

                --重新进行当前请求
                self:queryVersion(type)

                return

            else
         
                local url = data["updateUrl"]
                local ver = data["version"]
                dump(url, "-----大厅下载地址-----")
                dump(ver, "-----大厅最新版本号-----")

                if url ~= nil and ver ~= nil then
                    --更新大厅
                    self:updateGame(url, ver, gid, code)
                end

                return

            end

        end

    })
   

end

--返回大厅
function HallUpdate:enterHall()
    -- body
    display_scene("hall.gameScene" , 1)
end

--进入hallScene，开始初始化程序
function HallUpdate:enterHall2()
    display_scene("hall.hallScene" , 1)
end

--更新
function HallUpdate:updateGame(url,version,gid,code)

    --本地校验版本号
    local flagTest = self:checkVersion(code,version)
    print("flagTest", flagTest)
    if flagTest == false then
        self:enterHall2(code)
        return;
    end

    local frameTimeCount = 0
    pathToSave = cc.FileUtils:getInstance():getWritablePath()

    self:showLoadingTips("正在更新大厅")
    self:setLoadingProgress(url, 0)

    local function onError(errorCode)

        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then

            dump("没有新版本", "-----大厅更新-----")
            self:enterHall2(code)

        elseif errorCode == cc.ASSETSMANAGER_NETWORK then --网络错误更新失败

            dump("网络错误", "-----大厅更新-----")
            self:showLoadingTips("网络异常下载更新失败") --exit game

            if nil ~= assetsManager then
                assetsManager:release()
                assetsManager = nil
                print("release assets manager")
            end

            self:queryVersion(2)

        else

            dump("更新出错", "-----大厅更新-----")
            self:showLoadingTips("更新出错")

            if nil ~= assetsManager then
                assetsManager:release()
                assetsManager = nil
                print("release assets manager")
            end

            self:queryVersion(2)

        end

    end

    local function onProgress( percent )
        self:setLoadingProgress(url, percent)
    end

    local function onSuccess()

        dump("更新成功", "-----大厅更新-----")

        --记录大厅版本
        local strKey = code .. "_current-version"
        cc.UserDefault:getInstance():setStringForKey(strKey, version)

        --重新加载lua
        require("app.MyApp"):run()

    end

    local function getAssetsManager()

        if nil == assetsManager then
            print(url)
            print(version)
            assetsManager = cc.AssetsManager:new(url,version,pathToSave)
            -- assetsManager = cc.AssetsManager:new(strFile,strVersion,pathToSave)
            assetsManager:retain()
            assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
            assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
            assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
            assetsManager:setConnectionTimeout(3)
        end

        return assetsManager
    end

    local function onNodeEvent(msgName)
        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end
    end

    print("scene name[%s]",SCENENOW["name"])
    SCENENOW["scene"]:registerScriptHandler(onNodeEvent)

    local bUpdated = false
    local function update(dt)
        frameTimeCount = frameTimeCount + dt

        if frameTimeCount >= 1.5 and bUpdated == false then
            getAssetsManager():update()
            print("update assets")
            bUpdated = true
        end
    end
    SCENENOW["scene"]:scheduleUpdateWithPriorityLua(update,0)

end

function HallUpdate:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
end

function HallUpdate:_initUIView(csbNode)
    local bg = csbNode:getChildByName("bg")
    local precent = self:_getScaleParam()
    if bg then
        bg:setScaleX(bg:getScale()*precent)
        local x = bg:getPositionX()
        bg:setPositionX(x*precent)
    end

    local root = csbNode:getChildByName("content")
    if root then
        local child = root:getChildren()
        for i, v in ipairs( child or {} ) do
            local x = v:getPositionX()
            v:setPositionX(x*precent)
            if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                local size = v:getContentSize()
                v:setContentSize(cc.size(size.width * precent, size.height))
            end
        end 
    end
end

--登陆loading
function HallUpdate:landLoading(flag)

    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading == nil then
        layerLoading = cc.CSLoader:createNode("res/loading/loadingLayer.csb"):addTo(SCENENOW["scene"])
        self:_initUIView(layerLoading)
        layerLoading:setName("layout_loading")
    else
        if flag == false then
            -- layerLoading:setVisible(false)
            SCENENOW["scene"]:removeChildByName("layout_loading")
            print("GameCommon:landLoading false")
            return
        end

        layerLoading:setLocalZOrder(20000)
        layerLoading:setVisible(true)

        --进度条
        local content = layerLoading:getChildByName("content")
        local processBg = content:getChildByName("processBg")
        local progress = processBg:getChildByName("loadingBar")
        progress:setPercent(0)
        local txt_progress = content:getChildByName("precentTxt")
        txt_progress:setString(0)
        --local moveNode = content:getChildByName("moveNode")
        --moveNode:setVisible(false)
    end

end

--加载过程中提示
function HallUpdate:showLoadingTips(str)
    -- body
    print("GameCommon:showLoadingTips")
    if not SCENENOW["scene"] then
        --todo
        return;
    end
    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        local content = layerLoading:getChildByName("content")
        local txt = content:getChildByName("desTxt")
        if txt then
            txt:setString(str)
            txt:setColor(cc.c3b(0xff,0xff,0xff))
        else
            print("can't match Text_1")
        end
    else
        self:landLoading(true)
        layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
        if layerLoading then
            local content = layerLoading:getChildByName("content")
            local txt = content:getChildByName("desTxt")
            if txt then
                txt:setString(str)
                txt:setColor(cc.c3b(0xff,0xff,0xff))
            else
                print("can't match Text_1")
            end
        else
            print("can't match layout_loading")
        end
    end
end

--更新出错弹框
function HallUpdate:showTips(title, code, bShowButton, msg, sure_func)

    if SCENENOW["scene"] then

        --释放之前的
        local s = SCENENOW["scene"]:getChildByName("hallUpdateTips")
        if s then
            s:removeSelf()
        end

        s = cc.CSLoader:createNode("res/tips/LayerTips.csb")
        s:setName("hallUpdateTips")

        if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
            s:setScale(0.75)
        end

        SCENENOW["scene"]:addChild(s, 99998)

        local layer = s:getChildByName("tips_back_1")

        --显示标题
        local txt = layer:getChildByName("txt_msg")
        if txt then
            txt:setString(title)
        end

        --显示内容
        local msg_tt = layer:getChildByName("msg_tt")
        msg_tt:setString(msg)

        local btnSubmit = layer:getChildByName("btn_submit")
        local btnCancel = layer:getChildByName("btn_cancel")

        if bShowButton == 0 then
            btnCancel:setVisible(false)
            btnSubmit:setVisible(false)
        end

        if bShowButton == 1 then
            --显示取消与确定

        elseif bShowButton == 2 then--只显示取消按钮

            btnSubmit:setVisible(false)

            btnCancel:setVisible(true)
            btnCancel:setPosition(cc.p(400.00*self._getScaleParam(), 137.00))

        elseif bShowButton == 3 then--只显示确定按钮

            btnSubmit:setVisible(true)
            btnSubmit:setPosition(cc.p(400.00*self._getScaleParam(), 137.00))

            btnCancel:setVisible(false)

        elseif bShowButton == 4 then--全不显示

            btnSubmit:setVisible(false)
            btnCancel:setVisible(false)

        end

        local function touchEvent(sender, event)

            --触摸开始
            if event == TOUCH_EVENT_BEGAN then

            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then

            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then

                --现在去（确定）
                if sender == btnSubmit then
                     
                    if SCENENOW["scene"]:getChildByName("hallUpdateTips") then
                        SCENENOW["scene"]:removeChildByName("hallUpdateTips")
                    end

                    if sure_func then
                        sure_func()
                    end

                end

                --下次吧（取消）
                if sender == btnCancel then

                    if SCENENOW["scene"]:getChildByName("hallUpdateTips") then
                        SCENENOW["scene"]:removeChildByName("hallUpdateTips")
                    end

                end
            
            end

        end

        btnSubmit:addTouchEventListener(touchEvent)
        btnCancel:addTouchEventListener(touchEvent)
        
    end

end

--显示更新进度
function HallUpdate:setLoadingProgress(url, progress)

    if progress < 0 then
        return
    end

    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        if progress < 0 then
            progress = 0
        end
        local content = layerLoading:getChildByName("content")
        local processBg = content:getChildByName("processBg")
        local spLoading = processBg:getChildByName("loadingBar")
        --local spLoading = content:getChildByName("loadingBar")
        if spLoading then
            if spLoading:isVisible() == false then
                spLoading:setVisible(true)
            end
            spLoading:setPercent(progress)
        end
        local txt_progress = content:getChildByName("precentTxt")
        -- txt_progress:setString(tostring(url) .. "" ..  tostring(progress).."%")
        txt_progress:setString(tostring(progress).."%")

        --self:setMoveNodePos(content:getChildByName("moveNode"), progress)
    end

end

function HallUpdate:setMoveNodePos(node, precent)
    local beginPos = 292 + 624*(self._getScaleParam()-1)
    local endPos   = 946 + 624*(self._getScaleParam()-1)
    local moveDistan = (endPos-beginPos)*(precent/100)
    node:setPositionX((beginPos+moveDistan))--*self._getScaleParam()
    node:setVisible(true)
    if precent > 10 then
        node:getChildByName("flag2"):setVisible(true)
    end
end

--默认更新进度条
function HallUpdate:DefaultProgress()
    -- body
    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        local content = layerLoading:getChildByName("content")
        local processBg = content:getChildByName("processBg")
        local spLoading = processBg:getChildByName("loadingBar")
        --local spLoading = content:getChildByName("loadingBar")
        if spLoading then
            local progress = 0
            local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
                -- body
                progress = progress + 9.8
                self:setLoadingProgress(progress)
            end))
            local rep = cc.Repeat:create(seq,10)
            spLoading:runAction(rep)
        end
    end
end

--校验版本号
function HallUpdate:checkVersion(code,version)

    local strKey = code .. "_current-version"
    local localVersion = cc.UserDefault:getInstance():getStringForKey(strKey,"")
    local tbRemote = {}
    local tbLocal = {}

    print("local ver:",localVersion,"remote ver:",version)

    strKey = localVersion
    if strKey == "" then
        tbLocal[1] = 0
    else
        tbLocal = string.split(localVersion,".")
        for i = 1, #tbLocal do
            tbLocal[i] = tonumber(tbLocal[i])
        end
    end
    dump(tbLocal,"tbLocal")

    tbRemote = string.split(version,".")
    for i = 1, #tbRemote do
        tbRemote[i] = tonumber(tbRemote[i])
    end
    dump(tbRemote,"tbRemote")

    for i = 1, #tbLocal do
    
        if tbLocal[i] > tbRemote[i] then
            return false
        end

        if i == #tbRemote then
            if tbLocal[i] == tbRemote[i] then
                return false
            end
        end

    end

    return true

end

return HallUpdate