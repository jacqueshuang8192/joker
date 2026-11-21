local phzServer = import("cdpaohuzi.handle.PHZSendHandle")
local GameLogic = require("cdpaohuzi.logic.GameLogic")
local PHZResultLayer = class("PHZResultLayer", function ()
   return cc.CSLoader:createNode("cdpaohuzi/res/roundEndingLayer.csb")
end)
local CardConfig = require("cdpaohuzi.logic.CardConfig")
local cardW = 15
local cardH = 125
local DI_CARD_SCALE = 1.2
local HU_TYPE_IMG_PATH = "cdpaohuzi/res/setting/HuType_"
local MingTangTxt = {
	[0] = "无效",
	[1] = "大团圆",
	[2] = "背靠背",
	[3] = "碰碰胡",
	[4] = "行行息",
	[5] = "耍猴",
	[6] = "海底胡",
	[7] = "大字胡",
	[8] = "小字胡",
	[9] = "天胡",
	[10] = "地胡",
	[11] = "红胡",
	[12] = "黑乌",
	[13] = "点胡",
	[14] = "小卡胡",
	[15] = "大卡胡",
	[16] = "红乌",
	[17] = "一块扁",
	[18] = "黄庄",
}
function PHZResultLayer:ctor(data)
	GameUtils.setNodeNameBindObj(self)
	print("=====打开玩家结算界面=====")
	local color = cc.c3b(34, 52, 49)
	viewMgr:setMask( self, true, 255, color )
	viewMgr:setScenePos( self ) 
	local size = cc.Director:getInstance():getVisibleSize()
    -- local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
	self.maskLayout:setContentSize(size)
	
	self.data = data

	self.m_GameLogic = GameLogic:new()
	self.m_CardConfig = CardConfig:new()
	self.title_txt = nil;
	self.cardWeaItem = {}

	self.huTypeArr = {}    --胡牌类型集合
	self:initData()
	self:setNodeEventEnabled(true)
	self:setData()
	self:initUI()
end
function PHZResultLayer:initData()
	for i = 0, 2 do
		self.cardWeaItem[i] ={}
		self.huTypeArr[i] = {}
	end


end
function PHZResultLayer:initHuType()
	for i=1,9 do
		local tempItem = self:getChildByName("img_hu_type_"..i)
		tempItem:setVisible(false)
		self.huTypeArr[i] = tempItem
	end
end

function PHZResultLayer:refreshHuType()
	if #self.data.groupHuType <= 0 then return end
	local _tempIndex = 1
	for k,v in pairs(self.data.groupHuType) do
		if v > 0 and v <= 14 then
			local str = HU_TYPE_IMG_PATH..v..".png"
			self.huTypeArr[_tempIndex]:setVisible(true)
			local frame = display.newSpriteFrame(str)
	        self.huTypeArr[_tempIndex]:setSpriteFrame(frame)
	        _tempIndex = _tempIndex + 1
		end
	end
end

