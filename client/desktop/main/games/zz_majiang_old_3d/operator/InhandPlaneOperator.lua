local Card = require("zz_majiang_old_3d.card.card")
local cardUtils = require("zz_majiang_old_3d.utils.cardUtils")

local InhandPlaneOperator = class("InhandPlaneOperator")

local SPLIT_NEWCARD = 25

local selectedTag = 99

local NEW_CARD_TAG = 20

local cardTemp = nil

function InhandPlaneOperator:init(playerType, plane)
	plane:removeAllChildren()

	-- if playerType == CARD_PLAYERTYPE_MY then
	-- 	--todo
	-- 	plane:setSize(cc.size(0, plane:getSize().height))
	-- elseif playerType == CARD_PLAYERTYPE_LEFT then
	-- 	plane:setSize(cc.size(plane:getSize().width, 0))
	-- elseif playerType == CARD_PLAYERTYPE_RIGHT then
	-- 	plane:setSize(cc.size(plane:getSize().width, 0))
	-- elseif playerType == CARD_PLAYERTYPE_TOP then
	-- 	plane:setSize(cc.size(0, plane:getSize().height))
	-- end
	
end

function InhandPlaneOperator:showCards(playerType, plane, cardDatas,tingSeq)----显示手牌	

	table.sort(cardDatas)

	local cardsSeq = {}
	local laiziSeq = {}
	--癞子放到左侧
	for k,v in pairs(cardDatas) do
        if v == ZZMJ_LAIZI then
			local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)

			table.insert(laiziSeq, 1, cardData)
		else
			local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

			table.insert(cardsSeq, cardData)
		end
	end

	for i,v in ipairs(laiziSeq) do
		table.insert(cardsSeq, 1, v)
	end

	D3_OPERATOR:showCards(playerType, plane, cardsSeq)
end


--新胡牌时摊牌
function InhandPlaneOperator:showCardsForAll(playerType, plane, cardDatas, anke,hucard)---显示所有的牌（胡牌的时候）

	table.sort(cardDatas)

	local cardsSeq = {}
	local laiziSeq = {}
	local hucardData 

	local hucard = hucard or 0

	--癞子放到左侧
	for k,v in pairs(cardDatas) do
        if v == ZZMJ_LAIZI then
        	if v == hucard and (not hucardData) then  --胡牌单独展示
                hucardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)
            else
				local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)
				table.insert(laiziSeq, 1, cardData)
			end
		else
			if v == hucard and (not hucardData) then  --胡牌单独展示
				hucardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
			else

				local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)
				table.insert(cardsSeq, cardData)
			end
		end
	end

	for i,v in ipairs(laiziSeq) do
		table.insert(cardsSeq, 1, v)
	end

	D3_OPERATOR:showCardsForAll( playerType, plane, {}, cardsSeq )
	D3_OPERATOR:getNewCard(playerType, plane, hucardData, true)


end

---取消选择中的牌
function InhandPlaneOperator:cancelSelectingCard(plane)
	if selectedTag == 99 then
		--todo
		return
	end

	local selectedCard = plane:getChildByTag(selectedTag)

	if selectedCard then
		--todo
		local oriY = plane:getSize().height / 2

		local position = selectedCard:getPosition()

		if position.y > oriY then
			--todo
			selectedCard:setScale(1.1)
			local offsetX = 0.1 * selectedCard:getSize().width
			selectedCard:setPosition(cc.p(selectedCard:getPosition().x - offsetX / 2, selectedCard:getSize().height * selectedCard:getScale() / 2))

			local tag = selectedCard:getTag()
			tag = tag + 1
			local nextCard = plane:getChildByTag(tag)
			while nextCard do
				--todo
				nextCard:setPosition(cc.p(nextCard:getPosition().x - offsetX, nextCard:getPosition().y))
                -- nextCard:setColor(cc.c3b(255,255,255))
                tag = tag + 1

                nextCard = plane:getChildByTag(tag)
               
            end

            selectedTag = 99
            D3_CHUPAI = 1
        end
        D3_CHUPAI = 1
    end
     D3_CHUPAI = 1
    
end


--新摸牌
function InhandPlaneOperator:getNewCard(playerType, plane, value,tingSeq)

	local cardData
	if value == ZZMJ_LAIZI then
		cardData = D3_CARDDATA:new(value, 0, CARDNODE_TYPE_LAIZI)
	else
		cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)
	end

	D3_OPERATOR:getNewCard(playerType, plane, cardData, false)
end


function InhandPlaneOperator:playCard(playerType, plane)
	if playerType == CARD_PLAYERTYPE_MY then
		selectedTag = 99
	end
end
return InhandPlaneOperator