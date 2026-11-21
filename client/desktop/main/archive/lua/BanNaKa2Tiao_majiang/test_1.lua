
local Test = class("Test")

function Test:debugTool()
    TpackageName = "BanNaKa2Tiao_majiang"
    CARD_PLAYERTYPE_MY = 1
    CARD_PLAYERTYPE_LEFT = 2
    CARD_PLAYERTYPE_TOP = 3
    CARD_PLAYERTYPE_RIGHT = 4
    D3_CHUPAI = 1
    D3_CONTROLLER = require(TpackageName..".operator.GamePlaneOperator")
    D3_CARDDATA = require("hall.3DMahjongCard.CardData")
    ZZ_PLAYER_COUNT = 2
    self._cards = {
        -- 0,0,0,0,0,
        -- 1,1,1,1,1,
        -- 0,0,0,
        -- 1,1,1,1,1,
        -- 1,1,1,1,1,1,1,1,1,1,1,1,1,5,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,5,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,5,1,1,1,1,
        -- 1,1,1,1,1,1,1,1,1,1,1,1,1,5,1,1,1,1,
        -- 1,1,1,1,1,1,1,1,1,1,1,1,1,5,1,1,1,
    }
    local tabl = {}
    for i,v in ipairs(self._cards) do
        local card = {}
        card.m_value = v
        table.insert(tabl, card)
    end
    self.OutCardMgr = require(TpackageName..".2DMahjongCard.OutCardMgr").new()
    self.OutCardMgr:setName("OutCardMgr")
    SCENENOW["scene"]:addChild(self.OutCardMgr)
    self.InhandBackMgr = require(TpackageName..".2DMahjongCard.InhandBackMgr")
    ZZMJ_SCENE = self.OutCardMgr._scene
    
    local nodes = {
		self.OutCardMgr._scene.players.my_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.left_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.top_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.right_card_plane.outhand_plane,
    }
    self.OutCardMgr:showOutCards(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], self._cards)
    -- self.OutCardMgr:showOutCards(CARD_PLAYERTYPE_LEFT, nodes[CARD_PLAYERTYPE_LEFT], self._cards)
    -- self.OutCardMgr:showOutCards(CARD_PLAYERTYPE_RIGHT, nodes[CARD_PLAYERTYPE_RIGHT], self._cards)
    self.OutCardMgr:showOutCards(CARD_PLAYERTYPE_MY, nodes[CARD_PLAYERTYPE_MY], self._cards)
    local nodes = {
		self.OutCardMgr._scene.players.my_card_plane.inhand_plane,
		self.OutCardMgr._scene.players.left_card_plane.inhand_plane,
		self.OutCardMgr._scene.players.top_card_plane.inhand_plane,
		self.OutCardMgr._scene.players.right_card_plane.inhand_plane,
    }

    -- self.TableCardBackMgr = require(TpackageName..".2DMahjongCard.TableCardBackMgr")
    -- self.TableCardBackMgr:setScene(ZZMJ_SCENE)
    -- self.TableCardBackMgr:initUI(130, 1)

    self._cards = {
        1,1,1,1,5,
        1,1,65,1,1,
        4,3,65,
    }
    local cardsSeq = {}
	local laiziSeq = {}
	local hucardData 
    ZZMJ_LAIZI = 65

	local hucard = hucard or 0
    for k,v in pairs(self._cards) do
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

    -- local maPath = TpackageName.."/2DMahjongCard/res/newImage/down_holds/"
    -- require("hall.scene.verify.TestConfig"):chooseCard(self._cards, maPath, nil, "新余麻将")
    
    self._cards = cardsSeq
    self.InhandBackMgr:showCards(CARD_PLAYERTYPE_MY, nodes[CARD_PLAYERTYPE_MY], self._cards)
    self.InhandBackMgr:showCards(CARD_PLAYERTYPE_LEFT, nodes[CARD_PLAYERTYPE_LEFT], self._cards)
    self.InhandBackMgr:showCards(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], self._cards)
    self.InhandBackMgr:showCards(CARD_PLAYERTYPE_RIGHT, nodes[CARD_PLAYERTYPE_RIGHT], self._cards)


    CONTROL_TYPE_PENG = 8
    GANG_TYPE_PG = 16
    GANG_TYPE_AN = 125
    local data = {
        {
            type = GANG_TYPE_AN,
            cards = {1,1,1,1}
        },
        {
            type = CONTROL_TYPE_PENG,
            cards = {1,1,1}
        },
        -- {
        --     type = GANG_TYPE_PG,
        --     cards = {1,1,1,1}
        -- },
        {
            type = GANG_TYPE_AN,
            cards = {1,1,1,1}
        },
        -- {
        --     type = CONTROL_TYPE_PENG,
        --     cards = {1,1,1}
        -- },
        -- {
        --     type = CONTROL_TYPE_PENG,
        --     cards = {1,1,1}
        -- },
        -- {
        --     type = CONTROL_TYPE_PENG,
        --     cards = {1,1,1}
        -- },
    }
    
    local nodes = {
		self.OutCardMgr._scene.players.my_card_plane.lefthand_plane,
		self.OutCardMgr._scene.players.left_card_plane.lefthand_plane,
		self.OutCardMgr._scene.players.top_card_plane.lefthand_plane,
		self.OutCardMgr._scene.players.right_card_plane.lefthand_plane,
    }
    self.PengOrGangCardMgr = require(TpackageName..".2DMahjongCard.PengOrGangCardMgr")
    self.PengOrGangCardMgr:handData(CARD_PLAYERTYPE_MY, nodes[CARD_PLAYERTYPE_MY], data)
    self.PengOrGangCardMgr:handData(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], data)
    self.PengOrGangCardMgr:handData(CARD_PLAYERTYPE_LEFT, nodes[CARD_PLAYERTYPE_LEFT], data)
    self.PengOrGangCardMgr:handData(CARD_PLAYERTYPE_RIGHT, nodes[CARD_PLAYERTYPE_RIGHT], data)

