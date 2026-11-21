
local groupJoin = class("groupJoin")
local action
local joinroom_csb_path = "hall/res/csb/group/enter_room.csb"

--密码房进入输入密码界面
function groupJoin:showInputPasswordScene(typ, ... )

    local level = 0

    local doFunc = ...
    local tip_1
    local tip_2

    self:removeScene()
    self:removeInputPasswordScene()

    local s = cc.CSLoader:createNode("hall/scene/res/" .. resFolder .. "/group/join/enter_encrypt_room.csb"):addTo(SCENENOW["scene"],19999)
          s:setScale(1280/1920)

    -- action = cc.CSLoader:createTimeline(JoinGroupCsb_filePath)
    -- s:runAction(action)
    -- action:gotoFrameAndPlay(0,25,false)

    s:setName("enter_encrypt_room")

    local layerEnter = s:getChildByName("root_ly")

    local Image_3 = layerEnter:getChildByName("Image_3") --标题
    -- Image_3:loadTexture("hall/scene/res/" .. resFolder .. "/image/group/join/title_inputPssword.png") 
    local Text_43 = layerEnter:getChildByName("Text_43")  --提示
    local Text_43_0 = layerEnter:getChildByName("Text_43_0") --小提示
    local btn_create = layerEnter:getChildByName("btn_create") --创建按钮

    if typ == nil or typ == "join" then
        tip_1 = "请输入房间密码"
        tip_2 = "*输入正确密码后，将自动加入房间"
        Text_43_0:setVisible(true)
        btn_create:setVisible(false)
    elseif typ == "create" then
        tip_1 = "请输入房间密码"
        tip_2 = "*输入6密码后，将自动加入房间"
        Text_43_0:setVisible(false)
        btn_create:setVisible(true)
    end

    local strCode = ""  --密码
    local tbNumber = {}

    btn_create:addTouchEventListener(function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸结束
            if event == TOUCH_EVENT_CANCELLED then
                sender:setScale(0.9)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(0.9)

                if #tbNumber == 6 then

                    doFunc(strCode)

                elseif  #tbNumber == 0 then

                    local txts = {}
                    txts["title"] = "提示"
                    txts["sureBt_txt"] = "确定"
                    txts["cancelBt_txt"] = "取消"
                    txts["msg"] = "是否直接创建不加密房?"

                    local customfunc = {} 
                    customfunc["sure_func"] = function() 
                        doFunc()
                    end

                    require("hall.GameTips"):showCustomTips(txts,customfunc,1)

                else

                    local txts = {}
                    txts["title"] = "提示"
                    txts["sureBt_txt"] = "确定"
                    txts["cancelBt_txt"] = "取消"
                    txts["msg"] = "密码设置错误，是否直接创建不加密房?"

                    local customfunc = {} 
                    customfunc["sure_func"] = function() 
                        doFunc()
                    end

                    require("hall.GameTips"):showCustomTips(txts,customfunc,1)
                end
            end

        end)

    Text_43:setString(tip_1)
    Text_43_0:setString(tip_2)

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
                
                self:removeInputPasswordScene()

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
    local btn_exit = layerEnter:getChildByName("btn_exit")

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
                            strCode = ""
                            for i = 1, 6 do
                                strCode = strCode..tostring(tbNumber[i])
                            end

                            if typ == nil or typ == "join" then
                                print("inviteCode1:",strCode)
                                doFunc(strCode)
                            end
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
                
                self:removeInputPasswordScene()
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

function groupJoin:removeInputPasswordScene()

    local s = SCENENOW["scene"]:getChildByName("enter_encrypt_room")
    if s then
        --action:setAnimationEndCallFunc("animation1", function() print("ssssssssssssssssss") s:removeSelf() end)
        s:removeSelf()
    end
end


function groupJoin:showScene()

    local level = 0

    self:removeScene()

    local s = cc.CSLoader:createNode(joinroom_csb_path):addTo(SCENENOW["scene"],19999)
          -- s:setScale(1280/1920)

    action = cc.CSLoader:createTimeline(joinroom_csb_path)
    -- action:retain()
    s:runAction(action)
    action:gotoFrameAndPlay(0,25,false)
    
    s:setName("enter_room")

    local layerEnter = s:getChildByName("root_ly")

    local tbNumber = {}
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
    local btn_close = layerEnter:getChildByName("btn_close")
    local btn_paste = layerEnter:getChildByName("btn_paste")

    local join_bg_iv = layerEnter:getChildByName("join_bg_iv")
    join_bg_iv:setTouchEnabled(true)

    -- --设置确定按钮状态
    -- local function setSubmit(flag)
    --     if btn_submit then
    --         btn_submit:setEnabled(flag)
    --         if flag == false then
    --             btn_submit:loadTextureNormal("hall/common/small_disable_bt_n.png")
    --             -- btn_submit:setColor(cc.c3b(125,125,125))
    --         else
    --             btn_submit:loadTextureNormal("hall/common/setting_yellow_bt.png")
    --             -- btn_submit:setColor(cc.c3b(255,255,255))
    --         end
    --     end
    -- end
    -- setSubmit(false)

    --按钮事件
    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if #tbNumber < 6 then
                for i=1,10 do
                    if sender == tbBtnNumbers[i] then
                        local numPos = #tbNumber + 1
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
                            print("inviteCode1:",strCode)
                            require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], strCode, "", false, level, false)
                        end
                    end
                end
            end

            --重输
            if sender == btn_submit then

                tbNumber = {}
                reFresh()

            end

            --删除
            if sender == btn_del then
                table.remove(tbNumber)
                reFresh()
                    -- setSubmit(false)
            end

            if sender == btn_paste then

                local clipText = require("hall.util.GameMenu"):getRoomIdFromClipText()
                
                if clipText then
                    -- clipText = tostring(clipText）

                    local k = #clipText
                    for i = 1,k do
                        local str = "num_box_"..tostring(i)
                        local txt = layerEnter:getChildByName(str):getChildByName("Text_1")

                        local numberStr = string.sub(clipText,i,i)
                        txt:setString(numberStr) 
                        tbNumber[i] = tonumber(numberStr)
                    end

                    require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], clipText, "", false, 0, false)
                end

            end

            if sender == btn_close then
    
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
    btn_close:addTouchEventListener(touchButtonEvent)
    btn_paste:addTouchEventListener(touchButtonEvent)

end



function groupJoin:removeScene()

	local s = SCENENOW["scene"]:getChildByName("enter_room")
    if tolua.isnull(s) == false then
        action:gotoFrameAndPlay(25,45,false)
        --action:setAnimationEndCallFunc("animation1", function() print("ssssssssssssssssss") s:removeSelf() end)
        s:removeSelf()
    end
	
end

function groupJoin:action1()
    local s = SCENENOW["scene"]:getChildByName("enter_room")
    s:removeSelf()
end    

return groupJoin