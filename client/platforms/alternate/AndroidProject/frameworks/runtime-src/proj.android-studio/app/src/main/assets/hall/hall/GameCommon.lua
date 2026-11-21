local GameCommon  = class("GameCommon")
local headCache = {}
local head_2Path = "hall/scene/res/common/image/head_2.png"--圆角正方形
local fs = require("hall.tool.utils.fs")

--获取本地游戏版本号
function GameCommon:getGameVersion(game)

    local strKey = game.."_current-version"
    print("get version key:"..strKey)
    local strVersion = cc.UserDefault:getInstance():getStringForKey(strKey,"")
    print("-----获取["..game.."] 版本号是：["..strVersion.."]")
    return strVersion
    
end

function GameCommon:setLabelStringByLimitWidthOfOtherStr(labelObj,limitWidth,otherStr)
    -- body
    local function getStrMap(str)
        -- body
        local  strTab = {}
        for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do
            strTab[#strTab+1] = uchar
        end
        return strTab
    end
    if labelObj:getContentSize().width <= limitWidth then return end
    local labelStr = labelObj:getString()
    local strMap = getStrMap(labelStr)
    labelObj:setDimensions(0,0)
    local setStr = ""
    local tempStr2 = ""
    local otherStr = otherStr
    for k,v in pairs(strMap) do
        local tempStr = tempStr2..v
        labelObj:setString(tempStr..otherStr)
        if labelObj:getContentSize().width > limitWidth then
            break
        else
            tempStr2 = tempStr
        end    
    end
    setStr = setStr..tempStr2..otherStr
    labelObj:setString(setStr)
end


function GameCommon:getLabelStringByLimitWidth(labelStr,limitWidth)
    -- body
    local function getStrMap(str)
        -- body
        local  strTab = {}
        for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do
            strTab[#strTab+1] = uchar
        end
        return strTab
    end 
    local labelStr = labelStr
    local strMap = getStrMap(labelStr)
    local setStr = ""
    local tempStr2 = ""
    for k,v in pairs(strMap) do
        local tempStr = tempStr2..v
        labelObj:setString(tempStr)
        if labelObj:getContentSize().width > limitWidth then
            tempStr2 = tempStr2.."\n"
            setStr = setStr..tempStr2
            tempStr2 = ""
        else
            tempStr2 = tempStr
        end    
    end
    setStr = setStr..tempStr2
    return setStr
end

--退出组局
function GameCommon:gExitGroupGame(gameId , club_state)

    if  quickEnterRoom == true then   --一键复制加入房间功能时，退出房间后要重置剪切板
        require(GameSetting_filePath):resetClipboard()
    end 

    audio.stopMusic()
    audio.stopAllSounds()

    if club_state then 
        local game_obj = require("hall.gameScene").new(true)
        SCENENOW["scene"] = game_obj
        display.replaceScene(game_obj)
    else
        display_scene("hall.gameScene", 1)
    end
    
    HEART_BEAT_TID = 0

    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(nil,nil,"resetAllUser")
end

--退出大厅
function GameCommon:gExitGame()
    
    audio.stopMusic()
    audio.stopAllSounds()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        require("hall.GameSetting"):applyChangeUser()
    --     cc.Director:getInstance():purgeCachedData();
    --     --cc.Director:getInstance():endToLua();
    --     local luaj = require "cocos.cocos2d.luaj"
    --     local className =luaJniClass
      
    --     local ok,ret  = luaj.callStaticMethod(className,"exitGame")
    --     if not ok then
    --         print("exitGame luaj error:", ret)
    --     else
    --         print("exitGame PLATFORM_OS_ANDROID")
    --     end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        require("hall.GameSetting"):applyChangeUser()
    --     local args = {}
    --     local luaoc = require "cocos.cocos2d.luaoc"
    --     local className = "CocosCaller"
    --     local ok,ret  = luaoc.callStaticMethod(className,"exitGame")
    --     if not ok then
    --         cc.Director:getInstance():resume()
    --         print("exitGame PLATFORM_OS_IPHONE failed")
    --     else
    --         print("exitGame PLATFORM_OS_IPHONE")
    --     end
    else
        cc.Director:getInstance():endToLua()
    end

    -- display.replaceScene(display.newScene("null"))

end

--显示游戏设置
function GameCommon:showSettings(flag, bChangeUser, bDismiss, sDisband, disbandCallback, buttonShowName, additionalFunc, additionalShowName)

    require(Setting_filePath):showScene(flag, bChangeUser, bDismiss, sDisband, disbandCallback, buttonShowName,additionalFunc, additionalShowName)

end

function GameCommon:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
end

function GameCommon:_initUIView(csbNode)
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
function GameCommon:landLoading(flag,par)

    par = par or SCENENOW["scene"]
    if tolua.isnull(par) then
        return
    end
    local layerLoading = par:getChildByName("layout_loading")
    if layerLoading == nil  then

        layerLoading = cc.CSLoader:createNode("res/loading/loadingLayer.csb"):addTo(par)
        self:_initUIView(layerLoading)
        layerLoading:setName("layout_loading")
    end

    if layerLoading then

        if flag == false then
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
        if progress == nil then
            progress = content:getChildByName("loadingBar")
        end
        --local progress = content:getChildByName("loadingBar")
        progress:setPercent(0)
        local txt_progress = content:getChildByName("precentTxt")
        txt_progress:setString(0)
        --local moveNode = content:getChildByName("moveNode")
        --moveNode:setVisible(false)
    end

end

--加载过程中提示
function GameCommon:showLoadingTips(str)

    if not SCENENOW["scene"] then
        return;
    end

    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        local content = layerLoading:getChildByName("content")
        local txt = content:getChildByName("desTxt")
        if txt then
            txt:setString(str)
            txt:setColor(cc.c3b(255,255,255))
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

--显示更新进度
function GameCommon:setLoadingProgress(progress)
    -- body
    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        if progress < 0 then
            progress = 0
        end
        local content = layerLoading:getChildByName("content")
        local processBg = content:getChildByName("processBg")
        local spLoading = processBg:getChildByName("loadingBar")
        if spLoading == nil then
            spLoading = content:getChildByName("loadingBar")
        end
        if spLoading then
            if spLoading:isVisible() == false then
                spLoading:setVisible(true)
            end
            spLoading:setPercent(progress)
        end
        local txt_progress = content:getChildByName("precentTxt")
        if not tolua.isnull(txt_progress) then
            txt_progress:setString(tostring(progress).."%")
        end
        --self:setMoveNodePos(content:getChildByName("moveNode"), progress)
    end
end

--默认更新进度条
function GameCommon:DefaultProgress()
    -- body
    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        local content = layerLoading:getChildByName("content")
        local processBg = content:getChildByName("processBg")
        local spLoading = processBg:getChildByName("loadingBar")
        if spLoading == nil then
            spLoading = content:getChildByName("loadingBar")
        end
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

--设置 动画和进度条一起移动
function GameCommon:setMoveNodePos(node, precent)
    local beginPos = 292 + 624*(self._getScaleParam()-1)
    local endPos   = 946 + 624*(self._getScaleParam()-1)
    local moveDistan = (endPos-beginPos)*(precent/100)
    node:setPositionX((beginPos+moveDistan))--*self._getScaleParam()
    node:setVisible(true)
    --if precent > 10 then
    --    node:getChildByName("flag2"):setVisible(true)
    --end
end

--显示用户协议
function GameCommon:showAgreement(flag,msg)

    if flag == false then
        SCENENOW["scene"]:removeChildByName("layout_agreement")
        return
    end

    local layout = cc.CSLoader:createNode("hall/common/AgreementLayer.csb"):addTo(SCENENOW["scene"])
    layout:setLocalZOrder(91000)
    layout:setName("layout_agreement")

    local Panel_1 = layout:getChildByName("Panel_1")
    Panel_1:addTouchEventListener(
        function(sender,event)

            if event == TOUCH_EVENT_BEGAN then
                
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then

            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                layout:removeFromParent()
            end

        end
    )

    local floor = layout:getChildByName("floor")
    floor.noScale = true
    -- floor:onClick(function()
    --     layout:removeFromParent()
    -- end)

    local txtWidth = 650
    local txtHeight = 380
    local rowHeight = 20

    local txtCount = string.len(msg)
    local lineCount = (txtCount*10)/txtWidth

    if lineCount*rowHeight > txtHeight then
        --todo
        txtHeight = lineCount*rowHeight
    end

    print("GameCommon:showAgreement",txtCount,lineCount,txtHeight)

    local label = display.newTTFLabel({
        text = msg,
        font = "res/fonts/fzcy.ttf",
        size = 16,
        color = cc.c3b(234,30,30), -- 使用纯红色
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(txtWidth, txtHeight)
    })
    -- label:enableShadow(cc.c4b(234,238,187,255), cc.size(1,0))
    -- local label = cc.Label:createWithSystemFont(msg,"Arial",16,cc.size(txtWidth, txtHeight),cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    label:setLineHeight(rowHeight)

    local sv = floor:getChildByName("scroll_v")
    sv:setInnerContainerSize(cc.size(500, label:getContentSize().height / 1.4))
    label:setPosition(cc.p(label:getContentSize().width/2, 1270))
    sv:getInnerContainer():addChild(label)

end

--检查图片格式
function GameCommon:getUrlPicture(url)
    -- body
    if url == "" or url == nil then
        return ""
    end
    -- dump(url,"getUrlPicture")
    local strLower = string.lower(url)
    if string.find(strLower,"%.jpg") == nil and string.find(strLower,"%.png") == nil then
        return self:getUnformatPic(url)
    end
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    -- print("getUrlPicture:",strPic)
    return strPic
end

--获取非格式化图片名称
function GameCommon:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    strUrl = string.sub(strUrl,nPos+1,string.len(strUrl))
    nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    -- print("getUnformatPic:",strPic)
    return strPic..".jpg"
end

function GameCommon:setDefaultHead(head,uid,sex,size,isCircle,nick)

    isCircle = isCircle or false
    nick = nick or ""
    if isCircle then
        self:setCirleHead(head, "", size, uid, sex, "", nick)
    else
        self:setDefaultFangHead(head, "", size, uid, sex, "", nick)
    end
    
end

function GameCommon:setCirleHead(head, strIco, size, uid, sex, url, nick, disableTouch, type_, ip, addres)
    head:removeAllChildren()
    if head.clipnode then
        head.clipnode:removeSelf()
        head.clipnode = nil
    end
    if head.layerTouch then
        head.layerTouch:removeSelf()
        head.layerTouch = nil
    end
    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0)

    local stencil = cc.Node:create()
    clipnode:setStencil(stencil)
    local path = Stnecil_filePath
    if type_ == 1 then--正方圆角
        path = head_2Path
    end
    local spStnecil = display.newSprite(path)
    spStnecil:setScale(size/spStnecil:getContentSize().width)
    stencil:addChild(spStnecil)

    local content = nil
    file,fileErr = io.open(strIco)
    local fileexists = fs.exists(strIco)
    if fileexists then
        content = display.newSprite(strIco)
    else
        --content = display.newSprite(DefaultHead_filePath)
    end

    -- if fileErr == nil then
    --     local x = file:seek("end")
    --     if x > 0 then
    --         content = display.newSprite(strIco)
    --     else
    --         content = display.newSprite(DefaultHead_filePath)
    --     end
    -- else
    --     content = display.newSprite(DefaultHead_filePath)
    -- end
    -- local content = display.newSprite(strIco)
    if content ~= nil then
        content:setScaleX(size/content:getContentSize().width)
        content:setScaleY(size/content:getContentSize().height)
        clipnode:addChild(content)
    end


    clipnode:setPosition(head:getContentSize().width/2,head:getContentSize().height/2)
    head:addChild(clipnode)
    head.clipnode = head.clipnode
    if head.setTexture ~= nil then
        head:setTexture("")
    end

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))

    layerTouch:onClick(
        function(event)
            self:showPlayerInfoForGetHead(url,uid,sex,nick, ip, addres)
    end)
    
    if disableTouch == true then
        layerTouch:setTouchEnabled(false)
    else
        layerTouch:setTouchEnabled(true)
    end
    -- ly:setContentSize(cc.size(1183, 64.02))
    -- layerTouch:setBackGroundColorType(1)
    -- layerTouch:setBackGroundColor(cc.c3b(0, 0, 0))
    -- layerTouch:setBackGroundColorOpacity(200)
    layerTouch:setContentSize(cc.size(size,size))
    layerTouch:setPosition(size/2,size/2)
    head:addChild(layerTouch,9999999)
    head.layerTouch = head.layerTouch
