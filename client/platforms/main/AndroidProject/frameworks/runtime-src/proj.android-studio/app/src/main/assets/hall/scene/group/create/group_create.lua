local Scene = class("Scene")

--当前界面
local createGroupCsb

--当前游戏的初始配置
local nowSelectGameConfig = {}

local gameConfigCache = {}
--记录最终提交的参数
local parameter = {}

local GroupStart_arr = {}
local GroupHeight_arr = {}

local content_ly

local enabledAddColor = false

local tl_gameType = 1
local tl_gameTypeIndex = 1  
local tl_gameScoreIndex = 1

--特别处理，房卡扣卡和AA扣卡的显示处理
local round_circle_select_arr = {}
local roundOption = {}
--获取当前游戏AA制是否为默认选中
local nowgame_pay_type

--特别处理，人数不同，扣卡不同处理
local nowmaxSeatCount

local synchroTable = {}
local single_selection_table = {}
-- local gameTypeList = nil
local selectedColor = cc.c3b(0xFB,0xEC,0x01)
local unSelectedColor = cc.c3b(0xBF,0xBF,0xBF)

local CreateGroupCsb_filePath = "hall/res/csb/group/group_create.csb"

local CircleSelectCsb = "hall/res/csb/group/circle_select.csb"
local TickSelectCsb = "hall/res/csb/group/tick_select.csb"
local Drop_down_csb = "hall/res/csb/group/menu_drop_down.csb"

function Scene:CreateScene(GameMode, clubId, gameAttribute, setClubFloorConfig, floorId)

    if shieldCreateRoom == true then

        local uidExist = false

        if canCreateRoomPlayers then
            for _,uid in ipairs(canCreateRoomPlayers) do
                if uid == USER_INFO["uid"] then
                    uidExist = true
                    break
                end
            end
        end

        if uidExist == false then
            return require(CommonTips_filePath):showTips("提示", "", 3, "请联系微信客服创建房间！")
        end 
    end

    nowSelectGameConfig = {}
    parameter = {}

    --获取界面
    self:removeScene()
    
    createGroupCsb = cc.CSLoader:createNode(CreateGroupCsb_filePath):setName("createGroupCsb"):addTo(SCENENOW["scene"],501)
    -- createGroupCsb:setScale(1280/1920)  --:setName("createGroupCsb")

    -- SCENENOW["scene"]:addChild(createGroupCsb, 501)

    tl_gameScoreIndex = 1

    --头部区域
    local top_base = createGroupCsb:getChildByName("top_base")

    --提示语
    local notice_tt = top_base:getChildByName("notice_tt")

    local config_ly = createGroupCsb:getChildByName("config_ly")

    --返回按钮
    local btn_close = config_ly:getChildByName("btn_close")
    btn_close:addTouchEventListener(

        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                self:removeScene()
            end
        end)


    --用户昵称
    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"], 6)
    local lbNick = top_base:getChildByName("txt_nick")
    lbNick:setString(strNick)

    --用户id
    local userId = tostring(USER_INFO["uid"])
    local lbId = top_base:getChildByName("txt_nick_0")
    lbId:setString("ID: " .. userId)

    --房卡
    local btn_add_score = top_base:getChildByName("fangka_ly")
    local txt_score = btn_add_score:getChildByName("fangka_tt")
    if USER_INFO["cardCount"] ~= nil then
        txt_score:setString(tostring(USER_INFO["cardCount"]))
    else
        txt_score:setString("")
    end

    --积分
    local jifen_ly = top_base:getChildByName("jifen_ly")
    local jifen_tt = jifen_ly:getChildByName("jifen_tt")
    if USER_INFO["jifen"] ~= nil then
        jifen_tt:setString(tostring(USER_INFO["jifen"]))
    else
        jifen_tt:setString("")
    end

    if  isiOSVerify then
        btn_add_score:setVisible(false)
        jifen_ly:setVisible(false)
        notice_tt:setVisible(false)
    end

    --创建房间按钮
    local create_bt = config_ly:getChildByName("create_bt")

    create_bt:addTouchEventListener(function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                if  parameter["level"] == nil then
                    --dump(parameter,"setSingleGameViewgameConfig_parameter")
                    require(CommonTips_filePath):showTips("提示", "", 3, "请先选择游戏")
                    return
                end

                local remember_nowSelectGameConfig = ""
                if next(nowSelectGameConfig) ~= nil then
                    
                    --记录当前游戏选择的游戏配置
                    remember_nowSelectGameConfig = json.encode(nowSelectGameConfig)
                    --dump(remember_nowSelectGameConfig,"记下上次选择的游戏配置")

                    cc.UserDefault:getInstance():setStringForKey("rememberGameConfig"..parameter["gameName"], remember_nowSelectGameConfig)

                    --记录当前游戏为最后创建的游戏，记录下游戏level
                    -- cc.UserDefault:getInstance():setStringForKey("lastCreateGameName", self.selected_game_name)
                    -- cc.UserDefault:getInstance():setStringForKey("lastCreateBigGameName", self.selected_big_game_name)
                    -- cc.UserDefault:getInstance():setIntegerForKey("lastCreateGameMode", self.GameMode)          
                    
                    --remember_nowSelectGameConfig--游戏配置，打开桌子列表后就有了
                end

                self:removeScene()

                if  self.GameMode == 1 then  --组局场(开完马上加入房间)

                    for k,v in pairs(roundOption) do
                        
                        if parameter["round"] and v.optionValue == parameter["round"].optionValue then

                            if nowgame_pay_type == "AA" then
                                parameter["cardCount"] = v.aa_cardCount

                            else

                                if nowmaxSeatCount ~= nil then

                                    local key_cardcount = tostring(nowmaxSeatCount) .. "_people_cardCount"
                                    if v[key_cardcount] ~= nil then
                                        parameter["cardCount"] = v[key_cardcount]
                                    else
                                        parameter["cardCount"] = v.cardCount
                                    end

                                else

                                    parameter["cardCount"] = v.cardCount

                                end
                                
                            end

                        end

                    end

                    if  parameter["special"] and string.find(parameter["special"]["optionValue"],"1") then
                        local createFunc = function(password) require(GroupSetting_filePath):create(1, 1, 1, parameter["level"], parameter, nil, password) end
                        require(JoinGroup_filePath):showInputPasswordScene("create",createFunc)
                    else 
                        require("hall.GameCommon"):landLoading(true)  --房卡场一点创建房间就进入LOADING
                        require(GroupSetting_filePath):create(1, 1, 1, parameter["level"], parameter)
                    end

                elseif  self.GameMode == 2 then --联盟创建

                    for k,v in pairs(roundOption) do
                        
                        if parameter["round"] and v.optionValue == parameter["round"].optionValue then

                            if nowgame_pay_type == "AA" then
                                parameter["cardCount"] = v.aa_cardCount

                            else

                                if nowmaxSeatCount ~= nil then

                                    local key_cardcount = tostring(nowmaxSeatCount) .. "_people_cardCount"
                                    if v[key_cardcount] ~= nil then
                                        parameter["cardCount"] = v[key_cardcount]
                                    else
                                        parameter["cardCount"] = v.cardCount
                                    end

                                else

                                    parameter["cardCount"] = v.cardCount

                                end
                                
                            end

                        end

                    end

                    if setClubFloorConfig then
                        local clubView = require("hall.view.clubView.clubView")
                        clubView:saveData(clubId, parameter, floorId)
                        self:removeScene()
                        return
                    end

                    if  parameter["special"] and string.find(parameter["special"]["optionValue"],"1") then
                        local createFunc = function(password) require(GroupSetting_filePath):create_agent(1, 1, 1, parameter["level"], parameter,clubId, password) end
                        require(JoinGroup_filePath):showInputPasswordScene("create",createFunc)

                    else
                        require(GroupSetting_filePath):create_agent(1, 1, 1, parameter["level"], parameter,clubId)
                    end

                elseif  self.GameMode == 0 then  --金币场
                    --更新金币场房间列表的标签

                    if  parameter["special"] and string.find(parameter["special"]["optionValue"],"1") then

                        local createFunc = function(password)

                            require(NetworkLoadingView_filePath):showLoading("创建房间中")
                            require("hall.scene.group.join.table_list"):updateTab(tl_gameTypeIndex,tl_gameScoreIndex)       
                            require(GroupSetting_filePath)
                            :create_agent(1, parameter["baseChip"], 1, parameter["level"], parameter, nil, password) 
                        end

                        require(JoinGroup_filePath):showInputPasswordScene("create",createFunc)  

                    else
                        require(NetworkLoadingView_filePath):showLoading("创建房间中")
                        require("hall.scene.group.join.table_list"):updateTab(tl_gameTypeIndex,tl_gameScoreIndex)
                        require(GroupSetting_filePath):create_agent(1, parameter["baseChip"], 1, parameter["level"], parameter)
                    end

                end

            end
        end)
    
    local join_bt = config_ly:getChildByName("join_bt") 
    join_bt:addTouchEventListener(function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                if bm.notCheckReload == 1 then
                    local callback = function (pack)
                        local tid = tonumber(pack.tid) or 0
                        if tid <= 0 then
                            require(JoinGroup_filePath):showScene()
                        end
                    end

                    self:delEvent()
                    self.eventId = GameEvent:addListen("ReceiveUserGameStatus", callback)
                    require(HallServer_filePath):cliUserGameStatus()
                    -- require("hall.groudgamemanager"):requestGroupStatus(callback)
                else
                    require(JoinGroup_filePath):showScene()
                end
            end

        end)
    
    if  GameMode ~= nil then
        self.GameMode = GameMode
        if  GameMode == 1 or GameMode == 3  then
            join_bt:setVisible(true)
        else
            join_bt:setVisible(false)
        end

    end

    -- self:showGameConfig(clubId)
    self:showGameList(gameAttribute)
