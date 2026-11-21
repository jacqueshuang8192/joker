local phzServer = import("byzp.handle.PHZSendHandle")
local GameLogic = require("byzp.logic.GameLogic")
local PHZResultLayer = class("PHZResultLayer", function ()
   return cc.CSLoader:createNode("byzp/res/roundEndingLayer.csb")
end)
local CardConfig = require("byzp.logic.CardConfig")
PHZResultLayer.BTN_CLOSE = 1
PHZResultLayer.BTN_RETURN = 2
PHZResultLayer.BTN_AGAIN = 3
PHZResultLayer.BTN_ZHANJI = 4
local cardW = 15
local cardH = 125
local DI_CARD_SCALE = 0.75
local HU_TYPE_IMG_PATH = "byzp/res/setting/HuType_"

local HU_TYPE_STRING = {
	"无效",
	"大团圆",
	"背靠背",
	"碰碰胡",
	"行行息",
	"耍猴",
	"海底胡",
	"十八大",
	"十六小",
	"天胡",
	"地湖",
	"红胡",
	"黑胡",
	"点胡",
	"听胡",
	"黄庄",
}

function PHZResultLayer:ctor(data)
	dump(data,"=====打开玩家结算界面=====")
	GameUtils.setNodeNameBindObj(self)
	local color = cc.c3b(34, 52, 49)
	viewMgr:setMask( self, true, 255, color )
	viewMgr:setScenePos( self ) 
	local size = cc.Director:getInstance():getVisibleSize()
    -- local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
	self.maskLayout:setContentSize(size)
	self.data = data
	self.m_GameLogic = GameLogic:new()
	self.cardConfig_ = CardConfig:new()
	self.playHeadimg = {}
	self.playName = {}
	self.playJF = {}   --胡息
	self.playYou = {}  --油子
	self.playWinOrLose = {} --输赢 背景
	self.playerBg = nil;
	self.playerTitle = nil;
	self.playWinOrLoseText = {} --输赢 文字
	self.playerZiMo = {}
	self.playerHu = {}
	self.huxiArr = {}
	self.cardNodeArr = {} 
	self.cardTypeArr = {}
	self.huxiArrData = {}
	self.cardWeaItem = {}

	self.huTypeArr = {}    --胡牌类型集合
	self:initData()
	self.m_index_handle = 0

	self:setNodeEventEnabled(true)
	self:setData()
	self:initUI()

	--self:initHuType()

	--self:refreshHuType()

	--if g_PHZMainScene.m_bGameCount == g_PHZMainScene.m_bMaxGameCount then
	--	g_PHZMainScene.m_isActive = true
	--else
	--	g_PHZMainScene.m_isActive = false
	--end
	g_PHZMainScene.m_isActive = true
	-- self:getChildByName("result_bg_2"):setScale(g_PHZMainScene:_getScaleParam2())
	--self:getChildByName("result_bg"):setScale(g_PHZMainScene:_getScaleParam2())
	-- g_PHZMainScene:setRootSize(self)
