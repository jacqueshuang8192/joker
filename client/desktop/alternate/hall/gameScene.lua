import(".init")
local gameScene = class("gameScene", function()
    return display.newScene("gameScene")
end)

--加载自定义函数库
require("hall.util.customFunctions")
local phoneBind = require("hall.phoneBind")
local cacheBroadcast = nil
local cacheNotification = nil
local code_hall_version = "1.0.1"

currentPlayMode = 1 --cc.UserDefault:getInstance():getIntegerForKey("currentPlayMode", 1) --当前大厅主界面展示的场景:0是金币场，1是房卡场

local txt_roomCard 
local txt_gold 

local hasGameTypeList = {}

function gameScene:resetGameConfig()
    --记录当前不在游戏
    bm.isInGame = false
    USER_INFO["GroupLevel"] = nil
    STATUS_GAME = false
    USER_INFO["isWatch"] = 1
    USER_INFO["level"] = 0
    g_reloadGame = false
end

function gameScene:ctor(state)
    -- reqMgr:request()onChangeBg
    is_club_scene = false
    if  device.platform == "windows" then
        -- function dump()
        -- end
        -- function print()
        -- end
    else  
        --除了电脑之外，其他设备上都将dump设为空方法
        function dump()
        end
        -- function print()
        -- end
        function printW()
        end
        function dumpW()
        end
    end
    SCENENOW["name"] = "hall.gameScene"
    self:resetGameConfig()
    --设置大厅Socket协议和对应处理方法
    package.loaded[HallProtocol_filePath] = nil
    local PROTOCOL = require(HallProtocol_filePath)
    local HallHandle = require(HallHandle_filePath)
    bm.server:setProtocol(PROTOCOL, true)
    bm.server:setHandle(HallHandle.new(), true)
    print("大厅gameScene")
    self:loadHallForRoomCard()

    --进大厅已经请求了数据 此处取消 
    --self:queryRoomCardCount()

    --通知原生已进入大厅
    cct.getDateForApp("nowInHall", {}, "V")
    require("hall.util.GameMenu"):checkEnterRoomClipText()
    require("hall.util.GameMenu"):checkEnterClubClipText()
    dump(state,"USER_INFO[family_data]")
    if state then
        self:loadClubForRoom()
    end
    if self:checkPhone(USER_INFO.phone) == false then
        if tipsBind == false then
            tipsBind = true
            bindTemporary = true
            if tipsStop == true then
            phoneBind.new():addTo(self)
            end
        end
        if tipsBind == true and bindTemporary ==false then
            phoneBind.new():addTo(self)
        end
    end
    --require(Request_filePath):getIpFormRealmNameLst()
    require(GameData_filePath):getLocation()
    -- require(HallServer_filePath):CLIENT_COMMAND_USER_INFO()  -- 临时注释，服务器未实现此协议
	  -- require(Request_filePath):getInternetIP()
    -- 等待1秒
    --local scheduler = cc.Director:getInstance():getScheduler()
    --local schedulerID = nil
    --schedulerID = scheduler:scheduleScriptFunc(function()
    --    require(HallServer_filePath):CLIENT_COMMAND_USER_INFO()
    --    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
    --end,3,false)
end

function gameScene:loadClubForRoom()

    dump(USER_INFO["family_data"],"USER_INFO[family_data]")
    if USER_INFO.family_data then
        if self.hallMainLayer and self.hallMainLayer.familyMainlayer then
            --dump(data.roleType,"data.roleType--")
            if tolua.isnull(self.hallMainLayer.familyMainlayer) then
                self.hallMainLayer.familyMainlayer =  require("hall.familyCircle.FamilyMainLayer").new(USER_INFO.family_data ,self.hallMainLayer)
                if self.hallMainLayer.familyMainlayer then
                    self.hallMainLayer.familyMainlayer:addTo(self.hallMainLayer)
                end
            else
                self.hallMainLayer.familyMainlayer:setVisible(true)
                self.hallMainLayer.familyMainlayer:FreshData(USER_INFO["family_data"] ,self.hallMainLayer)
            end


        else
            self.hallMainLayer.familyMainlayer =  require("hall.familyCircle.FamilyMainLayer").new(USER_INFO.family_data ,self.hallMainLayer)
            if self.hallMainLayer.familyMainlayer then
                self.hallMainLayer.familyMainlayer:addTo(self.hallMainLayer)
            end
        end

        --self.hallMainLayer.familyMainlayer = require("hall.familyCircle.FamilyMainLayer").new(family_id, self.hallMainLayer, owerId, roleType)
        --if self.hallMainLayer.familyMainlayer then
        --    self.hallMainLayer.familyMainlayer:addTo(self.hallMainLayer)
        --end
    end

   
