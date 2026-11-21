local phzServer = import("yuanjiangguihz.handle.PHZSendHandle")
local GameLogic = require("yuanjiangguihz.logic.GameLogic")
local PHZOprorateNode = class("PHZOprorateNode")


function PHZOprorateNode:ctor(phzoprorateNode)
	self.m_GameLogic = GameLogic:new()
	-- self:setNodeEventEnabled(true)
	self.phzoprorateNode = phzoprorateNode
	self:initUI()

end

function PHZOprorateNode:initUI()
	self.btn_hu = self.phzoprorateNode:getChildByName("btn_hu")
	self.btn_piao = self.phzoprorateNode:getChildByName("btn_piao")
	self.btn_liu = self.phzoprorateNode:getChildByName("btn_liu")
	self.btn_peng = self.phzoprorateNode:getChildByName("btn_peng")
	self.btn_chi = self.phzoprorateNode:getChildByName("btn_chi")
	self.btn_wai = self.phzoprorateNode:getChildByName("btn_wai")
	self.btn_close = self.phzoprorateNode:getChildByName("btn_close")

    self.btn_hu:onClick(handler(self, self.clickBtnHu))
    self.btn_piao:onClick(handler(self, self.clickBtnPiao))
    self.btn_liu:onClick(handler(self, self.clickBtnLiu))
    self.btn_peng:onClick(handler(self, self.clickBtnPeng))
    self.btn_chi:onClick(handler(self, self.clickBtnChi))
    self.btn_wai:onClick(handler(self, self.clickBtnWai))
    self.btn_close:onClick(handler(self, self.handleNode))

	self.btnArr = {
		self.btn_hu,
		self.btn_piao,
		self.btn_liu,
		self.btn_peng,
		self.btn_chi,
		self.btn_wai,
		-- self.btn_close,
	}
end

function PHZOprorateNode:onEnter()
end

function PHZOprorateNode:onExit()
end

function PHZOprorateNode:isShowOporateNode(isShow)
	isShow = isShow or false
	if isShow == false then
		self:hide()
	else
		self:show()
	end
end

--点击胡牌按钮
function PHZOprorateNode:clickBtnHu()
	print("玩家进行胡牌")
	self:isShowOporateNode(false)
	phzServer:CLI_PLAYER_HU_CARD()
	self:hide()
end

--点击碰按钮
function PHZOprorateNode:clickBtnPeng()
	print("玩家进行碰牌")
	phzServer:CLI_PLAYER_PENG_CARD()
	self:isShowOporateNode(false)
	self:hide()
end

function PHZOprorateNode:clickBtnPiao()
	print("玩家飘牌")
	phzServer:CLI_PLAYER_PIAO_CARD()
	self:isShowOporateNode(false)
	self:hide()
end

function PHZOprorateNode:clickBtnLiu()
	print("玩家溜牌")
	local curCard = g_PHZMainScene:getCurrentCard()
	local type_liu = 1
	local tempIndex = g_CardScene.m_CardIndex
	local tempCardIndex = {}
	local tempMyChairArr = g_PHZMainScene:get_my_down_card()
	local lius = {}
	for idx,value in ipairs(tempMyChairArr) do
		if value.type == g_379.t_wai and value.curCard == curCard then
			local curIndex = self.m_GameLogic:SwitchToCardIndex(curCard)
			table.insert(tempCardIndex, curIndex)
		end
	end

	local waiCard = {}
	for idx,weaveItem in ipairs(g_CardScene.m_WeaveItem[g_379.myViewId] or {}) do
		if weaveItem.type == g_379.t_wai then
			waiCard[weaveItem.curCard] = weaveItem.count
        end  
	end

	for k,v in pairs(tempIndex) do
		local card = GameLogic:SwitchIndexToCardID(k)
		local num = lius[card] or 0
		num = num + v
		if card == curCard then
			num = num + 1
		end
		if num == 4 then
			table.insert(tempCardIndex, k)
		else
			local num = waiCard[card] or 0
			num = num + v
			if num == 4 then
				table.insert(tempCardIndex, k)
			end
		end
	end
	
	if #tempCardIndex == 1 then
		local card = self.m_GameLogic:SwitchIndexToCardID(tempCardIndex[1])
		phzServer:CLI_PLAYER_LIU_CARD(card)
	else
		g_PHZMainLayer:AddChiCardLayer(tempIndex, 1, type_liu, tempCardIndex)
	end

	print("==当前==curCard==",tempCardIndex)
	-- self:isShowOporateNode(false)
	self:hide()
end

function PHZOprorateNode:clickBtnWai()
	print("玩家歪牌")
	phzServer:CLI_PLAYER_WAI_CARD()
	self:isShowOporateNode(false)
	self:hide()
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
        dump(tempIndex)
        local tempCardIndex = clone(tempIndex)
        local tempBiCardIndex = clone(tempIndex)
        -- for k,v in pairs(tempCardIndex) do
		-- 	if v >= 3 then
		-- 		tempCardIndex[k] = 0
		-- 	end
		-- end

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
	self:hide()
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


--点击跑按钮
function PHZOprorateNode:clickBtnPao()
	print("玩家进行跑")
	self:isShowOporateNode(false)
	phzServer:CLI_PLAYER_PAO_CARD()

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
	local oldX = -155.81
    for idx,node in ipairs(self.btnArr) do
		if node:isVisible() then
			local width = node:getContentSize().width
			-- oldX = oldX - width / 2
            node:setPositionX(oldX)
            oldX = oldX - (width + 8)
        end
	end
	
end


function PHZOprorateNode:refreshListView()
	local this = self
	local cell = require("yuanjiangguihz.view.PHZChoiceCardCell")
	--test
	self.data = {{1,2,3},{2,5,3},{2,3,10},{2,3,10}}

	if #self.data < 1 then return end

	local TableView = require("yuanjiangguihz.logic.TableView")
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
	self:hide()
end	
	
function PHZOprorateNode:show()
	self.phzoprorateNode:show()
end

function PHZOprorateNode:hide()
	self.phzoprorateNode:hide()
end

return PHZOprorateNode	