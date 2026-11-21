--[[
* author:   zwm
* date:     2020-05-29
--]]

local Card = require(TpackageName..".Card")
local SingleCell = class("SingleCell", function ( ... )
    return display.newNode()
end)

function SingleCell:ctor(data, isBigWin)
    local path = "xinyu510k/res/SingleCell.csb"
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
    cell:getChildByName("jScore"):setVisible(false)
    cell:getChildByName("rScore"):setString(info.bombchip or "0")
    cell:getChildByName("sScore"):setString(info.turnchip or "0")
    cell:getChildByName("tScore"):setString(info.bombchip + info.turnchip)
    local userInfo = DDZ_USERINFO_TABLE[info.uid]
    self:setUserInfo(cell, userInfo)
    if next(info.cards) then
        self:showHandlerCards(cell, info.cards)
    end
end

function SingleCell:showHandlerCards(obj, cards)
    if cards == nil or next(cards) == nil then return end
    for i,v in ipairs(cards) do
        local value, kind = Card:init(v)
        local sp = Card:getSmallCard(value, kind)
        if sp then
            sp:setPosition(cc.p(350+ 24*(i-1), 95))
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
    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(info.nickName, 4))

    local strHead = self:getUnformatPic(info.icon_url)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        local headImg = obj:getChildByName("headImg")
        headImg:setPositionX(89)
        headImg:loadTexture(imgFullPath)
        headImg:setContentSize(cc.size(71, 71))
    end
    -- body
end

return SingleCell