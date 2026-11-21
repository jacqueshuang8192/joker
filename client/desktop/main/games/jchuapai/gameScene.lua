local Protocol = require("jchuapai.src.handle.Protocol")
local ReceiveHandle = require("jchuapai.src.handle.ReceiveHandle")
local SendHandle = require("jchuapai.src.handle.SendHandle")
local GameSceneView = require("jchuapai.src.view.GameSceneView")
local Config = require("jchuapai.src.Config")
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

end

function gameScene:onEnter()
    SendHandle:LoginRoom(USER_INFO.tid, USER_INFO.seat_id, USER_INFO.activity_id)
end

function gameScene:getViewIdBySeatId(seat)
	if g_388.my_seat_id < 0 or g_388.my_seat_id == 0 then
		return seat + 1
	else
        local num = 0 - g_388.my_seat_id
		local viewId = (seat + num) % g_388.TOTAL_PLAYERNUM
		if seat + num == g_388.TOTAL_PLAYERNUM then
			return g_388.TOTAL_PLAYERNUM
		end
		return viewId + 1
	end
end

function gameScene:onExit()
    self.ReceiveHandle:delHandleMgr()
    self.Config:onExit()
    if USER_INFO.level ~= g_388.level then--退出游戏或者返回大厅的时候清除
    end
end

return gameScene