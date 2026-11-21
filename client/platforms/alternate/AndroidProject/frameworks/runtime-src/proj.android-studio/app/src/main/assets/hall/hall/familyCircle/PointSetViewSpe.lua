local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local PointSetViewSpe = class("PointSetViewSpe", NewViewBaseLayer)
local GetGameName = require("hall.familyCircle.GetGameName")
local EVENTNAME = {
	UPDATE_MY_SON_CONFIG_DIST = "/updateMySonConfigDistSpe",
}
function PointSetViewSpe:ctor(groupId, playerId, data, roleType)
    local csbPath = "hall/res/FriendScircle/PartnerInfo/PointSetViewSpe.csb"
    PointSetViewSpe.super.ctor(self, csbPath)
    self:enableMask(true)
    GameUtils.setNodeNameBindObj(self._csbNode)
    self.parents = g_hallMainLayer.familyMainlayer
    self.family_id = groupId
    self.playerId = playerId
    self.data = data
    self.roleType = roleType
    self:initUI()
    self:initEvent()
    self:initGameDataDraw()
end

function PointSetViewSpe:initUI()
    self.item:hide()
    self.btn_1:hide()
    self.listViewTal:setScrollBarEnabled(false)
    self.ListView_1:setScrollBarEnabled(false)
end

function PointSetViewSpe:initEvent()
    ReqMgr:addHandle("PointSetViewSpe", EVENTNAME)
  
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)
    self.btn_sure:onClick(handler(self, self.onClickSure), true)
end

function PointSetViewSpe:onClickSure( )
    local str = ""
    --词典格式 configId-自己抽取-是否默认 例如 (2-1-0,3-4-1,5-5-0)
    dump(self.data, 'xjkfldafda')
    for k,data in pairs(self.data) do
        local configId = data.configId or "0"
        local myFixedProfit = data.myFixedProfit or "0"
        local isDefault = data.isDefault or "0"
        local superFixedProfit = data.superFixedProfit or "0"
        str = str .. configId .."-".. myFixedProfit .."-".. isDefault .. "-" .. superFixedProfit ..","
    end

    local data = {}
    data.groupId = self.family_id
    data.XYUid = USER_INFO.uid
    data.searchUid = self.playerId
    data.distStr = str

    dump(data,"familyCircle.PointSetViewSpe")
    ReqMgr:request(EVENTNAME.UPDATE_MY_SON_CONFIG_DIST, data, handler(self, self.UPDATE_MY_SON_CONFIG_DIST))
end

function PointSetViewSpe:UPDATE_MY_SON_CONFIG_DIST(event )
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if netData.returnCode == 0 and self then
        viewMgr:showTip({text = "操作成功！"})
    else
        viewMgr:showTip({text = error})
    end
end

function PointSetViewSpe:onClickBtnClose()
    self:removeSelf()
end

function PointSetViewSpe:onClickBtn1( event )

    local target = event.target
    if target == nil then
        viewMgr:showTip({text = "请先定制游戏!"})
        return
    end
    local value = target.value
    local parant = target:getParent()
    dump("onClickBtn1")
    for k,node in ipairs(parant:getChildren()) do
        node:setEnabled(true)
    end
    target:setEnabled(false)
    self:labelLayout(value)
end

function PointSetViewSpe:initGameDataDraw()
    local gameNameList = {}
    local firstBtn = nil
    for k, value in pairs(self.parents.gameConfigList) do
        for k2, v2 in pairs(value) do
            if next(v2) then
                --只添加某个游戏或者是所有的游戏
                if HallIsShowSpecialRatioGameMap then
                    for gameK, gameV in pairs(HallIsShowSpecialRatioGameMap) do
                        if gameV == v2.level then
                            gameNameList[k] = v2.level
                            break
                        end
                    end
                else
                    gameNameList[k] = v2.level
                    break
                end
            end
        end
    end
    for k, value in pairs(self.parents.gameConfigList) do
        if gameNameList[k] then
            local btn_1 = self.btn_1:clone()
            btn_1:show()
            GameUtils.setNodeNameBindObj(btn_1)
            self.listViewTal:pushBackCustomItem(btn_1)
            local name = GetGameName:getName(gameNameList[k])
            btn_1:setTitleText(name)
            btn_1:setEnabled(true)
            btn_1.value = value
            btn_1:onClick(handler(self, self.onClickBtn1))
            if firstBtn == nil then
                firstBtn = btn_1
            end
        end
    end
    self.listViewTal:requestDoLayout()
    self:onClickBtn1( {target = firstBtn} )
