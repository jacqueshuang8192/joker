--[[
* author:   zwm
* date:     2019-03-19
* describe: 创建游戏详细信息界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local LINE_HEIGTH = 80

local ViewBaseLayer = require("hall.ViewBaseLayer")
local CreateRoomInfoTip = class("CreateRoomInfoTip", ViewBaseLayer)

function CreateRoomInfoTip:ctor(roomInfo)
    local csbPath = "hall/res/createRoom/createGameTip.csb"
    CreateRoomInfoTip.super.ctor(self, csbPath)

    self.parameter = {}
    self:initGameData(roomInfo)
    self:loadRoomInfo(roomInfo)
end

function CreateRoomInfoTip:initGameData(gameConfig)
    self.multiChoseOption = {}
    --记录当前游戏的游戏id
    self.parameter["gameId"] = gameConfig.gameId
    --记录当前游戏对应的等级
    self.parameter["level"] = gameConfig.level
    --记录当前游戏对应的底注
    self.parameter["diZhu"] = gameConfig.dizhu
    --记录当前游戏对应的筹码
    self.parameter["chouMa"] = gameConfig.chouMa
    --记录当前游戏对应的大类名
    self.parameter["gameName"] = gameConfig.gameName
    --创建金币场时选择的底注
    self.parameter["baseChip"] = 1
    self:setRoomDefaultPara(gameConfig)
end

function CreateRoomInfoTip:setRoomDefaultPara(gameConfig)
    for k1, v1 in pairs( gameConfig.gameConfig or {} ) do
        self.multiChoseOption[v1.configGroup[1].config] = {}
        for k2, v2 in pairs( v1.configGroup[1].configOption or {} ) do
            if v2.isDefualt == 1 then
                if v1.configGroup[1].config == "round" then
                    self.parameter["cardCount"] = v2.cardCount
                end
                self:updateConfig(v1.configGroup[1].config, v1.configShowName, v2, v2.isDefualt, v1.configGroup[1].isCheckBox)
            end
        end
    end
end

function CreateRoomInfoTip:loadRoomInfo(roomInfo)
    if roomInfo == nil then return end

    for k, v in pairs( roomInfo.gameConfig or {} ) do
        self:addEachTypeToLst(v) 
    end
end

-- 添加每类的所有选项
function CreateRoomInfoTip:addEachTypeToLst(info)
    local groupLY = ccui.Layout:create()
    groupLY:setSwallowTouches(true)
    groupLY:setAnchorPoint(cc.p(0,0))
    groupLY:setTouchEnabled(false)
    local lines = 1
    if info and info.configGroup and info.configGroup[1].configOption then
        lines = math.ceil(#info.configGroup[1].configOption/4)
        groupLY:setContentSize(cc.size(1160, LINE_HEIGTH*lines))
    else
        return
    end
    local groupName = self:getGroupTTF(info.configShowName, lines)
    if groupName then
        groupName:addTo(groupLY)
    end

    local line = self:getLineSpr()
    if line then
        line:addTo(groupLY)
    end
    local isHave = false
    if info.configGroup[1] then
        for k, v in pairs( info.configGroup[1].configOption or {} ) do
            if info.configGroup[1].isCheckBox == 0 or info.configGroup[1].isCheckBox == 1 then
                local des = v.optionName
                if info.configGroup[1].config == "round" then
                    des = string.format("%s(Fx%d)", des, v.cardCount)
                end
                local checkBox = self:getCheckBox(info.configGroup[1].isCheckBox, des, (v.isDefualt or 0) > 0)
                checkBox:setName("checkBox"..tostring(k))
                checkBox:setPosition(self:getPositionByIndex(k,lines))
                groupLY:addChild(checkBox)
                isHave = true
                self:toAddListenerCheckBox(groupLY, checkBox, info, info.configGroup[1].isCheckBox ~= 0)
            elseif info.configGroup[1].isCheckBox == 3 then
                self:updateConfig(info.configGroup[1].config, info.configShowName, v, v.isDefualt, info.configGroup[1].isCheckBox)
            end            
        end
    end
    if isHave then
        self.listView:pushBackCustomItem(groupLY)
    end
end

function CreateRoomInfoTip:getGroupTTF(str, lines)
    local label = cc.Label:createWithTTF(str or "", "hall/res/font/FZY3JW.TTF", 30)
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setPosition(cc.p(20, LINE_HEIGTH/2 + (lines-1)*LINE_HEIGTH + 5))
    label:setColor(cc.c3b(174, 103, 46))
    return clone(label)
end

function CreateRoomInfoTip:getLineSpr()
    local sprite = cc.Sprite:create("hall/res/createRoom/image/huan_line.png")
    sprite:setPosition(1160/2, 3)
    return clone(sprite)
end

function CreateRoomInfoTip:getCheckBox(type, des, isSel)
    local checkNode = nil 
    if type == 0 then
        checkNode = cc.CSLoader:createNode("hall/res/createRoom/circleCheckBox.csb")
    elseif type == 1 then
        checkNode = cc.CSLoader:createNode("hall/res/createRoom/tickCheckBox.csb") 
    end

    if checkNode then
        local content = checkNode:getChildByName("content")

        local checkBox = content:getChildByName("checkBox")
        checkBox:setSelected(isSel)

        local desTxt = content:getChildByName("desTxt") 
        desTxt:setString(des)
        if isSel then
            desTxt:setTextColor(cc.c3b(71, 192, 125))
        end
        return checkNode:clone()
    end

    
end

function CreateRoomInfoTip:getPositionByIndex(index, allLines)
    local line = math.floor(index/4)
    local _index = index%4
    if _index == 0 then 
        _index = 4  
        line = line - 1
    end
    local beginPosX = 150
    print("===line==_index==",line,_index)
    return cc.p((_index-1)*200+beginPosX,LINE_HEIGTH*(allLines-line))



    -- local line = math.floor(index/5)
    -- -- local line = index
    -- local mod = math.mod(index, 3)
    -- local beginPosX = 150
    -- return cc.p((index-1)*230+beginPosX,LINE_HEIGTH*((maxLine-line)))



    -- if mod == 0 then
    --     return cc.p(2*230 + beginPosX, LINE_HEIGTH*((maxLine-line)+1))
    -- else
    --     return cc.p((mod-1)*230 + beginPosX, LINE_HEIGTH*(maxLine-(line)))
    -- end
end

function CreateRoomInfoTip:toAddListenerCheckBox(parant, checkNode, groupData, isMutex)
    local checkBox = checkNode:getChildByName("content"):getChildByName("checkBox")
    local label    = checkNode:getChildByName("content"):getChildByName("desTxt")
    

    checkBox:addEventListenerCheckBox(function(sender,eventType)
        require("hall.GameCommon"):playEffectSound("hall/scene/res/common/music/Audio_Button_Click.mp3")
        local index = tonumber(string.sub(checkNode:getName(), 9, -1))
        if eventType == CHECKBOX_STATE_EVENT_SELECTED then
            if isMutex then
                local data = groupData.configGroup[1]
                self:updateConfig(data.config, groupData.configShowName, data.configOption[index], 1, data.isCheckBox)
                label:setTextColor(cc.c3b(71, 192, 125))
            else
                self:reSetDesTxtColorByIndex(parant, groupData, index)
            end
            
        elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
            if isMutex then
                local data = groupData.configGroup[1]
                self:updateConfig(data.config, groupData.configShowName, data.configOption[index], 2, data.isCheckBox)
                label:setTextColor(cc.c3b(174, 103, 46))
            else
                sender:setSelected(true)
            end
        end
    end)

    local btnCallBack = function ( sender, event )
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound(BTN_CLICK_VOICE)
        elseif event == TOUCH_EVENT_ENDED then
            local sel = checkBox:getSelectedState()
            if not sel and isMutex then
                self:reSetDesTxtColorByIndex(parant, groupData, index)
            end
        end
    end
    -- label:setTouchEnabled(true)
    -- label:addTouchEventListener(btnCallBack)

end

function CreateRoomInfoTip:reSetDesTxtColorByIndex(parant, data, index)
    print("reSetDesTxtColorByIndex -----------------------")
    dump(data.configGroup[1].configOption)
    for i = 1, #data.configGroup[1].configOption do
        local checkBox = parant:getChildByName("checkBox"..tonumber(i)):getChildByName("content"):getChildByName("checkBox")
        local label = parant:getChildByName("checkBox"..tonumber(i)):getChildByName("content"):getChildByName("desTxt")
        if i == index then
            checkBox:setSelected(true)
            label:setTextColor(cc.c3b(71, 192, 125))
            if data.configGroup[1].config == "round" then
                self.parameter["cardCount"] = data.configGroup[1].configOption[index].cardCount
            end
            self:updateConfig(data.configGroup[1].config, data.configShowName, data.configGroup[1].configOption[index], data.configGroup[1].configOption[index].isDefualt, data.configGroup[1].isCheckBox)
        else
            checkBox:setSelected(false)
            label:setTextColor(cc.c3b(174, 103, 46))
        end
    end
end

function CreateRoomInfoTip:updateConfig(config,configName,option,updateType,checkBoxType)
                                 
    local optionName = option["optionName"]
    local optionValue = option["optionValue"]
    local isShow = option["isShow"]
    local newRelateConfigArr = option["newRelateConfigArr"]

    if checkBoxType == 1 or checkBoxType == 4 then

        local select = {}
        select["optionName"] = ""
        select["optionValue"] = ""

        if  updateType ==  1 then  --添加
            self.multiChoseOption[config][optionName] = {}
            self.multiChoseOption[config][optionName]["value"] = optionValue
            self.multiChoseOption[config][optionName]["updateType"] = 1
        else
            self.multiChoseOption[config][optionName] = {}
            self.multiChoseOption[config][optionName]["value"] = optionValue
            self.multiChoseOption[config][optionName]["updateType"] = 2
        end
         
        for optionName,optionTable in pairs(self.multiChoseOption[config]) do
            if optionTable["updateType"] == 1 then
                select["optionName"] = select["optionName"] .. optionName .. " "
                select["optionValue"] = select["optionValue"] .. optionTable["value"] .. ","
            end
        end

        --添加默认项
        select["optionName"] = string.sub(select["optionName"], 1, string.len(select["optionName"]) - 1)
        select["optionValue"] = string.sub(select["optionValue"], 1, string.len(select["optionValue"]) - 1)
        select["isShow"] = isShow
        select["configName"] = configName

        self.parameter[config] = select

    elseif checkBoxType == 0 or checkBoxType == 3 then

        local select = {}
        select["optionName"] = optionName
        select["optionValue"] = optionValue
        select["isShow"] = isShow
        select["configName"] = configName

        self.parameter[config] = select

    elseif checkBoxType == 2 then

        local select = {}
        select["optionName"] = optionName
        select["optionValue"] = optionValue
        select["isShow"] = isShow
        select["configName"] = configName

        --配置项为底分时，把选项值放到
        if  config == "baseChip" then
            self.parameter["baseChip"] = tonumber(optionValue)
        else
            self.parameter[config] = select
        end  
    end
end

function CreateRoomInfoTip:onClickBtnClose( sender, event )
    self:removeSelf()
end

function CreateRoomInfoTip:onClickBtnCreate( sender, event )
    dump(self.parameter, "onClickBtnCreate")
    require("hall.GameCommon"):landLoading(true)  --房卡场一点创建房间就进入LOADING
    require(GroupSetting_filePath):create(1, 1, 1, self.parameter["level"], self.parameter)
end

return CreateRoomInfoTip