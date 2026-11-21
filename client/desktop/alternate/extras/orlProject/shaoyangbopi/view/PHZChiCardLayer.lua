local phzServer = import("shaoyangbopi.handle.PHZSendHandle")
local GameLogic = require("shaoyangbopi.logic.GameLogic")
local CardConfig = require("shaoyangbopi.logic.CardConfig")
local CardSprite = require("shaoyangbopi.models.CardSprite")
local PHZChiCardLayer = class("PHZChiCardLayer", function ()
   return cc.CSLoader:createNode("shaoyangbopi/res/PHZChiCardLayer.csb")
end)
local scale = 1.7
PHZChiCardLayer.TAG_SQ = 1
PHZChiCardLayer.Card_width = 65 * (scale-0.2)
local maxCell = 10

function PHZChiCardLayer:ctor(cbIndex,curCard)
	
	self.m_CurCard = curCard
	self.m_CardIndex = clone(cbIndex)

	self.m_GameLogic = GameLogic:new()
    self.m_CardConfig = CardConfig:new()

    self.firstCard = {}
    self.secondCard = {}
    self.threeCard = {}

    self.firstAllData = {}
    self.secondAllData = {}
    self.threeAllData = {}

    self.secondCardIndex = {}
    self.threeCardIndex = {}

    self.isAddHeight = false

	self:setNodeEventEnabled(true)
	self:initUI()

    g_PHZMainScene:setRootSize(self)
end

function PHZChiCardLayer:onEnter()
end

function PHZChiCardLayer:onExit()
	self.firstCard = {}
	self.secondCard = {}
	self.threeCard = {}

	self.firstAllData = {}
    self.secondAllData = {}
    self.threeAllData = {}

    self.secondCardIndex = {}
    self.threeCardIndex = {}

    self.isAddHeight = false
end

function PHZChiCardLayer:onCallBack(_tag)
	if _tag == PHZChiCardLayer.TAG_SQ then
		self:clickBtnSQ()
	end
end

--点击收起按钮
function PHZChiCardLayer:clickBtnSQ()
	print("点击收起按钮")
	-- phzServer:CLI_PASS()
	self:setVisible(false)
	g_PHZMainLayer.PHZOprorateNode:setVisible(true)
end

function PHZChiCardLayer:initUI()

    self.BG_1 = self:getChildByName("phz_bg5_1")
    self.BG_2 = self.BG_1:getChildByName("phz_bg5_2")
    self.BG_3 = self.BG_2:getChildByName("phz_bg5_3")

    self.BG_2:setVisible(false)
    self.BG_3:setVisible(false)

	-- self.btn_sq = self.BG_1:getChildByName("btn_sq")

	self.btn_sq = self:getChildByName("btn_sq")
	self.btn_sq:setTag(PHZChiCardLayer.TAG_SQ)
	self.btn_sq:onClick(function(event)
		local target = event.target
		self:onCallBack(target:getTag())
	end)
	self.listView_1 = self.BG_1:getChildByName("ListView_1")
	self.listView_2 = self.BG_2:getChildByName("ListView_2")
	self.listView_3 = self.BG_3:getChildByName("ListView_3")

	self.listView_1:removeAllItems()
	self.listView_2:removeAllItems()
	self.listView_3:removeAllItems()

	self.BGList = {self.BG_1,self.BG_2,self.BG_3}
	self.listViewArr = {self.listView_1,self.listView_2,self.listView_3}

 	local curIndex = self.m_GameLogic:SwitchToCardIndex(self.m_CurCard)

 	print("==当前吃牌的index==",curIndex)

 	for k,v in pairs(self.m_CardIndex) do
		if v >= 3 then
			self.m_CardIndex[k] = 0
		end
	end

	self.m_CardIndex[curIndex]=self.m_CardIndex[curIndex]+1

	local tempArr = clone(self.m_CardIndex)
	self.firstAllData =  self.m_GameLogic:get_all_chipai(tempArr,curIndex)
	dump(self.firstAllData)
	self:refreshListView(1,self.listView_1,self.firstAllData)
	
	local tempChiPaiNum = #self.firstAllData or 0
	if tempChiPaiNum > maxCell then
		tempChiPaiNum = maxCell
	end
	self.BGList[1]:setContentSize(60+tempChiPaiNum*PHZChiCardLayer.Card_width,206)
	self.listView_1:setContentSize(tempChiPaiNum*PHZChiCardLayer.Card_width,170)

