local SpeedjoinView = class("SpeedjoinView", function()
    return cc.CSLoader:createNode("hall/res/FriendScircle/SpeedjoinView/SpeedjoinView.csb")
end)

local GetGameName = require("hall.familyCircle.GetGameName")

function SpeedjoinView:ctor(gameConfigList,chooseWanFaType)
    self:setMask()
    GameUtils.setNodeNameBindObj(self)
    self.gameConfigList = gameConfigList
    self.chooseWanFaType = chooseWanFaType
    self:initUI()
    self:initEvent()
    self:initGameDataDraw()
end

function SpeedjoinView:initUI()
    self.item:hide()
    self.btn_1:hide()
    self.ListView_1 = self.root.ListView_1
    self.ScrollView_1 = self.root.ScrollView_1
    self.btnClose = self.root.btnClose
    self.ListView_1:setScrollBarEnabled(false)
    self.ScrollView_1:setScrollBarEnabled(false)
end

function SpeedjoinView:initEvent()
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)
end


function SpeedjoinView:onClickBtnClose()

    -- self:getParent():initSpeedjoinTxt()
    
    self:removeSelf()
end

function SpeedjoinView:onClickBtn1( event )
    local target = event.target
    if target == nil then
        viewMgr:showTip({text = "请先定制游戏!"})
        return
    end
    local value = target.value
    local parant = target:getParent()
    for k,node in ipairs(parant:getChildren()) do
        node:setEnabled(true)
    end
    target:setEnabled(false)
    self:labelLayout(value)
end

function SpeedjoinView:initGameDataDraw()
    local SelectLevelAndConfigID = cc.UserDefault:getInstance():getStringForKey("SelectLevelAndConfigID", 1)
    SelectLevelAndConfigID = string.split(SelectLevelAndConfigID, ":")
    local selectLevel = tonumber(SelectLevelAndConfigID[1])
    local selectId = tonumber(SelectLevelAndConfigID[2])

    local gameNameList = {}
    local firstBtn = nil
    local selectedBtn = nil
    for k, value in pairs(self.gameConfigList) do
        for k2, v2 in pairs(value) do
            if next(v2) then
                gameNameList[k] = v2.level
                break
            end
        end
    end

    local gameTypeReal = {}
    for i,v in ipairs(self.chooseWanFaType or {}) do
        if v then
            gameTypeReal[tonumber(v)] = 1
        end
    end

    for k, value in pairs(self.gameConfigList) do
        -- if gameNameList[k] and gameTypeReal[k] then
            local btn_1 = self.btn_1:clone()
            btn_1:show()
            GameUtils.setNodeNameBindObj(btn_1)
            self.ListView_1:pushBackCustomItem(btn_1)
            local name = GetGameName:getName(gameNameList[k])
            btn_1.txt:setString(name)
            btn_1:setEnabled(true)
            btn_1.value = value
            btn_1:onClick(handler(self, self.onClickBtn1))
            if firstBtn == nil then
                firstBtn = btn_1
            end
            if selectLevel == gameNameList[k] then
                selectedBtn = btn_1
            end
        -- end
    end
    if selectedBtn then
        firstBtn = selectedBtn
    end
    self.ListView_1:requestDoLayout()
    self:onClickBtn1( {target = firstBtn} )
end

