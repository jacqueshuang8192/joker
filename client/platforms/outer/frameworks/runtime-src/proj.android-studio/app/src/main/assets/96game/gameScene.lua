local FaceUI = require("hall.FaceUI.faceUI")
local NinetySixDefine = require("96game.src.ctrl.NinetySixDefine")
local NinetySixControl = require("96game.src.ctrl.NinetySixControl")
local NinetySixGameInfo = require("96game.src.view.NinetySixGameInfo")
local NinetySixPlayer = require("96game.src.view.NinetySixPlayer")
local NinetySixBtnOpt = require("96game.src.view.NinetySixBtnOpt")
local NinetySixHandCards = require("96game.src.view.NinetySixHandCards")
local NinetySixOutCards = require("96game.src.view.NinetySixOutCards")
local NinetySixRoundSettle = require("96game.src.view.NinetySixRoundSettle")
local NinetySixTotalSettle = require("96game.src.view.NinetySixTotalSettle")

local NinetySixScene =
    class(
    "NinetySixScene",
    function()
        return display.newScene("NinetySixScene")
    end
)

function NinetySixScene:ctor()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    self:resolutionSize()
    GROUP_96 = false
    SCENENOW["scene"] = self
    -- self:setNodeEventEnabled(true)
    self.ctrl = NinetySixControl.new(self)
    self.logic = self.ctrl.logic

    self:initUI()

    -- self:showRoundSettle(  )
    -- self:showTotalSettle(  )
end

function NinetySixScene:resolutionSize()
    DESIGN_SCREEN_WIDTH = 1280
    DESIGN_SCREEN_HEIGHT = 720

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

function NinetySixScene:initUI()
    local FrameCache = cc.SpriteFrameCache:getInstance()
    FrameCache:addSpriteFrames("96game/res/ninetysix_poker.plist", "96game/res/ninetysix_poker.png")
    FrameCache:addSpriteFrames("96game/res/poker.plist", "96game/res/poker.png")
    
    self._scene = cc.CSLoader:createNode("96game/res/csb/GameScene.csb"):addTo(self)

    self.Panel_center = self._scene:getChildByName("Panel_center")
    self.Panel_arrow = self._scene:getChildByName("Panel_arrow")
    self.game_info = NinetySixGameInfo.new(self, self._scene)
    self.btn_opt = NinetySixBtnOpt.new(self, self._scene)
    self.hand_card = NinetySixHandCards.new(self, self._scene)

    self.panel_player = self._scene:getChildByName('Panel_player')
    self.tPlayers = {
        NinetySixPlayer.new(self, self.panel_player, 1),
        NinetySixPlayer.new(self, self.panel_player, 2),
        NinetySixPlayer.new(self, self.panel_player, 3),
        NinetySixPlayer.new(self, self.panel_player, 4)
    }

    self.Panel_effect = self._scene:getChildByName('Panel_effect')
    self.Panel_out = self._scene:getChildByName('Panel_out')
    self.tCardOuts = {
        NinetySixOutCards.new(self, self.Panel_out, 1),
        NinetySixOutCards.new(self, self.Panel_out, 2),
        NinetySixOutCards.new(self, self.Panel_out, 3),
        NinetySixOutCards.new(self, self.Panel_out, 4)
    }

    self.faceUI = FaceUI.new();
    self.faceUI:setHandle(self.ctrl.send)
    self.faceUI:setName("faceUI")
    self:addChild(self.faceUI, 9999)

    local winSize = cc.Director:getInstance():getWinSize()
    self.SceneBG = self._scene:getChildByName('SceneBG')
    local bgSize = self.SceneBG:getContentSize()
    local scaleX, scaleY = winSize.width / bgSize.width, winSize.height / bgSize.height
    self.SceneBG:setScale(math.max(scaleX, scaleY))
    self._scene:setContentSize(winSize)
    ccui.Helper:doLayout(self._scene)
    --添加96版本号显示
    --local lbVersion = cc.Label:createWithTTF("1.0.0.1","hall/res/font/FZY3JW.TTF",40)
    --lbVersion:setColor(cc.c3b(125, 125, 125))
    --lbVersion:setPosition(cc.p(lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2 ))
    --self._scene:addChild(lbVersion, 1000)
    --lbVersion:onClick(function ( event )
    --    self.ctrl.send:CLIENT_COMMAND_GET_CARD()
    --end)
    --local cards ={}
    --table.insert(cards,1)
    --table.insert(cards,2)
    --table.insert(cards,3)
    --table.insert(cards,1)
    --table.insert(cards,2)
    --table.insert(cards,3)
    --table.insert(cards,1)
    --table.insert(cards,2)
    --table.insert(cards,3)
    --table.insert(cards,1)
    --table.insert(cards,2)
    --table.insert(cards,3)
    --table.insert(cards,1)
    --table.insert(cards,2)
    --table.insert(cards,3)
    --table.insert(cards,1)
    --table.insert(cards,2)
    --table.insert(cards,3)
    --table.insert(cards,1)
    --table.insert(cards,2)
    --table.insert(cards,3)
    --local cheatLayer = require("96game.src.view.CheatCardLayer").new(self,cards)
    --cheatLayer:setZOrder(999)
    --cheatLayer:setName("CheatCardLayer")
    --self._scene:addChild(cheatLayer)
    -- self:showWinArmature2( )
