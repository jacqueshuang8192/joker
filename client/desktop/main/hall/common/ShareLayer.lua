
local ShareLayer = class("ShareLayer")
local ShareCsb_filePath = "hall/res/share/shareLayer.csb"

function ShareLayer:showShareLayerInHall(title, url, imagePath, desc)

    local title_arr = LuaSplit(title, "，")
    local gameName = title_arr[1]
    local newName = ""
    if gameName ~= nil then

        if gameName == "168斗地主" then
            newName = newName .. "斗地主，" .. title_arr[2]

        elseif gameName == "168牛牛" then
            newName = newName .. "牛牛，" .. title_arr[2]

        elseif gameName == "168跑得快" then
            newName = newName .. "跑得快，" .. title_arr[2]

        else

            if title == "【168麻将】" then
        
                newName = "【" .. appName .. "】"

            elseif title == "【168棋牌】" then
        
                newName = "【" .. appName .. "】"

            else

                newName = title

            end

        end

    end

    if device.platform == "ios" then
        imagePath = device.writablePath .. iOSShareIcon_filePath
        dump(imagePath, "-----分享-----")
    end

    --dump(newName, "-----分享-----")

    local scene = cc.CSLoader:createNode(ShareCsb_filePath):addTo(SCENENOW["scene"])
    scene:setName("shareLayer")
    scene:setLocalZOrder(9999)

    action = cc.CSLoader:createTimeline(ShareCsb_filePath)
    scene:runAction(action)
    action:gotoFrameAndPlay(0,25,false)

    scene:setScale(1)
    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
        scene:setScale(0.75)
    end

    local floor = scene:getChildByName("floor")
    local wx_bt = floor:getChildByName("wx_bt")
    local pyq_bt = floor:getChildByName("pyq_bt")

    if isShareFriend then
        pyq_bt:setVisible(false)
        wx_bt:setPositionX((wx_bt:getParent():getContentSize().width/2))
    end

    -- floor.noScale=true
    -- floor:onClick(function()
    --     scene:removeFromParent()
    -- end)
        
    local function touchEvent(sender, event)
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

            if sender == wx_bt then
                print("share wx")
                local args = {}
                args["channel"] = "wx"
                args["title"] = newName
                if url ~= nil then
                    args["url"] = appDownLoadAddress

                end
        
                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end
                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"wx")
                    table.insert(share_content,newName)
                    if url ~= nil then
                        table.insert(share_content, appDownLoadAddress)

                    else
                        table.insert(share_content,"")
                    end
                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end
                    table.insert(share_content,desc)
                    cct.getDateForApp("share", share_content, "V")
                else
                    cct.getDateForApp("share", args, "V")
                end

                scene:removeFromParent()
                

            elseif sender == pyq_bt then
                print("share pyq")
                local args = {}
                args["channel"] = "pyq"
                args["title"] = newName
                if url ~= nil then
                    args["url"] = appDownLoadAddress

                end
                
                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end
                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"pyq")
                    table.insert(share_content,newName)
                    if url ~= nil then
                        table.insert(share_content, appDownLoadAddress)

                    else
                        table.insert(share_content,"")
                    end
                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end
                    table.insert(share_content,desc)
                    cct.getDateForApp("share", share_content, "V")
                else
                    cct.getDateForApp("share", args, "V")
                end

                scene:removeFromParent()

            end
        end
    end

    wx_bt:addTouchEventListener(touchEvent)
    pyq_bt:addTouchEventListener(touchEvent)

    --取消按钮
    local cancel_bt = floor:getChildByName("cancel_bt")
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

                scene:removeFromParent()

            end

        end
    )

end