end

function PointSetViewSpe:labelLayout(list)
    self.ListView_1:removeAllItems()
    if list and next(list) then
        local countList = 0
        for k2, v2 in pairs(list or {}) do
            if v2.name ~= nil then
                countList = countList + 1
            end
        end
        local firstItem = nil
        local btn1Height = 71
        local btn2Height = 73
        local height = btn2Height * countList + btn1Height
        local initY = height - btn1Height / 2

        dump(self.data)

        for k2, v2 in pairs(list or {}) do
            if v2.name ~= nil then
                local item = self.item:clone()
                GameUtils.setNodeNameBindObj(item)
                item:show()
                item.id = k2
                local name = require("hall.GameCommon"):formatNick(v2.name or " ")
                self.data[k2] = self.data[k2] or {}
                self.data[k2].myFixedProfit = self.data[k2].myFixedProfit or 0
                self.data[k2].myFixedMaxProfit = self.data[k2].myFixedMaxProfit or 0
                self.data[k2].superFixedProfit = self.data[k2].superFixedProfit or 0
                self.data[k2].superFixedMaxProfit = self.data[k2].superFixedMaxProfit or 0

                self.data[k2].isDefault = self.data[k2].isDefault or 1
                self.data[k2].myFixedTatolProfit = self.data[k2].myFixedMaxProfit
                local data = self.data[k2]
                local myFixedProfit = data.myFixedProfit
                local myFixedMaxProfit = data.myFixedMaxProfit
                local isDefault = data.isDefault
                local superFixedProfit = data.superFixedProfit
                local superFixedMaxProfit = data.superFixedMaxProfit
                myFixedMaxProfit = myFixedMaxProfit / 100
                myFixedProfit = myFixedProfit / 100
                superFixedProfit = superFixedProfit / 100
                superFixedMaxProfit = superFixedMaxProfit / 100
                item.txt_name:setString(name)
                item.txt_point:setString(myFixedProfit)
                item.txt_point_spe:setString(superFixedProfit)
                if self.roleType == 0 then
                    item.txt_remain_point:setString("剩:全部")
                    item.txt_remain_point_spe:setString("超额剩:全部")
                else
                    item.txt_remain_point:setString("剩".. (myFixedMaxProfit - myFixedProfit))
                    item.txt_remain_point_spe:setString('超额剩' .. (superFixedMaxProfit - superFixedProfit))
                end
                if isDefault == 1 then
                    item.btn_default.txt_default:setString("默认")
                else
                    item.btn_default.txt_default:setString("非默认")
                end
                item.btn_default.id = k2
                item.btn_default:onClick(handler(self, self.onClickDefault), true)

                self:newEditBox(item.txt_point, handler(self, self.onEditBox))
                self:newEditBox(item.txt_point_spe, handler(self, self.onEditBox2))
                self.ListView_1:pushBackCustomItem(item)
            end
        end
    end
end

function PointSetViewSpe:onClickDefault( event )
    local target = event.target
    local id = target:getParent().id
    local data = self.data[id] or {}
    local isDefault = data.isDefault or 1
    if isDefault == 1 then
        isDefault = 0
    else
        isDefault = 1
    end
    if isDefault == 1 then
        target.txt_default:setString("默认")
    else
        target.txt_default:setString("非默认")
    end
    self.data[target.id].isDefault = isDefault
end

function PointSetViewSpe:newEditBox(node, handle, maxLength, string)
    if node.editBox then
        return
    end
    node:setSwallowTouches(false)
    string = string or node:getString()
    maxLength = maxLength or 7
    local params = {
        size = node:getContentSize(),
        -- fontSize = node:getFontSize(),
        fontSize = 1,
        fontColor = node:getTextColor(),
        maxLength = maxLength,
        inputMode = cc.EDITBOX_INPUT_MODE_DECIMAL,
        -- placeHolder = string,
    }
    local editBox = ccs.newEditBox(params)
    node:getParent():addChild(editBox)
    editBox:setAnchorPoint(node:getAnchorPoint())
    editBox:setPosition(node:getPosition())
    local idx = editBox:getLocalZOrder()
    editBox:setLocalZOrder(-99)
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

