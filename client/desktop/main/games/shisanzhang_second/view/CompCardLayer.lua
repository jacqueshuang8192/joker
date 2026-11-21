local CompCardLayer = class("CompCardLayer")
local ActionUtils = require(TpackageName .. ".ActionUtils")
local CardUtils = require(TpackageName .. ".CardUtils")
local ShiSanZhangConfig = require(TpackageName..".config.ShiSanZhangConfig")

function CompCardLayer:outCards(playerType, plane, flag, open_cards)
    if plane == nil then return end
    local handcard_plane = plane.handcard_plane
    local cords_comp = handcard_plane.cords_comp.root
    cords_comp.click_dao:setEnabled(false)

    if flag == true then
        plane.back_vw:removeAllChildren()
        if type(open_cards) == "table" then
            cords_comp.click_dao:setEnabled(true)

            local cardIdx = 1
            for nodeIdx, info in ipairs(open_cards) do
                local dao = cords_comp.dao["Panel_"..nodeIdx]
                for i,cards in ipairs(info.son_card) do
                    local node = dao["FileNode_"..cardIdx]
                    node:setCard(cards)
                    cardIdx = cardIdx + 1
                end
            end
        end
    end

    handcard_plane:setVisible(flag)
    for idx=1,13 do
        local node = ViewBase:seekChild(cords_comp.dao,"FileNode_"..idx)
        node:showBack()
    end
    for i=1,4 do
        cords_comp.result["score_"..i]:setVisible(false)
        cords_comp.result["type_"..i]:setVisible(false)
    end
    cords_comp.result["teshu"]:setVisible(false)
end

