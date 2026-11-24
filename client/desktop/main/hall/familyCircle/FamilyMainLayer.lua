--[[
* author:   zwm
* date:     2019-03-21
* describe: 进入游戏界面
* explain:  如果要继承 ViewBaseLayer 这个基类，子类要加载的csb文件，如果需要适配全屏。
            如果有背景图片，要命名为"bg"。界面里面的节点则放到节点"root"下。(具体请参照hallMainLayer.csd, 这个界面)
            如果没这两个节点这不会适配。
--]]
local ViewBaseLayer = require("hall.NewViewBaseLayer")
local FamilyMainLayer = class("FamilyMainLayer", ViewBaseLayer)
local Safe = require("hall.familyCircle.Safe")
local ScoreRank = require("hall.familyCircle.ScoreRank")

local FamilyTableView = require("hall.familyCircle.FamilyTableView")
local FamilyLimit = require("hall.familyCircle.FamilyLimit")
local FamilySelectGameTip = require("hall.familyCircle.FamilySelectGameTip")
local FamilyTakeLayer = require("hall.familyCircle.FamilyTakeLayer")
local clubSendData = require("hall.view.clubView.clubSendData")
local FamilyData = require("hall.familyCircle.FamilyData")
local CocosUtil = require("hall.util.CocosUtil")
local FamilyUntils = require("hall.familyCircle.FamilyUntils")
local FamilyNoticeTip = require("hall.familyCircle.FamilyNoticeTip")
local FamilyCreateGame = require("hall.familyCircle.FamilyCreateGame")
local UpdateGameName = require("hall.familyCircle.UpdateGameName")
local SubordinateMembers = require("hall.familyCircle.SubordinateMembers")
local GetGameName = require("hall.familyCircle.GetGameName")
local WanFaView = require("hall.familyCircle.WanFaView")

local Timer = require("hall.lib.Timer")

local oneLineCount = 3
local oneColCount = 2

local levelList = require("hall.familyCircle.levelList")
local jifen_levels = levelList[1]
local fangka_levels = levelList[2]

local EVENTNAME = {
    GOTO_CLUB = "/gotoClub",
    GET_NOTICE = "/getNotice",
    --SELECT_GAME_CONFIG = "/selectGameConfig",
    DELETE_GROUP_BY_OWERID = "/deleteGroupByOwerId",
    SELECT_GROUP_PLAYER_BYDAYINGJIA = "/selectGroupPlayerBydayingjia",
    playerExitGroupByGroupId = "/playerExitGroupByGroupId",
    joinFreeGame = "/joinFreeGame",
}
local heightSize = 98

familyType_jf = 2
 --2:积分--3房卡
familyType_fk = 3
function FamilyMainLayer:ctor(data, parents, clickLevel)
    self.chooseWanFaType = {}
    is_club_scene = true
    ReqMgr:addHandle("FamilyMainLayer", EVENTNAME)
    gameTypeTemp = 0
    local csbPath = "hall/res/FriendScircle/familyMainLayer.csb"
    FamilyMainLayer.super.ctor(self, csbPath)
    GameUtils.setNodeNameBindObj(self._csbNode)

    self.btnMember:show()
    self.btnJilu:hide()
    self.btnZhanJi:hide()

    self:onChangeBg()
    self:updateUserScore(0) --设置积分默认值0
    self.parents = parents
    self.data = data
    self:setData(data)
    if PreviousLevel ~= 0 and clickLevel == nil then
        clickLevel = PreviousLevel
    end
    if familyType == nil then --2:积分--3房卡
        familyType = familyType_jf
    end
    clickLevel = clickLevel or 0
    self.curLevel = clickLevel
    self.clickLevel = clickLevel
    self.gameTypeIndex = 0
    self.bg = self._csbNode.bg
    display.doLayout(self.root, self.bg)

    if self.gameNum then
        self.gameNum:setVisible(false)
    end

    self:reloadViewByLevelType()
    self:getGameTypeIndex()
    self:initEvent()
    self:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
    self.left_listView:setScrollBarEnabled(false)
    -- self.ScrollView_1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- self.ScrollView_1:setInnerContainerSize(self.ScrollView_1:getContentSize())
    -- self.ScrollView_1:setInnerContainerPosition(cc.p(0,0))
    self.time = 0
     --桌子刷新問題
    self.isTouth = true
    self.name:setString("")
end

function FamilyMainLayer:getGameTypeIndex()
    for i, value in ipairs(jifen_levels) do
        for gameType, level in pairs(value) do
            if tonumber(level) == self.clickLevel then
                self.gameTypeIndex = tonumber(gameType)
                break
            end
        end
    end
end

function FamilyMainLayer:reloadViewByLevelType()
    self.gameConfigList = {}
    local idxs = {
        [2] = 1,
        [3] = 2
    }
    local idx = idxs[familyType]
    jifen_levels = levelList[idx]
    self.left_listView:removeAllChildren()
    self:FreshData(self.data, self.parents, self.clickLevel)
    self:initUI()
end

function FamilyMainLayer:initUI()
    if self.roleType then
        self.btn_familyOut:setVisible(self.roleType ~= 0 and ((self.config.auto_exit_club or 1) == 1))
    end

    self.vw_btns:setVisible(false)
    self.btn_del:setVisible(USER_INFO["uid"] == self.owerId)
    self.btn_familySet:setVisible(USER_INFO["uid"] == self.owerId)
    self.btn_new:setVisible(USER_INFO["uid"] == self.owerId)
    self.btn_familyGiveScore:setVisible(familyType == familyType_jf)
    self.bt_jifen:setVisible(familyType == familyType_jf)
    self.btnFamilyType.jifen:setVisible(familyType == familyType_jf)
    self.btnFamilyType.fangka:setVisible(familyType == familyType_fk)
    self:setvwbtns()
    self:initScrollView()
end

function FamilyMainLayer:initEvent()
    self.btnSet:onClick(handler(self, self.onClickBtnSet), true)
    self.btn_del:onClick(handler(self, self.onClickBtnDel), true)
    self.btn_familySet:onClick(handler(self, self.onClickBtnFamilySet), true)
    self.bt_jifen:onClick(handler(self, self.onClickJifen), false)
    self.btn_familyGiveScore:onClick(handler(self, self.onClickGiveScore), true)
    self.btn_new:onClick(handler(self, self.onClickNew), true)
    self.btnFamilyType:onClick(handler(self, self.onClickFamilyType), true, 0.5)

    --新加入按钮
    self.btn_familyOut:onClick(handler(self, self.onClickFamilyOut), true)

    --公告和名片移到这里
    self.btn_mingPian:onClick(handler(self, self.onClickMingPian), true)
    self.btn_gongGao:onClick(handler(self, self.onClickGongGao), true)

    self.btn_tongzuoXianZhi:onClick(handler(self, self.onClickTongZuoXianZhi), true)

    self.btn_youxiXuanZhe:onClick(handler(self, self.onClickYouXiXuanZhe), true)

    self.BtnSpeedjoin:onClick(handler(self, self.onClickBtnSpeedjoin), true)
    self.BtnSetconfig:onClick(handler(self, self.onClickBtnSetconfig), true)
    self.btnJilu:onClick(handler(self, self.onClickBtnZj), true)
    self.btnZhanJi:onClick(handler(self, self.onClickBtnZhanJi), true)

    self:initSpeedjoinTxt()
end

function FamilyMainLayer:onClickYouXiXuanZhe()
    self.UserClashView = require("hall.familyCircle.WanFaSettingLayer").new(self.family_id, self.chooseWanFaType)
    if self.UserClashView then
        self.UserClashView:addTo(self)
    end
end

function FamilyMainLayer:onClickTongZuoXianZhi()
    self.UserClashView = require("hall.familyCircle.UserClashView").new(self.family_id)
    if self.UserClashView then
        self.UserClashView:addTo(self)
    end
end

function FamilyMainLayer:initSpeedjoinTxt()
    local SelectLevelAndConfigID = cc.UserDefault:getInstance():getStringForKey("SelectLevelAndConfigID", 1)
    SelectLevelAndConfigID = string.split(SelectLevelAndConfigID, ":")
    local selectLevel = tonumber(SelectLevelAndConfigID[1])
    local selectId = tonumber(SelectLevelAndConfigID[2])

    --[[local name = GetGameName:getName(selectLevel)
    self.BtnSpeedjoin:getChildByName("Text_1"):setString(name)--]]
    local strname = cc.UserDefault:getInstance():getStringForKey("SpeedjoinViewWanFaName", "")
    self.BtnSpeedjoin:getChildByName("Text_1"):setString(strname)
end

function FamilyMainLayer:getConfigByLevel(selectLevel)
    for k, data in ipairs(jifen_levels) do
        for gameType, level in pairs(data) do
            if selectLevel == level then
                return gameType
            end
        end
    end
    return 0
end

function FamilyMainLayer:onClickBtnSpeedjoin(...)
    local SelectLevelAndConfigID = cc.UserDefault:getInstance():getStringForKey("SelectLevelAndConfigID", 1)
    SelectLevelAndConfigID = string.split(SelectLevelAndConfigID, ":")
    local selectLevel = tonumber(SelectLevelAndConfigID[1])
    local selectId = tonumber(SelectLevelAndConfigID[2])

    if selectId then
        local gameType = self:getConfigByLevel(selectLevel)
        if not self.gameConfigList[gameType] then
            viewMgr:showTip({text = "桌子未创建"})
            return
        end
        require("hall.HallServer"):SPEED_JOIN(tonumber(self.family_id), selectLevel, selectId)
        makeroom = self:getGameConfigListById(selectId)
    else
        viewMgr:showTip({text = "点击进房选择游戏"})
    end
end

function FamilyMainLayer:onClickBtnSetconfig(event)
    local SpeedjoinView = require("hall.familyCircle.SpeedjoinView").new(self.gameConfigList, self.chooseWanFaType)
    SpeedjoinView:addTo(self)
    local director = cc.Director:getInstance()
    local size = director:getWinSize()
    SpeedjoinView:setAnchorPoint(0.5, 0.5)
    SpeedjoinView:setPosition(size.width / 2, size.height / 2)
end

function FamilyMainLayer:onClickGongGao()
    if self.roleType == 0 or self.roleType == 2 then
        self.family_notice = FamilyNoticeTip.new(self.family_id):addTo(self)
    end
end

