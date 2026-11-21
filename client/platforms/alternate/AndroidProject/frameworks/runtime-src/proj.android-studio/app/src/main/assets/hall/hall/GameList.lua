

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameList  = class("GameList")

local gameList = {}
local updateIndex = 1

function GameList:addGame(gameid,code,name,version)
    -- body
    table.insert(gameList,{gameid,code,name,version})
end

--加载游戏列表
function GameList:loadGameList(data)
    -- dump(data,"deal with table")
    if data == nil then
      return
    end
    --gameList = {}
    for k,v in pairs(data) do
      -- dump(v["gameTypeList"],"gameTypeList111")
      if k ~= "roomNane" and k ~= "roomType" then
        for o,p in pairs(v["gameTypeList"]) do
          for m,n in pairs(p["gameList"]) do
            table.insert(gameList,{n["gameId"],n["code"],n["name"],n["version"],n["playerCount"],n["freeGamePhoto"],n["isMainPage"],n["isShow"],n["level"]})
          end  
        end 
      end  
    end
end

function GameList:getGameCode(gameid)
    -- body
    for i,v in ipairs(gameList) do
        if v[1] == gameid then
            return v[2]
        end
    end
    return ""
end

--根据gameid，查找游戏名
function GameList:getGameName(gameid)
    -- body
    for i,v in ipairs(gameList) do
        if v[1] == gameid then
            return v[3]
        end
    end
    return ""
end

--获取单个游戏信息
function GameList:getInfoByCode(code)
    for i,v in ipairs(gameList) do
        if v[2] == code then
            return v
        end
    end
    return nil
end

--获取当前更新游戏信息
function GameList:getCurrentUpdateGame()
    updateIndex = updateIndex + 1
    return gameList[updateIndex - 1]
end

