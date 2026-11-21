local CardMgr = class("CardMgr")
local PokerCard = require("zhajinhua_jb.src.PokerCard")
local SoundUtils = require("zhajinhua_jb.src.SoundUtils")

function CardMgr:ctor(GameSceneView)
    self.GameSceneView = GameSceneView
end

function CardMgr:sendCard()
    local viewIds = {}
    for seat_id, viewId in pairs(g_317.viewIds) do
        table.insert(viewIds, viewId)
    end
    table.sort(viewIds)
    local time = 0
    local time1 = 0.1
    local cardCount = 3
	for idx = 1, cardCount do
        for _, viewId in ipairs(viewIds) do
            SoundUtils:playEffect("send_card")
            local UserInfoView = self.GameSceneView:getPlayerBySeatId( nil, viewId )
            local inhand_vw = UserInfoView.inhand_vw

            local getCardSize = PokerCard:getCardSize()
            local cardHeight = getCardSize.height
            local cardWidth = getCardSize.width
            local getWinSize = cc.Director:getInstance():getWinSize()
            local inhandSize = inhand_vw:getContentSize()
            local card = PokerCard.new()
            card:setScale(0.5)
            card:addTo(inhand_vw)
            card:showBack()
            card:setPosition(inhand_vw:convertToNodeSpace(cc.p(getWinSize.width / 2, getWinSize.height / 2)))
            card:setName("card"..idx)

            local scale = inhandSize.height / cardHeight
            cardWidth = cardWidth * scale
            local oriX = cardWidth / 2 
            local oriY = inhandSize.height / 2
            local intervalW = (inhandSize.width - cardWidth) / (cardCount - 1)
            local x = oriX + intervalW * (idx - 1)
            local Spawn = cc.Spawn:create(
                cc.ScaleTo:create(time1, scale), 
                cc.MoveTo:create(time1, cc.p(x, oriY))
            )
            printW(x, oriY, time,"=-================")
            local DelayTime = cc.DelayTime:create(time)
            local Sequence = cc.Sequence:create(DelayTime, Spawn)
            card:runAction(Sequence)
            time = time + 0.1
        end
    end
    return time + time1
end

function CardMgr:getClientCard( poker )
    local color_1 = bit.band(poker, 0xf0)
    local color = 1
    if color_1 == 0x00 then--方块 红 大字
        color = 2
    elseif color_1 == 0x10 then--梅花 黑 小字
        color = 1
    elseif color_1 == 0x20 then--红桃 红 大字
        color = 2
    elseif color_1 == 0x30 then--黑桃 黑 小字
        color = 1
    end
    local card = poker % 16
    return card, color
end

function CardMgr:sortOrder(cards)
    table.sort(cards, function(a, b)
        local acard, acolor = self:getClientCard(a)
        local bcard, bcolor = self:getClientCard(b)
        if acard == bcard then
            return acolor > bcolor
        else
            return acard > bcard
        end
    end)
end

return CardMgr
