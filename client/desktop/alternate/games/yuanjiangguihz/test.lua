
local Test = class("Test")

function Test:debugTool()
    local data = {
        ["cmd"]            = 4616,
        ["currCardArr"] = {
            [1]  = 22,
            [2]  = 7,
            [3]  = 8,
            [4]  = 10,
            [5]  = 17,
            [6]  = 2,
            [7]  = 26,
            [8]  = 18,
            [9]  = 25,
            [10] = 6,
            [11] = 19,
            [12] = 23,
            [13] = 4,
            [14] = 18,
            [15] = 8,
            [16] = 5,
            [17] = 26,
            [18] = 25,
            [19] = 18,
            [20] = 7,
            [21] = 7,
        },
        ["huUserArr"] = {
            [1] = {
                ["cardGroupArr"] = {
                    [1] = {
                        ["cardCount"] = 2,
                        ["cards"] = {
                            [1] = 10,
                            [2] = 10,
                        },
                    },
                },
                ["cardGroupCount"] = 1,
                ["groupArr"] = {
                    [1] = 2,
                    [2] = 7,
                    [3] = 10,
                },
                ["group_count"]    = 3,
                ["huTypeArr"] = {
                    [1] = {
                        ["type"] = 9,
                        ["xi"]   = 50,
                    },
                },
                ["huTypeCount"]    = 1,
                ["hufan"]          = 1,
                ["huxi"]           = 70,
                ["seat_id"]        = 1,
                ["uid"]            = 10060,
            },
        },
        ["huUserCount"]    = 1,
        ["hutypeArr"] = {
        },
        ["hutypecount"]    = 0,
        ["isZiMo"]         = 0,
        ["m_CurCardCount"] = 21,
        ["m_HuCard"]       = 10,
        ["nRoundResult"]   = 1,
        ["userArr"] = {
            [1] = {
                ["chiCardArr"] = {
                    [1] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 19,
                            [2] = 20,
                            [3] = 21,
                        },
                    },
                    [2] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 4,
                            [2] = 2,
                            [3] = 3,
                        },
                    },
                    [3] = {
                        ["card_count"] = 3,
                        ["cards"] = {
                            [1] = 26,
                            [2] = 23,
                            [3] = 18,
                        },
                    },
                },
                ["chi_count"]         = 3,
                ["handCardArr"] = {
                    [1] = 25,
                    [2] = 25,
                    [3] = 6,
                    [4] = 26,
                    [5] = 6,
                    [6] = 22,
                    [7] = 6,
                },
                ["isHu"]              = 0,
                ["liuList"] = {
                    [1] = 1,
                },
                ["liucount"]          = 1,
                ["m_byHandCardCount"] = 7,
                ["m_chips"]           = 2835905,
                ["m_totalBlc"]        = -35000,
                ["m_turnBlc"]         = -35000,
                ["penCardArr"] = {
                },
                ["pen_count"]         = 0,
                ["piaoList"] = {
                },
                ["piaocount"]         = 0,
                ["seat_id"]           = 0,
                ["uid"]               = 10059,
                ["waiCardArr"] = {
                },
                ["wai_count"]         = 0,
            },
            [2] = {
                ["chiCardArr"] = {
                },
                ["chi_count"]         = 0,
                ["handCardArr"] = {
                    [1] = 10,
                    [2] = 2,
                    [3] = 7,
                    [4] = 10,
                },
                ["isHu"]              = 1,
                ["liuList"] = {
                },
                ["liucount"]          = 0,
                ["m_byHandCardCount"] = 4,
                ["m_chips"]           = 9652400,
                ["m_totalBlc"]        = 35000,
                ["m_turnBlc"]         = 35000,
                ["penCardArr"] = {
                    [1] = {
                        ["card"]  = 17,
                        ["score"] = 3,
                    },
                },
                ["pen_count"]         = 1,
                ["piaoList"] = {
                },
                ["piaocount"]         = 0,
                ["seat_id"]           = 1,
                ["uid"]               = 10060,
                ["waiCardArr"] = {
                    [1] = 24,
                    [2] = 20,
                    [3] = 3,
                    [4] = 5,
                },
                ["wai_count"]         = 4,
            },
        },
        ["userCount"]      = 2,
    }
    g_PHZMainLayer:showResultLayer(data)
end

function Test:KEY_F11()
  
end

function Test:KEY_F7( )
    
end

function Test:KEY_F11()
 
end

return Test