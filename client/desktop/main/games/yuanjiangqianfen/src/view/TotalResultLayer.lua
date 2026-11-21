--[[
* author:   zwm
* date:     2020-06-23
* describe: 沅江千分大结算界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]


local ViewBaseLayer = require("hall.ViewBaseLayer")
local TotalResultLayer = class("TotalResultLayer", ViewBaseLayer)

local CELL_POS_X = 35
local CELL_POS_Y_BEGIN = 493
local CELL_POS_Y_INTERVAL = 124

function TotalResultLayer:ctor(data)
    TotalResultLayer.super.ctor(self, "yuanjiangqianfen/res/TotalResultLayer.csb")
    self._data = data
    self:__initUI()
    self:showResult(self._data)
end

function TotalResultLayer:__initUI()    
    -- self.cell1:setVisible(false)
    -- self.cell2:setVisible(false)
    -- self.cell3:setVisible(false)
    -- self.cell4:setVisible(false)
end

function TotalResultLayer:showTotalResult()
    self:setVisible(true)
    g_mainScene.allResultLayer = nil
end

function TotalResultLayer:showResult(data)
    print("TotalResultLayer:showResult ------------------")
    if data == nil then return end
    --dump(data, "TotalResultLayer:showResult(data) == ")
    local bigWinUid = self:getBigWinUid()
    for i, v in ipairs(data.playerlist or {}) do
        local item = require("yuanjiangqianfen.src.view.TotalCell").new(v, bigWinUid)
        item:setVisible(true)
        item:setPosition(cc.p(200 + (i-1)*310, 150))
        self.content:addChild(item)
        -- self:initItem(item, v, v.uid == bigWinUid)
    end
end

function TotalResultLayer:getBigWinUid()
    local uid = nil
    local maxSocre = 0
    for i, v in ipairs(self._data or {}) do
        if v.finalScore > maxSocre then
            maxSocre = v.finalScore
            uid = v.uid
        end
    end
    
    return uid
end

function TotalResultLayer:onClickBtnToHall(sender, event)
    require("hall.tips.CommonTips"):_gameToHall()
end

function TotalResultLayer:onClickBtnShare(sender, event)
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

function TotalResultLayer:onExit()
    -- body
end

return TotalResultLayer