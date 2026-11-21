local Protocol = require("zhajinhua_jb.src.handle.Protocol")
local ReceiveHandle = require("zhajinhua_jb.src.handle.ReceiveHandle")
local SendHandle = require("zhajinhua_jb.src.handle.SendHandle")
local GameSceneView = require("zhajinhua_jb.src.view.GameSceneView")
local Config = require("zhajinhua_jb.src.Config")
local PokerCard = require("zhajinhua_jb.src.PokerCard")
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
    self:changeCard()
end

function gameScene:onEnter()
    SendHandle:enterRoom()
    local SoundUtils = require("zhajinhua_jb.src.SoundUtils")
    SoundUtils:playBackgroundMusic()
end

function gameScene:getViewIdBySeatId(seat)
	if g_317.my_seat_id < 0 or g_317.my_seat_id == 0 then
		return seat + 1
	else
        local num = 0 - g_317.my_seat_id
		local viewId = (seat + num) % g_317.TOTAL_PLAYERNUM
		if seat + num == g_317.TOTAL_PLAYERNUM then
			return g_317.TOTAL_PLAYERNUM
		end
		return viewId + 1
	end
end

function gameScene:onChangeBg()
    local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO.level,1)
    self.GameSceneView.bg:loadTexture("zhajinhua_jb/res/GameScene/bg_"..str..".png")
end

function gameScene:changeCard()
    g_317.cardPath = cc.UserDefault:getInstance():getIntegerForKey("cardType_"..USER_INFO.level, 1)
    dumpW(g_317.cardPath)
    for k,node in pairs(g_317.allCards) do
        PokerCard:changeImg(node, node._pokerCard)
    end
end

function gameScene:onExit()
    self.ReceiveHandle:delHandleMgr()
    if USER_INFO.level ~= g_317.level then--退出游戏或者返回大厅的时候清除
        self.Config:onExit()
    end
end

return gameScene