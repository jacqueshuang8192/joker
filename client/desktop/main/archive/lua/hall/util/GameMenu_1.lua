--
-- Author: 张鸿鹏
-- Date: 2017-06-30 14:09:27
local GameMenu = class("GameMenu")
local flagString = "——>复制这条信息后，打开游戏"
local clubFlagString = "——>复制这条信息打开游戏后自动申请加入联盟"

local roomFlag = "房号（@"
local clubIdFlag = "联盟ID（@"

function GameMenu:addMenu(menu_ly, device_info_plane, gameName, battery, wifi, time)
    self:playBackgroundMusic(gameName)
    self:getDeviceInfo(device_info_plane,battery,wifi,time)
end

function GameMenu:getDeviceInfo(device_info_plane, battery, wifi, time)
    
    device_info_plane:stopAllActions()
    local battery = battery or device_info_plane:getChildByName("battery_level")
    local wifi = wifi or device_info_plane:getChildByName("wifi_level")
    local time = time or device_info_plane:getChildByName("time")

    local updateTime = 5

    local updateInfo = cc.CallFunc:create(
    	function()
           --dump("刷新设备信息")
           self:getDeviceElectricity(battery)
           self:getSignalQuality(wifi)
           self:getDeviceTime(time)
    	end)

	local seqAc = cc.Sequence:create(updateInfo,cc.DelayTime:create(updateTime))
    device_info_plane:runAction(cc.RepeatForever:create(seqAc))
end


--获取设备电量
function GameMenu:getDeviceElectricity(battery_control)
    if battery_control == nil then
        return 
    end

    local betteryPercent = 100
    if device.platform == "ios" and isShowElectricity then
        betteryPercent = cct.getDataForApp("getBetteryPercent", {}, "I")

    elseif device.platform == "android" and isShowElectricity then 

        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        -- 获取应用版本
        local appVersion
        local ok,ret  = luaj.callStaticMethod(className,"getAppVersion",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            appVersion = ret
        end

        dump(appVersion, "-----appVersion-----")

        --获取应用电量
        ok,ret  = luaj.callStaticMethod(className,"getPhonePower",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            betteryPercent = tonumber(ret)
        end
        
    end

    battery_control:setPercent(betteryPercent) 

    return betteryPercent

end

--检测网络质量
function GameMenu:getSignalQuality(wifi_control)
    
    local wifi_picture = "hall/util/wifi_0"
    local wifi_level_num = 4
    local PINT_TIME = PINT_TIME or 300
    local ping = tonumber(PINT_TIME)

	    if ping<=120 then
	        wifi_level_num = 4
	    elseif ping>120 and ping<=200 then
	        wifi_level_num = 3
	    elseif ping>200 and ping<=300 then
	        wifi_level_num = 2
	    elseif ping>300 and ping<=500 then
	        wifi_level_num = 1
	    elseif ping>500 then
	        wifi_level_num = 0
	    end   

    wifi_control:setTexture(wifi_picture..wifi_level_num..".png")

    return  wifi_level_num

end

function GameMenu:getDeviceTime(time_control)

    local nowtime = os.date("%H:%M")
    time_control:setString(nowtime)

    return nowtime

end

function GameMenu:playBackgroundMusic(gameName, musicType)
     
    local MusicNum = 6
    local index = math.random(5, MusicNum)
    local bgmPath = "hall/scene/res/common/music/gameBGM_"..index..".mp3"

    audio.playMusic(bgmPath,true)

    return  bgmPath
end


function GameMenu:getCopyRoomIdButton(roomId,...)  --roomId,gameName,gameCofig
    local roomId = tostring(roomId)
    local gameName,gameCofig = ...
    
    gameName = gameName or ""

    local shareInfo = "我在".. appName .. "上开了一个"..gameName.."的房！房号是" .. roomId .. "!快来玩吧！（复制这段文字打开APP可自动加入房间！）"
    
    local copyButton = ccui.Button:create()
    copyButton:loadTextures(AgentHandlePic_filePath, nil, nil)
    
    local copyText = ccui.Text:create():addTo(copyButton)
    copyText:setString("复制房号"):setFontSize(18):setColor(cc.c3b(125, 125, 125))
    copyText:setPosition(cc.p(copyButton:getContentSize().width/2, copyButton:getContentSize().height/2))

    copyButton:addTouchEventListener(function(sender,event)

            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.85)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1)
                require(GameSetting_filePath):copyToClipboard(shareInfo) 
            end
    end)

    return copyButton   --此按钮还没有父节点
