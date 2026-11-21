local files = cc.FileUtils:getInstance()
files:addSearchPath(files:getWritablePath())
files:addSearchPath("src/")
files:addSearchPath("res/")
files:addSearchPath("trunk/")
files:addSearchPath("app/")
files:setPopupNotify(false)

require("config")
require("cocos.init")
require("framework.init")
require("TTLuaHelps")

__G__TRACKBACK__MAIN = function(msg)
    local trace = debug.traceback(msg, 1)
    print(trace)

    if _G.display_scene and not isShowErrorScene then
        display_scene("app.scenes.MainScene")
    else
        cct.runErrorScene(trace)
    end
    
    return trace
end

__G__TRACKBACK__=__G__TRACKBACK__MAIN

local function main()
    require("app.MyApp"):run()
end

local status, msg = xpcall(main, __G__TRACKBACK__MAIN)
if not status then
    print(msg)
end