function FamilyMainLayer:onClickMingPian()
    if self.roleType == 0 or self.roleType == 2 then -- 盟主-- 合伙人
        local BusinessCard = require("hall.BusinessCard.BusinessCard")
        BusinessCard.new(self.data):addTo(self)
    elseif self.roleType == 3 then -- 普通玩家
        local BusinessCard_2 = require("hall.BusinessCard.BusinessCard_2")
        local BusinessCard_2 = BusinessCard_2.new(self.data):addTo(self)
        BusinessCard_2:initGame()
    end
end

function FamilyMainLayer:onClickFamilyOut()
    local commtip_data = {}
    commtip_data.type = 2
    commtip_data.title = "退出联盟"
    commtip_data.content = "你确定要退出联盟么"

    local function Sure(familyid)
        local data = {
            groupId = familyid,
            XYUid = USER_INFO["uid"]
        }
        ReqMgr:request(EVENTNAME.playerExitGroupByGroupId, data, handler(self, self.playerExitGroupByGroupId))
    end
    local function Cancel(id)
    end

    commtip_data.callBackSure = CocosUtil:Bind(Sure, self.family_id)
    commtip_data.callBackCancel = CocosUtil:Bind(Cancel, self.family_id)
    require("hall.tips.CommonTips"):showTips(commtip_data)
end

function FamilyMainLayer:setvwbtns()
    local chids = self.vw_btns:getChildren()
    local size = self.vw_btns:getContentSize()
    local height = chids[1]:getContentSize().height

    local oldY = (height + 8)
    for idx, node in ipairs(chids) do
        if node:isVisible() then
            node:setPositionY(oldY)
            oldY = oldY + (height + 8)
        end
    end
    self.vw_btns:setSize(size.width, oldY)
end

function FamilyMainLayer:onClickFamilyType()
    local count = 0
    for k, v in pairs(fangka_levels) do
        count = count + 1
    end
    if count <= 0 then
        return
    end
    if familyType == familyType_jf then
        familyType = familyType_fk
    elseif familyType == familyType_fk then
        familyType = familyType_jf
    end

    self:reloadViewByLevelType()
    self.btnFamilyType.jifen:setVisible(familyType == familyType_jf)
    self.btnFamilyType.fangka:setVisible(familyType == familyType_fk)
    clickLevel = nil
end

function FamilyMainLayer:onClickNew()
    local ReminderView = require("hall.familyCircle.ReminderView").new(self.family_id)
    if ReminderView then
        ReminderView:addTo(self)
    end
end

function FamilyMainLayer:onClickGiveScore()
    local GiveScoreView = require("hall.familyCircle.GiveScoreView").new(self, self.family_id)
    if GiveScoreView then
        GiveScoreView:addTo(self)
    end
end

function FamilyMainLayer:setData(data)
    USER_INFO["family_id"] = data.key
    self.family_id = data.key
    self.owerId = data.owerId
    self.roleType = data.roleType
    self.checkGameType = 0
    self.config = json.decode(self.data.config)
    self.btn_familyOut:setVisible(self.roleType ~= 0 and ((self.config.auto_exit_club or 1) == 1))

    self.btn_mingPian:setVisible(true)
    self.btn_gongGao:setVisible(self.roleType == 0 or self.roleType == 2)
    self.btn_youxiXuanZhe:setVisible(self.roleType == 0)
    self.btn_youxiXuanZhe:setVisible(false)
    self.btn_tongzuoXianZhi:setVisible(self.roleType == 0)

    if self.roleType ~= 0 and self.roleType ~= 2 then
        self.btnZhanJi:setVisible(false)
    end

    if self.parents and self.parents.configData then
        local configData = self.parents.configData[self.family_id]
        if configData then
            configData = json.decode(configData)
            if configData and configData.config then
                self.config = json.decode(configData.config)
            end
        end
    end
    self.bt_items:removeAllChildren()
    self.left_listView:removeAllChildren()
    self.ListViewSelect:removeAllChildren()

    self.gameConfigList = {}
    self.data = data
    self.table_datas = {}
    self:initScrollViewData()
end

function FamilyMainLayer:FreshData(data, parents, clickLevel)
    self:setData(data)
    local is = false
    for k, v in pairs(self.gameConfigList or {}) do
        is = true
        break
    end

    if is == false then
        local datav = {groupId = data.key, playerId = USER_INFO["uid"]}
        ReqMgr:request(EVENTNAME.GOTO_CLUB, datav, handler(self, self.select_game_config), nil, nil, false)
    else
        if self.InitGame then
            self:InitGame(USER_INFO["family_id"])
            self:onClickCheckbox({target = self.curCheckboxNode})
        end
    end
end

