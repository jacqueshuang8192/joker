local UserInfoPlaneOperator = class("UserInfoPlaneOperator")
local PokerCard = require( TpackageName..".PokerCard")

function UserInfoPlaneOperator:init(playerType,plane)

    if tolua.isnull(plane) then
        return
    end
    self._cards = {} --已经出牌尚未比牌时的牌数据
    plane:setVisible(false)
    self:showHeadSymbol(plane,"disconnect",false)
    self:showHeadSymbol(plane,"qiang",false)
    self:showHeadSymbol(plane,"room_rd",false)
    self:showHeadSymbol(plane,"owner",false)
    self:showHeadSymbol(plane,"banker",false)
    self:operationCardZhong(plane, false, 0)
    self:clearBetChip(plane)
    self:setCoin(plane,0)
    self:bindHandCardNode(plane,playerType)
    self:setHandCardNode(plane,false)
    self:set_back_vw(plane,false)
    plane:getChildByName("qiangzhuang_img"):setVisible(false)
    plane:getChildByName("beishu_txt"):setString("1 倍")
    plane:getChildByName("beishu_txt"):setVisible(false)
    plane.score_txt:hide()
end

function UserInfoPlaneOperator:set_back_vw(plane)
    plane.back_vw:removeAllChildren()
end

function UserInfoPlaneOperator:bindHandCardNode(plane,playerType)
    local cords_comp = plane.handcard_plane.cords_comp.root
    if playerType == CARD_PLAYERTYPE_MY then
        cords_comp.click_dao:onClick(handler(self, self.onClickDao))
    end

    for i=1,13 do
        local cardNode = ViewBase:seekChild(cords_comp,"FileNode_"..i)
        if not cardNode:getComponent(TpackageName..".PokerCard_3") then
            cc(cardNode):addComponent(TpackageName..".PokerCard_3"):exportMethods()
            cardNode:initUI(cardNode)
        end
    end

end

function UserInfoPlaneOperator:onClickDao(event)
    local target = event.target
    if target.isBack then
        for idx=1,13 do
            local node = ViewBase:seekChild(target:getParent(),"FileNode_"..idx)
            node:showFront()
        end
        target.isBack = false
    else
        for idx=1,13 do
            local node = ViewBase:seekChild(target:getParent(),"FileNode_"..idx)
            node:showBack()
        end
        target.isBack = true
    end
end

function UserInfoPlaneOperator:setHandCardNode(plane, flag, data, playerType)
    if plane == nil then return end
    local handcard_plane = plane.handcard_plane
    handcard_plane:setVisible(flag)
end

function UserInfoPlaneOperator:operationCardZhong(plane, flag, isOpen)
    if plane == nil then
        return
    end

    local operationTip = plane:getChildByName("operationTip")
    if operationTip then
        operationTip:setVisible(false)
        -- operationTip:setVisible(flag)
    end

end


function UserInfoPlaneOperator:hidePlayer(plane)
    if plane == nil then
        return
    end
    plane:setVisible(false)
end

function UserInfoPlaneOperator:showPlayer(plane)
    plane:setVisible(true)
end

function UserInfoPlaneOperator:relocate(plane)
    plane:setVisible(false)
end

function UserInfoPlaneOperator:setBetChip(plane,value,flag)
    if plane == nil then
        return
    end
    local bet_chip = plane:getChildByName("bet_chip")

    if  value and value > 1000000 then
        local finalChipTxt = tostring(value/1000000)
        value = string.format("%.1f", finalChipTxt) .. "万"
    end

    bet_chip:setString(value)

    if  flag ~= nil then
        bet_chip:setVisible(flag)
    end
end

function UserInfoPlaneOperator:setTextNmuber(plane,value)
    local text_num = plane:getChildByName("text_num")
    if text_num then
        local number = value
        --text_num:setVisible(false)
        if value >= 0 then
            number = "+"..value
        end
        text_num:setString(number)
    end
end

function UserInfoPlaneOperator:setTotalBetChip(plane,value)
    if plane == nil then
        return
    end
    self:setCoin(plane,value)
end

function UserInfoPlaneOperator:clearBetChip(plane)
    if plane == nil then
        return
    end
    self:setTotalBetChip(plane,0)

