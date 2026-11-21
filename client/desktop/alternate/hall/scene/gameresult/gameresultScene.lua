local gameresultScene = class("gameresultScene")

function gameresultScene:test()

    local data = {}
    data["resultSceneType"] = 2       --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = "123456"      --房间号
    data["fenchang"] = "123"            --分场
    data["round"] = 10                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data["resultData"] = {}             --玩家数据数组

    local p1 = {}             --玩家数据实体
    p1["nick"] = "我"           --昵称
    p1["uid"] = "00001"         --uid
    p1["icon_url"] = ""         --头像链接
    p1["sex"] = 1               --性别
    p1["isRoomOwer"] = 1        --是否为房主，1是，非1或不填不是
    p1["isWinner"] = 0          --是否为赢家，1是，非1或不填不是
    p1["total"] = "+100"        --总输赢分
    p1["gameDetail"] = {}       --游戏详情数组

    local gameDetail1 = {}           --游戏详情实体
    gameDetail1["showName"] = "自摸"   --展示名
    gameDetail1["value"] = "0"         --值

    local gameDetail2 = {}
    gameDetail2["showName"] = "点炮"
    gameDetail2["value"] = "0"

    local gameDetail3 = {}
    gameDetail3["showName"] = "抢杠"
    gameDetail3["value"] = "0"

    table.insert(p1["gameDetail"], gameDetail1)
    table.insert(p1["gameDetail"], gameDetail2)
    table.insert(p1["gameDetail"], gameDetail3)

    table.insert(data["resultData"], p1)
    table.insert(data["resultData"], p1)
    table.insert(data["resultData"], p1)
    table.insert(data["resultData"], p1)
    table.insert(data["resultData"], p1)
    table.insert(data["resultData"], p1)
    table.insert(data["resultData"], p1)
    table.insert(data["resultData"], p1)

    --返回大厅按钮点击事件
    local backHall_action = function(sender,event)

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

        end

    end

    --分享按钮点击事件
    local share_action = function(sender,event)

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

        end

    end

    self:showScene(data, backHall_action, share_action)

end

function gameresultScene:getBigWiner(data)
    local maxValue = 0
    local index = 1
    for k,v in pairs(data) do
        if v.total >= maxValue then
            maxValue = v.total
            index = k
        end
    end

    return index
end

