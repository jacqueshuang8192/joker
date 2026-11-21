local phzServer = import("pengpengzp.handle.PHZSendHandle")
local GameLogic = require("pengpengzp.logic.GameLogic")
local PHZOprorateNode = class("PHZOprorateNode", function ()
   return cc.CSLoader:createNode("pengpengzp/res/PHZOprorateNode.csb")
end)

PHZOprorateNode.TAG_CLOSE = 1
PHZOprorateNode.TAG_HU = 2
PHZOprorateNode.TAG_PENG = 3
PHZOprorateNode.TAG_CHI = 4
PHZOprorateNode.TAG_PAO = 6

function PHZOprorateNode:ctor()
	self.m_GameLogic = GameLogic:new()
	self:setNodeEventEnabled(true)
	self:initUI()
end

function PHZOprorateNode:onEnter()
end

function PHZOprorateNode:onExit()
end

function PHZOprorateNode:onCallBack(_tag)
	if _tag == PHZOprorateNode.TAG_CLOSE then
		self:handleNode()
	elseif _tag == PHZOprorateNode.TAG_HU then
		self:clickBtnHu()
		self:setVisible(false)
	elseif _tag == PHZOprorateNode.TAG_PENG then
		self:clickBtnPeng()
		self:setVisible(false)
	elseif _tag == PHZOprorateNode.TAG_CHI then
		self:clickBtnChi()
		self:setVisible(false)
	elseif _tag == PHZOprorateNode.TAG_PAO then
		self:clickBtnPao()
		self:setVisible(false)
	end
end

function PHZOprorateNode:isShowOporateNode(isShow)
	isShow = isShow or false
	self:setVisible(isShow)
end

--点击胡牌按钮
function PHZOprorateNode:clickBtnHu()
	print("玩家进行胡牌")
	self:isShowOporateNode(false)
	phzServer:CLI_PLAYER_HU_CARD()
end

--点击碰按钮
function PHZOprorateNode:clickBtnPeng()
	print("玩家进行碰牌")
	phzServer:CLI_PLAYER_PENG_CARD()
	self:isShowOporateNode(false)
end

--点击吃按钮
function PHZOprorateNode:clickBtnChi()
	print("==点击吃按钮==")
	self:isShowOporateNode(false)
	local curCard = g_PHZMainScene:getCurrentCard()
	print("==当前==curCard==",curCard)
    if curCard and curCard ~= 0 then
    	print("==将要打来界面==")
        local tempIndex = clone(g_CardScene.m_CardIndex)
        print("=====66666666666=====")
        print("=====66666666666=====")
        print("=====66666666666=====")
        dump(tempIndex)
        
        local tempCardIndex = clone(tempIndex)
        local tempBiCardIndex = clone(tempIndex)

        for k,v in pairs(tempCardIndex) do
			if v >= 3 then
				tempCardIndex[k] = 0
			end
		end

		local curIndex = self.m_GameLogic:SwitchToCardIndex(curCard)

		tempCardIndex[curIndex]=tempCardIndex[curIndex]+1
		local tempArr = clone(tempCardIndex)
		local firstAllData =  self.m_GameLogic:get_all_chipai(tempArr,curIndex)
		local chipaiArr = {}
		chipaiArr = self:InsertValueToChiArr(firstAllData[1],chipaiArr,curIndex)
		print("===chi===")
		dump(chipaiArr)
		for k,v in pairs(chipaiArr) do
			local tempIndex = self.m_GameLogic:SwitchToCardIndex(v)
			tempBiCardIndex[tempIndex] = tempBiCardIndex[tempIndex] - 1
		end
		local tempHaveBi = self:isHaveBiCard(tempBiCardIndex,curIndex)
		
		if #firstAllData == 1 and tempHaveBi == false then
			phzServer:CLI_PLAYER_CHI_CARD(chipaiArr[1],chipaiArr[2])
			self:isShowOporateNode(false)
		else
 			g_PHZMainLayer:AddChiCardLayer(tempIndex,curCard)
		end
    end
end

function PHZOprorateNode:isHaveBiCard(arr,curIndex)
	for k,v in pairs(arr) do
		if k == curIndex and v > 0 then
			return true
		end
	end
	return false
end

--发送吃牌数据
function PHZOprorateNode:InsertValueToChiArr(sendData,arr,curIndex)
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

--显示玩家的
function PHZOprorateNode:show()
	-- body
end

