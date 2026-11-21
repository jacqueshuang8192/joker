local MenjiroomView   = import("zhajinhua_jb.view.MenjiroomView")

local MenjiroomScenes = class("MenjiroomScenes", function()
    return display.newScene("MenjiroomScenes")
end)

function MenjiroomScenes:ctor()
	ZhaJinHuaControl  = MenjiroomView:new():addTo(self)

	display.addSpriteFrames("zhajinhua_jb/res/common_texture.plist", "zhajinhua_jb/res/common_texture.png")
	display.addSpriteFrames("zhajinhua_jb/res/NewImg/card/Plist.plist", "zhajinhua_jb/res/NewImg/card/Plist.png")


    display.addSpriteFrames("zhajinhua_jb/res/room/animation/headWinNew.plist", "zhajinhua_jb/res/room/animation/headWinNew.png")

    display.addSpriteFrames("zhajinhua_jb/res/room/compareCard/winner.plist", "zhajinhua_jb/res/room/compareCard/winner.png")
    display.addSpriteFrames("zhajinhua_jb/res/room/compareCard/boom.plist", "zhajinhua_jb/res/room/compareCard/boom.png")
    display.addSpriteFrames("zhajinhua_jb/res/room/compareCard/allCompare.plist", "zhajinhua_jb/res/room/compareCard/allCompare.png")

end

function MenjiroomScenes:onEnter()

end
function MenjiroomScenes:reConnect()
    dump("MenjiroomScenes:reConnect")
    require("zhajinhua_jb.ZhajinHuaServer"):enterRoom()
end
function MenjiroomScenes:onExit()
    print('onExit-MenjiroomScenes')
	g_isWatch = nil
    --print(type(ZhaJinHuaPanel))
end
return MenjiroomScenes