end

function GameCommon:setDefaultFangHead(head, strIco, size, uid, sex, url, nick)
    
    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0)

    local stencil = cc.Node:create()
    clipnode:setStencil(stencil)

    local spStnecil = display.newSprite(Stnecil_filePath)
    spStnecil:setScale(size/spStnecil:getContentSize().width)
    stencil:addChild(spStnecil)

    local content
    local fileexists = fs.exists(strIco)
    if fileexists then
        content = display.newSprite(strIco)
    else
        content = display.newSprite(DefaultHead_filePath)
    end
    -- local content = display.newSprite(strIco)
    content:setPosition(head:getContentSize().width/2, head:getContentSize().height/2)
    content:setScaleX(size/content:getContentSize().width)
    content:setScaleY(size/content:getContentSize().height)
    -- clipnode:addChild(content)

    clipnode:setPosition(clipnode:getContentSize().width/2,clipnode:getContentSize().height/2)
    head:addChild(content)

    if head.setTexture ~= nil then
        head:setTexture("")
    end

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))
    layerTouch:setPosition(head:getContentSize().width/2, head:getContentSize().height/2)
    layerTouch:setTouchEnabled(true)
    layerTouch:addTouchEventListener(
        function(sender,event)
            if event == 2  then
                self:showPlayerInfoForGetHead(url,uid,sex,nick)
            end
    end)
    layerTouch:setContentSize(cc.size(size,size))
    head:addChild(layerTouch)

