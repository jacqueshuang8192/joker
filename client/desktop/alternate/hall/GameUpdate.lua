

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameUpdate  = class("GameUpdate")


local nFreeGameCounts = 0
local nMatchGameCounts = 0
local updateStatus = 0


local timerOut=10
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

--获取服务器版本
function GameUpdate:queryVersion(gid,code,bSee,name)

    bSee = bSee or 1
    if not code then
        return
    end

    print("queryVersion needUpdate",tostring(needUpdate))

    if not needUpdate then
        --todo
        if bSee >0 then
            --todo
            self:enterGame(code)
        else 
            --todo
            self:enterScene(code)
        end
        return;   
    end

    local h
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/version/queryVersion"
    xhr:open("POST", httpurl)
    print("queryVersion ===== >" .. httpurl)

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
            xhr.success=true;
            self:unscheduleGlobal(h)
            local data = json.decode(xhr.response)["data"]
            if data then
                local Manual = data["isManual"]
                local url = data["updateUrl"]
                local ver = data["version"]
                -- self:checkLocalVersion(code)
                dump(data, "queryVersion")
                if bSee > 0 then
                    if Manual > 0 then
                        self:updateGame(url,ver,gid,code)
                    else
                        self:showTips(code,name,url,ver,gid)
                    end
                else
                    self:updteGameUnsee(url,ver,gid,code)
                end
            else
                self:queryVersion(gid,code,bSee,name);
                return;
            end
        else
            -- print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            -- if USER_INFO["enter_mode"] > 0 then
            --     self:enterScene(code)
            -- else
            --     self:enterGame(code)
            -- end
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "type=3".."&gameId="..tostring(gid)
    xhr:send(strPost)

    print("USER_INFOnter_mode", USER_INFO["enter_mode"])
    if  USER_INFO["enter_mode"] ~=0 then
        --todo
        xhr.success=false;
        h=scheduler.performWithDelayGlobal(function()
            if not xhr.success then --请求版本失败
                --todo
                --网络异常
                --self:showLoadingTips("请求大厅版本超时");
                --重新开始
                --require(modname)
                -- if isGroup then
                if require("hall.gameSettings"):getGameMode() == "group" then
                    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                else
                    require("hall.GameCommon"):gExitGame();
                end
                
            end
            self:unscheduleGlobal(h)
        end, timerOut)
    end
    
    print(strPost)

end

--非强制，提示更新
function GameUpdate:showTips(code,game,url,ver,gid)
    -- body
    print("show tips")
    if SCENENOW["scene"] then
        local s = cc.CSLoader:createNode("hall/LayerTips.csb")
        s:setName("layer_tips")
        SCENENOW["scene"]:addChild(s)
        local layer = s:getChildByName("tips_back_1")
        local txt = layer:getChildByName("txt_msg")
        if txt then
            txt:setString("更新"..game.."游戏")
            txt:enableOutline(cc.c4b(58,35,10,255),1)
        end
        local lbTitle = layer:getChildByName("txt_title")
        if lbTitle then
            lbTitle:enableOutline(cc.c4b(58,35,10,255),1)
        end

        local btnSubmit = layer:getChildByName("btn_submit")
        local btnCancel = layer:getChildByName("btn_cancel")

        
            local function touchEvent(sender, event)
                if event == TOUCH_EVENT_ENDED then
                    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
                    if sender == btnSubmit then
                        if SCENENOW["scene"]:getChildByName("layer_tips") then
                            SCENENOW["scene"]:removeChildByName("layer_tips")
                        end
                        self:updateGame(url,ver,gid,code)
                    end
                    if sender == btnCancel then
                        if SCENENOW["scene"]:getChildByName("layer_tips") then
                            SCENENOW["scene"]:removeChildByName("layer_tips")
                        end
                        self:enterGame(code)
                    end
                end
            end

            btnSubmit:addTouchEventListener(touchEvent)
            btnCancel:addTouchEventListener(touchEvent)

    end

end