function PHZResultLayer:setData()
	for k,v in pairs(self.data.userArr) do
		if v.ti_count > 0 then
			for k,v2 in pairs(v.tiCardArr) do
				local weaveItem = {}
				weaveItem.cbWeaveKind = AK_SAO_EX
				weaveItem.cbCardList = {}
				weaveItem.text = "提"
				weaveItem.cbCardList = {v2.card,0x00,0x00,0x00}
				weaveItem.cbComfrom = 0                  --来自手牌还是打下去得牌  0 已经打下去得牌，1：手牌
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
		if v.pao_count > 0 then
			for k,v2 in pairs(v.paoCardArr) do
				-- local tempCardArr = {v.cardvalue,v.cardvalue,v.cardvalue,v.cardvalue}
				local weaveItem = {}
				weaveItem.cbWeaveKind = AK_DUO
				weaveItem.text = "跑"
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = {v2.card,v2.card,v2.card,v2.card}
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
		if v.wei_count > 0 then
			for k,v2 in pairs(v.weiCardArr) do
				-- local tempCardArr = {v.cardvalue,0x00,0x00}
				local weaveItem = {}
				weaveItem.cbWeaveKind = AK_SAO
				weaveItem.text = "偎"
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = {v2.card,0x00,0x00}
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
		if v.pen_count > 0 then
			for k,v2 in pairs(v.penCardArr) do
				-- local tempCardArr = {v.cardvalue,v.cardvalue,v.cardvalue}
				local weaveItem = {}
				weaveItem.cbWeaveKind = AK_PENG
				weaveItem.text = "碰"
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = {v2.card,v2.card,v2.card}
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end

		if v.chi_count > 0 then
			for k2,v2 in pairs(v.chiCardArr) do
				local weaveItem = {}
				weaveItem.cbWeaveKind = AK_CHI
				weaveItem.cbCardList = {}
				weaveItem.text = "吃"
				weaveItem.cbCardList = v2.cards
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end

		if v.bi_count > 0 then
			for k2,v2 in pairs(v.biCardArr) do
				local weaveItem = {}
				weaveItem.cbWeaveKind = AK_CHI
				weaveItem.text = "吃"
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = v2.cards
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
		if v.isHu == 0 then
			local WeaveArray,ArrayCount = self.m_GameLogic:getCurhandCard(v.handCardArr)
			for k3, v3 in pairs(WeaveArray) do
				local weaveItem = {}
				weaveItem.cbCardList = {}
				weaveItem.cbCardList =  v3
				weaveItem.cbComfrom = 0
				weaveItem.cbWeaveKind = AK_NULL
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
	end
	for k,v in pairs(self.data.huUserArr) do
		if v.group_count > 0 then
			local weaveItem = {}
			weaveItem.cbCardList = {}
			weaveItem.cbCardList = v.groupArr
			weaveItem.cbComfrom = 1

			if self.data.groupType == 1 then -- 吃
				weaveItem.cbWeaveKind = AK_CHI
			elseif self.data.groupType == 2 then -- 碰
				weaveItem.cbWeaveKind = AK_PENG
			elseif self.data.groupType == 3 then -- 偎
				weaveItem.cbWeaveKind = AK_SAO
			elseif self.data.groupType == 4 then
				weaveItem.cbWeaveKind = AK_NULL
			end
			local huxi = self.m_GameLogic:GetWeaveHuXi(weaveItem)
			weaveItem.huxi = huxi or "0"
			table.insert(self.cardWeaItem[v.seat_id],weaveItem)
		end
		if v.cardGroupCount >0 then
			for k2,v2 in pairs(v.cardGroupArr) do
				local weaveItem = {}
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = v2.cards
				weaveItem.cbComfrom = 1
				if v2.type == 1 then
					weaveItem.cbWeaveKind = AK_CHI
				elseif v2.type == 2 then
					weaveItem.cbWeaveKind = AK_PENG
				elseif v2.type == 3 then
					weaveItem.cbWeaveKind = AK_SAO
				elseif v2.type == 4 then
					weaveItem.cbWeaveKind = AK_NULL
				end
				local huxi = self.m_GameLogic:GetWeaveHuXi(weaveItem)
				weaveItem.huxi = huxi or "0"

				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
	end
end

function PHZResultLayer:onEnter()
end

function PHZResultLayer:onExit()
end