end


function GameCommon:downloadNetworkPic(url)

    local file = nil
    local fileErr = nil
    local spHead = nil
    
    --链接空，载入默认头像
    local strHead = self:getUrlPicture(url)

    if  strHead == nil or strHead == "" then
        return
    end

    --先在本地获取
    local imgFullPath = device.writablePath..strHead
    local fileexists = fs.exists(imgFullPath)
    if fileexists then
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

            cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)
        
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

-- local textureCache = cc.Director:getInstance():getTextureCache()
tu_Xiang_Img = {}
function GameCommon:getUserHead(url, uid, sex, sp, size, isCircle, nick, disableTouch, ip, addres)
    if not sp then
        return
    end
    isCircle = isCircle or false
    sex = sex or 0
    local file = nil
    local fileErr = nil
    local spHead = nil
    --链接空，载入默认头像 & 替换服务器上的图片
    if string.sub(url,1,string.len('XY::')) == 'XY::' then
        self.httpHead = string.gsub(HttpAddr, '/hbiInterface', '');
        self.httpSuffix = string.gsub(url, 'XY::', '');
        url = self.httpHead .. self.httpSuffix
    end

    local strHead = self:getUrlPicture(url)
    
    -- print("==strHead==",strHead)
    if strHead == nil or strHead == "" then
        print("==strHead is nil!!!==")
        self:setDefaultHead(sp,uid,sex,size,isCircle,nick)
        return
    end
    -- sp:retain();

    -- sp.name = nick
    -- dump(sp,"sp_getUserHead_________")
    local path = device.writablePath
    if device.platform == "windows" then
        path = device.writablePath.."cache\\" --获取本地存储目录
        if not fs.exists(path) then
            fs.mkdir(path) --目录不存在，创建此目录
        end
    end
    -- local strHead = crypto.md5(strHead, false)
    local imgFullPath = path..strHead

    --先在本地获取
    -- local imgFullPath = device.writablePath..strHead
    -- print("==imgFullPath==",imgFullPath)
    -- print("getUserHead-uid",uid)
    if  uid and headCache[uid] then 
        fileErr = nil
        -- textureCache:addImage(imgFullPath)
    else
    end
    sp.imgFullPath = imgFullPath

    -- print("==file==fileErr==",file,fileErr)
    local fileexists = fs.exists(imgFullPath)
    if fileexists then

        if not isCircle then
            -- if headCache[uid] ~= true then
            --     local x = file:seek("end")
            --     if x > 0 then
            --     else
            --         imgFullPath = DefaultHead_filePath
            --     end
            --     headCache[uid] = true
            -- end
            -- tu_Xiang_Img = imgFullPath
            -- sp:loadTexture(imgFullPath)
            -- sp:setContentSize(cc.size(size,size))
            -- sp:setTouchEnabled(true)

            -- sp:addTouchEventListener(
            --     function(sender,event)
            --         --触摸结束
            --         if event == TOUCH_EVENT_ENDED then
            --             self:showPlayerInfoForGetHead(url,uid,sex,nick)
            --         end
            --     end
            -- )
            if disableTouch == nil then
                disableTouch = true
            end
            self:setCirleHead(sp, imgFullPath, size, uid, sex, url, nick, disableTouch, 1, ip, addres)
        else
            -- self:setCirleHead(sp,imgFullPath,size)
            self:setCirleHead(sp, imgFullPath, size, uid, sex, url, nick, disableTouch, nil, ip, addres)
        end

    else
        local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            -- print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                -- print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                -- print(code)
                return
            end

            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            -- print(response)
            
            --保存下载数据到本地文件，如果不成功，重试10次。
            local times = 1
            -- print("savedata:"..filename)
            -- if not file then
                dump(filename)
                local fi = request:saveResponseData(filename)
                while (not fi) and times < 10 do
                    times = times + 1
                end
            -- end
            -- while (not request:saveResponseData(filename)) and times < 10 do
            --     times = times + 1
            -- end
            local isOvertime = (times == 10) --是否超时

            if sp.imgFullPath ~= filename then
                return
            end

            if isOvertime then  --超时，放弃下载，使用默认头像
                self:setDefaultHead(sp,uid,sex,size,isCircle,nick)
            else
            -- cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)
                if not isCircle and tolua.isnull(sp) == false then

                    sp:loadTexture(imgFullPath)
                    sp:setContentSize(cc.size(size,size))
                    sp:setTouchEnabled(true)

                    -- dump(sp,"sp_getUserHead——1")
                    -- dump(sp.name,"getUserHeadgetUserHeadgetUserHead——1")
                    -- dump(nick,"getUserHeadgetUserH____nick____eadgetUserHead——1")

                    sp:addTouchEventListener(

                        function(sender,event)

                            --触摸结束
                            if event == TOUCH_EVENT_ENDED then
                                self:showPlayerInfoForGetHead(url,uid,sex,nick)
                            end

                        end

                    )

                else
                    -- self:setCirleHead(sp,imgFullPath,size)
                    self:setCirleHead(sp, imgFullPath, size, uid, sex, url, nick, disableTouch)
                end
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