function PointSetViewSpe:newEditBox2(node, handle, maxLength, string)
    if node.editBox then
        return
    end
    node:setSwallowTouches(false)
    string = string or node:getString()
    maxLength = maxLength or 7
    local params = {
        size = node:getContentSize(),
        -- fontSize = node:getFontSize(),
        fontSize = 1,
        fontColor = node:getTextColor(),
        maxLength = maxLength,
        inputMode = cc.EDITBOX_INPUT_MODE_DECIMAL,
        -- placeHolder = string,
    }
    local editBox = ccs.newEditBox(params)
    node:getParent():addChild(editBox)
    editBox:setAnchorPoint(node:getAnchorPoint())
    editBox:setPosition(node:getPosition())
    local idx = editBox:getLocalZOrder()
    editBox:setLocalZOrder(-99)
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

function PointSetViewSpe:onEditBox( strEventName,sender )
    dump(strEventName,"-strEventName")
    if strEventName == "began" then--光标进入，选中全部内容
        sender:setText("")
        sender:getParent().txt_point:setString("")
    elseif strEventName == "ended" then--当编辑框失去焦点并且键盘消失的时候被调用
        local text = sender:getText()
        text = tonumber(text) or 0
        if math.floor(text) < text then
            text = string.format("%.2f", text)
        end
        local id = sender:getParent().id
        local myFixedTatolProfit = self.data[id].myFixedTatolProfit or 0
        local textNum = tonumber(text) * 100

        if self.roleType == 0 then
            self.data[id].myFixedProfit = textNum
            sender:getParent().txt_remain_point:setString("剩:全部")
        else
            if myFixedTatolProfit - textNum >= 0 then
                self.data[id] = self.data[id] or {}
                self.data[id].myFixedProfit = textNum
                sender:setText(text)
                sender:getParent().txt_point:setString(text)
                local myFixedProfit = (myFixedTatolProfit - textNum) / 100
                sender:getParent().txt_remain_point:setString("剩".. myFixedProfit)
            else
                text = 0
                local sum = myFixedTatolProfit / 100 - text
                sender:getParent().txt_remain_point:setString("剩".. myFixedTatolProfit / 100 )
            end
        end

        sender:setText(text)
        sender:getParent().txt_point:setString(text)
       
    elseif strEventName == "return" then--当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
    elseif strEventName == "changed" then--输入内容改变时调用
        sender:getParent().txt_point:setString(sender:getText())
    end
end

function PointSetViewSpe:onEditBox2( strEventName,sender )
    dump(strEventName,"-strEventName")
    if strEventName == "began" then--光标进入，选中全部内容
        sender:setText("")
        sender:getParent().txt_point_spe:setString("")
    elseif strEventName == "ended" then--当编辑框失去焦点并且键盘消失的时候被调用
        local text = sender:getText()
        text = tonumber(text) or 0
        if math.floor(text) < text then
            text = string.format("%.2f", text)
        end
        local id = sender:getParent().id
        local superFixedMaxProfit = self.data[id].superFixedMaxProfit or 0
        local superFixedProfit = self.data[id].superFixedProfit or 0
        local textNum = tonumber(text) * 100

        if self.roleType == 0 then
            self.data[id].superFixedProfit = textNum
            sender:getParent().txt_remain_point_spe:setString("超额剩:全部")
        else
            if superFixedMaxProfit - textNum >= 0 then
                self.data[id] = self.data[id] or {}
                self.data[id].superFixedProfit = textNum
                sender:setText(text)
                sender:getParent().txt_point_spe:setString(text)
                local myFixedProfit = (superFixedMaxProfit - textNum) / 100
                sender:getParent().txt_remain_point_spe:setString('超额剩' .. myFixedProfit)
            else
                text = 0
                sender:getParent().txt_remain_point_spe:setString("超额剩".. superFixedMaxProfit / 100)
            end
        end

        sender:setText(text)
        sender:getParent().txt_point_spe:setString(text)

    elseif strEventName == "return" then--当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
    elseif strEventName == "changed" then--输入内容改变时调用
        sender:getParent().txt_point_spe:setString(sender:getText())
    end
end

function PointSetViewSpe:onExit()
    ReqMgr:delHandle("PointSetViewSpe", EVENTNAME)
end

return PointSetViewSpe