end

function Scene:delEvent()
    if self.eventId then
        GameEvent:delListen(self.eventId)
        self.eventId = nil
    end
end


function Scene:removeScene()
    self:delEvent()
    local s = SCENENOW["scene"]:getChildByName("createGroupCsb")
    if s then
        s:removeSelf()
    end

    gameConfigCache = {}
end


--生成游戏列表
function Scene:showGameList(gameAttribute)

    --dump(bm.gameList, "-----游戏列表-----")
    if  tolua.isnull(createGroupCsb) then
        return
    end

    local gamelist_sv = createGroupCsb:getChildByName("gamelist_sv")

    local function touchButtonEvent(level)
        tl_gameTypeIndex = level
        if  gameConfigCache[level] then
            self:setSingleGameView(gameConfigCache[level])
        else
            require(Request_filePath):getCreateGroupGameConfigForGoldGame(level)
        end
    end

    local function touchBigButtonFunc()
        self:clearConfigView()
    end 

    local GameList = require("hall.GameList")
    gameAttribute = gameAttribute or {}
    GameList:addGamesToListView(gamelist_sv,self.GameMode,touchButtonEvent,touchBigButtonFunc, nil, gameAttribute[2], gameAttribute[1]) 
end


function Scene:setSingleGameView(gameConfig)
    nowSelectGameConfig = gameConfig    
    
    dump(gameConfig,"setSingleGameViewgameConfig")

    if  gameConfigCache[gameConfig.level] == nil then
        gameConfigCache[gameConfig.level] = gameConfig
    end

    parameter = {}
    
    -- parameter["gameType"] = gameConfig.gameType
    --记录当前游戏的游戏id
    parameter["gameId"] = gameConfig.gameId
    --记录当前游戏对应的等级
    parameter["level"] = gameConfig.level
    --记录当前游戏对应的底注
    parameter["diZhu"] = gameConfig.dizhu
    --记录当前游戏对应的筹码
    parameter["chouMa"] = gameConfig.chouMa
    --记录当前游戏对应的大类名
    parameter["gameName"] = gameConfig.gameName
    --创建金币场时选择的底注
    parameter["baseChip"] = 1
    
    --dump(parameter,"setSingleGameViewgameConfig_level")

    self:getMemoryGameConfig(parameter["gameName"])
    
    self:showConfigView(true)

end

function Scene:getMemoryGameConfig(gameName)

    local level = level or parameter["level"]

    --本地保存的当前选中游戏的记忆配（根据level区别储存）
    local rememberGameConfig = json.decode(cc.UserDefault:getInstance():getStringForKey("rememberGameConfig"..gameName,""))

    if rememberGameConfig and next(rememberGameConfig)~=nil then 
        
        --dump(rememberGameConfig,"rememberGameConfig")
        local memoryTable = {}
         
        -- local nowLevel = 0    --校验当前游戏配置的level和选中的游戏的level是否相同（应对otherGame)
        
        local current_configShowName = ""
        local function loopGetValue(object) 

            if  type(object) ~= "table" then  
                return  object         
            end 

            -- if nowLevel== 0 and object.level then
            --    nowLevel = object.level
            -- end
         
            local NewTable = {}  
            for k, v in pairs(object) do  
                
                if type(v) == "table" then
                    if  v["configShowName"] then
                        current_configShowName = v["configShowName"]
                    end

                    if  v["optionName"]  then  -- and v["optionName"]
                        -- --dump(v,"loopGetValue")   
                        memoryTable[v.optionName .. current_configShowName] = v["isDefualt"]
                    end
                end

                NewTable[loopGetValue(k)] = loopGetValue(v)
            end    

            return setmetatable(NewTable, getmetatable(object))

        end 


        local function loopSetValue(object) 

            if  type(object) ~= "table" then  
               return  object         
            end 

            -- if nowLevel== 0 and object.level then
            --    nowLevel = object.level
            -- end

            local NewTable = {}  
            for k, v in pairs(object) do
                
                if type(v) == "table" then

                    if  v["configShowName"] then
                        current_configShowName = v["configShowName"]
                    end

                    if   v["optionName"]  then  --and v["optionName"]
                         if  memoryTable[v.optionName .. current_configShowName] then
                             -- --dump(memoryTable[v.optionName .. current_configShowName],"memoryTable[v.optionName .. current_configShowName]")
                             v["isDefualt"]  = memoryTable[v.optionName .. current_configShowName]
                             -- --dump(v,"loopSetValue")
                         end
                    end
                end

                NewTable[loopSetValue(k)] = loopSetValue(v)

            end    

            return setmetatable(NewTable, getmetatable(object))

        end 

        loopGetValue(rememberGameConfig)                   --创建中介数组（一维）
        nowSelectGameConfig = loopSetValue(nowSelectGameConfig)   --接收数组的值
        
        -- --dump(memoryTable,"memoryTable")

    end

