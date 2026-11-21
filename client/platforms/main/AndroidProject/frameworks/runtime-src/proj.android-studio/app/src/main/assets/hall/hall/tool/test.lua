local Test = class("Test")

function Test:debugTool()


    -- TpackageName = "shisanzhang_new"
    -- DESIGN_SCREEN_WIDTH  = 1920
    -- DESIGN_SCREEN_HEIGHT = 1080
    -- SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    -- SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    -- local size = SCENENOW["scene"]:getContentSize()
    -- dump(size)
    -- -- 0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x01,   --方块
    -- -- 0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x11,   --樱花
    -- -- 0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x21,   --红桃
    -- -- 0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x31,   --黑桃
    -- self._cards = {
    --     0x4E,0x38,0x08,0x18,0x09,
    --     0x37,0x17,0x05,0x15,0x22,
    --     -- 0x4E,0x4f,0x4f,
    --     0x2B,0x3D,0x31
    -- }
    -- self.shisanzhang = require(TpackageName..".view.MatchCardView").new()
    -- self.shisanzhang:setDataCards(self._cards,1)
    -- self.shisanzhang._csbNode:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
    -- self.shisanzhang:setName("MatchCardView")
    -- SCENENOW["scene"]:addChild(self.shisanzhang,999999999)
	--require("hall.GameCommon"):playEffectSound("pengpengzp/res/sound/101B.mp3")
	-- TpackageName = "cdpaohuzi"
	--local PHZResultLayer = require(TpackageName..".view.PHZResultLayer").new()
	--SCENENOW["scene"]:addChild(PHZResultLayer,999999999)
   
	-- self.test = require(TpackageName..".test")
	-- self.test:debugTool()
	
	--dofile("PHZ_Ting.lua")
    dump(g_hallMainLayer.familyMainlayer.config_id)
    dump(g_hallMainLayer.familyMainlayer.checkGameType)
    dump(g_hallMainLayer.familyMainlayer.table_datas)
    dump(g_hallMainLayer.familyMainlayer.tableIds)
    dump(g_hallMainLayer.familyMainlayer.tableDatas)
    dump(g_hallMainLayer.familyMainlayer.dt_beginTime)
    dump(g_hallMainLayer.familyMainlayer.dt_intervalTime)
    dump(g_hallMainLayer.familyMainlayer.dt_idx)
    dump("aaaaaaaaaaaaaaaaaaaaa")
end

function Test:close()
    local tab = {
        "niuniu_zhuang_1", 
        "dingzhuang", 
        "OutCardMgr",
        "CardBackMgr",
        "MatchCardView",
    }
    for i,name in ipairs(tab) do
        local armatureObj =  SCENENOW["scene"]:getChildByName(name)
        if armatureObj then
            if armatureObj.getAnimation then
                local Animation = armatureObj:getAnimation()
                Animation:gotoAndPause(0)  
            end
            armatureObj:stopAllActions()  
            armatureObj:removeFromParent()
        end
    end

    dump(collectgarbage("count"))
end

function Test:KEY_F11()
   self.test:KEY_F11()

end

function Test:KEY_F12()
    local sendHandle = require(TpackageName..".handle.ZZMJSendHandle")
    sendHandle:CLI_REQ_TEST_CARDS()
end
return Test