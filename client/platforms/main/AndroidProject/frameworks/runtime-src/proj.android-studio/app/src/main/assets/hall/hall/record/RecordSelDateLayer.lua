--[[
* author:   zwm
* date:     2019-03-25
* describe: 总战绩里选择日期界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local MAX_DATE = 15

local ViewBaseLayer = require("hall.ViewBaseLayer")
local RecordSelDateLayer = class("RecordSelDateLayer", ViewBaseLayer)

function RecordSelDateLayer:ctor(idx)
    local csbPath = "hall/res/record/recordSelDateLayer.csb"
    RecordSelDateLayer.super.ctor(self, csbPath)

    self.curSelIndex = idx or 15
    
    self:initUIInfoByIndex(self.curSelIndex)
end

function RecordSelDateLayer:initUIInfoByIndex(idx)
    for i = 1, MAX_DATE do
        if i == idx then
            local stateImg = "hall/res/record/image/sd_sel_bg.png"
            require("hall.util.CocosUtil"):toReplaceButtonImg(self["btnDate"..i], stateImg, stateImg, nil, 1)
        else
            local stateImg = "hall/res/commom/blank_kuang.png"
            require("hall.util.CocosUtil"):toReplaceButtonImg(self["btnDate"..i], stateImg, stateImg)
        end
        
        local timeTable = os.date("*t", os.time() - (MAX_DATE - i)*24*3600)
        self["date"..i]:setString(timeTable.day or "0")
        if i == idx then
            local time = string.split(os.date("%Y-%m-%d %H:%M:%S", os.time() - (MAX_DATE - i)*24*3600), " ")
            self.dateTime:setString(time[1] or "")
        end
    end

end

function RecordSelDateLayer:exchangeRecordByIndex(idx)
    dump(idx)

    self:initUIInfoByIndex(idx)
    local time = string.split(os.date("%Y-%m-%d %H:%M:%S", os.time() - (MAX_DATE - idx)*24*3600), " ")
    -- dump(time)
    self.dateTime:setString(time[1] or "")
    local parent = self:getParent()
    -- if idx ~= self.curSelIndex then
        parent:refrashRecordByIndex(os.time() - (MAX_DATE - idx)*24*3600)
    -- end
    self:removeSelf()
end

function RecordSelDateLayer:onClickBtnClose(sender, event)
    self:removeSelf()
end

function RecordSelDateLayer:onClickBtnDate1(sender, event)
    self:exchangeRecordByIndex(1)
end

function RecordSelDateLayer:onClickBtnDate2(sender, event)
    self:exchangeRecordByIndex(2)
end

function RecordSelDateLayer:onClickBtnDate3(sender, event)
    self:exchangeRecordByIndex(3)
end

function RecordSelDateLayer:onClickBtnDate4(sender, event)
    self:exchangeRecordByIndex(4)
end

function RecordSelDateLayer:onClickBtnDate5(sender, event)
    self:exchangeRecordByIndex(5)
end

function RecordSelDateLayer:onClickBtnDate6(sender, event)
    self:exchangeRecordByIndex(6)
end

function RecordSelDateLayer:onClickBtnDate7(sender, event)
    self:exchangeRecordByIndex(7)
end

function RecordSelDateLayer:onClickBtnDate8(sender, event)
    self:exchangeRecordByIndex(8)
end

function RecordSelDateLayer:onClickBtnDate9(sender, event)
    self:exchangeRecordByIndex(9)
end

function RecordSelDateLayer:onClickBtnDate10(sender, event)
    self:exchangeRecordByIndex(10)
end

function RecordSelDateLayer:onClickBtnDate11(sender, event)
    self:exchangeRecordByIndex(11)
end

function RecordSelDateLayer:onClickBtnDate12(sender, event)
    self:exchangeRecordByIndex(12)
end

function RecordSelDateLayer:onClickBtnDate13(sender, event)
    self:exchangeRecordByIndex(13)
end

function RecordSelDateLayer:onClickBtnDate14(sender, event)
    self:exchangeRecordByIndex(14)
end

function RecordSelDateLayer:onClickBtnDate15(sender, event)
    self:exchangeRecordByIndex(15)
end

return RecordSelDateLayer