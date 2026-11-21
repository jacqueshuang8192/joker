
local Test = class("Test")

function Test:debugTool()
    TpackageName = "szkwx_majiang"
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
    local InhandBackMgr = require(TpackageName..".2DMahjongCard.InhandBackMgr")
    SZKWX_SCENE = self.OutCardMgr._scene
    
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

    self.CardBackMgr = require("hall.2DMahjongCard.CardBackMgr")
    self.CardBackMgr:setScene(SZKWX_SCENE)
    self.CardBackMgr:initUI(130, 1)

    self._cards = {
        1,1,1,1,5,
        1,1,65,1,1,
        4,3,65,
    }
    local cardsSeq = {}
	local laiziSeq = {}
	local hucardData 
    SZKWX_LAIZI = 65

	local hucard = hucard or 0
    for k,v in pairs(self._cards) do
        if v == SZKWX_LAIZI then
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

    -- local maPath = "hall/2DMahjongCard/res/newImage/down_holds/"
    -- require("hall.scene.verify.TestConfig"):chooseCard(self._cards, maPath, nil, "快乐麻将")
    
    self._cards = cardsSeq
    self.InhandBackMgr = InhandBackMgr
    self.InhandBackMgr:showCards(CARD_PLAYERTYPE_MY, nodes[CARD_PLAYERTYPE_MY], self._cards)
    self.InhandBackMgr:showCards(CARD_PLAYERTYPE_LEFT, nodes[CARD_PLAYERTYPE_LEFT], self._cards)
    self.InhandBackMgr:showCards(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], self._cards)
    self.InhandBackMgr:showCards(CARD_PLAYERTYPE_RIGHT, nodes[CARD_PLAYERTYPE_RIGHT], self._cards)
    local x = 15
    local y = -15
    local chids = nodes[CARD_PLAYERTYPE_LEFT]:getChildren()
	local count = #chids
    local newCardNode = chids[count]:setTag(20)
    local orlPos = newCardNode:getContentSize()
    newCardNode:setTag(20)
    newCardNode:setPosition(cc.p(x, y))

    InhandBackMgr:showCardsForAll(CARD_PLAYERTYPE_LEFT, nodes[CARD_PLAYERTYPE_LEFT], self._cards, 20)
    local chids = nodes[CARD_PLAYERTYPE_TOP]:getChildren()
	local count = #chids
    local newCardNode = chids[count]:setTag(20)
    local orlPos = newCardNode:getContentSize()
    newCardNode:setPositionX(-orlPos.width) 
            
    InhandBackMgr:showCardsForAll(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], self._cards, cardsSeq[1])


    local chids = nodes[CARD_PLAYERTYPE_RIGHT]:getChildren()
	local count = #chids
    local newCardNode = chids[count]:setTag(20)
    local orlPos = newCardNode:getContentSize()
    local x = 12
    local y = 415
    newCardNode:setTag(20)
    newCardNode:setPosition(cc.p(x, y))
    InhandBackMgr:showCardsForAll(CARD_PLAYERTYPE_RIGHT, nodes[CARD_PLAYERTYPE_RIGHT], self._cards, cardsSeq[1])

    CONTROL_TYPE_PENG = 8
    GANG_TYPE_PG = 16
    GANG_TYPE_AN = 125
    local data = {
        {
            type = CONTROL_TYPE_PENG,
            cards = {1,1,1}
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
        {
            type = CONTROL_TYPE_PENG,
            cards = {1,1,1}
        },
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

    -- local cards = {
    --     {card = 1,position = 1},
    --     {card = 6,position = 1},
    --     {card = 1,position = 0},
    --     {card = 2,position = 1},
    --     {card = 1,position = 1},
    --     {card = 7,position = 0},
    --     {card = 5,position = 1},
    -- }
    -- table.sort(cards, function(a,b)
    --     return a.card < b.card
    -- end)
    -- local Card = require("hall.2DMahjongCard.Card")
    -- local zhama_vw = self.OutCardMgr._scene.zhama_vw
    -- local cards_vw = zhama_vw.cards_vw
    -- zhama_vw:show()
    -- cards_vw:removeAllChildren()
    -- local card = Card:setMyInHandCardBack()
    -- local size = cards_vw:getContentSize()
    -- local scale = 1
    -- local pool_col_space = 8
    -- local number_2 = #cards
    -- local cardHeight = card:getSize().height * scale
    -- local cardWidth = card:getSize().width * scale + pool_col_space
    -- local oriX = (size.width - number_2 * cardWidth) / 2 + cardWidth / 2
    -- local oriY = size.height / 2
    -- for idx,card in ipairs(cards) do
    --     local node = Card:setMyInHandCardBack()
    --     local x = oriX + ((idx - 1) * cardWidth)
    --     node:setPosition(cc.p(x, oriY))
    --     cards_vw:addChild(node)
    -- end
    -- local time = 0.5
    -- local inittime = 0.5
    -- local chids = cards_vw:getChildren()
    -- cards_vw:stopAllActions()
    -- for idx,cardtal in ipairs(cards) do
    --     time = inittime * idx
    --     cards_vw:performWithDelay(function()
    --         local node = chids[idx]
    --         node:setMyInHandCard(cardtal.card)
    --         if cardtal.position == 1 then
    --             node:setZhongMaAnima()
    --         end
    --     end, time)
    -- end
    -- time = time + inittime

    


    -- local data = {
    --     ["bankerId"]             = 2479009
    --     ,["birdCards"] = {
        
    --     }
        
    --     ,["birdCount"]            = 0
        
    --     ,["cmd"]                  = 24584
        
    --     ,["niao_quanzhong_flag"]  = 0
        
    --     ,["niao_quanzhong_value"] = 0
    --     ,maScore = 1
        
    --     ,["players"] = {
        
    --         [1] = {
        
    --             ["agCards"] = {
        
        
    --             }
        
    --             ,["agCount"]          = 1
        
    --             ,["bgCount"]          = 0
        
    --             ,["changeCoins"]      = 3000
        
    --             ,["coins"]            = 1003900
        
    --             ,["dgCount"]          = 0
        
    --             ,["gCards"] = {
        
        
    --             }
        
    --             ,["gCount"]           = 1
        
    --             ,["hucontent"] = {
        
    --                 [1] = {
        
    --                     ["hutype"] = 2
        
    --                     ,["zimo"] = {
        
    --                         [1] = {
        
    --                             ["huCard"]         = 33
        
    --                             ,["ifgangshanghua"] = 0
        
    --                         }
        
    --                     }
        
    --                 }
        
    --             }
        
    --             ,["ifhu"]             = 1
        
    --             ,["ifpao"]            = 0
        
    --             ,["isOnline"]         = 1
        
    --             ,["nick"]             = "Greg"
        
    --             ,["pCards"] = {
        
        
    --             }
        
    --             ,["pCount"]           = 1
        
    --             ,["pgCount"]          = 1
        
    --             ,["remainCards"] = {
        
                  
    --                 0,0,0,0,0,
    --                 0,0,0,
    --                 1,1,1,1,1,
    --             }
        
    --             ,["remainCardsCount"] = 5
        
    --             ,["seat_id"]          = 0
        
    --             ,["uid"]              = 2479009
    --             ,hu_tai = {}
    --         },
        
    --         [2] = {
        
    --             ["agCards"] = {
        
        
    --             }
    --             ,hu_tai = {}
        
    --             ,["agCount"]          = 2
        
    --             ,["bgCount"]          = 0
        
    --             ,["changeCoins"]      = -3000
        
    --             ,["coins"]            = 995900
        
    --             ,["dgCount"]          = 1
        
    --             ,["gCards"] = {
        
    --             }
        
    --             ,["gCount"]           = 0
        
    --             ,["ifhu"]             = 0
        
    --             ,["ifpao"]            = 0
        
    --             ,["isOnline"]         = 1
        
    --             ,["nick"]             = "Greg"
        
    --             ,["pCards"] = {
        
        
    --             }
        
    --             ,["pCount"]           = 1
        
    --             ,["pgCount"]          = 0
        
    --             ,["remainCards"] = {
    --                 0,0,0,0,0,
    --                 0,0,0,
    --                 1,1,1,1,1,
    --             }
        
    --             ,["remainCardsCount"] = 4
        
    --             ,["seat_id"]          = 1
        
    --             ,["uid"]              = 2479010
        
    --         }
        
    --     }
        
    --     ,["time"]                 = 27637
        
    --     ,["userCount"]            = 2
        
    --     ,["zhongNiaoCount"]       = 0
        
    --     ,["zhongcard"] = {
        
    --     }
        
    -- }
    -- self.GameResult = require(TpackageName..".view.GameResult").new(data)
    -- self.GameResult:setName("niuniu_zhuang_1")
    -- SCENENOW["scene"]:addChild(self.GameResult,9999999)
    -- cards_vw:performWithDelay(function()
    --     zhama_vw:hide()
    --     self.GameResult = require(TpackageName..".view.GameResult").new(data)
    --     self.GameResult:setName("niuniu_zhuang_1")
    --     SCENENOW["scene"]:addChild(self.GameResult,9999999)
    -- end, time)
end
function Test:KEY_F11()
    self._cards = {m_value = 1}
   
    local nodes = {
		self.OutCardMgr._scene.players.my_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.left_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.top_card_plane.outhand_plane,
		self.OutCardMgr._scene.players.right_card_plane.outhand_plane,
    }
    self.OutCardMgr:playOutCard(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], self._cards)
    self.OutCardMgr:playOutCard(CARD_PLAYERTYPE_MY, nodes[CARD_PLAYERTYPE_MY], self._cards)
end
return Test