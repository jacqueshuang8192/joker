local UserInfoPlaneOperator = class('UserInfoPlaneOperator', ViewBase)

local defaultHead = TpackageName .. '/images/player_head1.png'
-- local bet_coin_img_path = TpackageName .. "/images/effect_gold_3.png"
local bet_coin_img_path = TpackageName .. '/csb/GameSceneSector/icon_2.png'

local grab_effect_img = TpackageName .. '/images/grab_effect_1.png'
local bet_effect_img = TpackageName .. '/images/bet_effect_1.png'

function UserInfoPlaneOperator:init(playerType, plane)
    plane:setVisible(false)
    -- if plane:getName() == "player_plane" then
    --     plane = plane.head_plane
    -- end
    plane.state:hide()
    plane = plane.head_plane:setLocalZOrder(5)
    self:setCoin(plane, 0)
    self:setReadyStatus(plane, false)
    self:setGrabBankerTimes(plane, 0, false)
    self:showHeadSymbol(plane, 'banker', false)
    self:showHeadSymbol(plane, 'owner', false)
    self:setBetTimes(plane, 0, false)
    self:setBetChip(plane, 0, false)
    self:setTotalBetChip(plane, 0, false)
    local chip_img = plane:getChildByName('chip_img')
    chip_img:setVisible(false)

    local effect_frame = plane:getChildByName('effect_frame')
    effect_frame:setVisible(false)
    local score_txt = self:seekChild(plane, 'score_txt')
    score_txt:setVisible(false)

    local btn_buygold = plane:getChildByName('btn_buygold')
    if btn_buygold then
        btn_buygold:addTouchEventListener(
            function(sender, event)
                if event == TOUCH_EVENT_ENDED then
                    SCENENOW['scene']:requestCharge()
                    SoundUtils:playEffect('click')
                end
            end
        )
    end
end

function UserInfoPlaneOperator:relocate(plane)
    plane:setVisible(false)
end

function UserInfoPlaneOperator:setBetChip(plane, value, flag)
end

function UserInfoPlaneOperator:setTotalBetChip(plane, value, flag)
end

function UserInfoPlaneOperator:clearBetChip(plane)
    self:setBetChip(plane, 0)
    self:setTotalBetChip(plane, 0)
end

function UserInfoPlaneOperator:showBetEffect(plane, value)
    local coin_sp = display.newSprite(coin_img_path)

    local head = plane:getChildByName('head_img')
    local targetPos = head:getPosition()
    local oriPos = cc.p(targetPos.x + math.random(-30, 30), targetPos.y + math.random(80, 120))

    coin_sp:setPosition(oriPos)
    plane:addChild(coin_sp, 100)

    -- local random = value/BASE_CHIP * 4

    local animtime = 0.2 + 0.05 * math.random(10)

    local mb = cc.MoveBy:create(animtime, cc.p(0, math.random(-80, -120)))
    -- local mb = cc.MoveTo:create(animtime,cc.p(0, 0))

    local fo = cc.FadeOut:create(0.2)
    local remove_action =
        cc.CallFunc:create(
        function()
            coin_sp:removeFromParent()
        end
    )
    -- cc.EaseElasticOut:create()
    local seq = cc.Sequence:create(mb, fo, remove_action)
    coin_sp:runAction(seq)
end

function UserInfoPlaneOperator:switchMode(plane, _type)
    local head_frame_img = plane:getChildByName('head_frame_img')
    local head = plane:getChildByName('head_img')

    local bet_chip = plane:getChildByName('bet_chip')
    local total_bet_chip = plane:getChildByName('total_bet_chip')
    local btn_buygold = plane:getChildByName('btn_buygold')
    local name_txt = plane:getChildByName('name_txt')
    local chip_txt = plane:getChildByName('chip_txt')

    if _type == 1 then
        head_frame_img:setTouchEnabled(true)
        head:setTouchEnabled(false)

        chip_txt:setVisible(false)

        if btn_buygold and isGoldGame == 0 then
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

        if btn_buygold and isGoldGame == 0 and plane.uid == USER_INFO['uid'] and false then
            -- if isiOSVerify then
            --     btn_buygold:setVisible(false)
            -- else
            --     btn_buygold:setVisible(true)
            -- end
        else
            name_txt:setVisible(true)
        end

        bet_chip:setVisible(false)
        total_bet_chip:setVisible(false)
    end
