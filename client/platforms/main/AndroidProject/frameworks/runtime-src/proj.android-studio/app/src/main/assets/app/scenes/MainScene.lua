local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local isShowErrorPanle=false

function MainScene:ctor()
    self:initData()
end

function MainScene:initData()
    bm.SchedulerPool = import("socket.SchedulerPool").new()
end

function MainScene:onEnter()
    if device.platform ~= "windows" then
        local scaleY=CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH/scaleY, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)
        print("MainScene:onEnter() ----------------------------", CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
    else
        local scaleY=CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
        cc.Director:getInstance():getOpenGLView():setFrameSize(CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH/scaleY, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)
    end
    print("MainScene:onEnter")

    needUpdate = false
    hallNeedUpdate = false

    display_scene("hall.hallScene", 1)
end

return MainScene