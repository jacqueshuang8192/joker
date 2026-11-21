local SendHandle = require("hz_majiang.src.handle.SendHandle")
local OprorateBtn = class("OprorateBtn")
local PokerCard = require("hz_majiang.src.PokerCard")

function OprorateBtn:ctor(hall)
	self.hall = hall
	self:initUI()
	self:initEvent()
end

function OprorateBtn:initUI()
    self.btn_peng = self.hall.btn_peng:hide()
    self.btn_chi = self.hall.btn_chi:hide()
    self.btn_gang = self.hall.btn_gang:hide()
	self.btn_hu = self.hall.btn_hu:hide()
	self.gang_vw = self.hall.gang_vw:hide()
end

function OprorateBtn:clearData()
    self.btn_peng:hide()
    self.btn_chi:hide()
    self.btn_gang:hide()
	self.btn_hu:hide()
end

function OprorateBtn:initEvent()
    self.btn_peng:onClick(handler(self, self.onClick_peng), true)
    self.btn_chi:onClick(handler(self, self.onClick_chi), true)
    self.btn_gang:onClick(handler(self, self.onClick_gang), true)
    self.btn_hu:onClick(handler(self, self.onClick_hu), true)
end

function OprorateBtn:setData( data )
	self:clearData()
	local btnArr = {
		self.btn_hu,
		self.btn_peng,
		self.btn_chi,
		self.btn_gang,
	}

	local director = cc.Director:getInstance()
	local size = director:getWinSize()
	local initPosX = size.width * 0.9
	for idx,v in ipairs(data) do
		local node = btnArr[idx]
		if v == 1 then
			node:setVisible(true)
			node:setPositionX(initPosX)
			initPosX = initPosX - (node:getContentSize().width + 30)
		else
			node:setVisible(false)
		end
	end
end

function OprorateBtn:onClick_close(event)
	local func = function (  )
		SendHandle:CLI_PASS()
		self:clearData()
	end
	if self.btn_hu:isVisible() then
		local data = {}
		data.type = 2
		data.content = "是否过胡"
		data.title = "提示"
		data.callBackSure = function (  )
			func()
		end
		require("hall.tips.CommonTips"):showTips(data)
	else
		func()
	end
end

function OprorateBtn:onClick_peng(event)
	SendHandle:CLI_PLAYER_PENG_CARD()
	self:clearData()
end

function OprorateBtn:onClick_chi(event)
end


function OprorateBtn:showTypeCards(chiResult, curOutCard, index)
	local director = cc.Director:getInstance()
	local size = director:getWinSize()
	local initPosX = size.width
	

	local scale = 0.45
    local getShortCardSize = PokerCard:getShortCardSize( )
    local cardWidth = getShortCardSize.width * scale
	local cardHeight = getShortCardSize.height * scale
end

function OprorateBtn:onClickCard( event )
	
end

function OprorateBtn:CLI_PLAYER_CHI_CARD( )
	local biarr = self:getBiArr()
	self:clearData()
end

function OprorateBtn:onClick_gang(event)
    SendHandle:CLI_PLAYER_PAO_CARD()
	self:clearData()
end

function OprorateBtn:onClick_hu(event)
    SendHandle:CLI_PLAYER_HU_CARD()
	self:clearData()
end



return OprorateBtn	