function FamilyMainLayer:select_game_config(event, keepLevel)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if returnCode == 0 then
        if STATUS_GAME then
            return
        end
        print("=== select_game_config 被调用，keepLevel =", keepLevel)
        --合并数据
        if self.updateUserScore and data.point then
            self:updateUserScore(data.point)
            self.curPoint = data.point
        end
        local gameTypes = {}
        for i, value in ipairs(jifen_levels) do
            for gameType, level in pairs(value) do
                gameTypes[gameType] = gameType
            end
        end

        self.chooseWanFaType = {}
        if data.gameLimits then --玩法选择的数据
            self.chooseWanFaType = data.gameLimits
        end

        --需要拿到是否是限制了玩法的
        if self.InitGame then
            self:InitGame(USER_INFO["family_id"])
        end

        if data.gameConfigs then
            for k, v in pairs(data.gameConfigs) do
                local confg = {}
                if type(v.config) == "string" then
                    confg = json.decode(v.config) or {}
                elseif type(v.config) == "table" then
                    confg = v.config
                end

                if gameTypes[v.gameType] and next(confg) then
                    confg.name = v.name
                    confg.id = v.id
                    local FloorData = {}
                    FloorData.name = v.name
                    FloorData.gameName = v.name
                    FloorData.gameLevel = v.level
                    FloorData.level = v.level
                    FloorData.gameType = tonumber(v.gameType)
                    FloorData.id = v.id
                    confg.gameType = tonumber(v.gameType)
                    FloorData.gameConfig = confg
                    FloorData.gameConfig.tempGameType = tonumber(v.gameType)
                    if self.addConfigData then
                        self:addConfigData(FloorData)
                    end
                end
            end
        end

        if data.notice and data.notice.notice and self.showBroadcast then
            braodComponentDefaulMessage = data.notice.notice or ""
            self:showBroadcast(data.notice) --公告
        end
        
        -- 如果传入了 keepLevel，就尝试选中这个 level
        if keepLevel and keepLevel ~= 0 then
            local children = self.left_listView:getChildren() or {}
            print("=== select_game_config, children count =", #children)
            for i, child in ipairs(children) do
                print("  child", i, "level =", child.level)
            end
            
            local foundTarget = nil
            for i, child in ipairs(children) do
                if child.level == keepLevel then
                    foundTarget = child
                    break
                end
            end
            
            if foundTarget then
                print("=== 找到了 keepLevel =", keepLevel, "，准备选中")
                -- 找到了，直接选中这个
                for i, child in ipairs(children) do
                    child.select = true
                end
                foundTarget.select = false
                self.curCheckboxNode = foundTarget
                self.clickLevel = keepLevel
                self.curLevel = keepLevel
                self.checkGameType = foundTarget.k
                self.config_id = nil
                self:initScrollViewData()
                self:SendServer(0)
                self:getWanFaData()
                print("=== 完成选中 keepLevel")
                return
            else
                print("=== 没有找到 keepLevel =", keepLevel, "，使用默认方式")
            end
        end
        
        -- 否则用原来的方式
        print("=== 使用默认方式，curCheckboxNode.level =", self.curCheckboxNode and self.curCheckboxNode.level)
        self:onClickCheckbox({target = self.curCheckboxNode})
    end
end



function FamilyMainLayer:InitGame(family_id)
    require("hall.GameCommon"):formatNick(self.data.groupName or " ")
    local name = require("hall.GameCommon"):formatNick(self.data.groupName or " ")
    self.name:setString(name)
    self.nameID:setString("ID:" .. USER_INFO["uid"])
    self.family_id = family_id
    self.lamp_word = "房主发布消息"

    local func = function(jifen_levels, clickLevel)
        for i, value in ipairs(jifen_levels) do
            for gameType, level in pairs(value) do
                if clickLevel == level then
                    return true
                end
            end
        end
        return false
    end
    local is_include_level = func(jifen_levels, self.clickLevel)

    local size = #jifen_levels

    local ssize = self.left_listView:getInnerContainerSize()
    local scrollsize = self.left_listView:getContentSize()
    local height = size * heightSize
    if height < scrollsize.height then
        height = scrollsize.height
    end
    local pos = self.left_listView:getInnerContainerPosition()
    self.left_listView:setInnerContainerSize(cc.size(ssize.width, height))
    local index = 0

    local idx = 0
    if is_include_level then
        idx = self.clickLevel
    end
    self.curCheckboxNode = nil
    for i, value in ipairs(jifen_levels) do
        for key, level in pairs(value) do
            local checkbox = ccui.ImageView:create()
            if level == 0 then
                checkbox.select = true
            else
                checkbox.select = false
            end
            checkbox:loadTexture("hall/res/FriendScircle/new_img/" .. level .. ".png")
            checkbox:ignoreContentAdaptWithSize(true)
            checkbox.level = level
            checkbox:setName("bt_" .. level .. "_" .. key)
            checkbox.v = level
            checkbox.k = key
            checkbox:onClick(handler(self, self.onClickCheckbox), true)
            self.left_listView:addChild(checkbox)
            local y = height - (i - 1) * heightSize - heightSize / 2
            checkbox:setPosition(73, y)
            if level == idx and is_include_level then
                checkbox.select = false
                self.gameTypeIndex = tonumber(key)
                self.curCheckboxNode = checkbox
            end
        end
    end
    FamilyData:Init()
    self:set_bt_items(self.config)
end

function FamilyMainLayer:InitGameAfterChoose(family_id)
    self.left_listView:removeAllChildren()
    local func = function(jifen_levels, clickLevel)
        for i, value in ipairs(jifen_levels) do
            for gameType, level in pairs(value) do
                if clickLevel == level then
                    return true
                end
            end
        end
        return false
    end
    local is_include_level = func(jifen_levels, self.clickLevel)

    local idx = 0
    if is_include_level then
        idx = self.clickLevel
    end
    self.curCheckboxNode = nil

    local showLevel = {}
    if #self.chooseWanFaType > 0 then
        table.insert(showLevel, {[0] = 0})
        for i, v in ipairs(self.chooseWanFaType) do
            for key, value in ipairs(jifen_levels) do
                for key, level in pairs(value) do
                    if key == tonumber(v) then
                        table.insert(showLevel, value)
                        break
                    end
                end
            end
        end
    else
        --showLevel = jifen_levels
    end

    if showLevel == {} then
        viewMgr:showTip({text = "请至少选择一款游戏"})
    end

    for i, value in ipairs(showLevel) do
        for key, level in pairs(value) do
            local checkbox = ccui.ImageView:create()
            if level == 0 then
                checkbox.select = true
                checkbox:loadTexture("hall/res/FriendScircle/new_img/btn_2.png")
            else
                checkbox:loadTexture("hall/res/FriendScircle/new_img/btn_1.png")
                checkbox.select = false
            end
            checkbox:ignoreContentAdaptWithSize(true)
            checkbox.level = level
            checkbox:setName("bt_" .. level .. "_" .. key)
            checkbox.v = level
            checkbox.k = key
            checkbox:onClick(handler(self, self.onClickCheckbox), true)
            -- self.left_listView:pushBackCustomItem(checkbox)
            if level == idx and is_include_level then
                checkbox.select = false
                self.gameTypeIndex = tonumber(key)
                self.curCheckboxNode = checkbox
            end
        end
    end
    FamilyData:Init()

    local chids = self.left_listView:getChildren()
    chids[1].select = false
    self:onClickCheckbox({target = chids[1]})
end

function FamilyMainLayer:onClickCheckbox(event)
    if not self.isTouth and event.x then
        return
    end
    local sender = event.target
    if sender == nil then
        return
    end

    self.time = 0
    local v = sender.v
    local k = sender.k
    self.curLevel = v
    gameTypeTemp = k
    if sender.select == false then
        self.gameTypeIndex = tonumber(k)
        local chids = self.left_listView:getChildren() or {}
        for k2, v2 in ipairs(chids) do
            v2.select = false
            local tableData = string.split(v2:getName(), "_")
            -- v2:loadTexture("hall/res/FriendScircle/new_img/btn_2.png")
            -- v2:loadTexture("hall/res/FriendScircle/new_img/icon_choice_"..tableData[2]..".png")
            v2:ignoreContentAdaptWithSize(true)
            v2:removeAllChildren()
        end

        self.ListViewSelect:removeAllChildren()
        PreviousLevel = self.curLevel
        if sender.level ~= 0 then
            self.checkGameType = k
            self.config_id = nil
            self:InitTakeTable(nil, v, k)
        else
            self.config_id = nil
            self.checkGameType = 0
        end
        self:initScrollViewData()
        self:SendServer(0)
        self:getWanFaData()
        -- sender:loadTexture("hall/res/FriendScircle/new_img/btn_1.png")
        -- sender:loadTexture("hall/res/FriendScircle/new_img/icon_select_"..v..".png")
        sender:ignoreContentAdaptWithSize(true)
        sender.select = true

        if not self.isOneClick then
            self.isOneClick = true
            local sendery = sender:getPosition().y - self.left_listView:getContentSize().height + heightSize / 2
            if sendery < 0 then
                sendery = 0
            end
            local pos = self.left_listView:getInnerContainerPosition()
            pos.y = -sendery
            self.left_listView:setInnerContainerPosition(pos)
        end

        self.curCheckTableNode = sender
        self:creArmature(sender)
    end
end

function FamilyMainLayer:creArmature(scene)
    local effectManage = ccs.ArmatureDataManager:getInstance()
    local path = "hall/res/hallMain/ani/xuanzhong/xuanzhong"
    display.addSpriteFrames(path .. "0.png", path .. "0.plist")
    effectManage:addArmatureFileInfo(path .. "0.png", path .. "0.plist", path .. ".ExportJson")
    local Armature = ccs.Armature:create("xuanzhong")
    Armature:addTo(scene)
    local anim = Armature:getAnimation()
    anim:playWithIndex(0, 0, 1) --第一个参数是动画表index 第二个是时间间隔 第三个是是否循环

    local size = scene:getSize()

    Armature:setPosition(size.width / 2, size.height / 2)
    return Armature
end

function FamilyMainLayer:InitBroadCast()
    require("hall.familyCircle.FamilyBraodComponent"):showBraod(self.braodPlane)
    local data = {
        groupId = self.family_id,
        XYUid = USER_INFO.uid
    }
    ReqMgr:request(EVENTNAME.GET_NOTICE, data, handler(self, self.GET_NOTICE))
end

--显示走马灯广播
function FamilyMainLayer:GET_NOTICE(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if returnCode == 0 then
        self:showBroadcast(data) --公告
    else
        viewMgr:showTip({text = error})
    end
end

function FamilyMainLayer:showBroadcast(data)
    require("hall.familyCircle.FamilyBraodComponent"):showBraod(self.braodPlane)
    require("hall.familyCircle.FamilyBraodComponent"):setDefaultBraodMessage(data.notice)
end

function FamilyMainLayer:SendServer(_type)
    local page = self.addTableSize
    if _type == 0 then
        page = self.tableInitSize
    end
    -- self.isTouth = false
    require("hall.HallServer"):sendClubData(self.family_id, familyType, _type, page, self.checkGameType, self.config_id)
end

function FamilyMainLayer:InitGameData(isManager)
    local touch = function(event)
        local target = event.target
        local name = target:getName()
        --[[if name == "gonggao" then
            if self.roleType == 0 or self.roleType == 2 then
                self.family_notice = FamilyNoticeTip.new(self.family_id):addTo(self)
            end
        elseif name == "mingbian" then
            if self.roleType == 0 or self.roleType == 2 then -- 盟主-- 合伙人
                local BusinessCard = require("hall.BusinessCard.BusinessCard")
                BusinessCard.new(self.data):addTo(self)
            elseif self.roleType == 3 then-- 普通玩家
                local BusinessCard_2 = require("hall.BusinessCard.BusinessCard_2")
                local BusinessCard_2 = BusinessCard_2.new(self.data):addTo(self)
                BusinessCard_2:initGame( )
            end--]]
        if name == "hehuoren" then
            local FamilyPartner = require("hall.familyCircle.FamilyPartner")
            FamilyPartner.new(self, self.roleType, self.family_id, USER_INFO["uid"], self.owerId):addTo(self)
        elseif name == "xianzhi" then --限制
            local flag = false
            for key, value in pairs(self.gameConfigList or {}) do
                for kkey, table_ds in pairs(value) do
                    if table_ds then
                        flag = true
                        break
                    end
                end
                if flag then
                    break
                end
            end
            if flag then
                local DrawConfig = require("hall.familyCircle.DrawConfig")
                DrawConfig.new(self, self.family_id):addTo(self)
            else
                viewMgr:showTip({text = "请先定制游戏!"})
            end
        elseif name == "jifen" then --积分管理
            local ishehuoren = not (tonumber(self.owerId) == tonumber(USER_INFO["uid"]))
            local IntegralManagement = require("hall.familyCircle.IntegralManagement")
            IntegralManagement.new(self.family_id, self, USER_INFO["uid"], ishehuoren, nil, self.roleType):addTo(self)
        elseif name == "baoxiangui" then --保险柜
            Safe.new(self.family_id, self.roleType, self, self.curPoint):addTo(self)
        elseif name == "chengyuan" then
            SubordinateMembers.new(self, self.family_id, USER_INFO["uid"]):addTo(self)
        elseif name == "paiming" then
            ScoreRank.new(self):addTo(self)
        end
    end
    local paths = {
        --gonggao = "hall/res/FriendScircle/image/bt_item1.png",--公告
        --mingbian = "hall/res/FriendScircle/image/bt_item2.png",--名片
        paiming = "hall/res/FriendScircle/image/bt_item3.png",
         --排名
        xianzhi = "hall/res/FriendScircle/image/bt_item4.png",
         --限制
        jifen = "hall/res/FriendScircle/image/bt_item5.png",
         --积分
        hehuoren = "hall/res/FriendScircle/image/bt_item6.png",
         --合伙人
        chengyuan = "hall/res/FriendScircle/image/bt_item7.png",
         --成员
        baoxiangui = "hall/res/FriendScircle/image/bt_item8.png"
     --保险柜
    }
    if familyType == familyType_fk then
        paths = {}
    end
    local btns = {}
    local size = self.bt_items:getContentSize()
    --local posX = size.width / 2
    local posX = self.btnMember:getPositionX() + self.btnMember:getContentSize().width
    if self.roleType == 0 then -- 盟主
        btns = {
            --"gonggao",
            --"mingbian",
            "paiming",
            "xianzhi",
            "jifen",
            "hehuoren",
            "baoxiangui"
        }
    elseif self.roleType == 2 then -- 合伙人
        btns = {
            --"gonggao",
            --"mingbian",
            "paiming",
            "jifen",
            "hehuoren",
            "chengyuan",
            "baoxiangui"
        }
    else -- 普通玩家
        if isManager then
            btns = {
                "paiming",
                "jifen",
                "hehuoren",
                "chengyuan",
                "baoxiangui"
            }
        else
            btns = {
                --"mingbian",
                "baoxiangui"
            }
        end
    end
    local indx = 1
    for idx, name in ipairs(btns) do
        local path = paths[name]
        if path then
            local item = ccui.ImageView:create(path)
            local size = item:getContentSize()
            item:loadTexture(path)
            item:setVisible(true)
            item:setName(name)
            item:onClick(touch, true)
            item:setPosition(cc.p(posX + 20 + indx * size.width, size.height / 2))
            self.bt_items:addChild(item)
            indx = indx + 1
        end
    end
end

function FamilyMainLayer:set_bt_items(config)
    -- self.parents:loadClub()
    -- 1 : 显示 0 : 不显示
    -- "show_ranking":1, //显示排行榜
    -- "show_member":0, //显示成员
    -- "show_record":1,  //战绩纪录
    -- "is_chat":1,	//是否聊天
    -- "exchange_status":0, //赠送积分
    -- "is_agree":0, //是否同意 1 : 要盟主同意才可以加入 0 : 可以直接加入
    -- "club_status":1 //打烊  1 : 正常运营 0:打烊
    -- "auto_exit_club" : 1 : 显示退出联盟的按钮

    if USER_INFO.family_data and config then
        USER_INFO.family_data.config = json.encode(config)
        self.config = config
    end
    if self.parents.configData then
        local configData = self.parents.configData[self.family_id]
        configData = json.decode(configData)
        configData.config = json.encode(config)
        self.parents.configData[self.family_id] = json.encode(configData)
    end

    local show_ranking = (config.show_ranking or 1) == 1 or self.owerId == USER_INFO.uid
    local show_member = (config.show_member or 1) == 1 or self.owerId == USER_INFO.uid or self.data.isManager == 1
    local show_record = (config.show_record or 1) == 1 or self.owerId == USER_INFO.uid
    local is_chat = (config.is_chat or 1) == 1 or self.owerId == USER_INFO.uid
    local exchange_status = ((config.exchange_status or 1) == 1 or self.owerId == USER_INFO.uid) and familyType == familyType_jf
    local is_agree = (config.is_agree or 1) == 1 or self.owerId == USER_INFO.uid
    local club_status = (config.club_status or 1) == 1 or self.owerId == USER_INFO.uid
    g_family_is_chat = is_chat

    self.bt_items:removeAllChildren()
    self:InitGameData(self.data.isManager == 1)

    local tab = {
        --[[ gonggao = self.bt_items:getChildByName("gonggao"),
        mingbian = self.bt_items:getChildByName("mingbian"),--]]
        paiming = self.bt_items:getChildByName("paiming"),
        xianzhi = self.bt_items:getChildByName("xianzhi"),
        btn_familyGiveScore = self.btn_familyGiveScore,
        hehuoren = self.bt_items:getChildByName("hehuoren"),
        chengyuan = self.bt_items:getChildByName("chengyuan"),
        baoxiangui = self.bt_items:getChildByName("baoxiangui"),
        btnZhanJi = self.btnZhanJi,
        btnMember = self.btnMember
    }

    local data = {
        --[[gonggao = true,
        mingpian = true,--]]
        paiming = show_ranking,
        xianzhi = true,
        btn_familyGiveScore = exchange_status,
        hehuoren = true,
        chengyuan = true,
        baoxiangui = true,
        btnZhanJi = show_record,
        btnMember = show_member
    }
    if not show_record then
        self.btnJilu:setPosition(self.btnZhanJi:getPosition())
    end
    if self.roleType == 0 then -- 盟主
        -- self.btnJilu:show()
    elseif self.roleType == 2 then -- 合伙人
        -- self.btnJilu:show()
    elseif self.roleType == 3 then -- 普通玩家
    end

    -- "show_ranking":1, //显示排行榜
    -- "show_member":0, //显示成员
    -- "show_record":1,  //战绩纪录
    -- "is_chat":1,	//是否聊天
    -- "exchange_status":0, //赠送积分
    -- "is_agree":0, //是否同意 1 : 要盟主同意才可以加入 0 : 可以直接加入
    -- "club_status":1 //打烊  1 : 正常运营 0:打烊

    for key, isShow in pairs(data) do
        local node = tab[key]
        if node then
            if isShow == false then
                if self[key] then
                    node:hide()
                else
                    node:removeSelf()
                end
            else
                node:show()
            end
        end
    end

    local size = self.bt_items:getSize()
    local childs = self.bt_items:getChildren()
    -- local cardWidth = tab[1]:getWidth()
    -- local oriX = size.width -  cardWidth / 2
    -- local oriX = size.width
    -- for idx,node in ipairs(childs) do
    --     local cardWidth = node:getWidth()
    --     if idx == 1 then
    --         oriX = oriX -  cardWidth / 2
    --     end
    --     cardWidth = cardWidth + cardWidth / 3
    -- 	local x = oriX - ( idx-1 ) * cardWidth
    --     node:setPositionX(x)
    -- end

    local size = self.bt_items:getSize()
    local childs = self.bt_items:getChildren()
    local cardWidth = childs[1]:getWidth()
    local oriX = size.width - 320
    local idx = 1
    for idx, node in ipairs(childs) do
        cardWidth = node:getWidth()
        oriX = oriX - cardWidth
        node:setPositionX(oriX)
        oriX = oriX - 10
    end

    self:setvwbtns()
end

function FamilyMainLayer:onClickBtnSet(...)
    local enterRoomLayer = require("hall.setting.SettingLayer").new(false)
    if enterRoomLayer then
        enterRoomLayer:addTo(self)
    end
end

function FamilyMainLayer:onClickBtnFamilySet()
    local FamilySettingLayer = require("hall.setting.FamilySettingLayer").new(self.config, self.family_id, self)
    if FamilySettingLayer then
        FamilySettingLayer:addTo(self)
    end
end

function FamilyMainLayer:onClickJifen()
    local SelfScoreRecord = require("hall.familyCircle.SelfScoreRecord").new(self.family_id)
    if SelfScoreRecord then
        SelfScoreRecord:addTo(self)
    end
end

--删除联盟
function FamilyMainLayer:onClickBtnDel(...)
    local data = {
        groupId = self.family_id,
        XYUid = USER_INFO.uid
    }
    ReqMgr:request(EVENTNAME.SELECT_GROUP_PLAYER_BYDAYINGJIA, data, handler(self, self.SELECT_GROUP_PLAYER_BYDAYINGJIA))
end

function FamilyMainLayer:SELECT_GROUP_PLAYER_BYDAYINGJIA(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if returnCode == 0 then
        local pointCount = 0
        for k, v in pairs(data) do
            if v.pointCount / 100 >= 1 then
                pointCount = v.pointCount / 100
                break
            end
        end
        if pointCount >= 1 then
            viewMgr:showTip({text = "成员中积分大于或者等于1，不允许解散！"})
        else
            self:onClickBtnDel1()
        end
    else
        viewMgr:showTip({text = error})
    end
end

function FamilyMainLayer:onClickBtnDel1(...)
    local this = self
    local function callFunc()
        this:DelectJLB(this.family_id, this.owerId)
    end
    local data = {type = 2, title = "提示", content = "是否解散联盟？", callBackSure = callFunc}

    require("hall.tips.CommonTips"):showTips(data)
end

function FamilyMainLayer:DelectJLB(groupId, ownerId)
    local data = {
        owerId = ownerId,
        groupId = groupId
    }
    ReqMgr:request(EVENTNAME.DELETE_GROUP_BY_OWERID, data, handler(self, self.handerDelectJLB), nil, nil, false)
end

function FamilyMainLayer:handerDelectJLB(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if 0 == returnCode then
        self.parents:loadClub()
        self:removeSelf()
        viewMgr:showTip({text = "解散联盟成功"})
    elseif 1 == returnCode then
        viewMgr:showTip({text = "解散联盟失败"})
    end
end

function FamilyMainLayer:onClickBtn_vw(...)
    local visible = self.vw_btns:isVisible()
    self.vw_btns:setVisible(not visible)
end

function FamilyMainLayer:onClickBtnZj(...)
    -- if isOldZhanji == true then
    --     local ScoreRecordView = require("hall.familyCircle.ScoreRecordView").new(self.family_id, self.roleType)
    --     ScoreRecordView:addTo(self)
    -- else
    --     local statistical_qzj = require("hall.familyCircle.statistical_qzj").new(self.family_id, self.roleType)
    --     statistical_qzj:addTo(self)
    -- end
    require("hall.familyCircle.JiLuView").new(self.family_id, self, self.owerId, self.roleType, self.config):addTo(self)
end

function FamilyMainLayer:onClickBtnZhanJi(...)
    -- if isOldZhanji == true then
    local ScoreRecordView = require("hall.familyCircle.ScoreRecordView").new(self.family_id, self.roleType)
    ScoreRecordView:addTo(self)
    -- else
    --     local statistical_qzj = require("hall.familyCircle.statistical_qzj").new(self.family_id, self.roleType)
    --     statistical_qzj:addTo(self)
    -- end
end

function FamilyMainLayer:onClickBtnMember()
    --if self.roleType == 0 or self.roleType == 2 or self.data.isManager == 1 then
    local FamilyMember = require("hall.familyCircle.FamilyMember")
    FamilyMember.new(self.family_id, USER_INFO["uid"], self):addTo(self)
    --else
    --    viewMgr:showTip({text = "您没有权限!"})
    --end
end

function FamilyMainLayer:onClickBtnAddConfig(sender, event)
    FamilyCreateGame.new(self, 1, sender.level, nil, sender.gameType, sender.length, nil, nil):addTo(self)
end

function FamilyMainLayer:onClickBtnreturn(...)
    --require(HallServer_filePath):CLIENT_COMMAND_USER_ONLINE(self.family_id)  --返回大厅一定要给alloc发送自己退回大厅
    SCENENOW["scene"]:queryRoomCardCount()
    self:removeSelf()
end

function FamilyMainLayer:showOldConfig(data, gameType, level)
    local UpdateConfigNameT = function(configId, level)
        UpdateGameName.new(self, level, gameType, configId, self.family_id):addTo(self)
    end
    local updateGameConfig = function(gameType, configId, level)
        FamilyCreateGame.new(self, 2, level, self.gameConfigList[gameType][configId], gameType, nil, configId, self.family_id):addTo(self)
    end

    self.ListViewSelect:removeAllChildren()
    local btn_game = self.btAllConfig:clone()
    GameUtils.setNodeNameBindObj(btn_game)
    btn_game:setTouchEnabled(false)
    btn_game:setBright(false)
    btn_game.Image_4:show()
    btn_game.type = gameType
    btn_game:onClick(
        function(event)
            if not self.isTouth then
                return
            end
            local target = event.target
            local gameType = target.type

            local childs = target:getParent():getChildren()
            for i, v in ipairs(childs) do
                if v.Image_4 then
                    v:setTouchEnabled(true)
                    v:setBright(true)
                    v.Image_4:hide()
                end
            end
            target:setTouchEnabled(false)
            target:setBright(false)
            target.Image_4:show()
            if self.gameConfigList[gameType] then
                self.config_id = nil
                self.checkGameType = gameType
                self:initScrollViewData()
                self:SendServer(0)
                self:getWanFaData()
            end
        end
    )
    self.ListViewSelect:pushBackCustomItem(btn_game)
    local newData = {}
    for k, v in pairs(data) do
        table.insert(newData, v)
    end
    self:wanFaTableSort(newData, 2)
    for k, v in ipairs(newData) do
        if v and next(v) then
            local btn = self.bt_updateGame:clone()
            local btUpdateConfigName = btn:getChildByName("btUpdateConfigName")
            local btSettingConfig = btn:getChildByName("btSettingConfig")
            btn.level = v.level
            btn.gameType = gameType
            btn:getChildByName("text_change"):setString(v.name)
            btUpdateConfigName.configId = v.id
            btUpdateConfigName.gameType = gameType

            if self.owerId == USER_INFO["uid"] then
                btUpdateConfigName:show()
                btSettingConfig:show()
                btUpdateConfigName:onClick(CocosUtil:Bind(UpdateConfigNameT, v.id, v.level))
                btSettingConfig:onClick(CocosUtil:Bind(updateGameConfig, gameType, v.id, v.level))
            else
                btUpdateConfigName:hide()
                btSettingConfig:hide()
            end
            btn.gameType = gameType
            btn.id = v.id
            GameUtils.setNodeNameBindObj(btn)
            btn:onClick(handler(self, self.onClickBtnConfig))
            btn.Image_4:hide()
            self.ListViewSelect:pushBackCustomItem(btn)
        end
    end
    if self.owerId == USER_INFO["uid"] then
        local addBnt = self.btnAddConfig:clone()
        addBnt.level = level
        addBnt.gameType = gameType
        addBnt.length = table.nums(data)
        self.ListViewSelect:pushBackCustomItem(addBnt)
    end
end

function FamilyMainLayer:onClickBtnConfig(event)
    if not self.isTouth then
        return
    end
    local target = event.target
    local gameType = target.gameType
    local configId = target.id
    local childs = target:getParent():getChildren()
    for i, v in ipairs(childs) do
        if v.Image_4 then
            v:setTouchEnabled(true)
            v:setBright(true)
            v.Image_4:hide()
        end
    end
    target:setTouchEnabled(false)
    target:setBright(false)
    target.Image_4:show()

    if self.gameConfigList[gameType][configId] then
        self.config_id = configId
        self.checkGameType = gameType
        self:initScrollViewData()
        self:SendServer(0)
        self:getWanFaData()
    end
end
--add by zzy 2019-7-22  第一次进入界面获取数据
function FamilyMainLayer:getAllChairData(take_data, player_data)
    local table_data_new = {}
    for k, v in pairs(take_data) do
        local temp = {["flag"] = 1, ["config"] = v}
        table.insert(table_data_new, temp)
    end

    if next(player_data) then
        for k, v in pairs(player_data) do
            local temp = {["flag"] = 2, ["config"] = v}
            table.insert(table_data_new, temp)
        end
    end
    return table_data_new
end

function FamilyMainLayer:InitTakeTable(configId, level, gameType)
    local data = self.gameConfigList or {}
    self:showOldConfig(data[gameType] or {}, gameType, level)
end

function FamilyMainLayer:ShowHead(parents, game_data)
    local user_list = game_data.config.user_list
    local tempTable = {}
    local list = {}
    local zhuangList = {}
    for k, v in pairs(user_list) do
        tempTable[json.decode(v).uid] = v
    end
    for k, v in pairs(tempTable) do
        v = json.decode(v)
        table.insert(list, v)
    end
    for seat_id = 1, 20 do
        local head_img = parents:getChildByName("touxiang" .. seat_id)
        if head_img then
            head_img:setVisible(false)
            if head_img.toux then
                head_img.toux:removeAllChildren()
            end
        end
    end
    if GetGameName:isBidTable(game_data.config.level) then
        local zhuangList = {}
        for i=1,2 do
            for idx,v in ipairs(list) do
                if v.zhuan_id == 1 then
                    table.remove(list, idx)
                    table.insert(zhuangList, v)
                    break
                end
            end
        end
        for seat_id = 1, 2 do
            if zhuangList[seat_id] then
                local head_img = parents:getChildByName("touxiang" .. seat_id)
                if head_img ~= nil then
                    head_img:setVisible(true)
                    local data = zhuangList[seat_id]
                    local photoUrl = data.profit
                    local head_toux = head_img:getChildByName("toux")
                    if head_toux then
                        local headSize = head_toux:getWidth()
                        head_toux:setVisible(true)
                        require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_toux, headSize, false, "", true)
                        head_img:setTouchEnabled(false):setVisible(true)
                    else
                        local headSize = head_img:getWidth()
                        require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_img, headSize, false, "", true)
                    end
                end
            end
        end
        for seat_id = 3, 20 do
            if list[seat_id - 2] then
                local head_img = parents:getChildByName("touxiang" .. seat_id)
                if head_img ~= nil then
                    head_img:setVisible(true)
                    local data = list[seat_id - 2]
                    local photoUrl = data.profit
                    local head_toux = head_img:getChildByName("toux")
                    if head_toux then
                        local headSize = head_toux:getWidth()
                        head_toux:setVisible(true)
                        require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_toux, headSize, false, "", true)
                        head_img:setTouchEnabled(false):setVisible(true)
                    else
                        local headSize = head_img:getWidth()
                        require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_img, headSize, false, "", true)
                    end
                end
            end
        end

        return
    end
    for seat_id = 1, 20 do
        if list[seat_id] then
            local head_img = parents:getChildByName("touxiang" .. seat_id)
            if head_img ~= nil then
                head_img:setVisible(true)
                local data = list[seat_id]
                local photoUrl = data.profit
                local head_toux = head_img:getChildByName("toux")
                if head_toux then
                    local headSize = head_toux:getWidth()
                    head_toux:setVisible(true)
                    require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_toux, headSize, false, "", true)
                    head_img:setTouchEnabled(false):setVisible(true)
                else
                    local headSize = head_img:getWidth()
                    require("hall.GameCommon"):getUserHead(photoUrl, "", "", head_img, headSize, false, "", true)
                end
            end
        end
    end
