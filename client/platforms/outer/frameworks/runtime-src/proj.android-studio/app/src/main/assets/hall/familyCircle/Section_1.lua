local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local Section = class("Section", NewViewBaseLayer)
local EVENTNAME = {

}
function Section:ctor(data, callBack)
    local data = string.split(data, ",")
    self.data = {}
    for idx, value in ipairs(data) do
        local strs = string.split(value, "-")
        if strs[2] then
            local newStrs = {}
            for i,v in ipairs(strs) do
                v = tonumber(v) or 0
                v = v / 100
                newStrs[i] = v
            end
            table.insert(self.data, newStrs)
        end
    end
    self.callBack = callBack
    local csbPath = "hall/res/FriendScircle/drawView/Section.csb"
    Section.super.ctor(self, csbPath)
    self:enableMask(true)
    GameUtils.setNodeNameBindObj(self._csbNode)
    self:initUI()
    self:initEvent()
    self:setData()
end

function Section:initUI()
    self.item:hide()
    self.ListView_1:removeAllItems()
    for i = 1, 3 do
        local str = i
        local content = self.item["content_"..i]
        content.text:setString("0")
    end
end

function Section:initEvent()
    ReqMgr:addHandle("Section", EVENTNAME)
    self.btnClose:onClick(handler(self, self.onClickBtnReturn), true)
    self.btn_sure:onClick(handler(self, self.onClickSure), true)
    self.btn_add:onClick(handler(self, self.onClickAdd), true)
end

function Section:onClickSure( event )
    local childs = self.ListView_1:getChildren()
    local data = ""
    local startTxts = {}
    local endTxts = {}
    for idx, node in ipairs(childs) do
        local startTxt = tonumber(node.content_1.text:getString()) or 0
        local endTxt = tonumber(node.content_2.text:getString()) or 0
        local text3 = tonumber(node.content_3.text:getString()) or 0
        startTxt = startTxt * 100
        endTxt = endTxt * 100
        text3 = text3 * 100
        if startTxts[startTxt] then
            viewMgr:showTip({text = "参数不合法！"})
            return
        else
            startTxts[startTxt] = idx
        end
        if endTxts[endTxt] then
            viewMgr:showTip({text = "参数不合法！"})
            return
        else
            endTxts[endTxt] = idx
        end

        if endTxt > startTxt then
            local str = startTxt.."-"..endTxt .. "-" .. text3
            data = data .. str .. ","
            -- table.insert(data, str)
        else
            viewMgr:showTip({text = "参数不合法！"})
            return
        end
    end
    dump(data,"data---------")

    local startNums = {}
    for idx, node in ipairs(childs) do
        local startNum = tonumber(node.content_1.text:getString()) or 0
        local endNum = tonumber(node.content_2.text:getString()) or 0
        startNums[startNum] = endNum
    end

    for startNum, endNum in pairs(startNums) do
        for startNum_1, endNum_1 in pairs(startNums) do
            if startNum < startNum_1 and endNum_1 < endNum then
                viewMgr:showTip({text = "参数不合法！"})
                return
            end
        end
    end

    self.callBack(data)
    viewMgr:showTip({text = "设置成功！"})

end

