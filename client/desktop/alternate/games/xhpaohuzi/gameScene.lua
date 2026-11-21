local Protocol = require("xhpaohuzi.src.handle.Protocol")
local ReceiveHandle = require("xhpaohuzi.src.handle.ReceiveHandle")
local SendHandle = require("xhpaohuzi.src.handle.SendHandle")
local GameSceneView = require("xhpaohuzi.src.view.GameSceneView")
local Config = require("xhpaohuzi.src.Config")
local Card = require("xhpaohuzi.src.Card")
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
    SendHandle:LoginRoom(USER_INFO.tid, USER_INFO.seat_id, USER_INFO.activity_id)
    self:ChoseBgMusic()
end

function gameScene:ChoseBgMusic()
    if HasThreeBgm and HasThreeBgm > 0  then
        local musicPath = cc.UserDefault:getInstance():getIntegerForKey("bgMusicType_"..USER_INFO.level, 1)

        local sound_path = "hall/scene/res/common/music/AllBgMusic/phz_"..musicPath..".mp3"

        cc.SimpleAudioEngine:getInstance():playMusic(sound_path, true)
    else
        --播放背景音乐
        audio.playMusic("xhpaohuzi/res/sound/Music.mp3", true)
    end
end


function gameScene:getViewIdBySeatId(seat)
	if g_398.my_seat_id < 0 or g_398.my_seat_id == 0 then
		return seat + 1
	else
        local num = 0 - g_398.my_seat_id
		local viewId = (seat + num) % g_398.TOTAL_PLAYERNUM
		if seat + num == g_398.TOTAL_PLAYERNUM then
			return g_398.TOTAL_PLAYERNUM
		end
		return viewId + 1
	end
end

function gameScene:onChangeBg()
    local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO.level,1)
    self.GameSceneView.bg:loadTexture("xhpaohuzi/res/GameScene/bg_"..str..".png")
end

function gameScene:changeCard()
    g_398.cardPath = cc.UserDefault:getInstance():getIntegerForKey("cardType_"..USER_INFO.level, 1)
    dump(g_398.cardPath)
    for k,node in pairs(g_398.allCards) do
        Card:changeImg(node, node._pokerCard, node._type)
    end
end

function gameScene:onExit()
    self.ReceiveHandle:delHandleMgr()
    if USER_INFO.level ~= g_398.level then--退出游戏或者返回大厅的时候清除
        self.Config:onExit()
    end
end

return gameScene