end

function FamilyMainLayer:onClickEnterRoom(event)
    require(GameData_filePath):getLocation()
    local target = event.target
    local endPos = target:getTouchEndPosition()
    local delta = cc.pSub(endPos, target:getTouchBeganPosition())
    local len = cc.pGetLength(delta)
    if len > 20 or endPos.x < 130 then
        return
    end

    local game_data = target._game_data or {}
    if game_data.flag == 1 then
        local config = game_data.config or {}
        local configId = tonumber(config.id)
        local level = tonumber(config.level)
        for _, tableData in ipairs(self.tableDatas or {}) do
            local tableConfig = tableData.config or {}
            local tableInfo = tableConfig.table_info or {}
            local maxSeatCount = tonumber(tableInfo.maxSeatCount) or 0
            local userCount = #(tableConfig.user_list or {})
            local sameConfig = tonumber(tableConfig.id) == configId and tonumber(tableConfig.level) == level
            local hasSeat = maxSeatCount <= 0 or userCount < maxSeatCount
            if sameConfig and tonumber(tableConfig.isFlag or 0) ~= 1 and hasSeat then
                game_data = tableData
                break
            end
        end
    end
    if game_data.flag == 1 then
        local config = game_data.config or {}
        local id = config.id
        local game_data1 = self:getGameConfigListById(id)
        if game_data1 then
            game_data = {["flag"] = 1, ["config"] = game_data1.gameConfig}
        end
    end
    local param = {
        game_name = target._game_name,
        gameWF = target._gameWF,
        game_data = game_data
    }
    local FamilyClickEnterRoom = require("hall.familyCircle.FamilyClickEnterRoom")
    param.roleType = self.roleType
    FamilyClickEnterRoom.new(param, self, self.owerId):addTo(self)
