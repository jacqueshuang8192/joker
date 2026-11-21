local Protocol = require("hcphz.src.handle.Protocol")
local ReceiveHandle = require("hcphz.src.handle.ReceiveHandle")
local SendHandle = require("hcphz.src.handle.SendHandle")
local GameSceneView = require("hcphz.src.view.GameSceneView")
local Config = require("hcphz.src.Config")
local gameScene = class("gameScene", function()
    return display.newScene("gameScene")
end)

function gameScene:ctor()
    self.Config = Config.new()
    self:setNodeEventEnabled(true)
    self.GameSceneView = GameSceneView.new():addTo(self)
    bm.server:setProtocol(Protocol)
    self.ReceiveHandle = ReceiveHandle.new(self)
    bm.server:setHandle(self.ReceiveHandle)
    --骨骼动画表情
    require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self.GameSceneView:getToSendFaceAndTxtFuncs(), self)
    self:onChangeBg()
end

function gameScene:onEnter()
    SendHandle:LoginRoom(USER_INFO.tid, USER_INFO.seat_id, USER_INFO.activity_id)
    audio.playMusic("hcphz/res/sound/Music.mp3", true)
end

function gameScene:getViewIdBySeatId(seat)
	if g_396.my_seat_id < 0 or g_396.my_seat_id == 0 then
		return seat + 1
	else
        local num = 0 - g_396.my_seat_id
		local viewId = (seat + num) % g_396.TOTAL_PLAYERNUM
		if seat + num == g_396.TOTAL_PLAYERNUM then
			return g_396.TOTAL_PLAYERNUM
		end
		return viewId + 1
	end
end

function gameScene:onChangeBg()
    local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO.level,1)
    self.GameSceneView.bg:loadTexture("hcphz/res/GameScene/bg_"..str..".png")
end

function gameScene:onExit()
    self.ReceiveHandle:delHandleMgr()
    if USER_INFO.level ~= g_396.level then--退出游戏或者返回大厅的时候清除
        self.Config:onExit()
    end
end

return gameScene