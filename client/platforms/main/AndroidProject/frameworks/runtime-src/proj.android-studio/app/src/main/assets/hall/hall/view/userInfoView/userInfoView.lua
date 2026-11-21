
local userInfoView = class("userInfoView")

local userInfo_arr = {}

function userInfoView:showView(url, userInfo)

    -- dump(userInfo, "---------- old userInfo ---------")
	if  userInfo == nil then
		return
	end

    -- if  userInfo_arr[userInfo["uid"]] == nil then
    --     userInfo_arr[userInfo["uid"]] = userInfo
    -- end
    
    self:upDateUserInfo(userInfo["uid"], userInfo)

    userInfo = userInfo_arr[userInfo["uid"]]
    -- dump(userInfo_arr, "---------- userInfo_arr ---------")
    -- dump(userInfo, "-----showView-----")

	if SCENENOW["scene"] then

		-- local s = SCENENOW["scene"]:getChildByName("userInfoView")
	 --    if s then
	 --        s:removeSelf()
	 --    end

          -- s = cc.CSLoader:createTimeline("hall/view/userInfoView/userInfoView_nomal_Layer.csb")
        local csbPath 

	    if bm.isInGame then

            if SCENENOW["scene"]:getChildByName("userInfoView") then
                print("===已经存在，无需再次添加！！！===")
            else
                local enterRoomLayer = require("hall.setting.SettingLayer").new(false)
                if enterRoomLayer then
                    local zOrder = ViewBase:getZOrderByChilds(SCENENOW["scene"])
                    enterRoomLayer:setName("userInfoView")
                    enterRoomLayer:addTo(SCENENOW["scene"], zOrder)

                end
            end
            -- if device.platform == "ios" then
            --     if isiOSVerify then
            --         if resFolder == "longteng" then
            --             csbPath = "hall/view/userInfoView/userInfoView_game_Layer_longteng.csb" 
            --         else
            --             csbPath = "hall/view/userInfoView/userInfoView_game_Layer.csb"
            --         end    

            --     else
            --         if resFolder == "longteng" then
            --             csbPath = cc.FileUtils:getInstance():getWritablePath() .. "hall/view/userInfoView/userInfoView_game_Layer_longteng.csb"
            --         else
            --             csbPath = cc.FileUtils:getInstance():getWritablePath() .. "hall/view/userInfoView/userInfoView_game_Layer.csb"
            --         end
                    
            --     end
            -- else
            --     if resFolder == "longteng" then
            --         csbPath = "hall/view/userInfoView/userInfoView_game_Layer_longteng.csb"
            --     else
            --         csbPath = "hall/view/userInfoView/userInfoView_game_Layer.csb"
            --     end
                
            -- end

            -- s = cc.CSLoader:createNode(csbPath)
            -- s:setZOrder(999)

	    else
            if SCENENOW["scene"]:getChildByName("userInfoView") then
                print("===已经存在，无需再次添加！！！===")
            else
                local enterRoomLayer = require("hall.setting.SettingLayer").new(true)
                if enterRoomLayer then
                    enterRoomLayer:setName("userInfoView")
                    enterRoomLayer:addTo(SCENENOW["scene"])
                end
            end
            

            -- if device.platform == "ios" then
            --     if isiOSVerify then
            --         if resFolder == "longteng" then
            --             csbPath = "hall/view/userInfoView/userInfoView_nomal_Layer_longteng.csb"
            --         else
            --             csbPath = "hall/view/userInfoView/userInfoView_nomal_Layer.csb"                     
            --         end
            --     else
            --         if resFolder == "longteng" then
            --             csbPath = cc.FileUtils:getInstance():getWritablePath() .. "hall/view/userInfoView/userInfoView_nomal_Layer_longteng.csb"
            --         else
            --             csbPath = cc.FileUtils:getInstance():getWritablePath() .. "hall/view/userInfoView/userInfoView_nomal_Layer.csb"
            --         end
 
            --     end
            -- else
            --     if resFolder == "longteng" then
            --         csbPath = "hall/view/userInfoView/userInfoView_nomal_Layer_longteng.csb"
            --     else
            --         csbPath = "hall/view/userInfoView/userInfoView_nomal_Layer.csb"
            --     end
            -- end

            -- s = cc.CSLoader:createNode(csbPath)
            
	    end


        if cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width == 960 then
            s:setScale(0.75)
        end
        
        if not bm.isInGame then 
            return 
        else
            return 
        end

        if  bm.isInGame then
        else
            -- local action = cc.CSLoader:createTimeline(csbPath)
            -- s:runAction(action)
            -- action:gotoFrameAndPlay(0,25, false)
        end

        s:setName("userInfoView")
    	SCENENOW["scene"]:addChild(s)

    	local bg_ly = s:getChildByName("Panel_1")
    	bg_ly:setTouchEnabled(true)
    	bg_ly:addTouchEventListener(
            function(sender,event)

                if event == TOUCH_EVENT_BEGAN then
                	
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then

                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    self:removeView()
                end

            end
        )

    	local root_ly = s:getChildByName("root_ly")
    	root_ly:setTouchEnabled(true)
    	root_ly:addTouchEventListener(
            function(sender,event)

                if event == TOUCH_EVENT_BEGAN then
                	
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then

                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    self:removeView()
                end

            end)


        local head_ly = root_ly:getChildByName("head_ly")
        if  bm.isInGame then
            require("hall.view.headView.headView"):addView(head_ly, 70, -66, 70, 70, url)
        else
            require("hall.view.headView.headView"):addView(head_ly, 80, -76, 90, 90, url)
        end

        local name_tt = root_ly:getChildByName("name_tt")
        if  userInfo["nickName"] then
        	name_tt:setString(userInfo["nickName"])
        end

        local id_tt = root_ly:getChildByName("id_tt")
        if  userInfo["uid"] then
        	id_tt:setString("ID: " .. userInfo["uid"])
        end

        local ip_tt = root_ly:getChildByName("ip_tt")
        if ip_tt ~= nil then
            if userInfo["ip"] ~= nil and userInfo["ip"] ~= "" then
                ip_tt:setString("IP: " .. userInfo["ip"])
            else
                ip_tt:setString("IP: ")
            end
        end

        local gold_info = root_ly:getChildByName("gold_info")

        --钻石
        local gold_tt = gold_info:getChildByName("gold_tt")
        if  gold_tt ~= nil then
            -- if  bm.isInGame then
            --     gold_tt:setVisible(false)
            -- else
            gold_tt:setVisible(true)

            if  bm.isInGame == true then
                if  userInfo["gold"] then
                    -- gold_tt:setString("拥有钻石:" .. userInfo["gold"])  --USER_INFO["gold"]
                    local allStrs = {}

                    local strTable = {}
                    strTable["content"] = "拥有钻石:"
                    strTable["color"] = cc.c3b(0x8B,0x69,0x14)
                    table.insert(allStrs,strTable)

                    local strTable = {}
                    strTable["content"] = require(NumberUtil_filePath):formatGold(userInfo["gold"])
                    strTable["color"] = cc.c3b(0x8B,0x69,0x14)
                    table.insert(allStrs,strTable)

                    require("hall.GameCommon"):LabelToRich(gold_tt,allStrs)

                else
                    if userInfo["uid"] == USER_INFO["uid"] then

                        local allStrs = {}

                        local strTable = {}
                        strTable["content"] = "拥有钻石:"
                        strTable["color"] = cc.c3b(0x8B,0x69,0x14)
                        table.insert(allStrs,strTable)

                        local strTable = {}
                        strTable["content"] = require(NumberUtil_filePath):formatGold(USER_INFO["gold"])
                        strTable["color"] = cc.c3b(0x8B,0x69,0x14)
                        table.insert(allStrs,strTable)

                        require("hall.GameCommon"):LabelToRich(gold_tt,allStrs)
                        -- gold_tt:setString("拥有钻石:" .. (USER_INFO["gold"] or 0))
                    else
                        gold_info:setVisible(false)
                        -- gold_tt:setString("拥有钻石： ???")
                    end
                end
            else

                local allStrs = {}

                local strTable = {}
                strTable["content"] = "拥有钻石： "
                strTable["color"] = cc.c3b(0x8B,0x69,0x14)
                table.insert(allStrs,strTable)

                local strTable = {}
                strTable["content"] = require(NumberUtil_filePath):formatGold(USER_INFO["gold"]) 
                strTable["color"] = cc.c3b(0x8B,0x69,0x14)
                table.insert(allStrs,strTable)

                require("hall.GameCommon"):LabelToRich(gold_tt,allStrs)

                -- gold_tt:setString("拥有钻石：" .. (USER_INFO["gold"] or 0))
            end

                --赠送
                local present = gold_info:getChildByName("present")
                if  present ~= nil then

                    -- if  isiOSVerify then
                        present:setVisible(false)
                    -- else
                    --     present:setVisible(isShowGiveCard)
                    -- end
                    
                    present:setTouchEnabled(true)
                    present:addTouchEventListener(function(sender,event)

                            if event == TOUCH_EVENT_BEGAN then
                                
                            end

                            --触摸取消
                            if event == TOUCH_EVENT_CANCELED then

                            end

                            --触摸结束
                            if event == TOUCH_EVENT_ENDED then
                                require(Gift_filePath):showGiftScene()
                            end

                        end)
                end
                
            -- end
        end

        
        local income_info = root_ly:getChildByName("income_info")

        if income_info then
            --房主收益
            local Image_5 = income_info:getChildByName("Image_5")

            local income_tt = income_info:getChildByName("income_tt")
            if  income_tt ~= nil then
                if  bm.isInGame then
                    income_tt:setVisible(false)
                else
                    income_tt:setVisible(true)

                    local allStrs = {}

                    local strTable = {}
                    strTable["content"] = "房主返利： "
                    strTable["color"] = cc.c3b(255,255,255)
                    table.insert(allStrs,strTable)

                    local strTable = {}
                    strTable["content"] = require(NumberUtil_filePath):toWan(USER_INFO["owerIncome"],99999)
                    strTable["color"] = cc.c3b(255,255,0)
                    table.insert(allStrs,strTable)

                    require("hall.GameCommon"):LabelToRich(income_tt,allStrs)

                    -- income_tt:setString("房主返利：" .. require(NumberUtil_filePath):toWan(USER_INFO["owerIncome"], 99999))
                    
                    --提现
                    local getmoney_bt = income_info:getChildByName("getmoney_bt")
                    if getmoney_bt ~= nil then

                        if hasRebate == false then
                            getmoney_bt:setVisible(false)
                        end

                        -- getmoney_bt:setPositionX(330)
                        getmoney_bt:setTouchEnabled(true)
                        getmoney_bt:addTouchEventListener(function(sender,event)

                                if event == TOUCH_EVENT_BEGAN then
                                    
                                end

                                --触摸取消
                                if event == TOUCH_EVENT_CANCELED then

                                end

                                --触摸结束
                                if event == TOUCH_EVENT_ENDED then
                                    require(GetMoneyScene_filePath):showScene()

                                end

                            end)
                    end


                end

            end

            income_info:setVisible(hasRebate)

        end


        --所在城市
        local city_tt = root_ly:getChildByName("city_tt")
        if city_tt ~= nil then

            -- if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

            --     local args = {}
            --     local sigs = "()Ljava/lang/String;"
            --     local luaj = require "cocos.cocos2d.luaj"
            --     local className = luaJniClass
            --     local ok,ret  = luaj.callStaticMethod(className,"getCity",args,sigs)
            --     if not ok then
            --         print("luaj error:", ret)
            --     else
            --         USER_INFO["LocalCity"] = ret
            --     end

            -- elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then

            --     local args = {}
            --     local luaoc = require "cocos.cocos2d.luaoc"
            --     local className = "CocosCaller"
            --     local ok,ret  = luaoc.callStaticMethod(className,"getCity")
            --     if not ok then
            --         cc.Director:getInstance():resume()
            --     else
            --         USER_INFO["LocalCity"] = ret
            --     end
            -- end

            if  userInfo["city"] and userInfo["city"] ~= "" then
                city_tt:setString("所在城市： " .. userInfo["city"])
            else
                city_tt:setString("")  --("所在城市： ")
            end
            
        end

        --在游戏中显示
        if bm.isInGame then

            if not isiOSVerify then

                local distance_lv = root_ly:getChildByName("distance_lv")

                if isShowAnimView and userInfo["uid"] ~= USER_INFO["uid"] then

                    --添加互动表情
                    require("hall.view.animView.animView"):addView(root_ly, -250, -50,userInfo["uid"])

                    local Image_8 = root_ly:getChildByName("Image_8")
                    local scaleY = 0.5
                    Image_8:setScaleY(scaleY)
                    -- Image_8:setPosition(Image_8:getPosition().x, Image_8:getPosition().y)

                    local fixY = 10  --修正列表容器露出的大小
                    distance_lv:setContentSize(Image_8:getContentSize().width,Image_8:getContentSize().height*scaleY - fixY)
                end

                -- --获取房间中的玩家地理位置
                local location_arr = {}
                for k,v in pairs(userInfo_arr) do  --现在退出组局会清除玩家数据，因此不再需要匹配邀请码
                --     if v.invote_code == USER_INFO["invote_code"] then
                        table.insert(location_arr, v)
                --     end
                end
                
                if #location_arr > 0 then

                    -- dump(location_arr, "-----用户信息控件-----")
                    
                    local isCompare_arr = {}
                    for k,v in pairs(location_arr) do
                        
                        local uid = v["uid"]

                        -- if  uid == userInfo["uid"] then
                        
                            --获取当前用户的经纬度
                            local latitude = tonumber(v["latitude"] or "") or 0
                            local longitude = tonumber(v["longitude"] or "") or 0

                            local nickName = (uid == USER_INFO["uid"]) and "我" or v["nickName"] -- require("hall.GameCommon"):formatNickToLaction(v["nickName"],8)
                            nickName = nickName or ""
                            -- dump(nickName,"nickName")

                            if latitude ~= 0 and longitude ~= 0 then

                                -- dump(location_arr,"用户有经纬度信息", "----------")

                                for a,b in pairs(location_arr) do

                                    local b_uid = b["uid"]

                                    if  b_uid ~= uid and uid == userInfo["uid"]  then

                                        local b_latitude = tonumber(b["latitude"] or "") or 0 
                                        local b_longitude = tonumber(b["longitude"] or "") or 0 

                                        local b_nickName = (b_uid == USER_INFO["uid"]) and "我" or b["nickName"] --require("hall.GameCommon"):formatNickToLaction(b["nickName"],8)

                                        b_nickName = b_nickName or ""
                                        -- dump(b_nickName,"b_nickName")

                                        --判断当前用户之前是否已经比较
                                        local isCompare = 0
                                        
                                        -- for q,w in pairs(isCompare_arr) do
                                        --     if w == b_uid then
                                        --         isCompare = 1
                                        --     end
                                        -- end

                                        --获取当前用户的id
                                        -- table.insert(isCompare_arr, uid)

                                        -- dump(isCompare_arr,"isCompare_arr")
                                        if isCompare == 0 then
                                            -- dump("当前用户未进行比较")

                                                local distanceLayer
                                                if device.platform == "ios" then
                                                    if isiOSVerify then
                                                        distanceLayer = cc.CSLoader:createNode("hall/view/userInfoView/distanceLayer.csb")
                                                    else
                                                        distanceLayer = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/view/userInfoView/distanceLayer.csb")
                                                    end
                                                else
                                                    distanceLayer = cc.CSLoader:createNode("hall/view/userInfoView/distanceLayer.csb")
                                                end


                                                local root_ly = distanceLayer:getChildByName("root_ly")
                                                local distance_tt = root_ly:getChildByName("distance_tt"):removeFromParent():setString("该昵称含有非法字符")
                                                distance_tt:setScale(0.9)
                                                -- print(b_latitude,b_longitude,latitude, longitude,"用户经纬度")

                                                if b_latitude ~= 0 and b_longitude ~= 0 then
                                                    local s = require("hall.util.LocationUtil"):getDistance(latitude, longitude, b_latitude, b_longitude)
                                                    
                                                    -- dump(s,"用户之间距离")
                                                    if s >= 0 then

                                                        if s < 1000 then
                                                            distance_tt:setString(nickName .. "与" .. b_nickName .. "相距" .. tostring(s) .. "米")
                                                        else
                                                            s = s / 1000
                                                            s = math.floor(s)
                                                            distance_tt:setString(nickName .. "与" .. b_nickName .. "相距" .. tostring(s) .. "千米")
                                                        end
                                                        

                                                        distance_lv:pushBackCustomItem(distance_tt)

                                                    end
                                                end

                                        else

                                            --dump("当前用户已比较", "-----isCompare_arr-----")

                                        end

                                    end

                                end

                            else

                                --dump("用户无经纬度信息", "----------")

                                local distanceLayer
                                if device.platform == "ios" then
                                    if isiOSVerify then
                                        distanceLayer = cc.CSLoader:createNode("hall/view/userInfoView/distanceLayer.csb")
                                    else
                                        distanceLayer = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/view/userInfoView/distanceLayer.csb")
                                    end
                                else
                                    distanceLayer = cc.CSLoader:createNode("hall/view/userInfoView/distanceLayer.csb")
                                end


                                local root_ly = distanceLayer:getChildByName("root_ly")
                                local distance_tt = root_ly:getChildByName("distance_tt"):removeFromParent()
                                
                                if nickName then
                                    distance_tt:setString(nickName .. "位置未知")
                                    distance_tt:setScale(0.9)
                                    distance_lv:pushBackCustomItem(distance_tt)
                                end

                            end


                        -- end


                    end


                end

            end

        end

        local input_tf = root_ly:getChildByName("input_tf")
        if input_tf then

            if USER_INFO["sign"] ~= nil and USER_INFO["sign"] ~= "" and USER_INFO["sign"] ~= "0" then
                input_tf:setString(USER_INFO["sign"])
            else
                input_tf:setString("")
            end

        end

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

                    if input_tf then
                        self:saveSigName(USER_INFO["uid"], input_tf:getString())

                    end

                    self:removeView()

                end

            end

        )
		
        if  onlyHasRoomCardMode == true then

            if gold_info then
                gold_info:setVisible(false)
            end

            if income_info then
                income_info:setVisible(false)
            end
            
        end

        if isiOSVerify then
            if Image_5 then
                Image_5:setVisible(false)
            end
            if income_tt then
                income_tt:setVisible(false)
            end
            if getmoney_bt then
                getmoney_bt:setVisible(false)
            end
            if ip_tt then
                ip_tt:setVisible(false)
            end
            if city_tt then
                city_tt:setVisible(false)
            end
            local Image_8 = root_ly:getChildByName("Image_8")
            if Image_8 then
                Image_8:setVisible(false)
            end
            if input_tf then
                input_tf:setVisible(false)
            end
            
        end

	end