end

function FamilyMainLayer:CreateGameTable(flag, data, total_data, isWatch, isGengXin)
    local watching = JAVA_DOUNIU and tonumber(data.config.level) == 302 and isWatch == 0
    if data.config.isFlag == 1 and not watching then
        viewMgr:showTip({text = "房间人数已满!"})
        return
    end
    print("vvvvvv", flag)
    if require("hall.GameUpdate"):getUpdateStatus() == 0 and isGengXin ~= true then
        local callback = function()
            self:CreateGameTable(flag, data, total_data, isWatch, true)
        end
        local level = data.config.level
        local name = GetGameName:getName(level)
        local path = GetGameName:getPath(level)
        require("hall.GameUpdate"):queryVersionInJoinGame(level, path, 1, name, callback)
        return
    end

    if 1 == flag then
        -- if device.platform ~= "windows" then

        -- end
        if data.config and data.config.ipXz and data.config.ipXz.optionValue == 1 then -- 限制IP
            -- statements
            if USER_INFO["ip"] == nil then
            elseif USER_INFO["ip"] == "" then
            end

            if USER_INFO["ip"] and USER_INFO["ip"] ~= "" then
            else
                viewMgr:showTip({text = "IP限制!"})
                return
            end
        end

        if data.config and data.config.juLi then
            local juLi = 0
            local config1 = data.config1 or {}
            if type(config1.juLi) == "table" then
                juLi = config1.juLi.optionValue
            elseif type(config1.juLi) == "number" then
                juLi = config1.juLi
            end
            if juLi > 0 then
                if USER_INFO["Latitude"] and USER_INFO["Latitude"] ~= 0 and USER_INFO["Longitude"] and USER_INFO["Longitude"] ~= 0 then
                else
                    viewMgr:showTip({text = "距离限制，请打开GPS!"})
                    return
                end
            end
        end

        local create_state = false
        local inviteCode = ""
        local joincallback = function(data)
            require("hall.HallServer"):loginGameNew(data.level, data.tableId, data.gameActivityId, 1)
        end
        local createFunc = function()
            if data.config then
                require(GroupSetting_filePath):create_agent(1, 1, 1, data.config.level, data.config, self.family_id, nil, joincallback)
            end
        end
        createFunc()

        if data.config and data.config.level and data.config.id then
            cc.UserDefault:getInstance():setStringForKey("SelectLevelAndConfigID", data.config.level .. ":" .. data.config.id)
            cc.UserDefault:getInstance():setStringForKey("SpeedjoinViewWanFaName", data.config.name)

            self:initSpeedjoinTxt()
        end
    end

    if 2 == flag then
        local joincallback = function(event)
            local netData = event.netData
            local param = event.param
            local returnCode = tostring(netData.returnCode)
            local data1 = netData.data or {}
            local error = netData.error
            if returnCode == "0" then
                --加入房间
                -- local table_info = json.decode(data.config.table_info)
                local table_info = data.config.table_info or {}
                if data.config.isFlag == 1 and not watching then
                    viewMgr:showTip({text = "房间人数已满!"})
                    return
                end
                cc.UserDefault:getInstance():setStringForKey("SelectLevelAndConfigID", data.config.level .. ":" .. data.config.id)
                cc.UserDefault:getInstance():setStringForKey("SpeedjoinViewWanFaName", data.config.groupName)
                self:initSpeedjoinTxt()
                local juLi = 0

                local config1 = data.config1 or {}
                if config1.juLi then
                    if type(config1.juLi) == "table" then
                        juLi = config1.juLi.optionValue
                    elseif type(config1.juLi) == "number" then
                        juLi = config1.juLi
                    end
                end
                dump(juLi, "ggggggggggggg---")
                local level = tonumber(data1.level) or tonumber(data.config.level)
                local tableId = tonumber(data1.tableId) or tonumber(data.config.table_id)
                local activityId = tonumber(data1.gameActivityId) or tonumber(data1.activityId) or tonumber(table_info.activityId) or tonumber(table_info.gameActivityId)
                if not tableId or not activityId then
                    viewMgr:showTip({text = "room data error"})
                    dump({data1 = data1, config = data.config, table_info = table_info}, "joinFreeGame missing tableId/activityId")
                    return
                end
                require("hall.HallServer"):loginGameNew(level, tableId, activityId, 1, isWatch, juLi)
            else
                viewMgr:showTip({text = error})
            end
        end

        local joinTableInfo = data.config.table_info or {}
        if type(joinTableInfo) == "string" then
            joinTableInfo = json.decode(joinTableInfo) or {}
        end
        local invitationCode = data.config.m_strInviteCode or joinTableInfo.inviteCode
        if not invitationCode or invitationCode == "" then
            local tableId = tonumber(data.config.table_id)
            local activityId = tonumber(joinTableInfo.activityId) or tonumber(joinTableInfo.gameActivityId)
            if tableId and activityId then
                require("hall.HallServer"):loginGameNew(data.config.level, tableId, activityId, 1, isWatch)
                return
            end
            viewMgr:showTip({text = "room data error"})
            dump({config = data.config, table_info = joinTableInfo}, "joinFreeGame missing inviteCode")
            return
        end
        local tbl = {}
        tbl["XYUid"] = USER_INFO.uid
        tbl["invitationCode"] = invitationCode
        tbl["configId"] = data.config.id
        tbl["level"] = data.config.level
        tbl["activityId"] = joinTableInfo.activityId or joinTableInfo.gameActivityId
        tbl["isWatch"] = isWatch or 1
        tbl["type"] =  "P"
        ReqMgr:request(EVENTNAME.joinFreeGame, tbl, joincallback)
    end
