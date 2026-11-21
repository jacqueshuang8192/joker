
local Test = class("Test")

function Test:debugTool()

    -- require("jchuapai.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["chouCardArr"] = {
        },
        ["chouPaiCount"]   = 0,
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 1,
            [2]  = 37,
            [3]  = 36,
            [4]  = 23,
            [5]  = 36,
            [6]  = 39,
            [7]  = 34,
            [8]  = 37,
            [9]  = 37,
            [10] = 38,
            [11] = 35,
            [12] = 3,
            [13] = 41,
            [14] = 8,
            [15] = 10,
            [16] = 9,
            [17] = 25,
            [18] = 17,
            [19] = 9,
            [20] = 8,
            [21] = 41,
            [22] = 35,
            [23] = 2,
            [24] = 41,
            [25] = 4,
            [26] = 33,
            [27] = 38,
            [28] = 38,
            [29] = 34,
            [30] = 2,
            [31] = 6,
            [32] = 36,
            [33] = 38,
            [34] = 44,
            [35] = 7,
            [36] = 44,
            [37] = 5,
            [38] = 6,
            [39] = 40,
        },
        ["endGame"]        = 0,
        ["huUserArr"] = {
            [1] = {
                ["groupCardArr"] = {
                    [1] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 23,
                            [2] = 10,
                            [3] = 37,
                        },
                    },
                    [2] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 8,
                            [2] = 9,
                            [3] = 38,
                        },
                    },
                    [3] = {
                        ["cardCount"] = 2,
                        ["cards"] = {
                            [1] = 39,
                            [2] = 40,
                        },
                    },
                    [4] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 44,
                            [2] = 44,
                            [3] = 44,
                        },
                    },
                    [5] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 34,
                            [2] = 34,
                            [3] = 34,
                        },
                    },
                    [6] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 42,
                            [2] = 42,
                            [3] = 42,
                        },
                    },
                },
                ["group_count"]  = 6,
                ["mainJing"]     = 5,
                ["maxHuXi"]      = 80,
                ["seat_id"]      = 0,
                ["tongCardArr"] = {
                    [1] = {
                        ["cardCount"] = 5,
                        ["cards"] = {
                            [1] = 5,
                            [2] = 5,
                            [3] = 21,
                            [4] = 21,
                            [5] = 45,
                        },
                    },
                },
                ["tong_count"]   = 1,
                ["uid"]          = 10059,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 1,
        ["m_CurCardCount"] = 39,
        ["m_HuCard"]       = 44,
        ["nFangPaoSeat"]   = 0,
        ["nRoundResult"]   = 1,
        ["userArr"] = {
            [1] = {
                ["fanList"] = {
                },
                ["fancount"]          = 0,
                ["handCardArr"] = {
                    [1]  = 42,
                    [2]  = 42,
                    [3]  = 9,
                    [4]  = 37,
                    [5]  = 42,
                    [6]  = 34,
                    [7]  = 38,
                    [8]  = 45,
                    [9]  = 5,
                    [10] = 23,
                    [11] = 40,
                    [12] = 5,
                    [13] = 21,
                    [14] = 34,
                    [15] = 8,
                    [16] = 39,
                    [17] = 44,
                    [18] = 44,
                    [19] = 21,
                    [20] = 34,
                    [21] = 10,
                },
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 21,
                ["m_chips"]           = 2707154,
                ["m_totalBlc"]        = 8000,
                ["m_turnBlc"]         = 8000,
                ["pengList"] = {
                    [1] = 33,
                    [2] = 33,
                    [3] = 33,
                },
                ["pengcount"]         = 3,
                ["seat_id"]           = 0,
                ["uid"]               = 10059,
                ["zhaoList"] = {
                    [1] = 4,
                    [2] = 4,
                    [3] = 4,
                    [4] = 4,
                },
                ["zhaocount"]         = 4,
            },
            [2] = {
                ["fanList"] = {
                },
                ["fancount"]          = 0,
                ["handCardArr"] = {
                    [1]  = 37,
                    [2]  = 7,
                    [3]  = 6,
                    [4]  = 40,
                    [5]  = 10,
                    [6]  = 7,
                    [7]  = 45,
                    [8]  = 10,
                    [9]  = 39,
                    [10] = 39,
                    [11] = 19,
                    [12] = 6,
                    [13] = 39,
                    [14] = 3,
                    [15] = 42,
                    [16] = 40,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 16,
                ["m_chips"]           = 358200,
                ["m_totalBlc"]        = -8000,
                ["m_turnBlc"]         = -8000,
                ["pengList"] = {
                    [1] = 2,
                    [2] = 2,
                    [3] = 2,
                    [4] = 35,
                    [5] = 35,
                    [6] = 35,
                },
                ["pengcount"]         = 6,
                ["seat_id"]           = 1,
                ["uid"]               = 10060,
                ["zhaoList"] = {
                    [1] = 43,
                    [2] = 43,
                    [3] = 43,
                    [4] = 43,
                },
                ["zhaocount"]         = 4,
            },
        },
        ["userCount"]      = 2,
    }
    
    local data1 = {
        ["cmd"]          = 4617,
        ["isShowSingle"] = 0,
        ["player_count"] = 2,
        ["player_info"] = {
            [1] = {
                ["huxilist"] = {
                    [1] = 0,
                },
                ["huxilistNum"] = 1,
                ["m_totalBlc"]  = 0,
                ["nick_name"]   = "测试1号",
                ["photo_url"]   = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
                ["sex"]         = 1,
                ["uid"]         = 10060,
            },
            [2] = {
                ["huxilist"] = {
                    [1] = 0,
                },
                ["huxilistNum"] = 1,
                ["m_totalBlc"]  = 0,
                ["nick_name"]   = "测试2号",
                ["photo_url"]   = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
                ["sex"]         = 1,
                ["uid"]         = 10059,
            },
        },
    }
    self.ReceiveHandle = SCENENOW.scene.ReceiveHandle
    -- self.ReceiveHandle:SVR_PLAYER_HU_CARD(data)
    -- self.ReceiveHandle:G2H_BROADCAST_GROUP_RESULT(data)
    self.GameSceneView = SCENENOW.scene.GameSceneView
    self.CardView = SCENENOW.scene.GameSceneView.CardView
    -- self.GameSceneView:setGameResult(data)
    -- self.CardView:removeHandCards({1,2,3,4,5,6,7,8,9})
    local CardHuXiUtils = require("jchuapai.src.CardHuXiUtils")
    local cards = {0x06,0x15,0x2d}
    local CardUtils = require("jchuapai.src.CardUtils")
    table.sort(cards, function( a, b )
		local carda = CardUtils:GetCardLogicValue(a)
		local cardb = CardUtils:GetCardLogicValue(b)
		return carda < cardb
	end)
    local huxi = CardHuXiUtils:CalHuXi( cards, 7 )
    local huxi = CardHuXiUtils:CalHuXi( cards, 7 )
end

function Test:KEY_F11()
    self.CardView:clearData()
end

function Test:KEY_F7()
    self.CardView:setCurHandCards({
        0x01,0x01,0x01,0x11,0x11,0x02,0x02,0x02,0x02,0x02, --一、二
        0x03,0x03,0x03,0x13,0x13,0x04,0x04,0x04,0x04,0x04, --三、四
        0x05,0x05,0x05,0x15,0x15,0x06,0x06,0x06,0x06,0x06, --五、六
    })
end

function Test:KEY_F12()
end

return Test