function GameCommon:setDefaultPlayerHead(head,user_info,size)
    isCircle = isCircle or false
    local userid = math.abs(user_info["uid"])
    if user_info["sex"] == 0 then
        user_info["sex"] = user_info["sex"] + 1
    end
    local strIco = DefaultHead_filePath
    -- if user_info["sex"] == 1 or user_info["sex"] == "1" then--男
    --     local index = math.mod(userid,4) + 1
    --     print("setDefaultPlayerHead",tostring(sex),tostring(index))
    --     strIco = "hall/heads/boy-"..tostring(index)..".png"
    -- elseif user_info["sex"] == 2 or user_info["sex"] == "2" then--女
    --     local index = math.mod(userid,7) + 1
    --     print("setDefaultPlayerHead",tostring(sex),tostring(index))
    --     strIco = "hall/heads/girl-"..tostring(index)..".png"
    -- end
    -- head:setTexture(strIco)
    user_info["icon_url"] = strIco
    -- print("setDefaultPlayerHead",tostring(user_info["sex"]),tostring(user_info["icon_url"]))
    self:setHead(head,user_info,size)
end

function GameCommon:setHead(head,user_info,size,touchabled)

    if head == nil then
        return
    end

    head:setTexture("")
    
    if head:getChildByName("head_img") then
        head:getChildByName("head_img"):removeSelf()
    end
    if head:getChildByName("head_touch") then
        head:getChildByName("head_touch"):removeSelf()
    end
    -- if head:getChildByName("head_vip") then
    --     head:getChildByName("head_vip"):removeSelf()
    -- end

    local show_info = touchabled or 1
    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0)

    local stencil = cc.Node:create()
    clipnode:setStencil(stencil)
    local spStnecil = display.newSprite(DefaultHead_filePath)
    spStnecil:setScale(size/spStnecil:getContentSize().width)
    stencil:addChild(spStnecil)
    local fileexists = fs.exists(user_info["icon_url"])
    if fileexists then
        local content = display.newSprite(user_info["icon_url"])
        content:setScaleX(size/content:getContentSize().width)
        content:setScaleY(size/content:getContentSize().height)
        clipnode:addChild(content)
    end

    clipnode:setPosition(clipnode:getContentSize().width/2,clipnode:getContentSize().height/2)
    head:addChild(clipnode)
    head:setScale(1)
    clipnode:setName("head_img")

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))

    local spHeadMask = display.newSprite(HeadFrame_filePath)
    spHeadMask:setAnchorPoint(cc.p(0.5,0.5))
    local s = size/(spHeadMask:getContentSize().width-20)
    spHeadMask:setScale(s)
    
    spHeadMask:setPosition(spHeadMask:getContentSize().width/2, spHeadMask:getContentSize().height/2)
  
    layerTouch:addChild(spHeadMask)
    -- layerTouch:ssize(spHeadMask:getWidth(),spHeadMask:getHeight())

    if show_info == 1 then
        layerTouch:setTouchEnabled(true)
        layerTouch:addTouchEventListener(function(sender,event)
                if event == 2  then
                    print("head touch")
                    self:showPlayerInfo(user_info)
                end
            end)
    end
    layerTouch:setContentSize(spHeadMask:getContentSize())
    --layerTouch:setPosition(head:getPositionX(), head:getPositionY())
    clipnode:setName("head_touch")
    head:addChild(layerTouch)
    head:setTexture("")