end
function Test:KEY_F11()

    local cardsSeq = self._cards

    -- self._cards = {m_value = 1}
   
    local nodes = {
		self.OutCardMgr._scene.players.my_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.left_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.top_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.right_card_plane.outhand_plane,
    } 
    local nodes = {
		self.OutCardMgr._scene.players.my_card_plane.inhand_plane,
		self.OutCardMgr._scene.players.left_card_plane.inhand_plane,
		self.OutCardMgr._scene.players.top_card_plane.inhand_plane,
		self.OutCardMgr._scene.players.right_card_plane.inhand_plane,
    }

    -- self.OutCardMgr:playOutCard(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], self._cards)
    -- self.OutCardMgr:playOutCard(CARD_PLAYERTYPE_MY, nodes[CARD_PLAYERTYPE_MY], self._cards)


    local x = 15
    local y = -15
    -- local chids = nodes[CARD_PLAYERTYPE_LEFT]:getChildren()
	-- local count = #chids
    -- local newCardNode = chids[count]:setTag(20)
    -- local orlPos = newCardNode:getContentSize()
    -- newCardNode:setTag(20)
    -- newCardNode:setPosition(cc.p(x, y))

    self.InhandBackMgr:showCardsForAll(CARD_PLAYERTYPE_LEFT, nodes[CARD_PLAYERTYPE_LEFT], self._cards, 20)
    -- local chids = nodes[CARD_PLAYERTYPE_TOP]:getChildren()
	-- local count = #chids
    -- local newCardNode = chids[count]:setTag(20)
    -- local orlPos = newCardNode:getContentSize()
    -- newCardNode:setPositionX(-orlPos.width) 
            
    self.InhandBackMgr:showCardsForAll(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], self._cards, cardsSeq[1])


    -- local chids = nodes[CARD_PLAYERTYPE_RIGHT]:getChildren()
	-- local count = #chids
    -- local newCardNode = chids[count]:setTag(20)
    -- local orlPos = newCardNode:getContentSize()
    -- local x = 12
    -- local y = 415
    -- newCardNode:setTag(20)
    -- newCardNode:setPosition(cc.p(x, y))
    self.InhandBackMgr:showCardsForAll(CARD_PLAYERTYPE_RIGHT, nodes[CARD_PLAYERTYPE_RIGHT], self._cards, cardsSeq[1])
end
return Test