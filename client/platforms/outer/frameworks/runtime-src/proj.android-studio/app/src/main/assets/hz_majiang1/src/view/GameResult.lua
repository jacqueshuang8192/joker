--[[
	公告弹出框
]]
local GameResult = class("GameResult", function()
    return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."hz_majiang/res/GameResult/GameResult.csb")
end)
local PokerCard = require("hz_majiang.src.PokerCard")
local scheduler = cc.load("scheduler")
local SendHandle = require("hz_majiang.src.handle.SendHandle")
local HZMJ_HU_TYPE_TABLE = {"胡牌", "天胡", "地胡", "混一色", "门清","清一色", "七对", "豪华七对", "双豪华七对", "三豪华七对", "杂幺九", "全幺九", "全风头", "坎坎", "十三幺", "十八罗汉", "碰碰", "海底"}

function GameResult:ctor(data, round, tround)
	self:setNodeEventEnabled(true)
	GameUtils.setNodeNameBindObj(self)
	display.doLayout(self)
    self:initUI()
	self:initEvent()
	self:initGame( data, round, tround )
	self:setName("GameResult")
end

function GameResult:initUI()
    self.item = self.root.item:hide()
    self.txt_round = self.root.txt_round
    self.txt_zhongma = self.root.txt_zhongma
    self.zhongma_vw = self.root.zhongma_vw
    self.txt_time = self.root.txt_time
    self.users_vw = self.root.users_vw
    self.txt_time:setString("")
	self.txt_round:setString("")
	self.txt_zhongma:setString("")
end

function GameResult:initGame( data, round, tround )
	self.zhongBao = data.zhongBao ----奖码
	self.users_vw:removeAllChildren()
	local size = self.users_vw:getSize()
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
		self.users_vw:addChild(item)
	end
	local time_str = os.date("%Y-%m-%d %H:%M:%S", os.time())

	round = round.."/"..tround.."局"
	self.txt_time:setString(time_str)
	self.txt_round:setString(round)
	local str = "中码+"..data.maScore
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
		item.score:setFntFile("hz_majiang/res/GameResult/majiang_win.fnt")
		item:loadTexture("hz_majiang/res/GameResult/bg_2.png")
    else
        item.score:setFntFile("hz_majiang/res/GameResult/majiang_lose.fnt")
		item:loadTexture("hz_majiang/res/GameResult/bg_1.png")
	end
    item.desc:setString(desc)
	item.score:setString(score)
	item.img_zhuang:hide()
	if data.zhuang == USER_INFO.uid then
		item.img_zhuang:show()
	end
	local size = item.head:getSize()
	

	if g_308.gameConfig.model == 1 then  --黑夜模式
		item.head:loadTexture("hz_majiang/res/GameScene/player/headimg.png")
		item.name:setString("黑衣人")
	else
		item.name:setString(nickname)
		require("hall.GameCommon"):getUserHead(data.portrait, "", "", item.head, size.width , false, "", true)
	end
	

	local cards = data.remainCards
	self:setPengAndGangCards(item.card_vw, data)
	item.img_zimo:hide()
	if data.hucontent then
		local hucontent = data.hucontent[1]
		local card = 0
		local hutype = hucontent.hutype
		if hutype == 1 then
			card = hucontent.pinghu[1].huCard
		else
			card = hucontent.zimo[1].huCard
		end
		item.img_zimo:show()
		item.img_zimo:loadTexture("hz_majiang/2DMahjongCard/res/newImage/last_card/"..card..".png")
		item.img_zimo:setPositionX(item.img_zimo:getPosition().x-100)
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
	self.zhongma_vw:removeAllChildren()
	local size = self.zhongma_vw:getSize()
	local number = table.getn(cardDatas)
	local scale = 1

	for idx,cardData in ipairs(cardDatas) do
		local cardNode = PokerCard:newEndingCard(cardData.card)

		local cardHeight = cardNode:getSize().height
		local cardWidth = cardNode:getSize().width - 7
		cardHeight = cardHeight * scale
		cardWidth = cardWidth * scale
		local oriX = (size.width - cardWidth * number) / 2
		local oriY = size.height / 2


		if cardData.isZhongMa == 1 and not (g_308.gameConfig.zhuaniao == 999) then
			cardNode:setZhongMaAnima(false)
		end
		local x = oriX + ( idx - 1 ) * cardWidth
		cardNode:setPosition(cc.p(x, oriY))
		cardNode:setScale(scale)
		cardNode:show()
		self.zhongma_vw:addChild(cardNode)
	end