end

function gameScene:queryRoomCardCount()
    local this = self
    local params = {}
    params["userId"] = USER_INFO["uid"]
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/roomCard/queryRoomCardCount",
        date= params,
        type_="POST",
        requestMsg = "",
        isshowfailTip = false,
        callBack = function(data)
            dump(data, "-----查询房卡数量-----")
            data_netData = json.decode(data["netData"])
            if data_netData.returnCode == "0" then
                local sData = data_netData.data
                if sData  then

                    if sData.cardCount ~= nil then
                        USER_INFO["cardCount"] = sData.cardCount
                    end

                    if sData.gold ~= nil then
                        USER_INFO["gold"] = sData.gold
                    end

                    if sData.repositoryMony ~= nil then
                        USER_INFO["repositoryMony"] = sData.repositoryMony
                    end

                    if sData.owerIncome ~= nil then
                        USER_INFO["owerIncome"] = sData.owerIncome
                    end
                    dump(this.hallMainLayer,"===ggggg65757gg")
                    if this.hallMainLayer then

                        this.hallMainLayer:updateGold()
                    end

                end
            end

        end})

end

function gameScene:loadHallForRoomCard()
    package.loaded["hall.HallMainLayer"] = nil
    local hallMainLayer = require("hall.HallMainLayer").new()
    if hallMainLayer then
        self.hallMainLayer = hallMainLayer
        hallMainLayer:addTo(self)
    end
end

function gameScene:onEnter()

    --进入大厅重置心跳TID
    HEART_BEAT_TID = 0
    dump( string.format("%0.1f", math.floor(100000/1000)/100),"string.format")

    --检查重连（仅在断线重连时调用）
    if bm.netdisConnect then
        require(HallServer_filePath):cliUserGameStatus()
    end
    -- require("hall.groudgamemanager"):requestGroupStatus()

    self:ChoseBgMusic()

    

    if USER_INFO["hasReceiveRegisterBonus"] == 0 then
        require(MissionScene_filePath):receiveRegisterBonus(self)
    end

    self:onChangeBg()
end

function gameScene:ChoseBgMusic()
    if HasThreeBgm and HasThreeBgm > 0  then
        require("hall.util.SoundUtils"):playBgmByType()
    else
        require("hall.util.SoundUtils"):playHallBG()
    end
end

function gameScene:onChangeBg()
    if self.hallMainLayer then
        self.hallMainLayer:onChangeBg()
        if self.hallMainLayer.familyMainlayer and self.hallMainLayer.familyMainlayer.onChangeBg then
            self.hallMainLayer.familyMainlayer:onChangeBg()
        end
    end
end

function gameScene:checkPhone(var)
    local b = tonumber(var) -- b="number"
    print(b)
    if (b==nil) then
        print("is not number")
        return false


    end
    print("var==========".. #var)


    if(#var ~= 11) then
        return false;
    end
    --local array = {"133","153","180","189","181", --电信
    --               "130","131","132","145", --联通
    --               "155","156","185","186",
    --               "134","135","136","137", --移动
    --               "138","139","147","150",
    --               "151","152","157","158",
    --               "159","182","187","188"
    --}
    --print(string.sub(var,0,3))
    --for i = 1, #array do
    --    if(array[i] == string.sub(var,0,3)) then
    return true;
    --    end
    --end

end
--离开大厅
function gameScene:onExit()
    --self.hallMainLayer = nil
end

return gameScene