end

--为按钮注册复制房间号功能
function GameMenu:registCopyRoomIdFunc(button, roomId, ...)  --roomId,gameName,gameCofig

    local roomId = tostring(roomId)
    local gameName,gameCofig = ...
    gameName = gameName or require("hall.familyCircle.GetGameName"):getName(USER_INFO.GroupLevel)
    gameCofig = gameCofig or ""

    -- local shareInfo = "我在".. appName .. "上开了一个"..gameName.."的房！房号是" .. roomId .. "!快来玩吧！（复制此消息打开"..appName.."即可快速加入房间！）"
    local shareInfo = "【" .. gameName .. "（" .. gameCofig .. "）】" 
    .. roomFlag .. roomId .. "@）" .. flagString

    if  tolua.isnull(button) == false then
        button:onClick(function( event )
            require(GameSetting_filePath):copyToClipboard(shareInfo) 
        end)
    else
        local data = {type = 1, title = "提示", content = "控件不存在!"}
        require(CommonTips_filePath):showTips(data)
    end

end

--为按钮注册复制联盟号号功能
function GameMenu:registCopyClubIdFunc(button, clubId, ...)  --clubId,gameName,gameCofig

    local clubId = tostring(clubId)
    local clubName = ...
    
    clubName = clubName or ""

    -- local shareInfo = "我在".. appName .. "上开了一个"..gameName.."的房！房号是" .. clubId .. "!快来玩吧！（复制此消息打开"..appName.."即可快速加入房间！）"
    local shareInfo = "【" .. clubName .. "】" 
    .. clubIdFlag .. clubId .. "@）" .. clubFlagString

    if  tolua.isnull(button) == false then
        button:addTouchEventListener(function(sender,event)

            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.85)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1)
                require(GameSetting_filePath):copyToClipboard(shareInfo) 
            end

        end)
        
    else
        local data = {type = 1, title = "提示", content = "控件不存在!"}
        require(CommonTips_filePath):showTips(data)
    end

end

function GameMenu:checkEnterRoomClipText()  --roomId,gameName,gameCofig

    if quickEnterRoom ~= true and bm.IsInGame == true then
        return
    end

    local roomId = self:getRoomIdFromClipText()
    if roomId then
        local  level = 0   --level为0表示不需要level
        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], roomId, "", false, level, false)
    end

end

function GameMenu:checkEnterClubClipText()  --roomId,gameName,gameCofig

    if bm.IsInGame == true then
        return
    end

    local clubId = self:getClubIdFromClipText()
    if clubId then
        require("hall.view.clubView.clubView"):requestJoinOrCreateClub(2, clubId)
    end

end

function GameMenu:getClubIdFromClipText() 
    
    local clipText = self:getClipTextFromApp() --= "我在".. appName .. "上开了一个牛牛的房！房号是049459!快来玩吧！（复制这段文字到剪贴板打开APP可自动加入房间！）"
    
    if clipText and string.find(clipText, clubFlagString) then

        local strBegin,strEnd = string.find(clipText, clubIdFlag)

        local clubId = string.sub(clipText,strEnd+1,strEnd + 6)

        print(clubId, "剪切板联盟号")

        if tonumber(clubId) then
            return clubId
        end

    end

end


function GameMenu:getRoomIdFromClipText() 
    
    local clipText = self:getClipTextFromApp() --= "我在".. appName .. "上开了一个牛牛的房！房号是049459!快来玩吧！（复制这段文字到剪贴板打开APP可自动加入房间！）"
    
    if clipText and string.find(clipText,flagString) then

        local strBegin,strEnd = string.find(clipText,roomFlag)

        local roomId = string.sub(clipText,strEnd+1,strEnd + 6)

        print(roomId,"剪切板房间号")

        if tonumber(roomId) then
            return roomId
        end

    end

end


function GameMenu:getClipTextFromApp() 

    local clipText 

    if  device.platform == "android" then
        
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        local ok,ret  = luaj.callStaticMethod(className, "getClipText", args, sigs)
        if not ok then
            print("luaj error:", ret)
        else
            clipText = ret
        end

        print(clipText,"clipText")
        
    elseif  device.platform == "ios" then
        clipText = cct.getDataForApp("getMsgFromClipboard", {}, "string")
        -- require("hall.GameTips"):showTips("提示", "", 3, tostring(clipText) .. "查看剪贴板内容!,ret为"..string.len(ret))
    end

    return clipText
