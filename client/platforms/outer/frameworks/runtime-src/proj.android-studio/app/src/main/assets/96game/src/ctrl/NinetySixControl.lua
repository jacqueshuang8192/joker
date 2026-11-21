local NinetySixUtils = require("96game.src.ctrl.NinetySixUtils")
local NinetySixLogic = require("96game.src.ctrl.NinetySixLogic")
local NinetySixProtocol = require("96game.src.handle.NinetySixProtocol")
local NinetySixReceiveHandle = require("96game.src.handle.NinetySixReceiveHandle")
local NinetySixSendHandle = require("96game.src.handle.NinetySixSendHandle")
local NinetySixControl = class("NinetySixControl")

-- adb devices
-- adb shell ps | grep xylm
-- adb logcat --pid

function NinetySixControl:ctor(scene)
    NinetySixControl.pInstance = self
    self.scene = scene

    self.logic = NinetySixLogic.new(self, scene)
    self.utils = NinetySixUtils.new(self)

    self.receive = NinetySixReceiveHandle.new()
    self.send = NinetySixSendHandle.new()
    self.receive:setCtrl(self, self.logic, self.scene)
    self.send:setCtrl(self, self.logic, self.scene)
    
    bm.server:setProtocol(NinetySixProtocol)
    bm.server:setHandle(self.receive)
end

function NinetySixControl:onExit()
    -- self.receive:setCtrl(nil, nil, nil)
end

function NinetySixControl:sendLogin()
    self.send:LoginRoom(USER_INFO["tid"], USER_INFO["seat"], USER_INFO["activity_id"])

    HEART_BEAT_TID = USER_INFO["tid"]
end

function NinetySixControl:sendFaceByIdx(id)
    self.send:CLI_MSG_FACE(id)
end

--退出房间，返回大厅
function NinetySixControl:returnToHall()
    USER_INFO["gameConfig"] = ""
    HEART_BEAT_TID = 0
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
end

--再来一局
function NinetySixControl:onceAgain()
    self.logic:nextRoundClean()
    GameEvent:dispatch("NinetySixNextRoundClean")
    require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"])
end

function NinetySixControl:doShareScreen()
    local config_arr = LuaSplit(self.logic.gameConfig, " ")
    local share_content = ""
    for k, v in pairs(config_arr) do
        if v ~= "" then
            share_content = share_content .. v .. ","
        end
    end
    share_content = string.sub(share_content, 1, string.len(share_content) - 1)

    local paras = {}
    paras["desc"] = share_content
    paras["imagePath"] = "screen"
    paras["name"] = "分享结果"
    paras["showType"] = 2
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(self.scene)
    end

    -- --通知APP分享结果
    -- if device.platform == "android" then
    --     require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
    -- elseif device.platform ~= "windows" then
    --     require("hall.common.ShareLayer"):shareGroupResultForIOS()
    -- end
end
function NinetySixControl:doQuitAl()
    self.send:CLI_ROBOT(0)
end
function NinetySixControl:doShareRoom()
    local config_arr = LuaSplit(self.logic.gameConfig, " ")
    local share_content = ""
    for k, v in pairs(config_arr) do
        if v ~= "" then
            share_content = share_content .. v .. ","
        end
    end
    share_content = string.sub(share_content, 1, string.len(share_content) - 1)

    local paras = {}
    paras["desc"] = share_content
    paras["imagePath"] = "url"
    paras["name"] = "96扑克，房号：" .. self.logic.inviteCode
    paras["showType"] = 2
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(self.scene)
    end
end

return NinetySixControl