end

function FamilyMainLayer:getSuitTabledItem(flag, game_data)
    if game_data then
        local maxPlayerCount = self:getGameNum(game_data)
        game_data.maxPlayerCount = maxPlayerCount
        local node = FamilyTableView:getSuitTabledItem(flag, game_data)
        return node
    end
end

function FamilyMainLayer:getGameNum(game_data)
    local gamePlayerN = 0
    if 1 == game_data.flag then
        gamePlayerN = tonumber(self:getGamePlayerNum(game_data)) or 0
    end
    if 2 == game_data.flag or gamePlayerN == 0 then
        local tableT = json.decode(game_data.config.table_info)
        local tableT = game_data.config.table_info
        if tableT then
            gamePlayerN = tonumber(tableT.maxSeatCount) or 0
        end
    end

    if gamePlayerN == 0 and game_data.config and game_data.config.maxSeatCount then
        gamePlayerN = game_data.config.maxSeatCount.optionValue or 0
    end
    return gamePlayerN
end

--这个问题必须要解决，因为新加的游戏总是会有这个玩家个数出现
function FamilyMainLayer:getGamePlayerNum(data)
    local gameID = data.config.level
    if gameID == 359 then
        local gamePlayerN = data.maxPlayerCount or 2
        --常德字牌 or 娄底跑胡子
        return gamePlayerN
    elseif gameID == 361 then
        return 4
    elseif
        gameID == 325 or gameID == 340 or gameID == 302 or gameID == 392 or gameID == 303 or gameID == 304 or gameID == 305 or gameID == 306 or gameID == 307 or gameID == 317 or gameID == 347 or
            gameID == 308 or
            gameID == 348 or
            gameID == 324 or
            gameID == 320 or
            gameID == 357 or
            gameID == 329 or
            gameID == 358 or
            gameID == 359 or
            gameID == 360 or
            gameID == 361 or
            gameID == 315 or
            gameID == 376 or
            gameID == 612 or
            gameID == 613 or
            gameID == 614 or
            gameID == 345 or
            gameID == 342 or
            gameID == 615 or
            gameID == 616
     then
        --跑得快 or 比鸡 or 明牌抢庄 or 自由上庄 or 轮庄斗牛 or 定庄斗牛 or 疯狂斗牛
        --牛牛上庄 or 诈金花 or 超级三加一 or 快乐麻将 or 320
        local playN = data.config.maxSeatCount.optionValue
        return playN
    end
    return 0
end

function FamilyMainLayer:upDateName(gameType, configId, str)
    self.gameConfigList[gameType][configId].gameConfig.name = str
    self.gameConfigList[gameType][configId].name = str

    local chil = self.ScrollView_1:getChildren()
    for i, v in ipairs(chil) do
        if v.data and v.data.config and v.data.config.id == configId then
            v.gamename:setString(str)
        end
    end
end

function FamilyMainLayer:RequestCludScore()
    local data = {
        uid = USER_INFO["uid"],
        groupId = self.family_id
    }
    ReqMgr:request(EVENTNAME.GOTO_CLUB, data, handler(self, self.goto_club), nil, nil, false)
end

function FamilyMainLayer:goto_club(event)
    local netData = event.netData
    local param = event.param
    local returnCode = netData.returnCode
    local data = netData.data
    local error = netData.error
    if not (returnCode == 0) then
        viewMgr:showTip({text = error})
        return
    end
    if self.updateUserScore then
        self:updateUserScore(data.point)
        self.curPoint = data.point
    end
end

function FamilyMainLayer:updateUserScore(score)
    self.name_jifen:setString(score / 100)
end

function FamilyMainLayer:setTableNodeRundByTableId(data)
    if GetGameName:isBidTable(data.level) then
        return
    end
    local childs = self.ScrollView_1:getChildren()
    for idx, node in ipairs(childs) do
        if node.data.config.table_id == data.table_id then
            local str_2 = ""
            if node.data.config.level == 353 or node.data.config.level == 345 then
                local modetype = 0
                for k, gameConfigList in pairs(self.gameConfigList) do
                    for k1, v1 in pairs(gameConfigList) do
                        -- if v1.gameConfig.modetype == 1 2 then
                        if v1.gameConfig.id == node.data.config.id and v1.gameConfig.modetype then
                            modetype = v1.gameConfig.modetype.optionValue
                            break
                        end
                    end
                    if modetype ~= 0 then
                        break
                    end
                end

                if modetype == 0 then
                    modetype = 1
                end

                if modetype == 1 then
                    local round = node.data.config.table_info.round
                    local currRound = data.currRound
                    node.data.config.currRound = data.currRound

                    if round and currRound and currRound >= 0 then
                        str_2 = "第" .. currRound .. "局"
                    end
                end
            elseif 368 ~= node.data.config.level then
                local round = node.data.config.table_info.round
                local currRound = data.currRound
                node.data.config.currRound = data.currRound
                if round and currRound and currRound >= 0 then
                    str_2 = currRound .. "/" .. round
                end
            end
            node.gameWF:setString(str_2)
            break
        end
    end
end

--以下数据拆分  玩法数据
--gameType
--gameConfigId
--tableId
function FamilyMainLayer:addConfigData(data)
    local gameType = data.gameType
    local id = data.id
    if id and gameType then
        local is = false
        if self.gameConfigList[gameType] then
            if not self.gameConfigList[gameType][id] then
                is = true
            end
            self.gameConfigList[gameType][id] = data
        else
            self.gameConfigList[gameType] = {}
            self.gameConfigList[gameType][id] = data
            is = true
        end

        local checkGameType = self.checkGameType
        local config_id = self.config_id
        if is and config_id == nil and checkGameType == gameType then
            local temp = {["flag"] = 1, ["config"] = data.gameConfig}
            self:addTableNode(temp)
            self:setTableNodesPos(true)
        end
        if checkGameType == gameType then
            self:InitTakeTable(nil, data.level, gameType)
        end
    end
end

function FamilyMainLayer:delConfigData(gameType, configId)
    if self.gameConfigList[gameType] then
        self.gameConfigList[gameType][configId] = nil
    end
    local level = self:getLevelByGameType(gameType)
    local childs = self.ScrollView_1:getChildren()
    for idx, node in ipairs(childs) do
        if node.data.flag == 1 and node.data.config.id == configId then
            node:removeSelf()
            self.config_id = nil
            self:setTableNodesPos(true)
            break
        end
    end
    self:InitTakeTable(nil, level, gameType)
end

function FamilyMainLayer:getWanFaData()
    local gameConfigList = {}
    local checkGameType = self.checkGameType
    local config_id = self.config_id
    if isShowAllTable and checkGameType == 0 then
        for gameType, ConfigList in pairs(self.gameConfigList) do
            if gameType ~= 113 then
                for _, value in pairs(ConfigList) do
                    table.insert(gameConfigList, value)
                end
            end
        end
    elseif config_id then
        local value = self.gameConfigList[checkGameType][config_id]
        if value then
            table.insert(gameConfigList, value)
        end
    elseif checkGameType ~= 0 then
        local tab = self.gameConfigList[checkGameType] or {}
        for idx, value in pairs(tab) do
            table.insert(gameConfigList, value)
        end
    end

    local newTab = {}
    for k, v in pairs(gameConfigList) do
        local temp = {["flag"] = 1, ["config"] = v.gameConfig}
        table.insert(newTab, temp)
    end

    self:wanFaTableSort(newTab, 3)
    for k, data in ipairs(newTab) do
        self:addTableNode(data)
    end
end

function FamilyMainLayer:getWanFaData1()
    local gameConfigList = {}
    for gameType, ConfigList in pairs(self.gameConfigList) do
        if gameType ~= 113 then
            for _, value in pairs(ConfigList) do
                table.insert(gameConfigList, value)
            end
        end
    end
    local newTab = {}
    for k, v in pairs(gameConfigList) do
        local temp = {["flag"] = 1, ["config"] = v.gameConfig}
        table.insert(newTab, temp)
    end
    return newTab
end

function FamilyMainLayer:getLevelByGameType(gameType)
    for key, value in ipairs(levelList[1]) do
        for k1, level in pairs(value) do
            if gameType == k1 then
                return level
            end
        end
    end
    for key, value in ipairs(levelList[2]) do
        for k1, level in pairs(value) do
            if gameType == k1 then
                return level
            end
        end
    end
end

function FamilyMainLayer:DelarWith(pack, typ)
    self:TestData(pack, typ)
end

local function normalizeTableUserList(user_list)
    local list = {}
    for _, userInfo in pairs(user_list or {}) do
        if type(userInfo) == "table" then
            userInfo = userInfo.userinfo or userInfo.userInfo
        end
        if userInfo and userInfo ~= "" then
            table.insert(list, userInfo)
        end
    end
    return list
