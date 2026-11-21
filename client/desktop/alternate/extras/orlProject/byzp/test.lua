
local test = class("test")
local ResultLayer = require("byzp.view.PHZResultLayer")
function test:debugTool()
    local PHZReceiveHandle = require("byzp.handle.PHZReceiveHandle")
    local data = {
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 8,
            [2]  = 18,
            [3]  = 26,
            [4]  = 26,
            [5]  = 9,
            [6]  = 1,
            [7]  = 20,
            [8]  = 17,
            [9]  = 2,
            [10] = 20,
            [11] = 24,
            [12] = 19,
            [13] = 25,
            [14] = 6,
            [15] = 9,
            [16] = 6,
            [17] = 6,
            [18] = 2,
            [19] = 18,
            [20] = 18,
            [21] = 3,
            [22] = 17,
            [23] = 22,
            [24] = 18,
            [25] = 26,
            [26] = 23,
            [27] = 17,
            [28] = 10,
            [29] = 5,
            [30] = 19,
            [31] = 9,
            [32] = 4,
            [33] = 17,
        },
        ["endGame"]        = 1,
        ["huUserArr"] = {
            [1] = {
                ["cardGroupArr"] = {
                    [1] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 25,
                            [2] = 25,
                            [3] = 25,
                        },
                        ["type"]      = 3,
                    },
                    [2] = {
                        ["cardCount"] = 3,
                        ["cards"] = {
                            [1] = 2,
                            [2] = 7,
                            [3] = 10,
                        },
                        ["type"]      = 1,
                    },
                    [3] = {
                        ["cardCount"] = 2,
                        ["cards"] = {
                            [1] = 3,
                            [2] = 3,
                        },
                        ["type"]      = 4,
                    },
                },
                ["cardGroupCount"] = 3,
                ["fanxincount"]    = 0,
                ["groupArr"] = {
                },
                ["groupType"]      = 0,
                ["group_count"]    = 0,
                ["seat_id"]        = 1,
                ["uid"]            = 10060,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 1,
        ["m_CurCardCount"] = 33,
        ["m_HuCard"]       = 0,
        ["nFangPaoSeat"]   = -1,
        ["nRoundResult"]   = 1,
        ["userArr"] = {
            [1] = {
                ["biCardArr"] = {
                },
                ["bi_count"]          = 0,
                ["chiCardArr"] = {
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1]  = 22,
                    [2]  = 10,
                    [3]  = 3,
                    [4]  = 10,
                    [5]  = 2,
                    [6]  = 19,
                    [7]  = 7,
                    [8]  = 22,
                    [9]  = 19,
                    [10] = 7,
                    [11] = 23,
                    [12] = 7,
                    [13] = 22,
                    [14] = 26,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 14,
                ["m_chips"]           = 2723100,
                ["m_oil"]             = -24,
                ["m_totalBlc"]        = -4000,
                ["m_turnBlc"]         = -4000,
                ["paoCardArr"] = {
                },
                ["pao_count"]         = 0,
                ["penCardArr"] = {
                    [1] = {
                        ["card"]  = 1,
                        ["score"] = 1,
                    },
                    [2] = {
                        ["card"]  = 24,
                        ["score"] = 3,
                    },
                },
                ["pen_count"]         = 2,
                ["seat_id"]           = 0,
                ["tiCardArr"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 10059,
                ["weiCardArr"] = {
                },
                ["wei_count"]         = 0,
            },
            [2] = {
                ["biCardArr"] = {
                },
                ["bi_count"]          = 0,
                ["chiCardArr"] = {
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1] = 3,
                    [2] = 3,
                    [3] = 25,
                    [4] = 25,
                    [5] = 25,
                    [6] = 2,
                    [7] = 10,
                },
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 7,
                ["m_chips"]           = 1292100,
                ["m_oil"]             = 24,
                ["m_totalBlc"]        = 4000,
                ["m_turnBlc"]         = 4000,
                ["paoCardArr"] = {
                },
                ["pao_count"]         = 0,
                ["penCardArr"] = {
                    [1] = {
                        ["card"]  = 5,
                        ["score"] = 1,
                    },
                    [2] = {
                        ["card"]  = 4,
                        ["score"] = 1,
                    },
                    [3] = {
                        ["card"]  = 8,
                        ["score"] = 1,
                    },
                },
                ["pen_count"]         = 3,
                ["seat_id"]           = 1,
                ["tiCardArr"] = {
                    [1] = {
                        ["card"]  = 21,
                        ["score"] = 12,
                    },
                },
                ["ti_count"]          = 1,
                ["uid"]               = 10060,
                ["weiCardArr"] = {
                },
                ["wei_count"]         = 0,
            },
        },
        ["userCount"]      = 2,
    }
    -- PHZReceiveHandle:SVR_PLAYER_TING_INFO(data)
    g_PHZMainScene.m_AllZhanJi = {
        ["cmd"]          = 4617,
        ["isShowSingle"] = 1,
        ["player_count"] = 2,
        ["player_info"] = {
            [1] = {
                ["huxilist"] = {
                    [1] = 6000,
                    [2] = -4000,
                    [3] = 2000,
                    [4] = -5000,
                    [5] = 6000,
                    [6] = -6000,
                },
                ["huxilistNum"] = 6,
                ["m_totalBlc"]  = -1000,
                ["totalScore"]  = -1000,
                ["uid"]         = 10059,
            },
            [2] = {
                ["huxilist"] = {
                    [1] = -6000,
                    [2] = 4000,
                    [3] = -2000,
                    [4] = 5000,
                    [5] = -6000,
                    [6] = 6000,
                },
                ["huxilistNum"] = 6,
                ["m_totalBlc"]  = 1000,
                ["totalScore"]  = 1000,
                ["uid"]         = 10060,
            },
        },
    }
    g_fanCardValue = {
        ["cmd"]              = 4628,
        ["seat_id"]          = 1,
        ["srcCardDatas"] = {
            [1] = 8,
        },
        ["srcXinNum"]        = 1,
        ["tarDownCardDatas"] = {
            [1] = 7,
        },
        ["tarDownXinNum"]    = 1,
        ["tarSelfCardDatas"] = {
            [1] = 8,
        },
        ["tarSelfXinNum"]    = 1,
        ["tarUpCardDatas"] = {
            [1] = 9,
        },
        ["tarUpXinNum"]      = 1,
        ["xinNum"]           = 0,
    }
    g_PHZMainScene.m_isGameOver = true
    g_PHZMainLayer:showResultLayer(data)