function PHZResultLayer:initUI()
	self.item_cards:hide()
	self.player:hide()
	
	self.root = self:getChildByName("root")
	self.root:getChildByName("room_lb"):setString("房间号："..g_PHZMainScene.m_nRoomID)
	self.show_plane= self.root:getChildByName("show_plane")
    self.btn_again = self.root:getChildByName("btn_again")
    self.btn_zhanji = self.root:getChildByName("btn_zhanji")
	self.m_diCardBg = self.root:getChildByName("diLayout")
	self.m_chouPaiCardBg = self.root:getChildByName("chouPaiLayout")
	self.player_listview = self.root.show_plane.player_listview
	self.btn_zhanji:hide()
	self.m_diCardBg:removeAllChildren()
	self.m_chouPaiCardBg:removeAllChildren()
	self.Text_chouPai = self.root:getChildByName("Text_chouPai")
	self.Text_chouPai:setVisible(false)
	if self.data.endGame ==1 then
		self.btn_again:setVisible(false)
		self.btn_zhanji:setVisible(true)
		-- if g_PHZMainScene.m_isGameOver == false then
		-- 	self.btn_zhanji:setEnabled(false)
		-- else
		-- 	self.btn_zhanji:setEnabled(true)
		-- end

	else
		self.btn_again:setVisible(true)
		self.btn_zhanji:setVisible(false)
	end

    self.btn_again:onClick(handler(self,self.clickBtnAgain))
    self.btn_zhanji:onClick(handler(self,self.clickBtnZhanji))
	-- for i = 0, 2 do
	-- 	local player = self.player_listview:getChildByName("player"..(i+1))
	-- 	player:setVisible(false)
	-- 	player:getChildByName("isZiMo"):setString("")
	-- 	player:getChildByName("head")
	-- 	player:getChildByName("hu_signal"):setVisible(false)
	-- 	player:getChildByName("nick_lb"):setString("")
	-- 	player.ListView:removeAllChildren()
	-- 	player.hu_card:hide()
	-- end
	self.title_txt =self.show_plane:getChildByName("title_txt")
	self.title_txt:setString("")
	for i,userInfo in ipairs(self.data.userArr) do
		local player = self.player:clone()
		player:setName(userInfo.seat_id)
		player:show()
		GameUtils.setNodeNameBindObj(player)
		self.player_listview:pushBackCustomItem(player)
	end
    self:refreshCardArr()
    self:refreshPlayerInfo()
end


function PHZResultLayer:refreshCardArr()
	for k,userInfo in ipairs(self.data.userArr) do
		local player = self.player_listview:getChildByName(userInfo.seat_id)
		player.ListView:removeAllItems()
		for idx,cardsInfo in ipairs(self.cardWeaItem[userInfo.seat_id]) do
			local item = self.item_cards:clone()
			player.ListView:pushBackCustomItem(item)
			self:setCardsItems(item, cardsInfo)
		end
	end

	for k,v in pairs(self.data.currCardArr) do
		local imgPath = "cdpaohuzi/res/CardLitter/Card_miniature_000.png"
		local cardInfo = self.m_CardConfig:getCardInfoByid(v)
		if cardInfo then
			imgPath = string.format("%s.png",cardInfo.CardIconA)
		end
		local cardObj = display.newSprite()
		local frame = display.newSpriteFrame(imgPath)
		cardObj:setSpriteFrame(frame)
		cardObj:setAnchorPoint(cc.p(0, 0))
		local x = (k-1) * cardObj:getContentSize().width * DI_CARD_SCALE
		cardObj:setPosition(x,0)
		cardObj:setScale(DI_CARD_SCALE)
		self.m_diCardBg:addChild(cardObj)
	end
	
	if self.data.chouPaiCount ~= 0 then
		self.Text_chouPai:setVisible(true)
	end
	for k,v in pairs(self.data.chouCardArr) do
		local imgPath = "cdpaohuzi/res/CardLitter/Card_miniature_000.png"
		local cardInfo = self.m_CardConfig:getCardInfoByid(v)
		if cardInfo then
			imgPath = string.format("%s.png",cardInfo.CardIconA)
		end
		local cardObj = display.newSprite()
		local frame = display.newSpriteFrame(imgPath)
		cardObj:setSpriteFrame(frame)
		cardObj:setAnchorPoint(cc.p(0, 0))
		local x = (k-1) * cardObj:getContentSize().width * DI_CARD_SCALE
		cardObj:setPosition(x,0)
		cardObj:setScale(DI_CARD_SCALE)
		self.m_chouPaiCardBg:addChild(cardObj)
	end
end