function CompCardLayer:compCards(totalInfo)

    if totalInfo == nil then 
        return 
    end

    self:claerAllPlane()


    local userInfos = {}
    local userInfosSpcard = {}
    for i,userInfo in ipairs(totalInfo) do
        if userInfo.cardSpcardOutType > 1 then
            table.insert( userInfosSpcard, userInfo )
        else
            table.insert( userInfos, userInfo )
        end
    end

    local talScoreKey = {
        [1] = "tdScore",
        [2] = "zdScore",
        [3] = "wdScore",
    }
    local talTsScoreKey = {
        [1] = "tsTScore",
        [2] = "tsZScore",
        [3] = "tsWScore",
    }
    --显示普通牌玩家的每一道牌
    local timeIdx = 0
    local timeSpcard = 0

    for nodeIdx = 1, 3 do
        local daoTime = 0
        for _, userInfo in ipairs(userInfos) do
            local uid = userInfo.uid
            local playerType = SHISANZHANG_PLAYERTYPE_TABLE[uid]
            local plane = GamePlaneOperator:getPlayerPlane(playerType)
            local handcard_plane = plane.handcard_plane:show()
            local cords_comp = handcard_plane.cords_comp.root
            local openCard = userInfo.openCard
            local dao = cords_comp.dao["Panel_"..nodeIdx]
            local time = 0.2

            if BALANCE_SPEED == 1 then
                time = time*0.3
            elseif BALANCE_SPEED == 2 then
                time = time*0.85
            end

            local action1=cc.ScaleTo:create(time,1.4)
            local action2=cc.ScaleTo:create(time,1)

            daoTime = time*5*timeIdx

            local delay = cc.DelayTime:create(daoTime)
            dao:setLocalZOrder(99)

            local cardsType = openCard[nodeIdx].son_card_type

            if nodeIdx == 1 and cardsType == 4 then
                cardsType = "冲三"
            elseif nodeIdx == 2 and cardsType == 7 then
                cardsType = "中墩葫芦"
            end

            local cards = openCard[nodeIdx].son_card

            local callFuncAc_1 = cc.CallFunc:create(function ()
                for i,node in ipairs(dao:getChildren()) do
                    node:setCard(cards[i])
                    node:showFront()
                end
            end)

           
            local callFuncAc_21 = cc.CallFunc:create(function ()
                SoundUtils:playCardKindEffect(cardsType, SHISANZHANG_USERINFO_TABLE[uid].sex)

            end)

            dao:runAction(cc.Sequence:create(delay,callFuncAc_1,action1,action2,callFuncAc_21))
            timeIdx = timeIdx + 1
        end


        --计算每一道牌的分
        for _, userInfo in ipairs(userInfos) do
            local uid = userInfo.uid
            local playerType = SHISANZHANG_PLAYERTYPE_TABLE[uid]
            local plane = GamePlaneOperator:getPlayerPlane(playerType)
            local handcard_plane = plane.handcard_plane:show()
            local cords_comp = handcard_plane.cords_comp.root
            local openCard = userInfo.openCard
            local dao = cords_comp.dao["Panel_"..nodeIdx]
            timeSpcard = daoTime+0.2

            local delay = cc.DelayTime:create(timeSpcard)

            local callFuncAc_1 = cc.CallFunc:create(function ()
                dao:setLocalZOrder(nodeIdx)
                local scoreNode = cords_comp.result["score_"..nodeIdx]:setVisible(true)
                local typeNode = cords_comp.result["type_"..nodeIdx]:setVisible(true)
                local cardsType = openCard[nodeIdx].son_card_type
                local ScoreKey = talScoreKey[nodeIdx]
                local TsScoreKey = talTsScoreKey[nodeIdx]
                local score_1 = userInfo[ScoreKey]
                local score_2 = userInfo[TsScoreKey]
    
                if nodeIdx == 1 and cardsType == 4 then
                    cardsType = "冲三"
                elseif nodeIdx == 2 and cardsType == 7 then
                    cardsType = "中墩葫芦"
                end

                local fileName = CardUtils:getTypeFileName(cardsType)

                dump(fileName,"-----fileName")

                typeNode:loadTexture(TpackageName.."/res/layout/roomScene/type/"..fileName..".png", 1)

                ViewBase:setTextureSize(typeNode)

                if score_1 >= 0 then
                    scoreNode:setFntFile(TpackageName .. "/res/layout/roomScene/zong_win_num.fnt")
                    score_1 = "+"..score_1
                else
                    scoreNode:setFntFile(TpackageName .. "/res/layout/roomScene/zong_lose_num.fnt")
                end
                if score_2 >= 0 then
                    score_2 = "+"..score_2
                end

                local text = ""
                local tal = {
                    [3] = "left",
                    [6] = "left",
                    [8] = "left"
                }
                if tal[playerType] then
                    text = "( " .. score_2 .. " ) " .. score_1
                else
                    text = score_1.. " ( " .. score_2 .. " )"
                end
                scoreNode:setString(text)
               
            end)
            dao:runAction(cc.Sequence:create(delay,callFuncAc_1))
        end
    end

    --显示特殊牌玩家的牌
    for idx,userInfo in ipairs(userInfosSpcard) do
        local cardSpcardOutType = userInfo.cardSpcardOutType
        local uid = userInfo.uid
        local playerType = SHISANZHANG_PLAYERTYPE_TABLE[uid]
        local plane = GamePlaneOperator:getPlayerPlane(playerType)
        local handcard_plane = plane.handcard_plane:show()
        local cords_comp = handcard_plane.cords_comp.root
        local openCard = userInfo.openCard
        local time = 1.5

        if BALANCE_SPEED == 1 then
            time = time*0.3
        elseif BALANCE_SPEED == 2 then
            time = time*0.85
        end

        timeSpcard = timeSpcard + (idx - 1) * time


        local delay = cc.DelayTime:create(timeSpcard)

        local callFuncAc_1 = cc.CallFunc:create(function ()
            for nodeIdx = 1, 3 do
                local dao = cords_comp.dao["Panel_"..nodeIdx]
                local cards = openCard[nodeIdx].son_card
                for i,node in ipairs(dao:getChildren()) do
                    node:setCard(cards[i])
                    node:showFront()
                end
            end
            GamePlaneOperator:setTeShuAnim(cardSpcardOutType)
            local typeNode = cords_comp.result["teshu"]:setVisible(true)
            local cardsType = cardSpcardOutType
			local fileName = CardUtils:getTypeFileName(cardsType)
            dump(fileName,"----------------fileName")
            typeNode:loadTexture(TpackageName.."/res/layout/roomScene/type/"..fileName..".png", 1)
            SoundUtils:playCardKindEffect(cardsType, SHISANZHANG_USERINFO_TABLE[uid].sex)
            ViewBase:setTextureSize(typeNode)
        end)
        local tar = SHISANZHANG_GAME_SCENE:runAction(cc.Sequence:create(delay,callFuncAc_1))
        -- table.insert(SHISANZHANG_GAME_SCENE.compActiveTarTal, tar)
    end

    --计算所有玩家的总分
    for idx,userInfo in ipairs(totalInfo) do
        local uid = userInfo.uid
        local playerType = SHISANZHANG_PLAYERTYPE_TABLE[uid]
        local delay = cc.DelayTime:create(timeSpcard)
        local callFuncAc_1 = cc.CallFunc:create(function ()
            GamePlaneOperator:setPlayerScore(playerType, userInfo.jcScore)
        end)
        SHISANZHANG_GAME_SCENE:runAction(cc.Sequence:create(delay,callFuncAc_1))
        -- table.insert(SHISANZHANG_GAME_SCENE.compActiveTarTal, tar)
    end