--检验本地版本
function GameUpdate:checkLocalVersion(code)
    -- body
    local strKey = code.."_current-version"
    local strVersion = cc.UserDefault:getInstance():getStringForKey(strKey,"")
    print(strKey..":"..strVersion)
    local nPos = string.len(strVersion)
    if nPos > 40 then
        cc.UserDefault:getInstance():setStringForKey(strKey,"")
    end
end

--进入游戏
function GameUpdate:enterGame(code)
    -- bodyenterGame

    dump(code, "-----游戏更新,进入游戏-----")

    require("hall.GameCommon"):landLoading(false)
    code = code or "hall"
    print("entered hall game code id ",code)
    local strGame = code.."."..code.."Scene"
    USER_INFO["current_code"] = code
    print(strGame)
    display_scene(strGame,1)
    -- end
end

--直接进入游戏
function GameUpdate:enterScene(code)

    if  require("hall.GameList"):getReloadTable() > 0 then
        self:enterGroup(code)
    else
        if  SCENENOW["name"] == "hall.hallScene" then
            SCENENOW["scene"]:gameUpdateFinished()
        end
    end

end

--进入组局
function GameUpdate:enterGroup(code)

    --进入游戏
    dump(code, "-----进入组局-----")
    bm.isInGame = true

    local strGame = code .. ".gameScene"
    display_scene(strGame, 1)
    print("xtl")
    --移除所有加载进度条
    --require("hall.GameCommon"):landLoading(false)
    --require(NetworkLoadingView_filePath):removeView()

    --移除所有加载圈

    --if SCENENOW["scene"]:getChildByName("loading") then
    --    SCENENOW["scene"]:removeChildByName("loading")
    --end

end


function GameUpdate:reloadPackage(rootPath)  --lua的模块在require后会进入package.loaded,导致重新加载时不会全部更新
    local fileOperate = require("hall.util.fileOperate")
    fileOperate:init()
    if rootPath and rootPath ~= "" then  --搜索目录为空字符串时会搜索所有文件
        local paths = fileOperate:GetAllLuaFiles(rootPath)
        -- dump(paths,"reloadPackage")
        for _,path in pairs(paths) do
            path = string.gsub(path,".lua","")
            path = string.gsub(path,"\\",".")
            package.loaded[path] = nil 
        end
    end

    dump("package.loaded_purged")
end


--获取更新状态
function GameUpdate:getUpdateStatus()
    -- body
    return updateStatus
end

--设置更新状态
function GameUpdate:setUpdateStatus(status)
    -- body
    updateStatus = status
end

