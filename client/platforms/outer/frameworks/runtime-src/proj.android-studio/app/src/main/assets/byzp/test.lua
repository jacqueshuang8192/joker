
local Test = class("Test")

function Test:debugTool()
    
    -- require("byzp.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 4,
            [2]  = 10,
            [3]  = 4,
            [4]  = 4,
            [5]  = 7,
            [6]  = 21,
            [7]  = 2,
            [8]  = 24,
            [9]  = 7,
            [10] = 2,
            [11] = 23,
            [12] = 5,
            [13] = 6,
            [14] = 22,
            [15] = 22,
            [16] = 19,
            [17] = 19,
            [18] = 25,
            [19] = 23,
            [20] = 10,
            [21] = 6,
            [22] = 3,
            [23] = 18,
            [24] = 18,
            [25] = 25,
            [26] = 17,
            [27] = 2,
            [28] = 20,
            [29] = 17,
            [30] = 22,
            [31] = 1,
        },
        ["endGame"]        = 0,
        ["huUserArr"] = {
            [1] = {
                ["cardGroupArr"] = {
                    [1] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 9,
                            [2] = 9,
                            [3] = 9,
                        },
                        ["type"]      = 3,
                    },
                    [2] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 6,
                            [2] = 7,
                            [3] = 8,
                        },
                        ["type"]      = 1,
                    },
                    [3] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 18,
                            [2] = 19,
                            [3] = 20,
                        },
                        ["type"]      = 1,
                    },
                    [4] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 21,
                            [2] = 22,
                            [3] = 23,
                        },
                        ["type"]      = 1,
                    },
                },
                ["cardGroupCount"] = 4,
                ["fanxincount"]    = 3,
                ["groupArr"] = {
                },
                ["groupType"]      = 26,
                ["group_count"]    = 0,
                ["seat_id"]        = 1,
                ["uid"]            = 10060,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 0,
        ["m_CurCardCount"] = 31,
        ["m_HuCard"]       = 19,
        ["nFangPaoSeat"]   = 0,
        ["nRoundResult"]   = 1,
        ["userArr"] = {
            [1] = {
                ["biList"] = {
                },
                ["bi_count"]          = 0,
                ["chiList"] = {
                    [1] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 2,
                            [2] = 7,
                            [3] = 10,
                        },
                        ["xishu"]      = 3,
                    },
                },
                ["chi_count"]         = 1,
                ["handCardArr"] = {
                    [1]  = 8,
                    [2]  = 5,
                    [3]  = 6,
                    [4]  = 26,
                    [5]  = 20,
                    [6]  = 24,
                    [7]  = 5,
                    [8]  = 20,
                    [9]  = 9,
                    [10] = 4,
                    [11] = 23,
                    [12] = 24,
                    [13] = 24,
                    [14] = 5,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 14,
                ["m_chips"]           = 3140426,
                ["m_oil"]             = -18,
                ["m_totalBlc"]        = 4000,
                ["m_turnBlc"]         = -10000,
                ["paoList"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 0,
                ["pengList"] = {
                },
                ["seat_id"]           = 0,
                ["tiList"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 10059,
                ["weiList"] = {
                    [1] = {
                        ["card"]  = 1,
                        ["opt"]   = 1,
                        ["score"] = 3,
                    },
                },
                ["wei_count"]         = 1,
            },
            [2] = {
                ["biList"] = {
                },
                ["bi_count"]          = 0,
                ["chiList"] = {
                    [1] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 17,
                            [2] = 18,
                            [3] = 19,
                        },
                        ["xishu"]      = 6,
                    },
                },
                ["chi_count"]         = 1,
                ["handCardArr"] = {
                    [1]  = 7,
                    [2]  = 8,
                    [3]  = 9,
                    [4]  = 9,
                    [5]  = 18,
                    [6]  = 9,
                    [7]  = 21,
                    [8]  = 20,
                    [9]  = 22,
                    [10] = 6,
                    [11] = 23,
                },
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 11,
                ["m_chips"]           = 903900,
                ["m_oil"]             = 18,
                ["m_totalBlc"]        = -4000,
                ["m_turnBlc"]         = 10000,
                ["paoList"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 0,
                ["pengList"] = {
                },
                ["seat_id"]           = 1,
                ["tiList"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 10060,
                ["weiList"] = {
                    [1] = {
                        ["card"]  = 3,
                        ["opt"]   = 1,
                        ["score"] = 3,
                    },
                    [2] = {
                        ["card"]  = 26,
                        ["opt"]   = 1,
                        ["score"] = 6,
                    },
                },
                ["wei_count"]         = 2,
            },
        },
        ["userCount"]      = 2,
    }
    g_359.fanData = {
        ["cmd"]              = 4628,
        ["seat_id"]          = 1,
        ["srcCardDatas"] = {
            [1] = 4,
        },
        ["srcXinNum"]        = 1,
        ["tarDownCardDatas"] = {
            [1] = 3,
        },
        ["tarDownXinNum"]    = 1,
        ["tarSelfCardDatas"] = {
            [1] = 4,
        },
        ["tarSelfXinNum"]    = 1,
        ["tarUpCardDatas"] = {
            [1] = 5,
        },
        ["tarUpXinNum"]      = 1,
        ["xinNum"]           = 3,
    }
    self.ReceiveHandle = SCENENOW.scene.ReceiveHandle
    self.GameSceneView = SCENENOW.scene.GameSceneView
    self.HandCardView = SCENENOW.scene.GameSceneView.HandCardView
    self.OprorateBtn = SCENENOW.scene.GameSceneView.OprorateBtn
    dump(self.OprorateBtn.chiData1)
    dump(self.OprorateBtn.chiData2)
    dump(self.OprorateBtn.chiData3)
    dump(g_359.userInfos)
    
    self.ReceiveHandle:SVR_PLAYER_HU_CARD(data)
    -- self.ReceiveHandle:G2H_BROADCAST_GROUP_RESULT(data)
    -- self.GameSceneView:setGameResult(data)
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