end
function PHZResultLayer:initData()
	for i = 0, 2 do
		self.cardWeaItem[i] ={}
		self.huTypeArr[i] = {}
		self.cardNodeArr[i] = {}
		self.cardTypeArr[i] = {}
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
	for k,v in ipairs(self.data.userArr) do
		if v.ti_count > 0 then
			for k,v2 in ipairs(v.tiCardArr) do
				--table.insert(self.huxiArrData,v.xishu)
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
			for k,v2 in ipairs(v.paoCardArr) do
				--table.insert(self.huxiArrData,v.xishu)
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
			for k,v2 in ipairs(v.weiCardArr) do
				--table.insert(self.huxiArrData,v.xishu)
				-- local tempCardArr = {v.cardvalue,0x00,0x00}
				local weaveItem = {}
				weaveItem.cbWeaveKind = AK_PENG
				weaveItem.text = "偎"
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = {v2.card,0x00,0x00}
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
		if v.pen_count > 0 then
			for k,v2 in ipairs(v.penCardArr) do
				--table.insert(self.huxiArrData,v.xishu)
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
			for k2,v2 in ipairs(v.chiCardArr) do
				--table.insert(self.huxiArrData,v.xishu)
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
			for k2,v2 in ipairs(v.biCardArr) do
				--table.insert(self.huxiArrData,v.xishu)
				local weaveItem = {}
				weaveItem.cbWeaveKind = AK_CHI
				weaveItem.text = "吃"
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = v2.cards
				weaveItem.cbComfrom = 0
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		end
		-- if v.isHu == 0 then
			local WeaveArray,ArrayCount = self.m_GameLogic:getCurhandCard(v.handCardArr)
			dump(WeaveArray,"userHandCardArr")
			for k3, v3 in ipairs(WeaveArray) do
				local weaveItem = {}
				weaveItem.cbCardList = {}
				weaveItem.cbCardList =  v3
				weaveItem.cbComfrom = 0
				weaveItem.cbWeaveKind = AK_NULL
				table.insert(self.cardWeaItem[v.seat_id],weaveItem)
			end
		-- end
	end
	-- for k,v in ipairs(self.data.huUserArr) do
	-- 	if v.group_count > 0 then
	-- 		local weaveItem = {}
	-- 		weaveItem.cbCardList = {}
	-- 		weaveItem.cbCardList = v.groupArr
	-- 		weaveItem.cbComfrom = 1

	-- 		if self.data.groupType == 1 then
	-- 			weaveItem.cbWeaveKind = AK_CHI
	-- 			weaveItem.text = "吃"
	-- 		elseif self.data.groupType == 2 then
	-- 			weaveItem.cbWeaveKind = AK_PENG
	-- 			weaveItem.text = "碰"
	-- 		elseif self.data.groupType == 3 then
	-- 			weaveItem.cbWeaveKind = AK_SAO
	-- 			weaveItem.text = "偎"
	-- 		elseif self.data.groupType == 4 then
	-- 			weaveItem.cbWeaveKind = AK_NULL
	-- 		end

	-- 		--local xishu = 0
	-- 		--if self.data.groupType ~= 4 then
	-- 		--	xishu = self.m_GameLogic:GetWeaveHuXi(weaveItem)
	-- 		--end

	-- 		--table.insert(self.huxiArrData,xishu)
	-- 		table.insert(self.cardWeaItem[v.seat_id],weaveItem)
	-- 	end
	-- 	if v.cardGroupCount >0 then
	-- 		for k2,v2 in ipairs(v.cardGroupArr) do
	-- 			local weaveItem = {}
	-- 			weaveItem.cbCardList = {}
	-- 			weaveItem.cbCardList = v2.cards
	-- 			weaveItem.cbComfrom = 1

	-- 			if v.groupType == 1 then
	-- 				weaveItem.cbWeaveKind = AK_NULL
	-- 				weaveItem.text = ""
	-- 			elseif v.groupType == 2 then
	-- 				weaveItem.cbWeaveKind = AK_NULL
	-- 				weaveItem.text = ""
	-- 			elseif v.groupType == 3 then
	-- 				weaveItem.cbWeaveKind = AK_NULL
	-- 				weaveItem.text = ""
	-- 			end
	-- 			--
	-- 			--local xishu = self.m_GameLogic:GetWeaveHuXi(weaveItem)
	-- 			--table.insert(self.huxiArrData,xishu)
	-- 			table.insert(self.cardWeaItem[v.seat_id],weaveItem)
	-- 		end
	-- 	end
	-- end
end

function PHZResultLayer:onEnter()
end

function PHZResultLayer:onExit()
end

