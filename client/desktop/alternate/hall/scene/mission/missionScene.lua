local missionScene = class("missionScene")

local area_arr = {}
local tab_arr = {}
local tabButton_arr = {}
local selectedTabIndex
local GroupStart_arr = {}
local GroupHeight_arr = {}

local s
local root_ly
local gamelist_sv
local content_ly

local _w = nil 

local curIndex = 1

local taskData = nil

function missionScene:showScene()

	if SCENENOW["scene"] ~= nil then

        self:removeScene()

	    s = cc.CSLoader:createNode(MissionSceneCsb_filePath)
	    s:setName("missionScene")
	    SCENENOW["scene"]:addChild(s,9999999)
        local action = cc.CSLoader:createTimeline(MissionSceneCsb_filePath)
        action:retain()
        s:runAction(action)
        action:gotoFrameAndPlay(0, 25, false)

        s:setScale(1280/1920)
        _w = self:loadChildrenWidget(s)

        curIndex = 1
        root_ly = s:getChildByName("root_ly")


	    local back_bt = root_ly:getChildByName("back_bt")

	    back_bt:setTouchEnabled(true)

        local closeFunc = function(sender,event)

                if event == TOUCH_EVENT_BEGAN then
                    sender:setScale(1.0)
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

            end

        back_bt:addTouchEventListener(closeFunc)
        _w["Panel_1"]:addTouchEventListener(closeFunc)
        _w["Image_1"]:addTouchEventListener(closeFunc)

        -- local Image_1 = root_ly:getChildByName("Image_1")
	    -- Image_1:setTouchEnabled(false)
	    -- Image_1:addTouchEventListener(

     --        function(sender,event)

     --            if event == TOUCH_EVENT_BEGAN then
     --                sender:setScale(1.0)
     --            end

     --            --触摸取消
     --            if event == TOUCH_EVENT_CANCELED then
     --                sender:setScale(1.0)
     --            end

     --            --触摸结束
     --            if event == TOUCH_EVENT_ENDED then
     --            	sender:setScale(1.0)

     --            end

     --        end

     --    )

        -- self:showMissionList()
        self:getMissionData()

    end

end

