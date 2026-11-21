--游戏界面信息
local NinetySixGameInfo = class("NinetySixGameInfo")

function NinetySixGameInfo:ctor(scene, parent)
    self.scene = scene
    self.parent = parent
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic

    self:initUI()
end

function NinetySixGameInfo:onEnter()
    self.tEvents = {
        GameEvent:addListen("NinetySixLoginBaseChips", handler(self, self.updateBaseChips)),
        GameEvent:addListen("NinetySixLoginRoomInfo", handler(self, self.updateView)),
        GameEvent:addListen("NinetySixReconnection", handler(self, self.updateView)),
        GameEvent:addListen("NinetySixUpdateRoundInfo", handler(self, self.updateRound)),
        GameEvent:addListen("NinetySixDuoPaiChange", handler(self, self.updateDuoPai)),
    }
end

function NinetySixGameInfo:onExit()
    for k, e in pairs(self.tEvents) do
        GameEvent:delListen(e)
    end
end

function NinetySixGameInfo:initUI()
    self.Panel_lefttop = self.parent:getChildByName("Panel_lefttop")

    self.Count_Down_BG = self.scene.Panel_center:getChildByName("Count_Down_BG")
    self.Card_Mounds = self.scene.Panel_center:getChildByName("Card_Mounds")
    self.Residuals_Cards = self.scene.Panel_center:getChildByName("Residuals_Cards")
    self.Count_Down = self.scene.Panel_center:getChildByName("Count_Down")

    self.Panel_device_info = self.Panel_lefttop:getChildByName("Panel_device_info")
    self.Room_InformationBG = self.Panel_lefttop:getChildByName("Room_InformationBG")

    self.BatteryLevel = self.Panel_device_info:getChildByName("BatteryLevel")
    self.TimeText = self.Panel_device_info:getChildByName("TimeText")
    self.WIFI_Logo = self.Panel_device_info:getChildByName("WIFI_Logo")

    self.RoomIdText = self.Room_InformationBG:getChildByName("RoomIdText")
    self.RoundText = self.Room_InformationBG:getChildByName("RoundText")
    self.RoundMsg = self.Room_InformationBG:getChildByName("RoundMsg")
    self.wPosCardMound = self.scene.Panel_center:convertToWorldSpace(self.Card_Mounds:getPosition())

    self.RoomIdText:setString("")
    self.RoundText:setString("")
    self.RoundMsg:setString("")
    self.Residuals_Cards:setString("")
    
    self.Count_Down:setString("")
    self.Count_Down_BG:setVisible(false)
    
    local function updateDeviceInfo()
        self.TimeText:setString(os.date("%H:%M"))
        self:updateElectricity()
        self:updateSignalQuality()
    end
    local seqAc = cc.Sequence:create(cc.CallFunc:create(updateDeviceInfo), cc.DelayTime:create(5))
    self.Panel_lefttop:runAction(cc.RepeatForever:create(seqAc))
end

function NinetySixGameInfo:updateDuoPai()
    self.Residuals_Cards:setString(tostring(self.logic.duoPai))
end

function NinetySixGameInfo:updateView()
    self.RoomIdText:setString("房间号：".. tostring(self.logic.inviteCode))
end
function NinetySixGameInfo:updateBaseChips()
    self.RoundMsg:setString("积分：   " .. tostring(self.logic.baseChip).."倍")
end
function NinetySixGameInfo:updateRound()
    local str = string.format("局  数：  %s/%s", tostring(self.logic.curRound), tostring(self.logic.totalRound))
    self.RoundText:setString(str)
end

--获取设备电量
function NinetySixGameInfo:updateElectricity()
    local betteryPercent = 100

    if device.platform == "ios" then
        betteryPercent = cct.getDataForApp("getBetteryPercent", {}, "I")
    elseif device.platform == "android" then
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        --[[
        -- 获取应用版本
        local appVersion
        local ok, ret = luaj.callStaticMethod(className, "getAppVersion", args, sigs)
        if not ok then
            print("luaj error:", ret)
        else
            appVersion = ret
        end
        --]]

        --获取应用电量
        ok, ret = luaj.callStaticMethod(className, "getPhonePower", args, sigs)
        if not ok then
            print("luaj error:", ret)
        else
            betteryPercent = tonumber(ret)
        end
    end

    self.BatteryLevel:setPercent(betteryPercent)
end

--检测网络质量
function NinetySixGameInfo:updateSignalQuality()
    local wifi_level_num = 4 --00 -- 04
    if PINT_TIME ~= nil then
        local ping = PINT_TIME
        if tonumber(ping) <= 120 then
            wifi_level_num = 4
        elseif tonumber(ping) > 120 and tonumber(ping) <= 200 then
            wifi_level_num = 3
        elseif tonumber(ping) > 200 and tonumber(ping) <= 300 then
            wifi_level_num = 2
        elseif tonumber(ping) > 300 and tonumber(ping) <= 500 then
            wifi_level_num = 1
        elseif tonumber(ping) > 500 then
            wifi_level_num = 0
        end
    end
    
    local str = string.format("ninetysix_poker_wifi_0%d.png", wifi_level_num)
    self.WIFI_Logo:loadTexture(str, 1)
end

return NinetySixGameInfo
