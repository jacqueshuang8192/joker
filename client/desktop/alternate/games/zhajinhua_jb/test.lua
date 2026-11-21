
local Test = class("Test")

function Test:debugTool()
    
    -- require("zhajinhua_jb.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["cmd"]         = 20736,
        ["game_amount"] = 8,
        ["playercount"] = 2,
        ["playerlist"] = {
            [1] = {
                ["nickName"]   = "柠檬我不萌",
                ["portrait"]   = "http://thirdwx.qlogo.cn/mmopen/vi_32/LGPeydxkvPFaGficfnibM0a2llcdfxeP54Znq1q0lJgInYm4qo0rapibQGdE1se9ibJvhLURur9MTaAHQH0gtf2HVA/132",
                ["sex"]        = 2,
                ["totalChips"] = 3600,
                ["uid"]        = 2438164,
            },
            [2] = {
                ["nickName"]   = "良缘",
                ["portrait"]   = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJmV9icZPicm0TEgpg1XHLOYvicAxmMhQCRvCWjJ0dykiasGP1JRdA7d0v7D2Rqw6d3QNYXedNtV6q42A/132",
                ["sex"]        = 1,
                ["totalChips"] = -3600,
                ["uid"]        = 1236741,
            },
        },
    }
    
    self.ReceiveHandle = SCENENOW.scene.ReceiveHandle
    self.GameSceneView = SCENENOW.scene.GameSceneView
    self.CardMgr = SCENENOW.scene.GameSceneView.CardMgr
    -- self.CardMgr:sendCard()
    self.ReceiveHandle:SVR_GROUP_RANKING(data)
end

function Test:KEY_F11()
end

function Test:KEY_F7()
   
end

function Test:KEY_F12()
end

return Test