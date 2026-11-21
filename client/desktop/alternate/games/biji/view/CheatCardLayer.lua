--[[
* author:   zwm
* date:     2018-12-09
* describe: 作弊界面
--]]

local cheatCardCsb = TpackageName.."/res/layout/cheatCardLayer.csb"
local pai_path = TpackageName.."/res/images/pokercard/"

local CheatCard = class("CheatCard", function ()
	return cc.CSLoader:createNode(cheatCardCsb)
end)

function CheatCard:ctor()
	self.selectedCard = {}
	self.cardLst = {0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d,
					0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d,
					0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,
					0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,
					}
	-- self.root = self:getChildByName("root")
	self:initClickEvent()
	self:showSurpCards(self.cardLst)
end

function CheatCard:initClickEvent()
	local btnClose = self:getChildByName("btnClose")
	btnClose:addTouchEventListener(handler(self, self.onClickBtn))

	local btnSure = self:getChildByName("btnSure")
	btnSure:addTouchEventListener(handler(self, self.onClickBtn))
end

function CheatCard:onClickBtn(sender, event)
	if event == TOUCH_EVENT_BEGAN then
		sender:setScale(0.95)
	elseif event == TOUCH_EVENT_ENDED then
		sender:setScale(1)
		if sender:getName() == "btnClose" then
			require("hall.GameTips"):showTips("提示", "", 1, "放弃下轮选牌", nil, handler(self, self.closeSelf))
			return
		elseif sender:getName() == "btnSure" then
			if #self.selectedCard ~= 9 then -- 需要的手牌只能为9个
				require("hall.GameTips"):showTips("提示", "", 3, "只能选择9个手牌")
			else
				self:sendSelectCards()
			end
		end
	end
end

function CheatCard:closeSelf()
	self:removeSelf()
end

function CheatCard:showSurpCards(cards)
	local baseLine = 13  -- 每行9个
	local line = math.ceil(#cards/baseLine)
	for i = 1, line do
		local tmp = {}
		for j = 1, baseLine do
			if cards[(i-1)*baseLine + j] ~= nil then
				table.insert(tmp, cards[(i-1)*baseLine + j])
			end
		end
		self:creatEachLineCards(tmp, i)
	end
end

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)

    return value
end

function CheatCard:creatEachLineCards(cards, index)
	local eachLine = self:getChildByName("line"..index)
	local children = eachLine:getChildren()
	for i,v in ipairs(children) do
		v.cardValue = cards[i]
		v.bSelect = false
		v:onClick(handler(self, self.onClickCard))
		local cardImg = v:getChildByName("cardImg")

		local path = self:getCardPathByValue(cards[i])
		self:changeImgByPath(cardImg, path)
		local maskImg = v:getChildByName("maskImg")
		maskImg:setVisible(false)
	end
end

function CheatCard:onClickCard(sender, event)
	--if event == TOUCH_EVENT_ENDED then
	if sender.bSelect then
		sender.bSelect = false
		sender:getChildByName("maskImg"):setVisible(false)
		for i, v in ipairs(self.selectedCard) do
			if v == sender.cardValue then
				table.remove(self.selectedCard, i)
				break
			end
		end
	else
		if #self.selectedCard > 9 then -- 手牌个数最多为9
			require("hall.GameTips"):showTips("提示", "", 3, "最多可选择9个可替换的牌")
			return
		end
		sender.bSelect = true
		sender:getChildByName("maskImg"):setVisible(true)
		table.insert(self.selectedCard, sender.cardValue)
	end
	--end
end

function CheatCard:getCardPathByValue( v )
	local result = ""
	local cardVariety = getVariety(v or 1)
	local cardValue = getValue(v or 1)
	if cardVariety == VARIETY_DIAMOND then -- 方块
		result = pai_path .. "lord_card_diamond_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_CLUB then-- 梅花
		result = pai_path .. "lord_card_spade_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_HEART then-- 红桃
		result = pai_path .. "lord_card_heart_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_SPADE then-- 黑桃
		result = pai_path .. "lord_card_club_" .. string.format("%d", cardValue) .. ".png"
	end
	return result
end


function CheatCard:changeImgByPath(sp, path)
	local cache = cc.Director:getInstance():getTextureCache():addImage(path)
	sp:setTexture(cache)
end

function CheatCard:sendSelectCards()
	if #self.selectedCard > 9 then -- 手牌个数最多为9
		require("hall.GameTips"):showTips("提示", "", 3, "最多可选择9个可替换的牌")
		return
	end
	
	require("biji.handle.BiJiSendHandle"):CLI_SEND_SELECT_CARDS(self.selectedCard)

	self:removeSelf()
end


return CheatCard