end

function CompCardLayer:setShotData(userInfos, dqIdx)
    local dqIdx = 0
    local time = 1.5
    table.sort( userInfos, function(a,b)
        return a.dqSize > b.dqSize
    end )

    for i, userInfo in ipairs(userInfos) do
        local dqUid = userInfo.uid
        local dqMap = userInfo.dqMap
        for idx,todqData in pairs(dqMap) do
            local isqld = false
            dump(idx,"111111111111")
            dump(dqMap,"-----------")
            dump(userInfo,"-----------")
            if userInfo.isSwat == 1 and idx == #dqMap then
                isqld = true
            end
            SHISANZHANG_GAME_SCENE:performWithDelay(function()
                self:setShotAndShoting(dqUid, todqData, true, isqld)
            end,time * dqIdx)
            dqIdx = dqIdx + 1
            dump(dqUid, "打枪算分-----------")

        end
    end

end
-- playerType_1 打枪,playerType_2被打枪
function CompCardLayer:setShotAndShoting(uid_1,todqData,flag, isqld)
    SoundUtils:playCardKindEffect("打枪", SHISANZHANG_USERINFO_TABLE[uid_1].sex)
    
    local uid_2 = todqData.theUid
    local playerType_1 = SHISANZHANG_PLAYERTYPE_TABLE[uid_1]
    local playerType_2 = SHISANZHANG_PLAYERTYPE_TABLE[uid_2]
    local plane_1 = GamePlaneOperator:getPlayerPlane(playerType_1)
    local plane_2 = GamePlaneOperator:getPlayerPlane(playerType_2)
    local isPlus = true
    dump(uid_1,"------打枪,playerType_2被打枪")
    dump(isqld, "-----------全垒打")

    local setPlayerScore = function()
        dump(uid_1)
        dump(todqData.score, "算分-----------打枪结算")
        GamePlaneOperator:setPlayerScore(playerType_1, todqData.score, isPlus)
        GamePlaneOperator:setPlayerScore(playerType_2, -(todqData.score), isPlus)

        if isqld then --全垒打
            if ShiSanZhangConfig:getVersion() then
                GamePlaneOperator:setAnim("quanleida")
            else
                GamePlaneOperator:setTeShuAnim("quanleida")
            end
            SoundUtils:playCardKindEffect("全垒打", SHISANZHANG_USERINFO_TABLE[uid_1].sex)
        end
    end

    self:setShot(plane_1, flag, playerType_1, playerType_2, setPlayerScore)
    self:setToShot(plane_2, flag)
end

