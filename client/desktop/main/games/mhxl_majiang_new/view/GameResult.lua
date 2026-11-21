--[[
	公告弹出框
]]
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local GameResult = class("GameResult", NewViewBaseLayer)
local Card = require(TpackageName .. ".2DMahjongCard.Card")
local scheduler = cc.load("scheduler")
local zhongbirdCount
local win_lose_table = {} -- key = seatId
local sendHandle = require(TpackageName..".handle.MHXLMJSendHandle")

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

    self.showType = 1 --1 显示的分数面板 2 显示的牌型
    self.btn_show.id_0:setString("查看牌型")
	self:initEvent()
	self:initGame( data )
end

function GameResult:initUI()
	-- local root = self._csbNode
    -- self.item = root.item:hide()
    self.item:hide()
    self.txt_time:setString("")
	self.txt_round:setString("")
	self.txt_zhongma:setString("")
end

function GameResult:initGame( data )

	local time_str = os.date("%Y-%m-%d %H:%M:%S", os.time())
	local round = MHXLMJ_ROUND or 0
	local tround = MHXLMJ_TOTAL_ROUNDS or 0
	round = round.."/"..tround.."局"
	self.txt_time:setString(time_str)
	self.txt_round:setString(round)

	local str = "翻鸡牌"
	self.txt_zhongma:setString(str)

	local tempBird = {}
	table.insert(tempBird,data.fanBird)
	self:setZhongMaCards(tempBird)

	self.users_score_info:setVisible(false)
	self.users_score_info:removeAllChildren()
	local size = self.users_score_info:getContentSize()
	for idx,userData in ipairs(data.players) do
		local item = self:initUserItem(userData)
		item:setPositionY(size.height/2)
		local width2 = item:getContentSize().width
		if idx == 1 then
			item:setPositionX(size.width/2 - width2/2 - 30)
		else
			item:setPositionX(size.width/2 + width2/2 + 30)
		end

		self.users_score_info:addChild(item)
	end
	self.users_score_info:setVisible(true)

	self.users_vw:setVisible(false)
	local plane = self.users_vw
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

end

function GameResult:initUserItem( data )
	local item = self.user_1:clone()

	local head = item:getChildByName("head_mi")
	local size = head:getSize()
    require("hall.GameCommon"):getUserHead(data.portrait, "", "", head, size.width , false, "", true)

    local Text_3  = item:getChildByName("Text_3")
    local score = data.changeCoins / 100
    Text_3:setString(score)


	local nickname = require("hall.GameCommon"):formatNick(data.nick, 6)
	local nick = item:getChildByName("nick")
	nick:setString(nickname)

	local id = item:getChildByName("id")
	id:setString(data.uid)

	local strType = ""
	if data.ifhu == 1 then
		if data.hucontent[1].hutype == 1 then
			strType = "平胡"
		else
			strType = "自摸"
		end
	else
		if data.ifpao == 1 then
			strType = "放炮"
		else
			if data.resultTingFlag == 1 then
				strType = "听牌"		
			end 
		end
	end
	local hu_type = item:getChildByName("hu_type")
	hu_type:setString(strType)

	local listView = item:getChildByName("listView")
	self:refreshListView(listView,data)

	return item	

end

