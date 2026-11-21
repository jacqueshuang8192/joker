local CardConfig = require("byzp.logic.CardConfig")
local PHZChoiceCardCell = class("PHZChoiceCardCell", function ()
   return cc.CSLoader:createNode("byzp/res/PHZChoiceCardCell.csb")
end)

PHZChoiceCardCell.Card_NUM = 3

PHZChoiceCardCell.TAG_CARD_BTN = 1

function PHZChoiceCardCell:ctor(chiCardlayer,parent,data,index,listViewIndex)
	self.chiCardlayer = chiCardlayer
	self.parent = parent 
	self.data = data
	self.index = index or 1
	self.listViewIndex = listViewIndex
	self:setNodeEventEnabled(true)
	self.cardConfig_ = CardConfig:new()
	self.m_CardArr = {}                     --三張牌的集合
	self:initUI()
	self:refreshCardImg()
end

function PHZChoiceCardCell:onEnter()

end

function PHZChoiceCardCell:onExit()

end

function PHZChoiceCardCell:initUI()
	local function onTouchButton(sender,eventType)
    	if sender then
    		if eventType == ccui.TouchEventType.ended then
    			sender:setScale(1)
    			self:onCallBack(sender:getTag())
    		end
    	end
    end

	self.img_selected = self:getChildByName("img_selected_1")
	self.img_selected:setVisible(false)
	for i=1,PHZChoiceCardCell.Card_NUM do
		self.m_CardArr[i] = self:getChildByName("Card_"..i)
		self.m_CardArr[i]:setVisible(false)
	end

	self.btn_click = self:getChildByName("btn_click")
	self.btn_click:setTag(PHZChoiceCardCell.TAG_CARD_BTN)
	self.btn_click:addTouchEventListener(onTouchButton)
    self.btn_click:setTouchSwallowEnabled(false)
end

function PHZChoiceCardCell:onCallBack( _tag )
	if _tag == PHZChoiceCardCell.TAG_CARD_BTN then
		self:ClickBtnCard()
	else
		print("this is error!!!")
	end
end

function PHZChoiceCardCell:hideSelectedIMG()
	self.img_selected:setVisible(false)
end

function PHZChoiceCardCell:ClickBtnCard()
	print("==选择吃牌的index为==listViewIndex==",self.listViewIndex,self.index)
	self.img_selected:setVisible(true)
	self.chiCardlayer:clickListViewByIndex(self.listViewIndex,self.index)
end

function PHZChoiceCardCell:refreshCardImg()
	print("======refreshCard========")
	for i=1,PHZChoiceCardCell.Card_NUM do
		if not self.data or not self.data[i] then return  print("===数据不存在==") end
		local cardID = g_CardScene.m_GameLogic:SwitchIndexToCardID(self.data[i])
		local cardInfo = self.cardConfig_:getCardInfoByid(cardID)
	    if cardInfo then
	    	local imgPath = string.format("%s.png",cardInfo.CardIconA)
		    local frame = display.newSpriteFrame(imgPath)
		    self.m_CardArr[i]:setSpriteFrame(frame)
		    self.m_CardArr[i]:setVisible(true)
		else
			print("-----this is error!!!----refresh")
	    end
	end
end


return PHZChoiceCardCell