function ShareLayer:showShareLayer(title, url, imagePath, desc)

    --add by zzy 将愿来得代码重新加入
    local title_arr = LuaSplit(title, "，")
    local gameName = title_arr[1]
    local newName = ""
    if gameName ~= nil then

        if gameName == "168斗地主" then
            newName = newName .. "斗地主，" .. title_arr[2]

        elseif gameName == "168牛牛" then
            newName = newName .. "牛牛，" .. title_arr[2]

        elseif gameName == "168跑得快" then
            newName = newName .. "跑得快，" .. title_arr[2]

        else

            if title == "【168麻将】" then
        
                newName = "【" .. appName .. "】"

            elseif title == "【168棋牌】" then
        
                newName = "【" .. appName .. "】"

            else

                newName = title

            end

        end

    end

    if device.platform == "ios" then
        -- imagePath = device.writablePath .. "hall/images/shareicon.png"
        imagePath = device.writablePath .. iOSShareIcon_filePath
        dump(imagePath, "-----分享-----")
    end

    --dump(newName, "-----分享-----")

    local scene = cc.CSLoader:createNode(ShareCsb_filePath):addTo(SCENENOW["scene"])
    scene:setName("shareLayer")
    scene:setLocalZOrder(9999)

    action = cc.CSLoader:createTimeline(ShareCsb_filePath)
    scene:runAction(action)
    action:gotoFrameAndPlay(0,25,false)

    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
        scene:setScale(0.75)
    end

    local floor = scene:getChildByName("bg")
    local bg = scene:getChildByName("bg")

    local wx_bt = floor:getChildByName("btnToFriend")
    local pyq_bt = floor:getChildByName("btnToQuan")

    if isShareFriend then
        pyq_bt:setVisible(false)
        wx_bt:setPositionX((wx_bt:getParent():getContentSize().width/2))
    end

    floor.noScale=true
    floor:onClick(function()
        scene:removeFromParent()
    end)
        
    local function touchEvent(sender, event)
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

            if sender == wx_bt then
            
                print("share wx")
                local args = {}
                args["channel"] = "wx"
                args["title"] = newName

                if url ~= nil then
                    args["url"] = moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"]
                
                    -- args["url"] = appDownLoadAddress

                end

                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end
                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"wx")
                    table.insert(share_content,newName)
                    if url ~= nil then
                        table.insert(share_content, moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"])
                    
                        -- table.insert(share_content, appDownLoadAddress)

                    else
                        table.insert(share_content,"")
                    end
                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end
                    table.insert(share_content,desc)
                    cct.getDateForApp("share", share_content, "V")
                else
                    cct.getDateForApp("share", args, "V")
                end

                scene:removeFromParent()
                

            elseif sender == pyq_bt then

                print("share pyq")
                local args = {}
                args["channel"] = "pyq"
                args["title"] = newName

                if url ~= nil then
                    args["url"] = moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"]
                
                    -- args["url"] = appDownLoadAddress

                end
                
                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end

                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"pyq")
                    table.insert(share_content,newName)

                    if url ~= nil then
                        table.insert(share_content, moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"])
                    
                        -- table.insert(share_content, appDownLoadAddress)

                    else
                        table.insert(share_content,"")
                    end

                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end

                    table.insert(share_content,desc)

                    cct.getDateForApp("share", share_content, "V")

                else
                    cct.getDateForApp("share", args, "V")
                end

                scene:removeFromParent()

            end
        end
    end

    wx_bt:addTouchEventListener(touchEvent)
    pyq_bt:addTouchEventListener(touchEvent)

    --取消按钮
    local cancel_bt = bg:getChildByName("btnClose")
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

                scene:removeFromParent()

            end

        end
    )

    -- local paras = {}
    -- paras.showType = 2
    -- paras.name = title
    -- paras.url = url
    -- paras.imagePath = imagePath
    -- paras.desc = desc

    -- local shareLayer = require("hall.share.ShareLayer").new(paras)
    -- if shareLayer then
    --     shareLayer:addTo(SCENENOW["scene"])
    -- end

    -- local title_arr = LuaSplit(title, "，")
    -- local gameName = title_arr[1]
    -- local newName = title

    -- if device.platform == "ios" then
    --     imagePath = device.writablePath .. iOSShareIcon_filePath
    --     dump(imagePath, "-----分享-----")
    -- end

    -- local scene = cc.CSLoader:createNode(ShareCsb_filePath):addTo(SCENENOW["scene"])
    -- scene:setName("shareLayer")
    -- scene:setLocalZOrder(9999)

    -- action = cc.CSLoader:createTimeline(ShareCsb_filePath)
    -- scene:runAction(action)
    -- action:gotoFrameAndPlay(0,25,false)

    -- if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
    --     scene:setScale(0.75)
    -- end

    -- local floor = scene:getChildByName("floor")
    -- local wx_bt = floor:getChildByName("wx_bt")
    -- local pyq_bt = floor:getChildByName("pyq_bt")

    -- if isShareFriend then
    --     pyq_bt:setVisible(false)
    --     wx_bt:setPositionX((wx_bt:getParent():getContentSize().width/2))
    -- end

    -- floor.noScale=true
    -- floor:onClick(function()
    --     scene:removeFromParent()
    -- end)
        
    -- local function touchEvent(sender, event)
    --     if event == TOUCH_EVENT_CANCELED then
    --         sender:setScale(1.0)
    --     end

    --     if event == TOUCH_EVENT_ENDED then
    --         sender:setScale(1.0)
    --         require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

    --         if sender == wx_bt then
            
    --             print("share wx")
    --             local args = {}
    --             args["channel"] = "wx"
    --             args["title"] = newName

    --             if url ~= nil then
    --                 args["url"] = moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"]
    --             end

    --             if imagePath ~= nil then
    --                 --todo
    --                 args["imagePath"] = imagePath
    --             end
    --             args["desc"] = desc

    --             if device.platform=="android" then
    --                 local share_content = {}
    --                 table.insert(share_content,"wx")
    --                 table.insert(share_content,newName)
    --                 if url ~= nil then
    --                     table.insert(share_content, moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"])
    --                 else
    --                     table.insert(share_content,"")
    --                 end
    --                 if imagePath ~= nil then
    --                     table.insert(share_content,imagePath)
    --                 else
    --                     table.insert(share_content,"")
    --                 end
    --                 table.insert(share_content,desc)
    --                 cct.getDateForApp("share", share_content, "V")
    --             else
    --                 cct.getDateForApp("share", args, "V")
    --             end

    --             scene:removeFromParent()

    --         elseif sender == pyq_bt then

    --             print("share pyq")
    --             local args = {}
    --             args["channel"] = "pyq"
    --             args["title"] = newName

    --             if url ~= nil then
    --                 args["url"] = moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"]
    --             end
                
    --             if imagePath ~= nil then
    --                 --todo
    --                 args["imagePath"] = imagePath
    --             end

    --             args["desc"] = desc

    --             if device.platform=="android" then
    --                 local share_content = {}
    --                 table.insert(share_content,"pyq")
    --                 table.insert(share_content,newName)

    --                 if url ~= nil then
    --                     table.insert(share_content, moChuanMLink .. "?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"])
    --                 else
    --                     table.insert(share_content,"")
    --                 end

    --                 if imagePath ~= nil then
    --                     table.insert(share_content,imagePath)
    --                 else
    --                     table.insert(share_content,"")
    --                 end

    --                 table.insert(share_content,desc)

    --                 cct.getDateForApp("share", share_content, "V")

    --             else
    --                 cct.getDateForApp("share", args, "V")
    --             end

    --             scene:removeFromParent()

    --         end
    --     end
    -- end

    