end

function UserInfoPlaneOperator:clearGameDatas(playerType, plane, stage)
    if stage == 1 then
        -- self:switchMode(plane,2)
        self:clearBetChip(plane)
        -- self:setGrabBankerSymbol(plane,false)
        self:setGrabBankerTimes(plane, 0, false)

        self:setBetTimes(plane, 0, false)
    elseif stage == 2 or stage == nil or stage == true then
        plane:stopAllActions()
        local score_txt = self:seekChild(plane, 'score_txt')
        score_txt:setVisible(false)
        local effect_frame = plane:getChildByName('effect_frame')
        effect_frame:setVisible(false)

        self:showHeadSymbol(plane, 'banker', false)
        self:setReadyStatus(plane, false)
        self:setBetTimes(plane, 0, false)
    end
end

function UserInfoPlaneOperator:showPlayerInfo(playerType, plane, userInfo)
    plane:setVisible(true)
    plane.uid = userInfo['uid']

    local seatId = nil
    if userInfo['uid'] then
        seatId = SANGONG_SEAT_TABLE[userInfo['uid']]
    end

    local photoUrl = userInfo['icon_url']
    local nickname = userInfo['nick']
    local coins = userInfo['coins'] or userInfo['gold']
    local nick_txt = plane:getChildByName('name_txt')
    local head = plane:getChildByName('head_img')
    local ready = userInfo['ready']
    self:setCoin(plane, coins)
    -----------------------显示购买金币按钮--------------------------
    if playerType == CARD_PLAYERTYPE_MY and false then --这版的不需要了
        local chip_txt = plane:getChildByName('chip_txt')
        local btn_buygold = plane:getChildByName('btn_buygold')

        if btn_buygold then
            if plane.uid == USER_INFO['uid'] and isGoldGame == 0 and isiOSVerify ~= true then
                -- btn_buygold:setVisible(true)
                nick_txt:setVisible(false)
                chip_txt:setPositionY(92)
            else
                btn_buygold:setVisible(false)
                nick_txt:setVisible(true)
                chip_txt:setPositionY(35)
            end
        end
    end
    ----------------------------------------------------------------
    if ready > 0 then
        self:setReadyStatus(plane, true)
    else
        self:setReadyStatus(plane, false)
    end
    local headSize = 118
    nickname = require('hall.GameCommon'):formatNick(nickname, 4)
    nick_txt:setString(nickname)
    -- head:loadTexture(defaultHead)   --先加载默认头像，解决头像请求超时会显示错的问题
    headSize = plane:getChildByName('head_img_bg'):getContentSize().width - 20
    local icon_url = userInfo.icon_url
    local uid = userInfo.uid
    local sex = userInfo.sex
    local size = head:getContentSize()
    local otherInfo = json.decode(userInfo.otherInfo) or {}
    local addres = otherInfo.addres
    local ip = userInfo.ip
    require('hall.GameCommon'):getUserHead(icon_url, uid, sex, head, size.width, false, nickname, false, ip, addres)

    return head
end
function UserInfoPlaneOperator:showMyPlayerInfo(plane, userInfo)
    plane:setVisible(true)
    plane.uid = userInfo['uid']
    local head = plane:getChildByName('head_img')
    userInfo['icon_url'] = userInfo['icon_url'] or DefaultHead_filePath
    local nickname = userInfo['nick']
    local coins = userInfo['coins'] or userInfo['gold']
    self:setCoin(plane, coins)
    local headWidth = 137.00
    local headHeight = 120
    local chip_txt = plane:getChildByName('chip_txt')
    -- chip_txt:setString(goldStr)
    local name_txt = plane:getChildByName('name_txt')
    local nickname = SanGongUtils:formatNick(nickname, 4)
    name_txt:setString(nickname)
    local total_bet_chip = plane:getChildByName('total_bet_chip')
    local text_pwd = plane:getChildByName('text_pwd')
    -- if USER_INFO["roomPassword"] and USER_INFO["roomPassword"] ~= "" then
    --     text_pwd:setString("密码："..USER_INFO["roomPassword"] or "")
    -- else
    --     text_pwd:setVisible(false)
    -- end
    -- require("hall.GameCommon"):setPlayerHead(userInfo, head, 100)

    local icon_url = userInfo.icon_url
    local uid = userInfo.uid
    local sex = userInfo.sex
    local otherInfo = json.decode(userInfo.otherInfo) or {}
    local addres = otherInfo.addres
    local ip = otherInfo.ip
    local size = head:getContentSize()
    require('hall.GameCommon'):getUserHead(
        icon_url,
        uid,
        sex,
        head,
        size.width,
        false,
        nickname,
        false,
        ip,
        USER_INFO.addres
    )

    return head