end


function Scene:copyAndPasteTable(gameName)

    --本地保存的当前选中游戏的记忆配（根据level区别储存）
    local rememberGameConfig = json.decode(cc.UserDefault:getInstance():getStringForKey("rememberGameConfig"..gameName,""))

    if rememberGameConfig and next(rememberGameConfig)~=nil then 
        
        local memoryTable = {}
        local currentHierarchy = 0

        local function loopGetValue(object) 

            if  type(object) ~= "table" then  
                return  object         
            end 
         
            local NewTable = {}  
            for k, v in pairs(object) do  
                
                if  type(v) == "table" then
                    if  v["optionName"] then
                        memoryTable[currentHierarchy] = v["isDefualt"]
                    end
                    currentHierarchy = currentHierarchy + 1
                end

                NewTable[loopGetValue(k)] = loopGetValue(v)
            end    

            return setmetatable(NewTable, getmetatable(object))
        end 

        local pasteCurrentHierarchy = 0
        local function loopSetValue(object) 

            if  type(object) ~= "table" then  
                return  object         
            end 

            local NewTable = {}  
            for k, v in pairs(object) do
                
                if type(v) == "table" then
                    if  memoryTable[pasteCurrentHierarchy] then
                        v["isDefualt"]  = memoryTable[pasteCurrentHierarchy]
                    end
                    pasteCurrentHierarchy = pasteCurrentHierarchy + 1
                end

                NewTable[loopSetValue(k)] = loopSetValue(v)
                
            end    

            return setmetatable(NewTable, getmetatable(object))

        end 

        loopGetValue(rememberGameConfig)                   --创建中介数组（一维）
        nowSelectGameConfig = loopSetValue(nowSelectGameConfig)   --接收数组的值

    end
end



function Scene:updateConfig(config,configName,option,updateType,checkBoxType)
    
    -- dump(config,"updateConfig_config")  --选项大类英文名
    -- dump(configName,"updateConfig_configName") --选项大类中文名
    -- dump(optionName,"updateConfig_optionName") --选中的选项中文名

    -- dump(option,"updateConfig_option") --选中的选项内容
                                 
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

        parameter[config] = select

    elseif checkBoxType == 0 or checkBoxType == 3 then

        local select = {}
        select["optionName"] = optionName
        select["optionValue"] = optionValue
        select["isShow"] = isShow
        select["configName"] = configName

        parameter[config] = select

     elseif checkBoxType == 2 then

        local select = {}
        select["optionName"] = optionName
        select["optionValue"] = optionValue
        select["isShow"] = isShow
        select["configName"] = configName

        --配置项为底分时，把选项值放到
        if  config == "baseChip" then
            parameter["baseChip"] = tonumber(optionValue)
        else
            parameter[config] = select
        end  
    end


    SCENENOW["scene"]:performWithDelay(function()

        if newRelateConfigArr then

            local typ = newRelateConfigArr["type"]
            local target = newRelateConfigArr["target"]
            local expectedOptionValue = newRelateConfigArr["optionvalue"]
            local expectedoptionName = newRelateConfigArr["optionName"]

            if typ == "synchro" then   --同步

                synchroTable[target] = {}
                synchroTable[target]["from"] = config
                synchroTable[target]["fromExpectedValue"] = optionValue

                parameter[target]["optionValue"] = expectedOptionValue
                parameter[target]["optionName"] = expectedoptionName

                self:updateSelection(target,expectedOptionValue)
            end

        end

        for target,v in pairs(synchroTable) do
            if v["from"] == config then
                
                -- dump(parameter[config]["optionValue"],"synchroTable_item_2")
                local fromExpectedValue = v["fromExpectedValue"]
                if  string.find(tostring(parameter[config]["optionValue"]),tostring(fromExpectedValue)) then
                    synchroTable[target]["canChange"] = false
                else
                    synchroTable[target]["canChange"] = true
                end
            end
        end

    end,0.01)

end

function Scene:updateSelection(config,expectedOptionValue)

    -- dump(expectedOptionValue,"expectedOptionValue")

    for  _,checkbox in pairs(single_selection_table[config]) do
        dump(checkbox.optionValue,"updateSelection_optionValue")
        if checkbox.optionValue ~= expectedOptionValue then
            checkbox:setSelected(false)  
            local select_tt_1 = checkbox:getParent():getChildByName("select_tt_1")
            local select_tt_2 = checkbox:getParent():getChildByName("select_tt_2")
            select_tt_1:setTextColor(unSelectedColor) 
            select_tt_2:setTextColor(unSelectedColor)
        else
            checkbox:setSelected(true)  
            local select_tt_1 = checkbox:getParent():getChildByName("select_tt_1")
            local select_tt_2 = checkbox:getParent():getChildByName("select_tt_2")
            select_tt_1:setTextColor(selectedColor) 
            select_tt_2:setTextColor(selectedColor)
        end
    end

end

function Scene:clearConfigView()

    if  tolua.isnull(createGroupCsb) then
        return
    end
    
    local config_ly = createGroupCsb:getChildByName("config_ly")
    local config_sv = config_ly:getChildByName("config_sv")
    --定义选项区域
    local content_ly = config_sv:getChildByName("content_ly")
    content_ly:removeAllChildren()

    parameter["level"] = nil
end

