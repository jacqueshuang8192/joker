local Test = class("Test")

require("framework.init")
local ddzHandle = class("ddzHandle")
	  
local PROTOCOL = import("xinyu510k.ddz_PROTOCOL")
local ddzServer = import("xinyu510k.ddzServer")
local     ddzSettings = require("xinyu510k.ddzSettings")
	  
local GamePlaneOperator = require("xinyu510k.operator.GamePlaneOperator")
local CardPlaneOperator = require("xinyu510k.operator.CardPlaneOperator")
local ControlPlaneOperator = require("xinyu510k.operator.ControlPlaneOperator")
	  
local Card          = require("xinyu510k.Card")
local unpack = table.unpack or unpack
local CardAnalysis, CARDTYPE = unpack(require("xinyu510k.CardAnalysis"))

function Test:debugTool()

	local cards = {}
    for i,card in ipairs(Mycard_layout:getChildren()) do
        if card.card_value then
            table.insert(cards, card.card_value)
        end
    end
	CardPlaneOperator:updateSendCard(cards, "max")

	dump(USER_INFO["cards"])
	--dump(tbPlayCardInfo)
	print('------------------------')
	-- dump(CardAnalysis:GetTipCard(), 'outcard')
	--dump(CardAnalysis:AnalysebCardData(USER_INFO["cards"]))
	
	-- local layout_effect = cardScene:getChildByName("layout_effect")
	-- require("xinyu510k.Animation"):animBoom(layout_effect)
	--GamePlaneOperator:beginPlayCard(1, OUT_CARD_TIMEOUT)
	--require("xinyu510k.operator.ControlPlaneOperator"):showErrorTips("kind_error")
	--ControlPlaneOperator:showControlButtons(2,true)
	-- local PartnerCards = {}
	-- dump(PartnerCards)
	-- local res = CardAnalysis:IsCallAssCard(PartnerCards, 39)
	--ddzHandle:SVR_GAME_OVER({})
	--[bombchip=1,turnchip=2],[bombchip=3,turnchip=3],[bombchip=2,turnchip=1],[bombchip=1,turnchip=1]
	--local pack = {playercount = 4, playerlist={{cards={0x01,0x03,0x22},bombchip=1,turnchip=2,totalchips=1,turnchip={1,2,3}},{cards={0x01,0x03,0x22},bombchip=1,turnchip=2,totalchips=2,turnchip={1,2,3}},{cards={0x01,0x03,0x22},bombchip=1,turnchip=2,totalchips=3,turnchip={1,2,3}},{cards={0x01,0x03,0x22},bombchip=1,turnchip=2,totalchips=4,turnchip={1,2,3}}}}
	--dump(pack,"SVR_GAME_OVER")
end

function Test:KEY_F11()
	local cards = {}
    for i,card in ipairs(Mycard_layout:getChildren()) do
        if card.card_value then
            table.insert(cards, card.card_value)
        end
    end
	CardPlaneOperator:updateSendCard(cards)

end

function Test:KEY_F12()

end
return Test