end

function UserInfoPlaneOperator:setReadyStatus(plane,flag)
    local img = plane:getChildByName("room_rd")
    
    if  img then
        if  flag == true then
            img:setVisible(true)
        elseif  flag == "action" then  
            img:setVisible(true)
            img:setScale(4)
            img:setOpacity(40)

            local action = cc.EaseSineOut:create(cc.Spawn:create(cc.ScaleTo:create(0.3,1),cc.FadeIn:create(0.3)))
            img:runAction(action)
        else
            img:setVisible(false)
        end
    end

end


function UserInfoPlaneOperator:showBetEffect(plane,value)

    local coin_sp = display.newSprite(coin_img_path)

    local head = plane:getChildByName("head_img")
    local targetPos = head:getPosition()
    local oriPos = cc.p(targetPos.x + math.random(-30,30) ,targetPos.y + math.random(80,120))

    coin_sp:setPosition(oriPos)
    plane:addChild(coin_sp, 100)

    -- local random = value/BASE_CHIP * 4

    local animtime = 0.2 + 0.05 * math.random(10)

    local mb = cc.MoveBy:create(animtime,cc.p(0,math.random(-80,-120)))

    local fo = cc.FadeOut:create(0.2)
    local remove_action = cc.CallFunc:create(function()           
          coin_sp:removeFromParent()
    end)
    local seq = cc.Sequence:create(mb, fo, remove_action)
    coin_sp:runAction(seq)

end

function UserInfoPlaneOperator:switchMode(plane,_type)

    local head_frame_img = plane:getChildByName("head_frame_img")
    local head = plane:getChildByName("head_img")

    local bet_chip = plane:getChildByName("bet_chip")
    local total_bet_chip = plane:getChildByName("total_bet_chip")
    local btn_buygold = plane:getChildByName("btn_buygold")
    local name_txt = plane:getChildByName("name_txt")
    local chip_txt = plane:getChildByName("chip_txt")

    if  _type == 1 then

        head_frame_img:setTouchEnabled(true)
        head:setTouchEnabled(false)
        
        chip_txt:setVisible(false)

        if  btn_buygold and isGoldGame == 0 then
            btn_buygold:setVisible(false)
        else
            name_txt:setVisible(false)
        end

        bet_chip:setVisible(true)
        total_bet_chip:setVisible(true)

    else
        head_frame_img:setTouchEnabled(false)
        head:setTouchEnabled(true)

        chip_txt:setVisible(true)

        if  btn_buygold and isGoldGame == 0 then
            if isiOSVerify then
                btn_buygold:setVisible(false)
            else
                btn_buygold:setVisible(true)
            end
        else
            name_txt:setVisible(true)
        end   
            
        bet_chip:setVisible(false)
        total_bet_chip:setVisible(false)

    end

end


function UserInfoPlaneOperator:clearGameDatas(playerType,plane,stage)
    dump("clearGameDatas")
    -- if  stage == 1 then
    --     self:switchMode(plane,2)
    --     self:clearBetChip(plane)
    -- 	self:setGrabBankerTimes(plane,0,false)
    -- elseif stage == 2 or stage == nil then
    --     self:showHeadSymbol(plane,"banker",false)
    -- end
    plane:stopAllActions()
    local score_txt = plane.score_txt:hide()

end

function UserInfoPlaneOperator:showHeadSymbol(plane,_type,flag)

    if _type == "disconnect" then
        local img = plane:getChildByName("online_img")

        if img then
            img:setVisible(flag)
        end

    elseif  _type == "banker" then

        local img = plane:getChildByName("zhuang_flag")

        if img then
            img:setVisible(flag)
        end

    elseif  _type == "owner" then

        local img = plane:getChildByName("owner_img")

        if img then
            img:setVisible(flag)
        end
    elseif _type == "qiang" then
        local img = plane:getChildByName("qiang_zhuang")

        if img then
            img:setVisible(flag)
        end
    elseif _type == "room_rd" then
        local img = plane:getChildByName("room_rd")

        if img then
            img:setVisible(flag)
        end

    end

end

