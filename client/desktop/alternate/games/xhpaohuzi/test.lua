
local Test = class("Test")

function Test:debugTool()
    
    -- require("xhpaohuzi.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["chouCardArr"] = {
        },
        ["chouPaiCount"]   = 0,
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 24,
            [2]  = 24,
            [3]  = 7,
            [4]  = 8,
            [5]  = 8,
            [6]  = 20,
            [7]  = 3,
            [8]  = 5,
            [9]  = 2,
            [10] = 6,
            [11] = 3,
            [12] = 24,
            [13] = 2,
            [14] = 5,
            [15] = 25,
            [16] = 17,
            [17] = 26,
            [18] = 4,
            [19] = 7,
            [20] = 23,
            [21] = 22,
            [22] = 10,
            [23] = 17,
            [24] = 25,
            [25] = 1,
        },
        ["endGame"]        = 0,
        ["huUserArr"] = {
            [1] = {
                ["cardGroupArr"] = {
                    [1] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 1,
                            [2] = 2,
                            [3] = 3,
                        },
                        ["type"]      = 1,
                    },
                    [2] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 10,
                            [2] = 26,
                            [3] = 26,
                        },
                        ["type"]      = 1,
                    },
                    [3] = {
                        ["cardCount"] = 2,
                        ["cards"] = {
                            [1] = 18,
                            [2] = 18,
                        },
                        ["type"]      = 4,
                    },
                },
                ["cardGroupCount"] = 3,
                ["seat_id"]        = 0,
                ["uid"]            = 10059,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 0,
        ["m_CurCardCount"] = 25,
        ["m_HuCard"]       = 2,
        ["nFangPaoSeat"]   = -1,
        ["nRoundResult"]   = 1,
        ["userArr"] = {
            [1] = {
                ["biList"] = {
                },
                ["bi_count"]          = 0,
                ["chiList"] = {
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1] = 18,
                    [2] = 18,
                    [3] = 3,
                    [4] = 10,
                    [5] = 26,
                    [6] = 1,
                    [7] = 26,
                },
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 7,
                ["m_chips"]           = 352053,
                ["m_oil"]             = 18,
                ["m_totalBlc"]        = 100,
                ["m_turnBlc"]         = 100,
                ["paoList"] = {
                    [1] = {
                        ["card"]  = 9,
                        ["score"] = 6,
                    },
                },
                ["pao_count"]         = 1,
                ["pen_count"]         = 3,
                ["pengList"] = {
                    [1] = {
                        ["card"]  = 19,
                        ["score"] = 3,
                    },
                    [2] = {
                        ["card"]  = 20,
                        ["score"] = 3,
                    },
                    [3] = {
                        ["card"]  = 21,
                        ["score"] = 3,
                    },
                },
                ["seat_id"]           = 0,
                ["tiList"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 10059,
                ["weiList"] = {
                },
                ["wei_count"]         = 0,
            },
            [2] = {
                ["biList"] = {
                },
                ["bi_count"]          = 0,
                ["chiList"] = {
                    [1] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 7,
                            [2] = 2,
                            [3] = 10,
                        },
                        ["xishu"]      = 3,
                    },
                },
                ["chi_count"]         = 1,
                ["handCardArr"] = {
                    [1]  = 23,
                    [2]  = 23,
                    [3]  = 19,
                    [4]  = 18,
                    [5]  = 5,
                    [6]  = 26,
                    [7]  = 21,
                    [8]  = 18,
                    [9]  = 23,
                    [10] = 17,
                    [11] = 3,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 11,
                ["m_chips"]           = 1661599,
                ["m_oil"]             = 0,
                ["m_totalBlc"]        = -100,
                ["m_turnBlc"]         = -100,
                ["paoList"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 2,
                ["pengList"] = {
                    [1] = {
                        ["card"]  = 22,
                        ["score"] = 3,
                    },
                    [2] = {
                        ["card"]  = 6,
                        ["score"] = 1,
                    },
                },
                ["seat_id"]           = 1,
                ["tiList"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 10060,
                ["weiList"] = {
                },
                ["wei_count"]         = 0,
            },
        },
        ["userCount"]      = 2,
    }
    
    self.ReceiveHandle = SCENENOW.scene.ReceiveHandle
    self.GameSceneView = SCENENOW.scene.GameSceneView
    self.HandCardView = SCENENOW.scene.GameSceneView.HandCardView
    self.OprorateBtn = SCENENOW.scene.GameSceneView.OprorateBtn
    dump(self.OprorateBtn.chiData1)
    dump(self.OprorateBtn.chiData2)
    dump(self.OprorateBtn.chiData3)
    dump(g_398.userInfos)
    
    self.ReceiveHandle:SVR_PLAYER_HU_CARD(data)
    -- self.ReceiveHandle:G2H_BROADCAST_GROUP_RESULT(data)
    -- self.GameSceneView:sendCard(1, 1)
    -- local pack = {}
    -- pack.seat_id = 1
    -- pack.CardValue1 = 4+16*0
    -- pack.CardValue2 = 4+16*1
    -- pack.CardValue3 = 4+16*2
    -- self.ReceiveHandle:SVR_PLAYER_PENG_CARD(pack)
    -- local pack = {}
    -- pack.seat_id = 1
    -- pack.Cardbuf = {
    --     3+16*3,
    --     2+16*1,
    --     1+16*1,
    -- }
    -- self.ReceiveHandle:SVR_PLAYER_CHI_CARD(pack)
    
end

function Test:KEY_F11()
    self.HandCardView:clearData()
end

function Test:KEY_F7()
    self.HandCardView:setCurHandCards({
        0x01,0x01,0x01,0x11,0x11,0x02,0x02,0x02,0x02,0x02, --一、二
        0x03,0x03,0x03,0x13,0x13,0x04,0x04,0x04,0x04,0x04, --三、四
        0x05,0x05,0x05,0x15,0x15,0x06,0x06,0x06,0x06,0x06, --五、六
    })
end

function Test:KEY_F12()
end

return Test