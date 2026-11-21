local UserInfoPlaneOperator = class("UserInfoPlaneOperator")

local coin_img_path = TpackageName .. "/images/effect_gold.png"

local img_path_win = TpackageName .. "/images/win_flag.png"
local img_path_lose = TpackageName .. "/images/lose_flag.png"
local img_path_tie = TpackageName .. "/images/tie_flag.png"

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

function UserInfoPlaneOperator:init(playerType, panel)
    dump("-------------- UserInfoPlaneOperator:init l ----------------")
    panel:setVisible(false)

    -- 积分文本
    self:setCoin(panel, 0)
    
    -- 准备文本
	self:setReadyStatus(panel, false)

    -- 庄图标
	self:showHeadSymbol(panel,"banker",false)

   
    -- 掉线图标
	self:showHeadSymbol(panel,"disconnect",false)

    -- 对局结果图标
    self:showResultImg(panel, 0)

    -- 抢庄
    self:showZhuangAttitude(panel, 0)

    --下注的金币
    self:setBetTimes(panel,false)
    
    self:showFangZhu(panel,false)


    self:showGrabBankerFrame(panel,false)
end

function UserInfoPlaneOperator:showGrabBankerFrame(panel,flag)
    panel.effects:setVisible(flag)
end

function UserInfoPlaneOperator:getSeatIdByPlayerType(playerType)
    local seat_id = playerType - 1 + RELATIVE_SEAT_ID
    if  seat_id >= TOTAL_PLAYERNUM then
        seat_id = seat_id - TOTAL_PLAYERNUM
    end
    return  seat_id
end

function UserInfoPlaneOperator:relocate(panel)
    panel:setVisible(false)
end

function UserInfoPlaneOperator:setBetChip(panel,value,flag)
    local bet_chip = panel:getChildByName("bet_chip")

    if  value and value > 100000 then
        local finalChipTxt = tostring(value/100000)
        value = string.format("%.1f", finalChipTxt) .. "万"
    end

    bet_chip:setString(value)

    if  flag ~= nil then
        bet_chip:setVisible(flag)
    end
end

function UserInfoPlaneOperator:setTotalBetChip(panel,value,flag)
    local total_bet_chip = panel:getChildByName("total_bet_chip")

    if  value and value > 100000 then
        local finalChipTxt = tostring(value/100000)
        value = string.format("%.1f", finalChipTxt) .. "万"
    end

    total_bet_chip:setString(value)

    if  flag ~= nil then
        total_bet_chip:setVisible(flag)
    end
end

function UserInfoPlaneOperator:clearBetChip(panel)
    self:setBetChip(panel,0)
    self:setTotalBetChip(panel,0)
end

function UserInfoPlaneOperator:showBetEffect(panel,value)

    local coin_sp = display.newSprite(coin_img_path)

    local head = panel:getChildByName("head_img")
    local targetPos = head:getPosition()
    local oriPos = cc.p(targetPos.x + math.random(-30,30) ,targetPos.y + math.random(80,120))

    coin_sp:setPosition(oriPos)
    panel:addChild(coin_sp, 100)

    -- local random = value/BASE_CHIP * 4

    local animtime = 0.2 + 0.05 * math.random(10)

    local mb = cc.MoveBy:create(animtime,cc.p(0,math.random(-80,-120)))

    local fo = cc.FadeOut:create(0.2)
    local remove_action = cc.CallFunc:create(function()           
          coin_sp:removeFromParent()
    end)
-- cc.EaseElasticOut:create()
    local seq = cc.Sequence:create(mb, fo, remove_action)
    coin_sp:runAction(seq)

end

function UserInfoPlaneOperator:switchMode(panel,_type)

    local head_frame_img = panel:getChildByName("head_frame_img")
    local head = panel:getChildByName("head_img")

    local bet_chip = panel:getChildByName("bet_chip")
    local total_bet_chip = panel:getChildByName("total_bet_chip")
    local btn_buygold = panel:getChildByName("btn_buygold")
    local name_txt = panel:getChildByName("name_txt")
    local chip_txt = panel:getChildByName("chip_txt")

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

