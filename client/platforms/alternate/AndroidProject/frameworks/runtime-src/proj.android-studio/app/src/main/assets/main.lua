cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath())
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("trunk/")
cc.FileUtils:getInstance():addSearchPath("app/")
cc.FileUtils:getInstance():setPopupNotify(false)

require("config")
require("cocos.init")
require("framework.init")
require("TTLuaHelps")

__G__TRACKBACK__MAIN = function(msg)
    local msg = debug.traceback(msg, 1)
    print(msg);

    if _G.display_scene and not isShowErrorScene then
        display_scene("app.scenes.MainScene")
    else
        cct.runErrorScene(msg)
    end
    
    return msg
end

__G__TRACKBACK__=__G__TRACKBACK__MAIN

local function main()
    require("app.MyApp"):run()
end

local status, msg = xpcall(main, __G__TRACKBACK__MAIN)
if not status then
    print(msg)
end