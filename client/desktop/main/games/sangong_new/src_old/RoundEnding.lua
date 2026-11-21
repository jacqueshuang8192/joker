local RoundEnding = class('RoundEnding')

function RoundEnding:init()
    --if ROUND_ENDING == nil or tolua.isnull(ROUND_ENDING) then
    if TOTAL_PLAYERNUM == 12 then
        ROUND_ENDING = cc.CSLoader:createNode('sangong/csb/EndingScene12.csb')
    else
        ROUND_ENDING = cc.CSLoader:createNode('sangong/csb/EndingScene.csb')
    end
    SCENENOW['scene']:addChild(ROUND_ENDING, 99999)
    --end
    ROUND_ENDING:setScale(SCREEN_WIDTH / DESIGN_SCREEN_WIDTH)
    local function touchButtonEvent(sender, event)
        --触摸开始
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
            if sender == self.btn_back then
                self:removeView()
            elseif sender == self.btn_share then
                if device.platform == 'android' then
                    require('hall.common.ShareLayer'):showShareLayer('分享结果', '', 'screen', '')
                elseif device.platform ~= 'windows' then
                    require('hall.common.ShareLayer'):shareGroupResultForIOS()
                end
            elseif sender == self.btn_exit then
                --SanGongSendHandle:quitRoom()
                self:removeView()
            end
        end
    end
    self.waitStopTime = ROUND_ENDING:getChildByName('waitStopTime')
    self.time = ROUND_ENDING:getChildByName('time')
    self.item = ROUND_ENDING:getChildByName('item')
    local SG_ENDING_PANEL = ROUND_ENDING:getChildByName('ending_panel')

    local SG_NOTIFY_PANEL = ROUND_ENDING:getChildByName('notify_panel')
    SG_ENDING_PANEL:setVisible(false)
    SG_NOTIFY_PANEL:setVisible(false)

    self.btn_exit = SG_ENDING_PANEL:getChildByName('btn_exit')
    self.btn_back = SG_ENDING_PANEL:getChildByName('btn_back')
    self.btn_share = SG_ENDING_PANEL:getChildByName('btn_share')
    self.btn_back:addTouchEventListener(touchButtonEvent)
    self.btn_exit:addTouchEventListener(touchButtonEvent)
    self.btn_share:addTouchEventListener(touchButtonEvent)
    self:initData()
    self:initDataNotify()
    ROUND_ENDING:setVisible(false)
end
function RoundEnding:initData()
    if ROUND_ENDING == nil or tolua.isnull(ROUND_ENDING) then
        self:init()
    end
    local SG_ENDING_PANEL = ROUND_ENDING:getChildByName('ending_panel')
    for i = 1, TOTAL_PLAYERNUM do
        local panel = SG_ENDING_PANEL:getChildByName('panel_' .. i)
        panel:getChildByName('content_lv'):removeAllItems()
    end
    --self:startTimer(5)
end
function RoundEnding:showItems(pack)
    --SG_NOTIFY_PANEL:setVisible(false)
    if SANGONG_SEAT_TABLE[pack.uid] == nil then
        return
    end
    if ROUND_ENDING == nil or tolua.isnull(ROUND_ENDING) then
        self:init()
    end
    local SG_ENDING_PANEL = ROUND_ENDING:getChildByName('ending_panel')
    local playerType = SANGONG_SEAT_TABLE[pack.uid] + 1
    local panel = SG_ENDING_PANEL:getChildByName('panel_' .. playerType)
    local time = SG_ENDING_PANEL:getChildByName('time')
    local inviteCode = SG_ENDING_PANEL:getChildByName('inviteCode')
    inviteCode:setString('房号：' .. USER_INFO['invote_code'])
    time:setString('结束时间：' .. os.date('%Y-%m-%d-%H:%M'))
    for i, v in pairs(pack.userinfo) do
        local item = self.item:clone()
        local nick = item:getChildByName('nick')
        local no = item:getChildByName('no')
        local score = item:getChildByName('score')
        local head = display.newSprite('sangong/images/over/kong.png')
        head:addTo(item)
        head:setPosition(125.58, 27.80)
        local userinfo = {
            icon_url = v.portrait
        }
        no:setString(i)
        nick:setString(SanGongUtils:formatNick(v.nickName or '', 4))
        local head_info = {}
        head_info['icon_url'] = v.portrait or DefaultHead_filePath
        head_info['uid'] = v.uid or 0
        head_info['sex'] = v['sex'] or 1
        head_info['sp'] = head
        head_info['size'] = 46
        head_info['touchable'] = 0
        head_info['use_sharp'] = 1
        require('hall.GameCommon'):setPlayerHead(head_info, head, 46)
        local chip = SanGongUtils:goldMath(v.chips)
        if chip >= 0 then
            score:setColor(cc.c3b(249, 3, 5))
        else
            score:setColor(cc.c3b(94, 234, 107))
        end
        score:setString(chip)
        panel:getChildByName('content_lv'):pushBackCustomItem(item)
    end
