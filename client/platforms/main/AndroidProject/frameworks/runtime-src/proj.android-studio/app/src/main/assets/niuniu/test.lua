local Test = class('Test')
local NiuNiuReceiveHandle = import(TpackageName .. '.handle.NiuNiuReceiveHandle')


function Test:debugTool()
    local pack =   {
        ["activityId"]                     = 150355,
        ["allUsersReadyStatus"]            = 0,
        ["bank_uid"]                       = -1,
        ["bankerOptState"]                 = 0,
        ["base"]                           = 1,
        ["bonusPool"]                      = -1,
        ["canGrabDealer"]                  = 1,
        ["can_grab_times"] = {
        },
        ["can_grab_times_mount"]           = 0,
        ["can_selects_base"] = {
        },
        ["can_selects_base_mount"]         = 0,
        ["card_mount"]                     = 0,
        ["cards"] = {
        },
        ["club_id"]                        = 100026,
        ["cmd"]                            = 4103,
        ["gameConfig"]                     = '{"additionalPoint":900,"baseChip":1,"cardCount":2,"gaoji":"7,6,3","grabDealerChips":200,"grabTimes":4,"hasLeper":0,"id":216,"joinGamePoint":20000,"master":100046,"maxSeatCount":6,"name":"一倍无华200进","niu10":4,"niu7":2,"niu8":3,"niu9":3,"oneOrAll":2,"profit":10,"profitLimit":500,"profitType":0,"rateOrConstant":1,"readyPoint":1000,"round":10,"secConstant":"","showCardNums":4,"speType":"5,6,2,3,8,1,4","subGameType":1,"tgTime":30,"tuizhu":10}',
        ["gameType"]                       = 1,
        ["gold"]                           = 1196029,
        ["grab_times"] = {
        },
        ["grab_times_mount"]               = 0,
        ["hasLeper"]                       = 0,
        ["initialChip"]                    = 10,
        ["inviteCode"]                     = "008781",
        ["isGoldGame"]                     = 1,
        ["isWatch"]                        = 0,
        ["leperCount"]                     = 0,
        ["lepers"] = {
        },
        ["less_time"]                      = 1,
        ["lost"]                           = 0,
        ["m_curGuoJuSize"]                 = 5,
        ["m_guodi"]                        = 0,
        ["m_nGuoCount"]                    = 1,
        ["maxPlyaerNum"]                   = 6,
        ["seat_id"]                        = -1,
        ["selects_base"] = {
        },
        ["selects_base_mount"]             = 0,
        ["start_id"]                       = 0,
        ["table_kind"]                     = 0,
        ["table_status"]                   = 0,
        ["user_base_calltime"]             = 0,
        ["user_base_out"]                  = 0,
        ["user_base_out_card_kind"]        = 1,
        ["user_base_out_cards"] = {
        },
        ["user_base_out_cards_mount"]      = 0,
        ["user_base_waitplay"]             = 0,
        ["user_base_waitplay_cards"] = {
        },
        ["user_base_waitplay_cards_mount"] = 0,
        ["user_mount"]                     = 5,
        ["user_status"]                    = 0,
        ["users_infos"] = {
            [1] = {
                ["gold"]                           = 241998,
                ["ip"]                             = "",
                ["keTuizhu"]                       = 0,
                ["latitude"]                       = "0",
                ["longitude"]                      = "0",
                ["lost"]                           = 0,
                ["nickName"]                       = "点滴回收王沙18174490203",
                ["otherInfo"]                      = '{"club_id":100026,"addres":"","city":"张家界市","ip":"127.0.0.1"}',
                ["portrait"]                       = "https://thirdwx.qlogo.cn/mmopen/vi_32/P241mpUZlicH2V4V9JdYzXralVicU2ib6RZUxWxGVrqp6BUL0bwAFJypG6jsUP4icWT5icX0ia3kpicSLeXICdn2xPgiaA/132",
                ["seat_id"]                        = 0,
                ["sex"]                            = 2,
                ["tuizhu"]                         = 0,
                ["uid"]                            = 101445,
                ["user_base_calltime"]             = 0,
                ["user_base_out"]                  = 0,
                ["user_base_out_cards"] = {
                },
                ["user_base_out_cards_cardkind"]   = 0,
                ["user_base_out_cards_mount"]      = 0,
                ["user_base_waitplay"]             = 0,
                ["user_base_waitplay_cards_mount"] = 0,
                ["user_if_auto"]                   = 0,
                ["user_if_outline"]                = 1,
                ["user_status"]                    = 1,
                ["win"]                            = 0,
            },
            [2] = {
                ["gold"]                           = 79883,
                ["ip"]                             = "",
                ["keTuizhu"]                       = 0,
                ["latitude"]                       = "29.455331",
                ["longitude"]                      = "109.447474",
                ["lost"]                           = 0,
                ["nickName"]                       = "冰墩墩",
                ["otherInfo"]                      = '{"club_id":100026,"addres":"","city":"湘西土家族苗族自治州","ip":"127.0.0.1"}',
                ["portrait"]                       = "https://thirdwx.qlogo.cn/mmopen/vi_32/alicGf1YcdPib7ibsMWYtcGiaORxeB1spianxibuC1aSNiak48rqtt6ib6PGLBgj8Hd2zALsRatmqlObGwGwzZI9Lic3yAw/132",
                ["seat_id"]                        = 1,
                ["sex"]                            = 2,
                ["tuizhu"]                         = 0,
                ["uid"]                            = 100687,
                ["user_base_calltime"]             = 0,
                ["user_base_out"]                  = 0,
                ["user_base_out_cards"] = {
                },
                ["user_base_out_cards_cardkind"]   = 0,
                ["user_base_out_cards_mount"]      = 0,
                ["user_base_waitplay"]             = 0,
                ["user_base_waitplay_cards_mount"] = 0,
                ["user_if_auto"]                   = 0,
                ["user_if_outline"]                = 1,
                ["user_status"]                    = 1,
                ["win"]                            = 0,
            },
            [3] = {
                ["gold"]                           = 111559,
                ["ip"]                             = "",
                ["keTuizhu"]                       = 0,
                ["latitude"]                       = "0",
                ["longitude"]                      = "0",
                ["lost"]                           = 0,
                ["nickName"]                       = "哦",
                ["otherInfo"]                      = '{"club_id":100026,"addres":"","city":"","ip":"127.0.0.1"}',
                ["portrait"]                       = "https://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLIicEOcWEPytjAog6FqIktyYRlwK8mmdPPG3RPAn1ZvaCc01q9a9YFoINYBicggLeQgY62yU7bwUqw/132",
                ["seat_id"]                        = 2,
                ["sex"]                            = 2,
                ["tuizhu"]                         = 0,
                ["uid"]                            = 101395,
                ["user_base_calltime"]             = 0,
                ["user_base_out"]                  = 0,
                ["user_base_out_cards"] = {
                },
                ["user_base_out_cards_cardkind"]   = 0,
                ["user_base_out_cards_mount"]      = 0,
                ["user_base_waitplay"]             = 0,
                ["user_base_waitplay_cards_mount"] = 0,
                ["user_if_auto"]                   = 0,
                ["user_if_outline"]                = 1,
                ["user_status"]                    = 0,
                ["win"]                            = 0,
            },
            [4] = {
                ["gold"]                           = 28048,
                ["ip"]                             = "",
                ["keTuizhu"]                       = 0,
                ["latitude"]                       = "0",
                ["longitude"]                      = "0",
                ["lost"]                           = 0,
                ["nickName"]                       = "安稳",
                ["otherInfo"]                      = '{"club_id":100026,"addres":"","city":"长沙市","ip":"127.0.0.1"}',
                ["portrait"]                       = "https://thirdwx.qlogo.cn/mmopen/vi_32/nKYG4iaW5hvwPmBbficjPmNeXhlNJbl3IoC6SF7MZFFy20RianCVInl8boBJZaVU2NyGw8TjDHmRfNP5hL4wI56LA/132",
                ["seat_id"]                        = 3,
                ["sex"]                            = 2,
                ["tuizhu"]                         = 0,
                ["uid"]                            = 100072,
                ["user_base_calltime"]             = 0,
                ["user_base_out"]                  = 0,
                ["user_base_out_cards"] = {
                },
                ["user_base_out_cards_cardkind"]   = 0,
                ["user_base_out_cards_mount"]      = 0,
                ["user_base_waitplay"]             = 0,
                ["user_base_waitplay_cards_mount"] = 0,
                ["user_if_auto"]                   = 0,
                ["user_if_outline"]                = 1,
                ["user_status"]                    = 1,
                ["win"]                            = 0,
            },
            [5] = {
                ["gold"]                           = 146788,
                ["ip"]                             = "",
                ["keTuizhu"]                       = 0,
                ["latitude"]                       = "0",
                ["longitude"]                      = "0",
                ["lost"]                           = 0,
                ["nickName"]                       = "理解",
                ["otherInfo"]                      = '{"club_id":100026,"addres":"","city":"恩施土家族苗族自治州","ip":"127.0.0.1"}',
                ["portrait"]                       = "https://thirdwx.qlogo.cn/mmopen/vi_32/YZiam4j42deweCibvibRce5FLtDMAPSibPmGq2js5JTbFibrYibvzcX3etLjSdaZXXQz41s6zbIOYiawC8aibDe2E1tg3g/132",
                ["seat_id"]                        = 4,
                ["sex"]                            = 2,
                ["tuizhu"]                         = 0,
                ["uid"]                            = 101394,
                ["user_base_calltime"]             = 0,
                ["user_base_out"]                  = 0,
                ["user_base_out_cards"] = {
                },
                ["user_base_out_cards_cardkind"]   = 0,
                ["user_base_out_cards_mount"]      = 0,
                ["user_base_waitplay"]             = 0,
                ["user_base_waitplay_cards_mount"] = 0,
                ["user_if_auto"]                   = 0,
                ["user_if_outline"]                = 1,
                ["user_status"]                    = 0,
                ["win"]                            = 0,
            },
        },
        ["waiweibet_chips"] = {
            [1] = 1,
            [2] = 2,
            [3] = 5,
        },
        ["waiweibet_count"]                = 3,
        ["win"]                            = 0,
    }
    NiuNiuReceiveHandle:SVR_LOGIN_ROOM(pack)
end

function Test:KEY_F7()
    
end

function Test:KEY_F11()
    local pack = {
        ["cmd"]           = 24578,
        ["hasLeper"]      = 0,
        ["leperCount"]    = 0,
        ["lepers"] = {
        },
        ["playerCount"]   = 0,
        ["send_card_num"] = 4,
        ["user_datas"] = {
        },
    }
    NiuNiuReceiveHandle:SVR_BROADCAST_GAME_START(pack)
end

function Test:KEY_F12()
local GamePlaneOperator = require(TpackageName .. '.operator.GamePlaneOperator')
GamePlaneOperator:showTableLaizi(77)
end
return Test
