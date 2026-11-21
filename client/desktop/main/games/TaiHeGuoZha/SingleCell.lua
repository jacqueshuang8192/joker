--[[
* author:   zwm
* date:     2020-05-29
--]]
local Card = require(TpackageName .. ".Card")
local SingleCell =
    class(
    "TotalCell",
    function(...)
        return display.newNode()
    end
)

function SingleCell:ctor(data, isBigWin)
    local path = "TaiHeGuoZha/res/SingleCell.csb"
    local node = nil
    if device.platform == "ios" then
        if isiOSVerify then
            node = cc.CSLoader:createNode(path):addTo(self)
        else
            node = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. path):addTo(self)
        end
    else
        node = cc.CSLoader:createNode(path):addTo(self)
    end
    self.node = node
    self:initItem(self.node, data, isBigWin)
end

function SingleCell:initItem(obj, info)
    local cell = obj:getChildByName("cell")
    cell:getChildByName("jScore"):setString(info.JSFen or "0")
    cell:getChildByName("rScore"):setString(info.JSJiang or "0")
    cell:getChildByName("sScore"):setString(info.correctFen or "0")
    cell:getChildByName("tScore"):setString(info.AllFen / 100)
    local userInfo = THGZ_USERINFO_TABLE[info.uid]
    self:setUserInfo(cell, userInfo)
    if next(info.scards) then
        self:showHandlerCards(cell, info.scards)
    end
    if next(info.jiangpaiinfo) then
        self:showJiangCards(cell, info.jiangpaiinfo)
    end
end

function SingleCell:showHandlerCards(obj, cards)
    if cards == nil or next(cards) == nil then
        return
    end

    for i, v in ipairs(cards) do
        local c = Card.new()
        local value, kind = c:init(v)
        local sp = Card:getSmallCard(value, kind)
        if sp then
            sp:setPosition(cc.p(350 + 24 * (i - 1), 95))
            obj:addChild(sp)
        end
    end
end

function SingleCell:showJiangCards(obj, jiangpaiinfo)
    if jiangpaiinfo == nil or next(jiangpaiinfo) == nil then
        return
    end

    for i, v in ipairs(jiangpaiinfo) do
        -- for a, b in ipairs(jiangpaiinfo[i]) do
        local c = Card.new()
        local value, kind = c:init(v["cards"])
        if v["cards"] == 14 then
            value = 14
            kind = 4
        end
        local cardtype = v["cardtype"]
        -- local value, cardtype = c:init(v)
        local sp = Card:getSmallCard(value, kind)

        if sp then
            sp:setPosition(cc.p(350 + 50 * (i - 1), 30))
            obj:addChild(sp)
            local psLogoc = cc.CSLoader:createNode("TaiHeGuoZha/res/Node.csb")
            local nbbg = psLogoc:getChildByName("nbbg")
            local paishu_txtc = psLogoc:getChildByName("paishu_txt")
            paishu_txtc:setString(cardtype)
            if psLogoc then
                psLogoc:setScale(0.5)
                local cardSize = sp:getContentSize()
                local y = cardSize.height / 5
                local nbbgSize = psLogoc:getContentSize()
                psLogoc:setPosition(cc.p(14, y))
                sp:addChild(psLogoc)
            end
        end
        -- end
    end
end

function SingleCell:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl, "/")
    if nPos == nil then
        return nil
    end
    strUrl = string.sub(strUrl, nPos + 1, string.len(strUrl))
    nPos = string.find(strUrl, "/")
    if nPos == nil then
        return nil
    end
    local strPic = string.sub(strUrl, 1, nPos - 1)
    strPic = string.reverse(strPic)
    return strPic .. ".jpg"
end

function SingleCell:setUserInfo(obj, info)
    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(info.nickName, 4))
    local headImg = obj:getChildByName("headImg")
    local size = headImg:getContentSize()
    require("hall.GameCommon"):getUserHead(info.icon_url, nil, nil, headImg, size.width, false, nil, false)
end

return SingleCell