function gameresultScene:showScene(data, backHall_action, share_action, extend_action)

    if(data == nil) then
        require(CommonTips_filePath):showTips("提示", "", 3, "战绩数据异常")
        return
    end

	if SCENENOW["scene"] ~= nil then

        self:removeScene()

	    local s = cc.CSLoader:createNode(GameResultScene_Long_Csb_filePath)
        local resultSceneType = data["resultSceneType"]
        if resultSceneType == 1 then
            s = cc.CSLoader:createNode(GameResultScene_Long_Csb_filePath)
        elseif resultSceneType == 2 then
            s = cc.CSLoader:createNode(GameResultScene_Short_Csb_filePath)
        end
        local tempX = s:getContentSize().width
	    s:setName("gameresultScene")
        s:setZOrder(999)
        -- s:setScaleX(SCREEN_WIDTH/tempX)
        -- if SCREEN_WIDTH > 1920 then
        --     s:setScaleX(SCREEN_WIDTH/tempX)
        -- else
        --     s:setScaleX(1280/tempX)
        -- end
        viewMgr:setSceneScale( s )
	    SCENENOW["scene"]:addChild(s)


        --房间信息
        local root_ly = s:getChildByName("root_ly")
        local roominfo_ly = root_ly:getChildByName("roominfo_ly")
        local roomnum_tt = roominfo_ly:getChildByName("roomnum_tt")
        local fenchang_tt = roominfo_ly:getChildByName("fenchang_tt")
        local round_tt = roominfo_ly:getChildByName("round_tt")
        local time_tt = roominfo_ly:getChildByName("time_tt")

        if SCENENOW["scene"].gameID ~= nil and SCENENOW["scene"].gameID == 340 then
            local ttfConfig = {}
            ttfConfig.fontFilePath = "hall/res/fonts/fzcy.ttf"
            ttfConfig.fontSize = 32
            local text = cc.Label:createWithTTF("游戏结果仅作娱乐用途，禁止用于赌博行为" or "", "hall/res/font/FZY3JW.TTF", 30)
            -- local text = cc.Label:createWithTTF(ttfConfig, "游戏结果仅作娱乐用途，禁止用于赌博行为")--"游戏结果仅作娱乐用途，禁止用于赌博行为", 
            text:setColor(cc.c3b(255, 255, 255))
            text:setString("游戏结果仅作娱乐用途，禁止用于赌博行为!")
            local pX = root_ly:getPositionX()
            local pY = root_ly:getPositionY()
            text:setPosition(ccp(pX, pY + 250))
            s:addChild(text)
        end
        --房间号
        local invote_code = data["invote_code"]
        if invote_code then
            roomnum_tt:setString(invote_code)
        end

        --分场
        local fenchang = data["fenchang"]
        if fenchang then
            fenchang_tt:setString(fenchang)
            print("100861111111")
            dump(fenchang, "119")
        end

        --局数
        local round = data["round"]
        if round then
            round_tt:setString(round)
        end

        --时间
        local date = data["date"]
        if date then
            time_tt:setString(date)
        end

        --战绩信息
        local resultData = data["resultData"]
        local content_sv = root_ly:getChildByName("content_sv")
        local content_ly = content_sv:getChildByName("content_ly")
        if resultData and #resultData > 0 then

            for k,v in pairs(resultData) do

                local userData = v

                local userDataCell
                local x
                local y
                if resultSceneType == 1 then

                    userDataCell = cc.CSLoader:createNode(GameResultScene_Long_Cell_Csb_filePath)

                    if #resultData == 1 then
                        x = 410
                    elseif #resultData == 2 then
                        x = -40 + 304.00 * k
                    elseif #resultData == 3 then
                        x = -190 + 304.00 * k
                    else
                        x = -310 + 290.00 * k
                    end

                    y = -421

                elseif resultSceneType == 2 then

                    userDataCell = cc.CSLoader:createNode(GameResultScene_Short_Cell_Csb_filePath)

                    if k < 6 then
                        x = 229.00 * (k - 1)
                        y = -177.00

                    else
                        x = 229.00 * (k - 6)
                        y = -378.00

                    end

                end
                userDataCell:setPosition(x, y)

                local cell_root_ly = userDataCell:getChildByName("root_ly")
                cell_root_ly:setTouchEnabled(false)

                local head_im = cell_root_ly:getChildByName("head_im")

                local icon_url = userData["icon_url"]
                local uid = userData["uid"]
                local sex = userData["sex"]
                local nick = userData["nick"]
                local isRoomOwer = userData["isRoomOwer"]
                local isWinner = userData["isWinner"]
                local total = userData["total"]
                local gameDetail = userData["gameDetail"]

                --房主
                local owner_im = cell_root_ly:getChildByName("owner_im")
                if isRoomOwer and isRoomOwer == 1 then
                    owner_im:setVisible(true)
                end

                --赢家
                local bg_im = cell_root_ly:getChildByName("bg_im")
                if isWinner and isWinner == 1 then
                    if resultSceneType == 1 then
                        bg_im:loadTexture(GameResultScene_Long_Cell_Bg_W_filePath)
                    elseif resultSceneType == 2 then

                    end
                end

                --头像
                if icon_url and uid and sex and nick then
                    require("hall.GameCommon"):getUserHead(icon_url, uid, sex, head_im, 50, false, nick)
                end

                

                --昵称
                local name_ly = cell_root_ly:getChildByName("name_ly")
                local name_content_tt = name_ly:getChildByName("content_tt")
                if nick then
                    if SCENENOW["scene"].gameID ~= nil and SCENENOW["scene"].gameID == 317 then
                        name_content_tt:setTextColor(cc.c3b(255, 255, 255))
                    end
                    -- local subName = str
                    name_content_tt:setString(nick)
                end
                
                --金花加大赢家
                if SCENENOW["scene"].gameID ~= nil and SCENENOW["scene"].gameID == 317 and self:getBigWiner(resultData) == k then
                    local sp = cc.Sprite:create("hall/scene/res/singlered/image/gameresult_new/bigWin.png")
                    sp:setPositionX(40)
                    sp:setPositionY(10)
                    head_im:addChild(sp)
                end

                --id
                local id_ly = cell_root_ly:getChildByName("id_ly")
                local id_content_tt = id_ly:getChildByName("content_tt")
                if uid then
                    dump(uid, "10099")
                    if SCENENOW["scene"].gameID ~= nil and SCENENOW["scene"].gameID == 317 then
                        id_content_tt:setTextColor(cc.c3b(255, 255, 255))
                    end
                    id_content_tt:setString(uid)
                end

                --游戏详情
                local gameinfo_sv = cell_root_ly:getChildByName("gameinfo_sv")
                if gameinfo_sv then

                    local gameinfo_content_ly = gameinfo_sv:getChildByName("content_ly")
                    if gameDetail and #gameDetail > 0 then

                        for k,v in pairs(gameDetail) do

                            local detail = v

                            local longdetailCell = cc.CSLoader:createNode(GameResultScene_Long_Detail_Cell_Csb_filePath)
                            longdetailCell:setPosition(0, k * 55 * -1)

                            local root_ly = longdetailCell:getChildByName("root_ly")
                            local content_tt = root_ly:getChildByName("content_tt")

                            local showName = detail["showName"]
                            local value = detail["value"]
                            if showName and value then
                                content_tt:setString(showName .. ":" .. value)
                            end

                            gameinfo_content_ly:addChild(longdetailCell)

                        end

                        if #gameDetail > 2 then

                            gameinfo_sv:setCascadeOpacityEnabled(true)
                            gameinfo_sv:setInnerContainerSize(cc.size(240.00, 55 * #gameDetail))
                            gameinfo_content_ly:setPosition(0, 55 * #gameDetail)

                        end

                    end

                end

                --总分
                local temp_total_tt = cell_root_ly:getChildByName("total_tt")
                temp_total_tt:setVisible(false)
                local total_tt = display.newTTFLabel({
                    text = content,
                    font = "hall/res/font/FZY3JW.TTF",
                    size = 28,
                    color = cc.c3b(166, 59, 6),
                    align = cc.TEXT_ALIGNMENT_LEFT,
                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                    dimensions = cc.size(txtWidth, 0)
                })

                total_tt:setAnchorPoint(temp_total_tt:getAnchorPoint())
                cell_root_ly:addChild(total_tt)
                total_tt:setPosition(temp_total_tt:getPosition())
                -- txt_lb:setString(textMessage)
                -- local total_tt = cell_root_ly:getChildByName("total_tt")
                --------------结算页面总分--------------------

                
                if total then
                    total = tonumber(total/100)
                    total_tt:setString(total)
                    if  SCENENOW["scene"].gameID ~= nil and SCENENOW["scene"].gameID == 340 then
                        total_tt:setScale(1.5)
                        local pY = total_tt:getPositionY()
                        total_tt:setPositionY(pY-5)
                    end
                end

                content_ly:addChild(userDataCell)
                    dump(total, "999123")
                    -- local AddCludList = require("hall.view.clubView.AddCludList")
                    -- AddCludList:TotalScoreChanges(uid, total)
            end

            if resultSceneType == 1 then

                if #resultData > 4 then
                    content_sv:setCascadeOpacityEnabled(true)
                    content_sv:setInnerContainerSize(cc.size(290.00 * #resultData, 421.00))
                end

            end

        end

        --返回大厅
        local back_bt = root_ly:getChildByName("back_bt")
        --if  SCENENOW["scene"].gameID ~= nil and SCENENOW["scene"].gameID == 340 then
        --    local pX = back_bt:getPositionX()
        --    back_bt:setPositionX(pX - 150)
        --end
        back_bt:setTouchEnabled(true)
        back_bt:addTouchEventListener(backHall_action)

        --分享战绩
        local share_bt = root_ly:getChildByName("share_bt")
        --if  SCENENOW["scene"].gameID ~= nil and SCENENOW["scene"].gameID == 340 then
        --    local pX = share_bt:getPositionX()
        --    share_bt:setPositionX(pX + 150)
        --end
        share_bt:setTouchEnabled(true)
        if isiOSVerify then
            share_bt:setVisible(false)
        end
        share_bt:addTouchEventListener(share_action)

        local extend_bt = root_ly:getChildByName("extend_bt")
        if extend_bt then
            if data["activity_id"] then
                back_bt:setPositionX(630)
                share_bt:setPositionX(956)
                extend_bt:setPositionX(295)
                extend_bt:setVisible(true)

                extend_bt:setTouchEnabled(true)
                extend_bt:addTouchEventListener(extend_action)
            else
                back_bt:setPositionX(490)
                share_bt:setPositionX(794)
                extend_bt:setVisible(false)
            end
        end

    end
end


function gameresultScene:removeScene()

	local s = SCENENOW["scene"]:getChildByName("gameresultScene")
    if s then
        s:removeSelf()
    end

end

return gameresultScene
