local SendHandle = require("jchuapai.src.handle.SendHandle")
local OprorateBtn = class("OprorateBtn")
local Card = require("jchuapai.src.Card")

function OprorateBtn:ctor(GameSceneView, CardView)
	self.hall = GameSceneView.hall
	self.GameSceneView = GameSceneView
	self.CardView = CardView
	self:initUI()
	self:initEvent()
end

function OprorateBtn:initUI()
    self.btn_cancel = self.hall.btn_cancel:hide()
    self.btn_chu = self.hall.btn_chu:hide()
    self.btn_tong = self.hall.btn_tong:hide()
    self.btn_zhao = self.hall.btn_zhao:hide()
    -- self.btn_zimo = self.hall.btn_zimo:hide()
    self.btn_dui = self.hall.btn_dui:hide()
	self.btn_hu = self.hall.btn_hu:hide()
	self.btn_fan = self.hall.btn_fan:hide()
	self.fan_vw = self.hall.fan_vw:hide()
end

function OprorateBtn:clearData()
	self.btn_cancel:hide()
    self.btn_chu:hide()
    self.btn_tong:hide()
    self.btn_zhao:hide()
    -- self.btn_zimo:hide()
    self.btn_dui:hide()
	self.btn_hu:hide()
	self.btn_fan:hide()
	self.fan_vw:hide()
end

function OprorateBtn:showChuBtn()
	self:setData( {1} )
	self.btn_cancel:hide()
end

function OprorateBtn:initEvent()
    self.btn_cancel:onClick(handler(self, self.onClick_cancel), true)
    self.btn_chu:onClick(handler(self, self.onClick_chu), true)
    self.btn_tong:onClick(handler(self, self.onClick_tong), true)
    self.btn_zhao:onClick(handler(self, self.onClick_zhao), true)
    -- self.btn_zimo:onClick(handler(self, self.onClick_zimo), true)
    self.btn_dui:onClick(handler(self, self.onClick_dui), true)
    self.btn_hu:onClick(handler(self, self.onClick_hu), true)
	self.btn_fan:onClick(handler(self, self.onClick_fan), true)
	self.fan_vw:onClick(function()
		self.fan_vw:hide()
	end)
end

function OprorateBtn:setData( data )
	self:clearData()
	local btnArr = {
		self.btn_chu,
		self.btn_dui,
		self.btn_zhao,
		self.btn_tong,
		self.btn_fan,
		self.btn_hu,
	}
	local initPosX = 1157.59
	local newData = {}
	for idx,v in ipairs(data) do
		newData[btnArr[idx]] = v
	end
	local newData1 = {
		{
			node = self.btn_chu,
			val = newData[self.btn_chu]
		},
		{
			node = self.btn_fan,
			val = newData[self.btn_fan]
		},
		{
			node = self.btn_zhao,
			val = newData[self.btn_zhao]
		},
		{
			node = self.btn_dui,
			val = newData[self.btn_dui]
		},
		{
			node = self.btn_tong,
			val = newData[self.btn_tong]
		},
		{
			node = self.btn_hu,
			val = newData[self.btn_hu]
		},
	}
	for idx,val in ipairs(newData1) do
		local node = val.node
		if val.val == 1 then
			node:setVisible(true)
			node:setPositionX(initPosX)
			initPosX = initPosX - node:getContentSize().width - 20
		else
			node:setVisible(false)
		end
	end
	self.btn_cancel:setPositionX(initPosX)
	self.btn_cancel:show()
end

function OprorateBtn:onClick_cancel(event)
    SendHandle:CLI_PASS()
	self:clearData()
end

function OprorateBtn:onClick_chu(event)
	local curClickCardNode = g_388.curClickCardNode
	if curClickCardNode then
		self.GameSceneView:isShowChuState( false )
		local card = curClickCardNode._card
		-- self.CardView:removeCardNode( curClickCardNode )
		-- g_388.curClickCardNode = nil
		dump(card)
		SendHandle:CLI_PLAYER_OUT_CARD(card)
		self:clearData()
	end
end

function OprorateBtn:onClick_tong(event)
    SendHandle:CLI_PLAYER_TONG_CARD()
	self:clearData()
end

function OprorateBtn:onClick_zhao(event)
    SendHandle:CLI_PLAYER_ZHAO_CARD()
	self:clearData()
end

function OprorateBtn:onClick_zimo(event)
    SendHandle:CLI_ZIMO()
	self:clearData()
end

function OprorateBtn:onClick_dui(event)
    SendHandle:CLI_PLAYER_PENG_CARD()
	self:clearData()
end

function OprorateBtn:onClick_hu(event)
    SendHandle:CLI_PLAYER_HU_CARD()
	self:clearData()
end

function OprorateBtn:onClick_fan(event)
	local cards = self.CardView:getHandCardsAndFanCards()
	dump(cards)
	if #cards == 1 then
		SendHandle:CLI_PLAYER_FAN_CARD(cards[1])
		self:clearData()
	else
		self.fan_vw:show()
		local panel = self.fan_vw.panel
		panel:removeAllChildren()
		local cardWidht = 100 + 20
		local width = #cards * cardWidht + 100
		local initX = width - 100
		panel:setContentSize(cc.size(width, 200))
		for idx, card in ipairs(cards) do
			local cardNode = Card.new("long", card)
			cardNode:addTo(panel)
			cardNode:setPosition(initX - (idx - 1) * cardWidht, -34)
			cardNode:onClick(function( event )
				SendHandle:CLI_PLAYER_FAN_CARD(event.target._card)
				self:clearData()
			end)
		end
	end
end

return OprorateBtn	