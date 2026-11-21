
local Test = class("Test")

function Test:debugTool()
    
    -- require("shaoyangbopi.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["chouCardArr"] = {
        },
        ["chouPaiCount"]   = 0,
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 20,
            [2]  = 19,
            [3]  = 1,
            [4]  = 25,
            [5]  = 22,
            [6]  = 4,
            [7]  = 26,
            [8]  = 6,
            [9]  = 5,
            [10] = 10,
            [11] = 9,
            [12] = 5,
            [13] = 24,
            [14] = 26,
            [15] = 18,
            [16] = 26,
            [17] = 3,
            [18] = 25,
            [19] = 3,
            [20] = 17,
            [21] = 18,
            [22] = 2,
            [23] = 22,
            [24] = 10,
            [25] = 1,
            [26] = 19,
            [27] = 7,
            [28] = 17,
            [29] = 26,
            [30] = 7,
            [31] = 8,
            [32] = 9,
            [33] = 18,
            [34] = 9,
            [35] = 20,
            [36] = 22,
            [37] = 2,
        },
        ["endGame"]        = 0,
        ["huUserArr"] = {
            [1] = {
                ["cardGroupArr"] = {
                    [1] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 8,
                            [2] = 8,
                            [3] = 8,
                        },
                        ["type"]      = 3,
                    },
                    [2] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 1,
                            [2] = 2,
                            [3] = 3,
                        },
                        ["type"]      = 1,
                    },
                    [3] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 1,
                            [2] = 2,
                            [3] = 3,
                        },
                        ["type"]      = 1,
                    },
                    [4] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 17,
                            [2] = 18,
                            [3] = 19,
                        },
                        ["type"]      = 1,
                    },
                    [5] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 22,
                            [2] = 23,
                            [3] = 24,
                        },
                        ["type"]      = 1,
                    },
                    [6] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 23,
                            [2] = 24,
                            [3] = 25,
                        },
                        ["type"]      = 1,
                    },
                },
                ["cardGroupCount"] = 6,
                ["groupArr"] = {
                },
                ["groupType"]      = 3,
                ["group_count"]    = 0,
                ["seat_id"]        = 0,
                ["taiList"] = {
                },
                ["taisCount"]      = 0,
                ["uid"]            = 1236741,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 1,
        ["m_CurCardCount"] = 37,
        ["m_HuCard"]       = 3,
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
                    [1]  = 24,
                    [2]  = 1,
                    [3]  = 19,
                    [4]  = 3,
                    [5]  = 8,
                    [6]  = 18,
                    [7]  = 22,
                    [8]  = 23,
                    [9]  = 23,
                    [10] = 1,
                    [11] = 2,
                    [12] = 2,
                    [13] = 8,
                    [14] = 25,
                    [15] = 17,
                    [16] = 24,
                    [17] = 8,
                },
                ["huxi"]              = 28,
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 17,
                ["m_chips"]           = 1102902,
                ["m_oil"]             = 18,
                ["m_totalBlc"]        = 28,
                ["m_turnBlc"]         = 2800,
                ["paoList"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 1,
                ["pengList"] = {
                    [1] = {
                        ["card"]  = 21,
                        ["score"] = 3,
                    },
                },
                ["seat_id"]           = 0,
                ["tiList"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 1236741,
                ["weiList"] = {
                },
                ["wei_count"]         = 0,
            },
            [2] = {
                ["biList"] = {
                },
                ["bi_count"]          = 0,
                ["chiList"] = {
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1]  = 19,
                    [2]  = 10,
                    [3]  = 4,
                    [4]  = 7,
                    [5]  = 20,
                    [6]  = 4,
                    [7]  = 25,
                    [8]  = 23,
                    [9]  = 21,
                    [10] = 4,
                    [11] = 24,
                    [12] = 17,
                    [13] = 9,
                    [14] = 7,
                    [15] = 23,
                    [16] = 5,
                    [17] = 10,
                },
                ["huxi"]              = 0,
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 17,
                ["m_chips"]           = 8990907,
                ["m_oil"]             = 0,
                ["m_totalBlc"]        = 0,
                ["m_turnBlc"]         = -2800,
                ["paoList"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 1,
                ["pengList"] = {
                    [1] = {
                        ["card"]  = 6,
                        ["score"] = 1,
                    },
                },
                ["seat_id"]           = 1,
                ["tiList"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 1236691,
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
    dump(g_353.userInfos)
    
    self.ReceiveHandle:SVR_PLAYER_HU_CARD(data)
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