function UserInfoPlaneOperator:clearGameDatas(playerType,panel,stage)
   
    if  stage == 1 then
        
        --self:switchMode(panel,2)
        --self:clearBetChip(panel)
    	-- self:setGrabBankerSymbol(panel,false)
    	--self:setGrabBankerTimes(panel,0,false)

    	self:setBetTimes(panel,false)

    elseif stage == 2 or stage == nil then
        -- 准备文本
        self:setReadyStatus(panel, false)
        -- self:setGrabBankerSymbol(panel,false)
        -- self:setGrabBankerTimes(panel,0,false)
        -- 庄图标
        self:showHeadSymbol(panel,"banker",false)
        -- 掉线图标
        self:showHeadSymbol(panel,"disconnect",false)
        -- 对局结果图标
        self:showResultImg(panel, 0)
        -- 抢庄
        self:showZhuangAttitude(panel, 0)
        
        self:setBetTimes(panel, false)
        self:showGrabBankerFrame(panel,false)

    end
end

function UserInfoPlaneOperator:showPlayerInfo(playerType,panel,userInfo,showBuyGoldButton)
    
    panel:setVisible(true)
    panel.uid = userInfo["uid"]

	local photoUrl = userInfo["icon_url"]
	local nickname = userInfo["nick"]
	local coins = userInfo["coins"]

	local head = panel:getChildByName("img_head_frame")
	self:setCoin(panel, coins)
    -- self:setReadyStatus(panel, false)

    local txt_name = panel:getChildByName("txt_name")

    ----------------------------------------------------------------
    local 	headSize =  head:getSize().width
    nickname = require("hall.GameCommon"):formatNick(nickname, 4)
    txt_name:setString(nickname)

	require("hall.GameCommon"):getUserHead(photoUrl, userInfo["uid"], userInfo["sex"], head, headSize, false, nickname, false)
    -- self:getUserHeadLight(photoUrl, userInfo["uid"], userInfo["sex"], head, headSize, false,nickname,userInfo)

   	-- self:showHeadSymbol(panel,"disconnect",false)
	return head
end

function UserInfoPlaneOperator:getCoin(label)

    if  label == nil then
        return
    end

    local labelContent = label:getString()

    local numberEndPos = string.find(labelContent,"万") - 1

    local orichip = tonumber(string.sub(labelContent,numberEndPos)) * 10000

    return orichip

end

function UserInfoPlaneOperator:updateCoin(panel, value, orichip)
    dump(value,"金币的改变值")
    
    if value and value ~= 0 then
	
		local chip = panel:getChildByName("txt_score")

        --local orichip = orichip or self:getLabelCoin(chip)

        local orichip = orichip or 0
        local orichip = orichip or tonumber(chip:getString())
        dump(orichip,"------------orichip")

        local finalChip = orichip + value

        self:setCoin(panel, finalChip)
    end
    
end

function UserInfoPlaneOperator:setCoin(panel, value)
	
	local  score = panel:getChildByName("txt_score")
	if  score then
        
        local goldStr = ""
        dump(value,"-------------------value")
        value = value / 100
		-- if 	value > 10000 then
  --           local finalChipTxt = tostring(value/10000)
  --           if string.len(finalChipTxt) <= 4 then
  --               goldStr = string.format("%.1f", finalChipTxt) .. "万"
  --           else
  --               local endlength = string.find(finalChipTxt,"%.")
  --               goldStr = string.sub(finalChipTxt,1,endlength-1) .. "万"
  --           end
  --       else
  --           goldStr = tostring(value)
		-- end
        
        goldStr = tostring(value)
        score:setString(goldStr)

	end
end

function UserInfoPlaneOperator:showHeadSymbol(panel, _type, flag)

    if _type == "disconnect" then
        local img = panel:getChildByName("img_network")

        if img then
            img:setVisible(flag)
        end

    elseif  _type == "banker" then

        local img = panel:getChildByName("img_banker")

        if img then
            img:setVisible(flag)
        end

    elseif  _type == "owner" then

        local img = panel:getChildByName("img_owner")

        if img then
            img:setVisible(flag)
        end
    end
end