function SpeedjoinView:labelLayout(list)
    local SelectLevelAndConfigID = cc.UserDefault:getInstance():getStringForKey("SelectLevelAndConfigID", 1)
    SelectLevelAndConfigID = string.split(SelectLevelAndConfigID, ":")
    local selectLevel = tonumber(SelectLevelAndConfigID[1])
    local selectId = tonumber(SelectLevelAndConfigID[2])
    local firstBtn = nil
    local selectedBtn = nil

    self.ScrollView_1:removeAllChildren()
    if list and next(list) then
        local countList = 0
        for k2, v2 in pairs(list or {}) do
            if v2.name ~= nil then
                countList = countList + 1
            end
        end
        local itemSize = self.item:getContentSize()
        local ssize = self.ScrollView_1:getInnerContainerSize()
        local scrollsize = self.ScrollView_1:getContentSize()
        local row = 2
        local height = math.ceil(countList / row) * itemSize.height
        if height < scrollsize.height then
            height = scrollsize.height
        end
        ssize.height = height
        self.ScrollView_1:setInnerContainerSize(ssize)
        local initY = ssize.height - itemSize.height / 2
        local initX = itemSize.width / 2

        local idx = 1
        for k2, v2 in pairs(list or {}) do
            if v2.name ~= nil then
                local item = self.item:clone()
                GameUtils.setNodeNameBindObj(item)
                item:show()
                item.value = v2
                self.ScrollView_1:addChild(item)
                item.txt_name:setString(v2.name)
                local str = self:getDescInfo(v2.gameConfig)
                item.txt_info:setString(str)
                item.showName = v2.name
                item.str = v2.name..":  "..str
                item.btn_info:onClick(handler(self, self.onClickInfo), true)
                item:onClick(handler(self, self.onClickItem), true)

                local rowIdx = idx % row
                rowIdx = rowIdx == 0 and row or rowIdx
                local colIdx = math.ceil(idx/ row)
                local x = initX + (rowIdx - 1) * itemSize.width
                local y = initY - (colIdx - 1) * itemSize.height
                item:setPosition(cc.p(x, y))
                idx = 1 + idx

                -- if firstBtn == nil then
                    -- firstBtn = item
                -- end
                if selectId == v2.id then
                    selectedBtn = item
                end
            end
        end
    end

    if selectedBtn then
        firstBtn = selectedBtn
        self:onClickItem( {target = firstBtn} )
    end
end

function SpeedjoinView:onClickItem( event )
    local target = event.target
    local value = target.value
    local parant = target:getParent()
    for k,node in ipairs(parant:getChildren()) do
        node:loadTexture("hall/res/FriendScircle/SpeedjoinView/btn_4.png")
    end
    target:loadTexture("hall/res/FriendScircle/SpeedjoinView/btn_3.png")

    cc.UserDefault:getInstance():setStringForKey("SelectLevelAndConfigID", value.level..":"..value.id)

    cc.UserDefault:getInstance():setStringForKey("SpeedjoinViewWanFaName", target.showName)

    if event.x then
        self:getParent():initSpeedjoinTxt()
    end

end

function SpeedjoinView:getDescInfo(config)
    local str1 = ""
    local str2 = ""
    local str3 = ""
    for k,cfg in pairs(config) do
        if cfg and type(cfg) == "table" and cfg.configName and cfg.optionName then
            local flag = true
            if config.gameId == 302 or config.gameId == 303 or config.gameId == 304 or config.gameId == 305 or config.gameId == 368 or config.gameId == 613 or config.gameId == 614 or config.gameId == 615 or config.gameId == 616 then
                --牛牛玩法过滤
                if k == 'speTypeOther' or k == 'pointMode' then
                    if config.gaoji and config.gaoji.optionValue then
                        if not string.find(config.gaoji.optionValue, '7') then
                            flag = false
                        end
                    else
                        flag = false
                    end
                end
                if k == 'speType' or k == 'timesRule'  then
                    if config.gaoji and config.gaoji.optionValue then
                        if string.find(config.gaoji.optionValue, '7') then
                            flag = false
                        end
                    end
                end
            end
            if flag then
                str3 =  str3.." "..cfg.configName.." "..cfg.optionName
            end
        end
    end

    if config.maxSeatCount then
        str1 = config.maxSeatCount.optionName
    end
    if config.round then
        str2 = config.round.optionName
    end
    return str3
end

function SpeedjoinView:onClickInfo( event )
    local target = event.target
    local parant = target:getParent()
    local str = parant.str
    local InfoView = require("hall.familyCircle.InfoView").new(str)
    InfoView:addTo(self)
    local size = self:getContentSize()
    InfoView:setAnchorPoint(0.5, 0.5)
    InfoView:setPosition(size.width / 2, size.height / 2)
end

function SpeedjoinView:setMask()
	local director = cc.Director:getInstance()
	local size = director:getWinSize()
    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.maskLayout:setContentSize(cc.size(size.width, size.height))

    local size = self:getContentSize()
    self.maskLayout:setPosition(cc.p(size.width / 2, size.height / 2))
    self.maskLayout:setBackGroundColorType(1)
    self.maskLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    self.maskLayout:setBackGroundColorOpacity(150)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(true)
    self:addChild(self.maskLayout, -1000)
end

function SpeedjoinView:onExit()

end

return SpeedjoinView