end

function GameCommon:setPlayerHead(user_info,sp,size)

    local file = nil
    local fileErr = nil
    local spHead = nil
    --链接空，载入默认头像
    sp:retain();

    local strHead = self:getUrlPicture(user_info["icon_url"])
    if strHead == nil or strHead == "" then
        self:setDefaultPlayerHead(sp,user_info,size)
        return
    end

    local path = device.writablePath
    if device.platform == "windows" then
        path = device.writablePath.."cache\\" --获取本地存储目录
        if not fs.exists(path) then
            fs.mkdir(path) --目录不存在，创建此目录
        end
    end
    local imgFullPath = path..strHead

    --先在本地获取
    -- local imgFullPath = device.writablePath..path..strHead
    --and headCache[user_info["uid"]]

    sp.imgFullPath = imgFullPath

    local fileexists = fs.exists(imgFullPath)
    if fileexists then
        user_info["icon_url"] = imgFullPath
        self:setHead(sp,user_info,size)
    else

        local function onRequestFinished(event,filename)
            -- body
            local ok = (event.name == "completed")
            -- print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                -- print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                -- print(code)
                return
            end

            if sp.imgFullPath ~= filename then
                return
            end

            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            -- print(response)

            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            -- print("savedata:"..filename)
            while (not request:saveResponseData(filename)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时

            local fileexists = fs.exists(imgFullPath)
            if not fileexists then
                imgFullPath = DefaultHead_filePath
            end

            cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)
            --sp:performWithDelay(function()
            user_info["icon_url"] = imgFullPath
            self:setHead(sp,user_info,size)
            --end, 0.1)
        end

        local request = network.createHTTPRequest(function (event)
            -- body
            if  event.name == "completed" then
                dump("headImgonRequestFinished")
                onRequestFinished(event,imgFullPath)
            end
        end,user_info["icon_url"],"GET")
        request:start()
    end
end

--设置头像
function GameCommon:setUserHead(head_info)
    -- body
    -- local spHead = display.newSprite(file)

    if head_info["sp"] == nil then
        return
    end
    if head_info["sp"]:getChildByName("head_img") then
        head_info["sp"]:getChildByName("head_img"):removeSelf()
    end
    if head_info["sp"]:getChildByName("head_touch") then
        head_info["sp"]:getChildByName("head_touch"):removeSelf()
    end
    if head_info["sp"]:getChildByName("head_vip") then
        head_info["sp"]:getChildByName("head_vip"):removeSelf()
    end
    local show_info = head_info["touchable"] or 0
    local size = head_info["size"] or 80
    local clipnode = nil
    if head_info["use_sharp"] and head_info["use_sharp"] == 1 then
        clipnode = cc.ClippingNode:create()
        clipnode:setInverted(false)
        clipnode:setAlphaThreshold(0)

        local stencil = cc.Node:create()
        clipnode:setStencil(stencil)
        local spStnecil = display.newSprite(DefaultHead_filePath)
        spStnecil:setScale(size/spStnecil:getContentSize().width)
        stencil:addChild(spStnecil)

        local content = display.newSprite(head_info["url"])
        content:setScaleX(size/content:getContentSize().width)
        content:setScaleY(size/content:getContentSize().height)
        clipnode:addChild(content)

        clipnode:setPosition(clipnode:getContentSize().width/2,clipnode:getContentSize().height/2)
    else
        clipnode = display.newSprite(head_info["url"])
        clipnode:setScaleX(size/clipnode:getContentSize().width)
        clipnode:setScaleY(size/clipnode:getContentSize().height)
    end
    clipnode:setName("head_img")
    head_info["sp"]:addChild(clipnode)

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))
    layerTouch:setName("head_touch")

    local spHeadMask = display.newSprite(HeadFrame_filePath)
    local s = size/(spHeadMask:getContentSize().width-25)
    spHeadMask:setScale(s)
    spHeadMask:setAnchorPoint(cc.p(0.5,0.5))
    spHeadMask:setPosition(spHeadMask:getContentSize().width/2, spHeadMask:getContentSize().height/2)
    layerTouch:addChild(spHeadMask)

    if show_info == 1 then
        layerTouch:setTouchEnabled(true)
        layerTouch:addTouchEventListener(function(sender,event)
                if event == 2  then
                    print("head touch")
                    self:showPlayerInfo(head_info["uid"])
                    --require("hall.GameTips"):showTips("玩家详情")
                end
            end)
    end
    layerTouch:setContentSize(spHeadMask:getContentSize())
    layerTouch:setPosition(clipnode:getPosition())
    head_info["sp"]:addChild(layerTouch)

    -- if head_info["vip"] then
    --     local sp_vip = display.newSprite("hall/common/main_vip_tb01.png")
    --     sp_vip:setPosition(-size/2+10,-size/2+10)
    --     head_info["sp"]:addChild(sp_vip)
    --     sp_vip:setName("head_vip")
    -- end

    head_info["sp"]:setTexture("")
