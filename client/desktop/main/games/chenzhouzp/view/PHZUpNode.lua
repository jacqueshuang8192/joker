local PHZUpNode = class("PHZUpNode", function ()
   return cc.CSLoader:createNode("chenzhouzp/res/PHZUpNode.csb")
end)

function PHZUpNode:ctor()
	self:setNodeEventEnabled(false)
	self.m_cardNum = 0
	self:initUI()
end

function PHZUpNode:onEnter()
end

function PHZUpNode:onExit()
end

function PHZUpNode:initUI()
	self.txt_dicardnum = self:getChildByName("txt_dicardnum")
	self:setDicardNum(0)
    self:playBackgroundMusic()

end

function PHZUpNode:playBackgroundMusic()
    local MusicNum = 6
    local index = math.random(5, MusicNum)
    local bgmPath = "hall/scene/res/common/music/gameBGM_"..index..".mp3"
    audio.playMusic(bgmPath,true)
end

function PHZUpNode:clearData()
	self:setDicardNum(0)
end

function PHZUpNode:setDicardNum(data)
	self.m_cardNum = data
	self.txt_dicardnum:setString(data)
end
-- function PHZUpNode:getAllCardNum()
	-- return self.m_cardNum
-- end
return PHZUpNode