function UserInfoPlaneOperator:showMyPlayerInfo(plane,userInfo)
    plane:setVisible(true)
    plane.uid = userInfo["uid"]
    local head = plane:getChildByName("head_img")
    userInfo["icon_url"] = userInfo["icon_url"] or DefaultHead_filePath
    local nickname = userInfo["nickName"]
    local coins = userInfo["gold"]
    local goldStr = ""
    print("coinsshowMyPlayerInfo",coins)
    if 	coins > 99999 then
        local finalChipTxt = tostring(coins/10000)
        if string.len(finalChipTxt) <= 4 then
            goldStr = string.format("%.1f", finalChipTxt) .. "万"
        else
            -- local endlength = string.find(finalChipTxt,"%.")
            -- goldStr = string.sub(finalChipTxt,1,endlength-1) .. "万"
            goldStr = string.format("%.2f", finalChipTxt) .. "万"
        end
    else
        goldStr = tostring(coins)
    end
    local 	headWidth =  137.00
    local 	headHeight =  120
    local chip_txt = plane:getChildByName("chip_txt")
    chip_txt:setString(goldStr)
    local name_txt = plane:getChildByName("name_txt")
    local nickname = require("hall.GameCommon"):formatNick(nickname, 4)
    name_txt:setString(nickname)
    local total_bet_chip = plane:getChildByName("total_bet_chip")
    local text_pwd = plane:getChildByName("text_pwd")
    if USER_INFO["roomPassword"] and USER_INFO["roomPassword"] ~= "" then
        text_pwd:setString("密码："..USER_INFO["roomPassword"] or "")
    else
        text_pwd:setVisible(false)
    end
    require("hall.GameCommon"):setPlayerHead(userInfo, head, head:getContentSize().width)
    -- require("hall.GameCommon"):setPlayerHead(userInfo, head, 100)
    --self:getUserHeadLight(icon_url, userInfo["uid"], userInfo["sex"], head, headSize, 185,false,nickname,userInfo)
   -- require("hall.GameCommon"):setPlayerHead(userInfo,head,108)
  -- require("hall.GameCommon"):getUserHead(icon_url, userInfo["uid"], userInfo["sex"], head, headSize, false,nickname)
   -- self:getUserHead(icon_url, userInfo["uid"], userInfo["sex"], head, headWidth,headHeight, false,nickname)
    return head
end

function UserInfoPlaneOperator:updateTableNoTotal(plane, chip)
end

function UserInfoPlaneOperator:showPlayerInfo(playerType,plane,userInfo,seat)
    dump(userInfo, "showPlayerInfo")
    plane:setVisible(true)
    plane.uid = userInfo["uid"]
    userInfo["icon_url"] = userInfo["icon_url"] or DefaultHead_filePath
	local nickname = userInfo["nickName"]
	local coins = userInfo["m_chips"]
	local head = plane:getChildByName("head_img")
	self:setCoin(plane,coins)
    local nick_txt = plane:getChildByName("name_txt")

    ----------------------------------------------------------------
    local 	headWidth =  120
    local 	headHeight =  120
    nickname = require("hall.GameCommon"):formatNick(nickname, 4)
    nick_txt:setString(nickname)
    if SHISANZHANG_GAME_STATE == GAME_STATUS_STOP then
        if  STAR_GAME_UID ~= USER_INFO["uid"] and  STAR_GAME_UID ~= userInfo.uid then
            if userInfo.if_ready > 0 then
                dump(userInfo.uid,"准备状态显示啦~~~~")
                self:showHeadSymbol(plane, "room_rd",true)
            else
                self:showHeadSymbol(plane, "room_rd",false)
            end
        end
    else
        self:showHeadSymbol(plane, "room_rd",false)
    end
    --    self:getUserHeadLight(icon_url, userInfo["uid"], userInfo["sex"], head, headSize, 185,false,nickname,userInfo)
    --	require("hall.GameCommon"):getUserHead(userInfo["icon_url"], userInfo["uid"], userInfo["sex"], head, headWidth,headHeight, false,nickname)
    require("hall.GameCommon"):getUserHead(userInfo["icon_url"], userInfo["uid"], userInfo["sex"], head, head:getContentSize().width, false, nickname)

	return head
end