end

--玩家详情
function GameCommon:showPlayerInfo(user_info)

    dump(user_info, "-----showPlayerInfo-----")

    if user_info == nil then
        return
    end

    if user_info.uid == nil then
        return
    end

    if user_info.uid == "" then
        return
    end

    if nick == nil then
        nick = uid
    end

    local userInfo = {}
    userInfo["isShowInGame"] = bm.isInGame
    userInfo["nickName"] = user_info.nickName or user_info.nick
    userInfo["uid"] = user_info.uid
    --userInfo["location_arr"] = {}
    --userInfo["ip"] = ""

    require("hall.view.userInfoView.userInfoView"):showView(user_info.icon_url, userInfo)

end

--玩家详情(新)
function GameCommon:showPlayerInfoForGetHead(icon_url, uid, sex_num, nick, ip, addres) 
    local scene = SCENENOW.scene
    local EmojiArmatureView = scene:getChildByName("EmojiArmatureView")
    -- local EmojiArmatureView = ViewBase:seekChild(scene, "EmojiArmatureView")
    if EmojiArmatureView then
        EmojiArmatureView:showScene(icon_url, uid, sex_num, nick, ip, addres)
        return
    end
    print("++++++++++++++++++++++++++++++++++++", debug.traceback())
    dump(icon_url, "-----玩家详情(新)-----")
    dump(uid, "-----玩家详情(新)-----")
    dump(sex_num, "-----玩家详情(新)-----")
    dump(nick, "----------- 玩家详情(新) ----------")
    dump(addres, "----------- 玩家详情(新) ----------")

    if uid == nil then
        return
    end

    if uid == "" then
        return
    end

--[[    if nick == nil then
        nick = uid
    end]]

    local userInfo = {}
    userInfo["isShowInGame"] = bm.isInGame
    userInfo["nickName"] = nick
    userInfo["uid"] = uid
    --userInfo["location_arr"] = {}
    --userInfo["ip"] = ""

    require("hall.view.userInfoView.userInfoView"):showView(icon_url, userInfo)

end


--格式化金币
function GameCommon:formatGold(gold,txtStyle)

    if not gold then
        printError("error formatGold gold is null")
    end

    gold = tonumber(gold)

    if( math.abs(gold) < 10000) then
        return gold
    else
        local w = math.modf(gold/10000)
        local lest = math.modf(gold%10000/1000)

        return w.."."..lest.."万"
    end

end


--格式化系统字体金币
function GameCommon:formatGoldSys(gold)

    if not gold then
        printError("error formatGold gold is null")
    end

    gold = tonumber(gold)

    if( gold < 10000) then
        return gold
    else
        local goldStr = ""

        local finalChipTxt = tostring(value/10000)
        if string.len(finalChipTxt) <= 4 then
            goldStr = string.format("%.1f", finalChipTxt) .. "万"
        else
            local endlength = string.find(finalChipTxt,"%.")
            goldStr = string.sub(finalChipTxt,1,endlength-1) .. "万"
        end

        return goldStr
    end

end

--格式化昵称
function GameCommon:formatNickToLaction(str,size)

    if str == nil then
        return ""
    end

    local width = 0
    local size = size or 3
    local char_count = 0
    local pos = 1
    local lenInByte = #str

    if lenInByte < 10 then
        return str
    else
        local nick = ""
        for i=1,lenInByte do
            local curByte = string.byte(str, pos)

            if curByte == nil then
                return str
            end
            
            local byteCount = 1;
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<=223 then
                byteCount = 2
            elseif curByte>=224 and curByte<=239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
             
            local char = string.sub(str, pos, pos+byteCount-1)
            nick = nick .. char
            char_count = char_count + 1
            pos = pos + byteCount
            if char_count > size then
                return nick .. ".."
            end
        end
    end

end

--格式化昵称
function GameCommon:formatNick(str,size)

    if str == nil then
        return ""
    end

    -- body
    local width = 0
    local size = size or 4
    local char_count = 0
    local pos = 1
    local lenInByte = #str

    if lenInByte < 10 then
        return str
    else
        local nick = ""
        for i=1,lenInByte do
            local curByte = string.byte(str, pos)

            if curByte == nil then
                return str
            end

            local byteCount = 1;
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<=223 then
                byteCount = 2
            elseif curByte>=224 and curByte<=239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
             
            local char = string.sub(str, pos, pos + byteCount - 1)
            nick = nick .. char
            char_count = char_count + 1
            pos = pos + byteCount
            if char_count > size then
                return nick .. "..."
            end

        end
    end

end

--格式化昵称
function GameCommon:formatNick_1(str,size)

    if str == nil then
        return ""
    end

    -- body
    local width = 0
    local size = size or 4
    local char_count = 0
    local pos = 1
    local lenInByte = #str
    local byte = string.byte(str, pos)
    
    if byte >= 240 then
        return str
    end

    local nick = ""
    for i=1,lenInByte do
        local curByte = string.byte(str, pos)

        if curByte == nil then
            return str
        end

        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<=223 then
            byteCount = 2
        elseif curByte>=224 and curByte<=239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
         
        local char = string.sub(str, pos, pos + byteCount - 1)
        nick = nick .. char
        char_count = char_count + 1
        pos = pos + byteCount
        if char_count > size then
            if str == char_count then
                return nick
            else
                return nick .. "..."
            end
        end

    end

end

