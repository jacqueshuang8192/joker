local WanFaView = class("WanFaView", function()
    return cc.CSLoader:createNode("hall/res/FriendScircle/SpeedjoinView/WanFaView.csb")
end)

local GetGameName = require("hall.familyCircle.GetGameName")

function WanFaView:ctor(gameConfigList, parent)
    self.parent = parent
    self:setMask()
    GameUtils.setNodeNameBindObj(self)
    self.gameConfigList = gameConfigList
    self:initUI()
    self:initEvent()
    self:labelLayout(gameConfigList)
end

function WanFaView:initUI()
    self.item:hide()
    self.ScrollView_1 = self.root.ScrollView_1
    self.btnClose = self.root.btnClose
    self.ScrollView_1:setScrollBarEnabled(false)

    local director = cc.Director:getInstance()
    local size = director:getWinSize()
    self:setAnchorPoint(0.5, 0.5)
    self:setPosition(size.width / 2, size.height / 2)
end

function WanFaView:initEvent()
    self.btnClose:onClick(handler(self, self.onClickBtnClose), true)
end


function WanFaView:onClickBtnClose()
    self:removeSelf()
end


function WanFaView:labelLayout(list)
    -- local list = {}
    -- for i,v in ipairs(gameConfigList) do
    --     table.insert(list, v.config)
    -- end
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
            end
        end
    end

end

function WanFaView:onClickItem( event )
    local targer = event.target
    local game_data = targer.value

    local temp = {["flag"] = 1  , ["config"] = game_data.gameConfig}
    self.parent:CreateGameTable(1 , temp , nil, nil)
    self:removeSelf()
end

function WanFaView:getDescInfo(config)
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

function WanFaView:onClickInfo( event )
    local target = event.target
    local parant = target:getParent()
    local str = parant.str
    local InfoView = require("hall.familyCircle.InfoView").new(str)
    InfoView:addTo(self)
    local size = self:getContentSize()
    InfoView:setAnchorPoint(0.5, 0.5)
    InfoView:setPosition(size.width / 2, size.height / 2)
end

function WanFaView:setMask()
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

function WanFaView:onExit()

end

return WanFaView