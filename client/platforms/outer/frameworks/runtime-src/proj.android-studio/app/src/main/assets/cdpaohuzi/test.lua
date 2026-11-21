
local Test = class("Test")

function Test:debugTool()
    
    -- require("cdpaohuzi.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["chouCardArr"] = {
        },
        ["chouPaiCount"]   = 0,
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 25,
            [2]  = 19,
            [3]  = 6,
            [4]  = 24,
            [5]  = 1,
            [6]  = 1,
            [7]  = 17,
            [8]  = 8,
            [9]  = 26,
            [10] = 21,
            [11] = 8,
            [12] = 7,
            [13] = 2,
            [14] = 4,
            [15] = 1,
            [16] = 21,
            [17] = 26,
            [18] = 5,
            [19] = 7,
            [20] = 22,
            [21] = 3,
            [22] = 17,
            [23] = 23,
            [24] = 3,
            [25] = 9,
            [26] = 2,
            [27] = 19,
            [28] = 26,
            [29] = 24,
            [30] = 25,
            [31] = 18,
            [32] = 8,
        },
        ["endGame"]        = 0,
        ["huUserArr"] = {
            [1] = {
                ["cardGroupArr"] = {
                    [1] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 2,
                            [2] = 7,
                            [3] = 10,
                        },
                        ["type"]      = 1,
                    },
                    [2] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 18,
                            [2] = 23,
                            [3] = 26,
                        },
                        ["type"]      = 1,
                    },
                    [3] = {
                        ["cardCount"] = 2,
                        ["cards"] = {
                            [1] = 25,
                            [2] = 25,
                        },
                        ["type"]      = 4,
                    },
                },
                ["cardGroupCount"] = 3,
                ["groupArr"] = {
                },
                ["groupType"]      = 22,
                ["group_count"]    = 0,
                ["seat_id"]        = 0,
                ["uid"]            = 10059,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 1,
        ["m_CurCardCount"] = 32,
        ["m_HuCard"]       = 25,
        ["nFangPaoSeat"]   = -1,
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
                            [1] = 19,
                            [2] = 17,
                            [3] = 18,
                        },
                        ["xishu"]      = 6,
                    },
                },
                ["chi_count"]         = 1,
                ["handCardArr"] = {
                    [1] = 23,
                    [2] = 2,
                    [3] = 7,
                    [4] = 26,
                    [5] = 25,
                    [6] = 10,
                    [7] = 18,
                },
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 7,
                ["m_chips"]           = 1000926,
                ["m_oil"]             = 31,
                ["m_totalBlc"]        = 700,
                ["m_turnBlc"]         = 700,
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
                ["seat_id"]           = 0,
                ["taiList"] = {
                },
                ["taisCount"]         = 0,
                ["tiList"] = {
                    [1] = {
                        ["card"]  = 20,
                        ["score"] = 12,
                    },
                },
                ["ti_count"]          = 1,
                ["tunshu"]            = 7,
                ["uid"]               = 10059,
                ["weiList"] = {
                    [1] = {
                        ["card"]  = 9,
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
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1]  = 1,
                    [2]  = 21,
                    [3]  = 10,
                    [4]  = 10,
                    [5]  = 24,
                    [6]  = 5,
                    [7]  = 23,
                    [8]  = 17,
                    [9]  = 18,
                    [10] = 3,
                    [11] = 8,
                    [12] = 2,
                    [13] = 10,
                    [14] = 7,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 14,
                ["m_chips"]           = 1012799,
                ["m_oil"]             = 0,
                ["m_totalBlc"]        = -700,
                ["m_turnBlc"]         = -700,
                ["paoList"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 1,
                ["pengList"] = {
                    [1] = {
                        ["card"]  = 4,
                        ["score"] = 1,
                    },
                },
                ["seat_id"]           = 1,
                ["taiList"] = {
                },
                ["taisCount"]         = 0,
                ["tiList"] = {
                },
                ["ti_count"]          = 0,
                ["tunshu"]            = 0,
                ["uid"]               = 10060,
                ["weiList"] = {
                    [1] = {
                        ["card"]  = 22,
                        ["opt"]   = 1,
                        ["score"] = 6,
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
    dump(g_342.userInfos)
    
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