--更新
function GameUpdate:updateGame(url,version,gid,code)

    dump(url, "-----游戏更新信息-----")
    dump(version, "-----游戏更新信息-----")
    dump(gid, "-----游戏更新信息-----")
    dump(code, "-----游戏更新信息-----")

    --检查连接是否正常
    local strUrl = string.lower(url)
    dump(strUrl, "-----游戏更新地址-----")
    if string.find(strUrl,".zip") == nil then
        print("-----游戏更新string.find(strUrl，.zip) == nil-----")
        self:enterGame(code)
        return
    end

    dump(code, "-----进入更新游戏-----")

    updateStatus = 1

    local strGame = "layout_game" .. tostring(gid)
    local layerout = SCENENOW["scene"]._scene:getChildByName("gamelist_ly"):getChildByName(strGame)
    local loadingBar = layerout:getChildByName("loading")

    dump(strGame, "-----下载圈设置完毕-----")

    local assetsManager = nil
    local pathToSave = ""
    pathToSave = cc.FileUtils:getInstance():getWritablePath()

    dump(pathToSave, "-----储存路径-----")

    local function onError(errorCode)

        dump(errorCode, "-----更新游戏出错，错误码-----")

        local gamedata = {}
        gamedata.url = url
        gamedata.version = version
        gamedata.gid = gid
        gamedata.code = code

        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end

        updateStatus = 0

        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then

            print("no new version")
            self:enterGame(code)

        elseif errorCode == cc.ASSETSMANAGER_NETWORK then

            print("network error")
            -- require("hall.GameTips"):showTipsUpdate("网络异常下载更新失败",url,version,gid,code)
            local data = {type = 1, title = "提示", content = "网络异常，下载更新失败"} 
            require(CommonTips_filePath):showTips(data)
            -- require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "网络异常，下载更新失败", gamedata)

        else

            -- require("hall.GameTips"):showTipsUpdate("更新出错",url,version,gid,code)
            local data = {type = 1, title = "提示", content = "网络异常，下载更新失败"} 
            require(CommonTips_filePath):showTips(data)
            -- require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "下载更新失败，请稍候再试", gamedata)

        end

    end

    local function onProgress(percent)

        if nil ~= loadingBar then
            if loadingBar:isVisible() == false then
                loadingBar:setVisible(true)
                local spMash = layerout:getChildByName("spMash")
                if spMash then
                    spMash:setVisible(false)
                end
            end

            local nPer = 100 - percent
            if nPer < 0 then
                nPer = 0
            elseif nPer > 100 then
                nPer = 100
            end
            loadingBar:setPercentage(nPer)
        end

    end

    local function onSuccess()
        
        dump(SCENENOW["name"], "-----更新游戏成功，当前情景是-----")

        updateStatus = 0
        local strKey = code .. "_current-version"
        cc.UserDefault:getInstance():setStringForKey(strKey,version)

        --设置当前选择的游戏
        if SCENENOW["name"] == "hall.gameScene" then
            
            --进入对应游戏金币场列表
            require(HallServer_filePath):loginAlloc(USER_INFO["GroupLevel"])
            
        end

    end

    local function getAssetsManager()

        if nil == assetsManager then
            dump(url, "-----更新游戏getAssetsManager-----")
            dump(version, "-----更新游戏getAssetsManager-----")
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

    getAssetsManager():update()

    local function onNodeEvent(msgName)
        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end
    end

    print("更新游戏，当前场景名：scene name[%s]",SCENENOW["name"])

    SCENENOW["scene"]:registerScriptHandler(onNodeEvent)

end

--非视更新
function GameUpdate:updteGameUnsee(url,version,gid,code)
    -- body
    --检查本地版本号
    print("code,version"..code.." "..version)
    if require("app.HallUpdate"):checkVersion(code,version) == false then
        --self:enterScene(code) 
        return
    end

    local assetsManager = nil
    local pathToSave = ""
    local strGame = "game"..tostring(id)
    --require(NetworkLoadingView_filePath):showLoading("正在更新游戏")
    --require("hall.GameCommon"):showLoadingTips("正在更新游戏")
    pathToSave = cc.FileUtils:getInstance():getWritablePath()

    updateStatus = 1

    local function onError(errorCode)

        local gamedata = {}
        gamedata.url = url
        gamedata.version = version
        gamedata.gid = gid
        gamedata.code = code

        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end

        updateStatus = 0
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            print("no new version")
            self:enterScene(code)
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            print("network error")
            -- require("hall.GameTips"):showTipsUpdate("网络异常下载更新失败",url,version,gid,code,0)
            local data = {type = 1, title = "提示", content = "网络异常，下载更新失败", callBackSingleSure = handler(self, self.updateErrorCallBack)} 
            require(CommonTips_filePath):showTips(data)


        else
            -- require("hall.GameTips"):showTipsUpdate("更新出错",url,version,gid,code,0)
            local data = {type = 1, title = "提示", content = "下载更新失败，请稍候再试", callBackSingleSure = handler(self, self.updateErrorCallBack)} 
            require(CommonTips_filePath):showTips(data)

        end

        print("onError:%d",errorCode)

    end

    function GameUpdate:updateErrorCallBack()
        -- body
    end

    local function onProgress(percent)
        if SCENENOW["name"] == "hall.hallScene" then
            require("hall.GameCommon"):setLoadingProgress(percent)
        end
    end

    local function onSuccess()
        print("update success")
        updateStatus = 0
        require(NetworkLoadingView_filePath):removeView(10)
    end

    local function getAssetsManager(strGame)
        if nil == assetsManager then
            assetsManager = cc.AssetsManager:new(url,version,pathToSave)
            assetsManager:retain()
            assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
            assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
            assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
            assetsManager:setConnectionTimeout(3)
        end

        return assetsManager
    end

    getAssetsManager():update()

    local function onNodeEvent(msgName)
        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end
    end

    SCENENOW["scene"]:registerScriptHandler(onNodeEvent)
