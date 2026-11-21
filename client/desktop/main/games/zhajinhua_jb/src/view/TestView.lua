
local PokerCard = require( "zhajinhua_jb.src.PokerCard")
local SendHandle = require("zhajinhua_jb.src.handle.SendHandle")
local handCardNum = 3
local TestView = class("TestView", function()
    return cc.CSLoader:createNode("zhajinhua_jb/res/TestView.csb")
end)
function TestView:ctor()
	GameUtils.setNodeNameBindObj(self)
	self.selectedCards = {}
	self.cardLst = {  
		0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x01,   --方块
		0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x11,   --樱花
		0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x21,   --红桃
		0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x31,   --黑桃
	}
	self:initUI()
	self:initEvent()
	self:setCards(self.cardLst)
end

function TestView:initUI()
    display.doLayout(self)
	self.cards_vw = self.root.cards_vw
	self.btnClose = self.root.btnClose
	self.btnSure = self.root.btnSure
end

function TestView:initEvent()
	self.btnClose:onClick(handler(self, self.onClickClose))
	self.btnSure:onClick(handler(self, self.onClickSure))
end

function TestView:setCards(cards)
    self.cards_vw:removeAllChildren()
    local size = self.cards_vw:getSize()

    local scale = 0.55
    local getShortCardSize = PokerCard:getCardSize( )
    local cardWidth = getShortCardSize.width * scale
    local cardHeight = getShortCardSize.height * scale
    
    local oriX = cardWidth / 2
    local oriY = size.height - cardHeight / 2
    local row = 13
    table.sort(cards)
    for idx,card in ipairs(cards) do
        local rowIdx = idx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(idx/ row)
        local cardNode = PokerCard.new(card)
        local x = oriX + (rowIdx - 1) * cardWidth
        local y = oriY - (colIdx - 1) * cardHeight
        cardNode:setPosition(cc.p(x, y))
        cardNode:setScale(scale)
        self.cards_vw:addChild(cardNode)
        cardNode.cardValue = card
        cardNode:onClick(handler(self, self.onClickCard),true)
    end
end

function TestView:onClickCard(event)
	local target = event.target
	if target and target.bSelect then
		target.bSelect = false
		self:setMask(target, false)
		for i, v in ipairs(self.selectedCards) do
			if v == target.cardValue then
				table.remove(self.selectedCards, i)
				break
			end
		end
	elseif target then
		if #self.selectedCards >= handCardNum then -- 手牌个数最多为13
			self:showTip()
			return
		end
		target.bSelect = true
		self:setMask(target, true)
		table.insert(self.selectedCards, target.cardValue)
	end
end

function TestView:setMask(node, selected)
	local maColor = cc.c3b(207,207,103)
	local orlColor = cc.c3b(255,255,255)
	if selected then
		node:setColor(maColor)
	else
		node:setColor(orlColor)
	end
end
function TestView:onClickClose(event)
	self:closeSelf()
end

function TestView:onClickSure(event)
	if #self.selectedCards > handCardNum then -- 需要的手牌只能为9个
		self:showTip()
	else
		self:sendSelectCards()
	end
end

function TestView:closeSelf()
	self:removeSelf()
end

function TestView:sendSelectCards()
	if #self.selectedCards ~= handCardNum then -- 手牌个数最多为13
		self:showTip()
		return
	end
	SendHandle:CLI_CHOICE_CARD(self.selectedCards)
	self:removeSelf()
end

function TestView:showTip( )
	local text = string.format("可选择%s个可替换的牌", handCardNum)
	viewMgr:showTip({text = text})
end

return TestView