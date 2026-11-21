--[[
* author:   zwm
* date:     2020-05-29
--]]

local Card = require(TpackageName..".Card")
local SingleCell = class("SingleCell", function ( ... )
    return display.newNode()
end)

function SingleCell:ctor(data, isBigWin)
    local path = "qs510k/res/SingleCell.csb"
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

    dump(data," ============= 【小结算】 ============ ")
    self:initItem(self.node, data, isBigWin)
end

function SingleCell:initItem(obj, info)
    local cell = obj:getChildByName("cell")
    cell:getChildByName("zdScore"):setString(info.bombchip or "0")
    cell:getChildByName("510kScore"):setString(info.k510chip or "0")
    cell:getChildByName("nowScore"):setString(info.bombchip + info.k510chip)
    cell:getChildByName("allScore"):setString(info.totalchip or "0")
    cell:getChildByName("rankScore"):setString(info.turnchip or "0")
    cell:getChildByName("win"):setTexture("qs510k/newImages/win_" .. info.rank ..".png")

    local userInfo = DDZ_USERINFO_TABLE[info.uid]
    self:setUserInfo(cell, userInfo)
    if next(info.cards) then
        self:showHandlerCards(cell, info.cards)
    end
end

function SingleCell:showHandlerCards(obj, cards)
    local cardsTemp = {}
    if cards == nil or next(cards) == nil then return end

    for i,v in ipairs(cards) do
        local value, kind = Card:init(v)
        table.insert(cardsTemp,{value,kind})
    end
    table.sort(cardsTemp,function(a,b) return a[1] > b[1] end )
    for i,v in ipairs(cardsTemp) do
        local sp = Card:getSmallCard(v[1], v[2])
        if sp then
            sp:setPosition(cc.p(150 + 24*(i-1), 55))
            obj:addChild(sp)
        end
    end
end

function SingleCell:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    strUrl = string.sub(strUrl,nPos+1,string.len(strUrl))
    nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    return strPic..".jpg"
end

function SingleCell:setUserInfo(obj, info)
    obj:getChildByName("name"):setPositionX(80)
    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(info.nick, 4))

    local strHead = self:getUnformatPic(info.icon_url)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        local headImg = obj:getChildByName("headImg")
        headImg:setPositionX(80)
        headImg:loadTexture(imgFullPath)
        headImg:setContentSize(cc.size(71, 71))
    end

    --暗夜模式
    if GAME_MODE == 1 then
        obj:getChildByName("headImg"):setVisible(false)
        obj:getChildByName("headBg"):setVisible(true)
        obj:getChildByName("headBg"):setPositionX(80)
        obj:getChildByName("headBg"):setTexture("qs510k/images/headimg_02.png")
        obj:getChildByName("name"):setString("黑衣人")
    end
    -- body
end

return SingleCell