
local GroupSetting  = class("GroupSetting")

--创建组局
function GroupSetting:create(time,baseChip,coin,level,parameter,clubId, password)

    --处理入参
    local configJson = {}
    local discription = ""
    local isShowOp = ""
    dump(parameter,"parameter@@@@@")
    for k,v in pairs(parameter) do
        if type(v) == "table" then

            if v.optionName ~= nil and v.configName then
                discription = discription .. v.configName .. ":" .. v.optionName .. " "
            end

            if v.isShow ~= nil and v.isShow == 1 and v.configName then
                isShowOp = isShowOp .. v.configName .. ":" .. v.optionName .." "
            end    

            if v.optionValue ~= nil then
                configJson[k] = v.optionValue
            end

        end
    end

    if parameter["cardCount"] ~= nil then
        configJson["cardCount"] = parameter["cardCount"]
    end
    if tonumber(parameter["cardCount"]) == nil or tonumber(parameter["cardCount"]) <= 0  then 
        parameter["cardCount"] = 4
        configJson["cardCount"] = 4
    end

    discription = string.sub(discription, 1, string.len(discription) - 1)

    local tempRound = 8
    if  not parameter["round"] then
    else
        tempRound = parameter["round"].optionValue
    end

    local tbl = {}
    tbl.userId = tostring(USER_INFO["uid"])--用户ID
    tbl.baseChip = 1 --底注
    tbl.gameId = tostring(parameter["gameId"])--游戏ID
    tbl.name = tostring(USER_INFO["nick"].."的组局")--组局名称
    tbl.level = tonumber(level)--level
    tbl.round = tempRound
    configJson["baseChip"] = parameter["baseChip"] or 10
    tbl.json = json.encode(configJson)
    tbl.discription = discription
    tbl.discription2Server = isShowOp
    tbl.groupId = clubId 
    tbl.others = 1   --自开 
    tbl.cardCount = parameter["cardCount"]
    tbl.password = password
    tbl.interfaceType = "J"

    require("hall.groudgamemanager"):createfreegame(USER_INFO["uid"], tbl)

end

--加入组局
function GroupSetting:enterRoom()

    -- 获取组局创建配置数据
    if bm.groupGameConfig == nil then
        return
    end
    
    -- local xzConfig = bm.groupGameConfig[1]
    local xzConfig
    if #bm.groupGameConfig > 0 then
        for k,v in pairs(bm.groupGameConfig) do
            --获取选中的游戏的组局配置
            if USER_INFO["enter_mode"] == v.gameId then
                xzConfig = v
                break
            end
        end
    end
    
    if xzConfig == nil then
        return
    end

    --记录当前游戏对应的等级
    local level = xzConfig.level

    local layerEnter = SCENENOW["scene"]:getChildByName("enter_room")
    if layerEnter == nil then
        layerEnter = cc.CSLoader:createNode("hall/group/enter_room/enter_room.csb"):addTo(SCENENOW["scene"])
        layerEnter:setName("enter_room")
    end
    local tbNumber = {}
    local numPos = 0
    local str = 1
    local function reFresh()
        dump(tbNumber, "tbNumber")
        for i = 1,6 do
            str = "num_box_"..tostring(i)
            local txt = layerEnter:getChildByName(str):getChildByName("Text_1")
            if tbNumber[i] then
                txt:setString(tostring(tbNumber[i]))
            else
                txt:setString("")
            end
        end
    end
    reFresh()

    --按钮
    local tbBtnNumbers = {}
    for i = 1,10 do
        if i < 10 then
            str = "btn_"..tostring(i)
        else
            str = "btn_0"
        end
        tbBtnNumbers[i] = layerEnter:getChildByName(str)
    end
    local btn_submit = layerEnter:getChildByName("btn_submit")
    local btn_del = layerEnter:getChildByName("btn_del")
    local btn_exit = layerEnter:getChildByName("btn_exit")

    --设置确定按钮状态
    local function setSubmit(flag)
        if btn_submit then
            btn_submit:setEnabled(flag)
            if flag == false then
                btn_submit:loadTextureNormal("hall/common/small_disable_bt_n.png")
                -- btn_submit:setColor(cc.c3b(125,125,125))
            else
                btn_submit:loadTextureNormal("hall/common/setting_yellow_bt.png")
                -- btn_submit:setColor(cc.c3b(255,255,255))
            end
        end
    end
    setSubmit(false)

    --按钮事件
    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if #tbNumber < 6 then
                for i=1,10 do
                    if sender == tbBtnNumbers[i] then
                        numPos = numPos + 1
                        tbNumber[numPos] = i
                        if tbNumber[numPos] >= 10 then
                            tbNumber[numPos] = 0
                        end
                        reFresh()
                        if #tbNumber == 6 then
                            --setSubmit(true)
                            local strCode = ""
                            for i = 1, 6 do
                                strCode = strCode..tostring(tbNumber[i])
                            end
                            print("inviteCode:",strCode)
                            require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], strCode, "", false, level, false)
                        end
                    end
                end
            end
            -- --确定进入组局
            -- if sender == btn_submit then
            --     local strCode = ""
            --     for i = 1, 6 do
            --         strCode = strCode..tostring(tbNumber[i])
            --     end
            --     print("inviteCode:",strCode)
            --     require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"],strCode)
            -- end
            --删除
            if sender == btn_del then
                if numPos > 0 then
                    table.remove(tbNumber,numPos)
                    numPos = numPos - 1
                    reFresh()
                    setSubmit(false)
                end
            end
            if sender == btn_exit then
                layerEnter:removeSelf()
            end
        end
    end

    --按钮注册
    for i = 1,10 do
        if tbBtnNumbers[i] then
            tbBtnNumbers[i]:addTouchEventListener(touchButtonEvent)
        end
    end

    --确定，删除
    btn_submit:addTouchEventListener(touchButtonEvent)
    btn_del:addTouchEventListener(touchButtonEvent)
    btn_exit:addTouchEventListener(touchButtonEvent)