end

function FamilyMainLayer:TABLE_DATA_NEW_TEMP(data)
    if self.tableIds[data.table_id] then
        return
    end
    self.tableIds[data.table_id] = 1
    local tempItem = {}
    tempItem.isFlag = data.isFlag
    tempItem.club_id = data.club_id
    tempItem.level = data.level
    tempItem.gameType = data.gameType
    tempItem.id = data.id
    tempItem.player_num = data.player_num
    tempItem.player_total = 1
    tempItem.table_id = data.table_id
    tempItem.table_info = data.table_info
    tempItem.groupName = data.groupName
    tempItem.currRound = data.currRound
    tempItem.user_list = normalizeTableUserList(data.user_list)
    tempItem.m_strInviteCode = data.m_strInviteCode
    self:setTableData(tempItem)
    local temp = {["flag"] = 2, ["config"] = tempItem}
    local checkGameType = self.checkGameType
    local config_id = self.config_id

    local is = false
    if checkGameType == 0 then
        if not GetGameName:isBidTable(tempItem.level) then
            is = true
        end
    elseif config_id then
        if config_id == tempItem.id then
            is = true
        end
    elseif checkGameType ~= 0 then
        if checkGameType == tempItem.gameType then
            is = true
        end
    end

    if is then
        table.insert(self.tableDatas, temp)
        self.scrollSort = true
    end
end

function FamilyMainLayer:TestData_News(data)
    if self.config_id and self.config_id == data.id then
        table.insert(self.table_datas, data)
    elseif self.checkGameType == 0 or self.checkGameType == data.gameType then
        table.insert(self.table_datas, data)
    end
end

function FamilyMainLayer:isEndSendData()
    self.isTouth = true
    self:tableSort(self.table_datas, true)
    for i, data in ipairs(self.table_datas) do
        self:TestData_New(data)
    end
    self.table_datas = {}
end

function FamilyMainLayer:TestData_New(data)
    if self.tableIds[data.table_id] then
        return
    end
    self.tableIds[data.table_id] = 1
    local tempItem = {}
    tempItem.isFlag = data.isFlag
    tempItem.club_id = data.club_id
    tempItem.level = data.level
    tempItem.gameType = data.gameType
    tempItem.id = data.id
    tempItem.player_num = data.player_num
    tempItem.player_total = 1
    tempItem.table_id = data.table_id
    tempItem.table_info = data.table_info
    tempItem.groupName = data.groupName
    tempItem.currRound = data.currRound
    tempItem.m_strInviteCode = data.m_strInviteCode
    tempItem.user_list = {}

    self:setTableData(tempItem)
    for k, v in pairs(normalizeTableUserList(data.user_list)) do
        table.insert(tempItem.user_list, v)
    end
    local temp = {["flag"] = 2, ["config"] = tempItem}

    if self.curLevel ~= 0 then
        if tonumber(data.gameType) == tonumber(self.gameTypeIndex) then
            table.insert(self.tableDatas, temp)
        end
    else
        if not GetGameName:isBidTable(tempItem.level) then
            table.insert(self.tableDatas, temp)
        end
    end
end

function FamilyMainLayer:TestData(data, typ)
    if typ == 3 or typ == 6 then --不是正經的數據
        if json.decode(data.userinfo) == nil or not next(json.decode(data.userinfo)) then
            return
        end
    end
    local checkGameType = tonumber(self.checkGameType)
    local is_all = isShowAllTable and self.curLevel == 0
    local is_type_invalid = checkGameType ~= 0 and data.gameType ~= checkGameType
    local is_id_invalid = self.config_id and data.id ~= self.config_id
    if (is_type_invalid or is_id_invalid) and not is_all then
        return
    end
    if self.curLevel == 0 and GetGameName:isBidTable(data.level) then
        return
    end

    if typ == 0 then --創建桌子
        if self.tableIds[data.table_id] then
            return
        end
        self.tableIds[data.table_id] = 1
        local _type = 1
        local tempItem = {}
        tempItem.club_id = data.club_id
        tempItem.is_start = data.is_start
        tempItem.level = data.level
        tempItem.gameType = data.gameType
        tempItem.id = data.id
        tempItem.player_num = 1
        tempItem.player_total = 1
        tempItem.table_id = data.table_id
        tempItem.table_info = data.table_info
        tempItem.groupName = data.groupName
        tempItem.currRound = data.currRound
        tempItem.m_strInviteCode = data.m_strInviteCode
        tempItem.user_list = {}
        self:setTableData(tempItem)
        local temp = {["flag"] = 2, ["config"] = tempItem}
        table.insert(self.tableDatas, temp)
        self.scrollSort = true
        return
    end
    if typ == 3 or typ == 6 then --不是正經的數據
        if json.decode(data.userinfo) == nil or not next(json.decode(data.userinfo)) then
            return
        end
    end
    if typ == 7 then --解散
        self:delTableNode(data.table_id)
    elseif typ == 5 or typ == 6 then --用户退出
        local tempUid = json.decode(data.userinfo).uid
        self:setTableUserImg(data.table_id, data.userinfo, tempUid)
    elseif typ == 4 then --用户加入桌子--加入，座子本來就有
        self:setTableUserImg(data.table_id, data.userinfo)
        self.scrollSort = true
    end
end

function FamilyMainLayer:initScrollView()
    self.ScrollView_1:show()
    self.ScrollView_1:setBounceEnabled(false)
    -- self.ScrollView_1:setBounceEnabled(true)
    self.ScrollView_1:setScrollBarEnabled(false)
    self.ListViewSelect:setScrollBarEnabled(false)
    self.ScrollView_1:addEventListenerScrollView(handler(self, self.addEventListenerScrollView))
    self:initScrollViewData()
end

function FamilyMainLayer:initScrollViewData()
    self.ScrollView_1:removeAllChildren()
    self.ScrollView_1:jumpToLeft()
    self.ScrollTime = os.now()
    self.ScrollType = nil
    self.tableDatas = {}
    self.tableIds = {}
    self.table_datas = {}
    self.dt_idx = 1
    self.dt_beginTime = 1
    self.dt_intervalTime = 0.1
    self.tableInitSize = 10
    self.addTableSize = 8
    self.tableMaxSize = self.tableInitSize
    self.ScrollRefreshSort = 0
end

function FamilyMainLayer:addEventListenerScrollView(target, selector)
    if selector == 10 or self:isMove() then
        if not self.isTouth or self.checkGameType == 113 then
            return
        end
        self:SendServer(1)
        self.initMoveX = nil
    end
end

function FamilyMainLayer:isMove()
    if self.initMoveX == nil then
        self.initMoveX = self.ScrollView_1:getInnerContainerPosition().x
    end
    local posx = self.ScrollView_1:getInnerContainerPosition().x
    if math.abs(posx - self.initMoveX) > 600 then
        return true
    end
    return false
end