end
function UserInfoPlaneOperator:getLabelCoin(label)
    if label == nil then
        return
    end

    local labelContent = label:getString()

    local orichip
    local numberEndPos = string.find(labelContent, '万')

    if numberEndPos then
        numberEndPos = numberEndPos - 1
        orichip = tonumber(string.sub(labelContent, numberEndPos)) * 10000
    else
        orichip = tonumber(labelContent)
    end

    return orichip
end

function UserInfoPlaneOperator:updateCoin(plane, value, orichip)
    if value then
        local chip = plane:getChildByName('chip_txt')
        local orichip = orichip or plane.coin -- self:getLabelCoin(chip)
        local finalChip = orichip + value
        -- self:setCoin(plane,finalChip)
        local str = ''
        local score_txt = self:seekChild(plane, 'score_txt')
        score_txt:setVisible(true)
        if value < 0 then
            str = tostring(value)
            score_txt:setFntFile(TpackageName .. '/csb/player_plane/lose_num.fnt')
        else
            str = '+' .. tostring(value)
            score_txt:setFntFile(TpackageName .. '/csb/player_plane/win_num.fnt')
        end
        score_txt:setString(str)

    end
end


function UserInfoPlaneOperator:setCoin(plane, value)
    local chip_txt = plane:getChildByName('chip_txt')
    if chip_txt and value then
        plane.coin = value
        local goldStr = ''
        -- value = value / 100
        if value > 99999 then
            local finalChipTxt = tostring(value / 10000)
            if string.len(finalChipTxt) <= 4 then
                goldStr = string.format('%.1f', finalChipTxt) .. '万'
            else
                -- local endlength = string.find(finalChipTxt,"%.")
                -- goldStr = string.sub(finalChipTxt,1,endlength-1) .. "万"
                goldStr = string.format('%.2f', finalChipTxt) .. '万'
            end
        else
            goldStr = tostring(value)
        end

        chip_txt:setString(goldStr)

        if isGoldGame == 0 then
            local uid = plane.uid
            if uid and require('hall.view.userInfoView.userInfoView').upDateUserInfo then
                require('hall.view.userInfoView.userInfoView'):upDateUserInfo(uid, {['gold'] = value}, 'gold')
            end
        end
    end
end

function UserInfoPlaneOperator:showHeadSymbol(plane, _type, flag)
    if _type == 'disconnect' then
        local img = plane:getChildByName('network_img')

        if img then
            img:setVisible(flag)
        end
    elseif _type == 'banker' then
        local img = plane:getChildByName('zhuang_flag')
        if img then
            img:setVisible(flag)
        end
    elseif _type == 'owner' then
        local img = plane:getChildByName('fangzhutip_img')

        if img then
            img:setVisible(flag)
        end
    end
end

function UserInfoPlaneOperator:setReadyStatus(plane, flag)
    local img = plane:getChildByName('ready_img')

    if img then
        if flag == true then
            img:setVisible(true)
        elseif flag == 'action' then
            img:setVisible(true)
            img:setScale(4)
            img:setOpacity(40)

            local action = cc.EaseSineOut:create(cc.Spawn:create(cc.ScaleTo:create(0.3, 1), cc.FadeIn:create(0.3)))
            img:runAction(action)
        else
            img:setVisible(false)
        end
    end
