local FaceUI = require("hall.FaceUI.faceUI")
-- local SanGongDefine = require("sangong_new.src.ctrl.SanGongDefine")
local SanGongControl = require("sangong_new.src.ctrl.SanGongControl")
local SanGongPanelContent = require("sangong_new.src.view.SanGongPanelContent")
local SanGongPanelPlayer = require("sangong_new.src.view.SanGongPanelPlayer")
-- local SanGongPlayer = require("sangong_new.src.view.SanGongPlayer")
-- local SanGongBtnOpt = require("sangong_new.src.view.SanGongBtnOpt")
-- local SanGongHandCards = require("sangong_new.src.view.SanGongHandCards")
-- local SanGongOutCards = require("sangong_new.src.view.SanGongOutCards")
-- local SanGongRoundSettle = require("sangong_new.src.view.SanGongRoundSettle")
-- local SanGongTotalSettle = require("sangong_new.src.view.SanGongTotalSettle")


local SanGongGameScene =
    class(
    'SanGongGameScene',
    function()
        return display.newScene('SanGongGameScene')
    end
)

function SanGongGameScene:resolutionSize()
    DESIGN_SCREEN_WIDTH = 1920
    DESIGN_SCREEN_HEIGHT = 1080

    local glView = cc.Director:getInstance():getOpenGLView()
    local framesize = glView:getFrameSize()
    SCREEN_WIDTH = framesize.width
    SCREEN_HEIGHT = framesize.height

    local scaleX, scaleY = framesize.width / DESIGN_SCREEN_WIDTH, framesize.height / DESIGN_SCREEN_HEIGHT
    local width, height = framesize.width, framesize.height

    local autoscale = "FIXED_HEIGHT"
    if autoscale == "FIXED_WIDTH" then
        width = framesize.width / scaleX
        height = framesize.height / scaleX
        glView:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    elseif autoscale == "FIXED_HEIGHT" then
        width = framesize.width / scaleY
        height = framesize.height / scaleY
        glView:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    else
        glView:setDesignResolutionSize(DESIGN_SCREEN_WIDTH, DESIGN_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)
    end

    GLOBAL_SCALE = DESIGN_SCREEN_WIDTH / SCREEN_WIDTH

    local sizeInPixels = glView:getFrameSize()
    display.sizeInPixels = {width = sizeInPixels.width, height = sizeInPixels.height}

    local director = cc.Director:getInstance()
    local viewsize = director:getWinSize()
    display.contentScaleFactor = director:getContentScaleFactor()
    display.size               = {width = viewsize.width, height = viewsize.height}
    display.width              = display.size.width
    display.height             = display.size.height
    display.cx                 = display.width / 2
    display.cy                 = display.height / 2
    display.c_left             = -display.width / 2
    display.c_right            = display.width / 2
    display.c_top              = display.height / 2
    display.c_bottom           = -display.height / 2
    display.left               = 0
    display.right              = display.width
    display.top                = display.height
    display.bottom             = 0
    display.center             = cc.p(display.cx, display.cy)
    display.left_top           = cc.p(display.left, display.top)
    display.left_bottom        = cc.p(display.left, display.bottom)
    display.left_center        = cc.p(display.left, display.cy)
    display.right_top          = cc.p(display.right, display.top)
    display.right_bottom       = cc.p(display.right, display.bottom)
    display.right_center       = cc.p(display.right, display.cy)
    display.top_center         = cc.p(display.cx, display.top)
    display.top_bottom         = cc.p(display.cx, display.bottom)
end

function SanGongGameScene:ctor()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    self:resolutionSize()

    SCENENOW["scene"] = self
    -- self:setNodeEventEnabled(true)
    self.ctrl = SanGongControl.new(self)
    self.logic = self.ctrl.logic

    self.bIsInitPanel = false
    self:initUI()
end

function SanGongGameScene:initUI()
    local ins = cc.SpriteFrameCache:getInstance()
    require('hall.PokerCard'):loadRes()
    ins:addSpriteFrames("sangong_new/res/images/sangong.plist", "sangong_new/res/images/sangong.png")
    self._scene = cc.CSLoader:createNode("sangong_new/res/csb/GameSceneForTen.csb"):addTo(self)

    local winSize = cc.Director:getInstance():getWinSize()
    self.background = self._scene:getChildByName('background')
    local bgSize = self.background:getContentSize()
    local scaleX, scaleY = winSize.width / bgSize.width, winSize.height / bgSize.height
    self.background:setScale(math.max(scaleX, scaleY))
    self._scene:setContentSize(winSize)
    ccui.Helper:doLayout(self._scene)
end

function SanGongGameScene:initPanel()
    if self.bIsInitPanel then
        return
    end

    self.bIsInitPanel = true
    self.Panel_content = self._scene:getChildByName("Panel_content")
    self.Plane_players = self._scene:getChildByName("Plane_players")
    self.Plane_players:setVisible(true)
    self.content = SanGongPanelContent.new(self, self.Panel_content)

    local dealCardsPos = self.Plane_players:getChildByName("dealCardsPos")
    self.dealCardWSPos = self.Plane_players:convertToWorldSpace(dealCardsPos:getPosition())

    self.tPlayers = {}
    for i = 1, 10 do
        table.insert(self.tPlayers, SanGongPanelPlayer.new(self, self.Plane_players, i))
    end

    self.faceUI = FaceUI.new();
    self.faceUI:setHandle(self.ctrl.send)
    self.faceUI:setName("faceUI")
    self:addChild(self.faceUI)

    --显示表情符号
    local data = {
        sendFaceHand = handler(self.ctrl.send, self.ctrl.send.CLI_MSG_FACE)
    }
    local Emoji = require('hall.EmojiArmatureView.EmojiArmatureView')
    self.emojiView = Emoji:newEmojiArmatureView(data, self)
end

function SanGongGameScene:getPlayerView(uid)
    local viewId = self.logic:getPlayerViewId(uid)
    return self.tPlayers[viewId]
end

function SanGongGameScene:onEnter()
    local ins = cc.SpriteFrameCache:getInstance()
    local isLoad = ins:isSpriteFramesWithFileLoaded("sangong_new/res/images/sangong.plist")
    if not isLoad then
        ins:addSpriteFrames("sangong_new/res/images/sangong.plist", "sangong_new/res/images/sangong.png")
    end
    self:initPanel()

    for _, v in ipairs(self.tPlayers) do
        v:onEnter()
    end

    self.content:onEnter()

    --播放背景音乐
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    -- self.ctrl.utils:playBackgroundMusic()
    self.ctrl:sendLogin()
end

function SanGongGameScene:onExit()
    -- require("hall.VoiceRecord.VoiceRecordView"):removeView()

    for _, v in ipairs(self.tPlayers) do
        v:onExit()
    end
    self.content:onExit()
    self.ctrl:onExit()
end

function SanGongGameScene:onChangeBg()
    local str = cc.UserDefault:getInstance():getIntegerForKey('GameBgType', 2)
    self.background:loadTexture('sangong_new/res/big_png/big_scene_bg_' .. str .. '.png')
end

return SanGongGameScene
