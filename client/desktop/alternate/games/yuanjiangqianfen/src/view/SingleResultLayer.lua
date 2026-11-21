--[[
* author:   zwm
* date:     2020-06-23
* describe: 沅江千分小结算界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local YJQFServer = import(TpackageName .. ".src.protocol.YJQFServer")
local ViewBaseLayer = require("hall.ViewBaseLayer")
local SingleResultLayer = class("SingleResultLayer", ViewBaseLayer)
local Card = require(TpackageName .. ".src.view.Card")

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124

function SingleResultLayer:ctor(data)
    SingleResultLayer.super.ctor(self, "yuanjiangqianfen/res/SingleResultLayer.csb")
    self._data = data
    --dump(data, "SingleResultLayer == ")
    self:__initUI()
    self:showResult(self._data)
end

function SingleResultLayer:__initUI()
    self.user1:setVisible(false)
    self.user2:setVisible(false)
    self.user3:setVisible(false)
end

function SingleResultLayer:showResult(data)
    if data == nil then return end
    dump(data, "showResult(data) == ")
    for i, v in ipairs(data) do
        self["user"..i] = require("hall.util.CocosUtil"):bindCocosObjToLua(self["user"..i], "yuanjiangqianfen.src.view.SingleCell", v)
        self["user"..i]:setVisible(true)
        if v.Cardcount > 0 then
            self:showSurCards(v.Cardbuf)
        end
    end
end

function SingleResultLayer:showSurCards(cards)
    local structCards = g_mainScene.playerInfoLayer:exchangeCardsValue(cards)
    Card:sortCard(structCards)
    for i,v in ipairs(structCards or {}) do
        local card = Card:getCard(v, 1)
        if not tolua.isnull(card) then
            card:setScale(0.27)
            card:setPosition(self:getPositionByIdx(i))
            self.surCardsNode:addChild(card)
        end
    end
end

function SingleResultLayer:getPositionByIdx(idx)
    local x = math.fmod(idx, 20)
    local y = math.floor(idx/20)
    return cc.p(22 + (x - 1) *44, 90 - y*60)
end

function SingleResultLayer:onClickBtnAgain(sender, event)
    self:removeSelf()
    if g_mainScene.allResultLayer then --表示收到大结算的数据
        g_mainScene.allResultLayer:showTotalResult()
    else
        YJQFServer:CLI_READY_GAME(1)
    end
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