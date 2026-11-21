
local Test = class("Test")

function Test:debugTool()
    local data = {
        ["bankerId"]     = 1236741,
        ["birdCards"] = {
            [1] = {
                ["card"]      = 2,
                ["isZhongMa"] = 0,
            },
            [2] = {
                ["card"]      = 5,
                ["isZhongMa"] = 1,
            },
        },
        ["birdCount"]    = 2,
        ["cmd"]          = 24584,
        ["maScore"]      = 1,
        ["nRoundResult"] = 1,
        ["players"] = {
            [1] = {
                ["agCards"] = {
                },
                ["agCount"]          = 0,
                ["bgCount"]          = 0,
                ["changeCoins"]      = 600,
                ["dgCount"]          = 0,
                ["gCards"] = {
                },
                ["gCount"]           = 0,
                ["hu_tai"] = {
                    [1] = {
                        ["byTaiCount"] = 1,
                        ["byType"]     = 1,
                    },
                },
                ["hu_tai_size"]      = 1,
                ["hucontent"] = {
                    [1] = {
                        ["hutype"] = 2,
                        ["zimo"] = {
                            [1] = {
                                ["huCard"]         = 21,
                                ["ifgangshanghua"] = 0,
                            },
                        },
                    },
                },
                ["ifhu"]             = 1,
                ["ifpao"]            = 0,
                ["isDaHu"]           = 0,
                ["isOnline"]         = 1,
                ["isQingShui"]       = 0,
                ["m_chips"]          = 10600,
                ["nick"]             = "良缘",
                ["pCards"] = {
                    [1] = 25,
                },
                ["pCount"]           = 1,
                ["pgCount"]          = 0,
                ["piaoScore"]        = 0,
                ["portrait"]         = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJmV9icZPicm0TEgpg1XHLOYvicAxmMhQCRvCWjJ0dykiasGP1JRdA7d0v7D2Rqw6d3QNYXedNtV6q42A/132",
                ["remainCards"] = {
                    [1]  = 3,
                    [2]  = 3,
                    [3]  = 18,
                    [4]  = 19,
                    [5]  = 20,
                    [6]  = 21,
                    [7]  = 23,
                    [8]  = 24,
                    [9]  = 65,
                    [10] = 65,
                    [11] = 65,
                },
                ["remainCardsCount"] = 11,
                ["seat_id"]          = 0,
                ["uid"]              = 1236741,
            },
            [2] = {
                ["agCards"] = {
                },
                ["agCount"]          = 0,
                ["bgCount"]          = 0,
                ["changeCoins"]      = -200,
                ["dgCount"]          = 0,
                ["gCards"] = {
                },
                ["gCount"]           = 0,
                ["hu_tai"] = {
                },
                ["hu_tai_size"]      = 0,
                ["ifhu"]             = 0,
                ["ifpao"]            = 0,
                ["isDaHu"]           = 0,
                ["isOnline"]         = 1,
                ["isQingShui"]       = 0,
                ["m_chips"]          = 8960800,
                ["nick"]             = "柠檬我不萌",
                ["pCards"] = {
                },
                ["pCount"]           = 0,
                ["pgCount"]          = 0,
                ["piaoScore"]        = 0,
                ["portrait"]         = "http://thirdwx.qlogo.cn/mmopen/vi_32/LGPeydxkvPFaGficfnibM0a2llcdfxeP54Znq1q0lJgInYm4qo0rapibQGdE1se9ibJvhLURur9MTaAHQH0gtf2HVA/132",
                ["remainCards"] = {
                    [1]  = 4,
                    [2]  = 4,
                    [3]  = 6,
                    [4]  = 9,
                    [5]  = 9,
                    [6]  = 18,
                    [7]  = 18,
                    [8]  = 21,
                    [9]  = 22,
                    [10] = 23,
                    [11] = 25,
                    [12] = 37,
                    [13] = 40,
                },
                ["remainCardsCount"] = 13,
                ["seat_id"]          = 1,
                ["uid"]              = 2438164,
            },
            [3] = {
                ["agCards"] = {
                },
                ["agCount"]          = 0,
                ["bgCount"]          = 0,
                ["changeCoins"]      = -200,
                ["dgCount"]          = 0,
                ["gCards"] = {
                },
                ["gCount"]           = 0,
                ["hu_tai"] = {
                },
                ["hu_tai_size"]      = 0,
                ["ifhu"]             = 0,
                ["ifpao"]            = 0,
                ["isDaHu"]           = 0,
                ["isOnline"]         = 1,
                ["isQingShui"]       = 0,
                ["m_chips"]          = 8844600,
                ["nick"]             = "野狼",
                ["pCards"] = {
                },
                ["pCount"]           = 0,
                ["pgCount"]          = 0,
                ["piaoScore"]        = 0,
                ["portrait"]         = "http://thirdwx.qlogo.cn/mmopen/vi_32/gQee4LlTE2IDW99icFtiaoMSczxToeUDWIKXjm2MvNGhjhfvs4icPYeyQtbX2vv9jCe7G1fD59bbAibKmBessrbOaA/132",
                ["remainCards"] = {
                    [1]  = 1,
                    [2]  = 2,
                    [3]  = 5,
                    [4]  = 6,
                    [5]  = 9,
                    [6]  = 18,
                    [7]  = 20,
                    [8]  = 23,
                    [9]  = 33,
                    [10] = 33,
                    [11] = 34,
                    [12] = 35,
                    [13] = 40,
                },
                ["remainCardsCount"] = 13,
                ["seat_id"]          = 2,
                ["uid"]              = 2438163,
            },
            [4] = {
                ["agCards"] = {
                },
                ["agCount"]          = 0,
                ["bgCount"]          = 0,
                ["changeCoins"]      = -200,
                ["dgCount"]          = 0,
                ["gCards"] = {
                },
                ["gCount"]           = 0,
                ["hu_tai"] = {
                },
                ["hu_tai_size"]      = 0,
                ["ifhu"]             = 0,
                ["ifpao"]            = 0,
                ["isDaHu"]           = 0,
                ["isOnline"]         = 1,
                ["isQingShui"]       = 0,
                ["m_chips"]          = 8935379,
                ["nick"]             = "隐身守候",
                ["pCards"] = {
                    [1] = 35,
                },
                ["pCount"]           = 1,
                ["pgCount"]          = 0,
                ["piaoScore"]        = 0,
                ["portrait"]         = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJ24chnIbicnZmJuwuxC6j5icOu5jKgG15ktTrT6Nqckk21qmWUPnpfAuXz029Yp1BA41mS5hr2nLmQ/132",
                ["remainCards"] = {
                    [1]  = 5,
                    [2]  = 5,
                    [3]  = 6,
                    [4]  = 7,
                    [5]  = 8,
                    [6]  = 20,
                    [7]  = 22,
                    [8]  = 23,
                    [9]  = 24,
                    [10] = 65,
                },
                ["remainCardsCount"] = 10,
                ["seat_id"]          = 3,
                ["uid"]              = 1236691,
            },
        },
        ["time"]         = 1537,
        ["userCount"]    = 4,
    }
    local data = {
        ["cmd"]         = 20736,
        ["game_amount"] = 2,
        ["playercount"] = 2,
        ["playerlist"] = {
            [1] = {
                ["angang"]    = 0,
                ["chips"]     = 500,
                ["dianpao"]   = 0,
                ["jiepao"]    = 0,
                ["minggang"]  = 0,
                ["nick_name"] = "良缘",
                ["photo_url"] = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJmV9icZPicm0TEgpg1XHLOYvicAxmMhQCRvCWjJ0dykiasGP1JRdA7d0v7D2Rqw6d3QNYXedNtV6q42A/132",
                ["sex"]       = 1,
                ["uid"]       = 1236741,
                ["zhongma"]   = 4,
                ["zimo"]      = 1,
            },
            [2] = {
                ["angang"]    = 0,
                ["chips"]     = -500,
                ["dianpao"]   = 0,
                ["jiepao"]    = 0,
                ["minggang"]  = 0,
                ["nick_name"] = "柠檬我不萌",
                ["photo_url"] = "http://thirdwx.qlogo.cn/mmopen/vi_32/LGPeydxkvPFaGficfnibM0a2llcdfxeP54Znq1q0lJgInYm4qo0rapibQGdE1se9ibJvhLURur9MTaAHQH0gtf2HVA/132",
                ["sex"]       = 2,
                ["uid"]       = 2438164,
                ["zhongma"]   = 0,
                ["zimo"]      = 0,
            },
        },
    }
    self.ReceiveHandle = SCENENOW.scene.ReceiveHandle
    self.GameSceneView = SCENENOW.scene.GameSceneView
    
    -- self.ReceiveHandle:SVR_END(data)

