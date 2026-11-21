--add by zzy 2019-6-27
local ViewBaseLayer = require("hall.ViewBaseLayer")
local RecordXQCell = class("RecordXQCell", ViewBaseLayer)

function RecordXQCell:ctor(data)
    local csbPath = "hall/res/record/RecordXQCell.csb"
    RecordXQCell.super.ctor(self, csbPath)

    print("=====RecordXQCell==ctor====")
    print("=====RecordXQCell==ctor====")
    print("=====RecordXQCell==ctor====")

    self.data = data
    
    self:initUIInfo()
    
end

function RecordXQCell:initUIInfo()
   self.recordCellBg:setSwallowTouches(true)
   self.ListView:setSwallowTouches(true)

   --test
   self:refreshMatchInfo(nil)
end

function RecordXQCell:refreshMatchInfo(data)
    --test
    data = {1}

    self.ListView:removeAllChildren()
    if not data then return end
    print("====2222222====")
    for k,v in pairs(data) do
        local tempCell = self.cell1:clone()
        -- if not tempCell then return end
        self:initCellUI(tempCell,v)
        local groupLY = ccui.Layout:create()
        groupLY:setAnchorPoint(cc.p(0,1))
        groupLY:setTouchEnabled(false)
        groupLY:setContentSize(cc.size(300, 70))
        groupLY:addChild(tempCell)
        self.ListView:pushBackCustomItem(groupLY)
    end
end

function RecordXQCell:initCellUI(layout , data )
    print("====RecordXQCell=initCellUI==2222===")
    -- if  not data then return end
    print("====RecordXQCell=initCellUI==2222===")
    layout:setVisible(true)

    -- local time = string.split(os.date("%Y-%m-%d %H:%M:%S", os.time() - 1*24*3600), " ")
    -- dump(time,"===time===")

end 

return RecordXQCell