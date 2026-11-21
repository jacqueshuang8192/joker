--[[
* author:   zwm
* date:     2018-12-09
* describe: 作弊界面Item
--]]

local cheatCardItemCsb = TpackageName.."/res/layout/cheatCardCell.csb"
local pai_path = TpackageName.."/res/images/pokercard/"

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)

    return value
end

local CheatCardItem = class("CheatCardItem", function ()
	return cc.CSLoader:createNode(cheatCardItemCsb)
end)

function CheatCardItem:ctor(cards)
	self:initValidNode()
	self:setCardsValue(cards)
end

function CheatCardItem:initValidNode()
	for i = 1, 13 do
		self["card"..i] = self:getChildByName("card_"..tostring(i))
		print("initValidNode ---------------", self["card"..i] == nil)
		-- self["card"..i]:onClick(handler(self, self.onClickCard))
	end
end

function CheatCardItem:onClickCard( sender )
	if sender == nil then return end

	if sender.bSelect then
		sender.bSelect = false
		sender:getChildByName("maskImg"):setVisible(false)
		for i, v in ipairs(gCheatCardLayer.selectedCard) do
			if v == sender.cardValue then
				table.remove(gCheatCardLayer.selectedCard, i)
				break
			end
		end
		
	else
		if #gCheatCardLayer.selectedCard >= 9 then -- 手牌个数最多为9
			require("hall.GameTips"):showTips("提示", "", 3, "最多可选择9个可替换的牌")
			return
		end
		sender.bSelect = true
		sender:getChildByName("maskImg"):setVisible(true)
		table.insert(gCheatCardLayer.selectedCard, sender.cardValue)
	end
end

function CheatCardItem:setCardsValue( cards )
	for i = 1, 13 do
		if cards[i] ~= nil then
			self["card"..tostring(i)].cardValue = cards[i]
			self["card"..tostring(i)].bSelect = false
			local path = self:getCardPathByValue(cards[i])
			self:changeImgByPath(self["card"..tostring(i)]:getChildByName("cardImg"), path)
		else
			self["card"..i]:setVisible(false)
		end
	end
end

function CheatCardItem:getCardPathByValue( v )
	local result = ""
	local cardVariety = getVariety(v or 1)
	local cardValue = getValue(v or 1)
	if cardVariety == VARIETY_DIAMOND then -- 方块
		result = pai_path .. "lord_card_diamond_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_CLUB then-- 梅花
		result = pai_path .. "lord_card_heart_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_HEART then-- 红桃
		result = pai_path .. "lord_card_spade_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_SPADE then-- 黑桃
		result = pai_path .. "lord_card_club_" .. string.format("%d", cardValue) .. ".png"
	end
	return result
end


function CheatCardItem:changeImgByPath(sp, path)
	local cache = cc.Director:getInstance():getTextureCache():addImage(path)
	print("path =-0--------------------------", path)
	sp:setTexture(cache)
end

return CheatCardItem