function GameResult:refreshListView(listView,player)

	listView:setScrollBarEnabled(false)

	if tonumber(player.chajiao) and player.chajiao > 0 then
		local item = self.user_1_item:clone()

		local text = item:getChildByName("text")
		text:setString("查叫")

		local score = item:getChildByName("score")
		score:setString("+".. player.chajiao)

		listView:pushBackCustomItem(item)
	end


	if tonumber(player.lianzhuan) and player.lianzhuan > 0 then
		local item = self.user_1_item:clone()

		local text = item:getChildByName("text")
		text:setString("连庄")

		local score = item:getChildByName("score")
		score:setString("+".. player.lianzhuan)

		listView:pushBackCustomItem(item)
	end


	if tonumber(player.agMoney) and player.agMoney > 0 then
		local item = self.user_1_item:clone()

		local text = item:getChildByName("text")
		text:setString("暗杠")

		local score = item:getChildByName("score")
		score:setString("+".. player.agMoney)

		listView:pushBackCustomItem(item)
	end

	if tonumber(player.mgMoney) and player.mgMoney > 0 then
		local item = self.user_1_item:clone()
		local text = item:getChildByName("text")
		text:setString("明杠") 

		local score = item:getChildByName("score")
		score:setString("+".. player.mgMoney)

		listView:pushBackCustomItem(item)
	end


	if player.niao_tai and #player.niao_tai>0 then
		for k,v in pairs(player.niao_tai) do
			local item = self.user_1_item:clone()
			local text = item:getChildByName("text")
			text:setString(MHXLMJ_NIAO_TYPE_TABLE[v.byType])


			local score = item:getChildByName("score")
			if v.byTaiCount > 0 then
				score:setString( "+" .. v.byTaiCount)
			else
				score:setString( " "..v.byTaiCount)
			end
			
			listView:pushBackCustomItem(item)
		end
	end


	if player.fa_niao_tai and #player.fa_niao_tai>0 then
		for k,v in pairs(player.fa_niao_tai) do
			local item = self.user_1_item:clone()
			local text = item:getChildByName("text")
			text:setString(MHXLMJ_NIAO_TYPE_TABLE[v.byType])


			local score = item:getChildByName("score")
			if v.byTaiCount > 0 then
				score:setString( "+" .. v.byTaiCount)
			else
				score:setString( " "..v.byTaiCount)
			end
			
			listView:pushBackCustomItem(item)
		end
	end

	if player.hu_tai_mh and #player.hu_tai_mh>0 then
		for k,v in pairs(player.hu_tai_mh) do
			local item = self.user_1_item:clone()
			local text = item:getChildByName("text")
			text:setString(MHXLMJ_HU_TYPE_TABLE[v.byType])

			local score = item:getChildByName("score")
			score:setString("+" .. v.byTaiCount)
			listView:pushBackCustomItem(item)
		end
	end

	if player.userExtras_tai_mh and #player.userExtras_tai_mh then
		for k,v in pairs(player.userExtras_tai_mh) do
			local item = self.user_1_item:clone()
			local text = item:getChildByName("text")
			text:setString(MHXLMJ_HU_EXT_TYPE_TABLE[v.byType])

			local score = item:getChildByName("score")
			score:setString("+" .. v.byTaiCount)
			listView:pushBackCustomItem(item)	
		end	
	end

	local isShow = 0   --如果是 抢杠胡 杠上开花 热炮 那胡牌类型是平胡的时候  不显示平胡
	if player.hucontent then
		local hucontent = player.hucontent[1]
		local hutype = hucontent.hutype
		if hutype == 1 then
			local ifqiangganghu = hucontent.pinghu[1].ifqiangganghu
			if tonumber(ifqiangganghu) and ifqiangganghu > 0 then
				local item = self.user_1_item:clone()
				local text = item:getChildByName("text")
				text:setString("抢杠胡")

				local score = item:getChildByName("score")
				score:setString("+10")
				listView:pushBackCustomItem(item)
				isShow = 1	
			end

			local ifgangpao = hucontent.pinghu[1].ifgangpao
			if tonumber(ifgangpao) and ifgangpao > 0 then
				local item = self.user_1_item:clone()
				local text = item:getChildByName("text")
				text:setString("热炮")

				local score = item:getChildByName("score")
				score:setString("+3")
				listView:pushBackCustomItem(item)	
				isShow = 1	
			end
		else
			local ifgangshanghua = hucontent.zimo[1].ifgangshanghua
			if tonumber(ifgangshanghua) and ifgangshanghua > 0 then
				local item = self.user_1_item:clone()
				local text = item:getChildByName("text")
				text:setString("杠上开花")

				local score = item:getChildByName("score")
				score:setString("+3")
				listView:pushBackCustomItem(item)
				isShow = 2		
			end
		end
	end

	if player.hu_tai and #player.hu_tai>0 then
		for k,v in pairs(player.hu_tai) do
			if v.byTaiCount > isShow then
				local item = self.user_1_item:clone()
				local text = item:getChildByName("text")
				text:setString(MHXLMJ_HU_TYPE_TABLE[v.byType])

				local score = item:getChildByName("score")
				score:setString("+" .. v.byTaiCount)
				listView:pushBackCustomItem(item)	

			end
		end
	end

end

function GameResult:initItem( data )
	local item = self.item:clone()
	item:show()
	GameUtils.setNodeNameBindObj(item)
	local nickname = require("hall.GameCommon"):formatNick(data.nick, 4)

	--local desc = self:getEndingInfo(data)

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
			card = hucontent.pinghu[1].huCard
		else
			card = hucontent.zimo[1].huCard
		end
		item.img_zimo:show()
		item.img_zimo:loadTexture(TpackageName .. "/2DMahjongCard/res/newImage/last_card/"..card..".png")
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
		local card = Card:newEndingCard(cardData)
		--[[if  cardData.position == 1 and not (G_game and G_game.isYiMaQuanZhong) then
			card:setZhongMaAnima(false)
		end--]]
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

	--杠
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
	
	--碰
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