function PHZResultLayer:initUI()
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			self:onCallBack(sender:getTag())
    		end
    	end
    end
	self.item_cards:hide()
	self.floor = self:getChildByName("floor")
	self.floor:getChildByName("room_lb"):setString("房间号："..g_PHZMainScene.m_nRoomID)
	--local timeStr = os.date("%Y-%m-%d %H:%M:%S",data["time"])
	--self.floor:getChildByName("time_lb"):setString(timeStr)
	self.show_plane= self.floor:getChildByName("show_plane")
    --self.btn_close = self:getChildByName("result_bg")
    self.btn_return = self.floor:getChildByName("btn_retrun")

    self.btn_again = self.floor:getChildByName("btn_again")
    self.btn_zhanji = self.floor:getChildByName("btn_zhanji")
	if self.data.endGame ==1 then
		self.btn_again:setVisible(false)
		self.btn_zhanji:setVisible(true)
		if g_PHZMainScene.m_isGameOver ==false then
			self.btn_zhanji:setEnabled(false)
		else
			self.btn_zhanji:setEnabled(true)
		end

	else
		self.btn_again:setVisible(true)
		self.btn_zhanji:setVisible(false)
	end
	self.m_diCardBg = self.floor:getChildByName("diLayout")
	self.m_diCardBg:removeAllChildren()
    -- self.btn_close:setTag(PHZResultLayer.BTN_CLOSE)
    self.btn_return:setTag(PHZResultLayer.BTN_RETURN)
    self.btn_again:setTag(PHZResultLayer.BTN_AGAIN)
    self.btn_zhanji:setTag(PHZResultLayer.BTN_ZHANJI)

    -- self.btn_close:addTouchEventListener(onTouchButton)
    self.btn_return:addTouchEventListener(onTouchButton)
    self.btn_again:addTouchEventListener(onTouchButton)
    self.btn_zhanji:addTouchEventListener(onTouchButton)

    self.btn_return:setVisible(false)
	for i = 0, 2 do
		local player = self.show_plane:getChildByName("player_plane_"..(i+1))
		player:setVisible(false);
		
		self.playerZiMo[i+1] = player:getChildByName("isZiMo"):setString("")
		self.playHeadimg[i+1] = player:getChildByName("head")
		self.playerHu[i+1] = player:getChildByName("hu_signal"):setVisible(false)
		player:getChildByName("imgbg_fan"):setVisible(false)
		player:getChildByName("fanCardNode"):setVisible(false)
		player:getChildByName("huCardNode"):setVisible(false)
		player.ListView:removeAllChildren()
		self.playName[i+1] = player:getChildByName("nick_lb"):setString("")
		self.playJF[i+1] = player:getChildByName("score_lb"):setString(0)
		self.playYou[i+1] = player:getChildByName("score_zi"):setString(0)
		--self.playWinOrLose[i] = player:getChildByName("result_img_"..i)

	end
	self.playerTitle =self.show_plane:getChildByName("title_txt")
	self.playerTitle:setString("")

    self.img_huCard = self:getChildByName("hucardimg")


    self:refreshCardArr()
    self:refreshPlayerInfo()
end


function PHZResultLayer:refreshCardArr()
	for k,userInfo in ipairs(self.data.userArr) do
		local player_plane_ = self.show_plane["player_plane_"..userInfo.seat_id+1]
		for idx,cardsInfo in ipairs(self.cardWeaItem[userInfo.seat_id]) do
			if self.cardNodeArr[userInfo.seat_id] then
				
			end
			local item = self.item_cards:clone()
			player_plane_.ListView:pushBackCustomItem(item)
			self:setCardsItems(item, cardsInfo)
		end
	
	end
	for k,v in pairs(self.data.currCardArr) do
		local imgPath = "byzp/res/CardLitter/card_miniature_000.png"
		local cardInfo = self.cardConfig_:getCardInfoByid(v)
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

function PHZResultLayer:setCardsItems( item, cardsInfo)
	item:show()
	GameUtils.setNodeNameBindObj(item)
	local text = ""
	if AK_NULL == cardsInfo.cbWeaveKind then

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
	end
	if cardsInfo.text then
		text = cardsInfo.text
	end
	for idx=1,4 do
		item["card_"..idx]:hide()
	end
	item.card_type:setString(text)
	item.card_type:show()
	for idx, cardV in ipairs(cardsInfo.cbCardList) do
		local paths = self.cardConfig_:getCardInfoByid(cardV)
		if paths ~= nil then
			local cardNode = item["card_"..idx]:show()
			local imgPath = string.format("%s.png",paths.CardIconB)
			cardNode:loadTexture(imgPath)
			dump()
		else
			dump(cardV)
			dump(paths)
		end
	end
end