end

function GameUpdate:getState()
    -- body
    return updateStatus
end

-------------------------------------------------------------------------------------------------------------------------------------------------

--获取游戏最新版本（加入组局时用）
function GameUpdate:queryVersionInJoinGame(gid,code,bSee,name, callback)

    dump("", "-----检查游戏版本（加入组局时用）-----")

    bSee = bSee or 1
    if not code then
        if callback then
            callback()
        end
        return
    end

    --假如配置中记录不需要更新，则直接进入游戏
    if not needUpdate then
        if callback then
            callback()
        else
            require("hall.GameUpdate"):enterGroup(code)
        end
        return
    end

    local h
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/version/queryVersion"
    xhr:open("POST", httpurl)
    -- print("获取服务器版本的链接 ===== >" .. httpurl)

    local function onReadyStateChange()

        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
            xhr.success=true;
            self:unscheduleGlobal(h)

            local data = json.decode(xhr.response)["data"]
            if data then
                local Manual = data["isManual"]
                local url = data["updateUrl"]
                local ver = data["version"]

                -- dump(ver,"queryVersionInJoinGame_version")
                if require("hall.GameData"):compareLocalVersion(ver,code) > 0 then
                    --更新游戏
                    self:updateGameInJoinGame(url,ver,gid,code, callback)
                else
                    if callback then
                        callback()
                    else
                        require("hall.GameUpdate"):enterGroup(code)
                    end
                end

            else
                --重新获取游戏版本
                self:queryVersionInJoinGame(gid,code,bSee,name);
                return;
            end

        else
            --重新获取游戏版本
            self:queryVersionInJoinGame(gid,code,bSee,name);
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "type=3".."&gameId="..tostring(gid)
    xhr:send(strPost)

    print("USER_INFOnter_mode", USER_INFO["enter_mode"])
    if USER_INFO["enter_mode"] ~=0 then
        --todo
        xhr.success=false;
        h=scheduler.performWithDelayGlobal(function()
            if not xhr.success then --请求版本失败
                --网络异常
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                require("hall.GameCommon"):landLoading(false)
                
            end
            self:unscheduleGlobal(h)
        end, timerOut)
    end
    
    print(strPost)

end

