local GameLogic = require("yuanjiangguihz.logic.GameLogic")
local PHZResultLayer = class("PHZResultLayer", function ()
   return cc.CSLoader:createNode("yuanjiangguihz/res/roundEndingLayer.csb")
end)
local CardConfig = require("yuanjiangguihz.logic.CardConfig")
local cardW = 15
local cardH = 125
local DI_CARD_SCALE = 0.75
local HU_TYPE_IMG_PATH = "yuanjiangguihz/res/setting/HuType_"
local MingTangTxt = {
	[0] = "无效",
	[1] = "9对",
	[2] = "无息平",
	[3] = "大字胡",
	[4] = "小字胡",
	[5] = "黑子胡",
	[6] = "火胡子",
	[7] = "一点朱",
	[8] = "对子息",
	[9] = "行行息",
	[10] = "黑对子胡",
	[11] = "海底",
	[12] = "吊吊手",
	[13] = "大对子胡",
	[14] = "小对子胡",
	[15] = "天胡",
	[16] = "报听",
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

		if v.pen_count > 0 then
			for k,v2 in pairs(v.penCardArr) do
				-- local tempCardArr = {v.cardvalue,v.cardvalue,v.cardvalue}
				local weaveItem = {}
				weaveItem.cbWeaveKind = g_379.t_peng
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = {v2.card,v2.card,v2.card}
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end

		if v.wai_count > 0 then
			for k,card in pairs(v.waiCardArr) do
				local weaveItem = {}
				weaveItem.cbWeaveKind = g_379.t_wai
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = {card,card,card}
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
		if v.liucount > 0 then
			for k,card in pairs(v.liuList) do
				local weaveItem = {}
				weaveItem.cbWeaveKind = g_379.t_liu
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = {card,0x00,0x00,0x00}
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
		if v.piaocount > 0 then
			for k,card in pairs(v.piaoList) do
				local weaveItem = {}
				weaveItem.cbWeaveKind = g_379.t_piao
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = {card,card,card,card}
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end

		if v.chi_count > 0 then
			for k2,v2 in pairs(v.chiCardArr) do
				local weaveItem = {}
				weaveItem.cbWeaveKind = g_379.t_chi
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
				weaveItem.cbWeaveKind = g_379.t_null
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

			if self.data.groupType == 1 then
				weaveItem.cbWeaveKind = g_379.t_chi
			elseif self.data.groupType == 2 then
				weaveItem.cbWeaveKind = g_379.t_peng
			elseif self.data.groupType == 3 then
				weaveItem.cbWeaveKind = g_379.t_wai
			elseif self.data.groupType == 4 then
				weaveItem.cbWeaveKind = g_379.t_null
			end
			table.insert(self.cardWeaItem[v.seat_id],weaveItem)
		end
		if v.cardGroupCount >0 then
			for k2,v2 in pairs(v.cardGroupArr) do
				local weaveItem = {}
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = v2.cards
				weaveItem.cbComfrom = 1
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
	self.player_listview = self.root.show_plane.player_listview
	self.btn_zhanji:hide()
	self.m_diCardBg:removeAllChildren()
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
	
	self.title_txt =self.show_plane:getChildByName("title_txt")
	self.title_txt:setString("")
	for i,userInfo in ipairs(self.data.userArr) do
		local player = self.player:clone()
		player:setName(userInfo.seat_id)
		player:show()
		GameUtils.setNodeNameBindObj(player)
		self.player_listview:pushBackCustomItem(player)
		player.txt_fanshu:setString("")
		player.txt_huxi:setString("")
		player.hu_card:hide()
		player.txt_quanmingtang:setString("")
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
		local imgPath = "yuanjiangguihz/res/CardLitter/Card_miniature_000.png"
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
end

function PHZResultLayer:refreshPlayerInfo()
	local huUser_seatId = -1
	for k2,userInfo in ipairs(self.data.huUserArr) do
		huUser_seatId = userInfo.seat_id
		local player = self.player_listview:getChildByName(userInfo.seat_id)
		player:getChildByName("hu_signal"):setVisible(true)
		-- if userInfo.uid == USER_INFO.uid then
		-- 	local imgPath = "yuanjiangguihz/res/other/bottom_win.png"
		-- 	local text = "胜局"
		-- 	self.title_txt:setString(text)
		-- 	self.show_plane:loadTexture(imgPath)
		-- end
		player.txt_fanshu:setString("番数:"..userInfo.hufan)
		player.txt_huxi:setString("胡息:"..userInfo.huxi)

		local taiStr = ""
		for _,tai in ipairs(userInfo.huTypeArr) do
			if tai.xi == 0 then
				taiStr = taiStr..MingTangTxt[tai.type].." "
			else
				taiStr = taiStr..MingTangTxt[tai.type].."x "..tai.xi.." "
			end
		end
		if taiStr == "" then
			taiStr = "平胡"
		end
		player.txt_quanmingtang:setString(taiStr)
	end
	local text = "败局"
	local imgPath = "yuanjiangguihz/res/other/bottom_lose.png"

	for k,userInfo in pairs(self.data.userArr) do
		local player = self.player_listview:getChildByName(userInfo.seat_id)
		local m_turnBlc = userInfo.m_turnBlc / 100
		if m_turnBlc > 0 then
			if userInfo.uid == USER_INFO.uid then
				imgPath = "yuanjiangguihz/res/other/bottom_win.png"
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

		if userInfo.seat_id ~= huUser_seatId then
			player.hu_signal:hide()
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
	-- 	local imgPath = "yuanjiangguihz/res/other/bottom_lose.png"
	-- 	local text = "流局"
	-- 	self.show_plane:loadTexture(imgPath)
	-- 	self.title_txt:setString(text)
	-- end
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
	local text = ""
	if g_379.t_null == cardsInfo.cbWeaveKind then

	elseif g_379.t_wai == cardsInfo.cbWeaveKind then
		text = "歪"
	elseif g_379.t_peng == cardsInfo.cbWeaveKind then
		text = "碰"
	elseif g_379.t_chi == cardsInfo.cbWeaveKind then
		text = "吃"
	elseif g_379.t_kan == cardsInfo.cbWeaveKind then
		text = "坎"
	elseif g_379.t_liu == cardsInfo.cbWeaveKind then
		text = "溜"
	elseif g_379.t_piao == cardsInfo.cbWeaveKind then
		text = "飘"
	end

	for idx=1,4 do
		item["card_"..idx]:hide()
		-- item["card_"..idx].img_hu:hide()
	end
	item.card_type:setString(text)
	item.txt_huxi:setString("")
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