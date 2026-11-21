local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local ZouShiView = class("ZouShiView", NewViewBaseLayer)
local Server = require("shenshou100.src.handle.Server")
function ZouShiView:ctor()
    ZouShiView.super.ctor(self, "shenshou100/res/View/ZouShiView.csb", false)
    self:enableMask(true)
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
    self:initEvent()
    self:setData()
end

function ZouShiView:initUI()
    self.btnClose = self._csbNode.root.bg.btnClose
    self.item = self._csbNode.root.item:hide()
    self.ListView = self._csbNode.root.ListView

    self.ListView:setScrollBarEnabled(false)
    self.ListView:removeAllItems()
end

function ZouShiView:initEvent()
    self.btnClose:onClick(handler(self, self.onClickClose), true)
end

function ZouShiView:onClickClose(event)
    self:removeSelf()
end


function ZouShiView:setData()
    local datas = g_102.recordData
    while #datas > 50 do
        table.remove(datas,1)
    end
    for i,data in ipairs(datas) do
        local item = self.item:clone():show()
        GameUtils.setNodeNameBindObj(item)
        item.img_new:hide()
        if i == #datas then
            item.img_new:show()
        end
        for i,v in ipairs(data) do
            local node = item[tostring(i)]
            local path = "shenshou100/res/View/fu.png"
            if v == 1 then
                path = "shenshou100/res/View/sheng.png"
            end
            node:loadTexture(path)
        end
        self.ListView:pushBackCustomItem(item)
    end
    self.ListView:jumpToRight()
end

function ZouShiView:onExit()

end

return ZouShiView