function UserInfoPlaneOperator:setReadyStatus(panel, flag)
    local ready = panel:getChildByName("txt_ready")
    if  ready then
        ready:setVisible(flag)
    end
    if flag==false then 
        GamePlaneOperator:showchip()
    end
end

function UserInfoPlaneOperator:setGrabBankerSymbol(panel,flag)

    -- local bet_img = panel:getChildByName("bet_img")

    -- if  bet_img then
    -- 	bet_img:setVisible(flag)
    -- end

end

function UserInfoPlaneOperator:setGrabBankerTimes(panel,times,flag)

    local times_txt = panel:getChildByName("grab_banker_times_txt")
    local img = panel:getChildByName("grab_banker_img")

    if  times then
        times_txt:setString("x"..times)
    end

    img:setVisible(flag)
    times_txt:setVisible(flag)
end

function UserInfoPlaneOperator:setBetTimes(panel,flag,times)
    local chip_img = panel:getChildByName("chip_img")
    chip_img:setVisible(flag)
    if times then
        chip_img.bet_times_txt:setString(times)
    end
end

function UserInfoPlaneOperator:setEffectFrame(playerType, panel, _type, flag)

    local effect_frame = panel:getChildByName("effects")

    if  flag == false then

        panel:stopAllActions()
        effect_frame:setVisible(false)

    elseif flag == nil then

        if  _type == 1 then
            effect_frame:loadTexture(grab_effect_img)
            effect_frame:setVisible(true)
        elseif  _type == 2 then
            panel:stopAllActions()
            effect_frame:loadTexture(grab_effect_img)
            effect_frame:setVisible(true)
            local 	grab_banker_action = cc.RepeatForever:create(
            cc.Sequence:create(
            cc.CallFunc:create(function()
                if effect_frame:isVisible()  then
                    effect_frame:setVisible(false)
                else
                    effect_frame:setVisible(true)
                end
            end),
            cc.DelayTime:create(0.25)
            )
            )
            panel:runAction(grab_banker_action)

        elseif  _type == 3 then
            effect_frame:setVisible(true)
            effect_frame:loadTexture(bet_effect_img)
        end
    elseif  flag == true then
        effect_frame:setVisible(true)
    end

end

function UserInfoPlaneOperator:getUserHeadLight(url,uid,sex,head,headSize,isCircle,nick,userInfo)

    local url_str = self:getUrlPicture(url)
    local imgFullPath = device.writablePath .. url_str
    file,fileErr = io.open(imgFullPath)
    dump(url_str,"头像图片是否打开成功")

    if  fileErr == nil then
        if isCircle then
            self:setCirleHead(head, imgFullPath, headSize, uid, sex, url, nick, userInfo)
        else
            -- local x = file:seek("end")
            -- if x > 4000000 or  x <= 0 then
            --     imgFullPath = DefaultHead_filePath
            -- end

            head:loadTexture(imgFullPath)
            head:setContentSize(cc.size(size,size))
            head:setTouchEnabled(true)
            head:addTouchEventListener(function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    require("hall.view.userInfoView.userInfoView"):showView(url, userInfo)
                end

            end)
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

            local code = request:getReheadonseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end

            -- 请求成功，显示服务端返回的内容
            local reheadonse = request:getReheadonseString()
            print(reheadonse)

            --保存下载数据到本地文件，如果不成功，重试3次。
            local times = 1
            print("savedata:"..filename)
            while (not request:saveReheadonseData(filename)) and times < 3 do
                times = times + 1
            end
            local isOvertime = (times == 3) --是否超时

            cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)

            if isCircle then
                self:setCirleHead(head, imgFullPath, headSize, uid, sex, url, nick, userInfo)
            else

                local x = file:seek("end")
                if x > 4000000 or  x <= 0 then
                    imgFullPath = DefaultHead_filePath
                end

                head:loadTexture(imgFullPath)
                head:setContentSize(cc.size(size,size))
                head:setTouchEnabled(true)
                head:addTouchEventListener(function(sender,event)

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then
                        require("hall.view.userInfoView.userInfoView"):showView(url, userInfo)
                    end

                end)
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