--更新游戏（加入组局时用）
function GameUpdate:updateGameInJoinGame(url,version,gid,code, callback)

    dump(updateStatus, "-----更新游戏（加入组局时用）-----")

    if updateStatus ~= 1 then

        --检查连接是否正常
        local strUrl = string.lower(url)
        dump(strUrl, "-----游戏更新地址-----")
        if string.find(strUrl,".zip") == nil then
            if callback then
                callback()
            else
                require("hall.GameUpdate"):enterGroup(code)
            end
            return
        end

        --检查本地版本号
        if require("app.HallUpdate"):checkVersion(code,version) == false then
            print("-----检查本地版本号，返回不用更新游戏，则直接进入游戏-----")
            if callback then
                callback()
            else
                require("hall.GameUpdate"):enterGroup(code)
            end
            return
        end

        updateStatus = 1

        local assetsManager = nil
        local pathToSave = ""

        if SCENENOW["name"] == GameScene_filePath then
            require("hall.GameCommon"):showLoadingTips("正在更新游戏")
        end

        pathToSave = cc.FileUtils:getInstance():getWritablePath()

        --更新错误处理
        local function onError(errorCode)

            updateStatus = 0

            if nil ~= assetsManager then
                assetsManager:release()
                assetsManager = nil
            end

            local data = {}
            data["url"] = url
            data["version"] = version
            data["gid"] = gid
            data["code"] = code

            if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
                --没有新版本，直接进入游戏
                if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
                    g_hallMainLayer.familyMainlayer = nil
                end
                if callback then
                    callback()
                else
                    require("hall.GameUpdate"):enterGroup(USER_INFO.USER_INFO)
                end
            elseif errorCode == cc.ASSETSMANAGER_NETWORK then
                --网络不可用
                -- require("hall.GameTips"):showTipsUpdate("网络异常下载更新失败",url,version,gid,code)
                local data = {type = 1, title = "更新游戏", content = "网络异常，更新游戏出错", callBackSingleSure = handler(self, self.updateErrorCallBack)}
                require(CommonTips_filePath):showTips(data)
                require("hall.GameCommon"):landLoading(false)

            else
                --其他原因导致更新出错
                -- require("hall.GameTips"):showTipsUpdate("更新出错",url,version,gid,code)
                local errorMsg = ""

                if  errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
                    errorMsg = "解压出错，请重启游戏！"
                elseif  errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
                    errorMsg = "没有新版本，请重试"
                end

                local data = {type = 1, title = "更新游戏", content = errorCode, callBackSingleSure = handler(self, self.exitGame)}
                require(CommonTips_filePath):showTips(data)
                require("hall.GameCommon"):landLoading(false)

            end

            print("onError:%d", errorCode)

        end

        --更新进度显示
        local function onProgress(percent)
            dump(code .. ":" ..percent, "-----游戏更新，当前进度-----")
            if SCENENOW["name"] == "hall.gameScene" then
                require("hall.GameCommon"):setLoadingProgress(percent)
            end
        end

        local function onSuccess()
            
            dump(SCENENOW["name"], "-----更新游戏成功，进入游戏，当前场景是：-----")

            --重置更新状态
            updateStatus = 0

            --记录当前游戏版本
            local strKey = code .. "_current-version"
            cc.UserDefault:getInstance():setStringForKey(strKey,version)

            -- --成功下载后先清除文件夹的package.loaded缓存
            self:reloadPackage(code)

            --进入游戏
            if callback then
                callback()
            else
                require("hall.GameUpdate"):enterGroup(code)
            end
            if isShowZaiXianYq then
                local OnineYaoQing=require("hall.roomCommonUI.zaixianyaoqingLayer").new()
                OnineYaoQing:setName("OnineYaoQingLayer")
                OnineYaoQing:addTo(SCENENOW["scene"],SCENENOW["scene"]:getChildrenCount() + 10)
            end

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

        getAssetsManager():update()

        local function onNodeEvent(msgName)
            if nil ~= assetsManager then
                assetsManager:release()
                assetsManager = nil
                print("release assets manager")
            end
        end

        print("scene name[%s]",SCENENOW["name"])
        SCENENOW["scene"]:registerScriptHandler(onNodeEvent)

    end
    
end

function GameUpdate:exitGame()
    cc.Director:getInstance():endToLua()
end

-------------------------------------------------------------------------------------------------------------------------------------------------

--获取游戏最新版本（重连用）
function GameUpdate:queryVersionInReconnect(gid,code,bSee,name)

    dump("", "-----获取游戏最新版本（重连用）-----")

    bSee = bSee or 1
    if not code then
        return
    end

    --假如配置中记录不需要更新，则直接进入游戏
    if  not needUpdate then
        require("hall.GameUpdate"):enterGroup(code)
        return
    end

    local h
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/version/queryVersion"
    xhr:open("POST", httpurl)
    print("获取服务器版本的链接 ===== >" .. httpurl)

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
            xhr.success=true;
            self:unscheduleGlobal(h)
            local data = json.decode(xhr.response)["data"]
            if data then
                local Manual = data["isManual"]
                local url = data["updateUrl"]
                local ver = data["version"]

                --更新游戏
                self:updateGameInReconnect(url,ver,gid,code)

            else
                --重新获取游戏版本
                self:queryVersionInReconnect(gid,code,bSee,name);
                return;
            end

        else
            --重新获取游戏版本
            self:queryVersionInReconnect(gid,code,bSee,name);
        end

    end

    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "type=3" .. "&gameId="..tostring(gid)
    xhr:send(strPost)

    print("USER_INFOnter_mode", USER_INFO["enter_mode"])
    if USER_INFO["enter_mode"] ~= 0 then
        xhr.success = false;
        h=scheduler.performWithDelayGlobal(function()
            if not xhr.success then --请求版本失败
                --网络异常
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                
            end
            self:unscheduleGlobal(h)
        end, timerOut)
    end
    
    print(strPost)