function UserInfoPlaneOperator:setCoin(plane,value)
    if plane == nil then
        return
    end
	if  plane then
        local chip = plane:getChildByName("grade_txt")
        value = value / 100
        plane.coin = value
        local goldStr = ""

		if 	value > 99999 then
            local finalChipTxt = tostring(value/10000)
            if string.len(finalChipTxt) <= 4 then
                goldStr = string.format("%.1f", finalChipTxt) .. "万"
            else
                -- local endlength = string.find(finalChipTxt,"%.")
                -- goldStr = string.sub(finalChipTxt,1,endlength-1) .. "万"
                goldStr = string.format("%.2f", finalChipTxt) .. "万"
            end
        else
            goldStr = tostring(value)
		end
		chip:setString(goldStr)
	end
end

--检查图片格式
function UserInfoPlaneOperator:getUrlPicture(url)
    -- body
    if url == "" or url == nil then
        return ""
    end
    dump(url,"getUrlPicture")
    local strLower = string.lower(url)
    if string.find(strLower,"%.jpg") == nil and string.find(strLower,"%.png") == nil then
        return self:getUnformatPic(url)
    end
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    print("getUrlPicture:",strPic)
    return strPic
end

--获取非格式化图片名称
function UserInfoPlaneOperator:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    strUrl = string.sub(strUrl,nPos+1,string.len(strUrl))
    nPos = string.find(strUrl,"/")
    if nPos == nil then
        return nil
    end
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    print("getUnformatPic:",strPic)
    return strPic..".jpg"
end

function UserInfoPlaneOperator:setDefaultHead(head,uid,sex,width,height,isCircle,nick)

    isCircle = isCircle or false
    nick = nick or ""
    if isCircle then
        self:setCirleHead(head, "", width,height, uid, sex, "", nick)
    else
        self:setDefaultFangHead(head, "", width,height, uid, sex, "", nick)
    end

end

function UserInfoPlaneOperator:setDefaultFangHead(head, strIco, size, uid, sex, url, nick)

    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0)

    local stencil = cc.Node:create()
    clipnode:setStencil(stencil)

    local spStnecil = display.newSprite(Stnecil_filePath)
    spStnecil:setScale(size/spStnecil:getContentSize().width)
    stencil:addChild(spStnecil)

    local content
    local file,fileErr = io.open(strIco)
    if fileErr == nil then
        local x = file:seek("end")
        if x > 0 then
            content = display.newSprite(strIco)
        else
            content = display.newSprite(DefaultHead_filePath)
        end
    else
        content = display.newSprite(DefaultHead_filePath)
    end
    -- local content = display.newSprite(strIco)
    content:setPosition(head:getContentSize().width/2, head:getContentSize().height/2)
    content:setScaleX(size/content:getContentSize().width)
    content:setScaleY(size/content:getContentSize().height)
    -- clipnode:addChild(content)

    clipnode:setPosition(clipnode:getContentSize().width/2,clipnode:getContentSize().height/2)
    head:addChild(content)

    if head.setTexture ~= nil then
        head:setTexture("")
    end

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))
    layerTouch:setPosition(head:getContentSize().width/2, head:getContentSize().height/2)
    layerTouch:setTouchEnabled(true)
    layerTouch:addTouchEventListener(
            function(sender,event)
                if event == 2  then
                    self:showPlayerInfoForGetHead(url,uid,sex,nick)
                end
            end)
    layerTouch:setContentSize(cc.size(size,size))
    head:addChild(layerTouch)

end