end

--发送吃牌数据
function PHZChiCardLayer:InsertValueToChiArr(sendData,arr,curIndex)
	for i,v in ipairs(sendData) do
		if v == curIndex then
			table.remove(sendData,i)
			break
		end
	end

	for i,v in ipairs(sendData) do
		local tempV = self.m_GameLogic:SwitchIndexToCardID(v)
		table.insert(arr,tempV)
	end
	return arr
end
--发送比牌数据
function PHZChiCardLayer:InsertValueToBIArr(sendData1,sendData2,arr)
	for i,v in ipairs(sendData1) do
		local tempV = self.m_GameLogic:SwitchIndexToCardID(v)
		local tempArr = {value = tempV}
		table.insert(arr,tempArr)
	end
	if sendData2 == nil then return arr end
	for i,v in ipairs(sendData2) do
		local tempV = self.m_GameLogic:SwitchIndexToCardID(v)
		local tempArr = {value = tempV}
		table.insert(arr,tempArr)
	end
	return arr
end

function PHZChiCardLayer:getBiCardValue(cardIndex)
	local tempCardV = cardIndex
	if tempCardV > 9 then
		tempCardV = tempCardV + 7
	else
		tempCardV = tempCardV + 1
	end
	return tempCardV
end

--点击第几个listview,中的第几行colV
function PHZChiCardLayer:clickListViewByIndex(listViewIndex,colV)
	local curIndex = self.m_GameLogic:SwitchToCardIndex(self.m_CurCard)

	local tempBiCard = self:getBiCardValue(curIndex)

	local allItems = self.listViewArr[listViewIndex]:getChildren()
	for i=1,#allItems do
		allItems[i]:getChildByName("tempCell"):hideSelectedIMG()
	end

	if listViewIndex == 1 then
		self.firstCard = self.firstAllData[colV]
		self.secondCard = {}
		self.threeCard = {}

		self.BGList[3]:setVisible(false)

		local tempArr = clone(self.m_CardIndex)
		local tempdata = self.m_GameLogic:get_all_bipai(tempArr,curIndex,self.firstCard)
		if #tempdata > 0 then
			self.BGList[2]:setVisible(true)
			self.secondAllData = tempdata
			self.secondCardIndex = self.m_GameLogic:clearCardByCardArr(tempArr,self.firstCard,-1)
			self:refreshListView(listViewIndex+1,self.listViewArr[listViewIndex+1],tempdata)
			
			--by changed zzy
			local tempChiPaiNum = #self.secondAllData or 0
			if tempChiPaiNum > maxCell then
				tempChiPaiNum = maxCell
			end
			self.BGList[2]:setContentSize(15+tempChiPaiNum*PHZChiCardLayer.Card_width,206)
			self.listView_2:setContentSize(tempChiPaiNum*PHZChiCardLayer.Card_width,170)

		else
			print("第一列，直接发送吃牌列表")
			local chipaiArr = {}
			chipaiArr = self:InsertValueToChiArr(self.firstCard,chipaiArr,curIndex)
			phzServer:CLI_PLAYER_CHI_CARD(chipaiArr[1],chipaiArr[2])
			print("第一列，直接发送吃牌列表")
			print("第一列，直接发送吃牌列表")
			print("第一列，直接发送吃牌列表")
			print("第一列，直接发送吃牌列表")

			dump(chipaiArr)
			g_PHZChiCardLayer = nil
			self:removeFromParent()
		end


	elseif listViewIndex == 2 then
		self.secondCard = self.secondAllData[colV]
		local tempArr = clone(self.secondCardIndex)
		tempdata = self.m_GameLogic:get_all_bipai(tempArr,curIndex,self.secondCard)
		if #tempdata > 0 then
			self.BGList[3]:setVisible(true)
			local size = self.BGList[1]:getContentSize()
			self.threeAllData = tempdata
			self:refreshListView(listViewIndex+1,self.listViewArr[listViewIndex+1],tempdata)

			--by changed zzy
			local tempChiPaiNum = #self.threeAllData or 0
			if tempChiPaiNum > maxCell-1 then
				tempChiPaiNum = maxCell-1
			end
			self.BGList[3]:setContentSize(15+tempChiPaiNum*PHZChiCardLayer.Card_width,206)
			self.listView_3:setContentSize(11+tempChiPaiNum*PHZChiCardLayer.Card_width,170)

			if self.isAddHeight  then return end
			for i=1,3 do
				-- local posY = self.BGList[i]:getPositionY()
				-- self.BGList[i]:setPositionY(posY+size.height)

			end
			self.isAddHeight = true
		else
			print("==第二列，直接发送列表==")
			local chipaiArr = {}
			chipaiArr = self:InsertValueToChiArr(self.firstCard,chipaiArr,curIndex)
			local bipaiArr = {}
			bipaiArr = self:InsertValueToBIArr(self.secondCard,nil,bipaiArr)
			print("==第二列，直接发送列表==")
			print("==第二列，直接发送列表==")
			print("==第二列，直接发送列表==")
			dump(chipaiArr)
			dump(bipaiArr)
			dump(tempBiCard)
			print("=======8888888888888===curIndex===",curIndex)
			print("=======8888888888888===tempBiCard===",tempBiCard)
			phzServer:CLI_PLAYER_CHI_CARD(chipaiArr[1],chipaiArr[2], tempBiCard,bipaiArr)
			-- phzServer:CLI_PLAYER_BI_CARD(tempBiCard,3,bipaiArr)
			g_PHZChiCardLayer = nil
			self:removeFromParent()
		end

	elseif listViewIndex == 3 then
		self.threeCard = self.threeAllData[colV]
		print("第三列发送成功")
		local chipaiArr = {}
		chipaiArr = self:InsertValueToChiArr(self.firstCard,chipaiArr,curIndex)
		local bipaiArr = {}
		bipaiArr = self:InsertValueToBIArr(self.secondCard,self.threeCard,bipaiArr)
		phzServer:CLI_PLAYER_CHI_CARD(chipaiArr[1],chipaiArr[2], tempBiCard,bipaiArr)
		-- phzServer:CLI_PLAYER_BI_CARD(tempBiCard,6,bipaiArr)
		print("第三列发送成功")
		print("第三列发送成功")
		print("第三列发送成功")
		dump(chipaiArr)
		dump(tempBiCard)
		print("=======8888888888888===curIndex===",curIndex)
		print("=======8888888888888===tempBiCard===",tempBiCard)
		dump(bipaiArr)
		g_PHZChiCardLayer = nil
		self:removeFromParent()
	end
end

function PHZChiCardLayer:refreshListView(listViewIndex,_listView,data)
	_listView:removeAllItems()
	local cell = require("shaoyangbopi.view.PHZChoiceCardCell")
	for i,v in ipairs(data) do
		self:addCell(listViewIndex,_listView,cell,v,i)
	end
end

function PHZChiCardLayer:addCell(listViewIndex,_listView,cell,data,index)
	if #data == 0 then return end
	local Widget = ccui.Widget:create()
	local item = cell.new(self,Widget,data,index,listViewIndex)
	dump(item:getAnchorPoint())
	-- item:setAnchorPoint(0.5,0.5)
	item:setPositionY(-50)
	item:setScale(scale)
	item:setName("tempCell")
	Widget:addChild(item)
	Widget:setContentSize(100,170)

	_listView:pushBackCustomItem(Widget)
end
	
return PHZChiCardLayer	