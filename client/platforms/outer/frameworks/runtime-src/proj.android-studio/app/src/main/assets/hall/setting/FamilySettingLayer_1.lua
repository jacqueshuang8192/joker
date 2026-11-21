--[[
* author:   zwm
* date:     2019-03-21
* describe: 设置界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]

local FamilySettingLayer = class("FamilySettingLayer", NewViewBaseLayer)
local EVENTNAME = {
	UPDATE_GROUP_CONFIG = "/updateGroupConfig",
}

function FamilySettingLayer:ctor(config, family_id, parent)
    ReqMgr:addHandle("FamilySettingLayer", EVENTNAME)
    local csbPath = "hall/res/setting/FamilySettingLayer.csb"
    FamilySettingLayer.super.ctor(self, csbPath)
    self.parent = parent
    self.seleceeds = {} --checkBox_1是选中 checkBox_2是不选中
    self.config = config
    self.family_id = family_id
    self:enableMask(true)
    self:initUI()
    self:initEvent()
    self:setData( )
end

function FamilySettingLayer:initUI()
    self.item:hide()
    self.itemTxt:hide()
    self.ListView:removeAllChildren()
    self.ListView:setScrollBarEnabled(false);
end

function FamilySettingLayer:initEvent()
    self.btn_sure:onClick(handler(self, self.onClickSure))
    
end

function FamilySettingLayer:setData( )

     -- 1 : 显示 0 : 不显示
    -- "show_ranking":1, //显示排行榜
	-- "show_member":0, //显示成员
	-- "show_record":1,  //战绩纪录
	-- "is_chat":1,	//是否聊天
	-- "exchange_status":0, //赠送积分
	-- "is_agree":0, //是否同意 1 : 要盟主同意才可以加入 0 : 可以直接加入
    -- "club_status":1 //打烊  1 : 正常运营 0:打烊
    local config = self.config
    local show_ranking = (config.show_ranking or 1) == 1 
    local show_member = (config.show_member or 1) == 1 
    local show_record = (config.show_record or 1) == 1 
    local is_chat = (config.is_chat or 1) == 1 
    local exchange_status = (config.exchange_status or 1) == 1 
    local is_agree = (config.is_agree or 1) == 1 
    local club_status = (config.club_status or 1) == 1 
    local auto_exit_club = (config.auto_exit_club or 1) == 1
    local show_table = (config.show_table or 0)
    local datas = {
        {
            desc = "成员能否显示排名",
            is = show_ranking,
            name = "show_ranking",
            select_1 = "显示",
            select_2 = "不显示",
        },
        {
            desc = "能否显示成员列表",
            is = show_member,
            name = "show_member",
            select_1 = "显示",
            select_2 = "不显示",
        },
        {
            desc = "成员能否显示战绩",
            is = show_record,
            name = "show_record",
            select_1 = "显示",
            select_2 = "不显示",
        },
        {
            desc = "成员能否聊天",
            is = is_chat,
            name = "is_chat",
            select_1 = "可以",
            select_2 = "不可以",
        },
        {
            desc = "成员能否赠送积分",
            is = exchange_status,
            name = "exchange_status",
            select_1 = "可以",
            select_2 = "不可以",
        },
        {
            desc = "成员要盟主同意才可以加入",
            is = is_agree,
            name = "is_agree",
            select_1 = "开启",
            select_2 = "不开启",
        },
        {
            desc = "联盟运营状态",
            is = club_status,
            name = "club_status",
            select_1 = "运营",
            select_2 = "打烊中",
        },
        {
            desc = "玩家是否可以自动退盟",
            is = auto_exit_club,
            name = "auto_exit_club",
            select_1 = "开启",
            select_2 = "不开启",
        },
        {
            desc = "请输入玩家桌子最大局数",
            is = show_table,
            name = "show_table",
            select_1 = "开启",
            select_2 = "不开启",
        }
       
    }
    self.datas = datas
    for idx,data in ipairs(datas) do
        if data.name == "show_table" then
            local item = self.itemTxt:clone()
            GameUtils.setNodeNameBindObj(item)
            item:show()
            item.txt_title:setString("请输入玩家桌子显示数量")
            item.txt:setString(data.is)
            self:newTextField(item.txt, nil, nil, idx)
            self.ListView:pushBackCustomItem(item)
        else
            local item = self.item:clone()
            GameUtils.setNodeNameBindObj(item)
            item:show()
            self:initItem(item, data, idx)
            self.ListView:pushBackCustomItem(item)
        end
    end
    -- for idx=1,7 do
    --     local item = self.item:clone()
    --     GameUtils.setNodeNameBindObj(item)
    --     item:show()
    --     self:initItem(item, data, idx)
    --     self.ListView:pushBackCustomItem(item)
    -- end
end

function FamilySettingLayer:newTextField(node, maxLength, string, index1)
    string = string or node:getString()
    maxLength = maxLength or 10
    local params = {
        size = node:getContentSize(),
        fontSize = node:getFontSize(),
        fontColor = node:getTextColor(),
        maxLength = maxLength,
        placeHolder = string,
    }
    node:hide()
    local textField = ccs.textField(params)
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
            local num = tonumber(sender:getString()) or 0
            num = math.floor(num)
            if num < 0 then
                num = 0
            end
            sender:setText(num)
            node:setString(num)
			if index1 then
                self.datas[index1].is = num
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

function FamilySettingLayer:initItem(item, data, idx)
    item.txt_title:setString(data.desc)
    for i=1,2 do
        local checkBox = item.lsview["checkBox_"..i]
        local desTxt = item.lsview["desTxt_"..i]
        checkBox:setSelectedState(false)
        -- local str = i == 1 and "显示" or "不显示"
        local str = data["select_"..i]
        desTxt:setString(str)
        checkBox:addEventListenerCheckBox(function(sender,eventType)
            require("hall.GameCommon"):onClickSound()
            if eventType == CHECKBOX_STATE_EVENT_SELECTED then
                local target = sender
                local parent = target:getParent()
                for i=1,2 do
                    local checkBox = item.lsview["checkBox_"..i]
                    checkBox:setSelectedState(false)
                end
                checkBox:setSelectedState(true)
                local name = checkBox:getName()
                local isSelected = name == "checkBox_1"
                self.datas[idx].selected = isSelected
                item.lsview:doLayout()  
            elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
                checkBox:setSelectedState(true)
            end
        end)
    end
    item.lsview:doLayout()  
    item.lsview:setScrollBarEnabled(false)

    local checkBox_1 = item.lsview["checkBox_1"]
    local checkBox_2 = item.lsview["checkBox_2"]
    if data.is then
        checkBox_1:setSelectedState(true)
        self.datas[idx].selected = true
    else
        checkBox_2:setSelectedState(true)
        self.datas[idx].selected = false
    end
end

function FamilySettingLayer:onClickSure(event)
    dump(self.datas)
     -- 1 : 显示 0 : 不显示
     local data = {
        playerId = USER_INFO["uid"] ,
        groupId = self.family_id ,
    }
    dump(self.config,"--------111111")
    local config = {}
    for idx,value in ipairs(self.datas) do
        if value.name == "show_table" then
            data[value.name] = value.is
            config[value.name] = value.is
            self.config[value.name] = value.is
        else
            data[value.name] = value.selected == true and 1 or 0
            config[value.name] = value.selected == true and 1 or 0
            self.config[value.name] = value.selected == true and 1 or 0
        end

    end
    ReqMgr:request(EVENTNAME.UPDATE_GROUP_CONFIG, data, handler(self , self.UPDATE_GROUP_CONFIG), config)

end

function FamilySettingLayer:UPDATE_GROUP_CONFIG(event )
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if returnCode == 0 then
        viewMgr:showTip({text = data})
        dump(self.config,"--------222222")
        self.parent.config = self.config
        if g_hallMainLayer then
            g_hallMainLayer:loadClub()
        end
    else
        viewMgr:showTip({text = error})
    end
    dump(data)
end

function FamilySettingLayer:onClickBtnClose(event)
    self:removeSelf()
end

function FamilySettingLayer:onExit()
    ReqMgr:delHandle("FamilySettingLayer", EVENTNAME)
end

return FamilySettingLayer