end

function NinetySixScene:lbVersionShow()
    self.ctrl.send:CLIENT_COMMAND_GET_CARD()
end

function NinetySixScene:getPlayerView(uid)
    local viewId = self.logic:getPlayerViewId(uid)
    return self.tPlayers[viewId]
end

function NinetySixScene:getOutCardView(uid)
    local viewId = self.logic:getPlayerViewId(uid)
    return self.tCardOuts[viewId]
end

function NinetySixScene:showWinArmature1( )
    local json = "96game/res/ani/zhanshi.ExportJson"
    local png = "96game/res/ani/zhanshi0.png"
    local plist = "96game/res/ani/zhanshi0.plist"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(png, plist, json)

    self.armature = ccs.Armature:create("zhanshi")
    self.armature:setPosition(640, 360)
    -- self.armature:getAnimation():setSpeedScale(1)
    self.panel_player:addChild(self.armature)

    self.curTestIdx = 1
    self.ani_name = {'peng', 'hu', 'shao', 'chi', 'tie'}
    local function dotest()
        self.curTestIdx = self.curTestIdx + 1
        if self.curTestIdx > #self.ani_name then
            self.curTestIdx = 1
        end
        self.armature:getAnimation():play(self.ani_name[self.curTestIdx], -1, 0)
    end
    local seqAc = cc.Sequence:create(cc.CallFunc:create(dotest), cc.DelayTime:create(2))
    self.panel_player:runAction(cc.RepeatForever:create(seqAc))

    --[[
    local function afterFunction()
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(json)
    end
    self.armature:getAnimation():setMovementEventCallFunc(afterFunction)
    --]]
end