end

function userInfoView:upDateUserInfo(uid, info, updateType)

    -- userInfo_arr[uid] = userInfo_arr[uid] or {}
    -- info必须为table,可采取 {["gold"] = 1000} 的形式传参
    
    if  updateType == "resetAllUser" then  --重置所有玩家

        for uid,v in pairs(userInfo_arr) do
            if uid ~= USER_INFO["uid"] then
                userInfo_arr[uid] = nil
            end
        end

        return
    end

    if  userInfo_arr[uid] == nil then
        userInfo_arr[uid] = {}
    end

    if  type(info) ~= "table" then
        print("更新的用户信息数组类型错误，不为TABLE！")  
    end

    if  updateType == nil then   --兼容老的调用形式
        for k,v in pairs(info) do
--[[            if  k ~= "ip" then
                userInfo_arr[uid][k] = v
            end]]
            -- end
            userInfo_arr[uid][k] = v
        end

        dump(userInfo_arr[uid],"更新所有数")

    elseif updateType == "reset" then  --重置

        userInfo_arr[uid] = nil

    else  --"gold"更新单项数据
            
        userInfo_arr[uid][updateType] = info[updateType]
        dump(userInfo_arr[uid],"更新单项数据")
        
    end

    --dump(info, "-----userInfoView 当前缓存的用户数据-----")
