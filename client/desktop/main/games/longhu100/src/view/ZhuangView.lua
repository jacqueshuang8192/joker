local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local ZhuangView = class("ZhuangView", NewViewBaseLayer)
local Server = require("longhu100.src.handle.Server")
function ZhuangView:ctor()
    ZhuangView.super.ctor(self, "longhu100/res/View/ZhuangView.csb", false)
    self:enableMask(true)
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
    self:initEvent()
    self:setData()
end

function ZhuangView:initUI()
    self.btnClose = self._csbNode.root.bg.btnClose
    self.btnQx = self._csbNode.root.btnQx:hide()
    self.btnXz = self._csbNode.root.btnXz:hide()
    self.btnSz = self._csbNode.root.btnSz:hide()
    self.item = self._csbNode.root.item:hide()
    self.ListView_z = self._csbNode.root.ListView_z
    self.ListView_s = self._csbNode.root.ListView_s
    self.ListView_z:setScrollBarEnabled(false)
    self.ListView_s:setScrollBarEnabled(false)
    self.ListView_z:removeAllItems()
    self.ListView_s:removeAllItems()
    local userInfo = g_101.userInfos(USER_INFO.uid)
    if userInfo.isBanker == 1 then
        self.btnXz:show()
    elseif userInfo.isBanker == 2 then
        self.btnQx:show()
    else
        self.btnSz:show()
    end

    self._csbNode.root.bg.Image_94.txt1:setString(string.format("上庄需要%d", g_101.gameConfig.applyBankerScore))
    self._csbNode.root.bg.Image_94.txt2:setString(string.format("最长连庄%d局", g_101.gameConfig.bankTimes))
end

function ZhuangView:initEvent()
    self.btnClose:onClick(handler(self, self.onClickClose), true)
    self.btnQx:onClick(handler(self, self.onClickQx), true)
    self.btnXz:onClick(handler(self, self.onClickXz), true)
    self.btnSz:onClick(handler(self, self.onClickSz), true)
end

function ZhuangView:onClickClose(event)
    self:removeSelf()
end
function ZhuangView:onClickQx(event)
    Server:CLIENT_COMMAND_USER_CANCEL_APPLY()
    self:removeSelf()
end
function ZhuangView:onClickXz(event)

    Server:CLIENT_COMMAND_USER_DOWN_BANKER()
    self:removeSelf()
end
function ZhuangView:onClickSz(event)
    Server:CLIENT_COMMAND_USER_APPLY_BANKER()
    self:removeSelf()
end

function ZhuangView:setData()
    local zhuangUsers = g_101.getZhuangUsers(1)
    local allChips = 0
    for i,v in ipairs(zhuangUsers) do
        allChips = allChips + v.chips
    end
    for i,v in ipairs(zhuangUsers) do
        local item = self.item:clone():show()
        GameUtils.setNodeNameBindObj(item)
        self.ListView_z:pushBackCustomItem(item)
        require("hall.GameCommon"):getUserHead(v.portrait, nil, nil, item.head, item.head:getWidth(), false, nil, true, nil, nil)
        local nickName = require("hall.GameCommon"):formatNick(v.nickName, 3)
        item.txt_name:setString(nickName)
        item.txt_chip:setString(v.chips / 100)
        local perc = string.format("%0.2f%%",v.chips / allChips * 100)
        item.txt_penl:setString(perc)
    end

	local zhuangUsers2 = g_101.getZhuangUsers(2)
    for i,v in ipairs(zhuangUsers2) do
        local item = self.item:clone():show()
        GameUtils.setNodeNameBindObj(item)
        self.ListView_s:pushBackCustomItem(item)
        require("hall.GameCommon"):getUserHead(v.portrait, nil, nil, item.head, item.head:getWidth(), false, nil, true, nil, nil)
        local nickName = require("hall.GameCommon"):formatNick(v.nickName, 3)
        item.txt_name:setString(nickName)
        item.txt_chip:setString(v.chips / 100)
        item.txt_penl:setString("")
    end

end

function ZhuangView:onExit()

end

return ZhuangView
