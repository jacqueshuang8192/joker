cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath())
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

--cc.FileUtils:getInstance():addSearchPath("tags/hall/")
--
cc.FileUtils:getInstance():addSearchPath("trunk/")
--cc.FileUtils:getInstance():addSearchPath("E:/chubao/5.0/")
--cc.FileUtils:getInstance():addSearchPath("E:/chubao/pyqlm/")
--cc.FileUtils:getInstance():addSearchPath("E:/chubao/gzmyq/")
--cc.FileUtils:getInstance():addSearchPath("E:/newGameFX/trunk/")
cc.FileUtils:getInstance():addSearchPath("app/")--搜索路劲的配置值
cc.FileUtils:getInstance():setPopupNotify(false)
 --cc.FileUtils:getInstance():setSearchPaths(
 --{
 -- --[2] = "D:/work/hellouniverse/gameClient/branches/",
 --[1] = "E:/chubao/gzmyq/",
 --[2] = "trunk/",
 --[3] = "C:/Users/MissTian/AppData/Local/DouyouTV/",
 --[4] = "src/",
 --[5] = "res/",
 --[6] = "app/"})

--cc.FileUtils:getInstance():setPopupNotify(false)

require("config")
require("cocos.init")
require("framework.init")
require("TTLuaHelps")

__G__TRACKBACK__MAIN = function(msg)
    local msg = debug.traceback(msg, 1)
    print(msg);

    if _G.display_scene and not isShowErrorScene then
    	--todo
    	display_scene("app.scenes.MainScene")
    else
    	cct.runErrorScene(msg)
    end
    
    --
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