--生成配置界面
function Scene:showConfigView(isFirst)

    --dump(nowSelectGameConfig, "-----当前游戏配置情况-----")
     
    self.multiChoseOption = {}

    if  tolua.isnull(createGroupCsb) then
        return
    end

    
    local config_ly = createGroupCsb:getChildByName("config_ly")

    local config_sv = config_ly:getChildByName("config_sv")

    --定义选项区域
    local content_ly = config_sv:getChildByName("content_ly")
    content_ly:removeAllChildren()

    isFirst = isFirst or false

    --记录每组分类高度数组
    local groupHeight_arr = {}

    --获取当前游戏配置
    local gameConfig = nowSelectGameConfig.gameConfig
    if  gameConfig == nil then
        return
    end

    local additionalOptionNum = 0

    local curSelPeopleNum = 0

    --dump(gameConfig, "------配置分类-----")
    
    local single_select_tag = -1
    single_selection_table = {}

    --特别处理，房卡扣卡和AA扣卡的显示处理
    round_circle_select_arr = {}
    roundOption = {}
    --获取当前游戏AA制是否为默认选中
    nowgame_pay_type = nil
    for gameConfig_p,v in pairs(gameConfig) do
        
        local configGroup = v.configGroup
        for configGroup_p,v in ipairs(configGroup) do

            local config = v.config
            if config == "pay_type" then

                local configOption = v.configOption
                for configOption_p,v in pairs(configOption) do

                    if v.isDefualt == 1 then
                        nowgame_pay_type = v.optionValue
                    end

                end
                
            end

        end

    end
    --dump(nowgame_pay_type, "-----nowgame_pay_type-----")

    --获取当前人数的默认人数
    nowmaxSeatCount = nil
    for gameConfig_p,v in pairs(gameConfig) do
        
        local configGroup = v.configGroup
        for configGroup_p,v in ipairs(configGroup) do

            local config = v.config
            if config == "maxSeatCount" then

                local configOption = v.configOption
                for configOption_p,v in pairs(configOption) do

                    if v.isDefualt == 1 then
                        nowmaxSeatCount = v.optionValue
                    end

                end
                
            end

        end

    end
    --dump(nowmaxSeatCount, "-----nowmaxSeatCount-----")

    for gameConfig_p,v in ipairs(gameConfig) do

        --添加配置分类显示区域
        local class_ly = ccui.Layout:create()
        class_ly:setAnchorPoint(cc.p(0,1))
        class_ly:setContentSize(cc.size(0, 0))
        class_ly:setTouchEnabled(false) 
        content_ly:addChild(class_ly,999-gameConfig_p)

        --定义配置分类显示区域高度
        local class_ly_height = 0

        --获取配置分类名
        local configShowName = v.configShowName

        groupHeight_arr[gameConfig_p + additionalOptionNum] = {}

        local configShowName_tt = config_ly:getChildByName("configShowName_tt"):clone():addTo(class_ly)
        configShowName_tt:setPosition(-45, -5):setString(configShowName)
        
        --获取配置选项组
        local configGroup = v.configGroup

        for configGroup_p,v in ipairs(configGroup) do
           
            --每一个配置分类的LAYOUT
            local group_ly = ccui.Layout:create()
            group_ly:setAnchorPoint(cc.p(0,1))
            group_ly:setContentSize(cc.size(0, 0))
            group_ly:setTouchEnabled(false)
            class_ly:addChild(group_ly)

            local config = v.config  ----配置组名,用作key---
            single_selection_table[config] = {}
            local isCheckBox = v.isCheckBox  --0为单选，1为多选，2为下拉框，3为隐藏 4为无用但保留选项

            local configOption = v.configOption
            if  config == "round" then
                roundOption = configOption
            end

            local configNums = #configOption
            if  configNums > 0 then
                 
                self.multiChoseOption[config] = {}

                local oneLineItemCount = 3
                local begin_x = 86
                local fix_x,fix_y = 0,20

                if  isCheckBox == 0 then

                    if config == "round" then 
                        oneLineItemCount = 3
                    elseif configNums >= 4 then
                        oneLineItemCount = 4
                        fix_x = -70
                    end
                elseif  isCheckBox == 1 then
                    oneLineItemCount = 3
                elseif  isCheckBox == 2 then
                    oneLineItemCount = 999
                elseif  isCheckBox == 3 then
                elseif  isCheckBox == 4 then  
                end    

                if  v.oneLineItemCount then
                    oneLineItemCount = v.oneLineItemCount
                end

                --根据选项数计算显示区域行高
                if  isCheckBox ~= 3 and isCheckBox ~= 4 then
                    local  line = math.ceil(#configOption / oneLineItemCount)
                    -- if  line >  math.ceil(line) then
                    --     line = math.floor(line) + 1
                    -- end

                    local group_ly_height = 66 * line  --60是行高

                    groupHeight_arr[gameConfig_p + additionalOptionNum][configGroup_p] = group_ly_height

                    group_ly:setPosition(0, class_ly_height * -1)

                    class_ly_height = class_ly_height + group_ly_height
                end
 

                if isCheckBox == 0 then

                    for configOption_p,v in pairs(configOption) do
                        
                        -- dump(v,"配置细胞_单选框")
                        --定义单选项
                        local circle_select = cc.CSLoader:createNode(CircleSelectCsb)
                        group_ly:addChild(circle_select)

                        if config == "round" then 
                            table.insert(round_circle_select_arr, circle_select)
                        end

                        local select_ly = circle_select:getChildByName("select_ly")
                        -- select_ly:setTouchEnabled(false)
                        -- select_ly:setAnchorPoint(cc.p(0,1))
                        -- select_ly:setScale(0.9)

                        --按顺序排列显示选项
           
                        local selectionIndex = configOption_p - 1
                        local x = (select_ly:getContentSize().width + fix_x) * (selectionIndex % oneLineItemCount) + begin_x
                        local y = (select_ly:getContentSize().height + fix_y) * math.floor(selectionIndex / oneLineItemCount) * -1                    
                        select_ly:setPosition(cc.p(x, y))

                        circle_select:setVisible(true)

                        --设置选项显示内容
                        local select_im = select_ly:getChildByName("select_im")
                        select_im:setSelected(false)
                        select_im:setTag(configOption_p)
                        select_im.optionValue = v.optionValue

                        table.insert(single_selection_table[config],select_im)

                        local select_tt_1 = select_ly:getChildByName("select_tt_1")
                        select_tt_1:setString(v.optionName)
                        
                        local select_tt_2 = select_ly:getChildByName("select_tt_2")
                        select_tt_2:setString("")

                        if not isiOSVerify then

                            if config == "round" then

                                if nowmaxSeatCount ~= nil then
                                    --假如当前房间最大人数字段存在

                                    if nowgame_pay_type == "AA" then

                                        if v.aa_cardCount ~= nil then
                                            select_tt_2:setString("（房卡X" .. v.aa_cardCount .. "）")
                                        end

                                    else

                                        local key_cardcount = tostring(nowmaxSeatCount) .. "_people_cardCount"
                                        --dump(key_cardcount, "-----key_cardcount-----")
                                        if key_cardcount ~= nil and v[key_cardcount] ~= nil then

                                            select_tt_2:setString("（房卡X" .. v[key_cardcount] .. "）")

                                        else

                                            if v.cardCount ~= nil then
                                                select_tt_2:setString("（房卡X" .. v.cardCount .. "）")
                                            end

                                        end

                                    end


                                else
                                    --假如当前房间最大人数字段不存在

                                    if nowgame_pay_type == "fangka" then

                                        if v.cardCount ~= nil then
                                            select_tt_2:setString("（房卡X" .. v.cardCount .. "）")
                                        end

                                    elseif nowgame_pay_type == "AA" then

                                        if v.aa_cardCount ~= nil then
                                            select_tt_2:setString("（房卡X" .. v.aa_cardCount .. "）")
                                        end

                                    else

                                        if v.cardCount ~= nil then
                                            select_tt_2:setString("（房卡X" .. v.cardCount .. "）")
                                        end

                                    end

                                end

                            end

                            if config == "peopleNum" then
                                
                                if nowgame_pay_type == "fangka" then

                                    if v.cardCount ~= nil then
                                        select_tt_2:setString("（房卡X" .. v.cardCount .. "）")
                                    end

                                elseif nowgame_pay_type == "AA" then

                                    if v.aa_cardCount ~= nil then
                                        select_tt_2:setString("（房卡X" .. v.aa_cardCount .. "）")
                                    end

                                else

                                    if v.cardCount ~= nil then
                                        select_tt_2:setString("（房卡X" .. v.cardCount .. "）")
                                    end

                                end

                            end

                        end
                        
                        if  v.isDefualt == 1 then
                            select_tt_1:setTextColor(selectedColor)
                            select_tt_2:setTextColor(selectedColor)
                            select_im:setSelected(true)
                            --记录默认上传参数
                            self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)

                            --纪录当前人数
                            if config == "peopleNum" then
                                curSelPeopleNum = v.optionValue
                            end

                        else 
                            select_tt_1:setTextColor(unSelectedColor) 
                            select_tt_2:setTextColor(unSelectedColor)
                            select_im:setSelected(false)
                        end
                        
                        select_tt_1:setTouchEnabled(true)
                        select_tt_1:addTouchEventListener(function(sender,event)

                            --dump(event,"单选框文字1")         

                            --触摸结束
                            if event == TOUCH_EVENT_ENDED then
                                require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
                                    
                                if synchroTable[config] then
                                    dump(synchroTable[config],"synchroTable[config]")
                                    if  synchroTable[config]["canChange"] ~= true then
                                        return
                                    end
                                end

                                if  select_im:isSelected() then
                                    select_im:setSelected(true)
                                    select_tt_1:setTextColor(selectedColor)
                                    select_tt_2:setTextColor(selectedColor)
                                else
                                   --重置当前选项组的选中清空
                                    local configOption = nowSelectGameConfig.gameConfig[gameConfig_p].configGroup[configGroup_p].configOption
                                    for k,v in pairs(configOption) do
                                        v.isDefualt = 0
                                    end

                                    v.isDefualt = 1
                                    --dump(configOption,"重置当前选项组的选中清空configOption")

                                    for  _,checkbox in pairs(single_selection_table[config]) do
                                        if  checkbox:getTag() ~= sender:getTag() then
                                            checkbox:setSelected(false)  
                                            local select_tt_1 = checkbox:getParent():getChildByName("select_tt_1")
                                            local select_tt_2 = checkbox:getParent():getChildByName("select_tt_2")
                                            select_tt_1:setTextColor(unSelectedColor) 
                                            select_tt_2:setTextColor(unSelectedColor)
                                        end
                                    end

                                    select_im:setSelected(true)
                                    select_tt_1:setTextColor(selectedColor)
                                    select_tt_2:setTextColor(selectedColor)

                                    self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)

                                    --特殊处理房主扣卡和AA制扣卡
                                    if config == "pay_type" then

                                        --dump(v.optionValue, "-----pay_type-----")
                                        nowgame_pay_type = v.optionValue

                                        for k,circle_select in pairs(round_circle_select_arr) do

                                            local select_ly = circle_select:getChildByName("select_ly")
                                            local select_tt_2 = select_ly:getChildByName("select_tt_2")

                                            if v.optionValue == "fangka" then

                                                if nowmaxSeatCount ~= nil then

                                                    local key_cardcount = tostring(nowmaxSeatCount) .. "_people_cardCount"
                                                    if key_cardcount ~= nil then

                                                        if roundOption[k][key_cardcount] ~= nil then
                                                            select_tt_2:setString("（房卡X" .. roundOption[k][key_cardcount] .. "）")

                                                        else
                                                            
                                                            if roundOption[k].cardCount ~= nil then
                                                                select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                                            end

                                                        end

                                                    else

                                                        if roundOption[k].cardCount ~= nil then
                                                            select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                                        end

                                                    end

                                                else

                                                    if roundOption[k].cardCount ~= nil then
                                                        select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                                    end

                                                end

                                            elseif v.optionValue == "AA" then

                                                if roundOption[k].aa_cardCount ~= nil then
                                                    select_tt_2:setString("（房卡X" .. roundOption[k].aa_cardCount .. "）")
                                                end

                                            end

                                        end

                                    end

                                    --特殊处理人数变化后扣卡显示
                                    if config == "maxSeatCount" then

                                        --dump(v.optionValue, "-----maxSeatCount-----")
                                        nowmaxSeatCount = v.optionValue

                                        for k,circle_select in pairs(round_circle_select_arr) do

                                            local select_ly = circle_select:getChildByName("select_ly")
                                            local select_tt_2 = select_ly:getChildByName("select_tt_2")

                                            if nowgame_pay_type == "AA" then

                                                if roundOption[k].aa_cardCount ~= nil then
                                                    select_tt_2:setString("（房卡X" .. roundOption[k].aa_cardCount .. "）")
                                                end

                                            else

                                                if nowmaxSeatCount ~= nil then

                                                    local key_cardcount = tostring(nowmaxSeatCount) .. "_people_cardCount"
                                                    if key_cardcount ~= nil then

                                                        if roundOption[k][key_cardcount] ~= nil then
                                                            select_tt_2:setString("（房卡X" .. roundOption[k][key_cardcount] .. "）")

                                                        else

                                                            if roundOption[k].cardCount ~= nil then
                                                                select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                                            end

                                                        end

                                                    else

                                                        if roundOption[k].cardCount ~= nil then
                                                            select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                                        end

                                                    end

                                                else

                                                    if roundOption[k].cardCount ~= nil then
                                                        select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                                    end

                                                end

                                            end

                                        end

                                    end

                                end

                            end

                        end)


                        --选项点击事件
                        select_im:addEventListenerCheckBox(function(sender,eventType)

                            require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

                            if eventType == CHECKBOX_STATE_EVENT_SELECTED then

                                if synchroTable[config] then
                                    -- dump(synchroTable[config],"synchroTable[config]")
                                    if  synchroTable[config]["canChange"] ~= true then
                                        sender:setSelected(not sender:isSelected())
                                        return
                                    end
                                end

                                for  _,checkbox in pairs(single_selection_table[config]) do
                                    if  checkbox:getTag() ~= sender:getTag() then
                                        checkbox:setSelected(false)
                                        local select_tt_1 = checkbox:getParent():getChildByName("select_tt_1")
                                        local select_tt_2 = checkbox:getParent():getChildByName("select_tt_2")
                                        select_tt_1:setTextColor(unSelectedColor) 
                                        select_tt_2:setTextColor(unSelectedColor)
                                    end
                                end

                               --重置当前选项组的选中清空
                                local configOption = nowSelectGameConfig.gameConfig[gameConfig_p].configGroup[configGroup_p].configOption
                                for k,v in pairs(configOption) do
                                    v.isDefualt = 0
                                end

                                v.isDefualt = 1

                                select_tt_1:setTextColor(selectedColor)
                                select_tt_2:setTextColor(selectedColor)

                                self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)

                                --特殊处理房主扣卡和AA制扣卡
                                if config == "pay_type" then

                                    --dump(v.optionValue, "-----pay_type-----")
                                    nowgame_pay_type = v.optionValue

                                    for k,circle_select in pairs(round_circle_select_arr) do
                                        
                                        --dump(roundOption[k], "-----roundOption[k]-----")
                                        
                                        local select_ly = circle_select:getChildByName("select_ly")
                                        local select_tt_2 = select_ly:getChildByName("select_tt_2")

                                        if v.optionValue == "fangka" then

                                            if roundOption[k].cardCount ~= nil then
                                                select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                            end

                                        elseif v.optionValue == "AA" then

                                            if roundOption[k].aa_cardCount ~= nil then
                                                select_tt_2:setString("（房卡X" .. roundOption[k].aa_cardCount .. "）")
                                            end

                                        end

                                    end

                                end

                                --特殊处理人数变化后扣卡显示
                                if config == "maxSeatCount" then

                                    --dump(v.optionValue, "-----maxSeatCount-----")
                                    nowmaxSeatCount = v.optionValue

                                    for k,circle_select in pairs(round_circle_select_arr) do

                                        local select_ly = circle_select:getChildByName("select_ly")
                                        local select_tt_2 = select_ly:getChildByName("select_tt_2")

                                        if nowgame_pay_type == "AA" then

                                            if roundOption[k].aa_cardCount ~= nil then
                                                select_tt_2:setString("（房卡X" .. roundOption[k].aa_cardCount .. "）")
                                            end

                                        else

                                            if nowmaxSeatCount ~= nil then

                                                local key_cardcount = tostring(nowmaxSeatCount) .. "_people_cardCount"
                                                if key_cardcount ~= nil then

                                                    if roundOption[k][key_cardcount] ~= nil then
                                                        select_tt_2:setString("（房卡X" .. roundOption[k][key_cardcount] .. "）")
                                                    end

                                                else

                                                    if roundOption[k].cardCount ~= nil then
                                                        select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                                    end

                                                end

                                            else

                                                if roundOption[k].cardCount ~= nil then
                                                    select_tt_2:setString("（房卡X" .. roundOption[k].cardCount .. "）")
                                                end

                                            end

                                        end

                                    end

                                end

                            elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then 
                                if synchroTable[config] then
                                    -- dump(synchroTable[config],"synchroTable[config]")
                                    if  synchroTable[config]["canChange"] ~= true then
                                        sender:setSelected(not sender:isSelected())
                                        return
                                    end
                                end

                                select_im:setSelected(true)
                            end
                            
                            -- --更新关联项
                            -- local relateConfigArr = nowSelectGameConfig.gameConfig[gameConfig_p].configGroup[configGroup_p].configOption[configOption_p].relateConfigArr
                            -- local newisDefualt = nowSelectGameConfig.gameConfig[gameConfig_p].configGroup[configGroup_p].configOption[configOption_p].isDefualt
                            -- self:updateRelateConfig(relateConfigArr, newisDefualt)

                            -- self:showConfigView()

                        end)
                    
                    end

                elseif isCheckBox == 1 then

                    --dump(configOption,"configOption-复选框选项内容")

                    for configOption_p,v in pairs(configOption) do
                                        
                        -- dump(v,"配置细胞-复选框")
                        --定义选择项
                        local tick_select = cc.CSLoader:createNode(TickSelectCsb)
                        group_ly:addChild(tick_select)

                        local select_ly = tick_select:getChildByName("select_ly")
                        -- select_ly:setTouchEnabled(false)
                        -- select_ly:setAnchorPoint(cc.p(0,1))
                        -- select_ly:setScale(0.9)
                         
                        local selectionIndex = configOption_p - 1
                        local x = (select_ly:getContentSize().width + 0) * (selectionIndex % oneLineItemCount) + begin_x
                        local y = (select_ly:getContentSize().height + 20) * math.floor(selectionIndex / oneLineItemCount) * -1
                        select_ly:setPosition(cc.p(x, y))

                        tick_select:setVisible(true)
                        
                        local select_im = select_ly:getChildByName("select_im")
                        select_im:setTag(configOption_p)

                        local select_tt_1 = select_ly:getChildByName("select_tt_1")
                        if string.find(v.optionName, "shisanz_hourse") == nil then  

                            select_tt_1:setString(v.optionName)

                            if v.addColor~=nil then
                                --十三水5人玩，必须加一色
                                if curSelPeopleNum == 5 then
                                    v.isDefualt = 1
                                    enabledAddColor = false
                                else
                                    if enabledAddColor == false then
                                        v.isDefualt = 0
                                    end
                                end
                            end

                            --dump(v.optionName,"复选框的选项名")

                            --添加默认选项
                            if  v.isDefualt == 1 then
                                select_tt_1:setTextColor(selectedColor)
                                enabledAddColor = true
                                select_im:setSelected(true)
                                self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)
                            else
                                select_tt_1:setTextColor(unSelectedColor) 
                                select_im:setSelected(false)
                            end

                            --dump(select_im:isSelected(),"选项是否被选中")

                                    
                            select_tt_1:setTouchEnabled(true)
                            select_tt_1:addTouchEventListener(function(sender,event)

                                if  event == TOUCH_EVENT_ENDED then

                                    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
                                    
                                    if  select_im:isSelected() then
                                        v.isDefualt = 0
                                        select_tt_1:setTextColor(unSelectedColor)
                                        enabledAddColor = true
                                        select_im:setSelected(false)
                                        self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)
                                    else
                                        select_tt_1:setTextColor(selectedColor)

                                        v.isDefualt = 1
                                        select_im:setSelected(true)
                                        self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)
                                    end

                                end

                            end)


                            select_im:addEventListenerCheckBox(function(sender,eventType)

                                    require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
                                       --更新配置
                                    local configOption = nowSelectGameConfig.gameConfig[gameConfig_p].configGroup[configGroup_p].configOption[configOption_p]
                                    if configOption.addColor ~= nil then
                                        if curSelPeopleNum == 5 then
                                            return
                                        end
                                    end

                                    if eventType == CHECKBOX_STATE_EVENT_SELECTED then
                                        v.isDefualt = 1
                                        select_tt_1:setTextColor(selectedColor)
                                        self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)
                                    elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
                                        v.isDefualt = 0
                                        enabledAddColor = true
                                        select_tt_1:setTextColor(unSelectedColor)
                                        self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)
                                    end

                                    -- --更新关联项
                                    -- local relateConfigArr = configOption.relateConfigArr
                                    -- local newisDefualt = configOption.isDefualt
                                    -- self:updateRelateConfig(relateConfigArr, newisDefualt)             

                                    -- self:showConfigView()

                                end)

                        else
                            --十三水带马要特殊处理(其他人路过就好)
                            select_tt_1:setString("带马")

                            --添加默认选项
                            if v.isDefualt == 1 then
                                select_im:setSelected(true)
                                select_tt_1:setTextColor(selectedColor)
                                self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)
                            else
                                select_tt_1:setTextColor(unSelectedColor)
                                select_im:setSelected(false)
                            end

                            --选项点击事件
                            select_im:addEventListenerCheckBox(function(sender,eventType)
                                --更新配置
                                require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

                                if eventType == CHECKBOX_STATE_EVENT_SELECTED then
                                    v.isDefualt = 1
                                    select_tt_1:setTextColor(selectedColor )
                                elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
                                    v.isDefualt = 0
                                    select_tt_1:setTextColor(unSelectedColor)
                                end

                                self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)

                                -- local configOption = nowSelectGameConfig.gameConfig[gameConfig_p].configGroup[configGroup_p].configOption[configOption_p]

                                -- --更新关联项
                                -- local relateConfigArr = configOption.relateConfigArr
                                -- local newisDefualt = configOption.isDefualt
                                -- self:updateRelateConfig(relateConfigArr, newisDefualt)

                                -- self:showConfigView()
                            end)

                            local resPath = {}
                            resPath[1] = CreateGroup_Spade_5_filePath
                            resPath[2] = CreateGroup_Spade_10_filePath
                            resPath[3] = CreateGroup_Spade_1_filePath

                            local res_i = 0
                            for m, n in ipairs(resPath) do                                            
                                local x = select_ly:getPositionX() + 250 + res_i*100 --200 *configOption_p 
                                local y = select_ly:getPositionY() - 53  ----100  --
                                local spade = ccui.Button:create(n, n)
                                if spade then
                                    spade:setScale(0.8, 0.7)
                                    spade:setPosition(x, y)
                                    spade:setTag(tonumber(m))
                                    if v.isDefualt == 0 then
                                        spade:setColor(cc.c3b(0xb9,0xb9,0xb9))
                                    else
                                        if v.optionValue == m then
                                            spade:setColor(cc.c3b(0xff,0xff,0xff))
                                        else
                                            spade:setColor(cc.c3b(0xb9,0xb9,0xb9))
                                        end
                                    end
                                    group_ly:addChild(spade)
                                    spade:addClickEventListener(function(sender)
                                       --更新配置
                                       local configOption = nowSelectGameConfig.gameConfig[gameConfig_p].configGroup[configGroup_p].configOption[configOption_p]
                                        local isDefualt = configOption.isDefualt
                                        if isDefualt > 0 then
                                            local tag = sender:getTag()
                                            configOption.optionValue = tag
                                        
                                            -- --更新关联项
                                            -- local relateConfigArr = configOption.relateConfigArr
                                            -- local newisDefualt = configOption.isDefualt
                                            -- self:updateRelateConfig(relateConfigArr, newisDefualt)

                                            self:showConfigView()
                                        end                                                    
                                    end)
                                end

                                res_i = res_i + 1
                            end
                        end
                        
                    end

                elseif isCheckBox == 2 then

                    local x = 0 + 100
                    local y = -40

                    local menu_drop_down = cc.CSLoader:createNode(Drop_down_csb)
                          menu_drop_down:addTo(group_ly)           
                    local menu_lv =  menu_drop_down:getChildByName("menu_lv")
                          menu_lv:setVisible(false):removeAllChildren()

                          menu_lv:setPosition(cc.p(x, y))

                    local backGround = menu_drop_down:getChildByName("backGround")
                          backGround:setVisible(false)
                          backGround:setPosition(cc.p(x, y))

                    local openDropdownBox =  function(sender,event)

                            if event == TOUCH_EVENT_ENDED then
                                require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
                                menu_lv:setVisible(not menu_lv:isVisible()) 
                                backGround:setVisible(not backGround:isVisible()) 
                                -- local menu_lv_inner_size = menu_lv:getInnerContainerSize()
                            end

                          end

                    local select_result =  menu_drop_down:getChildByName("select_result")
                          select_result:setPosition(cc.p(x, y))

                    local selected_option = select_result:getChildByName("selected_option")
                          selected_option:addTouchEventListener(openDropdownBox)

                    -- local select_sign = select_result:getChildByName("select_sign")
                          -- select_sign:setTouchEnabled(true)
                          -- select_sign:addTouchEventListener(openDropdownBox)

                    local menu_item =  menu_drop_down:getChildByName("menu_item")


                    for configOption_index,v in pairs(configOption) do  

                        local optionName = v.optionName
                        local optionValue = v.optionValue

                        local additionalOptionName = ""
                        -- if  config == "baseChip" then
                        --     local baseChip = tonumber(optionValue)
                        --     local enterMisCoins = require("hall.scene.group.join.table_list"):getEnterMisCoins(baseChip,parameter["level"])
                        --     dump(enterMisCoins,"获取准入分数")
                        --     if  enterMisCoins then
                        --         additionalOptionName = " （ " .. enterMisCoins .. " 准入）"
                        --     end
                        -- end

                        local menu_item_clone = menu_item:clone()
                        menu_lv:pushBackCustomItem(menu_item_clone)

                        menu_item_clone:setString(optionName..additionalOptionName)
                        menu_item_clone:setVisible(true)
                        menu_item_clone:addTouchEventListener(function(sender,event)

                            if event == TOUCH_EVENT_ENDED then

                                require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

                                local configOption = nowSelectGameConfig.gameConfig[gameConfig_p].configGroup[configGroup_p].configOption
                                for k,v in pairs(configOption) do
                                    v.isDefualt = 0
                                end
                                    
                                v.isDefualt = 1
                                self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)
                                
                                backGround:setVisible(false) 
                                menu_lv:setVisible(false) 

                                if  selected_option then
                                    selected_option:setString(optionName..additionalOptionName)
                                end

                            end

                        end)

                        --dump(v,"下拉框的item")

                        if v.isDefualt == 1 then
                            
                            local ori_menu_item_size = selected_option:getSize()

                            selected_option:setString(optionName..additionalOptionName):setTextColor(selectedColor)

                            local menu_item_size = selected_option:getSize()

                            if  menu_item_size.width < ori_menu_item_size.width then
                                menu_item_size = ori_menu_item_size
                            end

                            if  config == "baseChip" then
                                menu_item_size.width = 430
                            end

                            menu_lv:setContentSize(cc.size(menu_item_size.width + 30,menu_lv:getInnerContainerSize().height))
                            -- menu_lv:setInnerContainerSize(cc.size(menu_item_size.width + 30,0))
                            -- menu_lv:setContentSize(menu_lv:getInnerContainerSize())
                            backGround:setContentSize(cc.size(menu_item_size.width + 30,#configOption*34))

                            select_result:setContentSize(menu_item_size.width + 30,menu_item_size.height + 10)
                            select_result:getChildByName("selected_backGround"):setContentSize(menu_item_size.width + 30,menu_item_size.height + 10)

                            local select_result_size = select_result:getContentSize()
                            selected_option:setPosition(select_result_size.width/2,select_result_size.height/2)
                            -- select_sign:setPosition(select_result_size.width+25,select_result_size.height/2)

                            self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)

                        end
                    
                    end

                elseif isCheckBox == 3 then

                    for configOption_p,v in pairs(configOption) do

                        v.isDefualt = 1
                        -- if v.isDefualt == 1 then
                            self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)                    
                        -- end
                    
                    end
                
                elseif isCheckBox == 4 then

                    for configOption_p,v in pairs(configOption) do

                        v.isDefualt = 1
                        -- if v.isDefualt == 1 then
                            self:updateConfig(config,configShowName,v,v.isDefualt,isCheckBox)                    
                        -- end
                    
                    end
                    
                end
                
            end

        end

        ----dump(groupHeight_arr, "-----groupHeight_arr-----")
        local class_y = 0
        if gameConfig_p > 1 then
            for selectionIndex,b in pairs(groupHeight_arr) do
                if selectionIndex < gameConfig_p + additionalOptionNum then
                    for c,d in pairs(b) do
                        class_y = class_y + d
                    end
                end
            end
        end
          
        --dump(class_y,"class_y")
        class_ly:setPosition(65, class_y * -1)

    end

    local allHeight = 0
    for selectionIndex,b in pairs(groupHeight_arr) do
        for c,d in pairs(b) do
            allHeight = allHeight + d
        end
    end

    dump(allHeight,"allHeight")

    if  allHeight < 900 then
        allHeight = 900
    end

    -- if  allHeight > 492 then   --这里如果设定得太小，选项上方就会出现空白区域
        content_ly:setPosition(0, allHeight)
    -- else
    --     content_ly:setPosition(0, 492)
    -- end

    if isFirst then   --只有初次加载才设置选项框大小和加载不同分场的选项
        --设置内容显示区域大小
        config_sv:setInnerContainerSize(cc.size(708.00, allHeight))
    end

     ----dump(parameter, "-----默认配置-----")