function Section:onClickAdd( event )
    local childs = self.ListView_1:getChildren()
    if #childs >= 5 then
        viewMgr:showTip({text = "设置点位区间，最多设置五个区间"})
        return
    end
    local idx = #childs + 1
    local item = self.item:clone()
    item:show()
    item:setName("item"..idx)
    self.ListView_1:pushBackCustomItem(item)
    GameUtils.setNodeNameBindObj(item)
    -- item.content_3:setString("30")
    -- for i = 1, 3 do
    --     local str = i
    --     local content = item["content_"..i]
    --     content.text:setString(str)
    --     self:newEditBox(content.text, handler(self, self.onEditBox))
    -- end
    local node = childs[#childs]
    local value = {0,10}
    if node then
        value = {}
        local num = tonumber(node.content_2.text:getString()) or 0
        table.insert(value, num)
        table.insert(value, num+10)
    end
    self:setItem(item, value)
end

function Section:onClickDelItem( event )
    local target = event.target:getParent()
    local index = self.ListView_1:getIndex(target)
    self.ListView_1:removeItem(index)
    -- self.ListView_1:requestDoLayout()
end

function Section:setData()
    self.ListView_1:removeAllItems()
    for idx, value in ipairs(self.data) do
        local item = self.item:clone()
        item:show()
        item:setName("item"..idx)
        self.ListView_1:pushBackCustomItem(item)
        GameUtils.setNodeNameBindObj(item)
        self:setItem(item, value)
    end
end

function Section:function_name( paramEndNum )
    local childs = self.ListView_1:getChildren()
    local preStartNum = 0
    local preEndNum = 0
    -- 10-20
    -- 20-40     50
    -- 40-60
    -- 60-80
    -- 80-100

    -- 0.9-80a
    for idx, node in ipairs(childs) do
        local startNum = tonumber(node.content_1.text:getString()) or 0
        local endNum = tonumber(node.content_2.text:getString()) or 0
        if endNum >= endTxt then
            
        end
    end
end

function Section:setItem(item, value)
    value = value or {}
    item.btn_del:onClick(handler(self, self.onClickDelItem), true)

    local childs = self.ListView_1:getChildren()
    local isEditBox = #childs < 2

    for idx = 1, 3 do
        local str = value[idx] or 0
        local content = item["content_"..idx]
        content.text:setString(str)
        if idx == 1 then
            if isEditBox then
                self:newEditBox(content.text, handler(self, self.onEditBox))
            end
        else
            self:newEditBox(content.text, handler(self, self.onEditBox))
        end
      
    end
end

function Section:onEditBox( strEventName,sender )
    if event == ccui.TextFiledEventType.attach_with_ime then
            --光标进入
        elseif event == ccui.TextFiledEventType.detach_with_ime then
            --光标离开 关闭键盘
            -- local num = tonumber(sender:getString()) or 0
            -- num = math.floor(num)
            -- if num < 0 then
            --     num = 0
            -- end
            -- sender:setText(num)
            -- node:setString(num)
            local text = sender:getString()
            text = tonumber(text) or 0
            if math.floor(text) < text then
                text = string.format("%.2f", text)
            end
            sender:setText(text)
            sender:getParent().text:setString(text)
            local item = sender:getParent():getParent()
            local startTxts = {}
            local endTxts = {}
            local childs = self.ListView_1:getChildren()
            for idx, node in ipairs(childs) do
                local startTxt = tonumber(node.content_1.text:getString()) or 0
                local endTxt = tonumber(node.content_2.text:getString()) or 0
                if endTxt <= startTxt then
                    viewMgr:showTip({text = "参数不合法！"})
                    return
                end
                if startTxts[startTxt] or startTxt == endTxt then
                    viewMgr:showTip({text = "参数有雷同不合法！"})
                    return
                else
                    startTxts[startTxt] = idx
                end
                if endTxts[endTxt] then
                    viewMgr:showTip({text = "参数有雷同不合法！"})
                    return
                else
                    endTxts[endTxt] = idx
                end
            end
        elseif event == ccui.TextFiledEventType.insert_text then
            --输入
            local num = tonumber(sender:getString()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            node:setString(num)
        elseif event == ccui.TextFiledEventType.delete_backward then
             --删除
             local num = tonumber(sender:getString()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            node:setString(num)
        end
end
function Section:newTextField(node, handle, maxLength, string)
    if node.editBox then
        return
    end
    string = string or node:getString()
    maxLength = maxLength or 10
    local params = {
        size = node:getContentSize(),
        fontSize = node:getFontSize(),
        fontColor = node:getTextColor(),
        maxLength = maxLength,
        placeHolder = string,
    }
    local textField =  node:getParent():getChildByName("textField")
    if textField then
        textField:removeSelf()
    end
    node:hide()
    local textField = ccs.textField(params)
    textField:setName("textField")
    textField:setContentSize(node:getContentSize())
    node:getParent():addChild(textField)
    textField:setAnchorPoint(node:getAnchorPoint())
    textField:setPosition(node:getPosition())
    textField:setTextColor(node:getTextColor())
    textField:setText(node:getString())
    textField:setTouchSize(node:getContentSize())
    textField:setTouchAreaEnabled(true)

    textField:addEventListener(function(sender,event)
        if event == ccui.TextFiledEventType.attach_with_ime then
            --光标进入
        elseif event == ccui.TextFiledEventType.detach_with_ime then
            --光标离开 关闭键盘
            -- local num = tonumber(sender:getString()) or 0
            -- num = math.floor(num)
            -- if num < 0 then
            --     num = 0
            -- end
            -- sender:setText(num)
            -- node:setString(num)
            local text = sender:getString()
            text = tonumber(text) or 0
            if math.floor(text) < text then
                text = string.format("%.2f", text)
            end
            sender:setText(text)
            sender:getParent().text:setString(text)
            local item = sender:getParent():getParent()
            local startTxts = {}
            local endTxts = {}
            local childs = self.ListView_1:getChildren()
            for idx, node in ipairs(childs) do
                local startTxt = tonumber(node.content_1.text:getString()) or 0
                local endTxt = tonumber(node.content_2.text:getString()) or 0
                if endTxt <= startTxt then
                    viewMgr:showTip({text = "参数不合法！"})
                    return
                end
                if startTxts[startTxt] or startTxt == endTxt then
                    viewMgr:showTip({text = "参数有雷同不合法！"})
                    return
                else
                    startTxts[startTxt] = idx
                end
                if endTxts[endTxt] then
                    viewMgr:showTip({text = "参数有雷同不合法！"})
                    return
                else
                    endTxts[endTxt] = idx
                end
            end
        elseif event == ccui.TextFiledEventType.insert_text then
            --输入
            local num = tonumber(sender:getString()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            node:setString(num)
        elseif event == ccui.TextFiledEventType.delete_backward then
             --删除
             local num = tonumber(sender:getString()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            node:setString(num)
        end
    end)
end
function Section:newEditBox(node, handle, maxLength, string)
    
    self:newTextField(node, handle, maxLength, string)
    do
        return
    end
    node:setSwallowTouches(false)
    string = string or node:getString()
    maxLength = maxLength or 7
    local params = {
        size = node:getContentSize(),
        fontSize = node:getFontSize(),
        maxLength = maxLength,
        inputMode = cc.EDITBOX_INPUT_MODE_DECIMAL,
        placeHolder = string,
    }
    local editBox = ccs.newEditBox(params)
    node:getParent():addChild(editBox)
    editBox:setAnchorPoint(node:getAnchorPoint())
    editBox:setPosition(node:getPosition())
    local idx = editBox:getLocalZOrder()
    editBox:setLocalZOrder(-1)
    editBox:setText(node:getString())
    node:getParent().editBox = editBox
    handle = handle or function( strEventName,sender )
        if strEventName == "began" then--光标进入，选中全部内容
        elseif strEventName == "ended" then--当编辑框失去焦点并且键盘消失的时候被调用
        elseif strEventName == "return" then--当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
        elseif strEventName == "changed" then--输入内容改变时调用
            node:setString(sender:getText())
        end
    end
    editBox:registerScriptEditBoxHandler(handle)
end

function Section:onClickBtnReturn(event)
    self:removeSelf()
end

function Section:onExit()
    ReqMgr:delHandle("Section", EVENTNAME)
end

return Section