function GameResult:initEvent()
	self.btn_jixu:onClick(handler(self, self.onClickJiXu), true)
    self.make:onTouch(handler(self, self.onClick_vw), false)
    self.btn_show:onClick(handler(self, self.onClickShow), true)
end

function GameResult:onClickShow(event)
	if event.name == "ended" then
        if self.showType == 1 then
        	self.showType = 2 --1 显示的分数面板 2 显示的牌型
    		self.btn_show.id_0:setString("查看分数")
    		self.users_vw:setVisible(true)
    		self.users_score_info:setVisible(false)
        elseif self.showType == 2 then
        	self.showType = 1 --1 显示的分数面板 2 显示的牌型
    		self.btn_show.id_0:setString("查看牌型")

    		self.users_vw:setVisible(false)
    		self.users_score_info:setVisible(true)

        end
    end
end


function GameResult:onClickJiXu(event)
	sendHandle:readyNow()
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

	if tonumber(player.agMoney) and player.agMoney > 0 then
		endingInfo = endingInfo .. "暗杠+" .. player.agMoney .. " "
	end

	if tonumber(player.mgMoney) and player.mgMoney > 0 then
		endingInfo = endingInfo .. "明杠+" .. player.mgMoney .. " "
	end


	if player.niao_tai and #player.niao_tai>0 then
		endingInfo = endingInfo .."鸡牌:"
	end

	for k,v in pairs(player.niao_tai) do
		if v.byTaiCount > 0 then
			endingInfo = endingInfo .. MHXLMJ_NIAO_TYPE_TABLE[v.byType] .."+" .. v.byTaiCount .. " "
		end
	end

	if player.hu_tai_mh and #player.hu_tai_mh>0 then
		endingInfo = endingInfo .."闷胡:"
	end

	for k,v in pairs(player.hu_tai_mh) do
		endingInfo = endingInfo .. MHXLMJ_HU_TYPE_TABLE[v.byType] .."+" .. v.byTaiCount .. " "
	end

	for k,v in pairs(player.userExtras_tai_mh) do
		endingInfo = endingInfo .. MHXLMJ_HU_EXT_TYPE_TABLE[v.byType] .."+" .. v.byTaiCount .. " "
	end


	if player.hu_tai and #player.hu_tai>0 then
		endingInfo = endingInfo .."胡牌:"
	end

	for k,v in pairs(player.hu_tai) do
		endingInfo = endingInfo .. MHXLMJ_HU_TYPE_TABLE[v.byType] .."+" .. v.byTaiCount .. " "
	end

	if player.hu_tai and #player.hu_tai>0 then
		if player.isTianting >0 then
			endingInfo ="天听 +10 "
		end
	end

	

	
	if player.hucontent then
		local hucontent = player.hucontent[1]
		local hutype = hucontent.hutype
		if hutype == 1 then
			local ifqiangganghu = hucontent.pinghu[1].ifqiangganghu
			if tonumber(ifqiangganghu) and ifqiangganghu > 0 then
				endingInfo = endingInfo .. "抢杠胡+10 "
			end

			local ifgangpao = hucontent.pinghu[1].ifgangpao
			if tonumber(ifgangpao) and ifgangpao > 0 then
				endingInfo = endingInfo .. "热炮+3 "
			end
		else
			local ifgangshanghua = hucontent.zimo[1].ifgangshanghua
			if tonumber(ifgangshanghua) and ifgangshanghua > 0 then
				endingInfo = endingInfo .. "杠上开花+3 "
			end
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
				self.maskLayout:hide()
				self.btn_jixu:hide()
				self.btn_show:hide()
			end
        end, 0.1)
    elseif event.name == "ended" then
        if self.handle then
            dump("清除定时器------------------------------")
            self.root:show()
            self.maskLayout:show()
			self.btn_jixu:show()
			self.btn_show:show()
            scheduler.unscheduleGlobal(self.handle)
        end
    elseif event.name == "cancelled" then
        if self.handle then
            dump("cancelled清除定时器------------------------------")
            self.root:show()
            self.maskLayout:show()
			self.btn_jixu:show()
			self.btn_show:show()
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
	MHXLMJ_ENDING_DATA = nil
	if MHXLMJ_GROUP_ENDING_DATA then
		require(TpackageName ..".GroupEndingLayer"):showGroupResult(MHXLMJ_GROUP_ENDING_DATA)
	end
end

return GameResult