function NinetySixScene:showWinArmature2( )
    --[[local tbl = {"banzao", "dihu", "hundahu", "hunhu", "huntahu", "huntaihu", "manzhao",
        "qinhu", "sedahu", "sehu", "setahu", "setaihu", "sudahu", "suhu", "suqinhu", "sutahu", "sutaihu", "tianhu", "zhuazhu", "zimo", "zou",}
        --]]

    local tbl = {"dahu", "kan", "manyuangun", "shun", "tahu", "taihu"}

    local json_fmt = "96game/res/ani/%s/%s.ExportJson"
    local png_fmt = "96game/res/ani/%s/%s.png"
    local plist_fmt = "96game/res/ani/%s/%s.plist"

    self.curTestIdx = 1
    local function dotest()
        self.curTestIdx = self.curTestIdx + 1
        if self.curTestIdx > #tbl then
            self.curTestIdx = 1
        end
        local name = tbl[self.curTestIdx]
        print("test=========================>start", name)

        local json = string.format(json_fmt, name, name)
        local png = string.format(png_fmt, name, name)
        local plist = string.format(plist_fmt, name, name)
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(png, plist, json)

        local armature = ccs.Armature:create(name)
        armature:setPosition(640, 360)
        armature:getAnimation():play(name , -1, 0)

        local function afterFunction()
            print("test******************end:", name)
            armature:removeFromParent()
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(json)
        end
        armature:getAnimation():setMovementEventCallFunc(afterFunction)

        self.panel_player:addChild(armature)
    end
    local seqAc = cc.Sequence:create(cc.CallFunc:create(dotest), cc.DelayTime:create(2))
    self.panel_player:runAction(cc.RepeatForever:create(seqAc))
end

--设置和文字消息
function NinetySixScene:onEnter()
    
    local FrameCache = cc.SpriteFrameCache:getInstance()
    local isLoad = FrameCache:isSpriteFramesWithFileLoaded("96game/res/ninetysix_poker.plist")
    print("onEnter------->NinetySixScene", isLoad)
    if not isLoad then
        FrameCache:addSpriteFrames("96game/res/ninetysix_poker.plist", "96game/res/ninetysix_poker.png")
        FrameCache:addSpriteFrames("96game/res/poker.plist", "96game/res/poker.png")
    end

    self.game_info:onEnter()
    self.btn_opt:onEnter()
    self.hand_card:onEnter()
    
    for k, v in pairs(self.tPlayers) do
        v:onEnter()
    end

    for k, v in pairs(self.tCardOuts) do
        v:onEnter()
    end

    --播放背景音乐
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    self.ctrl.utils:playBackgroundMusic()
    self.ctrl:sendLogin()
end

function NinetySixScene:onExit()
    -- require("hall.VoiceRecord.VoiceRecordView"):removeView()

    self.game_info:onExit()
    self.btn_opt:onExit()
    self.hand_card:onExit()

    for k, v in pairs(self.tPlayers) do
        v:onExit()
    end

    for k, v in pairs(self.tCardOuts) do
        v:onExit()
    end

    self.ctrl:onExit()
end

function NinetySixScene:onCleanup()
    print("onCleanup------->NinetySixScene")
    local FrameCache = cc.SpriteFrameCache:getInstance()
    FrameCache:removeSpriteFramesFromFile("96game/res/ninetysix_poker.plist")
    FrameCache:removeSpriteFramesFromFile("96game/res/poker.plist")
end

function NinetySixScene:removeNinetySixRoundSettle()
    local NinetySixRoundSettle = self:getChildByName("NinetySixRoundSettle")
    if NinetySixRoundSettle then
        NinetySixRoundSettle:removeSelf()
    end
end

function NinetySixScene:showRoundSettle(pack)
    local function show_settle()
        local settle = NinetySixRoundSettle.new(self)
        --print("show round settle error:=====", pack.huUserSeatid)
        settle:setPackData(pack)
    end

    if pack and pack.nRoundResult > 0 then
        local viewId = self.logic:getViewId(pack.huUserSeatid)
        local obj = self.tCardOuts[viewId]
        if obj then
            if pack.huType == NinetySixDefine.HU_PAI_PU_TONG and pack.nRoundResult == 1 then
                obj:doOptionAniAndVoice(NinetySixDefine.HU)
            else
                obj:doOptionAniAndVoice(pack.huType)
            end
            dump(self.logic.mySeatId,"self.logic.mySeatId")
            dump(pack.huUserSeatid,"pack.huUserSeatid")
            dump(pack.nRoundResult,"pack.nRoundResult")
            if self.logic.mySeatId == pack.huUserSeatid then
                if pack.nRoundResult == 1 then
                    local viewIdOthe = self.logic:getViewId(pack.dianPaoid)
                    dump(viewIdOthe,"viewIdOthe")
                    local objOthe = self.tCardOuts[viewIdOthe]
                    objOthe:moveToCard()
                end

            end
            if pack.huType == NinetySixDefine.HU_PAI_TIAN then
                show_settle()
            else
                self:performWithDelay(show_settle, 3.5)
            end
            --print("show round settle:", pack.huUserSeatid, viewId)

        else
            --print("show round settle error:", pack.huUserSeatid, viewId)
            show_settle()
            end
    else
        show_settle()
    end
