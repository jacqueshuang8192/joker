
local PROTOCOL -- = require("zhajinhua_jb.Zhajinhua_Protocol")

local zjhServer --= import("zhajinhua_jb.ZhajinHuaServer")
local zjhHandle -- = require("zhajinhua_jb.ZjhHandle")

local gameScene = class("gameScene", function()
    return display.newScene("gameScene")
end)


function gameScene:ctor()
    dump("gameScene:ctor()")
    GROUP_MODE = 2
    PROTOCOL = require("zhajinhua_jb.Zhajinhua_Protocol")
    zjhServer = import("zhajinhua_jb.ZhajinHuaServer")
    zjhHandle  = require("zhajinhua_jb.ZjhHandle")
    CLUB_ID = nil
    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(zjhHandle.new())
    countUserAllin = 0
    GAME_NAME = "拼三张"
    TpackageName = "zhajinhua_jb"
    isChoicCard = false
    --ZhaJinHuaPanel = nil

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
    IS_RANKING  = true
    RESULT_RANKING = nil
    dump(USER_INFO["player_nums"],"player_nums-----------------=")
    TOTAL_PLAYERNUM =  USER_INFO["player_nums"]
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
    ZhaJinHuaPosition ={
        [0] = {
            ['x'] = 333.45,
            ['y'] = 70.70,
        },
        [1] = {
            ['x'] = 218.30,
            ['y'] = 67.71,

        },
        [2] = {
            ['x'] = 218.30,
            ['y'] = 67.71,

        },
        [3] = {
            ['x'] = 218.30,
            ['y'] = 67.71,

        },
        [4] = {
            ['x'] = 218.30,
            ['y'] = 67.71,
        },
        [5] = {
            ['x'] = 218.30,
            ['y'] = 67.71,
        },
        [6] = {
            ['x'] = -86.63,
            ['y'] = 67.71,

        },
        [7] = {
            ['x'] = -86.63,
            ['y'] = 67.71,
        },
        [8] = {
            ['x'] = -86.63,
            ['y'] = 67.71,
        },
        [9] = {
            ['x'] = -86.63,
            ['y'] = 67.71,
        }
    }
end

function gameScene:onExit()
    print('onExit-gameScene')
    print(type(ZhaJinHuaPanel))

end

function gameScene:onEnter()

    --require("hall.GameCommon"):landLoading(true)
    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    -- audio.preloadMusic("zhajinhua_jb/res/audio/game_back.mp3")
    -- require("hall.GameCommon"):playEffectMusic("zhajinhua_jb/res/audio/game_back.mp3",true)
    -- require("hall.GameCommon"):playEffectMusic(HallBgm_filePath, true)

    --local mode = require("hall.gameSettings"):getGameMode()
    --if mode == "free" then
    --    local adapLevel = require("hall.hall_data"):getAdapterLevel("ddz")
    --    if adapLevel < 0 then
    --        require("hall.GameTips"):showTips("余额不足，请充值","change_money",1)
    --        return
    --    end
    --    USER_INFO["gameLevel"] = adapLevel
    --end
    local sound_path = "zhajinhua_jb/sounds/bgm.mp3"
    cc.SimpleAudioEngine:getInstance():playMusic(sound_path,true)
    display_scene("zhajinhua_jb.view.MenjiroomView", 1)
    zjhServer:enterRoom()
    -- end
    -- SoundUtils:playBackgroundMusic()
end


function gameScene:getPosforSeat(uid)
    return cc.p(1000,1000)
end

return gameScene
