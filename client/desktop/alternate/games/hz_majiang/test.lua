
local Test = class("Test")

function Test:debugTool()
    local data = {
        ["bankerId"]     = 10059,
        ["birdCards"] = {
            [1] = {
                ["card"]      = 18,
                ["isZhongMa"] = 1,
            },
        },
        ["birdCount"]    = 1,
        ["cmd"]          = 24584,
        ["maScore"]      = 2,
        ["nRoundResult"] = 1,
        ["players"] = {
            [1] = {
                ["agCards"] = {
                },
                ["agCount"]          = 0,
                ["bgCount"]          = 0,
                ["changeCoins"]      = 1400,
                ["dgCount"]          = 0,
                ["gCards"] = {
                },
                ["gCount"]           = 0,
                ["hu_tai"] = {
                    [1] = {
                        ["byTaiCount"] = 2,
                        ["byType"]     = 1,
                    },
                },
                ["hu_tai_size"]      = 1,
                ["hucontent"] = {
                    [1] = {
                        ["hutype"] = 2,
                        ["zimo"] = {
                            [1] = {
                                ["huCard"]         = 8,
                                ["ifgangshanghua"] = 0,
                            },
                        },
                    },
                },
                ["ifhu"]             = 1,
                ["ifpao"]            = 0,
                ["isDaHu"]           = 0,
                ["isOnline"]         = 1,
                ["isQingShui"]       = 1,
                ["m_chips"]          = 1035600,
                ["nick"]             = "测试0号",
                ["pCards"] = {
                },
                ["pCount"]           = 0,
                ["pgCount"]          = 0,
                ["piaoScore"]        = 0,
                ["portrait"]         = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
                ["remainCards"] = {
                    [1]  = 2,
                    [2]  = 2,
                    [3]  = 4,
                    [4]  = 4,
                    [5]  = 5,
                    [6]  = 5,
                    [7]  = 6,
                    [8]  = 6,
                    [9]  = 8,
                    [10] = 8,
                    [11] = 19,
                    [12] = 19,
                    [13] = 40,
                    [14] = 40,
                },
                ["remainCardsCount"] = 14,
                ["seat_id"]          = 0,
                ["uid"]              = 10059,
            },
            [2] = {
                ["agCards"] = {
                    [1] = 3,
                },
                ["agCount"]          = 1,
                ["bgCount"]          = 0,
                ["changeCoins"]      = -1400,
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
                ["m_chips"]          = 1399317,
                ["nick"]             = "测试1号",
                ["pCards"] = {
                },
                ["pCount"]           = 0,
                ["pgCount"]          = 0,
                ["piaoScore"]        = 0,
                ["portrait"]         = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
                ["remainCards"] = {
                    [1]  = 7,
                    [2]  = 8,
                    [3]  = 34,
                    [4]  = 36,
                    [5]  = 37,
                    [6]  = 38,
                    [7]  = 39,
                    [8]  = 41,
                    [9]  = 65,
                    [10] = 65,
                },
                ["remainCardsCount"] = 10,
                ["seat_id"]          = 1,
                ["uid"]              = 10060,
            },
        },
        ["time"]         = 50,
        ["userCount"]    = 2,
    }
    self.ReceiveHandle = SCENENOW.scene.ReceiveHandle
    self.GameSceneView = SCENENOW.scene.GameSceneView
    
    self.ReceiveHandle:SVR_END(data)

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