
local verifyScene = class("verifyScene")

function verifyScene:showScene()

    self:removeScene()

    local s
    s = cc.CSLoader:createNode(VerifyLayer_filePath):addTo(SCENENOW["scene"],99999)
    s:setName("verifyScene")
    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
        s:setScale(0.75)
    end
    DESIGN_SCREEN_WIDTH  = 1920
    DESIGN_SCREEN_HEIGHT = 1080

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

    s:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)


    local layerEnter = s:getChildByName("root_ly")

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

    local Panel_1 = s:getChildByName("Panel_1")
    Panel_1:addTouchEventListener(
        function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_ENDED then

                self:removeScene()

            end

        end
    )

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
    local btn_exit = s:getChildByName("btn_exit")

    local join_bg_iv = layerEnter:getChildByName("join_bg_iv")
    join_bg_iv:setTouchEnabled(true)

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
                            print("verifyCode:", strCode)
                            -- require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], strCode, "", false, level, false)

                            require(Request_filePath):verifyByUid(strCode)

                        end
                    end
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
                    -- setSubmit(false)
                end
            end

            if sender == btn_exit then
                self:removeScene()
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
    btn_exit:addTouchEventListener(touchButtonEvent)

end

function verifyScene:removeScene()

	local s = SCENENOW["scene"]:getChildByName("verifyScene")
    if s then
        s:removeSelf()
    end

end

return verifyScene