end
function NinetySixScene:hideRundButton()
    if NinetySixRoundSettle.hideRundButton then
        print("hideRundButton")
        NinetySixRoundSettle:hideRundButton()
    end
    print("hideRundButton=====")
end
function NinetySixScene:showTotalSettle(pack)
    local settle = NinetySixTotalSettle.new(self)
    settle:setPackData(pack)
end

function NinetySixScene:showTingCards(tingCards)
    self:hideTingCards()

    if tingCards and #tingCards > 0 then
        self.tingNode = ccui.ImageView:create("ninetysix_poker_scoreBG.png", 1)
        self.tingNode:ignoreContentAdaptWithSize(false)
        self.tingNode:setPosition(display.cx, display.cy + 20)
        self.tingNode:setScale9Enabled(true)
        self.tingNode:setCapInsets(cc.rect(20, 10, 49, 5))
        local items_margin = 0        
        local item_size = cc.size(80, 120)
        local mid_item_w = item_size.width / 2
        local size = cc.size(math.min(#tingCards * (items_margin + item_size.width), 1100) + 10, item_size.height + 20)
        self.tingNode:setContentSize(size)
        self.tingNode:setName("TingCardsNode")
        self:addChild(self.tingNode)

        local listView = ccui.ListView:create()
        -- listView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        listView:setDirection(ccui.ScrollViewDir.horizontal)
        listView:setBounceEnabled(true)
        -- listView:setScrollBarEnabled(true)
        -- listView:setTouchEnabled(true)
        -- listview:setBackGroundColor(cc.c3b(0xFF,0xFF,0xFF))
        listView:setContentSize(cc.size(size.width - 10, item_size.height))
        listView:setClippingEnabled(true)
        listView:setPosition(5, 10)
        listView:setItemsMargin(items_margin)
        self.tingNode:addChild(listView)
        local NinetySixPokerCard = require('96game.src.view.NinetySixPokerCard')

        for k, v in ipairs(tingCards) do
            local item = ccui.Widget:create()
            item:setContentSize(item_size)
    
            local poker = NinetySixPokerCard.new(self.hand_card, nil, 0.5) --138 188
            poker:setCardId(v.cardId)
            poker:setState(2)
            poker:setAnchorPoint(cc.p(0.5, 1))
            poker:setPosition(mid_item_w, item_size.height)
            item:addChild(poker)
            
            ----[[
            local str1 = "x " .. tostring(v.huxi)
            local text1 = ccui.Text:create(str1, "96game/res/font/FZY3JW.TTF", 28)
            text1:setAnchorPoint(cc.p(0.5, 0))
            text1:setPosition(mid_item_w, -5)
            text1:setColor(cc.c3b(0, 0xff, 0))
            item:addChild(text1)

            --[[
            local str2 = "已出：8"
            local text2 = ccui.Text:create(str2, "96game/res/font/FZY3JW.TTF", 18)
            text2:setAnchorPoint(cc.p(0, 0.5))
            text2:setPosition(cc.p(poker.cardWid, poker.cardHei * 0.3))
            text2:setColor(cc.c3b(0xff, 0, 0))
            item:addChild(text2)
            --]]

            listView:pushBackCustomItem(item)
        end
    end
end

function NinetySixScene:hideTingCards()
    if self.tingNode then
        self.tingNode:removeFromParent()
        self.tingNode = nil
    end
end

return NinetySixScene
