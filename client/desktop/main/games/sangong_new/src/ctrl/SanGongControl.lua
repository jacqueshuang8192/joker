local SanGongUtils = require("sangong_new.src.ctrl.SanGongUtils")
local SanGongLogic = require("sangong_new.src.ctrl.SanGongLogic")
local SanGongProtocol = require("sangong_new.src.handle.SanGongProtocol")
local SanGongReceiveHandle = require("sangong_new.src.handle.SanGongReceiveHandle")
local SanGongSendHandle = require("sangong_new.src.handle.SanGongSendHandle")
local SanGongControl = class("SanGongControl")

-- adb devices
-- adb shell ps | grep xylm
-- adb logcat --pid

function SanGongControl:ctor(scene)
    SanGongControl.pInstance = self
    self.scene = scene

    self.logic = SanGongLogic.new(self, scene)
    self.utils = SanGongUtils.new(self)

    self.receive = SanGongReceiveHandle.new()
    self.send = SanGongSendHandle.new()
    self.receive:setCtrl(self, self.logic, self.scene)
    self.send:setCtrl(self, self.logic, self.scene)

    bm.server:setProtocol(SanGongProtocol)
    bm.server:setHandle(self.receive)
end

function SanGongControl:onExit()
    -- self.receive:setCtrl(nil, nil, nil)
end

function SanGongControl:sendLogin()
    self.send:LoginRoom(USER_INFO["tid"], USER_INFO["seat"], USER_INFO["activity_id"])

    HEART_BEAT_TID = USER_INFO["tid"]
end

function SanGongControl:sendFaceByIdx(id)
    self.send:CLI_MSG_FACE(id)
end

--退出房间，返回大厅
function SanGongControl:returnToHall()
    USER_INFO["gameConfig"] = ""
    HEART_BEAT_TID = 0
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
end

--再来一局
function SanGongControl:onceAgain()
    self.logic:nextRoundClean()
    GameEvent:dispatch("SanGongNextRoundClean")
    require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"])
end

function SanGongControl:doShareScreen()
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

function SanGongControl:doShareRoom()
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
    paras["name"] = "欢乐三公，房号：" .. self.logic.inviteCode
    paras["showType"] = 2
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(self.scene)
    end
end

return SanGongControl
