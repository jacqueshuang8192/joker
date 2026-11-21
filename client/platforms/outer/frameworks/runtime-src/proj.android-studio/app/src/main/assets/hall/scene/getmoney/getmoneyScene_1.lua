local getmoneyScene = class("getmoneyScene")

local state
local gold_tf

local tbNumber = {}
local numPos = 0

local bill_sv
local bill_content_ly
local totalincome_tt

function getmoneyScene:showScene()

	if SCENENOW["scene"] ~= nil then

        self:removeScene()

	    local s = cc.CSLoader:createNode(GetMoneySceneCsb_filePath)
	    s:setName("getmoneyScene")
	    SCENENOW["scene"]:addChild(s)
        action = cc.CSLoader:createTimeline(GetMoneySceneCsb_filePath)
        action:retain()
        s:runAction(action)
        action:gotoFrameAndPlay(0, 25, false)

        state = 0

	    local Panel_1 = s:getChildByName("Panel_1")
	    Panel_1:setTouchEnabled(true)
	    Panel_1:addTouchEventListener(

            function(sender,event)

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
        )

        local root_ly = s:getChildByName("root_ly")

        local Image_1 = root_ly:getChildByName("Image_1")
        Image_1:setTouchEnabled(true)
        Image_1:addTouchEventListener(

            function(sender,event)

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

                end

            end
        )

        local getmoney_bt = root_ly:getChildByName("getmoney_bt")
        local getmoney_ly = root_ly:getChildByName("getmoney_ly")

        local bill_bt = root_ly:getChildByName("bill_bt")
        local bill_ly = root_ly:getChildByName("bill_ly")

        getmoney_bt:loadTextures(GetMoney_Select_S_filePath, nil, nil)
        bill_bt:loadTextures(Bill_Select_N_filePath, nil, nil)

        getmoney_ly:setVisible(true)
        bill_ly:setVisible(false)

        getmoney_bt:setTouchEnabled(true)
        getmoney_bt:addTouchEventListener(

            function(sender,event)

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

                    getmoney_bt:loadTextures(GetMoney_Select_S_filePath, nil, nil)
                    bill_bt:loadTextures(Bill_Select_N_filePath, nil, nil)

                    getmoney_ly:setVisible(true)
                    bill_ly:setVisible(false)

                    state = 0

                end

            end
        )
        
        bill_bt:setTouchEnabled(true)
        bill_bt:addTouchEventListener(

            function(sender,event)

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

                    getmoney_bt:loadTextures(GetMoney_Select_N_filePath, nil, nil)
                    bill_bt:loadTextures(Bill_Select_S_filePath, nil, nil)

                    getmoney_ly:setVisible(false)
                    bill_ly:setVisible(true)

                    state = 1

                end

            end
        )

        ----------------------------------------------------提现部分-----------------------------------------------------------
        --总收益
        local gold_tt_0 = getmoney_ly:getChildByName("gold_tt_0")
        if USER_INFO["goldCount"] ~= nil or USER_INFO["goldCount"] ~= "" then
            gold_tt_0:setString(require(NumberUtil_filePath):toWan(USER_INFO["goldCount"], 99999))
        end

        --当前收益
        local gold_tt = getmoney_ly:getChildByName("gold_tt")
        if USER_INFO["owerIncome"] ~= nil or USER_INFO["owerIncome"] ~= "" then
            gold_tt:setString(require(NumberUtil_filePath):toWan(USER_INFO["owerIncome"], 99999))
        end

	    --金额输入框
        gold_tf = getmoney_ly:getChildByName("gold_tf")

        tbNumber = {}
        numPos = 0
        local str = 1
        local function reFresh()
            
            if numPos == 0 then
                gold_tf:setString("")

            else

                gold_tf:setString("")

                for k,v in pairs(tbNumber) do
                    gold_tf:setString(gold_tf:getString() .. tostring(v))
                end

            end

        end
        reFresh()

        --按钮
        local tbBtnNumbers = {}
        for i = 1, 10 do

            if i < 10 then
                str = "btn_"..tostring(i)
            else
                str = "btn_0"
            end

            tbBtnNumbers[i] = getmoney_ly:getChildByName(str)

        end

        --重输
        local btn_submit = getmoney_ly:getChildByName("btn_submit")

        --删除
        local btn_del = getmoney_ly:getChildByName("btn_del")

        --全部
        local all_bt = getmoney_ly:getChildByName("all_bt")
        all_bt:addTouchEventListener(

            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    gold_tf:setString(USER_INFO["owerIncome"])

                    tbNumber = {}
                    numPos = 0

                end

            end

        )

        --按钮事件
        local function touchButtonEvent(sender, event)

            if event == TOUCH_EVENT_ENDED then

                for i=1, 10 do

                    if sender == tbBtnNumbers[i] then

                        numPos = numPos + 1
                        tbNumber[numPos] = i

                        if tbNumber[numPos] >= 10 then
                            tbNumber[numPos] = 0
                        end

                        reFresh()

                    end

                end

                --重输
                if sender == btn_submit then

                    tbNumber = {}
                    numPos = 0
                    reFresh()

                end

                --删除
                if sender == btn_del then

                    if numPos > 0 then

                        table.remove(tbNumber,numPos)
                        numPos = numPos - 1
                        reFresh()

                    end

                end

            end

        end

        --按钮注册
        for i = 1,10 do

            if tbBtnNumbers[i] then
                tbBtnNumbers[i]:addTouchEventListener(touchButtonEvent)
            end

        end

        --重输，删除
        btn_submit:addTouchEventListener(touchButtonEvent)
        btn_del:addTouchEventListener(touchButtonEvent)

        ----------------------------------------------------账单部分-----------------------------------------------------------
        --年
        local year_bt = bill_ly:getChildByName("year_bt")
        year_bt:setTouchEnabled(true)
        local year_tt = year_bt:getChildByName("year_tt")
        local year_ly = year_bt:getChildByName("year_ly")
        local year_sv = year_ly:getChildByName("year_sv")
        local year_content_ly = year_sv:getChildByName("content_ly")
        local year_state = 0
        local year_list = {"2017", "2018"}
        local year = os.date("%Y")
        year_tt:setString(year .. "年")

        --月
        local month_bt = bill_ly:getChildByName("month_bt")
        month_bt:setTouchEnabled(true)
        local month_tt = month_bt:getChildByName("month_tt")
        local month_ly = month_bt:getChildByName("month_ly")
        local month_sv = month_ly:getChildByName("month_sv")
        local month_content_ly = month_sv:getChildByName("content_ly")
        local month_state = 0
        local month_list = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"}
        local month = os.date("%m")
        month_tt:setString(month .. "月")

        year_bt:addTouchEventListener(

            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    if year_state == 0 then
                        year_ly:setVisible(true)
                        year_state = 1

                    else
                        year_ly:setVisible(false)
                        year_state = 0

                    end

                    month_ly:setVisible(false)
                    month_state = 0

                end

            end

        )

        month_bt:addTouchEventListener(

            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    if month_state == 0 then
                        month_ly:setVisible(true)
                        month_state = 1

                    else
                        month_ly:setVisible(false)
                        month_state = 0

                    end

                    year_ly:setVisible(false)
                    year_state = 0

                end

            end

        )

        for k,v in pairs(year_list) do
            
            local DateCell = cc.CSLoader:createNode(DateCellScene_filePath)
            DateCell:setPosition(0, 30 * k * -1 - 15)
            year_content_ly:addChild(DateCell)

            local root_ly = DateCell:getChildByName("root_ly")
            local name_tt = root_ly:getChildByName("name_tt")
            name_tt:setString(v)

            --定义一个按钮
            local typeButton = ccui.Button:create()
            typeButton:setTouchEnabled(true)
            typeButton:setAnchorPoint(0.5, 0.5)
            typeButton:loadTextures(DateCellBlank_filePath, nil, nil)
            typeButton:setPosition(50, 31 * k * -1 + 15)
            typeButton:addTouchEventListener(

                function(sender,event)

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then

                        year_tt:setString(v .. "年")

                        year = v

                        year_ly:setVisible(false)
                        year_state = 0

                    end

                end

            )
            year_content_ly:addChild(typeButton, 5000)

        end
        year_sv:setCascadeOpacityEnabled(true)

        for k,v in pairs(month_list) do
            
            local DateCell = cc.CSLoader:createNode(DateCellScene_filePath)
            DateCell:setPosition(0, 30 * k * -1 - 15)
            month_content_ly:addChild(DateCell)

            local root_ly = DateCell:getChildByName("root_ly")
            local name_tt = root_ly:getChildByName("name_tt")
            name_tt:setString(v)

            --定义一个按钮
            local typeButton = ccui.Button:create()
            typeButton:setTouchEnabled(true)
            typeButton:setAnchorPoint(0.5, 0.5)
            typeButton:loadTextures(DateCellBlank_filePath, nil, nil)
            typeButton:setPosition(50, 31 * k * -1 + 15)
            typeButton:addTouchEventListener(

                function(sender,event)

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then

                        month_tt:setString(v .. "月")

                        month = v

                        month_ly:setVisible(false)
                        month_state = 0

                    end

                end

            )
            month_content_ly:addChild(typeButton, 5000)

        end
        month_sv:setCascadeOpacityEnabled(true)
        month_sv:setInnerContainerSize(cc.size(100.00, 30 * #month_list + 15))
        month_content_ly:setPosition(0, 30 * #month_list + 15)

        --查询按钮
        local search_bt = bill_ly:getChildByName("search_bt")
        search_bt:setTouchEnabled(true)
        search_bt:addTouchEventListener(

            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    self:getPlayerCommissionList(USER_INFO["uid"], year, month)

                end

            end

        )

        --返利列表
        bill_sv = bill_ly:getChildByName("bill_sv")
        bill_content_ly = bill_sv:getChildByName("content_ly")
        totalincome_tt = bill_ly:getChildByName("totalincome_tt")

        ----------------------------------------------------底部按钮-----------------------------------------------------------
        --确定按钮
        local sure_bt = root_ly:getChildByName("sure_bt")
        sure_bt:setTouchEnabled(true)
        sure_bt:addTouchEventListener(

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

                    if state == 0 then
                        self:pickUpGold(USER_INFO["uid"], gold_tf:getString())

                    else
                        self:removeScene()

                    end

                end

            end

        )

        --取消按钮
        local cancel_bt = root_ly:getChildByName("cancel_bt")
        cancel_bt:setTouchEnabled(true)
        cancel_bt:addTouchEventListener(

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

                    self:removeScene()

                end

            end

        )

        --查询返利
        self:getPlayerCommissionList(USER_INFO["uid"], year, month)

    end

end

--提取金币
function getmoneyScene:pickUpGold(playerId, count)

    if count == nil or count == "" then
        require(CommonTips_filePath):showTips("提示", "", 3, "请输入金币数")
        return
    end
    
    local params = {}
    params["playerId"] = playerId
    params["count"] = count

    cct.createHttRq({
        url = HttpAddr .. "/gold/pickUpGold",
        date = params,
        type_= "POST",
        requestMsg = "正在提取金币",
        callBack = function(data)

            local responseData = data.netData
            if responseData then

                responseData = json.decode(responseData)
                dump(responseData, "-----提取金币返回-----")

                local returnCode = responseData.returnCode
                if returnCode == "0" then
                    require(CommonTips_filePath):showTips("提示", "", 3, "操作成功！")
                    
                    gold_tf:setString("")
                    tbNumber = {}
                    numPos = 0

                else
                    if responseData.error ~= nil then
                        require(CommonTips_filePath):showTips("提示", "", 3, responseData.error)

                    else
                        require(CommonTips_filePath):showTips("提示", "", 3, "未知错误，操作失败")

                    end

                end

                --更新用户金币数量
                require(GameScene_filePath):queryRoomCardCount()

            end

        end

    })

end

--查询返利
function getmoneyScene:getPlayerCommissionList(playerId, year, month)
    
    local params = {}
    params["playerId"] = playerId
    params["year"] = year
    params["month"] = month

    cct.createHttRq({
        url = HttpAddr .. "/gold/getPlayerCommissionList",
        date = params,
        type_= "POST",
        requestMsg = "",
        callBack = function(data)

            local responseData = data.netData
            if responseData then

                responseData = json.decode(responseData)
                dump(responseData, "-----查询返利返回-----")

                local returnCode = responseData.returnCode
                if returnCode == "0" then

                    bill_content_ly:removeAllChildren()

                    local backdata = responseData.data
                    local count = backdata.count
                    totalincome_tt:setString("总返利：" .. count)

                    local everyDay = backdata.everyDay
                    dump(everyDay, "-----everyDay-----")
                    for k,v in pairs(everyDay) do
            
                        local BillCell = cc.CSLoader:createNode(BillCellScene_filePath)
                        BillCell:setPosition(0, 30 * k * -1)
                        bill_content_ly:addChild(BillCell)

                        local root_ly = BillCell:getChildByName("root_ly")
                        local time_tt = root_ly:getChildByName("time_tt")
                        time_tt:setString(v.date)

                        local gold_tt = root_ly:getChildByName("gold_tt")
                        gold_tt:setString(v.goldCount)

                    end
                    
                    if #everyDay > 5 then
                        bill_sv:setCascadeOpacityEnabled(true)
                        bill_sv:setInnerContainerSize(cc.size(750.00, 30 * #everyDay))
                        bill_content_ly:setPosition(0, 30 * #everyDay)
                    end

                else
                    if responseData.error ~= nil then
                        require(CommonTips_filePath):showTips("提示", "", 3, responseData.error)

                    else
                        require(CommonTips_filePath):showTips("提示", "", 3, "未知错误，操作失败")

                    end

                end

            end

        end

    })

end

--显示剩余收益
function getmoneyScene:updataGold()

    local s = SCENENOW["scene"]:getChildByName("getmoneyScene")
    if s then
        local root_ly = s:getChildByName("root_ly")
        local getmoney_ly = root_ly:getChildByName("getmoney_ly")
        local gold_tt = getmoney_ly:getChildByName("gold_tt")
        if USER_INFO["owerIncome"] ~= nil or USER_INFO["owerIncome"] ~= "" then
            gold_tt:setString(require(NumberUtil_filePath):toWan(USER_INFO["owerIncome"], 99999))
        end
    end

end

function getmoneyScene:removeScene()

	local s = SCENENOW["scene"]:getChildByName("getmoneyScene")
    if s then
        s:removeSelf()
    end

end

return getmoneyScene