function FamilyMainLayer:setTableNodesPos(sortType)
    local childs = self.ScrollView_1:getChildren()
    local size = table.nums(childs)
    if size <= 0 then
        return
    end
    local tableNodeSize = childs[1]:getContentSize()
    -- local tableNodeSize = {width = 342, height = 230}
    local ssize = self.ScrollView_1:getInnerContainerSize()
    local scrollsize = self.ScrollView_1:getContentSize()
    local col = 2
    if tableNodeSize.height > 230 then
        col = 1
    end
    local width = math.ceil(size / col) * tableNodeSize.width
    if width < scrollsize.width then
        width = scrollsize.width
    end
    local pos = self.ScrollView_1:getInnerContainerPosition()
    self.ScrollView_1:setInnerContainerSize(cc.size(width, ssize.height))
    if pos.x * -1 + scrollsize.width > width then
        pos.x = (width - scrollsize.width) * -1
    end
    self.ScrollView_1:setInnerContainerPosition(pos)
    local col = 2

    local childs_1 = {}
    local childs_2 = {}
    -- local asdf = {}
    for i, node in ipairs(childs) do
        if node.data.flag == 1 then
            table.insert(childs_1, node)
        else
            -- if asdf[node.data.config.table_id] then
            -- 	assert(false, "重复!!!")
            -- end
            -- asdf[node.data.config.table_id] = 1
            table.insert(childs_2, node)
        end
    end
    self:wanFaTableSort(childs_1, 1)
    if sortType then
        self:tableSort(childs_2)
    end
    if FamilyTableSort == 1 or FamilyTableSort == 4 then
        childs = {}
        for i, node in ipairs(childs_2) do
            table.insert(childs, node)
        end
        for i, node in ipairs(childs_1) do
            table.insert(childs, node)
        end
    elseif FamilyTableSort == 2 then
        childs = {}
        for i, node in ipairs(childs_2) do
            table.insert(childs, node)
        end
        local curIdx = math.ceil(#childs_2 / 2) + 1
        if curIdx > #childs_2 then
            curIdx = #childs_2
        elseif curIdx < 1 then
            curIdx = 1
        end
        for i, node in ipairs(childs_1) do
            table.insert(childs, curIdx, node)
        end
    elseif FamilyTableSort == 3 then
        childs = {}
        for i, node in ipairs(childs_1) do
            table.insert(childs, node)
        end
        for i, node in ipairs(childs_2) do
            local currRound = node.data.config.currRound or 0
            if currRound >= 1 then
                table.insert(childs, node)
            else
                table.insert(childs, 1, node)
            end
        end
    else
        childs = {}
        for i, node in ipairs(childs_1) do
            table.insert(childs, node)
        end
        for i, node in ipairs(childs_2) do
            table.insert(childs, node)
        end
    end

    for index, node in ipairs(childs) do
        local tableNodeSize = node:getContentSize()
        local idx_x = math.ceil(index / col)
        local x = (idx_x - 1) * tableNodeSize.width
        local y = 0
        local idx_y = index % col
        if idx_y == 0 or GetGameName:isBidTable(node.data.config.level) then
            y = 0
        else
            y = tableNodeSize.height
        end
        if tableNodeSize.height > 230 then -- table.csd
            y = (scrollsize.height - tableNodeSize.height) / 2
            x = (index - 1) * tableNodeSize.width
        end
        node:setPosition(cc.p(x, y))
    end
end

function FamilyMainLayer:setTableNode(game_data, tableNode)
    local str_1 = ""
    local str_2 = ""
    if 1 == game_data.flag then
        if game_data.config.name == nil then
            game_data.config.name = ""
        end
        str_1 = game_data.config.name .. ""
        if game_data.config.level == 325 then
            local tempN = "(15张)"
            if tonumber(game_data.config.wanfa.optionValue) == 1 then
                tempN = "(16张)"
            end
            str_1 = game_data.config.name .. tempN
        end
    elseif 2 == game_data.flag then
        self:ShowHead(tableNode, game_data)
        str_1 = game_data.config.groupName
        if game_data.config.level == 353 or game_data.config.level == 345 then
            local modetype = 0
            for k, gameConfigList in pairs(self.gameConfigList) do
                for k1, v1 in pairs(gameConfigList) do
                    if v1.gameConfig then
                        if v1.gameConfig.id == game_data.config.id and v1.gameConfig.modetype then
                            modetype = v1.gameConfig.modetype.optionValue
                            break
                        end
                    elseif v1.config then
                        if v1.config.id == game_data.config.id and v1.config.modetype then
                            modetype = v1.config.modetype.optionValue
                            break
                        end
                    end
                end
                if modetype ~= 0 then
                    break
                end
            end

            if modetype == 0 then
                modetype = 1
            end
            if modetype == 1 then
                local round = game_data.config.table_info.round
                local currRound = game_data.config.currRound
                if round and currRound and currRound >= 0 then
                    --str_2 = currRound .. "/" .. round
                    str_2 = "第" .. currRound .. "局"
                end
            end
        elseif 368 ~= game_data.config.level then
            local round = game_data.config.table_info.round
            local currRound = game_data.config.currRound
            if round and currRound and currRound >= 0 then
                str_2 = currRound .. "/" .. round
            end
        end
    end

    local btn_game = tableNode.btn_game
    tableNode.gamename:setString(str_1)
    tableNode.gameWF:setString(str_2)
    if GetGameName:isBidTable(game_data.config.level) then
        tableNode.gameWF:setString("99+")
    end
    tableNode.table_id = game_data.config.table_id
    btn_game._game_name = str_1
    btn_game._gameWF = str_2
    btn_game._game_data = game_data
    btn_game:onClick(handler(self, self.onClickEnterRoom), true)
end

function FamilyMainLayer:addTableNode(data)
    if not GetGameName:isBidTable(self.curLevel) and data and data.config and GetGameName:isBidTable(data.config.level) then
        return
    end
    local tableNode = self:getSuitTabledItem(false, data)
    self.ScrollView_1:addChild(tableNode)
    self:setTableNode(data, tableNode)
    tableNode.data = data
    self:setTableNodesPos(true)
end

--tempUid 有值 退出
function FamilyMainLayer:setTableUserImg(table_id, userinfo, tempUid)
    local tmpData
    for idx, tdata in ipairs(self.tableDatas) do
        if tdata.config.table_id == table_id then
            if tempUid then --tempUid 有值 退出
                for k, v in ipairs(tdata.config.user_list) do
                    if tonumber(tempUid) == tonumber(json.decode(v).uid) then
                        table.remove(self.tableDatas[idx].config.user_list, k)
                        tmpData = self.tableDatas[idx]
                        break
                    end
                end
                if tmpData then
                    break
                end
            else --加入
                table.insert(self.tableDatas[idx].config.user_list, userinfo)
                tmpData = self.tableDatas[idx]
                break
            end
        end
    end
    if not tmpData then
        return
    end

    local childs = self.ScrollView_1:getChildren()
    for idx, node in ipairs(childs) do
        if node.data.config.table_id == table_id then
            node.data = tmpData
            self:ShowHead(node, tmpData)
            break
        end
    end
end

function FamilyMainLayer:delTableNode(table_id)
    self.tableIds[table_id] = nil
    for idx, data in ipairs(self.tableDatas) do
        if data.config.table_id == table_id then
            table.remove(self.tableDatas, idx)
            self.dt_idx = self.dt_idx - 1
            break
        end
    end

    local childs = self.ScrollView_1:getChildren()
    for idx, node in ipairs(childs) do
        if node.data.config.table_id == table_id then
            node:removeSelf()
            self:setTableNodesPos(true)
            break
        end
    end
end

function FamilyMainLayer:tableSort(datas, _type)
    table.sort(
        datas,
        function(a, b)
            local aconfig = a
            local bconfig = b
            local acurrRound = aconfig.currRound or 0
            local bcurrRound = bconfig.currRound or 0
            if _type then
            else
                aconfig = a.data.config
                bconfig = b.data.config
                acurrRound = aconfig.currRound or 0
                bcurrRound = bconfig.currRound or 0
            end
            if FamilyTableSort == 4 then
                local atable_info = aconfig.table_info or {}
                local btable_info = bconfig.table_info or {}
                local auser_list = aconfig.user_list or {}
                local buser_list = bconfig.user_list or {}
                local amaxSeatCount = atable_info.maxSeatCount or 1
                local bmaxSeatCount = btable_info.maxSeatCount or 1
                local anum = #auser_list / amaxSeatCount
                local bnum = #buser_list / bmaxSeatCount
                if anum == bnum then
                    return amaxSeatCount > bmaxSeatCount
                else
                    return anum > bnum
                end
            else
                if acurrRound ~= bcurrRound then
                    return acurrRound < bcurrRound
                else
                    local atable_info = aconfig.table_info or {}
                    local btable_info = bconfig.table_info or {}
                    local auser_list = aconfig.user_list or {}
                    local buser_list = bconfig.user_list or {}
                    local amaxSeatCount = atable_info.maxSeatCount or 1
                    local bmaxSeatCount = btable_info.maxSeatCount or 1
                    local anum = #auser_list / amaxSeatCount
                    local bnum = #buser_list / bmaxSeatCount
                    return anum < bnum
                end
            end
        end
    )
end

function FamilyMainLayer:wanFaTableSort(datas, _type)
    if _type == 1 then
        table.sort(
            datas,
            function(a, b)
                local aconfig = a.data.config
                local bconfig = b.data.config
                local acrateTime = aconfig.crateTime or 0
                local bcrateTime = bconfig.crateTime or 0
                return acrateTime < bcrateTime
            end
        )
    elseif _type == 2 then
        table.sort(
            datas,
            function(a, b)
                local aconfig = a.gameConfig
                local bconfig = b.gameConfig
                local acrateTime = aconfig.crateTime or 0
                local bcrateTime = bconfig.crateTime or 0
                return acrateTime < bcrateTime
            end
        )
    elseif _type == 3 then
        table.sort(
            datas,
            function(a, b)
                local aconfig = a.config
                local bconfig = b.config
                local acrateTime = aconfig.crateTime or 0
                local bcrateTime = bconfig.crateTime or 0
                return acrateTime < bcrateTime
            end
        )
    end
end

function FamilyMainLayer:getGameConfigListById(id)
    for k, gameConfigList in pairs(self.gameConfigList) do
        for k1, v1 in pairs(gameConfigList) do
            if k1 == id then
                return v1
            end
        end
    end
    return {}
end

function FamilyMainLayer:setTableData(data)
    if data.gameType == 113 then
        data.table_info = data.table_info or {}
    else
        local serverTableInfo = data.table_info or {}
        if type(serverTableInfo) == "string" then
            serverTableInfo = json.decode(serverTableInfo) or {}
        end
        local gameConfigList = self:getGameConfigListById(data.id)
        local gameConfig = gameConfigList.gameConfig or {}
        -- local gameConfig = self.gameConfigList[data.gameType][data.id].gameConfig
        local tal = {}
        tal.activityId = serverTableInfo.activityId or serverTableInfo.gameActivityId or data.activityId or data.gameActivityId
        tal.inviteCode = serverTableInfo.inviteCode or serverTableInfo.m_strInviteCode or data.m_strInviteCode
        tal.maxSeatCount = gameConfig.maxSeatCount or {}
        tal.maxSeatCount = tal.maxSeatCount.optionValue or 0
        tal.round = gameConfig.round or {}
        tal.round = tal.round.optionValue or 0
        tal.readyPoint = gameConfig.readyPoint or 0
        tal.joinGamePoint = gameConfig.joinGamePoint or 0
        local description = ""
        for idx, value in pairs(gameConfig) do
            if type(value) == "table" and value.isShow == 1 then
                description = description .. value.configName .. value.optionName .. "  "
            end
        end
        tal.description = description
        data.table_info = tal
    end
end

function FamilyMainLayer:update(dt)
    self.dt_beginTime = self.dt_beginTime + dt
    self.time = self.time + dt
    if self.dt_beginTime >= self.dt_intervalTime then
        if self.dt_idx and type(self.tableDatas) == "table" then
            local data = self.tableDatas[self.dt_idx]
            if data then
                local checkGameType = self.checkGameType
                local config_id = self.config_id
                if config_id and config_id == data.config.id then
                    self:addTableNode(data)
                elseif checkGameType ~= 0 and checkGameType == data.config.gameType then
                    self:addTableNode(data)
                elseif checkGameType == 0 then
                    self:addTableNode(data)
                end
                self.dt_beginTime = 0
                self.dt_idx = self.dt_idx + 1
                if self.scrollSort then --是否刷新排序
                    self:setTableNodesPos(true)
                    self.scrollSort = false
                else
                    self:setTableNodesPos(false)
                end
            end
        end
    end
end

function FamilyMainLayer:updateTableSum(allNum)
    if self.roleType and self.roleType == 0 then
        if self.gameNum then
            self.gameNum:setVisible(true)
            self.gameNum:setString("总桌子数：" .. allNum)
            self.gameNum:setVisible(false)
        end
    end
end

function FamilyMainLayer:onChangeBg()
    local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType" .. USER_INFO["level"], 1)
    -- self.bg:loadTexture("hall/res/FriendScircle/image/show_bg_"..str..".png")
end

function FamilyMainLayer:onChangeTableBg()
    -- self.ListViewSelect:removeAllChildren()
    -- if PreviousLevel ~= 0 then
    --     self.checkGameType = k
    --     self.config_id = nil
    --     self:InitTakeTable(nil, v, k)
    -- else
    --     self.config_id = nil
    --     self.checkGameType = 0
    -- end
    -- self:initScrollViewData()
    -- self:SendServer(0)
    -- self:getWanFaData()

    if self.curCheckTableNode then
        self.curCheckTableNode.select = false
        self:onClickCheckbox({target = self.curCheckTableNode})
    else
        local chids = self.left_listView:getChildren()
        chids[1].select = false
        self:onClickCheckbox({target = chids[1]})
    end
end

function FamilyMainLayer:onExit()
    ReqMgr:delHandle("FamilyMainLayer", EVENTNAME)
    gameTypeTemp = nil
end

return FamilyMainLayer
