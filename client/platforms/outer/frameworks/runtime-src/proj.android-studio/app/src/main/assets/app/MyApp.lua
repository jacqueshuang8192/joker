local MyApp = class("MyApp")
function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    collectgarbage("collect")
    USER_INFO  = {}
    SCENENOW   = {}
    SCENE={}
    bm = {}
    TABLE={}
    WinSize=cc.Director:getInstance():getWinSize()
    if device.platform ~= "windows" then
        CONFIG_WIN_WIDTH = WinSize.width
        CONFIG_WIN_HEIGHT = WinSize.height
    end
    print(string.format("MyApp:run() --------------------win_w = %d, win_h = %d", CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT))
    display_scene("app.scenes.MainScene")
end

function display_scene(name, flag)
    local scene = SCENE[name]
    if not scene or flag == 1 then
        scene = require(name).new()
    end
    SCENENOW["scene"] = scene
    SCENENOW["name"] = name
    display.replaceScene(scene)
end

return MyApp
