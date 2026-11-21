local phzServer = import("ldfpaofa.handle.PHZSendHandle")
local GameLogic = require("ldfpaofa.logic.GameLogic")
local PHZResultLayer = class("PHZResultLayer", function ()
   return cc.CSLoader:createNode("ldfpaofa/res/roundEndingLayer.csb")
end)
local CardConfig = require("ldfpaofa.logic.CardConfig")
PHZResultLayer.BTN_CLOSE = 1
PHZResultLayer.BTN_RETURN = 2
PHZResultLayer.BTN_AGAIN = 3
PHZResultLayer.BTN_ZHANJI = 4
local cardW = 15
local cardH = 125
local DI_CARD_SCALE = 0.75
local HU_TYPE_IMG_PATH = "ldfpaofa/res/setting/HuType_"

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
	for k,v in pairs(self.data.userArr) do
		if v.ti_count > 0 then
			for k,v2 in pairs(v.tiCardArr) do
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
			for k,v2 in pairs(v.paoCardArr) do
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
			for k,v2 in pairs(v.weiCardArr) do
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
			for k,v2 in pairs(v.penCardArr) do
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
			for k2,v2 in pairs(v.chiCardArr) do
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
			for k2,v2 in pairs(v.biCardArr) do
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

			if self.data.groupType == 1 then
				weaveItem.cbWeaveKind = AK_CHI
				weaveItem.text = "吃"
			elseif self.data.groupType == 2 then
				weaveItem.cbWeaveKind = AK_PENG
				weaveItem.text = "碰"
			elseif self.data.groupType == 3 then
				weaveItem.cbWeaveKind = AK_SAO
				weaveItem.text = "偎"
			elseif self.data.groupType == 4 then
				weaveItem.cbWeaveKind = AK_NULL
			end

			--local xishu = 0
			--if self.data.groupType ~= 4 then
			--	xishu = self.m_GameLogic:GetWeaveHuXi(weaveItem)
			--end

			--table.insert(self.huxiArrData,xishu)
			table.insert(self.cardWeaItem[v.seat_id],weaveItem)
		end
		if v.cardGroupCount >0 then
			for k2,v2 in pairs(v.cardGroupArr) do
				local weaveItem = {}
				weaveItem.cbCardList = {}
				weaveItem.cbCardList = v2.cards
				weaveItem.cbComfrom = 1

				if v.groupType == 1 then
					weaveItem.cbWeaveKind = AK_NULL
					weaveItem.text = ""
				elseif v.groupType == 2 then
					weaveItem.cbWeaveKind = AK_NULL
					weaveItem.text = ""
				elseif v.groupType == 3 then
					weaveItem.cbWeaveKind = AK_NULL
					weaveItem.text = ""
				end
                --
				--local xishu = self.m_GameLogic:GetWeaveHuXi(weaveItem)
				--table.insert(self.huxiArrData,xishu)
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
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			self:onCallBack(sender:getTag())
    		end
    	end
    end
	self.floor = self:getChildByName("floor")
	self.floor:getChildByName("room_lb"):setString("房间号："..g_PHZMainScene.m_nRoomID)
	--local timeStr = os.date("%Y-%m-%d %H:%M:%S",data["time"])
	--self.floor:getChildByName("time_lb"):setString(timeStr)
	self.show_plane= self.floor:getChildByName("show_plane")
    --self.btn_close = self:getChildByName("result_bg")
    self.btn_again = self.floor:getChildByName("btn_again")
    self.btn_zhanji = self.floor:getChildByName("btn_zhanji")
	self.m_diCardBg = self.floor:getChildByName("diLayout")
	self.m_diCardBg:removeAllChildren()
    -- self.btn_close:setTag(PHZResultLayer.BTN_CLOSE)
    self.btn_again:setTag(PHZResultLayer.BTN_AGAIN)
    self.btn_zhanji:setTag(PHZResultLayer.BTN_ZHANJI)
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
    -- self.btn_close:addTouchEventListener(onTouchButton)
    self.btn_again:addTouchEventListener(onTouchButton)
    self.btn_zhanji:addTouchEventListener(onTouchButton)
	for i = 0, 2 do
		local player = self.show_plane:getChildByName("player"..(i+1).."_plane")
		player:setVisible(false);
		for k = 1,9 do
			self.cardNodeArr[i][k] = player:getChildByName("node_card_"..k):setVisible(false)
			self.cardNodeArr[i][k]:removeAllChildren()
			self.cardTypeArr[i][k] = player:getChildByName("card_type_"..k):setVisible(false)
			self.cardTypeArr[i][k]:setString("")
		end
		self.playerZiMo[i+1] = player:getChildByName("isZiMo"):setString("")
		self.playHeadimg[i+1] = player:getChildByName("head")
		self.playerHu[i+1] = player:getChildByName("hu_signal"):setVisible(false)
		self.playName[i+1] = player:getChildByName("nick_lb"):setString("")
		self.playJF[i+1] = player:getChildByName("score_lb"):setString(0)
		--self.playYou[i+1] = player:getChildByName("score_zi"):setString(0)
		--self.playWinOrLose[i] = player:getChildByName("result_img_"..i)

	end
	self.playerTitle =self.show_plane:getChildByName("title_txt")
	self.playerTitle:setString("")

    self.img_huCard = self:getChildByName("hucardimg")


    self:refreshCardArr()
    self:refreshPlayerInfo()
