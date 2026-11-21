
local PROTOCOL = require("FanSanPi.FanSanPiProtocol")

local FSPServer = import("FanSanPi.FanSanPiServer") --zjhServer  --FanSanPiServer
local FSPHandle = require("FanSanPi.FanSanPiHandle") -- ZjhHandle

local gameScene = class("gameScene", function()
    return display.newScene("gameScene")
end)


function gameScene:ctor()
    dump("gameScene:ctor()")
    GROUP_MODE = 2
    CLUB_ID = nil
    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(FSPHandle.new())
    countUserAllin = 0
    GAME_NAME = "拼三张"
    TpackageName = "FanSanPi"
    isChoicCard = false
    --FanSanPiPanel = nil

    bm.Room = {}
    bm.User = {}
    bm.User.isDisplay = 0
    ZJH_USER_UID  = {}
    ZJH_USER_SEAT  = {}
    ALLIN_CHIPS = {}
    COMPARE_LIST = {}
    IS_ALLIN_CHIP = 0
    MY_SEAT_ID = -1
    ZJH_PLAYERTYPE_TABLE = {}  --
    ZJH_USER_UID_PLAYING = {}  -- 用户是否在玩
    ZJH_TABLE_CHIPS  = {}  --桌子筹码
    ZJH_USER_TOTAL_CHIPS = {} --用户总金额
    GAME_STATUS_STOP = 0
    GAME_STATUS_OUTCARD =1
    ZJH_USERINFO_TABLE={}
    ZJH_USER_ONLINE = {}
    FSP_USER_UID_CARDS = {}
    IS_RANKING  = true
    RESULT_RANKING = nil
    dump(USER_INFO["player_nums"],"player_nums-----------------=")
    TOTAL_PLAYERNUM =  6--USER_INFO["player_nums"]
    PLAYERNUM = 0    --当前在玩的游戏人数
    DESIGN_SCREEN_WIDTH  = 1920
    DESIGN_SCREEN_HEIGHT = 1080
    SCREEN_WIDTH = 1280  --屏幕尺寸
    SCREEN_HEIGHT = 720
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    SoundUtils = import(TpackageName .. ".SoundUtils")
    bm.User.Cards     = {}
    bm.User.isKan     = {} --玩家是否看牌
    bm.User.isDiu     = {} --玩家是否弃牌
    bm.Room.anim      = 0
    bm.Room.chips     = {}
    bm.Room.over      = true
    bm.Room.all_compare = 0
    bm.Room.result = nil
    bm.Room.init_chips = 0
    bm.Room.banker = nil
    bm.Room.zhus      = {}
    bm.Room.show_card = 0
    bm.Room.show_cards = {}
    ZJH_USER_UID_PLAYING = {}
    
    
end

function gameScene:onExit()
    print('onExit-gameScene')
    print(type(FanSanPiPanel))

end

function gameScene:onEnter()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    -- audio.playMusic(HallBgm_filePath, true)
    --播放背景音乐
    SoundUtils:playBackgroundMusic()
    display_scene("FanSanPi.view.MenjiroomView", 1)
    FSPServer:enterRoom()
end


function gameScene:getPosforSeat(uid)
    return cc.p(1000,1000)
end

return gameScene