--是否最后一个游戏更新
function GameList:isLastUpdate()
    print("isLastUpdate",tostring(updateIndex),tostring(#gameList))
    dump(gameList, "-----isLastUpdate-----")
    if updateIndex >= #gameList then
        return true
    end
    return false
end

function GameList:resetUpdateList()
    updateIndex = 1
end

function GameList:getList(isVerify_)
    -- body

    if isVerify_ then
            --todo

           local data={
                 {
                     1,
                      "ddz",
                      "¶·µØÖ÷",
                      "1.0.5",
                      1,
                      "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game1.png",
                 },
                  {
                      5,
                      "niuniu",
                      "¶·Å£",
                      "1.0.0",
                      5,
                      "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game2.png",
                 },
                 {
                      4,
                      "majiang",
                      "¶·Å£",
                      "1.0.0",
                      4,
                      "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game2.png",
                 },
                 {
                      6,
                      "top11",
                      "¶·Å£",
                      "1.0.0",
                      6,
                      "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game2.png",
                 }
             }

        return data
    end
    
    return gameList
end


local reloadTable = 0

--设置重连tid
function GameList:setReloadTable( tid )
  reloadTable = tid
end

function GameList:getReloadTable( ... )
  return reloadTable
end

--设置重连模式
local reloadOnlookUser = 0
function GameList:setReloginMode(on_look_user)
  reloadOnlookUser = on_look_user
end

function GameList:getReloginMode()
  return reloadOnlookUser
end

function GameList:getGameTypeList(currentPlayMode)

    local gameTypeList = {}
    if currentPlayMode == 0 then
        for t,singleGame in pairs(bm.gameList) do
            table.insert(gameTypeList,t)
        end

    else
        for t,singleGame in pairs(bm.gameList_forRoomCard) do
            table.insert(gameTypeList,t)
        end
    end

    return gameTypeList

end

function GameList:getLevelToTypeTable()

    local levelToTypeTable = {}

    for t,singleGame in pairs(bm.gameList) do

        for i, v in ipairs(singleGame["gameArr"]) do
            for x, y in ipairs(v["gameList"]) do
                if y.level then
                    levelToTypeTable[y.level] = t
                end
            end

        end
    end 

    for t,singleGame in pairs(bm.gameList_forRoomCard) do

        for i, v in ipairs(singleGame["gameArr"]) do
            if v.level then
                levelToTypeTable[v.level] = t
            end
        end
    end 

    return levelToTypeTable
end

function GameList:addGamesToListView(gamelist_lv, funcType, funcEvent, touchBigButtonFunc, limitClickTime, openLevel, singleGameType)   --列表容器，游戏列表类型（用途），功能型回调，触摸按钮的附加事件
    
    --------------------外部数据部分--------------------------------------------------
    gamelist_lv:setScrollBarEnabled(false):removeAllChildren()
    
    -- local funcType = 0    --0金币场，1房卡场，2联盟
    local forbitClick = false

    local gameList

    local lastCreateGameType_Gold = cc.UserDefault:getInstance():getStringForKey("lastCreateGameType_Gold","1")
    local lastCreateGameType_RoomCard = cc.UserDefault:getInstance():getStringForKey("lastCreateGameType_RoomCard","1")
 
    local CreateGroup_TabGame_Csb_filePath = "hall/res/csb/group/tab_gameLayer.csb"  --"hall/scene/res/" .. resFolder .."/group/create/tab_gameLayer.csb"
    local CreateGroup_TabType_Csb_filePath = "hall/res/csb/group/tab_typeLayer.csb" --"hall/scene/res/" .. resFolder .."/group/create/tab_typeLayer.csb"
    -- local tabTypeLayerCsb = "hall/res/csb/group/tab_typeLayer.csb"
    -- local tickSelectCsb = "hall/res/csb/group/tick_select.csb"

    local opened_game_bt_table = {}
    local opened_big_game_bt_table = {}

    local lastSelectedGameType
    ----------------------------------------------------------------------------------

    -- for _,v in pairs(bm.gameList_forRoomCard ) do
    -- dump(v,"bm.gameList_forRoomCard")
-- end
    if  funcType == 0 then  --金币场
        gameList = bm.gameList
        lastSelectedGameType = lastCreateGameType_Gold 
    elseif  funcType == 1  or funcType == 2 then  --房卡场/联盟
        gameList = bm.gameList_forRoomCard
        lastSelectedGameType = lastCreateGameType_RoomCard
    elseif funcType == 3 then   --金币场玩法
        gameList = bm.gameList
        lastSelectedGameType = lastCreateGameType_Gold
    elseif funcType == 4 then   --金币场玩法
        gameList = bm.gameList_forRoomCard
        lastSelectedGameType = lastCreateGameType_RoomCard
    end

    dump(lastCreateGameType_RoomCard,"lastCreateGameType_RoomCard")
    --按钮对应的界面事件
    local function openBigGameList(sender,typeGameList,bigGameName) 

        for k,bigGame_bt in pairs(opened_big_game_bt_table) do
            if  bigGame_bt ~= sender then
                bigGame_bt:getChildByName("text_tt_s"):setVisible(true)
                bigGame_bt:setBrightStyle(0)
                bigGame_bt.selected = false
            end
        end   

        for i,v in ipairs(opened_game_bt_table) do 
            gamelist_lv:removeChild(v)
        end

        gamelist_lv:doLayout()

        local singleGameNums = #typeGameList

        opened_game_bt_table = {}

        if  sender.selected == true then
            sender:setBrightStyle(0)
            sender:getChildByName("text_tt_s"):setVisible(true)            
            return
        else
            sender:setBrightStyle(1)
            sender:getChildByName("text_tt_s"):setVisible(false)
        end

            --显示当前分类下的游戏
            for k,v in ipairs(typeGameList) do

                -- dump(v,"单个游戏的配置")
                if type(v) == "table" then
                    
                    local level
                    local gameId
                    local gameName = v.name

                    if  v["level"] then
                        -- dump("一层levle存在")
                        level = v["level"]
                        gameId = v["gameId"]
                    elseif  v["gameList"][1]  then
                        level = v["gameList"][1]["level"]
                        gameId = v["gameList"][1]["gameId"]
                        -- dump("二层levle存在")
                    end
                        
                    if  singleGameNums == 1 then
                        funcEvent(level,gameId)
                    else
                        --添加游戏按钮
                        local game_bt = cc.CSLoader:createNode(CreateGroup_TabGame_Csb_filePath):getChildByName("game_bt"):removeFromParent()
                        -- game_bt:setAnchorPoint(cc.p(0, 0.5)) 

                        table.insert(opened_game_bt_table,game_bt) 
                        gamelist_lv:insertCustomItem(game_bt,gamelist_lv:getIndex(sender)+k)
                        ----------------------------------显示游戏名称------------------------------------
                        local  text_tt_n = game_bt:getChildByName("text_tt_n")
                        local  text_tt_s = game_bt:getChildByName("text_tt_s")
                        text_tt_n:setString(gameName)
                        text_tt_s:setString(gameName)

                        text_tt_n:setVisible(true)
                        text_tt_s:setVisible(true)

                        --设置默认选中的游戏配置(有记忆项则选择上次游戏，没有则选择第一个)

                        if openLevel then  --如果强制打开的level存在的时候，如创建完房间之后跳到对应tab
                            -- print(openLevel,level,"测试强制打开level")
                            if openLevel == level then
                                text_tt_s:setVisible(false)
                                game_bt:setEnabled(false)
                                funcEvent(level,gameId)
                            end
                        elseif  k == 1 then --defaultGameName == gameName then
                            text_tt_s:setVisible(false)
                            game_bt:setEnabled(false)
                            funcEvent(level,gameId)
                        end
                        --------------------------------------------------------------------------------
                        game_bt:addTouchEventListener(function(sender,event)

                            if  event == TOUCH_EVENT_BEGAN then

                            end

                            if  event == TOUCH_EVENT_CANCELED then
                                dump("取消点击")         
                            end

                            --触摸结束
                            if event == TOUCH_EVENT_ENDED then

                                require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)


                                if limitClickTime then

                                    if  forbitClick then
                                        require(CommonTips_filePath):showSmallTips("您的操作过于频繁")
                                        if  sender.selected ~= true then
                                            sender:setBrightStyle(0)
                                        else
                                            sender:setBrightStyle(1)
                                        end
                                        return false
                                    end
                                    
                                    forbitClick = true

                                    SCENENOW["scene"]:performWithDelay(function()
                                        forbitClick = false
                                    end,limitClickTime)
                                end


                                for i,game_bt in pairs(opened_game_bt_table) do
                                    game_bt:setEnabled(true)
                                    game_bt:getChildByName("text_tt_s"):setVisible(true)
                                end
                                
                                sender:setEnabled(false)
                                sender:getChildByName("text_tt_s"):setVisible(false)

                                funcEvent(level,gameId)
                            end

                        end)

                    end

                end
                
            end

            local index = gamelist_lv:getIndex(sender)
            local ratioY = index/#(gamelist_lv:getChildren())*100
                  gamelist_lv:jumpToPercentVertical(ratioY)
    end     

    -- dump(gameList,"gameListshowGameList")
    for t,singleGame in pairs(gameList) do         
        
        if singleGameType == nil or (singleGameType and t == singleGameType)  then
            -- dump(t,"游戏的序号")
            local gameName = singleGame["gameType"]

            local typeGameList = singleGame["gameArr"]

            -- dump(singleGame, "------singleGame------")
            local singleGameNums = #typeGameList

            if  singleGameNums > 0 then

                local bigGame_bt = cc.CSLoader:createNode(CreateGroup_TabType_Csb_filePath):getChildByName("game_bt"):removeFromParent()
                bigGame_bt:setAnchorPoint(cc.p(0, 0.5)) 
                gamelist_lv:pushBackCustomItem(bigGame_bt)
                ----------------------------------显示游戏名称------------------------------------
                local text_tt_n = bigGame_bt:getChildByName("text_tt_n")
                local text_tt_s = bigGame_bt:getChildByName("text_tt_s")
                      text_tt_n:setString(singleGame["gameType"])
                      text_tt_s:setString(singleGame["gameType"])
                      text_tt_n:setVisible(true)
                      text_tt_s:setVisible(true)

                table.insert(opened_big_game_bt_table,bigGame_bt)

                -- dump(t,"游戏gameTypE")
                if  t == lastSelectedGameType then
                    openBigGameList(bigGame_bt,typeGameList,t)   
                end

                bigGame_bt:addTouchEventListener(function(sender,event)

                    --触摸结束
                    if  event == TOUCH_EVENT_BEGAN  then
                        -- dump("点击开始")  
                        sender:setBrightStyle(1) 
                    end

                    if  event == TOUCH_EVENT_CANCELED  then
                    --     sender:setBrightStyle(1)     
                        -- dump("取消点击") 
                        if  sender.selected ~= true then
                            sender:setBrightStyle(0)
                        else
                            sender:setBrightStyle(1)
                        end

                    end 

                    if  event == TOUCH_EVENT_ENDED then
                        
                        require("hall.GameCommon"):playEffectSound(HallButtonClickVoice_filePath)

                        openLevel = nil

                        if limitClickTime then

                            dump("限制频繁操作")

                            if  forbitClick then
                                require(CommonTips_filePath):showSmallTips("您的操作过于频繁")
                                if  sender.selected ~= true then
                                    sender:setBrightStyle(0)
                                else
                                    sender:setBrightStyle(1)
                                end
                                return false
                            end

                            forbitClick = true

                            SCENENOW["scene"]:performWithDelay(function()
                                forbitClick = false
                            end,limitClickTime)
                        end

                        if  touchBigButtonFunc then
                            touchBigButtonFunc()
                        end

                        -- dump("打开游戏列表")

                        openBigGameList(bigGame_bt,typeGameList,t)

                        if  sender.selected ~= true then
                            sender.selected = true

                            if  funcType == 0 or funcType == 3  then
                                cc.UserDefault:getInstance():setStringForKey("lastCreateGameType_Gold",t)
                            else
                                cc.UserDefault:getInstance():setStringForKey("lastCreateGameType_RoomCard",t)
                            end
                        else
                            sender.selected = false                          
                        end

                    end

                end)

            end

        end

    end

end



return GameList