end

function GameResult:setCards(setCards, cardDatas)
	table.sort(cardDatas,function(a,b)
		return b < a
	end)
	local size = setCards:getSize()
	local number = table.getn(cardDatas)
	local scale = 1

	

	local childs = setCards:getChildren()
	local oriX = nil
	if #childs > 0 then
		local pos = childs[#childs]:getPosition()
		oriX = pos.x + 10
	end

	local idx = 1
	for i=number, 1, -1 do
		local cardData = cardDatas[i]
		local cardNode = PokerCard:newEndingCard(cardData)

		local cardHeight = cardNode:getSize().height
		local cardWidth = cardNode:getSize().width - 7
		cardHeight = cardHeight * scale
		cardWidth = cardWidth * scale
		if not oriX then
			oriX = cardWidth / 2
		end
		local oriY = cardHeight / 2
		
		local x = oriX + ( idx ) * cardWidth
		cardNode:setTag(i)
		cardNode:setScale(scale)
		cardNode:setPosition(cc.p(x, oriY))
		setCards:addChild(cardNode)
		cardNode:show()
		idx = idx + 1
	end
end

function GameResult:setPengAndGangCards(card_vw, data)
	card_vw:removeAllChildren()
	local size = card_vw:getSize()
	local scale = 1
	local idx = 0
	local oriX
	--暗杠
	for i,cardData in ipairs(data.agCards) do
		for idxx = 1, 4 do
			local cardNode = PokerCard:newEndingCard(cardData)

			local cardHeight = cardNode:getSize().height
			local cardWidth = cardNode:getSize().width - 7
			cardHeight = cardHeight * scale
			cardWidth = cardWidth * scale
			if not oriX	then
				oriX = cardWidth / 2
			end
			local oriY = cardHeight / 2

			local x = oriX + ( idx ) * cardWidth
			local y = oriY
			if idxx == 3 then
				x = oriX + ( idx-1 ) * cardWidth
				y = y + 23
			else
				idx = idx + 1
				cardNode:setEndingAnGangCard()
			end
			cardNode:setScale(scale)
			cardNode:setPosition(cc.p(x, y))
			card_vw:addChild(cardNode)
			cardNode:show()
		end
		oriX = oriX + 10
	end

	--杠
	for i,cardData in ipairs(data.gCards) do
		for idxx = 1, 4 do
			local cardNode = PokerCard:newEndingCard(cardData)

			local cardHeight = cardNode:getSize().height
			local cardWidth = cardNode:getSize().width - 7
			cardHeight = cardHeight * scale
			cardWidth = cardWidth * scale
			local oriY = cardHeight / 2
			if not oriX	then
				oriX = cardWidth / 2
			end
			local x = oriX + ( idx ) * cardWidth
			local y = oriY
			if idxx == 3 then
				x = oriX + ( idx-1 ) * cardWidth
				y = y + 23
			else
				idx = idx + 1
			end
			cardNode:setScale(scale)
			cardNode:setPosition(cc.p(x, y))
			card_vw:addChild(cardNode)
			cardNode:show()
		end
		oriX = oriX + 10
	end
	
	--碰
	for i,cardData in ipairs(data.pCards) do
		for idxx = 1, 3 do
			local cardNode = PokerCard:newEndingCard(cardData)

			local cardHeight = cardNode:getSize().height
			local cardWidth = cardNode:getSize().width - 7
			cardHeight = cardHeight * scale
			cardWidth = cardWidth * scale
			local oriY = cardHeight / 2
			if not oriX	then
				oriX = cardWidth / 2
			end
			local x = oriX + ( idx ) * cardWidth
			cardNode:setScale(scale)
			cardNode:setPosition(cc.p(x, oriY))
			card_vw:addChild(cardNode)
			cardNode:show()
			idx = idx + 1
		end
		oriX = oriX + 10
	end
end

function GameResult:initEvent()
	self.btn_jixu:onClick(handler(self, self.onClickJiXu), true)
    self.make:onTouch(handler(self, self.onClick_vw), false)
end

function GameResult:onClickJiXu(event)
	SendHandle:CLI_READYNOW_ROOM()
	self:onClickBtnClose(event)
end

function GameResult:getEndingInfo(player, index)
	local endingInfo = ""
	if player.winLoseType == -1 then
		endingInfo = endingInfo .. "点炮 "
	elseif player.winLoseType == 1 then
		endingInfo = endingInfo .. "接炮 "
	elseif player.winLoseType == 2 then
		endingInfo = endingInfo .. "自摸 "
	end
	if isChajiao and player.isChajiao == 1 then
		endingInfo = endingInfo .. "查叫 "
	end
	if tonumber(player.piao) and player.piao > -1 then
		endingInfo = endingInfo .. player.piao .. "点 "
	end
	-- for i=1,player.huTypeCount do
	-- 	endingInfo = endingInfo .. GXLZ_HU_TYPE_TABLE[player.huTypes[i] + 1] .. " "
	-- end
	if player.daizhuang == 1 then
		endingInfo = endingInfo .. "带庄 "
	end
	if player.mobao == 1 then
		endingInfo = endingInfo .. "摸宝 "
	end
	--if tonumber(player.agMoney) and player.agMoney > 0 then
	--	endingInfo = endingInfo .. "暗杠+" .. player.agMoney .. " "
	--end
	--if tonumber(player.mgMoney) and player.mgMoney > 0 then
	--	endingInfo = endingInfo .. "明杠+" .. player.mgMoney .. " "
	--end
	if tonumber(player.isDaHu) and player.isDaHu > 0 then
		endingInfo = endingInfo .. "大胡" .. "x2 "
	end
	if tonumber(player.isQingShui) and player.isQingShui > 0 then
		endingInfo = endingInfo .. "清水" .. "x2 "
	end
	--if tonumber(player.m_bHaiDiHu) and player.m_bHaiDiHu > 0 then
	--	endingInfo = endingInfo .. "海底胡x" .. player.m_bHaiDiHu .. " "
	--end

	if tonumber(player.piaoScore) and player.piaoScore > 0 then
		endingInfo = endingInfo .. "漂+" .. player.piaoScore.." "
	end

	for k,v in pairs(player.hu_tai) do
		if v.byType ==6 or v.byType ==7 then
			endingInfo = endingInfo .. HZMJ_HU_TYPE_TABLE[v.byType] .."x" .. "2"
		else
			endingInfo = endingInfo .. HZMJ_HU_TYPE_TABLE[v.byType] .."+" .. v.byTaiCount .. " "
		end

	end
	if player.hucontent then
		local hucontent = player.hucontent[1]
		local hutype = hucontent.hutype
		if hutype == 1 then
			local ifqiangganghu = hucontent.pinghu[1].ifqiangganghu
			if tonumber(ifqiangganghu) and ifqiangganghu > 0 then
				endingInfo = endingInfo .. "抢杠x2 "
			end
		else
			local ifgangshanghua = hucontent.zimo[1].ifgangshanghua
			if tonumber(ifgangshanghua) and ifgangshanghua > 0 then
				endingInfo = endingInfo .. "杠上开花x2 "
			end
		end
		if tonumber(self.zhongBao) and self.zhongBao > 0 then
			endingInfo = endingInfo .. "无宝奖码x" .. self.zhongBao .. " "
		end

	end
	
	return endingInfo
end

function GameResult:onClick_vw(event)
    if event.name == "began" then
        dump("定时器------------------------------")
		self.handle = scheduler.performWithDelayGlobal(function()
			if self and self.root then
				self.root:hide()
				self.make:hide()
				self.btn_jixu:hide()
			end
        end, 0.1)
    elseif event.name == "ended" then
        if self.handle then
            dump("清除定时器------------------------------")
            self.root:show()
            self.make:show()
			self.btn_jixu:show()
            scheduler.unscheduleGlobal(self.handle)
        end
    elseif event.name == "cancelled" then
        if self.handle then
            dump("cancelled清除定时器------------------------------")
            self.root:show()
            self.make:show()
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
	if self.handle then
		scheduler.unscheduleGlobal(self.handle)
	end
	if g_308.settlementData then
        self.GameSceneView:settlement(g_308.settlementData)
    end
end

return GameResult