end
function RoundEnding:removeView()
    ROUND_ENDING:setVisible(false)
    self:initData()
    --GAME_IS_ENDING = 0
    --self.time:stopAllActions()
end

--设置倒计时时间显示
function RoundEnding:startTimer(time)
    self.waitStopTime:stopAllActions()

    if time <= 0 then
        return
    end
    self.waitStopTime:setVisible(true)
    local timer_value = '' .. time
    local refreshTime = 1

    self.waitStopTime:setString(timer_value .. 's')
    local showTimerAc =
        cc.CallFunc:create(
        function()
            self.waitStopTime:setString(timer_value .. 's')
            timer_value = timer_value - refreshTime
            if timer_value > 0 then
            elseif timer_value == 0 then
                self:removeView()
            end
        end
    )

    local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime), showTimerAc)
    self.waitStopTime:runAction(cc.RepeatForever:create(seqAc))
end
function RoundEnding:initDataNotify()
    if tolua.isnull(ROUND_ENDING) then
        self:init()
    end
    local SG_NOTIFY_PANEL = ROUND_ENDING:getChildByName('notify_panel')
    local panel = SG_NOTIFY_PANEL:getChildByName('panel')
    local head = panel:getChildByName('head')
    local nick = panel:getChildByName('nick')
    nick:setString(SanGongUtils:formatNick(USER_INFO['nick'] or '', 4))
    local head_info = {}
    head_info['icon_url'] = USER_INFO['icon_url'] or DefaultHead_filePath
    head_info['uid'] = USER_INFO['uid']
    head_info['sex'] = USER_INFO['sex']
    head_info['sp'] = head
    head_info['size'] = 60
    head_info['touchable'] = 0
    head_info['use_sharp'] = 1
    require('hall.GameCommon'):setPlayerHead(head_info, head, 60)
end
function RoundEnding:showNotify(pack)
    if tolua.isnull(ROUND_ENDING) then
        self:init()
    end
    local SG_ENDING_PANEL = ROUND_ENDING:getChildByName('ending_panel')
    local SG_NOTIFY_PANEL = ROUND_ENDING:getChildByName('notify_panel')
    local winColor = cc.c4b(164, 18, 24, 255)
    local loseColor = cc.c4b(36, 171, 29, 255)
    SG_ENDING_PANEL:setVisible(false)
    SG_NOTIFY_PANEL:setVisible(true)
    local action1 = cc.FadeIn:create(0.2)
    local actionBy = cc.ScaleBy:create(0.2, 1.0, 1.0)
    local actionBy2 = cc.ScaleBy:create(0.2, 1.3, 1.3)
    local sq = cc.Sequence:create(action1, actionBy2, actionBy)
    local panel = SG_NOTIFY_PANEL:getChildByName('panel')
    panel:runAction(sq)
    --SCHEDULER.performWithDelayGlobal(function ()
    --	panel:setScale(1.2)
    --end, 3)

    local text_title = panel:getChildByName('text_title')
    local score = panel:getChildByName('score')
    local chip = SanGongUtils:goldMath(pack.score)

    if chip >= 0 then
        text_title:loadTexture('sangong/images/over/win.png')
        score:setTextColor(winColor)
    else
        text_title:loadTexture('sangong/images/over/give.png')
        score:setTextColor(loseColor)
    end
    score:setString(chip)
    if ROUND_ENDING then
        ROUND_ENDING:setVisible(true)
    end
end

function RoundEnding:showRoundEnding()
    if tolua.isnull(ROUND_ENDING) then
        self:init()
    end

    local SG_ENDING_PANEL = ROUND_ENDING:getChildByName('ending_panel')
    local SG_NOTIFY_PANEL = ROUND_ENDING:getChildByName('notify_panel')
    local panel = SG_NOTIFY_PANEL:getChildByName('panel')
    panel:setScale(1.2)
    SG_ENDING_PANEL:setVisible(true)
    SG_NOTIFY_PANEL:setVisible(false)
    ROUND_ENDING:setVisible(true)
end
return RoundEnding
