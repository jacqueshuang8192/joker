
--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local ListView = ccui.ListView

function ListView:onEvent(callback)
    ListView:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ON_SELECTED_ITEM_START"
        else
            event.name = "ON_SELECTED_ITEM_END"
        end
        event.target = sender
        callback(event)
    end)
    return ListView
end

function ListView:onScroll(callback)
    ListView:addScrollViewEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "SCROLL_TO_TOP"
        elseif eventType == 1 then
            event.name = "SCROLL_TO_BOTTOM"
        elseif eventType == 2 then
            event.name = "SCROLL_TO_LEFT"
        elseif eventType == 3 then
            event.name = "SCROLL_TO_RIGHT"
        elseif eventType == 4 then
            event.name = "SCROLLING"
        elseif eventType == 5 then
            event.name = "BOUNCE_TOP"
        elseif eventType == 6 then
            event.name = "BOUNCE_BOTTOM"
        elseif eventType == 7 then
            event.name = "BOUNCE_LEFT"
        elseif eventType == 8 then
            event.name = "BOUNCE_RIGHT"
        end
        event.target = sender
        callback(event)
    end)
    return ListView
end



--对ListView的优化，见http://blog.csdn.net/sinat_24556247/article/details/51275357
local ListView = ccui.ListView

function ListView:tableShow(number, grid, callback, refresh)--参数说明 数量，模板temp，刷新回调，强制刷新  
    if number == nil or grid == nil or callback == nil then  
        return   
    end  
  
    ListView:onScroll(nil)  
    ListView:removeAllItems()  
    if number == 0 then  
        ListView:jumpToTop()  
        return   
    end  
  
    ListView.allItems = ListView.allItems or {}  
    if refresh then  
        for _, v in pairs(ListView.allItems) do   
            v:release()  
        end  
  
        ListView.allItems = {}  
    end  
  
    local gridSize = grid:getBoundingBox()  
    local innerSize = ListView:getInnerContainerSize()  
    local size = ListView:getContentSize()  
    local direction = ListView:getDirection()  
    local offset = ListView:getItemsMargin()  
    local showNum = 0  
  
    if direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL then  
        offset = offset + gridSize.width  
        showNum = math.ceil(size.width / offset) + 2  
    elseif direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then  
        offset = offset + gridSize.height      
        showNum = math.ceil(size.height / offset) + 2  
    else  
        return  
    end  
  
    local function sortItems()  
        local function func(x, y)  
            return x.index < y.index  
        end  
  
        table.sort(ListView.allItems, func)  
    end  
  
    local function reflushTemp(temp, index)  
        if index <= 0 or index > number then  
            return   
        end  
  
        local parent = temp:getParent()  
        if parent == nil then  
            printWarn("temp not have parent")  
            return   
        end  
  
        local item = ListView:getItem(index - 1)  
        if item == nil then  
            printWarn("can not get item, item is nil")  
            return   
        end  
          
        temp:removeFromParent(false)  
        item:addChild(temp)  
        temp.index = index  
  
        callback(temp, index)  
    end  
  
    local function initItem(item, index)  
        local temp = grid:clone()  
        temp:setVisible(true)  
        temp:setPosition(cc.p(0, 0))  
        temp:setAnchorPoint(cc.p(0, 0))  
        temp.index = index  
        temp:retain()  
        item:addChild(temp)  
  
        ListView.allItems[index] = temp  
        callback(temp, index)  
    end  
  
    local function refreshItem(item, index)   
        local temp = ListView.allItems[index]  
        temp.index = index  
        local parent = temp:getParent()  
        if parent then  
            temp:removeFromParent()  
        end  
        item:addChild(temp)  
        callback(temp, index)  
    end  
  
    local function checkAndRefreshItems()  
        local percent = ListView:getPercent() / 100 --getPercent()c++里面重写的方法，取得当前当前位置与总距离的百分比  
        if percent < 0 or percent > 100 then  
            return   
        end  
  
        innerSize = ListView:getInnerContainerSize()  
        local index = 0  
        if direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL then  
            index = math.ceil((innerSize.width - size.width) * percent / offset)  
        elseif direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then  
            index = math.ceil((innerSize.height - size.height) * percent / offset)  
        end  
  
        if index > 1 then  
            index = index - 1  
        end  
  
        sortItems()  
        local i = 0  
        for _, v in pairs(ListView.allItems) do   
            if v.index < index then  
                reflushTemp(v, index + showNum - 1 - i)  
            elseif v.index > index + showNum - 1 then  
                reflushTemp(v, index + showNum - (i + 1))  
            end  
  
            i = i + 1  
        end  
    end  
  
    local function listViewCallBack(event)  
        if event.name == "SCROLLING" then  
            checkAndRefreshItems()  
        end  
    end    
  
    local default = ccui.Widget:create()  
    default:setContentSize(gridSize)  
    ListView:setItemModel(default)  
    for i = 1, number do   
        if i <= showNum then  
            local item = default:clone()  
            if ListView.allItems[i] then  
                refreshItem(item, i)  
            else  
                initItem(item, i)  
            end  
  
            ListView:pushBackCustomItem(item)  
        else  
            ListView:pushBackDefaultItem()  
        end  
    end  
  
    for k, v in pairs(ListView.allItems) do   
        if k > number then  
            v:release()  
            ListView.allItems[k] = nil  
        end  
    end  
  
    ListView:refreshView()  
    ListView:onScroll(listViewCallBack)  
    checkAndRefreshItems()  
end  
  
function ListView:clearUp()  
    ListView.allItems = ListView.allItems or {}  
    for k, v in pairs(ListView.allItems) do   
        v:release()  
        ListView.allItems[k] = nil  
    end  
    ListView:removeAllItems()  
end  
  
function ListView:getShowItems()  
    return ListView.allItems or {}  
end  


function ListView:onEvent(callback)
    ListView:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ON_SELECTED_ITEM_START"
        else
            event.name = "ON_SELECTED_ITEM_END"
        end
        event.target = sender
        callback(event)
    end)
    return ListView
end

function ListView:onScroll(callback)
    ListView:addScrollViewEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "SCROLL_TO_TOP"
        elseif eventType == 1 then
            event.name = "SCROLL_TO_BOTTOM"
        elseif eventType == 2 then
            event.name = "SCROLL_TO_LEFT"
        elseif eventType == 3 then
            event.name = "SCROLL_TO_RIGHT"
        elseif eventType == 4 then
            event.name = "SCROLLING"
        elseif eventType == 5 then
            event.name = "BOUNCE_TOP"
        elseif eventType == 6 then
            event.name = "BOUNCE_BOTTOM"
        elseif eventType == 7 then
            event.name = "BOUNCE_LEFT"
        elseif eventType == 8 then
            event.name = "BOUNCE_RIGHT"
        end
        event.target = sender
        callback(event)
    end)
    return ListView
end