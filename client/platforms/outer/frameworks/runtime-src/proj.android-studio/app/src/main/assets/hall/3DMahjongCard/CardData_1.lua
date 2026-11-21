local DCardData = class("DCardData")
--[[
	@type: 癞子普通牌的顺序
]]
function DCardData:ctor(this, value, orderSeq, type, fromplayerType,anP)
	self.m_value = value
	self.orderSeq = orderSeq
	self.type = type
	self.fromplayerType = fromplayerType or 0
	self.anP = anP or false
end

return DCardData