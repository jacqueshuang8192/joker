
local Test = class("Test")

function Test:debugTool()
    CARD_PLAYERTYPE_MY = 1
    CARD_PLAYERTYPE_LEFT = 2
    CARD_PLAYERTYPE_TOP = 3
    CARD_PLAYERTYPE_RIGHT = 4
    D3_CHUPAI = 1
    D3_CONTROLLER = require(TpackageName..".operator.GamePlaneOperator")
    D3_CARDDATA = require("hall.3DMahjongCard.CardData")
    YJ_PLAYER_COUNT = 2
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
    self.OutCardMgr = require(TpackageName .. ".2DMahjongCard.OutCardMgr").new()
    self.OutCardMgr:setName("OutCardMgr")
    SCENENOW["scene"]:addChild(self.OutCardMgr)
    local InhandBackMgr = require(TpackageName .. ".2DMahjongCard.InhandBackMgr")
    YJMJ_SCENE = self.OutCardMgr._scene
    
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

    self.CardBackMgr = require(TpackageName .. ".2DMahjongCard.CardBackMgr")
    self.CardBackMgr:setScene(YJMJ_SCENE)
    self.CardBackMgr:initUI(130, 1)

    self._cards = {
        1,1,1,1,5,
        1,1,65,1,1,
        4,3,65,
    }
    local cardsSeq = {}
	local laiziSeq = {}
	local hucardData 
    YJMJ_LAIZI = 65

	local hucard = hucard or 0
    for k,v in pairs(self._cards) do
        if v == YJMJ_LAIZI then
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

    -- local maPath = TpackageName .. "/2DMahjongCard/res/newImage/down_holds/"
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
    self.PengOrGangCardMgr = require(TpackageName .. ".2DMahjongCard.PengOrGangCardMgr")
    self.PengOrGangCardMgr:handData(CARD_PLAYERTYPE_MY, nodes[CARD_PLAYERTYPE_MY], data)
    self.PengOrGangCardMgr:handData(CARD_PLAYERTYPE_TOP, nodes[CARD_PLAYERTYPE_TOP], data)
    self.PengOrGangCardMgr:handData(CARD_PLAYERTYPE_LEFT, nodes[CARD_PLAYERTYPE_LEFT], data)
    self.PengOrGangCardMgr:handData(CARD_PLAYERTYPE_RIGHT, nodes[CARD_PLAYERTYPE_RIGHT], data)

    local cards = {
        {card = 1,position = 1},
        {card = 6,position = 1},
        {card = 1,position = 0},
        {card = 2,position = 1},
        {card = 1,position = 1},
        {card = 7,position = 0},
        {card = 5,position = 1},
    }
    table.sort(cards, function(a,b)
        return a.card < b.card
    end)
    local Card = require(TpackageName .. ".2DMahjongCard.Card")
    local zhama_vw = self.OutCardMgr._scene.zhama_vw
    local cards_vw = zhama_vw.cards_vw
    zhama_vw:show()
    cards_vw:removeAllChildren()
    local card = Card:setMyInHandCardBack()
    local size = cards_vw:getContentSize()
    local scale = 1
    local pool_col_space = 8
    local number_2 = #cards
    local cardHeight = card:getSize().height * scale
    local cardWidth = card:getSize().width * scale + pool_col_space
    local oriX = (size.width - number_2 * cardWidth) / 2 + cardWidth / 2
    local oriY = size.height / 2
    for idx,card in ipairs(cards) do
        local node = Card:setMyInHandCardBack()
        local x = oriX + ((idx - 1) * cardWidth)
        node:setPosition(cc.p(x, oriY))
        cards_vw:addChild(node)
    end
    local time = 0.5
    local inittime = 0.5
    local chids = cards_vw:getChildren()
    cards_vw:stopAllActions()
    for idx,cardtal in ipairs(cards) do
        time = inittime * idx
        cards_vw:performWithDelay(function()
            local node = chids[idx]
            node:setMyInHandCard(cardtal.card)
            if cardtal.position == 1 then
                node:setZhongMaAnima()
            end
        end, time)
    end
    time = time + inittime

    


    local data = {
        ["bankerId"]     = 10060,
        ["birdCards"] = {
            [1] = {
                ["card"]     = 33,
                ["position"] = 0,
            },
        },
        ["birdCount"]    = 1,
        ["cmd"]          = 24584,
        ["maScore"]      = 2,
        ["nRoundResult"] = 1,
        ["players"] = {
            [1] = {
                ["agCards"] = {
                },
                ["agCount"]          = 0,
                ["bgCount"]          = 0,
                ["changeCoins"]      = -2000,
                ["coins"]            = 2238525,
                ["dgCount"]          = 0,
                ["gCards"] = {
                },
                ["gCount"]           = 0,
                ["hu_tai"] = {
                },
                ["hu_tai_size"]      = 0,
                ["ifhu"]             = 0,
                ["ifpao"]            = 0,
                ["isDaHu"]           = 0,
                ["isOnline"]         = 1,
                ["isQingShui"]       = 0,
                ["nick"]             = "测试0号",
                ["pCards"] = {
                },
                ["pCount"]           = 0,
                ["pgCount"]          = 0,
                ["portrait"]         = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
                ["remainCards"] = {
                    [1]  = 1,
                    [2]  = 3,
                    [3]  = 6,
                    [4]  = 8,
                    [5]  = 17,
                    [6]  = 19,
                    [7]  = 23,
                    [8]  = 23,
                    [9]  = 25,
                    [10] = 25,
                    [11] = 34,
                    [12] = 36,
                    [13] = 38,
                },
                ["remainCardsCount"] = 13,
                ["seat_id"]          = 0,
                ["uid"]              = 10059,
            },
            [2] = {
                ["agCards"] = {
                },
                ["agCount"]          = 0,
                ["bgCount"]          = 0,
                ["changeCoins"]      = 2000,
                ["coins"]            = 990770,
                ["dgCount"]          = 0,
                ["gCards"] = {
                },
                ["gCount"]           = 0,
                ["hu_tai"] = {
                    [1] = {
                        ["byTaiCount"] = 1,
                        ["byType"]     = 1,
                    },
                },
                ["hu_tai_size"]      = 1,
                ["hucontent"] = {
                    [1] = {
                        ["hutype"] = 2,
                        ["zimo"] = {
                            [1] = {
                                ["huCard"]         = 20,
                                ["ifgangshanghua"] = 0,
                            },
                        },
                    },
                },
                ["ifhu"]             = 1,
                ["ifpao"]            = 0,
                ["isDaHu"]           = 0,
                ["isOnline"]         = 1,
                ["isQingShui"]       = 0,
                ["nick"]             = "测试1号",
                ["pCards"] = {
                },
                ["pCount"]           = 0,
                ["pgCount"]          = 0,
                ["portrait"]         = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
                ["remainCards"] = {
                    [1]  = 2,
                    [2]  = 2,
                    [3]  = 17,
                    [4]  = 18,
                    [5]  = 19,
                    [6]  = 20,
                    [7]  = 21,
                    [8]  = 21,
                    [9]  = 22,
                    [10] = 22,
                    [11] = 23,
                    [12] = 23,
                    [13] = 24,
                    [14] = 25,
                },
                ["remainCardsCount"] = 14,
                ["seat_id"]          = 1,
                ["uid"]              = 10060,
            },
        },
        ["remainCards"] = {
            [1]  = 33,
            [2]  = 5,
            [3]  = 24,
            [4]  = 4,
            [5]  = 6,
            [6]  = 38,
            [7]  = 24,
            [8]  = 34,
            [9]  = 41,
            [10] = 35,
            [11] = 9,
            [12] = 17,
            [13] = 39,
            [14] = 37,
            [15] = 4,
            [16] = 33,
            [17] = 2,
            [18] = 21,
            [19] = 24,
            [20] = 19,
            [21] = 41,
            [22] = 22,
            [23] = 7,
            [24] = 7,
            [25] = 33,
            [26] = 8,
            [27] = 35,
            [28] = 18,
            [29] = 4,
            [30] = 3,
            [31] = 6,
            [32] = 40,
            [33] = 39,
            [34] = 20,
            [35] = 40,
            [36] = 8,
            [37] = 33,
            [38] = 20,
            [39] = 37,
            [40] = 1,
            [41] = 41,
            [42] = 37,
            [43] = 40,
            [44] = 5,
            [45] = 34,
            [46] = 4,
            [47] = 38,
            [48] = 36,
            [49] = 25,
            [50] = 19,
            [51] = 18,
            [52] = 8,
            [53] = 5,
            [54] = 6,
            [55] = 17,
            [56] = 34,
            [57] = 7,
            [58] = 1,
            [59] = 35,
            [60] = 22,
            [61] = 18,
            [62] = 39,
            [63] = 9,
            [64] = 21,
            [65] = 35,
            [66] = 41,
            [67] = 2,
            [68] = 40,
            [69] = 9,
            [70] = 9,
            [71] = 5,
        },
        ["remainCount"]  = 71,
        ["time"]         = 187,
        ["userCount"]    = 2,
    }
    self.GameResult = require(TpackageName..".view.GameResult").new(data)
    self.GameResult:setName("niuniu_zhuang_1")
    SCENENOW["scene"]:addChild(self.GameResult,9999999)
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