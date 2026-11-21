local ViewBaseLayer = require("hall.ViewBaseLayer")
local SingleResultLayer = class("SingleResultLayer", ViewBaseLayer)
local ControlPlaneOperator = require("TaiHeGuoZha.operator.ControlPlaneOperator")
local CardPlaneOperator = require("TaiHeGuoZha.operator.CardPlaneOperator")
local Card = require(TpackageName .. ".Card")

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124

function SingleResultLayer:ctor(data)
    -- for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        -- if k == "escrow_time" then
        --     if v == 5 then
    SingleResultLayer.super.ctor(self, "TaiHeGuoZha/res/SingleResultLayer.csb")
    self._data = data
    self:__initUI()
    self:showResult(self._data)
            -- elseif v == 0 then
                -- SingleResultLayer.super.ctor(self, "TaiHeGuoZha/res/SingleResultLayer.csb")
                -- self._data = data
                -- self:__initUI()
                -- self:showResult(self._data)
                -- self:performWithDelay(
                --     function(sender, event)
                --         CardPlaneOperator:clearGameDatas()
                --         ControlPlaneOperator:showControlButtons(1, false)
                --         self:removeSelf()
                --     end,
                --     3.5
                -- )
            -- end
        -- end
    -- end
end

function SingleResultLayer:__initUI()
    self.rankFlag:setVisible(true)
    self.jianfenTitle:setVisible(true)
    self.light1:setVisible(false)
    self.light2:setVisible(false)
    self.light3:setVisible(false)
    self.light4:setVisible(false)
    txt_jianfen:setVisible(false)
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "maxSeatCount" then
            if v == 2 then
                self.rank_0_0:setVisible(true)
                self.rank_0_1:setVisible(false)
                self.rank_0_2:setVisible(false)
                self.rank_0_3:setVisible(false)
                self.rank_0_4:setVisible(true)
            else
                self.rank_0_0:setVisible(true)
                self.rank_0_1:setVisible(true)
                self.rank_0_2:setVisible(true)
                self.rank_0_3:setVisible(true)
                self.rank_0_4:setVisible(false)
            end
        end
    end
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "escrow_time" then
            if v == 5 then
                self.btnAgain:setVisible(true)
            elseif v == 0 then
                self.btnAgain:setVisible(false)
            end
        end
    end
end

function SingleResultLayer:showResult(data)
    if data == nil then
        return
    end
    --(data, "showResult(data)  ========  ")
    for i, v in ipairs(data) do
        local item = require("TaiHeGuoZha.SingleCell").new(v)
        local rank = v["rank"]
        item:setVisible(true)
        --(rank, "PlayerRankID  ========  ")
        item:setPosition(cc.p(35, 496 - (rank) * 124))
        self.content:addChild(item)
    end
end

function SingleResultLayer:initItem(obj, info)
    local cell = obj:getChildByName("cell")
    cell:getChildByName("jScore"):setString(info.JSFen or "0")
    cell:getChildByName("rScore"):setString(info.JSJiang or "0")
    cell:getChildByName("sScore"):setString(info.correctFen or "0")
    cell:getChildByName("tScore"):setString(info.AllFen)
    self:setUserInfo(cell, info)
    if next(info.scards) then
        self:showHandlerCards(cell, info.scards)
    end
end

function SingleResultLayer:showHandlerCards(obj, cards)
    if cards == nil or next(cards) == nil then
        return
    end

    for i, v in ipairs(cards) do
        local value, kind = Card:init(v)
        local sp = Card:getSmallCard(value, kind)
        if sp then
            sp:setPosition(cc.p(350 + 24 * (i - 1), 95))
            obj:addChild(sp)
        end
    end
end

function SingleResultLayer:getUnformatPic(url)
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

function SingleResultLayer:setUserInfo(obj, info)
    local userInfo = nil
    if USER_INFO["uid"] == info.uid then
        userInfo = USER_INFO
    else
        userInfo = THGZ_USERINFO_TABLE[info.uid]
    end
    if userInfo == nil then
        return
    end

    obj:getChildByName("name"):setString(require("hall.GameCommon"):formatNick(userInfo.nick, 4))

    local strHead = self:getUnformatPic(userInfo.icon_url)
    local imgFullPath = device.writablePath .. strHead
    local fileexists = require("hall.tool.utils.fs").exists(imgFullPath)
    if fileexists then
        obj:getChildByName("headImg"):loadTexture(imgFullPath, 0)
    end
end

function SingleResultLayer:onClickBtnAgain(sender, event)
    CardPlaneOperator:clearGameDatas()
    ControlPlaneOperator:showControlButtons(1, true)
    self:removeSelf()
end

function SingleResultLayer:onClickBtnShare(sender, event)
    local paras = {}
    paras["showType"] = 2
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
end

return SingleResultLayer