end

function ShareLayer:showShareLayerWithDaiKai(title, invote_code, activity_id, level, imagePath, desc)


   local title_arr = LuaSplit(title, "，")
    local gameName = title_arr[1]
    local newName = ""
    if gameName ~= nil then

        if gameName == "168斗地主" then
            newName = newName .. "斗地主，" .. title_arr[2]

        elseif gameName == "168牛牛" then
            newName = newName .. "牛牛，" .. title_arr[2]

        elseif gameName == "168跑得快" then
            newName = newName .. "跑得快，" .. title_arr[2]

        else

            if title == "【168麻将】" then
        
                newName = "【" .. appName .. "】"

            elseif title == "【168棋牌】" then
        
                newName = "【" .. appName .. "】"

            else
                print("#####Share : " .. title)
                newName = title

            end

        end

    end

    if device.platform == "ios" then
        -- imagePath = device.writablePath .. "hall/images/shareicon.png"
        imagePath = device.writablePath .. iOSShareIcon_filePath
        dump(imagePath, "-----分享-----")
    end

    --dump(newName, "-----分享-----")

    local scene = cc.CSLoader:createNode(ShareCsb_filePath):addTo(SCENENOW["scene"])
    scene:setName("shareLayer")
    scene:setLocalZOrder(9999)
    action = cc.CSLoader:createTimeline(ShareCsb_filePath)
    scene:runAction(action)
    action:gotoFrameAndPlay(0,25,false)

    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
        scene:setScale(0.75)
    end

    local floor = scene:getChildByName("bg")
    local bg = scene:getChildByName("bg")
    local wx_bt = floor:getChildByName("btnToFriend")
    local pyq_bt = floor:getChildByName("btnToQuan")

    floor.noScale=true
    floor:onClick(function()
        scene:removeFromParent()
    end)
        
    local function touchEvent(sender, event)
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

            if sender == wx_bt then
            
                print("share wx")
                local args = {}
                args["channel"] = "wx"
                args["title"] = newName

                -- if url ~= nil then
                    print("@@@@@@@@ share2: " .. moChuanMLink.. " " .. invote_code .." " ..activity_id .. " " .. level)
                    args["url"] = moChuanMLink .. "?invitationCode=" .. invote_code .. "&activityId=" .. activity_id .. "&level=" .. level
                --end

                -- args["url"] = appDownLoadAddress

                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end
                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"wx")
                    table.insert(share_content,newName)
                    --if url ~= nil then
                        table.insert(share_content, moChuanMLink .. "?invitationCode=" .. invote_code .. "&activityId=" .. activity_id .. "&level=" .. level)
                    -- else
                    --   table.insert(share_content,"")
                    --end

                    -- table.insert(share_content, appDownLoadAddress)

                    if imagePath ~= nil then
                        print("shareType is "..imagePath)
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end
                    table.insert(share_content,desc)
                    cct.getDateForApp("share", share_content, "V")
                else
                    cct.getDateForApp("share", args, "V")
                end

                scene:removeFromParent()
                

            elseif sender == pyq_bt then

                print("share pyq")
                local args = {}
                args["channel"] = "pyq"
                args["title"] = newName

                if url ~= nil then
                    args["url"] = moChuanMLink .. "?invitationCode=" .. invote_code .. "&activityId=" .. activity_id .. "&level=" .. level
                
                    -- args["url"] = appDownLoadAddress

                end
                
                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end

                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"pyq")
                    table.insert(share_content,newName)

                    if url ~= nil then
                        table.insert(share_content, moChuanMLink .. "?invitationCode=" .. invote_code .. "&activityId=" .. activity_id .. "&level=" .. level)
                    
                        -- table.insert(share_content, appDownLoadAddress)

                    else
                        table.insert(share_content,"")
                    end

                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end

                    table.insert(share_content,desc)

                    cct.getDateForApp("share", share_content, "V")

                else
                    cct.getDateForApp("share", args, "V")
                end

                scene:removeFromParent()

            end
        end
    end

    wx_bt:addTouchEventListener(touchEvent)
    pyq_bt:addTouchEventListener(touchEvent)

    --取消按钮
    local cancel_bt = bg:getChildByName("btnClose")
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

                scene:removeFromParent()

            end

        end
    )
    
