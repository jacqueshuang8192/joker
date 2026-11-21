local namecheckScene = class("namecheckScene")

function namecheckScene:showScene()

	if SCENENOW["scene"] ~= nil then

        self:removeScene()

	    local s = cc.CSLoader:createNode(NameCheckSceneCsb_filePath)
	    s:setName("namecheckScene")
	    SCENENOW["scene"]:addChild(s)
        action = cc.CSLoader:createTimeline(NameCheckSceneCsb_filePath)
        action:retain()
        s:runAction(action)
        action:gotoFrameAndPlay(0, 25, false)

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

        --名字
        local name_ly = root_ly:getChildByName("name_ly")
        local name_tf = name_ly:getChildByName("input_tf")

        --身份证
        local id_ly = root_ly:getChildByName("id_ly")
        local id_tf = id_ly:getChildByName("input_tf")

        --手机号
        local phone_ly = root_ly:getChildByName("phone_ly")
        local phone_tf = phone_ly:getChildByName("input_tf")

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

                    local name = name_tf:getString()
                    local id = id_tf:getString()
                    local phone = phone_tf:getString()

                    self:authIdCard(USER_INFO["uid"], name, id, phone)

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

function namecheckScene:authIdCard(uid, name, idCardNo, phone)

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
        url = HttpAddr .. "/gold/authIdCard",
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

function namecheckScene:removeScene()

	local s = SCENENOW["scene"]:getChildByName("namecheckScene")
    if s then
        s:removeSelf()
    end

end

return namecheckScene