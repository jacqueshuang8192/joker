local Protocol = require("hz_majiang.src.handle.Protocol")
local ReceiveHandle = require("hz_majiang.src.handle.ReceiveHandle")
local SendHandle = require("hz_majiang.src.handle.SendHandle")
local GameSceneView = require("hz_majiang.src.view.GameSceneView")
local Config = require("hz_majiang.src.Config")
local PokerCard = require("hz_majiang.src.PokerCard")
local SoundUtils = require("hz_majiang.src.SoundUtils")
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
    SoundUtils:playBackgroundMusic()
end

function gameScene:getViewIdBySeatId(seat)
	if g_308.my_seat_id < 0 or g_308.my_seat_id == 0 then
		return seat + 1
	else
        local num = 0 - g_308.my_seat_id
		local viewId = (seat + num) % g_308.TOTAL_PLAYERNUM
		if seat + num == g_308.TOTAL_PLAYERNUM then
			return g_308.TOTAL_PLAYERNUM
		end
		return viewId + 1
	end
end

function gameScene:onChangeBg()
    local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO.level,1)
    self.GameSceneView.bg:loadTexture("hz_majiang/res/GameScene/bg_"..str..".png")
end

function gameScene:changeCard()
    g_308.cardPath = cc.UserDefault:getInstance():getIntegerForKey("cardType_"..USER_INFO.level, 1)
    dumpW(g_308.cardPath)
    for k,node in pairs(g_308.allCards) do
        PokerCard:changeImg(node, node._cardValue)
    end
end

function gameScene:onExit()
    dump("销毁场景游戏-----------------")
    self.ReceiveHandle:delHandleMgr()
    if USER_INFO.level ~= g_308.level then--退出游戏或者返回大厅的时候清除
        self.Config:onExit()
    end
end

return gameScene