end

--更新用户签名
function userInfoView:saveSigName(uid, context)

    if context == "" then
        context = "0"
    end

    local params = {}
    params["userId"] = uid
    params["context"] = context

    cct.createHttRq({
        url = HttpAddr .. "/gold/saveSigName",
        date = params,
        type_= "POST",
        requestMsg = msg,
        callBack = function(data)

            local responseData = data.netData
            if responseData then

                responseData = json.decode(responseData)
                dump(responseData, "-----更新用户签名返回-----")

                local returnCode = responseData.returnCode
                if returnCode == "0" then
                    -- require(CommonTips_filePath):showTips("提示", "", 3, "操作成功！")

                    USER_INFO["sign"] = context

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
function userInfoView:updataGold()

    local s = SCENENOW["scene"]:getChildByName("userInfoView")
    if s then
        local root_ly = s:getChildByName("root_ly")
        local income_tt = root_ly:getChildByName("income_tt")
        if income_tt ~= nil then
            income_tt:setString("房主返利： " .. require(NumberUtil_filePath):toWan(USER_INFO["owerIncome"], 99999))
        end
    end

end

function userInfoView:removeView()

	local s = SCENENOW["scene"]:getChildByName("userInfoView")
    if s then
        s:removeSelf()
    end

end

return userInfoView