end


function test:getData( )
    g_fanCardValue = {
        ["cmd"]              = 4628,
        ["seat_id"]          = 1,
        ["srcCardDatas"] = {
            [1] = 8,
        },
        ["srcXinNum"]        = 1,
        ["tarDownCardDatas"] = {
            [1] = 7,
        },
        ["tarDownXinNum"]    = 1,
        ["tarSelfCardDatas"] = {
            [1] = 8,
        },
        ["tarSelfXinNum"]    = 1,
        ["tarUpCardDatas"] = {
            [1] = 9,
        },
        ["tarUpXinNum"]      = 1,
        ["xinNum"]           = 0,
    }
    self.data = {
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 25,
            [2]  = 1,
            [3]  = 1,
            [4]  = 10,
            [5]  = 10,
            [6]  = 24,
            [7]  = 7,
            [8]  = 17,
            [9]  = 6,
            [10] = 23,
            [11] = 6,
            [12] = 26,
            [13] = 25,
            [14] = 17,
            [15] = 21,
            [16] = 8,
            [17] = 18,
            [18] = 9,
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
                            [1] = 8,
                            [2] = 8,
                        },
                        ["type"]      = 4,
                    },
                },
                ["cardGroupCount"] = 2,
                ["groupArr"] = {
                },
                ["groupType"]      = 23,
                ["group_count"]    = 0,
                ["seat_id"]        = 0,
                ["uid"]            = 10059,
            },
        },
        ["huUserCount"]    = 1,
        ["isZiMo"]         = 1,
        ["m_CurCardCount"] = 18,
        ["m_HuCard"]       = 0,
        ["nFangPaoSeat"]   = 1,
        ["nRoundResult"]   = 1,
        ["userArr"] = {
            [1] = {
                ["biCardArr"] = {
                },
                ["bi_count"]          = 0,
                ["chiCardArr"] = {
                    [1] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 26,
                            [2] = 10,
                            [3] = 26,
                        },
                        ["xishu"]      = 0,
                    },
                    [2] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 20,
                            [2] = 4,
                            [3] = 4,
                        },
                        ["xishu"]      = 0,
                    },
                },
                ["chi_count"]         = 2,
                ["handCardArr"] = {
                    [1] = 24,
                    [2] = 24,
                    [3] = 24,
                    [4] = 8,
                },
                ["isHu"]              = 1,
                ["m_byHandCardCount"] = 4,
                ["m_chips"]           = 914000,
                ["m_oil"]             = 21,
                ["m_totalBlc"]        = 6000,
                ["m_turnBlc"]         = 6000,
                ["paoCardArr"] = {
                    [1] = {
                        ["card"]  = 2,
                        ["score"] = 6,
                    },
                    [2] = {
                        ["card"]  = 5,
                        ["score"] = 6,
                    },
                },
                ["pao_count"]         = 2,
                ["penCardArr"] = {
                    [1] = {
                        ["card"]  = 22,
                        ["score"] = 3,
                    },
                },
                ["pen_count"]         = 1,
                ["seat_id"]           = 0,
                ["tiCardArr"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 10059,
                ["weiCardArr"] = {
                },
                ["wei_count"]         = 0,
            },
            [2] = {
                ["biCardArr"] = {
                },
                ["bi_count"]          = 0,
                ["chiCardArr"] = {
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1]  = 3,
                    [2]  = 18,
                    [3]  = 3,
                    [4]  = 4,
                    [5]  = 21,
                    [6]  = 25,
                    [7]  = 6,
                    [8]  = 7,
                    [9]  = 22,
                    [10] = 26,
                    [11] = 10,
                    [12] = 21,
                    [13] = 20,
                },
                ["isHu"]              = 0,
                ["m_byHandCardCount"] = 13,
                ["m_chips"]           = 985900,
                ["m_oil"]             = -21,
                ["m_totalBlc"]        = -6000,
                ["m_turnBlc"]         = -6000,
                ["paoCardArr"] = {
                    [1] = {
                        ["card"]  = 19,
                        ["score"] = 9,
                    },
                },
                ["pao_count"]         = 1,
                ["penCardArr"] = {
                },
                ["pen_count"]         = 0,
                ["seat_id"]           = 1,
                ["tiCardArr"] = {
                },
                ["ti_count"]          = 0,
                ["uid"]               = 10060,
                ["weiCardArr"] = {
                    [1] = {
                        ["card"]  = 23,
                        ["opt"]   = 1,
                        ["score"] = 6,
                    },
                },
                ["wei_count"]         = 1,
            },
        },
        ["userCount"]      = 2,
    }
end
return test