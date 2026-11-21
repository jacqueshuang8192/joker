
local Test = class("Test")

function Test:debugTool()
    local data = {
        ["cmd"]       = 24614,
        ["count"]     = 2,
        ["isAction"]  = true,
        ["readyTime"] = 3,
        ["userinfos"] = {
            [1] = {
                ["callTimesTime"]     = 10,
                ["cardSpcardOutType"] = 0,
                ["dqMap"] = {
                },
                ["dqSize"]            = 0,
                ["gold"]              = 100,
                ["icon_url"]          = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJmV9icZPicm0TEgpg1XHLOYvicAxmMhQCRvCWjJ0dykiasGP1JRdA7d0v7D2Rqw6d3QNYXedNtV6q42A/132",
                ["isSwat"]            = 0,
                ["jcScore"]           = 1,
                ["m_chips"]           = 948421,
                ["nickName"]          = "良缘",
                ["openCard"] = {
                    [1] = {
                        ["son_card"] = {
                            [1] = {
                                ["card"]   = 11,
                                ["isKing"] = 0,
                            },
                            [2] = {
                                ["card"]   = 10,
                                ["isKing"] = 0,
                            },
                            [3] = {
                                ["card"]   = 23,
                                ["isKing"] = 0,
                            },
                        },
                        ["son_card_size"] = 3,
                        ["son_card_type"] = 1,
                    },
                    [2] = {
                        ["son_card"] = {
                            [1] = {
                                ["card"]   = 57,
                                ["isKing"] = 0,
                            },
                            [2] = {
                                ["card"]   = 41,
                                ["isKing"] = 0,
                            },
                            [3] = {
                                ["card"]   = 54,
                                ["isKing"] = 0,
                            },
                            [4] = {
                                ["card"]   = 53,
                                ["isKing"] = 0,
                            },
                            [5] = {
                                ["card"]   = 35,
                                ["isKing"] = 0,
                            },
                        },
                        ["son_card_size"] = 5,
                        ["son_card_type"] = 2,
                    },
                    [3] = {
                        ["son_card"] = {
                            [1] = {
                                ["card"]   = 34,
                                ["isKing"] = 0,
                            },
                            [2] = {
                                ["card"]   = 18,
                                ["isKing"] = 0,
                            },
                            [3] = {
                                ["card"]   = 2,
                                ["isKing"] = 0,
                            },
                            [4] = {
                                ["card"]   = 52,
                                ["isKing"] = 0,
                            },
                            [5] = {
                                ["card"]   = 4,
                                ["isKing"] = 0,
                            },
                        },
                        ["son_card_size"] = 5,
                        ["son_card_type"] = 7,
                    },
                },
                ["openCardSize"]      = 3,
                ["tdScore"]           = 1,
                ["tsTScore"]          = 0,
                ["tsWScore"]          = 0,
                ["tsZScore"]          = 0,
                ["turngold"]          = 1,
                ["uid"]               = 1236741,
                ["wdScore"]           = -1,
                ["zdScore"]           = 1,
            },
            [2] = {
                ["callTimesTime"]     = 10,
                ["cardSpcardOutType"] = 0,
                ["dqMap"] = {
                },
                ["dqSize"]            = 0,
                ["gold"]              = -100,
                ["icon_url"]          = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJ24chnIbicnZmJuwuxC6j5icOu5jKgG15ktTrT6Nqckk21qmWUPnpfAuXz029Yp1BA41mS5hr2nLmQ/132",
                ["isSwat"]            = 0,
                ["jcScore"]           = -1,
                ["m_chips"]           = 9027707,
                ["nickName"]          = "隐身守候",
                ["openCard"] = {
                    [1] = {
                        ["son_card"] = {
                            [1] = {
                                ["card"]   = 6,
                                ["isKing"] = 0,
                            },
                            [2] = {
                                ["card"]   = 36,
                                ["isKing"] = 0,
                            },
                            [3] = {
                                ["card"]   = 51,
                                ["isKing"] = 0,
                            },
                        },
                        ["son_card_size"] = 3,
                        ["son_card_type"] = 1,
                    },
                    [2] = {
                        ["son_card"] = {
                            [1] = {
                                ["card"]   = 33,
                                ["isKing"] = 0,
                            },
                            [2] = {
                                ["card"]   = 29,
                                ["isKing"] = 0,
                            },
                            [3] = {
                                ["card"]   = 28,
                                ["isKing"] = 0,
                            },
                            [4] = {
                                ["card"]   = 58,
                                ["isKing"] = 0,
                            },
                            [5] = {
                                ["card"]   = 39,
                                ["isKing"] = 0,
                            },
                        },
                        ["son_card_size"] = 5,
                        ["son_card_type"] = 1,
                    },
                    [3] = {
                        ["son_card"] = {
                            [1] = {
                                ["card"]   = 50,
                                ["isKing"] = 0,
                            },
                            [2] = {
                                ["card"]   = 18,
                                ["isKing"] = 0,
                            },
                            [3] = {
                                ["card"]   = 2,
                                ["isKing"] = 0,
                            },
                            [4] = {
                                ["card"]   = 56,
                                ["isKing"] = 0,
                            },
                            [5] = {
                                ["card"]   = 24,
                                ["isKing"] = 0,
                            },
                        },
                        ["son_card_size"] = 5,
                        ["son_card_type"] = 7,
                    },
                },
                ["openCardSize"]      = 3,
                ["tdScore"]           = -1,
                ["tsTScore"]          = 0,
                ["tsWScore"]          = 0,
                ["tsZScore"]          = 0,
                ["turngold"]          = -1,
                ["uid"]               = 1236691,
                ["wdScore"]           = 1,
                ["zdScore"]           = -1,
            },
        },
    }
    local ShiSanZhangReceiveHandle = import(TpackageName .. ".handle.ShiSanZhangReceiveHandle")
    ShiSanZhangReceiveHandle:SVR_END(data)
end

function Test:KEY_F11()
  
end

function Test:KEY_F7( )
    
end

function Test:KEY_F11()
 
end

return Test