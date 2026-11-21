
local Test = class("Test")

function Test:debugTool()
    
    -- self.gameScene = require("longhu100.gameScene").new():addTo(SCENENOW.scene,999999999):setName("test")
    
    -- self.ReceiveHandle = SCENENOW.scene.ReceiveHandle

    self.GameSceneView = SCENENOW.scene.GameSceneView
    -- local Scene = SCENENOW.scene
    -- dump(g_101.allUser)

    self.GameSceneView:setGameResult(1)
end

function Test:KEY_F11()
    -- self.HandCardView:clearData()

    -- SCENENOW["scene"]:getChildByName("SettlementView"):removeSelf()
   
    dump(g_101.settlementData)
end

function Test:KEY_F7()
    self.HandCardView:setCurHandCards({
        0x01,0x01,0x01,0x11,0x11,0x02,0x02,0x02,0x02,0x02, --一、二
        0x03,0x03,0x03,0x13,0x13,0x04,0x04,0x04,0x04,0x04, --三、四
        0x05,0x05,0x05,0x15,0x15,0x06,0x06,0x06,0x06,0x06, --五、六
    })
end

function Test:close()
    self.gameScene:removeSelf()
end
function Test:KEY_F12()
end

return Test