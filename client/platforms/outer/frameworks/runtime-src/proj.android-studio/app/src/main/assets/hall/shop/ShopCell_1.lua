--[[
* author:   zwm
* date:     2019-04-08
* describe: 商城cell界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local BASE_PATH = "hall/res/shop/image/"
local MAX_SIZE  = 4

local ViewBaseLayer = require("hall.ViewBaseLayer")
local ShopCell = class("ShopCell", ViewBaseLayer)

function ShopCell:ctor(data)
    local csbPath = "hall/res/shop/shopCell.csb"
    ShopCell.super.ctor(self, csbPath)
    self.goodsData = data or {}
    self:initShopCell(self.goodsData)
end

function ShopCell:initShopCell(goodsData)
    for i = 1, MAX_SIZE do
        if goodsData[i] then
            local v = goodsData[i]
            self["count"..i]:setString(v.value)
            self["bottonName"..i]:setString(v.cost)
            require("hall.util.CocosUtil"):toReplaceSprImg(self["flagImg"..i], BASE_PATH..v.path)
            self["btnBuy"..i]:setTouchEnabled(true)
            self["btnBuy"..i]:setSwallowTouches(false)
        else
            self["btnBuy"..i]:setVisible(false)
        end
    end
end

function ShopCell:onClickBtnBuy1(sender, event)
    
end

function ShopCell:onClickBtnBuy2(sender, event)
    
end

function ShopCell:onClickBtnBuy3(sender, event)
    
end

function ShopCell:onClickBtnBuy4(sender, event)
    
end

function ShopCell:onClickBtnClose(sender, event)
    self:removeSelf()
end

return ShopCell