local Test = class('Test')

function Test:debugTool()
    -- GamePlaneOperator:showTableLaizi(77)
    local Card = require(TpackageName .. '.PokerCard')
    local value = 76
    if not value then
        return
    end
    local card = NIUNIU_GAME_SCENE.laizi_vw:getChildByName('tableLaizi')
    local laizi_vw = NIUNIU_GAME_SCENE.laizi_vw
    local scale = 0.7
    if not card then
        card = Card.new()
        local _, csize = Card:getSingleCardBackPath()
        local size = laizi_vw:getContentSize()
        local x = (size.width / 2)
        local y = (size.height / 2 - csize.height * scale / 2)
        card:setScale(scale)
        card:addTo(laizi_vw)
        card:setPosition(x, y)
        card:setName('tableLaizi')
    end
    card:setCard(value)
    card:showBack()
    card:flipCard()
    laizi_vw:setScale(0.1)
    laizi_vw.shine:show()
    laizi_vw.shine_0:show()
    local scaleAction1 = cc.ScaleTo:create(0.1, 1.2)
    local scaleAction2 = cc.ScaleTo:create(0.05, 1)
    local CallFunc =
        cc.CallFunc:create(
        function()
            local CallFunc =
                cc.CallFunc:create(
                function()
                    laizi_vw.shine:setRotation(1)
                    laizi_vw.shine:hide()
                    laizi_vw.shine_0:hide()
                end
            )
            local rotateAc = cc.RotateBy:create(1, 360)
            local Repeat = cc.Repeat:create(rotateAc, 1)
            local Sequence = cc.Sequence:create(Repeat, CallFunc)
            laizi_vw.shine:runAction(Sequence)
        end
    )
    local Sequence = cc.Sequence:create(scaleAction1, scaleAction2, CallFunc)
    laizi_vw:runAction(Sequence)
    -- debugdata = {
    --     ["cmd"]             = 4176,
    --     ["gameResult"] = {
    --         [1] = {
    --             ["cardType"]   = 7,
    --             ["card_mount"] = 5,
    --             ["cards"] = {
    --                 [1] = 39,
    --                 [2] = 17,
    --                 [3] = 2,
    --                 [4] = 6,
    --                 [5] = 12,
    --             },
    --             ["changeChip"] = 2000,
    --             ["grab"]       = 0,
    --             ["isZhuang"]   = 1,
    --             ["nickName"]   = "测试0号",
    --             ["smallPhoto"] = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
    --             ["times"]      = 0,
    --             ["uid"]        = 10059,
    --         },
    --         [2] = {
    --             ["cardType"]   = 1,
    --             ["card_mount"] = 5,
    --             ["cards"] = {
    --                 [1] = 4,
    --                 [2] = 7,
    --                 [3] = 20,
    --                 [4] = 8,
    --                 [5] = 1,
    --             },
    --             ["changeChip"] = -2000,
    --             ["grab"]       = 2,
    --             ["isZhuang"]   = 0,
    --             ["nickName"]   = "测试1号",
    --             ["smallPhoto"] = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
    --             ["times"]      = 2,
    --             ["uid"]        = 10060,
    --         },
    --     },
    --     ["gameResultCount"] = 2,
    --     ["resultCount"]     = 1,
    --     ["resultIndex"]     = 1,
    -- }

    -- local Card = require(TpackageName .. ".PokerCard")
    -- for i,userInfo in ipairs(debugdata.gameResult) do
    --     for idx,value in ipairs(userInfo.cards) do
    --         local cardNode = Card.new()
    --         cardNode:setCard(value)
    --         cardNode:showFront()
    --         debugdata.gameResult[i].cards[idx] = cardNode
    --     end
    --     local cardKind_imgPath = CARDTYPE_IMAGE_PATH[userInfo.cardType]
    --     debugdata.gameResult[i].cardType = cardKind_imgPath
    --     debugdata.gameResult[i].cardType_plist = 1 --1是plist 0不是
    -- end
    -- local CardsRoundRecord = require("hall.common.CardsRoundRecord").new(debugdata)
    -- CardsRoundRecord:setHandler(handler(NiuNiuSendHandle, NiuNiuSendHandle.CLI_COMMAND_GAMERESULT_RECORD))
    -- CardsRoundRecord:addTo(SCENENOW["scene"]._scene,99999)
    -- CardsRoundRecord:setName("niuniu_zhuang_1")
end

function Test:KEY_F7()
    GamePlaneOperator:showTableLaizi(77)
end

function Test:KEY_F11()
    GamePlaneOperator:showTableLaizi(77)
end

function Test:KEY_F12()
    GamePlaneOperator:showTableLaizi(77)
end
return Test