function PHZResultLayer:refreshPlayerInfo()
	dump(g_PHZMainScene.otherInfo,"玩家==还在==")
	if g_PHZMainScene then
		print("==还在==")
	else
		print("======已经没有了====")
	end

	for k,v in pairs(self.data.userArr) do
		local text = "败局"
		local imgPath = "byzp/res/other/bottom_lose.png"
		self.playerTitle:setString(text)
		self.show_plane:loadTexture(imgPath)
		local player = self.show_plane:getChildByName("player_plane_"..(v.seat_id+1))
		player:setVisible(true)
		if v.uid == USER_INFO.uid then
			self.playName[v.seat_id+1]:setString(require("hall.GameCommon"):formatNick( USER_INFO.nick, 3))
			require("hall.GameCommon"):getUserHead(USER_INFO.icon_url,v.uid, USER_INFO.sex, self.playHeadimg[v.seat_id+1], 87, false, USER_INFO.nick)
		else
			self.playName[v.seat_id+1]:setString(require("hall.GameCommon"):formatNick( g_PHZMainScene.otherInfo[v.uid].nickName, 3))
			require("hall.GameCommon"):getUserHead(g_PHZMainScene.otherInfo[v.uid].portrait,v.uid,  g_PHZMainScene.otherInfo[v.uid].sex, self.playHeadimg[v.seat_id+1], 87, false,  g_PHZMainScene.otherInfo[v.uid].nickName)
		end

		self.playJF[v.seat_id+1]:setString(v.m_oil)
		local youzi = 0;
		if v.m_turnBlc/100 > 0 then
			youzi = "+"..(v.m_turnBlc/100)
		else
			youzi = v.m_turnBlc/100
		end
		self.playYou[v.seat_id+1]:setString(youzi)

		player:getChildByName("huCardNode"):setVisible(false)
	end
	for k2,v2 in pairs(self.data.huUserArr) do
		self.playerHu[v2.seat_id+1]:setVisible(true)
		local player_plane_ = self.show_plane:getChildByName("player_plane_"..(v2.seat_id+1))
		if g_fanCardValue then
			local paths = self.cardConfig_:getCardInfoByid(g_fanCardValue.srcCardDatas[1])
			local imgPath = string.format("%s.png",paths.CardIconB)
			player_plane_.fanCardNode:loadTexture(imgPath)
			player_plane_.fanCardNode:show()
			player_plane_.fanCardNode.num:setString(v2.fanxincount)
			player_plane_.imgbg_fan:show()
		end
		
		if v2.uid == USER_INFO.uid then
			local imgPath = "byzp/res/other/bottom_win.png"
			local text = "胜局"
			self.playerTitle:setString(text)
			self.show_plane:loadTexture(imgPath)
		end
		
		if self.data.m_HuCard ~= 0 then
			local paths = self.cardConfig_:getCardInfoByid(self.data.m_HuCard)
			if paths ~= nil then
				local imgPath = string.format("%s.png",paths.CardIconB)
				player_plane_:getChildByName("huCardNode"):loadTexture(imgPath,1)
				player_plane_:getChildByName("huCardNode"):show()
			end
		end
	end
	if self.data.nRoundResult ==0 then
		local imgPath = "byzp/res/other/bottom_lose.png"
		local text = "流局"
		self.show_plane:loadTexture(imgPath)
		self.playerTitle:setString(text)
	end
	self:setWinOrCloseImg()
	if self.data.nFangPaoSeat >=0 then
		self.playerZiMo[self.data.nFangPaoSeat+1]:setString("放炮")
	end
end

--设置玩家胜平负情况
function PHZResultLayer:setWinOrCloseImg()

	function PHZResultLayer:onCallBack(_tag)
		if _tag == PHZResultLayer.BTN_CLOSE then
			self:clickBtnClose()
		elseif _tag == PHZResultLayer.BTN_RETURN then
			self:clickBtnResult()
		elseif _tag == PHZResultLayer.BTN_AGAIN then
			self:clickBtnAgain()
		elseif _tag == PHZResultLayer.BTN_ZHANJI then
			self:clickBtnZhanji()
		end
	end

	--发送查看战绩功能
	function PHZResultLayer:clickBtnZhanji()
		print("=查看战绩！=")
		g_PHZMainScene.m_isActive = false

		g_PHZMainLayer:showAllResultLayer(g_PHZMainScene.m_AllZhanJi)

		-- phzServer:CLI_BROADCAST_GROUP_RESULT()
	end

	function PHZResultLayer:clickBtnClose()
		print("关闭结算界面")
		g_PHZMainLayer:isShowZhunBeiBtn(true)

		self:removeFromParent()
	end

	function PHZResultLayer:clickBtnResult()
		print("返回大厅")
		-- phzServer:CLI_BROADCAST_GROUP_RESULT()
		g_PHZMainLayer:disbandGroup()
		g_PHZMainLayer:isShowZhunBeiBtn(true)
		self:removeFromParent()
		-- require("hall.GameTips"):showTips("提示", "quitRoom", 1, "确定要退出房间么？",_,self.quitRoom)
	end

	function PHZResultLayer:clickBtnAgain()
		print("再来一局")
		g_PHZMainLayer:isShowZhunBeiBtn(true)

		self:removeFromParent()
	end

end
function PHZResultLayer:removeFromParentView()
	self:removeFromParent()

end
function PHZResultLayer:setBtnIsResult()
	if tolua.isnull(self.btn_zhanji) == false then
		self.btn_zhanji:setEnabled(true)
	end

end
return PHZResultLayer