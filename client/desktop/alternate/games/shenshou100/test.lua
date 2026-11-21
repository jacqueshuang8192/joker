
local Test = class("Test")

function Test:debugTool()
    
    self.gameScene = require("shenshou100.gameScene").new():addTo(SCENENOW.scene,999999999):setName("test")
    self.GameSceneView = self.gameScene.GameSceneView
    self.ReceiveHandle = SCENENOW.scene.ReceiveHandle
    local Scene = SCENENOW.scene
    self.GameSceneView:playerXZ(100006, 2, 1)
    self.GameSceneView:playerXZ(100006, 2, 2)
    self.GameSceneView:playerXZ(100006, 2, 3)
    self.GameSceneView:playerXZ(100006, 2, 4)
    self.GameSceneView:setTZXZ(5, 1, 10, 2, 6)
    self.GameSceneView:setTZXZ(5, 1, 10, 2, 6, true)
    dump(g_102.allUser)
end

function Test:KEY_F11()

    local data = {0,1,0,1}
    self.GameSceneView:setGameResult( data )
    self.GameSceneView:actionAllChip({}, 2)
    dump(g_102.settlementData)
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