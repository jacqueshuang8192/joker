-- GAME_WSS_URL = "wss://game.example.com"  -- 启用游戏网关时取消注释，填写自己的域名。
-- 测试 Java 牛牛时设为 true，原生牛牛使用 false。
JAVA_DOUNIU = false

function resolveGameApiAddress(nativeAddress)
    if type(nativeAddress) == "string" and nativeAddress:match("^https?://") then
        return nativeAddress
    end
    return HttpAddr
end

-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- display FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"
-- design resolution
CONFIG_SCREEN_WIDTH  = 1280
CONFIG_SCREEN_HEIGHT = 720

-- self design resolution
CONFIG_DESIGN_WIDTH  = 1280
CONFIG_DESIGN_HEIGHT = 720

-- win resolution
--CONFIG_WIN_WIDTH  = 2340
--CONFIG_WIN_HEIGHT = 1080

-- win resolution
CONFIG_WIN_WIDTH  = 1280
CONFIG_WIN_HEIGHT = 720


--[[CONFIG_WIN_WIDTH  = 2280
CONFIG_WIN_HEIGHT = 1080--]]
--
--[[
CONFIG_WIN_WIDTH  = 1920
CONFIG_WIN_HEIGHT = 1080--]]


-- CONFIG_WIN_WIDTH  = 2280
-- CONFIG_WIN_WIDTH  = 2340
-- CONFIG_WIN_HEIGHT = 1080 
-- CONFIG_WIN_WIDTH  = 1792
-- CONFIG_WIN_HEIGHT = 828


-- 1792×828
-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"



urlUpdate = "38.12.31.236:8080/gameUpdate"



HttpAddr = "http://38.12.31.236:8232/hbiInterface"  --你的服务器


isVerify = false
needUpdate = true

ios_class="CocosCaller"

android_class="org/cocos2dx/lib/CocosCaller"

luaJniClass="org/cocos2dx/lib/CocosCaller"
confilg_manager = nil

isShowErrorScene = true

isShowNetLog = false

showDumpData = true


