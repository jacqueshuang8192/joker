--[[
* author:   zwm
* date:     2019-04-08
* describe: 商城界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照ShopLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local GOODS = {
    {goodsId = 1, amount = 50, price = 50, path = "1.png"},
    {goodsId = 2, amount = 100, price = 100, path = "2.png"},
    {goodsId = 3, amount = 200, price = 200, path = "3.png"},
    {goodsId = 4, amount = 500, price = 500, path = "4.png"},
    {goodsId = 5, amount = 1000, price = 1000, path = "5.png"},
}
-- cc.FileUtils:getInstance():addSearchPath("hall/res")
-- cc.FileUtils:getInstance():addSearchPath("hall/res/shop")
-- cc.FileUtils:getInstance():addSearchPath("hall/res/shop/image")

local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local ShopLayer = class("ShopLayer", NewViewBaseLayer)

local EVENTNAME = {
	QUERY_GOODS_LIST = "/goods/queryGoodsList",
}

function ShopLayer:onExit()
    ReqMgr:delHandle("ShopLayer", EVENTNAME)
end

function ShopLayer:showShop()
    ReqMgr:addHandle("ShopLayer", EVENTNAME)
    local params = {}
    params["type"] = 1
    params["userId"] = USER_INFO.uid
    ReqMgr:request(EVENTNAME.QUERY_GOODS_LIST, params, handler(self, self.query_goods_list))
end

function ShopLayer:query_goods_list(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if returnCode == 0 then
        if not SCENENOW["scene"]:getChildByName("ShopLayer") then
            self.new(data.list):addTo(SCENENOW["scene"])
        end
    else
        viewMgr:showTip({text = error})
    end
end


function ShopLayer:ctor(data)
    -- display.addSpriteFrames("hall/res/shop/image/shop.plist","hall/res/shop/image/shop.png")
    local csbPath = "hall/res/shop/shopLayer.csb"
    ShopLayer.super.ctor(self, csbPath)
    self:enableMask(true)
    self:setName("ShopLayer")
    self.item:hide()
    self.goodsData = data or GOODS
    self:loadAllGoods(self.goodsData)
    self:setUserFXB()
end

function ShopLayer:loadAllGoods(datas)
    if datas == nil then return end
    local dataNum = #datas
    self.ScrollView:removeAllChildren()
    local interval_width = 25
    local interval_height = 20
    local interval = 3
    local itemSize = self.item:getSize()
    local panelSize = self.ScrollView:getContentSize()
    local scale = 1
    local itemHeight = itemSize.height * scale
    local itemWidth = itemSize.width * scale

    local height = math.ceil(dataNum / interval) * (itemSize.height + interval_height)
    if height < panelSize.height then
        height = panelSize.height
    end
    self.ScrollView:setInnerContainerSize(cc.size(panelSize.width, height))
    table.sort(datas, function(a, b)
        return a.amount < b.amount
    end)
    for index,data in ipairs(datas) do
        local item = self.item:clone():show()
        GameUtils.setNodeNameBindObj(item)
        local  y = math.ceil(index / interval)
        local indexY = height - (itemHeight + interval_height) * y + itemHeight/2
        if y > 1 then
            index = index % interval
            if index == 0 then
                index = interval
            end 
        end
        local x = (index-1) * (itemWidth + interval_width) + itemWidth/2
        item:setPosition(cc.p(x, indexY))

        self.ScrollView:addChild(item)
        local path = data.path or "4.png"
        item.number:setString(data.amount)
        item.btn.price:setString(data.price)
        item.goodsId = data.goodsId
        item.icon:loadTexture("hall/res/shop/"..path)
        item.btn:onClick(handler(self, self.onClickItem),true)
    end

end

function ShopLayer:onClickItem( event)
    local target = event.target
    local goodsId = target:getParent().goodsId
    local userId = USER_INFO.uid
    local payType = 1
    local table = {}
    table["userId"] = userId
    table["goodsId"] = goodsId
    table["amount"] = "1"
    table["payType"] = "Z"--支付宝
    -- table["payType"] = "W"--微信
    -- table["interfaceType"] = "J"

    local url = HttpAddr .. "/sfPay/rongZhouPayOrder".."?"

    for k,v in pairs(table) do
        url=url..k.."="..v.."&"
    end

    dump(url,"请求支付订单")

    cc.Application:getInstance():openURL(url)

    dump("goodsId = "..goodsId)
end

function ShopLayer:setUserFXB(sender, event)
    -- self.fxbCount:setString(require(NumberUtil_filePath):toWan(USER_INFO["gold"], 99999))
end

function ShopLayer:onClickBtnToProxy(sender, event)
    local data = {type = 1, title = "提示", content = self:getTipsContent()}
    require("hall.tips.CommonTips"):showTips(data)
end

function ShopLayer:getTipsContent()
    return "联系客服微信:123456789,成为代理"
end

function ShopLayer:onClickBtnClose(sender, event)
    self:removeSelf()
end

return ShopLayer