function PHZResultLayer:refreshPlayerInfo()
	local huUser_seatId = -1
	for k2,userInfo in ipairs(self.data.huUserArr) do
		huUser_seatId = userInfo.seat_id
		local player = self.player_listview:getChildByName(userInfo.seat_id)
		player:getChildByName("hu_signal"):setVisible(true)
		-- if userInfo.uid == USER_INFO.uid then
		-- 	local imgPath = "cdpaohuzi/res/other/bottom_win.png"
		-- 	local text = "胜局"
		-- 	self.title_txt:setString(text)
		-- 	self.show_plane:loadTexture(imgPath)
		-- end
	end
	local text = "败局"
	local imgPath = "cdpaohuzi/res/other/bottom_lose.png"

	for k,userInfo in pairs(self.data.userArr) do
		local player = self.player_listview:getChildByName(userInfo.seat_id)
		local m_oil = 0
		if userInfo.m_oil > 0 then
			m_oil = "+"..(userInfo.m_oil)
		else
			m_oil = userInfo.m_oil
		end
		player:getChildByName("txt_hu"):setString("胡息:"..userInfo.m_oil)
		
		local m_turnBlc = userInfo.m_turnBlc / 100
		if m_turnBlc > 0 then
			if userInfo.uid == USER_INFO.uid then
				imgPath = "cdpaohuzi/res/other/bottom_win.png"
				text = "胜局"
			end
			m_turnBlc = "+"..m_turnBlc
		elseif m_turnBlc == 0 then
			if userInfo.uid == USER_INFO.uid then
				text = "流局"
			end
		end
		

		player:getChildByName("score"):setString("分数:"..m_turnBlc)

		self.player_listview:getChildByName(userInfo.seat_id):setVisible(true)
		if userInfo.uid == USER_INFO.uid then
			player:getChildByName("nick_lb"):setString(require("hall.GameCommon"):formatNick( USER_INFO.nick, 3))
			require("hall.GameCommon"):getUserHead(USER_INFO.icon_url,userInfo.uid, USER_INFO.sex, player:getChildByName("head"), 87, false, USER_INFO.nick)
		else
			player:getChildByName("nick_lb"):setString(require("hall.GameCommon"):formatNick( g_PHZMainScene.otherInfo[userInfo.uid].nickName, 3))
			require("hall.GameCommon"):getUserHead(g_PHZMainScene.otherInfo[userInfo.uid].portrait,userInfo.uid,  g_PHZMainScene.otherInfo[userInfo.uid].sex, player:getChildByName("head"), 87, false,  g_PHZMainScene.otherInfo[userInfo.uid].nickName)
		end

		local taiStr = ""
		for _,tai in ipairs(userInfo.taiList) do
			taiStr = taiStr..MingTangTxt[tai.byType].."x "..tai.byCount.." "
			--taiStr = taiStr..MingTangTxt[tai.byType].."翻倍 "
			-- if tai.byType == 144 and tai.byCount ~= 1 then--黄庄
				-- if tai.byCount == 1 then
					-- taiStr = taiStr..MingTangTxt[tai.byType].."翻倍 "
				-- else
					-- taiStr = taiStr..MingTangTxt[tai.byType].."x "..tai.byCount.." "
				-- end
			-- else
				-- taiStr = taiStr..MingTangTxt[tai.byType].."x "..tai.byCount.." "
			-- end
		end
		player.txt_quanmingtang:setString(taiStr)
		player.txt_tun:setString("屯："..userInfo.tunshu)
		player.hu_card:hide()
		if userInfo.seat_id ~= huUser_seatId then
			--player.txt_quanmingtang:hide()
			player.txt_tun:hide()
			player.hu_signal:hide()
			player.txt_hu:hide()
		end
		if (self.data.isZiMo == 1) and userInfo.seat_id == huUser_seatId then
			player.isZiMo:show()
		else
			player.isZiMo:hide()
		end
	end

	self.title_txt:setString(text)
	self.show_plane:loadTexture(imgPath)
	-- if self.data.nRoundResult == 0 then
	-- 	local imgPath = "cdpaohuzi/res/other/bottom_lose.png"
	-- 	local text = "流局"
	-- 	self.show_plane:loadTexture(imgPath)
	-- 	self.title_txt:setString(text)
	-- end
	if self.data.nFangPaoSeat >= 0 then
		local player = self.player_listview:getChildByName(self.data.nFangPaoSeat)
		player:getChildByName("isZiMo"):setString("放炮")
	end

	if self.data.m_HuCard ~= 0 then
		local player = self.player_listview:getChildByName(huUser_seatId)
		local paths = self.m_CardConfig:getCardInfoByid(self.data.m_HuCard)
		if paths ~= nil then
			local imgPath = string.format("%s.png",paths.CardIconB)
			player.hu_card:loadTexture(imgPath,1)
			player.hu_card:show()
		end
	end
