
local Test = class("Test")

function Test:debugTool()
    
    -- require("ldfpaofa.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["chouCardArr"] = {
        },
        ["chouPaiCount"]   = 0,
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 26,
            [2]  = 19,
            [3]  = 6,
            [4]  = 6,
            [5]  = 9,
            [6]  = 4,
            [7]  = 7,
            [8]  = 3,
            [9]  = 24,
            [10] = 25,
            [11] = 7,
            [12] = 22,
            [13] = 17,
            [14] = 23,
            [15] = 17,
            [16] = 20,
            [17] = 1,
            [18] = 25,
            [19] = 18,
            [20] = 18,
            [21] = 18,
            [22] = 8,
            [23] = 9,
            [24] = 3,
            [25] = 8,
            [26] = 10,
            [27] = 3,
            [28] = 5,
            [29] = 1,
            [30] = 23,
            [31] = 5,
            [32] = 24,
            [33] = 22,
            [34] = 2,
        },
        ["endGame"]        = 1,
        ["huUserArr"] = {
            [1] = {
                ["cardGroupArr"] = {
                    [1] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 1,
                            [2] = 1,
                            [3] = 17,
                        },
                        ["type"]      = 1,
                    },
                    [2] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 5,
                            [2] = 6,
                            [3] = 7,
                        },
                        ["type"]      = 1,
                    },
                    [3] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 24,
                            [2] = 24,
                            [3] = 8,
                        },
                        ["type"]      = 1,
                    },
                    [4] = {
                        ["cardCount"] = 2,
                        ["cards"] = {
                            [1] = 26,
                            [2] = 26,
                        },
                        ["type"]      = 4,
                    },
                },
                ["cardGroupCount"] = 4,
                ["seat_id"]        = 0,
                ["taiList"] = {
                },
                ["taisCount"]      = 0,
                ["uid"]            = 100002,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 0,
        ["m_CurCardCount"] = 34,
        ["m_HuCard"]       = 17,
        ["nFangPaoSeat"]   = 1,
        ["nRoundResult"]   = 1,
        ["now"]            = 1685524435.3346,
        ["userArr"] = {
            [1] = {
                ["biList"] = {
                },
                ["bi_count"]          = 0,
                ["chiList"] = {
                    [1] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 19,
                            [2] = 17,
                            [3] = 18,
                        },
                        ["xishu"]      = 6,
                    },
                },
                ["chi_count"]         = 1,
                ["handCardArr"] = {
                    [1]  = 1,
                    [2]  = 8,
                    [3]  = 6,
                    [4]  = 7,
                    [5]  = 26,
                    [6]  = 24,
                    [7]  = 5,
                    [8]  = 26,
                    [9]  = 1,
                    [10] = 24,
                },
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 10,
                ["m_chips"]           = 861780,
                ["m_oil"]             = 2100,
                ["m_totalBlc"]        = 2700,
                ["m_turnBlc"]         = 2100,
                ["paoList"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 1,
                ["pengList"] = {
                    [1] = {
                        ["card"]  = 20,
                        ["score"] = 3,
                    },
                },
                ["seat_id"]           = 0,
                ["tiList"] = {
                    [1] = {
                        ["card"]  = 21,
                        ["score"] = 12,
                    },
                },
                ["ti_count"]          = 1,
                ["uid"]               = 100002,
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
                    [1]  = 23,
                    [2]  = 5,
                    [3]  = 23,
                    [4]  = 4,
                    [5]  = 9,
                    [6]  = 7,
                    [7]  = 6,
                    [8]  = 9,
                    [9]  = 25,
                    [10] = 19,
                    [11] = 8,
                    [12] = 19,
                    [13] = 26,
                    [14] = 25,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 14,
                ["m_chips"]           = 730590,
                ["m_oil"]             = 0,
                ["m_totalBlc"]        = 8100,
                ["m_turnBlc"]         = -2100,
                ["paoList"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 1,
                ["pengList"] = {
                    [1] = {
                        ["card"]  = 10,
                        ["score"] = 1,
                    },
                },
                ["seat_id"]           = 1,
                ["tiList"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 100017,
                ["weiList"] = {
                    [1] = {
                        ["card"]  = 2,
                        ["opt"]   = 1,
                        ["score"] = 3,
                    },
                },
                ["wei_count"]         = 1,
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
    dump(g_345.userInfos)
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
    -- self.HandCardView:clearData()

    -- SCENENOW["scene"]:getChildByName("SettlementView"):removeSelf()
   
    dump(g_345.settlementData)
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