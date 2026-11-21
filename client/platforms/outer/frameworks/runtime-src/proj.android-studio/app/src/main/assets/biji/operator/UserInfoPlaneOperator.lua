local UserInfoPlaneOperator = class("UserInfoPlaneOperator")

local bet_coin_img_path = TpackageName .. "/images/effect_gold_3.png"
-- -- 1表示左侧对齐， 2表示中间对齐， 3表示右对齐
-- local PlayersHeadShapeTable  ={ [CARD_PLAYERTYPE_MY]     = 1,   --1表示横的头像框，2表示竖的

-- 	                            [CARD_PLAYERTYPE_LEFT1]  = 2,
-- 	                            [CARD_PLAYERTYPE_LEFT2]  = 2,
-- 	                            [CARD_PLAYERTYPE_LEFT3]  = 2,

-- 	                            [CARD_PLAYERTYPE_TOP1]   = 1,
-- 	                            [CARD_PLAYERTYPE_TOP2]   = 1,
-- 	                            [CARD_PLAYERTYPE_TOP3]   = 1,

-- 	                            [CARD_PLAYERTYPE_RIGHT1] = 2,
-- 	                            [CARD_PLAYERTYPE_RIGHT2] = 2,
-- 	                            [CARD_PLAYERTYPE_RIGHT3] = 2}

local  grab_effect_img = TpackageName .. "/images/grab_effect_1.png"
-- local  grab_banker_effect_img = TpackageName .."/images/".. "grab_banker_effect_"
local  bet_effect_img =  TpackageName .. "/images/bet_effect_1.png"

function UserInfoPlaneOperator:init(playerType,plane)

    if tolua.isnull(plane) then
        return
    end
    plane:setVisible(false)
    self:showHeadSymbol(plane,"disconnect",false)
    self:showHeadSymbol(plane,"qiang",false)
    self:showHeadSymbol(plane,"room_rd",false)
    self:showHeadSymbol(plane,"owner",false)
    self:showHeadSymbol(plane,"banker",false)
    self:operationCardZhong(plane, false, 0)
    self:clearBetChip(plane)
    self:setCoin(plane,0)
end

function UserInfoPlaneOperator:operationCardZhong(plane, flag, isOpen)
    if plane == nil then
        return
    end

    local operationTip = plane:getChildByName("operationTip")
    if operationTip then
        operationTip:setVisible(flag)
    end
    local operationTipText = operationTip:getChildByName("text")
    if isOpen == 1 then
        operationTipText:loadTexture(TpackageName .. "/res/images/text_wancheng.png")
    else
        operationTipText:loadTexture(TpackageName .. "/res/images/text_peipaizhong.png")
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
    local grade_txt = plane:getChildByName("grade_txt")
    grade_txt:setString(value/100)
    -- local jb_text =  plane:getChildByName("jb_text")
    -- jb_text:setVisible(false)
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
-- cc.EaseElasticOut:create()remove
    local seq = cc.Sequence:create(mb, fo, _action)
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
    if  stage == 1 then
        
        self:switchMode(plane,2)
        self:clearBetChip(plane)
    	-- self:setGrabBankerSymbol(plane,false)
    	self:setGrabBankerTimes(plane,0,false)


    elseif stage == 2 or stage == nil then

        plane:stopAllActions()
        local cross_effect_frame_1 = plane:getChildByName("cross_effect_frame_1")
        local cross_effect_frame_2 = plane:getChildByName("cross_effect_frame_2")
              cross_effect_frame_1:setVisible(false)
              cross_effect_frame_2:setVisible(false)

        local score_bottom = plane:getChildByName("score_bottom")
              score_bottom:setVisible(false)

        local effect_frame = plane:getChildByName("effect_frame")
        effect_frame:loadTexture(grab_effect_img)
        effect_frame:setVisible(false)

        self:showHeadSymbol(plane,"banker",false)

    end

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
    require("hall.GameCommon"):setPlayerHead(userInfo, head, 100)
    --self:getUserHeadLight(icon_url, userInfo["uid"], userInfo["sex"], head, headSize, 185,false,nickname,userInfo)
   -- require("hall.GameCommon"):setPlayerHead(userInfo,head,108)
  -- require("hall.GameCommon"):getUserHead(icon_url, userInfo["uid"], userInfo["sex"], head, headSize, false,nickname)
   -- self:getUserHead(icon_url, userInfo["uid"], userInfo["sex"], head, headWidth,headHeight, false,nickname)
    return head
end
function UserInfoPlaneOperator:updateTableNoTotal(plane, chip)
    local grade_txt = plane:getChildByName("grade_txt")
    grade_txt:setString(chip/100)
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
    if BIJI_GAME_STATE == GAME_STATUS_STOP then
        if userInfo.if_ready > 0 then
            self:showHeadSymbol(plane, "room_rd",true)
        else
            self:showHeadSymbol(plane, "room_rd",false)
        end
    end
--    self:getUserHeadLight(icon_url, userInfo["uid"], userInfo["sex"], head, headSize, 185,false,nickname,userInfo)
--	require("hall.GameCommon"):getUserHead(userInfo["icon_url"], userInfo["uid"], userInfo["sex"], head, headWidth,headHeight, false,nickname)
    require("hall.GameCommon"):getUserHead(userInfo["icon_url"], userInfo["uid"], userInfo["sex"], head, 118, false, nickname)

	return head
end



function UserInfoPlaneOperator:setCoin(plane,value)
    if plane == nil then
        return
    end
	if  plane then
        local chip = plane:getChildByName("grade_txt")
        value = value/100
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


return UserInfoPlaneOperator