--点击跑按钮
function PHZOprorateNode:clickBtnPao()
	print("玩家进行跑")
	self:isShowOporateNode(false)
	phzServer:CLI_PLAYER_PAO_CARD()

end

function PHZOprorateNode:initUI()

	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.began then
    			sender:setScale(1.1)
    		elseif eventType == ccui.TouchEventType.ended then
    			sender:setScale(1)
    			self:onCallBack(sender:getTag())
    		elseif eventType == ccui.TouchEventType.canceled then
    			sender:setScale(1)
    		end
    	end
    end

	self.btn_close = self:getChildByName("btn_close")
	self.btn_hu = self:getChildByName("btn_hu")
	self.btn_peng = self:getChildByName("btn_peng")
	self.btn_chi = self:getChildByName("btn_chi")
	self.btn_pao = self:getChildByName("btn_pao")

	self.btn_close:setTag(PHZOprorateNode.TAG_CLOSE)
	self.btn_hu:setTag(PHZOprorateNode.TAG_HU)
	self.btn_peng:setTag(PHZOprorateNode.TAG_PENG)
	self.btn_chi:setTag(PHZOprorateNode.TAG_CHI)
	self.btn_pao:setTag(PHZOprorateNode.TAG_PAO)

    self.btn_close:addTouchEventListener(onTouchButton)
    self.btn_hu:addTouchEventListener(onTouchButton)
    self.btn_peng:addTouchEventListener(onTouchButton)
    self.btn_chi:addTouchEventListener(onTouchButton)
    self.btn_pao:addTouchEventListener(onTouchButton)

    self.btnArr = {self.btn_hu,self.btn_peng,self.btn_chi,self.btn_pao}
    self.btn_posArr = {
    	cc.p(140,100),
    	cc.p(256,100),
    	cc.p(372,100),
    	cc.p(488,100),
	}
end

function PHZOprorateNode:setButtonCanClick(data)

	-- data = {0,0,1,0}

	for k,v in pairs(data) do
		if v == 0 then
			self.btnArr[k]:setVisible(false)
		else
			self.btnArr[k]:setVisible(true)
		end
	end

	for k,v in pairs(data) do
		local tempNum = 0
		for k1,v1 in pairs(data) do
			if k1 > k and v1 == 0 then
				tempNum = tempNum + 1
			end
		end

		if v ~= 0 then
			self.btnArr[k]:setPosition(self.btn_posArr[k+tempNum].x,self.btn_posArr[k+tempNum].y)
		end
	end

	-- self:isCanClick(self.btn_hu,data[1])
	-- self:isCanClick(self.btn_peng,data[2])
	-- self:isCanClick(self.btn_chi,data[3])
	-- self:isCanClick(self.btn_pao,data[4])
end

function PHZOprorateNode:setBtnPos( node,index,isCanClickV,handleNum)
	
end

function PHZOprorateNode:isCanClick(node,isCanClickV)
	node:setEnabled(false)
	node:setTouchEnabled(false)
	if isCanClickV == 1 then
		node:setEnabled(true)
		node:setTouchEnabled(true)
	end
end

function PHZOprorateNode:refreshListView()
	local this = self
	local cell = require("pengpengzp.view.PHZChoiceCardCell")
	--test
	self.data = {{1,2,3},{2,5,3},{2,3,10},{2,3,10}}

	if #self.data < 1 then return end

	local TableView = require("pengpengzp.logic.TableView")
	local sizeSource = function(self, index)
		return cc.size(50, 160)
	end
	local loadSoruce = function(self, index)
		local Widget = ccui.Widget:create()
		local item = cell.new(Widget,this.data[index],index)
		Widget:addChild(item)
		Widget:setContentSize(50,160)
		return Widget
	end

	local unloadSoruce = function(self, index)
	end

	TableView.attachTo(self.listView, sizeSource, loadSoruce, unloadSoruce)
	self.listView:initDefaultItems(#self.data)
	self.listView:jumpTo(1)
	self.listView:addScrollViewEventListener(function(ref, type)
		
	end)
end

function PHZOprorateNode:addCell(cell,data,index)
	if not cell then return end
	if not data then return end
	if not index then return end
	local Widget = ccui.Widget:create()
	local item = cell.new(Widget,data,index)
	Widget:addChild(item)
	Widget:setContentSize(50,160)
	self.listView:pushBackCustomItem(Widget)
end

function PHZOprorateNode:handleNode()	
	phzServer:CLI_PASS()
	self:setVisible(false)
end	
	
return PHZOprorateNode	