
import(".utils.init")
import(".functions")
GameUtils = import(".GameUtils")
require("cocos.framework.extends.UIWidget")
ViewBase = import(".utils.viewBase")
require("cocos.framework.package_support")
cc.register("event", require("cocos.framework.components.event"))
cc.register("scheduler", require("hall.tool.scheduler"))
NewViewBaseLayer = import("hall.NewViewBaseLayer")
viewMgr = import(".viewManager")
import(".utils.ccs")

DEFAULT_FONT_NAME = "fonts/FZY3JW.ttf" --默认字体
DEFAULT_FONT_SIZE = 22
DEFAULT_BUTTON_COLOR = cc.c3b(251, 255, 255)

if device.platform == "windows" then
    import(".test")
  
    local fs = require("hall.tool.utils.fs")
    function debugGeloadPath(path)
        if fs.isfile(path) then
            reloadFile(path)
        elseif fs.isdir(path) then
            local dirs, files = fs.list(path)
            local size = #files
            for i,v in ipairs(files) do
                reloadFile(v)
            end
        end
    end
   
    function reloadPath (path)
        if package.loaded[path] then
            print("reloadPath:", path)
            package.loaded[path] = nil
        end
    end
    function reloadFile (file)
        local isLua = string.find(file, ".lua", -5) --".lua结尾"
        if not isLua then
            return
        end
        local reloadAll = function(file)
            local t = file --a/b/c/xxx.lua
            reloadPath(t)
            t = string.gsub(file, "/", ".") --a.b.c.xxx.lua
            reloadPath(t)
            t = string.sub(file, 1, -5) -- a/b/c/xxx
            reloadPath(t)
            t = string.gsub(t, "/", ".") -- a.b.c.xxx
            reloadPath(t)
        end
        local systemPaths = cc.FileUtils:getInstance():getSearchPaths()
        for i, p in ipairs(systemPaths) do
            p = string.gsub(p, "\\", "/")
            p = string.gsub(p, "\\\\", "/")
            p = string.gsub(p, "//", "/")
            local s = cc.FileUtils:getInstance():fullPathForFilename(file)
            s = string.gsub(s, "\\", "/")
            s = string.gsub(s, "\\\\", "/")
            s = string.gsub(s, "//", "/")
            local sPath = string.gsub(s, p, "")
            sPath = string.gsub(sPath, "//", "/")
            local path = string.gsub(sPath, "/", ".")
            path = string.sub(path, 1, -5)
            reloadPath(path)
        end
    end

    local keypadListener = cc.EventListenerKeyboard:create()
    keypadListener:registerScriptHandler(function(keyCode)
        if keyCode == cc.KeyCode.KEY_F8 then
            local test = require("hall.tool.test")
            test:debugTool()
        elseif keyCode == cc.KeyCode.KEY_F9 then
            debugGeloadPath("hall")
            debugGeloadPath("shisanzhang")
            debugGeloadPath("sangong")
            debugGeloadPath("niuniu")
            -- debugGeloadPath("src")
            debugGeloadPath("zz_majiang_old_3d")
            --if TpackageName then debugGeloadPath(TpackageName.."/test.lua") end
            if TpackageName then debugGeloadPath(TpackageName) end
        elseif keyCode == cc.KeyCode.KEY_F10 then
            local test = require("hall.tool.test")
            test:close()
        elseif keyCode == cc.KeyCode.KEY_F11 then
            local test = require("hall.tool.test")
            test:KEY_F11()
        elseif keyCode == cc.KeyCode.KEY_F7 then
            local test = require("hall.tool.test")
            test:KEY_F7()
        elseif keyCode == cc.KeyCode.KEY_F12 then
            local test = require("hall.tool.test")
            test:KEY_F12()
        elseif keyCode == cc.KeyCode.KEY_F6 then
            cc.UserDefault:getInstance():setIntegerForKey("uid", UID)
            cc.UserDefault:getInstance():setStringForKey("url", HttpAddr)
            local content = "return 0"
            fs.write("count.lua", content)
        end
    end, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithFixedPriority(keypadListener, -1)
end
