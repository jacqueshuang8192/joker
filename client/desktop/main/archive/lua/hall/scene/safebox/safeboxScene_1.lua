local safeboxScene = class("safeboxScene")

local state
local gold_tf

local tbNumber = {}
local numPos = 0

function safeboxScene:showScene()

	if SCENENOW["scene"] ~= nil then

        self:removeScene()

	    local s = cc.CSLoader:createNode(SafeBoxSceneCsb_filePath)
	    s:setName("safeboxScene")
	    SCENENOW["scene"]:addChild(s)
        action = cc.CSLoader:createTimeline(SafeBoxSceneCsb_filePath)
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

     --    local Image_1 = root_ly:getChildByName("Image_1")
	    -- Image_1:setTouchEnabled(true)
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

        --保险箱金币数
        local gold_tt = root_ly:getChildByName("gold_tt")
        if USER_INFO["repositoryMony"] ~= nil or USER_INFO["repositoryMony"] ~= "" then
            gold_tt:setString(require(NumberUtil_filePath):toWan(USER_INFO["repositoryMony"], 99999))
        end

        local save_ly = root_ly:getChildByName("save_ly")
	    save_ly:setTouchEnabled(true)
	    local save_iv = save_ly:getChildByName("Image_3")
	    
        local out_ly = root_ly:getChildByName("out_ly")
        out_ly:setTouchEnabled(true)
        local out_iv = out_ly:getChildByName("Image_3")

        save_ly:addTouchEventListener(

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

                	save_iv:loadTexture(SafeBox_Select_S_filePath)
                	out_iv:loadTexture(SafeBox_Select_N_filePath)

                	state = 0

                end

            end

        )

	    out_ly:addTouchEventListener(

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

                	save_iv:loadTexture(SafeBox_Select_N_filePath)
                	out_iv:loadTexture(SafeBox_Select_S_filePath)

                	state = 1

                end

            end

        )

	    --金额输入框
        gold_tf = root_ly:getChildByName("gold_tf")

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

            tbBtnNumbers[i] = root_ly:getChildByName(str)

        end

        --重输
        local btn_submit = root_ly:getChildByName("btn_submit")

        --删除
        local btn_del = root_ly:getChildByName("btn_del")

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

                    self:save2repository(USER_INFO["uid"], gold_tf:getString(), state)

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

    end

end

function safeboxScene:save2repository(playerId, count, type)

    if count == nil or count == "" then
        require(CommonTips_filePath):showTips("提示", "", 3, "请输入金币数")
        return
    end
    
    local params = {}
    params["playerId"] = playerId
    params["count"] = count
    params["type"] = type

    local msg
    if type == 0 then
        msg = "正在存入金币"

    elseif type == 1 then
        msg = "正在取出金币"

    end

    cct.createHttRq({
        url = HttpAddr .. "/gold/save2repository",
        date = params,
        type_= "POST",
        requestMsg = msg,
        callBack = function(data)

            local responseData = data.netData
            if responseData then

                responseData = json.decode(responseData)
                dump(responseData, "-----存取金币返回-----")

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

function safeboxScene:updataGold()

    local s = SCENENOW["scene"]:getChildByName("safeboxScene")
    if s then
        local root_ly = s:getChildByName("root_ly")
        local gold_tt = root_ly:getChildByName("gold_tt")
        if USER_INFO["repositoryMony"] ~= nil or USER_INFO["repositoryMony"] ~= "" then
            gold_tt:setString(require(NumberUtil_filePath):toWan(USER_INFO["repositoryMony"], 99999))
        end
    end

end

function safeboxScene:removeScene()

	local s = SCENENOW["scene"]:getChildByName("safeboxScene")
    if s then
        s:removeSelf()
    end

end

return safeboxScene