end

--更新游戏（重连用）
function GameUpdate:updateGameInReconnect(url,version,gid,code)

    dump(updateStatus, "-----更新游戏（重连用）-----")

    if updateStatus ~= 1 then
        
        --检查连接是否正常
        local strUrl = string.lower(url)
        dump(strUrl, "-----游戏更新地址-----")
        if string.find(strUrl,".zip") == nil then
            if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
                g_hallMainLayer.familyMainlayer = nil
            end
            require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
            return
        end

        --检查本地版本号
        if require("app.HallUpdate"):checkVersion(code,version) == false then
            print("-----检查本地版本号，返回不用更新游戏，则直接进入游戏-----")
            if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
                g_hallMainLayer.familyMainlayer = nil
            end
            require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
            return
        end

        updateStatus = 1

        local assetsManager = nil
        local pathToSave = ""

        if SCENENOW["name"] == GameScene_filePath then
            require("hall.GameCommon"):showLoadingTips("正在更新游戏")
        end
        pathToSave = cc.FileUtils:getInstance():getWritablePath()

        --更新错误处理
        local function onError(errorCode)

            updateStatus = 0

            if nil ~= assetsManager then
                assetsManager:release()
                assetsManager = nil
            end

            local data = {}
            data["url"] = url
            data["version"] = version
            data["gid"] = gid
            data["code"] = code

            if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
                --没有新版本，直接进入游戏
                if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
                    g_hallMainLayer.familyMainlayer = nil
                end
                require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])

            elseif errorCode == cc.ASSETSMANAGER_NETWORK then
                --网络不可用
                -- require("hall.GameTips"):showTipsUpdate("网络异常下载更新失败",url,version,gid,code)
                local data = {type = 1, title = "更新游戏", content = "网络异常，更新游戏出错"} 
                require(CommonTips_filePath):showTips(data)
                require("hall.GameCommon"):landLoading(false)

            else
                --其他原因导致更新出错
                -- require("hall.GameTips"):showTipsUpdate("更新出错",url,version,gid,code)
                local data = {type = 1, title = "更新游戏", content = "未知错误:" .. errorCode .. "，请重试"} 
                require(CommonTips_filePath):showTips(data)
                require("hall.GameCommon"):landLoading(false)

            end

            print("onError:%d", errorCode)

        end

        --更新进度显示
        local function onProgress(percent)
            dump(code .. ":" ..percent, "-----游戏更新，当前进度-----")
            if SCENENOW["name"] == "hall.gameScene" then
                require("hall.GameCommon"):setLoadingProgress(percent)
            end
        end

        local function onSuccess()
            
            dump(SCENENOW["name"], "-----更新游戏成功，进入游戏，当前场景是：-----")

            --重置更新状态
            updateStatus = 0

            --记录当前游戏版本
            local strKey = code .. "_current-version"
            cc.UserDefault:getInstance():setStringForKey(strKey,version)

            --进入游戏
            require("hall.GameUpdate"):enterGroup(code)

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

        getAssetsManager():update()

        local function onNodeEvent(msgName)
            if nil ~= assetsManager then
                assetsManager:release()
                assetsManager = nil
                print("release assets manager")
            end
        end

        print("scene name[%s]",SCENENOW["name"])
        SCENENOW["scene"]:registerScriptHandler(onNodeEvent)

    end
    
end
function GameUpdate:unscheduleGlobal( h )
    if type(h) == "number" then
        scheduler.unscheduleGlobal(h)
    end
end
return GameUpdate