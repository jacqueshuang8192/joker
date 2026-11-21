--[[
* author:   zwm
* date:     2020-05-28
* describe: 510k小结算界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local ViewBaseLayer = require("hall.ViewBaseLayer")
local SingleResultLayer = class("SingleResultLayer", ViewBaseLayer)
local ControlPlaneOperator = require("qs510k.operator.ControlPlaneOperator")
local CardPlaneOperator = require("qs510k.operator.CardPlaneOperator")
local Card = require(TpackageName..".Card")

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124

function SingleResultLayer:ctor(data)
    SingleResultLayer.super.ctor(self, "qs510k/res/SingleResultLayer.csb")
    self._data = data
    --dump(data, "SingleResultLayer == ")
    dump(data, " ================ 【 小结算数据 】 =================== ")
    self:__initUI()
    self:showResult(self._data)
end

function SingleResultLayer:__initUI()
    
    self.lightall = {self.light1,self.light2,self.light3,self.light4}
    for i=1,4 do
        self.lightall[i]:setVisible(false)
    end
    dump(USER_INFO, " ============= 【 USER_INFO 】 =============== ")
    for i,v in ipairs(self._data) do
        if tonumber(USER_INFO.uid) == tonumber(v.uid) then
            self.rankFlag:setVisible(true)
            self.rankFlag:setTexture("qs510k/images/single/rank_" .. v.rank ..".png")
        end
    end
    -- self["light"..USER_INFO["seat_id"]]:setVisible(true)
end

function SingleResultLayer:showResult(data)
    if data == nil then return end
    table.sort(data,function(a,b) return a.rank < b.rank end )
    for i, v in ipairs(data) do
        self.lightall[i]:setVisible(true)
        local item = require("qs510k.SingleCell").new(v)
        item:setVisible(true)
        item:setPosition(cc.p(35, 494- (i-1)*124))
        -- self:initItem(item, v)
        self.content:addChild(item)
    end
end

function SingleResultLayer:initItem(obj, info)
    local cell = obj:getChildByName("cell")
    cell:getChildByName("jScore"):setVisible(false)
    cell:getChildByName("rScore"):setString(info.bombchip or "0")
    cell:getChildByName("sScore"):setString(info.turnchip or "0")
    cell:getChildByName("tScore"):setString(info.bombchip + info.turnchip)
    self:setUserInfo(cell, info)
    if next(info.cards) then
        self:showHandlerCards(cell, info.cards)
    end
end

function SingleResultLayer:showHandlerCards(obj, cards)
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

function SingleResultLayer:getUnformatPic(url)
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

function SingleResultLayer:setUserInfo(obj, info)
    local userInfo = nil
    if USER_INFO["uid"] == info.uid then
        userInfo = USER_INFO
    else
        userInfo = DDZ_USERINFO_TABLE[info.uid]
    end
    if userInfo == nil then return end

    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(userInfo.nick, 4))

    local strHead = self:getUnformatPic(userInfo.icon_url)
    local imgFullPath = device.writablePath..strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        obj:getChildByName("headImg"):loadTexture(imgFullPath, 0)
    end
    -- body
end

function SingleResultLayer:onClickBtnAgain(sender, event)
    self:removeSelf()
	CardPlaneOperator:clearGameDatas()
	ControlPlaneOperator:showControlButtons(1,true)
end

function SingleResultLayer:onClickBtnShare(sender, event)
    local paras = {}
    paras["showType"] = 2;
    paras["desc"] = " "
    paras["imagePath"] = "screen"
    paras["name"] = "分享结果"
    paras["url"] = appDownLoadAddress
    local ShareLayer = require("hall.share.ShareLayer").new(paras)
    if ShareLayer then
        ShareLayer:onClickBtnToFriend()
        ShareLayer:removeSelf()
    end
end

function SingleResultLayer:onExit()
    -- body
end

return SingleResultLayer