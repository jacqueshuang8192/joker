
--[[
* author:   zwm
* date:     2018-11-21
* describe: 单局结算 cell
--]]

local newGameResultItemCsb = TpackageName.."/res/layout/newGameResultItemLayer.csb"
local pai_path = TpackageName.."/res/images/card/"

local GameResultItem = class("GameResultItem", function ()
	return cc.CSLoader:createNode(newGameResultItemCsb)
end)

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)
    if value == 1 then
    	value = 14
    end
    return value
end

function GameResultItem:ctor()
	self:initGetValidNode()
end

function GameResultItem:initGetValidNode()
	self.root = self:getChildByName("root")
	self.headImg = self.root:getChildByName("headImg")
	self.userName = self.root:getChildByName("userName")
	self.userID = self.root:getChildByName("userID")
	self.resultNode = self.root:getChildByName("resultNode")
	self.group1 = self.resultNode:getChildByName("group_1")
	self.group2 = self.resultNode:getChildByName("group_2")
	self.group3 = self.resultNode:getChildByName("group_3")
	self.winXiScore = self.resultNode:getChildByName("winXiScoreNode")
	self.loseXiScore = self.resultNode:getChildByName("loseXiScoreNode")
	self.winAllScore = self.resultNode:getChildByName("winAllScoreNode")
	self.loseAllScore = self.resultNode:getChildByName("loseAllScoreNode")
	self.xiFont = self.resultNode:getChildByName("fontXi")
end

function GameResultItem:init( info )
	self:setUserInfo(info)
	self:setEachCardAndScore(info)
	self:setXiAndTotle(info)
	self:setSpecialCardType(info)
end

function GameResultItem:setUserInfo(info)
	self.userName:setString(info["nickName"] or "")
	self.userID:setString(tostring(info["uid"]) or "")
	require("hall.GameCommon"):getUserHead(info["icon_url"], info["uid"], 2, self.headImg, 80, false, info["nickName"] or "")
end

function GameResultItem:setEachCardAndScore( info )
	for i,v in ipairs(info.chip_list) do
		-- local tempScore = v/100
		local tempScore = v
		local flag = tempScore > 0
		local winNode = self["group"..tostring(i)]:getChildByName("winScoreNode")
		winNode:setVisible(flag)
		winNode:getChildByName("winScore"):setString(tostring(tempScore))
		local loseNode = self["group"..tostring(i)]:getChildByName("loseScoreNode")
		loseNode:setVisible(not flag)
		loseNode:getChildByName("loseScore"):setString(tostring(tempScore*(-1)))
		self:setCardsValue(info, i)
	end
end

function GameResultItem:setCardsValue(info, index)
	for i,v in ipairs(info["openCard"][index]["son_card"]) do
		local cardImg = self["group"..tostring(index)]:getChildByName("card_"..tostring(i))
		local cardVariety = getVariety(v or 1)
		local cardValue = getValue(v or 1)
		if cardVariety == VARIETY_DIAMOND then -- 方块
			self:changeImgByPath(cardImg, pai_path .. "diamonds_" .. string.format("%02d", cardValue) .. ".png")
		elseif cardVariety == VARIETY_CLUB then-- 梅花
			self:changeImgByPath(cardImg, pai_path .. "clubs_" .. string.format("%02d", cardValue) .. ".png")
		elseif cardVariety == VARIETY_HEART then-- 红桃
			self:changeImgByPath(cardImg, pai_path .. "hearts_" .. string.format("%02d", cardValue) .. ".png")
		elseif cardVariety == VARIETY_SPADE then-- 黑桃
			self:changeImgByPath(cardImg, pai_path .. "spades_" .. string.format("%02d", cardValue) .. ".png")
		end
	end
end

function GameResultItem:changeImgByPath(sp, path)
	local cache = cc.Director:getInstance():getTextureCache():addImage(path)
	sp:setTexture(cache)
end

function GameResultItem:setXiAndTotle(info)
	-- local total = info.turngold/100--(info.chip_list[1] + info.chip_list[2] + info.chip_list[3])
	local total = info.turngold/100--(info.chip_list[1] + info.chip_list[2] + info.chip_list[3])
	local flag = total > 0
	self.winAllScore:setVisible(flag)
	self.loseAllScore:setVisible(not flag)
	if flag then
		self.winAllScore:getChildByName("winScore"):setString(tostring(total))
	else
		self.loseAllScore:getChildByName("loseScore"):setString(tostring(total*(-1)))
	end
	local xiTotal = info.turngold/100 - (info.chip_list[1]+info.chip_list[2]+info.chip_list[3])

	if xiTotal < 0 then
		self.winXiScore:setVisible(false)
		self.loseXiScore:setVisible(true)
		local lable = self.loseXiScore:getChildByName("loseScore")
		lable:setString(tostring(xiTotal*-1))
	else
		self.winXiScore:setVisible(true)
		self.loseXiScore:setVisible(false)
		local lable = self.winXiScore:getChildByName("winScore")
		lable:setString(tostring(xiTotal))
	end

	local node = self.resultNode:getChildByName("TGNode")
	node:setVisible(info.clearanceScore > 0)
end

function GameResultItem:setSpeTypeImg(path, index)
	dump(index,"setSpeTypeImg--index")
	local specialCardType = self.resultNode:getChildByName("specialCardType"..tostring(index))
	if specialCardType then
		specialCardType:setVisible(true)
		self:changeImgByPath(specialCardType, path)
	end


end

function GameResultItem:setSpecialCardType(info)
	local path = nil
	local index = 0 
	if info.sanqin ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontSanqing.png"
		index = 1
		self:setSpeTypeImg(path, index)
	end
	if info.quanhei ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontQuanhei.png"
		index = index + 1
		if index > 2 then return end
		self:setSpeTypeImg(path, index)
	end
	if info.quanhong ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontQuanhong.png"
		index = index + 1
		if index > 2 then return end
		self:setSpeTypeImg(path, index)
	end
	if info.sanshunzi ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontSansunzi.png"
		index = index + 1
		if index > 2 then return end
		self:setSpeTypeImg(path, index)
	end
	if info.shuangshunqing ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontSuansunqing.png"
		index = index + 1
		if index > 2 then return end
		self:setSpeTypeImg(path, index)
	end
	if info.shuangsantiao ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontSuansantiao.png"
		index = index + 1
		if index > 2 then return end
		self:setSpeTypeImg(path, index)
	end
	if info.quansantiao ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontQuansantiao.png"
		index = index + 1
		if index > 2 then return end
		self:setSpeTypeImg(path, index)
	end
	if info.lianshun ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontLiansun.png"
		index = index + 1
		if index > 2 then return end
		self:setSpeTypeImg(path, index)
	end
	if info.sitou ~= 0 then
		path = TpackageName.."/res/images/gameResult/fontSigetou.png"
		index = index + 1
		if index > 2 then return end
		self:setSpeTypeImg(path, index)
	end
	print("result ------------------------------ ", index)
	dump(info)
	if index >= 2 then return end
	--for i = 1, 2-index do
	--	 local specialCardType = self.resultNode:getChildByName("specialCardType"..tostring(3-i))
	--	 specialCardType:setVisible(false)
	--end
end

return GameResultItem