end

function PHZResultLayer:setCardsItems( item, cardsInfo)
	item:show()
	GameUtils.setNodeNameBindObj(item)
	
	local huxi = self.m_GameLogic:GetWeaveHuXi(cardsInfo)
	local text = ""
	if AK_NULL == cardsInfo.cbWeaveKind then
		huxi = ""
	elseif AK_SAO_EX == cardsInfo.cbWeaveKind then
		text = "扫穿"
	elseif AK_SAO == cardsInfo.cbWeaveKind then
		text = "扫"
	elseif AK_SAO_BAD == cardsInfo.cbWeaveKind then
		text = "臭扫"
	elseif AK_DUO == cardsInfo.cbWeaveKind then
		text = "开舵"
	elseif AK_PENG == cardsInfo.cbWeaveKind then
		text = "碰"
	elseif AK_CHI == cardsInfo.cbWeaveKind then
		text = "吃"
	elseif AK_KAN == cardsInfo.cbWeaveKind then
		text = "坎"
	else
		huxi = ""
	end
	if cardsInfo.text then
		text = cardsInfo.text
	end
	if cardsInfo.huxi then
		huxi = cardsInfo.huxi
	end
	for idx=1,4 do
		item["card_"..idx]:hide()
		-- item["card_"..idx].img_hu:hide()
	end
	item.card_type:setString(text)
	item.txt_huxi:setString(huxi)
	item.card_type:show()
	for idx, cardV in ipairs(cardsInfo.cbCardList) do
		local paths = self.m_CardConfig:getCardInfoByid(cardV)
		if paths ~= nil then
			local cardNode = item["card_"..idx]:show()
			local imgPath = string.format("%s.png",paths.CardIconB)
			cardNode:loadTexture(imgPath,1)
			-- if cardsInfo.huIdx and cardsInfo.huIdx == idx then
				-- cardNode.img_hu:show()
			-- end
			-- dump(paths)
		else
			-- dump(cardV,"paths = nil")
		end
	end
end

--发送查看战绩功能
function PHZResultLayer:clickBtnZhanji()
	print("=查看战绩！=")
	g_PHZMainLayer:showAllResultLayer(g_PHZMainScene.m_AllZhanJi)
end

function PHZResultLayer:clickBtnClose()
	print("关闭结算界面")
	if g_PHZMainScene.m_bGameCount < g_PHZMainScene.m_bMaxGameCount then
		g_PHZMainLayer:isShowZhunBeiBtn(true)
	end
	self:removeFromParent()
end

function PHZResultLayer:clickBtnResult()
	print("返回大厅")
	g_PHZMainLayer:disbandGroup()
	if g_PHZMainScene.m_bGameCount < g_PHZMainScene.m_bMaxGameCount then
		g_PHZMainLayer:isShowZhunBeiBtn(true)
	end
	self:removeFromParent()
end

function PHZResultLayer:clickBtnAgain()
	print("再来一局")
	g_PHZMainLayer:isShowZhunBeiBtn(true)
	self:removeSelf()
end

function PHZResultLayer:setBtnIsResult()
	if tolua.isnull(self.btn_zhanji) == false then
		self.btn_zhanji:setEnabled(true)
	end
end

return PHZResultLayer