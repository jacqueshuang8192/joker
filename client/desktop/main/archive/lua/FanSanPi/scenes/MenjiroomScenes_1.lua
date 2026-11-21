local MenjiroomView   = import("FanSanPi.view.MenjiroomView")

local MenjiroomScenes = class("MenjiroomScenes", function()
    return display.newScene("MenjiroomScenes")
end)

function MenjiroomScenes:ctor()
	ZhaJinHuaControl  = MenjiroomView:new():addTo(self)

	display.addSpriteFrames("FanSanPi/res/common_texture.plist", "FanSanPi/res/common_texture.png")
	display.addSpriteFrames("FanSanPi/res/NewImg/card/Plist.plist", "FanSanPi/res/NewImg/card/Plist.png")


    display.addSpriteFrames("FanSanPi/res/room/animation/headWinNew.plist", "FanSanPi/res/room/animation/headWinNew.png")

    display.addSpriteFrames("FanSanPi/res/room/compareCard/winner.plist", "FanSanPi/res/room/compareCard/winner.png")
    display.addSpriteFrames("FanSanPi/res/room/compareCard/boom.plist", "FanSanPi/res/room/compareCard/boom.png")
    display.addSpriteFrames("FanSanPi/res/room/compareCard/allCompare.plist", "FanSanPi/res/room/compareCard/allCompare.png")

end

function MenjiroomScenes:onEnter()

end
function MenjiroomScenes:reConnect()
    dump("MenjiroomScenes:reConnect")
    require("FanSanPi.FanSanPiServer"):enterRoom()
end
function MenjiroomScenes:onExit()
    print('onExit-MenjiroomScenes')
	g_isWatch = nil
    --print(type(FanSanPiPanel))
end
return MenjiroomScenes