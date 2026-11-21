--[[
	公告弹出框
]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local GameResult = class("GameResult", NewViewBaseLayer)
local Card = require(TpackageName .. ".2DMahjongCard.Card")
local scheduler = cc.load("scheduler")
local zhongbirdCount
local win_lose_table = {} -- key = seatId
local sendHandle = require(TpackageName..".handle.GXHCMJSendHandle")
local GameScene=require(TpackageName..".gameScene")
local GamePlaneOperator=require(TpackageName..".operator.GamePlaneOperator")
local CardBackMgr=require(TpackageName..".2DMahjongCard.CardBackMgr")

--胡牌类型
local GXHCMJ_HU_TYPE_TABLE = {
 "胡牌", "天胡", 
"地胡", "混一色", "门清","清一色", "七对",
 "豪华七对", "双豪华七对", "三豪华七对",
  "杂幺九", "全幺九", "全风头", "坎坎", 
"十三幺", "十八罗汉", "碰碰", "海底","全求人"}


local EVENTNAME = {
	GET_MY_ID_CARD = "/getMyIDCard",
}

function GameResult:ctor(data)
    ReqMgr:addHandle("GameResult", EVENTNAME)
    local csbPath = TpackageName.."/res/GameResult/GameResult.csb"
    GameResult.super.ctor(self, csbPath)
	GameUtils.setNodeNameBindObj(self._csbNode)
	display.doLayout(self._csbNode)
	self:enableMask(true)
    self:initUI()
	self:initEvent()
	self:initGame( data )
end

function GameResult:initUI()
	-- local root = self._csbNode
    -- self.item = root.item:hide()
   if GXHCMJ_GROUP_ENDING_DATA then
		self.btn_jixu:getChildByName("btn_xipai"):setVisible(false)
		end
    
    self.item:hide()
    self.txt_time:setString("")
	self.txt_round:setString("")
	self.txt_zhongma:setString("")
end

function GameResult:initGame( data )

	local plane = self.users_vw
	self.zhongBao = data.zhongBao ----奖码
	plane:removeAllChildren()
	local size = plane:getSize()
	local cardHeight = self.item:getSize().height
	local cardWidth = self.item:getSize().width
	local number = table.getn(data.players)
	local scale = 1
	cardHeight = cardHeight * scale + 5
	cardWidth = cardWidth * scale
	local talHeight = cardHeight * number
	local oriX = size.width / 2
	local oriY = (size.height - talHeight) / 2 + cardHeight / 2
	
	for idx,userData in ipairs(data.players) do
		local item = self:initItem(userData)
		local y = oriY + ( idx-1 ) * cardHeight
		item:setPosition(cc.p(oriX, y))
		plane:addChild(item)
	end
	local time_str = os.date("%Y-%m-%d %H:%M:%S", os.time())

	local round = GXHCMJ_ROUND or 0
	local tround = GXHCMJ_TOTAL_ROUNDS or 0
	round = round.."/"..tround.."局"
	self.txt_time:setString(time_str)
	self.txt_round:setString(round)
	local str=""
	if data.XingCount==0 then
	str = "中码+"..data.maScore
end
	self.txt_zhongma:setString(str)
	self:setZhongMaCards(data.birdCards)
end

function GameResult:initItem( data )
	local item = self.item:clone()
	item:show()
	GameUtils.setNodeNameBindObj(item)
	local nickname = require("hall.GameCommon"):formatNick(data.nick, 4)
	local desc = self:getEndingInfo(data)
	-- local desc = "self:getEndingInfo(data)"
	local score = data.changeCoins / 100
    if score >= 0 then
        score = "+"..score
		item.score:setFntFile(TpackageName .. "/res/GameResult/majiang_win.fnt")
		item:loadTexture(TpackageName .. "/res/GameResult/bg_2.png")
    else
        item.score:setFntFile(TpackageName .. "/res/GameResult/majiang_lose.fnt")
		item:loadTexture(TpackageName .. "/res/GameResult/bg_1.png")
	end
    item.name:setString(nickname)
    item.desc:setString(desc)
	item.score:setString(score)
	item.img_zhuang:hide()
	if data.zhuang == USER_INFO.uid then
		item.img_zhuang:show()
	end
	local size = item.head:getSize()
    require("hall.GameCommon"):getUserHead(data.portrait, "", "", item.head, size.width , false, "", true)

	local cards = data.remainCards
	self:setPengAndGangCards(item.card_vw, data)

	item.img_zimo:hide()
	if data.hucontent then
		local hucontent = data.hucontent[1]
		local card = 0
		local hutype = hucontent.hutype
		if hutype == 1 then
			if hucontent.pinghu then
			card = hucontent.pinghu[1].huCard
		end
		else
			if hucontent.zimo then
			card = hucontent.zimo[1].huCard
		end
		end
		item.img_zimo:show()
		item.img_zimo:loadTexture(TpackageName .. "/2DMahjongCard/res/newImage/last_card/"..card..".png")
		item.img_zimo:setPositionX(item.img_zimo:getPosition().x-80)
		for idx, value in ipairs(cards) do
			if value == card then
				table.remove( cards, idx )
				break
			end
		end
	end
	self:setCards(item.card_vw, cards)

	return item
end

function GameResult:setZhongMaCards(cardDatas)
	local plane = self.zhongma_vw
	local card = Card:newEndingCard({m_value = 1})
	plane:removeAllChildren()
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width - 7
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	local oriX = (size.width - cardWidth * number) / 2
	local oriY = size.height / 2

	for idx,cardData in ipairs(cardDatas) do
		local card = Card:newEndingCard(cardData.card)
		if  cardData.position == 1 and not (G_game and G_game.isYiMaQuanZhong) then
			card:setZhongMaAnima(false)
		end
		local x = oriX + ( idx - 1 ) * cardWidth
		card:setPosition(cc.p(x, oriY))
		card:setScale(scale)
		card:show()
		plane:addChild(card)
	end
end

function GameResult:setCards(plane, cardDatas)
	table.sort(cardDatas,function(a,b)
		return b < a
	end)
	local card = Card:newEndingCard({m_value = 1})
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width - 7
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale

	
	local oriX = cardWidth / 2
	-- local oriX = size.width - cardWidth / 2
	local oriY = cardHeight / 2
	local childs = plane:getChildren()
	if #childs > 0 then
		local pos = childs[#childs]:getPosition()
		oriX = pos.x + 10
	end
	local idx = 1
	for i=number, 1, -1 do
		local cardData = cardDatas[i]
		local card = Card:newEndingCard(cardData)
		-- local x = oriX - ( idx ) * cardWidth
		local x = oriX + ( idx ) * cardWidth
		card:setTag(i)
		card:setScale(scale)
		card:setPosition(cc.p(x, oriY))
		plane:addChild(card)
		card:show()
		idx = idx + 1
	end
end

function GameResult:setPengAndGangCards(plane, data)
	plane:removeAllChildren()
	local card = Card:newEndingCard({m_value = 1})
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width - 7
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	local oriX = cardWidth / 2
	local oriY = cardHeight / 2
	local idx = 0
	
	--暗杠
	if data.agCards then
	for i,cardData in ipairs(data.agCards) do
		for idxx = 1, 4 do
			local card = Card:newEndingCard(cardData)
			local x = oriX + ( idx ) * cardWidth
			local y = oriY
			if idxx == 3 then
				x = oriX + ( idx-1 ) * cardWidth
				y = y + 23
			else
				idx = idx + 1
				card:setEndingAnGangCard()
			end
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
			card:show()
		end
		oriX = oriX + 10
	end
end

	--杠
	if data.gCards then
	for i,cardData in ipairs(data.gCards) do
		for idxx = 1, 4 do
			local card = Card:newEndingCard(cardData)
			local x = oriX + ( idx ) * cardWidth
			local y = oriY
			if idxx == 3 then
				x = oriX + ( idx-1 ) * cardWidth
				y = y + 23
			else
				idx = idx + 1
			end
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
			card:show()
		end
		oriX = oriX + 10
	end
end
	
	--碰
	if data.pCards then 
	for i,cardData in ipairs(data.pCards) do
		for idxx = 1, 3 do
			local card = Card:newEndingCard(cardData)
			local x = oriX + ( idx ) * cardWidth
			card:setScale(scale)
			card:setPosition(cc.p(x, oriY))
			plane:addChild(card)
			card:show()
			idx = idx + 1
		end
		oriX = oriX + 10
	end
end 
	--吃
	local index = 0
	if data.cCards then 
	for i,cardData in ipairs(data.cCards) do
		local card = Card:newEndingCard(cardData.card)
		local x = oriX + ( idx ) * cardWidth
		card:setScale(scale)
		card:setPosition(cc.p(x, oriY))
		plane:addChild(card)
		card:show()
		idx = idx + 1

		index = index+1
		if index % 3 == 0 then
			oriX = oriX + 10
		end
	end
end

end

function GameResult:initEvent()
	self.btn_jixu:onClick(handler(self, self.onClickJiXu), true)
    self.make:onTouch(handler(self, self.onClick_vw), false)
    self.btn_jixu:getChildByName("btn_xipai"):onClick(handler(self, self.onClickXipai), true)
end

function GameResult:onClickXipai(event)
	
	local scenes  = SCENENOW['scene']
	CardBackMgr:removeTableCrad()
	GamePlaneOperator:clearGameDatas()
	scenes:showXipai()
	self:removeSelf()
end

function GameResult:onClickJiXu(event)
	if GXHCMJ_GROUP_ENDING_DATA then
		require(TpackageName ..".GroupEndingLayer"):showGroupResult(GXHCMJ_GROUP_ENDING_DATA)
	end
	sendHandle:readyNow()
	self:onClickBtnClose(event)
end

function GameResult:getEndingInfo(player, index)
	local endingInfo = ""
--[[	if player.winLoseType == -1 then
		endingInfo = endingInfo .. "点炮 "
	elseif player.winLoseType == 1 then
		endingInfo = endingInfo .. "接炮 "
	elseif player.winLoseType == 2 then
		endingInfo = endingInfo .. "自摸 "
	end
	if isChajiao and player.isChajiao == 1 then
		endingInfo = endingInfo .. "查叫 "
	end--]]

	if player.piao and tonumber(player.piao) and player.piao > -1 then
		endingInfo = endingInfo .. player.piao .. "点 "
	end
	-- for i=1,player.huTypeCount do
	-- 	endingInfo = endingInfo .. GXHCMJ_HU_TYPE_TABLEE[player.huTypes[i] + 1] .. " "
	-- end
	if player.daizhuang and player.daizhuang == 1 then
		endingInfo = endingInfo .. "带庄 "
	end
	if player.mobao and player.mobao == 1 then
		endingInfo = endingInfo .. "摸宝 "
	end
	if player.ifpao and player.ifpao==1 then
			endingInfo = endingInfo .. "放炮 "
	end
	--if tonumber(player.agMoney) and player.agMoney > 0 then
	--	endingInfo = endingInfo .. "暗杠+" .. player.agMoney .. " "
	--end
	--if tonumber(player.mgMoney) and player.mgMoney > 0 then
	--	endingInfo = endingInfo .. "明杠+" .. player.mgMoney .. " "
	--end
	if player.isDaHu and tonumber(player.isDaHu) and player.isDaHu > 0 then
		endingInfo = endingInfo .. "大胡" .. "x2 "

	end
	if player.isQingShui and tonumber(player.isQingShui) and player.isQingShui > 0 then
		endingInfo = endingInfo .. "清水" .. "x2 "
	end
	--if tonumber(player.m_bHaiDiHu) and player.m_bHaiDiHu > 0 then
	--	endingInfo = endingInfo .. "海底胡x" .. player.m_bHaiDiHu .. " "
	--end
	if player.hucontent then
		if player.hucontent[1].hutype==1 then
			endingInfo = endingInfo .. "接炮 "
		else
			endingInfo = endingInfo .. "自摸 "
		end 
--[[		if player.hucontent[1].yucount then
			endingInfo = endingInfo .. "钓"..player.hucontent[1].yucount.."鱼 "
		end--]]
	end
	dump(player.xingfen,"----player.xingfen---")
	if player.xingfen then
	if player.xingfen>0 then
		endingInfo=endingInfo.."醒分+"..player.xingfen
	end
end
if player.hu_tai then
	for k,v in pairs(player.hu_tai) do
		if v.byType ==6 or v.byType ==7 then
			endingInfo = endingInfo .. GXHCMJ_HU_TYPE_TABLE[v.byType] .."x" .. "2"
		else
			endingInfo = endingInfo .. GXHCMJ_HU_TYPE_TABLE[v.byType] .."+" .. v.byTaiCount .. " "
		end

	end
end
	if player.hucontent then
		local hucontent = player.hucontent[1]
		local hutype = hucontent.hutype
		if hutype == 1 and hucontent.pinghu then
			local ifqiangganghu = hucontent.pinghu[1].ifqiangganghu
			if tonumber(ifqiangganghu) and ifqiangganghu > 0 then
				endingInfo = endingInfo .. "抢杠x2 "
			end
		else
			if hucontent.zimo then
			local ifgangshanghua = hucontent.zimo[1].ifgangshanghua
			if tonumber(ifgangshanghua) and ifgangshanghua > 0 then
				endingInfo = endingInfo .. "杠上开花x2 "
			end
		end
		end
		if self.zhongBao and  tonumber(self.zhongBao) and self.zhongBao > 0 then
			endingInfo = endingInfo .. "无宝奖码x" .. self.zhongBao .. " "
		end
	end
	
	-- local birdCount = win_lose_table[(index - 1) .. "birdCount"]
	-- if not birdCount then
	-- 	--todo
	-- 	birdCount = 0
	-- end
	return endingInfo
end

function GameResult:onClick_vw(event)
    if event.name == "began" then
        dump("定时器------------------------------")
		self.handle = scheduler.performWithDelayGlobal(function()
			if self and self.root then
				self.root:hide()
				self.maskLayout:hide()
				self.btn_jixu:hide()
			end
        end, 0.1)
    elseif event.name == "ended" then
        if self.handle then
            dump("清除定时器------------------------------")
            self.root:show()
            self.maskLayout:show()
			self.btn_jixu:show()
            scheduler.unscheduleGlobal(self.handle)
        end
    elseif event.name == "cancelled" then
        if self.handle then
            dump("cancelled清除定时器------------------------------")
            self.root:show()
            self.maskLayout:show()
			self.btn_jixu:show()
            scheduler.unscheduleGlobal(self.handle)
        end
    end
end

-- 关闭界面
function GameResult:onClickBtnClose(event)
    self:removeSelf()
end

function GameResult:onExit()
	ReqMgr:delHandle("GameResult", EVENTNAME)
	if self.handle then
		scheduler.unscheduleGlobal(self.handle)
	end
	GXHCMJ_ENDING_DATA = nil
	if SCENENOW['name']==TpackageName..".gameScene" then
	if GXHCMJ_GROUP_ENDING_DATA then
		require(TpackageName ..".GroupEndingLayer"):showGroupResult(GXHCMJ_GROUP_ENDING_DATA)
	end
end
end

return GameResult