end

function Test:KEY_F11()
    -- self.ReceiveHandle = self.gameScene.ReceiveHandle
    -- self.GameSceneView = self.gameScene.GameSceneView
    -- self.TableCardView = self.GameSceneView.TableCardView
    -- self.UserInfoViews = self.GameSceneView.UserInfoViews
    -- self.ReceiveHandle:SVR_GROUP_RANKING(data)
    self.gameScene = require("hz_majiang.gameScene").new( )
    self.gameScene:addTo(SCENENOW.scene):setName("test")
    self.GameSceneView = self.gameScene.GameSceneView
    self.TableCardView = self.GameSceneView.TableCardView
    self.UserInfoViews = self.GameSceneView.UserInfoViews
    local cards = {}
    table.insert(cards, 1)
    table.insert(cards, 1)
    table.insert(cards, 1)
    table.insert(cards, 1)
    table.insert(cards, 1)

    table.insert(cards, 1)
    table.insert(cards, 1)
    table.insert(cards, 1)

    table.insert(cards, 1)
    table.insert(cards, 1)
    table.insert(cards, 1)
    table.insert(cards, 1)
    table.insert(cards, 1)
    for k,UserInfoView in pairs(self.UserInfoViews) do
        UserInfoView.HandCardView:playOutCard()
        if k ~= g_308.viewId_my then
            UserInfoView.HandCardView:showCardsForAll(cards)
            -- UserInfoView.HandCardView:showCards(cards)
            UserInfoView.HandCardView:showNewCardForAll(1)

        end
        local peng = {}
        table.insert(peng, 1)
        table.insert(peng, 1)
        table.insert(peng, 1)
        UserInfoView.HandCardView:removeHandCardNodes(peng)
        UserInfoView.PAndGView:addPOrGCards(peng, 512)

        local peng = {}
        table.insert(peng, 1)
        table.insert(peng, 1)
        table.insert(peng, 1)
        table.insert(peng, 1)
        UserInfoView.HandCardView:removeHandCardNodes(peng)
        UserInfoView.HandCardView:removeHandCardNodes(peng)
        UserInfoView.PAndGView:addPOrGCards(peng, 512)
        UserInfoView.PAndGView:addPOrGCards(peng, 512)
    end
    local peng = {}
    table.insert(peng, 1)
    table.insert(peng, 1)
    table.insert(peng, 1)
    for k,UserInfoView in pairs(self.UserInfoViews) do
        -- UserInfoView.HandCardView:playOutCard()
        -- UserInfoView.HandCardView:removeHandCardNodes(peng)
        -- UserInfoView.PAndGView:addPOrGCards(peng, false, true)
        -- UserInfoView.PAndGView:addBuGangCard(1)
        if k == g_308.viewId_my or k == g_308.viewId_top then
            UserInfoView.OutCardView:playOutCard(1)
        end
    end
end

function Test:KEY_F7()
   
end

function Test:KEY_F12()
end

return Test