end

function UserInfoPlaneOperator:setGrabBankerSymbol(plane, flag)
    -- local bet_img = plane:getChildByName("bet_img")
    -- if  bet_img then
    -- 	bet_img:setVisible(flag)
    -- end
end

function UserInfoPlaneOperator:setGrabBankerTimes(plane, times, flag)
    local times_txt = plane:getChildByName('grab_banker_times_txt')
    local img = plane:getChildByName('grab_banker_img')

    if times then
        times_txt:setString(times)
    end

    img:setVisible(flag)
    times_txt:setVisible(flag)
end

function UserInfoPlaneOperator:setBetTimes(plane, times, flag)
    local bet_times_txt = self:seekChild(plane, 'bet_times_txt')
    local chip_img = plane:getChildByName('chip_img')

    if times and flag ~= false then
        if times > 0 then
            local coinNum = times > 10 and times or 10

            SoundUtils:playEffect('coinfly_short')

            local head_pos = plane:getChildByName('head_img'):getPosition()
            local chip_img_pos = chip_img:getPosition()
            -- local coin_img = chip_img:getChildByName("coin_img"):setVisible(false)
            local distanceVector = cc.pSub(chip_img_pos, head_pos)
            local distance = math.sqrt(distanceVector.x ^ 2 + distanceVector.y ^ 2) -- cc.pLength(distanceVector)

            local moveTime = distance / 1200

            plane:performWithDelay(
                function()
                    if isGoldGame == 0 then
                        bet_times_txt:setString('x ' .. times)
                    else
                        bet_times_txt:setString(times)
                    end

                    chip_img:setVisible(true)
                    bet_times_txt:setVisible(true)
                    -- coin_img:setVisible(flag)
                end,
                moveTime + 0.05
            )

            coinNum = times > 100 and 100 or times
            local intervalTime = 0.12 / coinNum
            for i = 1, coinNum do
                local action =
                    cc.Sequence:create(
                    cc.DelayTime:create(intervalTime * i),
                    cc.EaseSineOut:create(cc.MoveTo:create(moveTime, chip_img_pos)),
                    cc.RemoveSelf:create()
                )
                -- local action = cc.Sequence:create(
                --     cc.DelayTime:create(intervalTime*i),
                --     cc.EaseSineOut:create(cc.MoveTo:create(moveTime, cc.p(0 ,0))),
                --     cc.RemoveSelf:create())
                local coin_sp = ccui.ImageView:create(bet_coin_img_path, 1)
                plane:addChild(coin_sp)
                coin_sp:setPosition(head_pos)
                coin_sp:runAction(action)
            end
        end
    else
        chip_img:setVisible(false)
        bet_times_txt:setVisible(false)
    end
end

function UserInfoPlaneOperator:setEffectFrame(playerType, plane, _type, flag)
    -- if true then return end
    --_type   1为抢庄，2为抢庄特效，3为加倍
    local effect_frame = plane:getChildByName('effect_frame')

    if flag == false then
        plane:stopAllActions()
        effect_frame:setVisible(false)
    elseif flag == nil then
        if _type == 1 then
            -- effect_frame:setVisible(true)
        elseif _type == 2 then
            -- effect_frame:setVisible(true)
            -- local 	grab_banker_action = cc.RepeatForever:create(
            -- 		cc.Sequence:create(
            -- 			cc.CallFunc:create(function()
            --                 local frame_1_isShow = effect_frame:isVisible()
            -- 				effect_frame:setVisible(frame_1_isShow)
            -- 			end),
            -- 		    cc.DelayTime:create(0.15)
            -- 		)
            -- 	)
            -- plane:runAction(grab_banker_action)
            plane:stopAllActions()
        elseif _type == 3 then
        -- effect_frame:setVisible(true)
        end
    elseif flag == true then
        effect_frame:setVisible(true)
    end
end

