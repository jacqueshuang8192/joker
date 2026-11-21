local TemplateGameScene = class("TemplateGameScene",function()
    return display.newScene("TemplateGameScene")
end)
local CocosUtil = require("hall.util.CocosUtil")
function TemplateGameScene:initData()
    -----------------------------------------游戏相关信息-------------------------------------
    --游戏包名
    TpackageName = "template"

    SCHEDULER = require(cc.PACKAGE_NAME .. ".scheduler")
    CHECK_SCHEDULER_GLOBAL = nil
    GAME_NAME = "模板"
    GAME_VERSION = "1.0.0"

    DESIGN_SCREEN_WIDTH  = 1920
    DESIGN_SCREEN_HEIGHT = 1080

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

    GLOBAL_SCALE = DESIGN_SCREEN_WIDTH/SCREEN_WIDTH


    TemplateSendHandle = import(TpackageName .. ".handle.TemplateSendHandle")

    TemplateUtils = require(TpackageName..".TemplateUtils")

    -- TABLE_IMG = TpackageName .. "/images/pieces_card/card_back.png"

    CURRENTCARDBACKINDEX = cc.UserDefault:getInstance():getIntegerForKey("CBStyleIndex",2) --使用何种牌背样式
    CURRENTCARDBACKINDEX = 5
    -----------------------------------------房间相关信息--------------------------------------
    GAME_TIME = 0   --- 投分时间  -- 看牌时间  -- 结束时间
    -----------------------------------------座位相关信息-------------------------------------
    --玩家头像
    PLAYER_HEADS_TABLE ={}
    --玩家头像位置
    PLAYER_HEADS_POSITION_TABLE ={}  --世界位置
    --座位表（服务器座位）
    TEMPLATE_SEAT_TABLE = {}  --key = uid  value = seat_id
    TEMPLATE_UID_TABLE = {}  --key = seat  value = uid
    TEMPLATE_PLAYERTYPE_TABLE = {}   --key = uid  value = playerType
    TEMPLATE_SEAT_TABLE[USER_INFO["uid"]] = -1


        --玩家信息表
    TEMPLATE_USERINFO_TABLE = {} --key = uid  value = userInfo
    Tid = -1
    ------------------------------------------宏定义-------------------------------------------

    GAME_STATUS_STOP = 0            --牌局已结束
    GAME_STATUS_YA = 1              --押注阶段
    GAME_STATUS_SEND_CARD = 2       --发牌阶段
    GAME_STATUS_OUT_CARD = 3        --出牌阶段
    GAME_STATUS_OPEN_CARD = 4       --开牌阶段

    GAME_STATUS_WAIT_STOP = 5		--等待停止时期
    GAME_STATUS_OPEN_KIND = 6

    IS_DETAIL_STOP = false
    IS_ON_RANKING = false
    --顺时针排列
    -- CARD_PLAYERTYPE_MY = 0
    CARD_PLAYERTYPE_MY = 1
    CARD_PLAYERTYPE_LEFT = 2
    CARD_PLAYERTYPE_RIGHT = 3
    CARD_PLAYERTYPE_TOP = 4

    CARD_PLAYERTYPE_1 = 1
    CARD_PLAYERTYPE_2 = 2
    CARD_PLAYERTYPE_3 = 3
    CARD_PLAYERTYPE_4 = 4

    CARD_PLAYERTYPE_5 = 5
    CARD_PLAYERTYPE_6 = 6
    CARD_PLAYERTYPE_7 = 7
    CARD_PLAYERTYPE_8 = 8

    CARD_PLAYERTYPE_9 = 9
    CARD_PLAYERTYPE_10 = 10
    CARD_PLAYERTYPE_11 = 11
    CARD_PLAYERTYPE_12 = 12
    SoundUtils = import(TpackageName .. ".SoundUtils")

end


function TemplateGameScene:ctor()
    self:initData()
    self._scene = cc.CSLoader:createNode(TpackageName.."/csb/gameScene.csb"):addTo(self)
    GamePlaneOperator = require(TpackageName .. ".operator.GamePlaneOperator").new(self._scene)
    TEMPLATE_PLANE = self._scene:getChidByName("hall_plane")

    local TemplateProtocol = import(TpackageName .. ".handle.TemplateProtocol")
    local TemplateReceiveHandle = import(TpackageName .. ".handle.TemplateReceiveHandle")
    --设置协议和协议处理
    bm.server:setProtocol(TemplateProtocol)
    bm.server:setHandle(TemplateReceiveHandle.new())

end

--设置和文字消息
function TemplateGameScene:onEnter()
    --播放背景音乐
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    SoundUtils:playBackgroundMusic()
    --房间信息
    --TemplateSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
    --HEART_BEAT_TID = USER_INFO["tid"]
    self.btn_setting  = TEMPLATE_PLANE:getChildByName("btn_setting")
    self.btn_setting:onClick(CocosUtil:Bind(self.showGameSetting , self))
    self.btn_chat = TEMPLATE_PLANE:getChidByName("btn_chat")
    self.btn_chat:onClick(CocosUtil:Bind(self.loadGameMsgLayer , self))
end
function TemplateGameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer)
        self.gameMsgLayer:setVisible(false)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end
function TemplateGameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function TemplateGameScene:sendFaceByIdx(id)
    print("sendFaceMsg --------------------------", id)
    TemplateSendHandle:CLI_MSG_FACE(id)
end
function TemplateGameScene:showGameSetting()
    self:loadMoreFuncLayer()
    self:setGameSetting()
end
function TemplateGameScene:setGameSetting()
    local data = {}
    data.disbandRoomHandler = function(sender,event)
        --触摸开始
        self:disbandGroup()
    end
    data.quitRoomHandler = function(sender,event)
        require("hall.GameCommon"):showSettings(false)
        TemplateSendHandle:quitRoom()
    end
    self.moreFuncLayer._quitRoom = data.quitRoomHandler
    self.moreFuncLayer._disbandRoom = data.disbandRoomHandler
end
function TemplateGameScene:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(self.moreFuncLayer, 15)
        -- g_roomCommonLayer = self.moreFuncLayer
    else
        --if 0 == SCENENOW["scene"].GameRound then
        --    self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        --else
            self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        --end
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end

    if g_isWatch == 0 then
        self.moreFuncLayer:set_btnDisbandRoom_visible(false)
    end
end

return  TemplateGameScene