end

function ShareLayer:captureScreenAndShare(pngName,channel,title,desc,imagePath)

    pngName = tostring(pngName) or "gameScreen.png"
    channel = tostring(channel) or "wx"
    title = tostring(title) or "我的战果"
    desc = tostring(desc) or "快来一起玩吧"
    imagePath = imagePath or ""

    local args = {}
    args["channel"] = channel
    args["title"] = title
    args["desc"] = desc
    print("luaCall 截屏",png_name)

    if device.platform=="android" then

        local share_content = {}
        table.insert(share_content,channel)
        table.insert(share_content,title)
        table.insert(share_content,"")
        table.insert(share_content,imagePath)
        table.insert(share_content,desc)
        cct.getDateForApp("share", share_content, "V")
        
    else

        local function afterCaptured(succeed,sp_png)
            if succeed then
                print("截屏success",sp_png)
                args["imagePath"] = sp_png
                cct.getDateForApp("shareGroupResult", args, "V")
            end
        end

        cc.utils:captureScreen(afterCaptured,pngName)

    end

end

function ShareLayer:shareGroupResultForIOS()

    local paras = {}
    paras.showType = 2
    paras.name = "我的战果"
    paras.url = url
    paras.imagePath = imagePath
    paras.desc = desc

    local function afterCaptured(succeed,sp_png)
        if succeed then
            print("截屏success",sp_png)
            paras.imagePath = sp_png
            cct.getDateForApp("shareGroupResult", args, "V")
        end
    end
    cc.utils:captureScreen(afterCaptured,"gameScreen.png")
                
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"])
        return 
    end

    local scene = cc.CSLoader:createNode(ShareCsb_filePath):addTo(SCENENOW["scene"])
    scene:setName("shareLayer")
    scene:setLocalZOrder(9999)
    action = cc.CSLoader:createTimeline(ShareCsb_filePath)
    scene:runAction(action)
    action:gotoFrameAndPlay(0,25,false)
    if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
        scene:setScale(0.75)
    end

    local floor = scene:getChildByName("bg")
    local bg = scene:getChildByName("bg")
    local wx_bt = floor:getChildByName("btnToFriend")
    local pyq_bt = floor:getChildByName("btnToQuan")

    floor.noScale=true
    floor:onClick(function()
        scene:removeFromParent()
    end)
        
    local function touchEvent(sender, event)
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

            if sender == wx_bt then
                print("share wx")
                local args = {}
                args["channel"] = "wx"
                args["title"] = "我的战果"
                if url ~= nil then
                    --todo
                    args["url"] = url
                end
        
                args["desc"] = "快来一起玩吧"

                print("luaCall 截屏",png_name)
                

                scene:removeFromParent()
                

            elseif sender == pyq_bt then
                print("share pyq")
                local args = {}
                args["channel"] = "pyq"
                args["title"] = "我的战果"
                if url ~= nil then
                    --todo
                    args["url"] = url
                end
        
                args["desc"] = "快来一起玩吧"

                print("luaCall 截屏",png_name)
                local function afterCaptured(succeed,sp_png)
                    if succeed then
                        print("截屏success",sp_png)
                        args["imagePath"] = sp_png
                        cct.getDateForApp("shareGroupResult", args, "V")
                    end
                end
                cc.utils:captureScreen(afterCaptured,"gameScreen.png")

                scene:removeFromParent()
            end
        end
    end

    wx_bt:addTouchEventListener(touchEvent)
    pyq_bt:addTouchEventListener(touchEvent)

    --取消按钮
    local cancel_bt = bg:getChildByName("btnClose")
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

                scene:removeFromParent()

            end

        end
    )

    