function UserInfoPlaneOperator:getUserHeadLight(url, uid, sex, head, headSize, isCircle, nick, userInfo)
    local url_str = self:getUrlPicture(url)
    local imgFullPath = device.writablePath .. url_str
    file, fileErr = io.open(imgFullPath)

    if fileErr == nil then
        if isCircle then
            self:setCirleHead(head, imgFullPath, headSize, uid, sex, url, nick, userInfo)
        else
            -- local x = file:seek("end")
            -- if x > 4000000 or  x <= 0 then
            --     imgFullPath = DefaultHead_filePath
            -- end

            head:loadTexture(imgFullPath)
            head:setContentSize(cc.size(size, size))
            head:setTouchEnabled(true)
            head:addTouchEventListener(
                function(sender, event)
                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then
                        require('hall.view.userInfoView.userInfoView'):showView(url, userInfo)
                    end
                end
            )
        end
    else
        local function onRequestFinished(event, filename)
            -- body
            local ok = (event.name == 'completed')

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


            --保存下载数据到本地文件，如果不成功，重试3次。
            local times = 1

            while (not request:saveReheadonseData(filename)) and times < 3 do
                times = times + 1
            end
            local isOvertime = (times == 3) --是否超时

            cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)

            if isCircle then
                self:setCirleHead(head, imgFullPath, headSize, uid, sex, url, nick, userInfo)
            else
                local x = file:seek('end')
                if x > 4000000 or x <= 0 then
                    imgFullPath = DefaultHead_filePath
                end

                head:loadTexture(imgFullPath)
                head:setContentSize(cc.size(size, size))
                head:setTouchEnabled(true)
                head:addTouchEventListener(
                    function(sender, event)
                        --触摸结束
                        if event == TOUCH_EVENT_ENDED then
                            require('hall.view.userInfoView.userInfoView'):showView(url, userInfo)
                        end
                    end
                )
            end
        end

        local request =
            network.createHTTPRequest(
            function(event)
                -- body
                if event.name == 'completed' then
                    onRequestFinished(event, imgFullPath)
                end
            end,
            url,
            'GET'
        )

        request:start()
    end
end

--获取非格式化图片名称
function UserInfoPlaneOperator:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl, '/')
    if nPos == nil then
        return nil
    end
    strUrl = string.sub(strUrl, nPos + 1, string.len(strUrl))
    nPos = string.find(strUrl, '/')
    if nPos == nil then
        return nil
    end
    local strPic = string.sub(strUrl, 1, nPos - 1)
    strPic = string.reverse(strPic)
    return strPic .. '.jpg'
end

--检查图片格式
function UserInfoPlaneOperator:getUrlPicture(url)
    -- body
    if url == '' or url == nil then
        return ''
    end

    local strLower = string.lower(url)
    if string.find(strLower, '.jpg') == nil and string.find(strLower, '.png') == nil then
        return self:getUnformatPic(url)
    end
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl, '/')
    local strPic = string.sub(strUrl, 1, nPos - 1)
    strPic = string.reverse(strPic)
    return strPic
end

--将头像框设置为圆形
function UserInfoPlaneOperator:setCirleHead(head, strIco, size, uid, sex, url, nick, userInfo)
    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0)

    local stencil = cc.Node:create()
    clipnode:setStencil(stencil)

    local headStnecil = diheadlay.newheadrite(Stnecil_filePath)
    headStnecil:setScale(size / headStnecil:getContentSize().width)
    stencil:addChild(headStnecil)

    local content
    file, fileErr = io.open(strIco)
    if fileErr == nil then
        local x = file:seek('end')
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
    content:setScaleX(size / content:getContentSize().width)
    content:setScaleY(size / content:getContentSize().height)
    clipnode:addChild(content)

    clipnode:setPosition(clipnode:getContentSize().width / 2, clipnode:getContentSize().height / 2)
    if head.addChild ~= nil then
        head:addChild(clipnode, 999)
    end

    if head.setTexture ~= nil then
        head:setTexture('')
    end

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5, 0.5))
    layerTouch:setTouchEnabled(true)
    layerTouch:addTouchEventListener(
        function(sender, event)
            if event == 2 then
                require('hall.view.userInfoView.userInfoView'):showView(url, userInfo)
            end
        end
    )
    layerTouch:setContentSize(cc.size(size, size))
    head:addChild(layerTouch)
end

return UserInfoPlaneOperator