end

--重连组局提示
function GroupSetting:showTips(data,exit,join)
    local paras = {type = 2, title = "提示", content = "是否重连房间?", callBackSure = handler(self, self.toConnectRoom), callBackCancel = handler(self, self.doNotConnectRoom)} 
    self.showTipsData = data
    require(CommonTips_filePath):showTips(paras)

end

function GroupSetting:toConnectRoom()
    require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], self.showTipsData["inviteCode"], self.showTipsData["activityId"], true)
end

function GroupSetting:doNotConnectRoom()
    require("hall.groudgamemanager"):exitFreeGame(USER_INFO["uid"], self.showTipsData["inviteCode"])
end

--进入组局
function GroupSetting:enterGroup()
    if g_hallMainLayer and g_hallMainLayer.familyMainlayer then
        g_hallMainLayer.familyMainlayer = nil
    end
    require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])

end

--是否组局创建者
function GroupSetting:isGroupOwner()
    if USER_INFO["enter_mode"] ~= 4 then
        print("不是组局游戏")
        return false
    end
    if tonumber(USER_INFO["group_owner"]) ~= USER_INFO["uid"] then
        print("不是组局创建者")
        return false
    end
    return true
end

--代开组局
function GroupSetting:create_agent(time, baseChip, coin, level, parameter, clubId, password, callback)

    --处理入参
    local configJson = {}
    local discription = ""
    local isShowOp = ""

    dump(parameter,"parameter@@@@@")

    for k,v in pairs(parameter) do
        -- if k ~= "gameId" and k ~= "diZhu" and k ~= "chouMa" and k ~= "level" then
        if type(v) == "table" then
            if  v.optionName ~= nil and v.configName then
                discription = discription .. v.configName .. ":" .. v.optionName .. " "
            end

            if  v.isShow ~= nil and v.isShow == 1 and v.configName then
                isShowOp = isShowOp .. v.configName .. ":" .. v.optionName .." "
            end    

            if v.optionValue ~= nil then
                configJson[k] = v.optionValue
            end
        end
        -- end
    end

    if parameter["cardCount"] ~= nil then
        configJson["cardCount"] = parameter["cardCount"]
    end

    if tonumber(parameter["cardCount"]) == nil or tonumber(parameter["cardCount"]) <= 0  then 
        parameter["cardCount"] = 4
        configJson["cardCount"] = 4

        if tonumber(level) == 318 then
            parameter["cardCount"] = 1
            configJson["cardCount"] = 1
        end
    end
    configJson["id"] = parameter["id"] or 0
    configJson["name"] = parameter["name"] or ""
    configJson["joinGamePoint"] = parameter["joinGamePoint"] or 0
    configJson["profitType"] = parameter["profitType"] or 0
    configJson.rateOrConstant = parameter.rateOrConstant or 0
    configJson["profit"] = parameter["profit"] or 0
    configJson["profitLimit"] = parameter["profitLimit"] or 0
    configJson["readyPoint"] = parameter["readyPoint"] or 0
    configJson["baseChip"] = parameter["baseChip"]
    configJson["oneOrAll"] = parameter["oneOrAll"] or 2
    configJson["additionalPoint"] = parameter["additionalPoint"] or 0
    configJson["secConstant"] = parameter.secConstant or ""
    if parameter.startCost and parameter.startCost > 0 then
        configJson["startCost"] = parameter.startCost
    end
    discription = string.sub(discription, 1, string.len(discription) - 1)

    local tbl = {}
    tbl.userId = tostring(USER_INFO["uid"])--用户ID
    --tbl.phone = tostring(USER_INFO["phone"])--电话
    tbl.baseChip = parameter["baseChip"] or 10--底注
    tbl.gameId = tostring(parameter["gameId"])--游戏ID
    tbl.password = password--游戏ID
    --tbl.minutes = tonumber(time)--时长
    --tbl["type"] = tostring(USER_INFO["type"])--用户类型
    --tbl.oriCoins = tonumber(1000)-- 带入筹码
    tbl.name = tostring(USER_INFO["nick"].."的组局")--组局名称
    tbl.level = tonumber(level)--level
    if  parameter["round"] then
        tbl.round = parameter["round"].optionValue--局数
    else
        tbl.round = 8
    end

    tbl.json = json.encode(configJson)
    tbl.discription = discription
    tbl.discription2Server = isShowOp
    tbl.groupId = clubId 
    tbl.interfaceType = "J"
    tbl.others = 0   --代开 
    tbl.cardCount = parameter["cardCount"]
    if parameter["tempGameType"] then
        tbl.gameType = tonumber(parameter["tempGameType"])
    end
    if parameter["id"] then
        tbl.configId = tonumber(parameter["id"])
    end

    require("hall.groudgamemanager"):createAgentGame(tbl, callback)

end


return GroupSetting