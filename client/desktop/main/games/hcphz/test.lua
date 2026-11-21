
local Test = class("Test")

function Test:debugTool()
    
    -- require("hcphz.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["cmd"]            = 4616,
        ["currCardArr"] = {
        },
        ["endGame"]        = 0,
        ["huUserArr"] = {
        },
        ["huUserCount"]    = 0,
        ["isZiMo"]         = 0,
        ["m_CurCardCount"] = 0,
        ["m_HuCard"]       = 0,
        ["nFangPaoSeat"]   = -1,
        ["nRoundResult"]   = 0,
        ["userArr"] = {
            [1] = {
                ["biList"] = {
                },
                ["bi_count"]          = 0,
                ["chiList"] = {
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1]  = 26,
                    [2]  = 2,
                    [3]  = 18,
                    [4]  = 25,
                    [5]  = 17,
                    [6]  = 8,
                    [7]  = 24,
                    [8]  = 6,
                    [9]  = 10,
                    [10] = 8,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 10,
                ["m_chips"]           = 3206426,
                ["m_oil"]             = 0,
                ["m_totalBlc"]        = 0,
                ["m_turnBlc"]         = 0,
                ["paoList"] = {
                    [1] = {
                        ["card"]  = 21,
                        ["score"] = 9,
                    },
                },
                ["pao_count"]         = 1,
                ["pen_count"]         = 0,
                ["pengList"] = {
                },
                ["seat_id"]           = 0,
                ["taiList"] = {
                },
                ["taisCount"]         = 0,
                ["tiList"] = {
                    [1] = {
                        ["card"]  = 23,
                        ["score"] = 12,
                    },
                },
                ["ti_count"]          = 1,
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
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1] = 10,
                    [2] = 8,
                    [3] = 1,
                    [4] = 8,
                    [5] = 26,
                    [6] = 24,
                    [7] = 22,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 7,
                ["m_chips"]           = 837900,
                ["m_oil"]             = 0,
                ["m_totalBlc"]        = 0,
                ["m_turnBlc"]         = 0,
                ["paoList"] = {
                    [1] = {
                        ["card"]  = 20,
                        ["score"] = 9,
                    },
                },
                ["pao_count"]         = 1,
                ["pen_count"]         = 0,
                ["pengList"] = {
                },
                ["seat_id"]           = 1,
                ["taiList"] = {
                },
                ["taisCount"]         = 0,
                ["tiList"] = {
                    [1] = {
                        ["card"]  = 4,
                        ["score"] = 9,
                    },
                    [2] = {
                        ["card"]  = 5,
                        ["score"] = 9,
                    },
                },
                ["ti_count"]          = 2,
                ["uid"]               = 10060,
                ["weiList"] = {
                    [1] = {
                        ["card"]  = 18,
                        ["opt"]   = 1,
                        ["score"] = 6,
                    },
                },
                ["wei_count"]         = 1,
            },
        },
        ["userCount"]      = 2,
    }
    g_396.fanData = {
        ["cmd"]              = 4628,
        ["seat_id"]          = 1,
        ["srcCardDatas"] = {
            [1] = 10,
        },
        ["srcXinNum"]        = 1,
        ["tarDownCardDatas"] = {
            [1] = 9,
        },
        ["tarDownXinNum"]    = 1,
        ["tarSelfCardDatas"] = {
            [1] = 10,
        },
        ["tarSelfXinNum"]    = 1,
        ["tarUpCardDatas"] = {
            [1] = 1,
        },
        ["tarUpXinNum"]      = 1,
        ["xinNum"]           = 2,
    }
    self.ReceiveHandle = SCENENOW.scene.ReceiveHandle
    self.GameSceneView = SCENENOW.scene.GameSceneView
    self.HandCardView = SCENENOW.scene.GameSceneView.HandCardView
    self.OprorateBtn = SCENENOW.scene.GameSceneView.OprorateBtn
    dump(self.OprorateBtn.chiData1)
    dump(self.OprorateBtn.chiData2)
    dump(self.OprorateBtn.chiData3)
    dump(g_396.userInfos)
    
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