--检查图片格式
function UserInfoPlaneOperator:getUrlPicture(url)
    -- body
    if url == "" or url == nil then
        return ""
    end

    local strLower = string.lower(url)
    if string.find(strLower,".jpg") == nil and string.find(strLower,".png") == nil then
        return self:getUnformatPic(url)
    end
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    return strPic
end

--将头像框设置为圆形
function UserInfoPlaneOperator:setCirleHead(head, strIco, size, uid, sex, url, nick,userInfo)

    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0)

    local stencil = cc.Node:create()
    clipnode:setStencil(stencil)

    local headStnecil = diheadlay.newheadrite(Stnecil_filePath)
    headStnecil:setScale(size/headStnecil:getContentSize().width)
    stencil:addChild(headStnecil)

    local content
    file,fileErr = io.open(strIco)
    if fileErr == nil then
        local x = file:seek("end")
        if x > 0 then

            if x > 4000000 then
                content = diheadlay.newheadrite(DefaultHead_filePath)
            else
                content = diheadlay.newheadrite(strIco)
            end

        else
            content = diheadlay.newheadrite(DefaultHead_filePath)
        end
    else
        content = diheadlay.newheadrite(DefaultHead_filePath)
    end
    -- local content = diheadlay.newheadrite(strIco)
    content:setScaleX(size/content:getContentSize().width)
    content:setScaleY(size/content:getContentSize().height)
    clipnode:addChild(content)

    clipnode:setPosition(clipnode:getContentSize().width/2,clipnode:getContentSize().height/2)
    if head.addChild ~= nil then
        head:addChild(clipnode, 999)
    end

    if head.setTexture ~= nil then
        head:setTexture("")
    end

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))
    layerTouch:setTouchEnabled(true)
    layerTouch:addTouchEventListener(
    function(sender,event)
        if event == 2  then
            require("hall.view.userInfoView.userInfoView"):showView(url, userInfo)
        end
    end)
    layerTouch:setContentSize(cc.size(size,size))
    head:addChild(layerTouch)

end

function UserInfoPlaneOperator:showResultImg(panel, flag)
    -- flag：0-不显示，1-显示赢，2-显示合，3-显示输
    local img_result = panel:getChildByName("img_result")

    if flag == 0 then
        img_result:setVisible(false)
    elseif flag == 1 then
        img_result:loadTexture(img_path_win)
    elseif flag == 2 then
        img_result:loadTexture(img_path_tie)
    elseif flag == 3 then
        img_result:loadTexture(img_path_lose)
    end
end

function UserInfoPlaneOperator:showZhuangAttitude(panel, flag)
    -- flag：0-全部隐藏，1-显示抢庄，2-显示不抢庄
    local txt_get_zhuang = panel:getChildByName("txt_get_zhuang")
    local txt_no_get_zhuang = panel:getChildByName("txt_no_get_zhuang")

    if flag == 0 then
        txt_get_zhuang:setVisible(false)
        txt_no_get_zhuang:setVisible(false)
    elseif flag == 1 then
        txt_get_zhuang:setVisible(true)
        txt_no_get_zhuang:setVisible(false)
    elseif flag == 2 then
        txt_get_zhuang:setVisible(false)
        txt_no_get_zhuang:setVisible(true)
    end
end

function UserInfoPlaneOperator:getLabelCoin(label)

    if  label == nil then
        return
    end

    local labelContent = label:getString()

    local orichip
    local numberEndPos = string.find(labelContent,"万")

    if  numberEndPos then
        numberEndPos = numberEndPos - 1
        local test_str = string.sub(labelContent, 1, numberEndPos)
        --dump(test_str, "----- test_str ------")
        orichip = tonumber(test_str) * 10000
    else
        orichip = tonumber(labelContent)
    end

    return orichip

end


function UserInfoPlaneOperator:showkaipai(panel, flag)
    local img_kaipai = panel:getChildByName("img_kaipai")
    if img_kaipai then
        --img_kaipai:loadTexture(TpackageName .. "/images/cardname/第九娘娘.png")
        flag = false
        img_kaipai:setVisible(flag)
    end
end

--房主
function UserInfoPlaneOperator:showFangZhu(panel, flag)
   panel.img_master:setVisible(flag)
  
end

return UserInfoPlaneOperator