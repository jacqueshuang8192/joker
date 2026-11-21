
local Test = class("Test")

function Test:debugTool()
    
    -- require("xupuphz.gameScene").new():addTo(SCENENOW.scene):setName("test")
    local data = {
        ["chouCardArr"] = {
            [1]  = 5,
            [2]  = 10,
            [3]  = 7,
            [4]  = 57,
            [5]  = 38,
            [6]  = 35,
            [7]  = 42,
            [8]  = 57,
            [9]  = 23,
            [10] = 25,
            [11] = 55,
            [12] = 6,
            [13] = 40,
            [14] = 53,
            [15] = 20,
            [16] = 51,
            [17] = 19,
            [18] = 2,
            [19] = 50,
            [20] = 25,
        },
        ["chouPaiCount"]   = 20,
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1] = 39,
            [2] = 34,
            [3] = 33,
            [4] = 19,
        },
        ["endGame"]        = 0,
        ["huUserArr"] = {
            [1] = {
                ["cardGroupArr"] = {
                    [1] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 24,
                            [2] = 24,
                            [3] = 24,
                        },
                        ["type"]      = 3,
                    },
                    [2] = {
                        ["cardCount"] = 2,
                        ["cards"] = {
                            [1] = 19,
                            [2] = 19,
                        },
                        ["type"]      = 4,
                    },
                },
                ["cardGroupCount"] = 2,
                ["groupArr"] = {
                },
                ["groupType"]      = 36,
                ["group_count"]    = 0,
                ["seat_id"]        = 1,
                ["uid"]            = 100017,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 1,
        ["m_CurCardCount"] = 4,
        ["m_HuCard"]       = 36,
        ["nFangPaoSeat"]   = -1,
        ["nRoundResult"]   = 1,
        ["userArr"] = {
            [1] = {
                ["biList"] = {
                    [1] = 34,
                    [2] = 50,
                    [3] = 18,
                },
                ["bicount"]           = 3,
                ["chiList"] = {
                    [1] = 2,
                    [2] = 35,
                    [3] = 36,
                    [4] = 39,
                    [5] = 37,
                    [6] = 6,
                    [7] = 18,
                    [8] = 55,
                    [9] = 58,
                },
                ["chicount"]          = 9,
                ["handCardArr"] = {
                    [1] = 56,
                    [2] = 22,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 2,
                ["m_chips"]           = 1008811,
                ["m_oil"]             = 0,
                ["m_totalBlc"]        = -200,
                ["m_turnBlc"]         = -200,
                ["paoCardArr"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 3,
                ["pengCardArr"] = {
                    [1] = 1,
                    [2] = 33,
                    [3] = 1,
                },
                ["seat_id"]           = 0,
                ["tiCardArr"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 100002,
                ["weiList"] = {
                    [1] = {
                        ["cardType"]   = 1,
                        ["cardvalue1"] = 53,
                        ["cardvalue2"] = 21,
                        ["cardvalue3"] = 21,
                    },
                },
                ["weicount"]          = 1,
            },
            [2] = {
                ["biList"] = {
                },
                ["bicount"]           = 0,
                ["chiList"] = {
                    [1] = 26,
                    [2] = 58,
                    [3] = 42,
                    [4] = 38,
                    [5] = 5,
                    [6] = 7,
                },
                ["chicount"]          = 6,
                ["handCardArr"] = {
                    [1] = 8,
                    [2] = 40,
                    [3] = 8,
                    [4] = 3,
                    [5] = 3,
                },
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 5,
                ["m_chips"]           = 717709,
                ["m_oil"]             = 22,
                ["m_totalBlc"]        = 200,
                ["m_turnBlc"]         = 200,
                ["paoCardArr"] = {
                },
                ["pao_count"]         = 0,
                ["pen_count"]         = 3,
                ["pengCardArr"] = {
                    [1] = 54,
                    [2] = 22,
                    [3] = 54,
                },
                ["seat_id"]           = 1,
                ["tiCardArr"] = {
                    [1] = 17,
                    [2] = 17,
                    [3] = 49,
                    [4] = 49,
                },
                ["ti_count"]          = 4,
                ["uid"]               = 100017,
                ["weiList"] = {
                    [1] = {
                        ["cardType"]   = 1,
                        ["cardvalue1"] = 36,
                        ["cardvalue2"] = 4,
                        ["cardvalue3"] = 4,
                    },
                },
                ["weicount"]          = 1,
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
  
    self.ReceiveHandle:SVR_PLAYER_HU_CARD(data)
    self.ReceiveHandle:G2H_BROADCAST_GROUP_RESULT(data)
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