--自动裁剪label内容
function GameCommon:formatLabelStr(str, lb, maxWidth)
    lb:setString("a")
    local widthByByte = lb:getContentSize().width
    dump(maxWidth, "maxWidth")
    dump(widthByByte, "widthByByte")

    local totalBytes = maxWidth / widthByByte - 3

    if totalBytes <= 0 then
        --todo
        lb:setString("...")
        return
    end

    local length = string.len(str)

    local tBytes = 0
    local dealStr = ""
    local isOver = false
    for i=1,length do
        local b = string.byte(str, i)

        if b > 255 then
            --todo
            if tBytes + 2 > totalBytes then
                --todo
                if i == 1 then
                    --todo
                    isOver = true
                    break
                else
                    dealStr = string.sub(str, 1, i - 1)
                    isOver = true
                    break
                end
            elseif tBytes + 2 == totalBytes then
                dealStr = string.sub(str, 1, i)
                if i ~= length then
                    --todo
                    isOver = true
                end
                break
            else
                tBytes = tBytes + 2
            end
        else
            if tBytes + 1 > totalBytes then
                --todo
                if i == 1 then
                    --todo
                    isOver = true
                    break
                else
                    dealStr = string.sub(str, 1, i - 1)
                    isOver = true
                    break
                end
            elseif tBytes + 1 == totalBytes then
                dealStr = string.sub(str, 1, i)
                if i ~= length then
                    --todo
                    isOver = true
                end
                break
            else
                tBytes = tBytes + 1
            end
        end
    end

    if not isOver then
        --todo
        lb:setString(str)
    else
        lb:setString(dealStr .. "...")
    end

    
end

--获取svid
function GameCommon:getSvid(tid)

    local id = bit.brshift(tid,16)
    return id
    
end

--播放游戏音效
function GameCommon:playEffectSound(filename,flag)
    self:playEffect(filename,flag or false)
end

--点击音效
function GameCommon:onClickSound()
    local BTN_CLICK_VOICE = "hall/scene/res/common/music/Audio_Button_Click.mp3"
    self:play2d(BTN_CLICK_VOICE)
end

function GameCommon:play2d(sound_path,a)
    if device.platform == "ios" then
        if isIosUseAppPlayEffect then
            local args = {}
            args["url"] = cc.FileUtils:getInstance():getWritablePath() ..  sound_path
            cct.getDateForApp("playEffect", args, "V")
            return
        end
    end
    ccexp.AudioEngine:play2d(sound_path, a or false, audio.getSoundsVolume())
    -- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
end

function GameCommon:playEffect(sound_path,a)
    if sound_path == nil then
        return
    end
    a = a or false
    if device.platform == "ios" then

        if isIosUseAppPlayEffect then
            
            local args = {}
            args["url"] = cc.FileUtils:getInstance():getWritablePath() ..  sound_path
            cct.getDateForApp("playEffect", args, "V")

        else
            cc.SimpleAudioEngine:getInstance():playEffect(sound_path, a)

        end
        
    else
        cc.SimpleAudioEngine:getInstance():playEffect(sound_path, a)

    end
end

--播放游戏音效
function GameCommon:playEffectMusic(filename,flag)

    if MUSIC_ON == true then
        local bRepeat = true
        if flag then
            bRepeat = flag
        else
            bRepeat = false
        end
        -- cc.SimpleAudioEngine:getInstance():playMusic(filename,bRepeat)
        audio.playMusic(filename,bRepeat)
        
    end

end

--显示数字
function GameCommon:showNums(num,color,isBack)
    -- body
    -- display.addSpriteFrames("hall/nums.plist", "hall/nums.png")
    isBack = isBack or false
    -- print("showNums:"..tostring(num))
    local spLayer = cc.Layer:create()
    num = num or 0
    local str = tostring(num)
    local len = string.len(num)
    local x = 0
    local y = 0
    local width = 0
    local height = 0
    if len < 1 then
        return nil
    end
    if isBack then
        if len == 1 then
            local left = display.newSprite("hall/no/num_bg_left.png"):addTo(spLayer)
            x = x + left:getContentSize().width/2
            width = width + left:getContentSize().width
            height = left:getContentSize().height
            left:setPosition(cc.p(x,y))
            x = x + left:getContentSize().width/2
            local right = display.newSprite("hall/no/num_bg_right.png"):addTo(spLayer)
            x = x + right:getContentSize().width/2
            width = width + right:getContentSize().width
            right:setPosition(cc.p(x,y))
            x = x + right:getContentSize().width/2
            local txt = self:getNum(str,color)
            txt:setScale(0.8)
            right:addChild(txt)
            txt:setPosition(cc.p(right:getContentSize().width/2,right:getContentSize().height/2))
            spLayer:setContentSize(cc.size(width,height))
        else
            for i=1,len do
                -- print(string.byte(str,i))
                local ch = string.char(string.byte(str,i))
                    if i == 1 then
                        local left = display.newSprite("hall/no/num_bg_left.png"):addTo(spLayer)
                        x = x + left:getContentSize().width/2
                        width = width + left:getContentSize().width
                        height = left:getContentSize().height
                        left:setPosition(cc.p(x,y))
                        x = x + left:getContentSize().width/2
                        local txt = self:getNum(ch,color)
                        txt:setScale(0.8)
                        left:addChild(txt)
                        txt:setPosition(cc.p(left:getContentSize().width/2,left:getContentSize().height/2))
                        spLayer:setContentSize(cc.size(width,height))
                    elseif i == len then
                        local right = display.newSprite("hall/no/num_bg_right.png"):addTo(spLayer)
                        x = x + right:getContentSize().width/2
                        width = width + right:getContentSize().width
                        right:setPosition(cc.p(x,y))
                        x = x + right:getContentSize().width/2
                        local txt = self:getNum(ch,color)
                        txt:setScale(0.8)
                        right:addChild(txt)
                        txt:setPosition(cc.p(right:getContentSize().width/2,right:getContentSize().height/2))
                        spLayer:setContentSize(cc.size(width,height))
                    else
                        local center = display.newSprite("hall/no/num_bg_center.png"):addTo(spLayer)
                        x = x + center:getContentSize().width/2
                        width = width + center:getContentSize().width
                        center:setPosition(cc.p(x,y))
                        x = x + center:getContentSize().width/2
                        local txt = self:getNum(ch,color)
                        txt:setScale(0.8)
                        center:addChild(txt)
                        txt:setPosition(cc.p(center:getContentSize().width/2,center:getContentSize().height/2))
                        spLayer:setContentSize(cc.size(width,height))
                    end
            end
        end
    else
        for i=1,len do
            -- print(string.byte(str,i))
            local ch = string.char(string.byte(str,i))
            local txt = self:getNum(ch,color)
            spLayer:addChild(txt)
            -- x = x - txt:getContentSize().width/2
            -- print("showNums x:"..tostring(x))
            txt:setPosition(cc.p(x,y))
            x = x + txt:getContentSize().width
            width = width + txt:getContentSize().width
            spLayer:setContentSize(cc.size(width,height))
        end
    end
    -- spLayer:setCascadeColorEnabled(true)
    spLayer:setCascadeOpacityEnabled(true)
    return spLayer
