
--加载大厅更新类
local HallUpdate = require("app.HallUpdate")

--实例化初始界面
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

--初始界面初始化
function MainScene:ctor()
    self:initData()
end

--设置是否弹出错误面板
local isShowErrorPanle=false
function MainScene:initData()

    local function SplitInterFace(word)
        local begin_index , end_index = string.find(word , "http://")
        local second_index , second_end = string.find(word , "/h")
        local result_word = string.sub(word , begin_index , end_index)
        local last_word = string.sub(word , end_index + 1 , second_index - 1)
        local boss_word = string.sub(word , second_index)
        local inter_word = result_word .. last_word .. ":35655" .. boss_word
        return inter_word
    end 

    --获取接口链接
    if device.platform ~= "windows" then
        local sigs = "Ljava/lang/String;"
        HttpAddr = cct.getDateForApp("getHttpAddr",{},sigs)
        HttpInterFace = SplitInterFace(HttpAddr)
    end

    --新建定时器池
    bm.SchedulerPool = import("socket.SchedulerPool").new()
    
end

function MainScene:onEnter()

    if device.platform ~= "windows" then
        --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_DESIGN_WIDTH, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.FIXED_HEIGHT)--cc.ResolutionPolicy.SHOW_ALL//FIXED_WIDTH
        local scaleY=CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH/scaleY, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc.ResolutionPolicy.SHOW_ALL
        --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_DESIGN_WIDTH, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.EXACT_FIT)--cc.ResolutionPolicy.SHOW_ALL
        print("MainScene:onEnter() ----------------------------", CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
    else
        local scaleY=CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
        cc.Director:getInstance():getOpenGLView():setFrameSize(CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH/scaleY, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc.ResolutionPolicy.SHOW_ALL
    end
    --local scaleY=CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
    --cc.Director:getInstance():getOpenGLView():setFrameSize(CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH/scaleY, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc.ResolutionPolicy.SHOW_ALL
    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_DESIGN_WIDTH, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.FIXED_HEIGHT)--cc.ResolutionPolicy.SHOW_ALL//FIXED_WIDTH
    --cc.Director:getInstance():getOpenGLView():setFrameSize(CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc.ResolutionPolicy.SHOW_ALL
    print("MainScene:onEnter")

    HallUpdate:landLoading(true)

    --记录游戏是否需要更新
    if device.platform == "windows" then
        needUpdate = false
    else
        needUpdate = true
    end

    --记录大厅是否需要更新
    if device.platform == "windows" then

        --windows平台大厅不需要检查更新
        hallNeedUpdate = false

    elseif device.platform == "ios" then

        local sigs = "Ljava/lang/String;"
        local ios_hallNeedUpdate = cct.getDateForApp("getIsHallNeedUpdate",{},sigs)
        self:getAppData(ios_hallNeedUpdate)

    else

        --其他平台，大厅都需要检查更新
        hallNeedUpdate = true

    end

    if not hallNeedUpdate then

        --进入大厅
        -- display_scene("hall.hallScene", 1)
        display_scene("hall/hallScene",1)
    else

        --检查大厅更新
        HallUpdate:showLoadingTips("检查大厅更新")
        HallUpdate:queryVersion(2)

    end
 
end

function MainScene:getAppData(data)

    if data == "1" then
        
        --需要时，大厅和游戏都需要检查更新
        hallNeedUpdate = true
        needUpdate = true

    elseif data == "2" then

        local action = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
            
            --iOS平台从本地获取是否需要更新大厅
            local sigs = "Ljava/lang/String;"
            local ios_hallNeedUpdate = cct.getDateForApp("getIsHallNeedUpdate",{},sigs)
            self:getAppData(ios_hallNeedUpdate)

        end))
        SCENENOW["scene"]:runAction(action)

    else

        --不需要时，大厅和游戏都不需要检查更新
        hallNeedUpdate = false
        needUpdate = false

    end

end


return MainScene