-- playerType_1 打枪,playerType_2被打枪
function CompCardLayer:setShot(plane, flag, playerType_1, playerType_2, callFun)
    -- local shot = ViewBase:seekChild(plane,"shot")
    local shot = plane.shot_img.shot
    if not shot then
        ActionUtils:creatorShotAnimNode(plane)
        shot = plane.shot_img.shot
    end
    shot:setVisible(flag)
    if flag then
        local Angles = self:getShotAngles(playerType_1,playerType_2)
        dump(os.date(),"打枪开始-----------")
        shot:setRotation(Angles)
        local anim = shot:getAnimation()
		anim:playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔 第三个是是否循环
		local function handler1(Armature, MovementEventType, handlerName)
			if MovementEventType == ccs.MovementEventType.complete then
                shot:hide()
                dump(os.date(),"打枪结束-----------")
                if callFun then
                    callFun()    
                end
			end
		end
		anim:setMovementEventCallFunc(handler1)        
    end
end

--被打枪
function CompCardLayer:setToShot(plane,flag)
    if flag and SHISANZHANG_GAME_SCENE and plane then
        ActionUtils:setToShot(plane,flag)
    end
end

-- playerType_1 打枪,playerType_2被打枪
function CompCardLayer:getShotAngles(playerType_1,playerType_2)
    local Angles = {
        [1] = {
            [1] = -33.20,
            [2] = -33.20,
            [3] = -12.78,
            [4] = -83.51,
            [5] = -83.51,
            [6] = -35.44,
            [7] = -83.51,
            [8] = -13.04,
        },
        [2] = {
            [1] = 124.26,
            [2] = 124.26,
            [3] = 43.35,
            [4] = 147.77,
            [5] = 163.82,
            [6] = 20.90,
            [7] = 125.56,
            [8] = 57.57,
        },
        [3] = {
            [1] = 30.63,
            [2] = -3.86,
            [3] = -3.86,
            [4] = -3.86,
            [5] = -3.86,
            [6] = -80.61,
            [7] = 20.87,
            [8] = 78.82,
        },
        [4] = {
            [1] = 79.61,
            [2] = -11.71,
            [3] = 0,
            [4] = 0,
            [5] = -52.15,
            [6] = -6.39,
            [7] = 79.61,
            [8] = 35.20,
        },
        [5] = {
            [1] = 72.63,
            [2] = 23.79,
            [3] = 23.79,
            [4] = 72.63,
            [5] = 72.63,
            [6] = 0,
            [7] = 72.63,
            [8] = 48.40,
        },
        [6] = {
            [1] = 40.00,
            [2] = 10.00,
            [3] = 80,
            [4] = 10.00,
            [5] = 10.00,
            [6] = 10.00,
            [7] = 30.00,
            [8] = 80,
        },
        [7] = {
            [1] = 58.72,
            [2] = -26.52,
            [3] = 0,
            [4] = -52.77,
            [5] = -70.23,
            [6] = -25.66,
            [7] = 0,
            [8] = 0,
        },
        [8] = {
            [1] = 20.73,
            [2] = -13.69,
            [3] = -46.32,
            [4] = -8.16,
            [5] = -18.26,
            [6] = -69.57,
            [7] = 0,
            [8] = 0,
        },
    } 
   return Angles[playerType_1][playerType_2] or 0
end

function CompCardLayer:claerAllPlane()
    local flag = false
    SHISANZHANG_GAME_SCENE:stopAllActions()

    local armatureObj =  SHISANZHANG_GAME_SCENE:getChildByName("kaishibipai") --重连清除开始比牌
    if armatureObj then
        if armatureObj.getAnimation then
            local Animation = armatureObj:getAnimation()
            Animation:gotoAndPause(0)  
        end
        armatureObj:stopAllActions()  
        armatureObj:removeFromParent()
    end

    for playerType = 1,TOTAL_PLAYERNUM do
        local plane = GamePlaneOperator:getPlayerPlane(playerType)
        self:setShot(plane, flag)
        plane.back_vw:removeAllChildren()
        plane.toShotVw:removeAllChildren()
        for nodeIdx=1,3 do
            local handcard_plane = plane.handcard_plane:hide()
            local cords_comp = handcard_plane.cords_comp.root
            local dao = cords_comp.dao["Panel_"..nodeIdx]
            dao:setScale(1)
            dao:stopAllActions()
            dao:setLocalZOrder(nodeIdx)

            for i,node in ipairs(dao:getChildren()) do
                node:showBack()
            end
        end
    end
end

return CompCardLayer