end

--更新关联项
function Scene:updateRelateConfig(relateConfigArr, require)

    ----dump(relateConfigArr, "-----选项关联项组-----")
    ----dump(require, "-----关联要求-----")

    if relateConfigArr ~= nil then
                                                
        for k,v in pairs(relateConfigArr) do

            ----dump(v, "-----选项关联项组-----")
            
            --关联项所在位置
            local relateConfigArrShowNamePosition = v.relateConfigArrShowNamePosition
            local relateConfigPosition = v.relateConfigPosition
            local relateConfigOptionPosition = v.relateConfigOptionPosition

            --关联项是否为多选
            local relateConfigisCheckBox = v.relateConfigisCheckBox

            --关联项触发条件
            local relateRequire = v.relateRequire

            if relateRequire == require then

                --关联操作是否为设置默认值
                local relateHandleIsSetDefualt = v.relateHandleIsSetDefualt
                
                --关联项触发操作
                local relateHandle = v.relateHandle

                --进行关联操作
                if nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition] ~= nil then
                    if nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition] ~= nil then
                        if nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition] ~= nil then

                            --假如当前关联选项组是单选
                            if relateConfigisCheckBox == 0 then

                                if relateHandleIsSetDefualt == 1 then

                                    --判断当前选项组是否已经有选中值
                                    local ishasdefual = 0
                                    local configOption = nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption
                                    if configOption ~= nil then
                                        for k,v in pairs(configOption) do
                                            if v.isDefualt == 1 then
                                                ishasdefual = 1
                                            end
                                        end
                                    end

                                    --当前没有选中值，设置默认值
                                    if ishasdefual == 0 then
                                        
                                        if nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt ~= relateHandle then
                                
                                            if relateHandle == 0 then
                                                nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt = 0
                                            
                                            elseif relateHandle == 1 then
                                                nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt = 1
                                            
                                            end

                                            --更新关联项的关联项
                                            local newRelateConfigArr = nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].relateConfigArr
                                            local newRelateisDefualt = nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt
                                            self:updateRelateConfig(newRelateConfigArr, newRelateisDefualt)

                                        end
                                        
                                    end

                                else

                                    --重置当前选项组的选中项
                                    local configOption = nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption
                                    if configOption ~= nil then
                                        for k,v in pairs(configOption) do
                                            v.isDefualt = 0
                                        end
                                    end

                                    if nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt ~= relateHandle then
                                
                                        if relateHandle == 0 then
                                            nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt = 0
                                        
                                        elseif relateHandle == 1 then
                                            nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt = 1
                                        
                                        end

                                        --更新关联项的关联项
                                        local newRelateConfigArr = nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].relateConfigArr
                                        local newRelateisDefualt = nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt
                                        self:updateRelateConfig(newRelateConfigArr, newRelateisDefualt)

                                    end

                                end

                            else

                                if nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt ~= relateHandle then
                                
                                    if relateHandle == 0 then
                                        nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt = 0
                                    
                                    elseif relateHandle == 1 then
                                        nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt = 1
                                    end

                                    --更新关联项的关联项
                                    local newRelateConfigArr = nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].relateConfigArr
                                    local newRelateisDefualt = nowSelectGameConfig.gameConfig[relateConfigArrShowNamePosition].configGroup[relateConfigPosition].configOption[relateConfigOptionPosition].isDefualt
                                    self:updateRelateConfig(newRelateConfigArr, newRelateisDefualt)

                                end
                                
                            end

                        end

                    end

                end

            end

        end

    end

end


return Scene