end

function GameCommon:getNum(str,color)
    -- body
    -- local spLayer = cc.Layer:create()
    color = color or cc.c3b(125,125,125)
    -- print("getNum:"..str)
    local spBack = display.newSprite("hall/no/mask"..str..".png")
    spBack:setColor(color)
    local spNum = display.newSprite("hall/no/"..str..".png")
    spBack:addChild(spNum)
    spNum:setPosition(cc.p(spBack:getContentSize().width/2,spBack:getContentSize().height/2))
    spBack:setCascadeOpacityEnabled(true)
    return spBack
end

--显示提示框
function GameCommon:showAlert(flag, msg, maxBodyWidth)

    if flag == false then
        SCENENOW["scene"]:removeChildByName("layer_tips")
        return
    end
    
end


--兑换筹码界面
function GameCommon:showChange(flag,sef)

end

--请求兑换筹码
function GameCommon:changeChip(value)

end

--请求历史记录
function GameCommon:getHistory()

end

--显示历史记录
function GameCommon:showHistory(flag)
    
end

--历史项目
function GameCommon:addHistoryItem(gameNo,playerlist,scale)

end

function GameCommon:gRecharge()

end

function GameCommon:LabelToRich(oriLabel,allStrs,lengthLimit)

    if  oriLabel == nil then
        return
    end

    lengthLimit = lengthLimit or 100

    local tiliRichText = ccui.RichText:create()

    oriLabel:setVisible(false)
    oriLabel:getParent():addChild(tiliRichText)
    -- oriLabel:getFontS()

    tiliRichText:setAnchorPoint(oriLabel:getAnchorPoint())
    tiliRichText:setPosition(oriLabel:getPosition())

    local fontSize =  oriLabel:getFontSize() or  24
    local fontFace =  oriLabel:getFontName()
    
    local allStrLens = 0

    for _,strTable in pairs(allStrs) do

        local re

        if strTable["type"] == "image" then
            local img = strTable["content"] or ""
            re = ccui.RichElementImage:create(1, cc.c3b(255,255,255), 255, img)
        else  --if strTable["type"] == "string" then
            local fontColor = strTable["color"] or cc.c3b(255,255,255)
            local str = strTable["content"] or ""
            re = ccui.RichElementText:create(1,fontColor,255,str,fontFace, fontSize)  
            allStrLens = allStrLens + self:getTextLength(str)
        end

        if allStrLens > lengthLimit then
            local fontColor = strTable["color"] or cc.c3b(255,255,255)
            local str = "..."
            local re = ccui.RichElementText:create(1,fontColor,255,str,fontFace, fontSize)  
            tiliRichText:pushBackElement(re)
            break
        end

        tiliRichText:pushBackElement(re)
    end

    return tiliRichText
end


function GameCommon:getTextLength(str)

    if str == nil then
        return 0
    end

    -- local width = 0
    -- local size = size or 3
    -- local char_count = 0
    -- local pos = 1

    -- local lenInByte = #str/3  --Lua里汉字算3个

    -- dump(lenInByte,"lenInByte")

    -- for i=1,lenInByte do

    --     local curByte = string.byte(str, pos) or 0
        
    --     local byteCount = 1;
    --     if curByte>0 and curByte<=127 then
    --         byteCount = 1
    --     elseif curByte>=192 and curByte<223 then
    --         byteCount = 2
    --     elseif curByte>=224 and curByte<239 then
    --         byteCount = 3
    --     elseif curByte>=240 and curByte<=247 then
    --         byteCount = 4
    --     end
         
    --     local char = string.sub(str, pos, pos+byteCount-1)
    --     char_count = char_count + 1
    --     pos = pos + byteCount
    -- end

    local count = 0  
    for uchar in string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do   
      if #uchar ~= 1 then  
        count = count + 1    --中文字符
      else  
        count = count + 0.5     --英文字符
      end  
    end   

    return count

end

dump(GameCommon:getTextLength("明牌抢庄"),"testgetTextLength")

return GameCommon