end


-- local NewViewBaseLayer = require("hall.NewViewBaseLayer")
-- local ConfigPanel = class("ConfigPanel", NewViewBaseLayer)
-- function ConfigPanel:ctor()
--     local csbPath = "hall/res/csb/commonGameAPI/configPanel.csb"
--     -- ConfigPanel.super.ctor(self, csbPath, nil, false)
--     ConfigPanel.super.ctor(self, csbPath, nil, nil)
--     GameUtils.setNodeNameBindObj(self._csbNode)

--     local SCREEN_WIDTH = self._csbNode:getWidth()
--     self._csbNode.root:setPositionX(SCREEN_WIDTH/2)

--     -- display.doLayout(self._csbNode.root)
--     self.oneConfigsTemplate:hide()
--     self.twoConfigsTemplate:hide()
--     self:enableMask(true)
--     self:setClickMaskClose()
-- end

function GameMenu:showConfigPanel(gameConfigTable) 
    -- DESIGN_SCREEN_HEIGHT = DESIGN_SCREEN_HEIGHT or 1080
    local scenenow = SCENENOW["scene"]
    --设计尺寸1920，1080
    local scene = cc.CSLoader:createNode("hall/res/csb/commonGameAPI/configPanel.csb")
    :addTo(scenenow,999999)
    :setName("ConfigPanel")
    local size = scenenow:getContentSize()
    scene:setAnchorPoint(0.5, 0.5)
    scene:setPosition(size.width / 2, size.height / 2)

    GameUtils.setNodeNameBindObj(scene)
    viewMgr:setSceneScale( scene.root )
    local root = scene.root
    local config_lv = root:getChildByName("config_lv")
    config_lv:setScrollBarEnabled(false)
    local oneConfigsTemplate = root:getChildByName("oneConfigsTemplate"):hide()
    local twoConfigsTemplate = root:getChildByName("twoConfigsTemplate"):hide()
    --[[gameConfigTable形式如: 
        { 
          {["玩法"] = "明牌抢庄", ["底分"] = "1/2"},
          {["翻倍规则"] = "XXXXXXX"},  
        }

        最多只支持一行两个显示项
    ]]

    for _,singleGameConfigTable in pairs(gameConfigTable or {}) do
        local configTable_size = table.nums(singleGameConfigTable)
        local t = 0
        local configBox = nil
        for configName,configDetail in pairs(singleGameConfigTable) do
            t = t + 1
            if configTable_size == 1 then
                configBox = oneConfigsTemplate:clone()
                configBox:show()
                local config_txt = configBox:getChildByName("config_txt")
                local config_title = configBox:getChildByName("config_title")
                config_title:setString(configName)
                config_txt:setString(configDetail)

            elseif configTable_size == 2 then
                if configBox == nil then
                    configBox = twoConfigsTemplate:clone()
                    configBox:show()
                end
                local item = configBox:getChildByName("item_" .. t)
                local config_txt = item:getChildByName("config_txt")
                local config_title = item:getChildByName("config_title")
                config_title:setString(configName)
                config_txt:setString(configDetail)
            end
        end
        if configBox then
            config_lv:pushBackCustomItem(configBox)
        end
    end
    scene.mask:hide()
    -- local mask = s:getChildByName("mask")
    -- scene.mask:onClick(function(event)
    --     if tolua.isnull(root) == false then
    --         scene:removeFromParent()
    --     end
    -- end)
    ccui.Helper:doLayout(scene)
    self:setMask(scene)
end

function GameMenu:setMask(scene)
	local director = cc.Director:getInstance()
	local size = director:getWinSize()
    scene.maskLayout = ccui.Layout:create()
    scene.maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    scene.maskLayout:setContentSize(cc.size(size.width, size.height))

    local size = scene:getContentSize()
    scene.maskLayout:setPosition(cc.p(size.width / 2, size.height / 2))
    scene.maskLayout:setBackGroundColorType(1)
    scene.maskLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    scene.maskLayout:setBackGroundColorOpacity(150)
    scene.maskLayout:setTouchEnabled(true)
    scene.maskLayout:setVisible(true)
    scene:addChild(scene.maskLayout, -1000)
    scene.maskLayout:onClick(function(event)
        if tolua.isnull(scene) == false then
            scene:removeFromParent()
        end
    end)
end

return GameMenu


