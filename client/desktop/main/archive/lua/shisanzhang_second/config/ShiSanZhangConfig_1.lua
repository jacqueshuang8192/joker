local ShiSanZhangConfig = class("ShiSanZhangConfig")
local Version = require(TpackageName..".config.Version")

ShiSanZhangConfig.version = Version--改这个
ShiSanZhangConfig.version_1 = 0--version_1旧版 自己的
ShiSanZhangConfig.version_2 = 1--version_2新版 定制的
local configTal = {
    [ShiSanZhangConfig.version_1] = {--version_1旧版 自己的
        scene_bg_path = TpackageName.."/res/layout/roomScene/bg_3.png",
        MatchCardView_bg = "",
        TpackageName = "shisanzhang",
        
        action = {
            setTeShuAnim = {
                name = "shisanshui_donghua",
                path = TpackageName .. "/res/layout/roomScene/action/shisanshui_donghua",
            },
            setToShot = {
                name = "shisanshui_qiangyang",
                path = TpackageName .. "/res/layout/roomScene/action/shisanshui_qiangyang",
            },
            creatorShotAnimNode = {
                name = "shisanshui_daqiang",
                path = TpackageName .. "/res/layout/roomScene/action/shisanshui_daqiang",
            },
        }
    },

    [ShiSanZhangConfig.version_2] = {--version_2新版 定制的
        scene_bg_path = TpackageName.."/res/layout/roomScene/bg_1.png",
        MatchCardView_bg = TpackageName.."/res/layout/MatchCardView/bg_1.jpg",
        TpackageName = "shisanzhang_second",

        action = {
            setTeShuAnim = {
                name = "shisanshui",
                path = TpackageName .. "/res/layout/roomScene/newAction/shisanshui",
            },
            setToShot = {
                name = "dankong",
                path = TpackageName .. "/res/layout/roomScene/newAction/dankong",
            },
            creatorShotAnimNode = {
                name = "qiang",
                path = TpackageName .. "/res/layout/roomScene/newAction/qiang",
            },
        }
    }, 
}

function ShiSanZhangConfig:getShiSanZhangConfig()
    local conf = configTal[ShiSanZhangConfig.version]
    -- local version = ShiSanZhangConfig.version
    -- if version == 0 then
    --     conf = configTal.version_1
    -- else
    --     conf = configTal.version_2
    -- end
    return conf
end

function ShiSanZhangConfig:getVersion()
    return ShiSanZhangConfig.version == ShiSanZhangConfig.version_2
end

ShiSanZhangConfig.config = ShiSanZhangConfig:getShiSanZhangConfig()
return ShiSanZhangConfig