end


function PHZResultLayer:refreshCardArr()
	for k,v in pairs(self.data.userArr) do
		for k1,v2 in pairs(self.cardWeaItem[v.seat_id]) do
			self.cardNodeArr[v.seat_id][k1]:setVisible(true)
			self.cardTypeArr[v.seat_id][k1]:setVisible(true)
			local text = ""
			if AK_NULL == v2.cbWeaveKind then

			elseif AK_SAO_EX == v2.cbWeaveKind then
				text = "扫穿"
			elseif AK_SAO == v2.cbWeaveKind then
				text = "扫"
			elseif AK_SAO_BAD == v2.cbWeaveKind then
				text = "臭扫"
			elseif AK_DUO == v2.cbWeaveKind then
				text = "开舵"
			elseif AK_PENG == v2.cbWeaveKind then
				text = "碰"
			elseif AK_CHI == v2.cbWeaveKind then
				text = "吃"
			elseif AK_KAN == v2.cbWeaveKind then
				text = "坎"
			end
			if v2.text then
				text = v2.text
			end
			self.cardTypeArr[v.seat_id][k1]:setString(text)
			local cell = require("ldfpaofa.view.PHZResultCardCell")
			dump(v2,"cell.new(v2)")
			dump(v2.cbWeaveKind,"v2.cbWeaveKind ")
			local item = cell.new(v2)
			item:setPosition(cc.p(0,0))
			self.cardNodeArr[v.seat_id][k1]:addChild(item)
		end
	end
	for k,v in pairs(self.data.currCardArr) do
		local imgPath = "ldfpaofa/res/CardLitter/Card_miniature_000.png"
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
		--cardObj:setVisible(false)
		self.m_diCardBg:addChild(cardObj)
		--local callFuncAc = cc.CallFunc:create(function ()
		--	cardObj:setVisible(true)
		--end)
		--local delay= cc.DelayTime:create(k* 0.05)
		--local seq  = cc.Sequence:create(delay,callFuncAc)
		--cardObj:runAction(seq)
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
		local imgPath = "ldfpaofa/res/other/bottom_lose.png"
		self.playerTitle:setString(text)
		-- self.show_plane:loadTexture(imgPath)
		self.show_plane:getChildByName("player"..(v.seat_id+1).."_plane"):setVisible(true)
		if v.uid == USER_INFO.uid then
			self.playName[v.seat_id+1]:setString(require("hall.GameCommon"):formatNick( USER_INFO.nick, 3))
			require("hall.GameCommon"):getUserHead(USER_INFO.icon_url,v.uid, USER_INFO.sex, self.playHeadimg[v.seat_id+1], 87, false, USER_INFO.nick)
		else
			self.playName[v.seat_id+1]:setString(require("hall.GameCommon"):formatNick( g_PHZMainScene.otherInfo[v.uid].nickName, 3))
			require("hall.GameCommon"):getUserHead(g_PHZMainScene.otherInfo[v.uid].portrait,v.uid,  g_PHZMainScene.otherInfo[v.uid].sex, self.playHeadimg[v.seat_id+1], 87, false,  g_PHZMainScene.otherInfo[v.uid].nickName)
		end


		local huxi = 0;
		if v.m_turnBlc/100 > 0 then
			huxi = "+"..(v.m_turnBlc/100)
		else
			huxi = v.m_turnBlc/100
		end
		self.playJF[v.seat_id+1]:setString(huxi)

	end
	for k2,v2 in pairs(self.data.huUserArr) do
		self.playerHu[v2.seat_id+1]:setVisible(true)
		if v2.uid == USER_INFO.uid then
			local imgPath = "ldfpaofa/res/other/bottom_win.png"
			local text = "胜局"
			self.playerTitle:setString(text)
			-- self.show_plane:loadTexture(imgPath)
		end
	end
	if self.data.nRoundResult ==0 then
		local imgPath = "ldfpaofa/res/other/bottom_lose.png"
		local text = "流局"
		-- self.show_plane:loadTexture(imgPath)
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
		if g_PHZMainScene.m_bGameCount < g_PHZMainScene.m_bMaxGameCount then
			g_PHZMainLayer:isShowZhunBeiBtn(true)
		end
		self:removeFromParent()
	end

	function PHZResultLayer:clickBtnResult()
		print("返回大厅")
		-- phzServer:CLI_BROADCAST_GROUP_RESULT()
		g_PHZMainLayer:disbandGroup()
		if g_PHZMainScene.m_bGameCount < g_PHZMainScene.m_bMaxGameCount then
			g_PHZMainLayer:isShowZhunBeiBtn(true)
		end
		self:removeFromParent()
		-- require("hall.GameTips"):showTips("提示", "quitRoom", 1, "确定要退出房间么？",_,self.quitRoom)
	end

	function PHZResultLayer:clickBtnAgain()
		print("再来一局")
		--if g_PHZMainScene.m_bGameCount < g_PHZMainScene.m_bMaxGameCount then
			g_PHZMainLayer:isShowZhunBeiBtn(true)
		--end
		self:removeSelf()
	end

end
function PHZResultLayer:setBtnIsResult()
	if tolua.isnull(self.btn_zhanji) == false then
		self.btn_zhanji:setEnabled(true)
	end

end
return PHZResultLayer