function UserInfoPlaneOperator:getUserHead(url,uid,sex,sp,width,height,isCircle,nick)

    -- body
    isCircle = isCircle or false
    sex = sex or 0
    local file = nil
    local fileErr = nil
    local spHead = nil

    --链接空，载入默认头像
    local strHead = self:getUrlPicture(url)
    if strHead == nil or strHead == "" then
        self:setDefaultHead(sp,uid,sex,width,height,isCircle,nick)
        return
    end
    sp:retain();

    --先在本地获取
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then

        if not isCircle then

            local x = file:seek("end")
            if x > 0 then

            else
                imgFullPath = DefaultHead_filePath
            end

            sp:loadTexture(imgFullPath)
            sp:setContentSize(cc.size(width,height))
            sp:setTouchEnabled(true)
            sp:addTouchEventListener(

                    function(sender,event)
                        --触摸结束
                        if event == TOUCH_EVENT_ENDED then
                            self:showPlayerInfoForGetHead(url,uid,sex,nick)
                        end

                    end

            )

        else
            -- self:setCirleHead(sp,imgFullPath,size)
            self:setCirleHead(sp, imgFullPath, width,height, uid, sex, url, nick)
        end

    else

        local function onRequestFinished(event,filename)
            -- body
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end

            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            print(response)

            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            print("savedata:"..filename)
            while (not request:saveResponseData(filename)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时

            cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)

            if not isCircle then
                sp:loadTexture(imgFullPath)
                sp:setContentSize(cc.size(width,height))
                sp:setTouchEnabled(true)
                sp:addTouchEventListener(

                        function(sender,event)
                            --触摸结束
                            if event == TOUCH_EVENT_ENDED then
                                self:showPlayerInfoForGetHead(url,uid,sex,nick)
                            end

                        end

                )

            else
                -- self:setCirleHead(sp,imgFullPath,size)
                self:setCirleHead(sp, imgFullPath, width,height, uid, sex, url, nick)
            end
        end

        local request = network.createHTTPRequest(function (event)
            -- body
            if event.name == "completed" then
                onRequestFinished(event,imgFullPath)
            end
        end,url,"GET")
        request:start()

    end
end

function UserInfoPlaneOperator:showPlayerInfoForGetHead(icon_url, uid, sex_num, nick)
    dump(icon_url, "-----玩家详情(新)-----")
    dump(uid, "-----玩家详情(新)-----")
    dump(sex_num, "-----玩家详情(新)-----")
    dump(nick, "----------- 玩家详情(新) ----------")
    if uid == nil then
        return
    end

    if uid == "" then
        return
    end

    --[[    if nick == nil then
            nick = uid
        end]]

    local userInfo = {}
    userInfo["isShowInGame"] = bm.isInGame
    userInfo["nickName"] = nick
    userInfo["uid"] = uid
    --userInfo["location_arr"] = {}
    --userInfo["ip"] = ""

    require("hall.view.userInfoView.userInfoView"):showView(icon_url, userInfo)

end

function UserInfoPlaneOperator:setPlayerScore( plane, score, isPlus, isAction )
    -- local playerType = SHISANZHANG_PLAYERTYPE_TABLE[uid]
    -- local plane = GamePlaneOperator:getPlayerPlane(playerType)

    local handcard_plane = plane.handcard_plane:show()
    local cords_comp = handcard_plane.cords_comp.root
    local scoreNode = cords_comp.result["score_4"]:setVisible(true)
    cords_comp.result["type_4"]:setVisible(true)
    if isPlus then
        local str = scoreNode:getString() or 0
        print(score)
        score = score + tonumber(str)
        print(score)
        dump(tonumber(str),"----------原先的分")
    end


    local time = 0.2
    if score >= 0 then
        score = "+"..score
        scoreNode:setFntFile(TpackageName .. "/res/layout/roomScene/win_num.fnt")
    else
        scoreNode:setFntFile(TpackageName .. "/res/layout/roomScene/lose_num.fnt")
    end
    scoreNode:setString(score)
    if not isAction then
        local action_1 = cc.ScaleTo:create(time,1.4)
        local action_2 = cc.ScaleTo:create(time,1)
        scoreNode:runAction(cc.Sequence:create(action_1,action_2))
    end
   
end

function UserInfoPlaneOperator:updateCoin(plane,value)
    dump(value,"金币的改变值")
    if value then
        local score_txt = plane.score_txt
        self:setPlayerScore( plane, value, nil, true )
        score_txt:setVisible(true)
        if value < 0 then
            value = tostring(value)
            score_txt:setFntFile(TpackageName .. "/res/layout/roomScene/lose_num.fnt")
        else
            value = "+"..tostring(value)
            score_txt:setFntFile(TpackageName .. "/res/layout/roomScene/win_num.fnt")
        end
        score_txt:setString(value)
    end
    
end

function UserInfoPlaneOperator:showPlayerBeishu(plane,beishu)
    plane:setVisible(true)
end

return UserInfoPlaneOperator