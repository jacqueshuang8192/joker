local CardConfig = require("yuanjiangguihz.logic.CardConfig")
local PHZResultCardCell = class("PHZResultCardCell", function ()
   return cc.CSLoader:createNode("yuanjiangguihz/res/PHZResultCardCell.csb")
end)

PHZResultCardCell.Card_NUM = 4

function PHZResultCardCell:ctor(data)
	self.data = data
	self.IsYinYing = self:isSetYinYing()
	-- print("==显示玩家打过得牌==")
	-- dump(self.data)
	-- print("==显示玩家打过得牌==")
	self:setNodeEventEnabled(true)
	self.cardConfig_ = CardConfig:new()
	self.m_CardArr = {}                     --三張牌的集合
	self:initUI()
	self:refreshCardImg()
end

function PHZResultCardCell:isSetYinYing()
	local tempISYinYing = false
	if self.data.cbComfrom == 1 and self.data.type == g_379.t_wai then
		tempISYinYing = true
	end
	return tempISYinYing
end

function PHZResultCardCell:onEnter()

end

function PHZResultCardCell:onExit()

end

function PHZResultCardCell:initUI()
	for i=1,PHZResultCardCell.Card_NUM do
		self.m_CardArr[i] = self:getChildByName("Card_"..i)
	end
end

function PHZResultCardCell:refreshCardImg()
	print("====7777777777====")
	local cardCount = #self.data.cardList
	for k,v in pairs(self.m_CardArr) do
		if k > cardCount then
			print("=====88888888888=====")
			v:setVisible(false)
		else
			v:setVisible(true)
			if not self.data.cardList or not self.data.cardList[k] then return  print("===数据不存在==") end
			local cardInfo = self.cardConfig_:getCardInfoByid(self.data.cardList[k])
		    if cardInfo then
		    	local imgPath = string.format("%s.png",cardInfo.CardIconA)
			    local frame = display.newSpriteFrame(imgPath)
			    v:setSpriteFrame(frame)
			    if self.IsYinYing then
			    	v:setColor(cc.c3b(175,175,175))
			    end

			else
				print("-----this is error!!!----refresh")
		    end
		end
	end
end


return PHZResultCardCell