local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local ZouShiView = class("ZouShiView", NewViewBaseLayer)
local Server = require("longhu100.src.handle.Server")
function ZouShiView:ctor()
    ZouShiView.super.ctor(self, "longhu100/res/View/ZouShiView.csb", false)
    self:enableMask(true)
    GameUtils.setNodeNameBindObj(self)
    self:setNodeEventEnabled(true)
    self:initUI()
    self:initEvent()
    self:setData(g_101.recordData)
end

function ZouShiView:initUI()
    self.btnClose = self._csbNode.root.bg.btnClose
    self.ListView = self._csbNode.root.ListView
    self.ScrollView_1 = self._csbNode.root.ScrollView_1
    self.LoadingBar = self._csbNode.root.LoadingBar

    self.ListView:setScrollBarEnabled(false)
    self.ScrollView_1:setScrollBarEnabled(false)
    self.ListView:removeAllItems()
    self.ScrollView_1:removeAllChildren()
end

function ZouShiView:initEvent()
    self.btnClose:onClick(handler(self, self.onClickClose), true)
end

function ZouShiView:onClickClose(event)
    self:removeSelf()
end


function ZouShiView:setData(data)
    local data = {}
    for i,v in ipairs(g_101.recordData) do
        table.insert(data, 1, v)
    end
    local newData = {}
    local tData = {}
    local idx = 1
    local maxCol = 1
    local long = {}
    local hu = {}
    for i,_type in ipairs(data) do
        local path = "longhu100/res/View/he1.png"
        if _type == 1 then
            path = "longhu100/res/View/long1.png"
        elseif _type == 2 then 
            path = "longhu100/res/View/hu1.png"
        elseif _type == 3 then
            path = "longhu100/res/View/he1.png"
        end
        local item = ccui.ImageView:create(path)
        self.ListView:pushBackCustomItem(item)
        table.insert(tData, _type)
        if #tData >= 7 then
            table.insert(newData, tData)
            tData = {}
        else
            if data[i+1] and data[i+1] ~= data[i] then
                table.insert(newData, tData)
                if maxCol < #tData then
                    maxCol = #tData
                end
                tData = {}
            elseif not data[i+1] then
                table.insert(newData, tData)
                if maxCol < #tData then
                    maxCol = #tData
                end
            end
        end
        if i <= 20 then
            if _type == 1 then
                table.insert( long, _type )
            elseif _type == 2 then 
                table.insert( hu, _type )
            end
        end
    end

    local progress = math.floor(#long / (#hu + #long) * 100 + 0.5)
    if #hu == 0 then
        progress = 100
    elseif #long == 0 then
        progress = 0
    end
    local progress1 = 100 - progress
    local txt = string.format("%d%%",progress)
    local txt1 = string.format("%d%%",progress1)
    if progress == 0 then
        txt = ""
        txt1 = "0%"
    end
    if progress1 == 0 then
        txt = "100%"
        txt1 = ""
    end
    local size = self.LoadingBar:getContentSize()
    self.LoadingBar:show()
    self.LoadingBar.LoadingBar_1:setPercent(progress)
    self.LoadingBar.LoadingBar_1.txt:setString(txt)
    self.LoadingBar.LoadingBar_1.txt:setPositionX(size.width * (progress / 2 / 100))
    self.LoadingBar.txt:setString(txt1)
    self.LoadingBar.txt:setPositionX(size.width * (progress1 / 2 / 100) + size.width * (progress / 100))

    local size = 41
    local ssize = self.ScrollView_1:getInnerContainerSize()
    local scrollsize = self.ScrollView_1:getContentSize()
    local width = #newData * size - ((#newData * 2))
    local height = maxCol * size - ((maxCol * 2))
    if width < scrollsize.width then
        width = scrollsize.width
    end
    if height < scrollsize.height then
        height = scrollsize.height
    end
    self.ScrollView_1:setInnerContainerSize(cc.size(width, height))
    
    local jiange = -2
    for indexx, tData in ipairs(newData) do
        for indexy,_type in ipairs(tData) do
            local path = "longhu100/res/View/he.png"
            if _type == 1 then
                path = "longhu100/res/View/long.png"
            elseif _type == 2 then 
                path = "longhu100/res/View/hu.png"
            elseif _type == 3 then
                path = "longhu100/res/View/he.png"
            end
            local item = ccui.ImageView:create(path)

            local y = height - ((indexy-1) * size + size / 2) - (indexy-1) * jiange
            local x = (indexx-1) * size + size / 2 + (indexx-1) * jiange
            item:setPosition(cc.p(x, y))
            item:addTo(self.ScrollView_1)
        end
    end
end

function ZouShiView:onExit()

end

return ZouShiView