end


function ShareLayer:showShareLayerForBinding(title, url, imagePath, desc, wx_bt, pyq_bt)

    local newName = title

    if device.platform == "ios" then
        imagePath = device.writablePath .. iOSShareIcon_filePath
        dump(imagePath, "-----分享-----")
    end


    local function touchEvent(sender, event)

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

            if sender == wx_bt then
                print("share wx")
                local args = {}
                args["channel"] = "wx"
                args["title"] = newName
                if url ~= nil then

                    if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" and USER_INFO["agentName"] ~= nil and USER_INFO["agentName"] ~= "" then
                        args["url"] = moChuanMLink.."?invitationCode=agent&activityId=" .. tostring(USER_INFO["agentId"]) .. "&level=" .. tostring(USER_INFO["agentName"])
                    else
                        args["url"] = appDownLoadAddress
                    end

                    -- args["url"] = appDownLoadAddress

                end
        
                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end
                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"wx")
                    table.insert(share_content,newName)
                    if url ~= nil then

                        if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" and USER_INFO["agentName"] ~= nil and USER_INFO["agentName"] ~= "" then
                            table.insert(share_content, moChuanMLink.."?invitationCode=agent&activityId=" .. tostring(USER_INFO["agentId"]) .. "&level=" .. tostring(USER_INFO["agentName"]))
                        else
                            table.insert(share_content,appDownLoadAddress)
                        end

                        -- table.insert(share_content,appDownLoadAddress)

                    else
                        table.insert(share_content,"")
                    end
                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end
                    table.insert(share_content,desc)
                    cct.getDateForApp("share", share_content, "V")
                else
                    cct.getDateForApp("share", args, "V")
                end

            elseif sender == pyq_bt then
                print("share pyq")
                local args = {}
                args["channel"] = "pyq"
                args["title"] = newName
                if url ~= nil then

                    if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" and USER_INFO["agentName"] ~= nil and USER_INFO["agentName"] ~= "" then

                        args["url"] =  moChuanMLink.."?invitationCode=agent&activityId=" .. tostring(USER_INFO["agentId"]) .. "&level=" .. tostring(USER_INFO["agentName"])

                    else
                        args["url"] = appDownLoadAddress
                    end

                    -- args["url"] = appDownLoadAddress

                end
                
                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end
                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"pyq")
                    table.insert(share_content,newName)
                    if url ~= nil then

                        if USER_INFO["agentId"] ~= nil and USER_INFO["agentId"] ~= "" and USER_INFO["agentName"] ~= nil and USER_INFO["agentName"] ~= "" then

                            table.insert(share_content,  moChuanMLink.."?invitationCode=agent&activityId=" .. tostring(USER_INFO["agentId"]) .. "&level=" .. tostring(USER_INFO["agentName"]))

                        else
                            table.insert(share_content, appDownLoadAddress)
                        end

                        -- table.insert(share_content, appDownLoadAddress)

                    else
                        table.insert(share_content,"")
                    end
                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end
                    table.insert(share_content,desc)
                    cct.getDateForApp("share", share_content, "V")
                else
                    cct.getDateForApp("share", args, "V")
                end

            end
        end
    end

    wx_bt:addTouchEventListener(touchEvent)
    pyq_bt:addTouchEventListener(touchEvent)

    return wx_bt,pyq_bt

end


function hideShareLayer()
    singleton:removeFromParent()
end

--按照传入的分隔符，切割字符串
function LuaSplit(str, split_char)  
    if str == "" or str == nil then   
        return {};  
    end  
    local split_len = string.len(split_char)  
    local sub_str_tab = {};  
    local i = 0;  
    local j = 0;  
    while true do  
        j = string.find(str, split_char,i+split_len);--从目标串str第i+split_len个字符开始搜索指定串  
        if string.len(str) == i then   
            break;  
        end  
  
  
        if j == nil then  
            table.insert(sub_str_tab,string.sub(str,i));  
            break;  
        end;  
  
  
        table.insert(sub_str_tab,string.sub(str,i,j-1));  
        i = j+split_len;  
    end  
    return sub_str_tab;  
end
    
return ShareLayer