function missionScene:showMissionList()
    
    if s == nil then
        return
    end

    gamelist_sv = root_ly:getChildByName("task_sv")
    if  gamelist_sv == nil then
        return
    end

    area_arr = {}
    tab_arr = {}
    tabButton_arr = {}
    selectedTabIndex = 1

    game_arr = {}
    selectedGameIndex = nil

    local typeCount = 0
    local gameCount = 0

    content_ly = gamelist_sv:getChildByName("content_ly")

    local task_list = {}

    local table1 = {}
    table1["type"] = "充值任务"

    local table2 = {}
    table2["type"] = "升级任务"

    table.insert(task_list, table1)
    table.insert(task_list, table2)

    local select_ly

    for k,v in pairs(task_list) do

        --定义并添加分类区域
        local gametype_ly = ccui.Layout:create()
        gametype_ly:setTouchEnabled(false)
        gametype_ly:setAnchorPoint(cc.p(0, 1))
        gametype_ly:setPosition(0, 88 * (k - 1) * -1)
        content_ly:addChild(gametype_ly)

        --添加分类标签
        local tab_typeLayer = cc.CSLoader:createNode(Mission_TabType_Csb_filePath)
        tab_typeLayer:setTouchEnabled(false)
        tab_typeLayer:setAnchorPoint(cc.p(0, 1))
        tab_typeLayer:setPosition(0, 0)
        gametype_ly:addChild(tab_typeLayer)

        --显示分类名称
        local tab_typeLayer_content_ly = tab_typeLayer:getChildByName("content_ly")
        tab_typeLayer_content_ly:setTouchEnabled(false)

        --背景图片
        local tab_typeLayer_bg_iv = tab_typeLayer_content_ly:getChildByName("bg_iv")
        tab_typeLayer_bg_iv:loadTexture(Mission_TabTypeBg_n_filePath)
        tab_typeLayer_bg_iv:setTouchEnabled(false)

        local tab_typeLayer_text_tt_n = tab_typeLayer_content_ly:getChildByName("text_tt_n")
        tab_typeLayer_text_tt_n:setVisible(true)
        tab_typeLayer_text_tt_n:setTouchEnabled(false)
        tab_typeLayer_text_tt_n:setString(k)

        local tab_typeLayer_text_tt_s = tab_typeLayer_content_ly:getChildByName("text_tt_s")
        tab_typeLayer_text_tt_s:setVisible(false)
        tab_typeLayer_text_tt_s:setTouchEnabled(false)
        tab_typeLayer_text_tt_s:setString(k)

        --定义一个按钮
        local typeButton = ccui.Button:create()
        typeButton:setTouchEnabled(true)
        typeButton:setAnchorPoint(cc.p(0.5, 0.5))
        typeButton:setTag(k)
        typeButton:loadTextures(Mission_Blank_filePath, nil, nil)
        typeButton:setPosition(cc.p(130, -40))
        typeButton:addTouchEventListener(

            function(sender,event)

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

                    --重置之前点击的按钮
                    local select_tab_typeLayer_bg_iv = select_ly:getChildByName("bg_iv")
                    select_tab_typeLayer_bg_iv:loadTexture(Mission_TabTypeBg_n_filePath)

                    local select_tab_typeLayer_text_tt_n = select_ly:getChildByName("text_tt_n")
                    select_tab_typeLayer_text_tt_n:setVisible(true)

                    local select_tab_typeLayer_text_tt_s = select_ly:getChildByName("text_tt_s")
                    select_tab_typeLayer_text_tt_s:setVisible(false)

                    --更新现在点的按钮
                    tab_typeLayer_bg_iv:loadTexture(Mission_TabTypeBg_s_filePath)
                    tab_typeLayer_text_tt_n:setVisible(false)
                    tab_typeLayer_text_tt_s:setVisible(true)

                    select_ly = tab_typeLayer_content_ly

                    --更新任务列表

                end

            end

        )
        gametype_ly:addChild(typeButton, 5000)

        --显示当前游戏分类的第一个游戏配置
        if k == 1 then

            tab_typeLayer_bg_iv:loadTexture(Mission_TabTypeBg_s_filePath)
            tab_typeLayer_text_tt_n:setVisible(false)
            tab_typeLayer_text_tt_s:setVisible(true)

            select_ly = tab_typeLayer_content_ly

        end

    end

    -- gamelist_sv:setCascadeOpacityEnabled(true)`
    -- if #task_list > 6 then
    --     gamelist_sv:setInnerContainerSize(cc.size(242.00, 88 * #task_list + 20))
    --     content_ly:setPosition(0, 88 * #rankList + 20)
    -- end

end

function missionScene:authIdCard(uid, name, idCardNo, phone)

    if name == nil or name == "" then
        require(CommonTips_filePath):showTips("提示", "", 3, "请输入真实姓名")
        return
    end

    if idCardNo == nil or idCardNo == "" then
        require(CommonTips_filePath):showTips("提示", "", 3, "请输入身份证号")
        return
    end

    if phone == nil or phone == "" then
        require(CommonTips_filePath):showTips("提示", "", 3, "请输入手机号码")
        return
    end
    
    local params = {}
    params["userId"] = uid
    params["name"] = name
    params["idCardNo"] = idCardNo
    params["phone"] = phone

    cct.createHttRq({
        url = HttpAddr .. "/fortune/getAdvertList",
        date = params,
        type_= "POST",
        requestMsg = "正在进行实名认证",
        callBack = function(data)

            local responseData = data.netData
            if responseData then

                responseData = json.decode(responseData)
                dump(responseData, "-----实名认证返回-----")

                local returnCode = responseData.returnCode
                if returnCode == "0" then
                    require(CommonTips_filePath):showTips("提示", "", 3, "实名认证成功！")

                else
                    if responseData.error ~= nil then
                        require(CommonTips_filePath):showTips("提示", "", 3, responseData.error)

                    else
                        require(CommonTips_filePath):showTips("提示", "", 3, "未知错误，实名认证失败")

                    end

                end

            end

        end

    })

end


--获取任务数据

function missionScene:getMissionData()
    -- body
    
    local params = {}
    params["userId"] = USER_INFO["uid"]
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/task/getTaskList",
        date= params,
        type_="POST",
        callBack = function(data)

        
            data_netData = json.decode(data["netData"])
            dump(data_netData,"----任务数据----")

            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                if sData ~= nil  then
                    --todo
                   
                    self:initTabTable(sData)

                end

            end   

        end

    })

end


function missionScene:receiveRegisterBonus(prams)

    --获取不到首登奖励具体数值的情况下
    if (firstLoginBonusGold == nil or  firstLoginBonusGold == 0) and
       (firstLoginBonusRoomCard == nil or firstLoginBonusRoomCard == 0) then
       return
    end

    local s = cc.CSLoader:createNode("hall/scene/res/".. resFolder .. "/mission/firstLoginAward.csb"):addTo(SCENENOW["scene"], 9999)
    s:setScale(1280/1920)

    local mask = s:getChildByName("mask")
    local background = s:getChildByName("background")

    local removeFunc = function(sender,event)

            --触摸开始
            if  event == TOUCH_EVENT_BEGAN then
                require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
            end

            --触摸取消
            if  event == TOUCH_EVENT_CANCELED then
            end

            --触摸结束
            if  event == TOUCH_EVENT_ENDED then
                if  tolua.isnull(s) == false then
                    s:runAction(cc.Sequence:create(
                        cc.FadeOut:create(0.4),
                    --     cc.ScaleTo:create(1,0.1)
                        cc.RemoveSelf:create()

                        ))
                end
            end
    end

    mask:addTouchEventListener(removeFunc)
    background:addTouchEventListener(removeFunc)

    local msg = s:getChildByName("msg")

    local allStrs = {}

    local strTable = {}
    strTable["content"] = "赠送 "
    strTable["color"] = cc.c3b(0xC2,0xD8,0xF0)
    table.insert(allStrs,strTable)

    if firstLoginBonusGold and firstLoginBonusGold > 0 then

        local strTable = {} 
        strTable["type"] = "image"
        strTable["content"] = "hall/scene/res/"..resFolder.."/image/mission/first_login_5.png"
        table.insert(allStrs,strTable)

        local strTable = {}
        strTable["content"] = (firstLoginBonusGold or 100) .. "个  "
        strTable["color"] = cc.c3b(0xC2,0xD8,0xF0)
        table.insert(allStrs,strTable)

    end

    if firstLoginBonusRoomCard and firstLoginBonusRoomCard > 0 then

        local strTable = {} 
        strTable["type"] = "image"
        strTable["content"] = "hall/scene/res/"..resFolder.."/image/mission/first_login_2.png"
        table.insert(allStrs,strTable)

        local strTable = {}
        strTable["content"] = tostring((firstLoginBonusRoomCard or 10) .. "张")
        strTable["color"] = cc.c3b(0xC2,0xD8,0xF0)
        table.insert(allStrs,strTable)

    end

    require("hall.GameCommon"):LabelToRich(msg,allStrs)

    if msg then
        msg:removeFromParent()
    end

    local receive_bt = s:getChildByName("receive_bt")
    receive_bt:addTouchEventListener(function(sender,event)

        --触摸开始
        if  event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)
            sender:setScale(0.9)
        end

        --触摸取消
        if  event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        --触摸结束
        if  event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)

            cct.createHttRq({
                url=HttpAddr .. "/userFirstLoginSentCard",
                date={
                    userId = USER_INFO["uid"]
                },
                type_= "GET",
                callBack = function(data)
                    local data_netData = json.decode(data["netData"])
                    dump(data_netData,"data_netData")
                    if  data_netData.returnCode == "0" then
                        if prams then
                            prams:queryRoomCardCount()
                        end


                        --require(CommonTips_filePath):showTips("提示", "", 3, "！")
                        require("hall.GameTips"):showTips("提示", "", 3, data_netData.data)
                        USER_INFO["hasReceiveRegisterBonus"] = 1

                        if  tolua.isnull(s) == false then
                            s:removeFromParent()
                        end

                    end

                end})

        end
    end)


end


function missionScene:sortTable(data)
    -- body
    local tmpTab = {}
    local index = 1 
    for k,v in pairs(data) do
        table.insert(tmpTab,v)
    end
    table.sort(tmpTab, function(a,b) return a["parentTaskId"]<b["parentTaskId"] end )

    return tmpTab
end



function missionScene:initTabTable(data)
    
    if  tolua.isnull(_w["tab_list"]) then
        return
    end

    data = self:sortTable(data)   --强行排序

    _w["tab_list"]:removeAllChildren()
    --_w["task_list"]:removeAllChildren()

    for k,v in pairs(data) do 
        local tabcell = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/mission/tab_typeLayer.csb")
        local itemLayout = tabcell:getChildByName("itemLayout") 
        local _itemW = self:loadChildrenWidget(itemLayout)
        itemLayout:removeFromParent()
        --print("KKKKKKKK " .. k)
        _itemW["tab_btn"]:setTag(k)

        if k == curIndex then
            _itemW["tab_btn"]:setEnabled(false)
            taskData = v
        end
        _itemW["text_tt_n"]:setString(v["parentTaskName"])

        _itemW["tab_btn"]:addTouchEventListener(
            function(sender,event)


                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    sender:setScale(1.0)
                    local index = _itemW["tab_btn"]:getTag()
                    --print("click index " .. index)
                    curIndex = index
                    if k ~= index then
                        _itemW["tab_btn"]:setEnabled(false)
                       
                    end    
                    self:initTabTable(data)
                end

            end
            )

        _w["tab_list"]:pushBackCustomItem(itemLayout)
        _w["tab_list"]:jumpToTop()

    end    

    self:initTaskTable(taskData)

end


--创建任务列表
function missionScene:initTaskTable(data)

    if  data == nil then
        return
    end

    dump(data,"任务分页列表")
    local taskData = data["task"]
    _w["task_list"]:removeAllChildren()
    ----print("@@@@@@  " .. #taskData)
    for k,v in pairs(taskData) do 
        local taskcell = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .."/mission/missionCell.csb")
        local itemLayout = taskcell:getChildByName("itemLayout")

        itemLayout:removeFromParent()
        local _itemW = self:loadChildrenWidget(itemLayout)
        local taskNow = v["taskNow"]
        local taskTerm = v["taskTerm"]
        local gift = json.decode(v["gift"]) or {}

        local tiliRichText = ccui.RichText:create()

        dump(tiliRichText,"tiliRichText")
        -- _itemW["task_tt"]:setString(..)
        _itemW["task_tt"]:setVisible(false)

        _itemW["task_tt"]:getParent():addChild(tiliRichText)
        tiliRichText:setAnchorPoint(cc.p(0,0.5))
        tiliRichText:setPosition(_itemW["task_tt"]:getPosition())
        -- tiliRichText:setString(v["taskDescribe"].."  "..taskNow.."/"..taskTerm)

        _itemW["comming_ly"]:setVisible(false)

        --local _,bonusTxtPos = 
        dump(v["taskDescribe"]:find("奖励"),"奖励文本的位置")

        local bonusTxtPos = v["taskDescribe"]:find("奖励")

        local taskDescribe = v["taskDescribe"]
        local bonusDescribe = ""

        if  bonusTxtPos then
            taskDescribe = string.sub(v["taskDescribe"],1,bonusTxtPos + string.len("奖励") - 1)
            bonusDescribe = string.sub(v["taskDescribe"],bonusTxtPos + string.len("奖励"))

        -- dump(string.sub(v["taskDescribe"],1,bonusTxtPos+2),"奖励文本的内容1")
        -- dump(string.sub(v["taskDescribe"],bonusTxtPos+3),"奖励文本的内容1")

        end

        local roomCard = gift["roomCard"]
        local gold = gift["gold"]

        if  roomCard then
            taskDescribe = taskDescribe .. "  房卡x" .. roomCard
        end

        if  gold then
            taskDescribe = taskDescribe .. "  钻石x" .. gold.."   " 
        end

        local re1 = ccui.RichElementText:create(1, cc.c3b(0x32,0x35,0x93), 255, taskDescribe.."     ", "hall/scene/res/common/font/FZY3JW.TTF", 30)  
              tiliRichText:pushBackElement(re1)

        if  bonusTxtPos then
            local re2 = ccui.RichElementImage:create(1, cc.c3b(255,255,255), 255, "hall/scene/res/" .. resFolder .."/image/mission/money.png")  
            local re3 = ccui.RichElementText:create(3, cc.c3b(0x32,0x35,0x93), 255, "x"..bonusDescribe, "hall/scene/res/common/font/FZY3JW.TTF", 30)  
            tiliRichText:pushBackElement(re2)
            tiliRichText:pushBackElement(re3)
        end

        local progress_txt = itemLayout:getChildByName("progress_txt")

        if  taskNow then
            progress_txt:setString(taskNow.."/"..taskTerm)
            _itemW["probar_bg"]:setPercent(taskNow*100 / (taskTerm))
        else
            progress_txt:setString("1/1")
            _itemW["probar_bg"]:setPercent(100)
        end

        local isEnough = v["isEnough"]   --是否可领取
        local status = tonumber(v["status"])      --是否领取过

        -- if isEnough == 0 then   --未完成
        --     _itemW["notcomplete_iv"]:setVisible(true)
        --     _itemW["get_ly"]:setVisible(false)
        -- elseif isEnough == 1 then  --完成可领取
        --     _itemW["notcomplete_iv"]:setVisible(false)
        --     _itemW["get_ly"]:setVisible(true)
        -- end   

        local changeButtonState = function(status)

            if status == 0 then--未完成
                _itemW["notcomplete_iv"]:setVisible(true)
                _itemW["get_ly"]:setVisible(false)
                _itemW["comming_ly"]:setVisible(false)
            elseif status == 2 then   --完成可领取
                _itemW["notcomplete_iv"]:setVisible(false)
                _itemW["get_ly"]:setVisible(true)
                _itemW["comming_ly"]:setVisible(false)    
            elseif status == 1 then--已领取
                _itemW["notcomplete_iv"]:setVisible(false)
                _itemW["get_ly"]:setVisible(false)
                _itemW["comming_ly"]:setVisible(true)

                local Text_1 = _itemW["get_ly"]:getChildByName("Text_1")

                if  v["taskName"] == "玩家绑定" then
                    _itemW["get_ly"]:setVisible(true)
                    _itemW["comming_ly"]:setVisible(false)
                    Text_1:setString("查看")
                else
                    Text_1:setString("已领取")
                end

            end    
        end

        changeButtonState(status)

        _itemW["get_ly"]:addTouchEventListener(
            function(sender,event)
                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    sender:setScale(1.0)

                    local params = {}
                    params["userId"] = USER_INFO["uid"]
                    params["taskId"] = v["taskId"]
                    params["squence"] = v["squence"]
                    params["interfaceType"] = "J"
                    cct.createHttRq({
                        url=HttpAddr .. "/task/playerApplyTask",
                        date= params,
                        type_="POST",
                        callBack = function(data)
                            
                            data_netData = json.decode(data["netData"])
                            dump(data_netData,"----完成任务返回数据----")

                            if data_netData.returnCode == "0" then

                                if  data_netData.data == "升级代理成功!!"  then
                                    local officialAccountQRcode = require("hall.GameCommon"):downloadNetworkPic(v["gift"])
                                    local officialAccountQRcodeImg = ccui.ImageView:create(officialAccountQRcode)
                                          officialAccountQRcodeImg:setPosition(cc.p(640,360))
                                          -- officialAccountQRcodeImg:setPositionPercent(cc.p(0.5,1))

                                    local mask = ccui.Layout:create():addTo(officialAccountQRcodeImg)
                                    local contentSize  = officialAccountQRcodeImg:getContentSize()
                                          mask:setAnchorPoint(cc.p(0.5,0.5))
                                          mask:setPosition(cc.p(contentSize.width/2,contentSize.height/2))
                                          -- mask:setPositionPercent(cc.p(0.5,0.5)) 
                                          mask:setContentSize(cc.size(1280,720))
                                          mask:setTouchEnabled(true)
                                          mask:addTouchEventListener(function(sender,event)

                                                if event == TOUCH_EVENT_ENDED then
                                                    officialAccountQRcodeImg:removeFromParent()
                                                end

                                          end)

                                    SCENENOW["scene"]:addChild(officialAccountQRcodeImg)

                                    require(CommonTips_filePath):showTips("提示", "", 3,"您已获得代理资格！请用另一台手机扫描二维码注册成为代理（也可截图保存，长按截图进行识别）")

                                elseif  data_netData.data  and data_netData.data ~= "" then

                                    local msg = data_netData.data

                                    if  data_netData.data.msg then
                                        msg = data_netData.data.msg
                                    end

                                    require(CommonTips_filePath):showTips("消息", "", 3,msg)

                                else
                                    require(CommonTips_filePath):showTips("消息", "", 3,"成功领取奖励")
                                end

                                require(GameScene_filePath):queryRoomCardCount()

                                changeButtonState(1)

                                v["status"] = "1"
                                -- self:getMissionData()

                            elseif data_netData.returnCode == "2" then

                                local msg = data_netData.data
                                if type(msg) == "string" then
                                    require(CommonTips_filePath):showTips("消息", "", 3,msg)
                                end
                                
                            end   

                        end

                    })
                   
                end

            end
            )

        _w["task_list"]:pushBackCustomItem(itemLayout)
        _w["task_list"]:jumpToTop()

    end    


end    

--获取子控件table
function missionScene:loadChildrenWidget(_node, _childrenTable)
    local function func(node, childrenTable)
        if node ~= nil and node:getChildrenCount() <= 0 then return end
        local cTable = node:getChildren()
        for i, v in ipairs(cTable) do
            childrenTable[v:getName()] = v
            func(v, childrenTable)
        end
    end
    if _childrenTable == nil then _childrenTable = {} end
    func(_node, _childrenTable)
    return _childrenTable
end



function missionScene:removeScene()

	local s = SCENENOW["scene"]:getChildByName("missionScene")
    if s then
        s:removeSelf()
    end

end

return missionScene