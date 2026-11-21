local ControlPlaneOperator = class('ControlPlaneOperator', ViewBase)
local LayerShuffling = require(TpackageName .. '.LayerShuffling')

function ControlPlaneOperator:init(plane)
    --查看总结算按钮
    self.btn_check_group_result = plane:getChildByName('btn_check_group_result')
    self.btn_check_group_result:setVisible(false)

    self.btn_return_to_hall = plane:getChildByName('btn_return_to_hall')
    self.guanZhan_img = plane:getChildByName('guanZhan_img')

    if self.btn_return_to_hall then
        self.btn_return_to_hall:setVisible(false)
    end

    self.btn_sit_down = plane:getChildByName('btn_sit_down')
    self.btn_sit_down:setVisible(false)

    self.ready_plane = plane:getChildByName('ready_plane')
    self.ready_plane:setVisible(false)

    self.btn_stand_up = self.ready_plane:getChildByName('btn_stand_up')
    -------------------
    self.btn_ready = self.ready_plane:getChildByName('btn_ready')
    local scene = plane:getParent():getParent()
    self.btn_start = scene.hall_plane.btn_start
    -- self.btn_start = plane:getChildByName("btn_start")
    self.btn_start:setVisible(false)
    local planeWidth = plane:getContentSize().width
    self.btn_start:setPositionX(planeWidth / 2)

    ---------------抢庄系列
    self.grab_banker_plane = plane:getChildByName('grab_banker_plane')
    self.grab_banker_plane:setVisible(false)

    self.btn_grab_banker_button = plane:getChildByName('btn_grab_banker_button')

    -----------加倍
    self.bet_plane = plane:getChildByName('bet_plane')
    self.btn_bet = plane:getChildByName('btn_bet')
    -----------出牌
    self.out_card_plane = plane:getChildByName('out_card_plane')
    self.out_card_plane:setVisible(false)

    self.outCardPlaneMiddlePositionX = self.out_card_plane:getContentSize().width / 2

    --搓牌
    self.btn_cuopai = self.out_card_plane:getChildByName('btn_cuopai')

    --翻牌（出牌）
    self.btn_fanpai = self.out_card_plane:getChildByName('btn_fanpai')
    self.btn_fanpai_oriPositionX = self.btn_fanpai:getPositionX()

    self.btn_outcard = self.out_card_plane:getChildByName('btn_outcard')
    --提示
    self.btn_tip = self.out_card_plane:getChildByName('btn_tip')
    self.btn_tip:setVisible(false)

    --斗公牛的节点
    self.douGongniu_plane = g_mainScene._scene:getChildByName('douGongniu_plane')
    self.douGongniu_plane:setVisible(true)

    self.dgn_betNode = self.douGongniu_plane:getChildByName('betNode')
    self.dgn_guodiNode = self.douGongniu_plane:getChildByName('guodiNode')
    self.dgn_bankOptNode = self.douGongniu_plane:getChildByName('bankOptNode')
    self.dgn_readyNode = self.douGongniu_plane:getChildByName('readyNode')
    self.dgn_clockBg = self.dgn_guodiNode:getChildByName('clockBg')
    self.dgn_betNode:setVisible(false)
    self.dgn_guodiNode:setVisible(false)
    self.dgn_bankOptNode:setVisible(false)
    self.dgn_readyNode:setVisible(false)
    -- if g_mainScene.gameConfigTable.gameType == 5 then
    self:bindDgnBtn()
    -- end

    local controlButtonsFunc = function(sender, event)
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
            SoundUtils:playEffect('click')

            if sender == self.btn_tip then
                self.btn_tip:setTouchEnabled(false)
                GamePlaneOperator:countFanAndShow()
            elseif sender == self.btn_fanpai then
                self:showControlButtons(5)
                GamePlaneOperator:turnCards()
                NiuNiuSendHandle:sendMycards({0, 0, 0})
            elseif sender == self.btn_outcard then
                GamePlaneOperator:hideCardNumCountEffect()
                local Mychoice = {0, 0, 0}
                NiuNiuSendHandle:sendMycards(Mychoice)
            elseif sender == self.btn_cuopai then
                self:showControlButtons(5)
                GamePlaneOperator:showCuoPai(_, true)
            elseif sender == self.btn_start then
                NiuNiuSendHandle:StartGame()
                self.btn_start:setVisible(false)
            elseif sender == self.btn_stand_up then
                NiuNiuSendHandle:standUp()
            elseif sender == self.btn_ready then
                -- self.ready_plane:setVisible(false)
                NiuNiuSendHandle:readyNow(1)
            elseif sender == self.btn_sit_down then
                local seat_id = -1
                NiuNiuSendHandle:sitDown(seat_id)
            elseif sender == self.btn_return_to_hall then
                require(TpackageName .. '.NiuNiuUtils'):returnToHall()
            elseif sender == self.btn_check_group_result then
                local GameResult = NIUNIU_SCENE:getChildByName('gameresultScene')
                if GameResult then
                    GameResult:setVisible(true)
                end
            end
        end
    end

    self.btn_tip:addTouchEventListener(controlButtonsFunc)
    self.btn_fanpai:addTouchEventListener(controlButtonsFunc)
    self.btn_cuopai:addTouchEventListener(controlButtonsFunc)
    self.btn_start:addTouchEventListener(controlButtonsFunc)
    self.btn_stand_up:addTouchEventListener(controlButtonsFunc)
    -- self.btn_ready:addTouchEventListener(controlButtonsFunc)
    self.btn_sit_down:addTouchEventListener(controlButtonsFunc)
    self.btn_check_group_result:addTouchEventListener(controlButtonsFunc)
    self.btn_outcard:addTouchEventListener(controlButtonsFunc)

    if self.btn_return_to_hall then
        self.btn_return_to_hall:addTouchEventListener(controlButtonsFunc)
    end

    self.waiwei_choose_plane = plane:getChildByName('waiwei_choose_plane')
    self.waiwei_choose_plane:setVisible(false)

    -- for i = 1,4 do
    --     local bet_chip_bt =  self.waiwei_choose_plane:getChildByName("bet_chip_" .. i)

    --     if  i == BETCOUNT then
    --         bet_chip_bt:setColor(cc.c3b(255,255,255))
    --     else
    --         bet_chip_bt:setColor(cc.c3b(120,120,120))
    --     end

    --     local bet_chip_txt = self.waiwei_choose_plane:getChildByName("bet_chip_txt_" .. i)
    --     local touchFunc = function(sender,event)

    --         --触摸结束（检查当前组局状态）
    --         if  event == TOUCH_EVENT_ENDED then

    --             for i = 1,4 do
    --                 local bet_chip_bt =  self.waiwei_choose_plane:getChildByName("bet_chip_" .. i)
    --                 bet_chip_bt:setColor(cc.c3b(120,120,120))
    --             end

    --             bet_chip_bt:setColor(cc.c3b(255,255,255))

    --             dump(i,"touchFunc")
    --             BETCOUNT = i
    --         end

    --     end

    --     bet_chip_txt:addTouchEventListener(touchFunc)
    --     bet_chip_bt:addTouchEventListener(touchFunc)

    -- end

    self:initEvent()
    self:setGuanZhanVisible(false)
end

function ControlPlaneOperator:initEvent()
    self.btn_ready:onTouch(handler(self, self.onClickReady))
end

function ControlPlaneOperator:onClickReady(event)
    if event.name == 'ended' then
        NiuNiuSendHandle:readyNow(1)
    end
end

function ControlPlaneOperator:bindDgnBtn()
    self.btnBetLeft = self.dgn_betNode:getChildByName('btnBetLeft')
    self.btnBetMid = self.dgn_betNode:getChildByName('btnBetMid')
    self.btnBetRight = self.dgn_betNode:getChildByName('btnBetRight')
    self.btnBetShot = self.dgn_betNode:getChildByName('btnBetShot')
    self.btnDownBank = self.dgn_bankOptNode:getChildByName('btnDownBank')
    self.btnNotUpBank = self.dgn_bankOptNode:getChildByName('btnNotUpBank')
    self.btnUpBank = self.dgn_bankOptNode:getChildByName('btnUpBank')
    self.btnDownBankOther = self.dgn_readyNode:getChildByName('btnDownBankOther')
    self.btnContinue = self.dgn_readyNode:getChildByName('btnContinue')

    self.btnBetLeft:addTouchEventListener(handler(self, self.onUserBetScore))
    self.btnBetMid:addTouchEventListener(handler(self, self.onUserBetScore))
    self.btnBetRight:addTouchEventListener(handler(self, self.onUserBetScore))
    self.btnBetShot:addTouchEventListener(handler(self, self.onUserBetScore))

    self.btnDownBank:addTouchEventListener(handler(self, self.onUserDownBank))
    self.btnDownBankOther:addTouchEventListener(handler(self, self.onUserDownBank))

    self.btnNotUpBank:addTouchEventListener(handler(self, self.onUserForUpBank))
    self.btnUpBank:addTouchEventListener(handler(self, self.onUserForUpBank))

    self.btnContinue:addTouchEventListener(handler(self, self.onUserReady))
    local function sliderChanged(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local amount = sender:getPercent()
            g_mainScene.sliderScore =
                math.floor((g_mainScene.dgnShotScore - g_mainScene.minBetScore) * (amount / 100)) +
                g_mainScene.minBetScore
            self.dgn_sliderScore:setString(g_mainScene.sliderScore)
        end
    end
    self.dgn_sliderScore = self.dgn_betNode:getChildByName('sliderScore')
    self.dgn_betSlider = self.dgn_betNode:getChildByName('betSlider')
    self.dgn_betSlider:addEventListener(sliderChanged)
end

function ControlPlaneOperator:onUserBetScore(sender, event)
    if event == TOUCH_EVENT_ENDED then
        local name = sender:getName()
        local score = 1
        if name == 'btnBetLeft' then
            score = g_mainScene.minBetScore
        elseif name == 'btnBetMid' then
            score = g_mainScene.midBetScore
        elseif name == 'btnBetRight' then
            score = g_mainScene.sliderScore
        elseif name == 'btnBetShot' then
            score = g_mainScene.dgnShotScore
        end

        NiuNiuSendHandle:addBase(score)
    end
end

function ControlPlaneOperator:onUserDownBank(sender, event)
    if event == TOUCH_EVENT_ENDED then
        NiuNiuSendHandle:sendUserDownBankOpt(1)
    end
end

function ControlPlaneOperator:onUserForUpBank(sender, event)
    if event == TOUCH_EVENT_ENDED then
        local name = sender:getName()
        local opt = 1
        if name == 'btnNotUpBank' then
            opt = 2
        end

        NiuNiuSendHandle:sendUserUpBankOpt(opt)
    end
end

function ControlPlaneOperator:onUserReady(sender, event)
    if event == TOUCH_EVENT_ENDED then
        NiuNiuSendHandle:readyNow(1)
    end
end

function ControlPlaneOperator:clearGameDatas(stage)
    if stage == 1 then
        self:showWaiWeiButton(false)
    elseif stage == 2 or stage == nil then
        self:showControlButtons(1, false)
    end
end

function ControlPlaneOperator:RemaidStartGame(flag)
    self.btn_start:setVisible(flag)
end

function ControlPlaneOperator:showWaiWeiButton(flag)
    self.waiwei_choose_plane:setVisible(flag)

    if flag == true then
        for i = 1, 4 do
            local bet_chip_txt = self.waiwei_choose_plane:getChildByName('bet_chip_txt_' .. i)
            local bet_chip_bt = self.waiwei_choose_plane:getChildByName('bet_chip_' .. i)

            if i <= #WAIWEI_BET_CHIPS then
                bet_chip_txt:setString(WAIWEI_BET_CHIPS[i])
            else
                bet_chip_bt:setTouchEnabled(false)
                bet_chip_txt:setTouchEnabled(false)
                bet_chip_txt:setString('???')
            end
        end
    end
end

function ControlPlaneOperator:updateWaiWeiButton()
    for i = 1, 4 do
        local bet_chip_bt = self.waiwei_choose_plane:getChildByName('bet_chip_' .. i)

        if i == BETCOUNT then
            bet_chip_bt:setColor(cc.c3b(255, 255, 255))
        else
            bet_chip_bt:setColor(cc.c3b(120, 120, 120))
        end
    end
end

function ControlPlaneOperator:showCheckResultButton(flag)
    if g_isWatch ~= 1 then
        flag = false
    end
    self.btn_check_group_result:setVisible(flag)

    if self.btn_return_to_hall then
        self.btn_return_to_hall:setVisible(flag)
    end
    if flag == true then
        LayerShuffling:removeScene()
        self.ready_plane:setVisible(false)
    end
    self:showControlButtons(1, false)
end

function ControlPlaneOperator:loadBetButtons(base, canChooseBases, tuiZhuBase)
    local canChooseBasesExist = {}
    if canChooseBases then
        for i, times in pairs(canChooseBases) do
            canChooseBasesExist[times] = true
        end
    else
        for i, times in pairs(base) do
            canChooseBasesExist[times] = true
        end
    end
    --self.bet_plane:setContentSize(cc.size(300,200))
    self.bet_plane:setScale(0.9)
    self.bet_plane:removeAllChildren()
    local bt_num = table.nums(base)

    local middleIndex = (bt_num + 1) / 2

    local planeMiddlePositionX = self.bet_plane:getContentSize().width / 2
    local planeMiddlePositionY = self.btn_bet:getContentSize().height / 2

    local buttonInterval = 300

    if bt_num > 0 then
        for i = 1, bt_num do
            local tempScore = tonumber(base[i]) or 0
            if tempScore < 1 then
                break
            end
            local btn_bet = self.btn_bet:clone()
            --btn_bet:setScale(0.8)
            btn_bet:setVisible(true)
            btn_bet:setPosition(planeMiddlePositionX + buttonInterval * (i - middleIndex), planeMiddlePositionY)
            local bet_times_txt = btn_bet:getChildByName('bet_times_txt')
            -- local img = btn_bet:getChildByName("img")
            -- local effect_img = btn_bet:getChildByName("effect_img")
            --       effect_img:setVisible(false)
            tempScore = tempScore
            bet_times_txt:setString(tostring(tempScore) .. '分')

            -- local path = string.format( "%s/csb/GameSceneSector/btn_%d.png", TpackageName, tempScore)
            -- dump(path)
            -- btn_bet:loadTextures(path, "", "", 1)
            self.bet_plane:addChild(btn_bet)
            self.bet_plane:setLocalZOrder(9999)
            if canChooseBasesExist[base[i]] then
                btn_bet:addTouchEventListener(
                    function(sender, event)
                        if event == TOUCH_EVENT_BEGAN then
                            sender:setScale(0.8)
                        end

                        --触摸取消
                        if event == TOUCH_EVENT_CANCELED then
                            sender:setScale(1.0)
                        end

                        --触摸结束
                        if event == TOUCH_EVENT_ENDED then
                            sender:setScale(1.0)

                            NiuNiuSendHandle:addBase(base[i])

                            -- GamePlaneOperator:setBetTimes(CARD_PLAYERTYPE_MY,base[i],true)
                            self.bet_plane:setVisible(false)
                            self.bet_plane:removeAllChildren()
                        end
                    end
                )
            else
                btn_bet:setBright(false) --setColor(cc.c3b(140,140,140))
            end
        end
    end

end

function ControlPlaneOperator:loadGrabBankerButtons(base, canChooseBases, canGrabDealer)
    local canChooseBasesExist = {}
    if canChooseBases then
        for i, times in pairs(canChooseBases) do
            canChooseBasesExist[times] = true
        end
    else
        for i, times in pairs(base) do
            canChooseBasesExist[times] = true
        end
    end

    self.grab_banker_plane:removeAllChildren()
    local bt_num = table.nums(base)

    local middleIndex = (bt_num + 1) / 2

    local planeMiddlePositionX = self.grab_banker_plane:getContentSize().width / 2
    -- local planeMiddlePositionY = self.grab_banker_plane:getContentSize().height/2
    local planeMiddlePositionY = self.btn_grab_banker_button:getContentSize().height / 2
    local buttonInterval = 230

    local effect_imgs = {}

    -- if bt_num == 2 then

    --     buttonInterval = 300

    --     local btn_buqiang = self.btn_buqiang:clone()
    --     btn_buqiang:setPosition(cc.p(planeMiddlePositionX + buttonInterval*(1-middleIndex),planeMiddlePositionY))
    --     self.grab_banker_plane:addChild(btn_buqiang)

    --     local btn_qiang = self.btn_qiang:clone()
    --     btn_qiang:  setPosition(cc.p(planeMiddlePositionX + buttonInterval*(2-middleIndex),planeMiddlePositionY))
    --     self.grab_banker_plane:addChild(btn_qiang)

    --     if canChooseBasesExist[1] then
    --         btn_qiang:setTouchEnabled(true)
    --     else
    --         btn_qiang:setTouchEnabled(false)
    --         btn_qiang:setBright(false)
    --     end

    for i = 1, bt_num do
        if base[i] == 0 then
            local btn_grab_banker_button = self.btn_grab_banker_button:clone():setVisible(true)

            local bet_times_txt = btn_grab_banker_button:getChildByName('bet_times_txt')
            -- bet_times_txt:setString("不抢")
            local path = string.format('%s/csb/GameSceneSector/btn_10.png', TpackageName)
            btn_grab_banker_button:loadTextures(path, '', '')
            bet_times_txt:setVisible(false)
            btn_grab_banker_button:setPosition(
                planeMiddlePositionX + buttonInterval * (i - middleIndex),
                planeMiddlePositionY
            )

            self.grab_banker_plane:addChild(btn_grab_banker_button)
            self.grab_banker_plane:setScale(0.9)
            btn_grab_banker_button:addTouchEventListener(
                function(sender, event)
                    if event == TOUCH_EVENT_BEGAN then
                        sender:setScale(0.8)
                    end

                    if event == TOUCH_EVENT_CANCELED then
                        sender:setScale(1.0)
                    end

                    if event == TOUCH_EVENT_ENDED then
                        sender:setScale(1.0)

                        SoundUtils:playEffect('click')
                        NiuNiuSendHandle:qiang(base[i])

                        self.grab_banker_plane:setVisible(false)
                    end
                end
            )
        else
            local btn_grab_banker_button = self.btn_bet:clone():setVisible(true)

            btn_grab_banker_button:setPosition(
                planeMiddlePositionX + buttonInterval * (i - middleIndex),
                planeMiddlePositionY
            )

            --抢庄按钮
            if canGrabDealer == 0 then
                btn_grab_banker_button:setBright(false)
                btn_grab_banker_button:setTouchEnabled(false)
            end

            self.grab_banker_plane:addChild(btn_grab_banker_button)
            self.grab_banker_plane:setScale(0.9)
            local bet_times_txt = self:seekChild(btn_grab_banker_button, 'bet_times_txt')
            local effect_img = btn_grab_banker_button:getChildByName('effect_img'):setVisible(false)
            -- table.insert(effect_imgs,effect_img)
            if bt_num > 2 then
                bet_times_txt:setVisible(true)
                bet_times_txt:setString(tostring(base[i]) .. '倍')
            else
                -- bet_times_txt:setString("抢庄")
                local path = string.format('%s/csb/GameSceneSector/btn_7.png', TpackageName)
                btn_grab_banker_button:loadTextures(path, path, '')
                bet_times_txt:setVisible(false)
            end

            if canChooseBasesExist[base[i]] then
                btn_grab_banker_button:addTouchEventListener(
                    function(sender, event)
                        if event == TOUCH_EVENT_BEGAN then
                            sender:setScale(0.8)
                        end

                        if event == TOUCH_EVENT_CANCELED then
                            sender:setScale(1.0)
                        end

                        if event == TOUCH_EVENT_ENDED then
                            sender:setScale(1.0)

                            SoundUtils:playEffect('click')
                            NiuNiuSendHandle:qiang(base[i])

                            -- for _,effect_img in pairs(effect_imgs) do
                            --     if not tolua.isnull(effect_img) then
                            --        effect_img:setVisible(false)
                            --     end
                            -- end

                            -- effect_img:setVisible(true)

                            self.grab_banker_plane:setVisible(false)

                            GamePlaneOperator:setGrabBankerTimes(CARD_PLAYERTYPE_MY, base[i], true)
                        end
                    end
                )
            else
                btn_grab_banker_button:setBright(false)
            end
        end
    end
end

function ControlPlaneOperator:showSitDownButton(flag)

    if isGoldGame == 0 then
        if flag == true and GAME_STATE == GAME_STATUS_STOP then --游戏停止状态下才能坐下
            self.btn_sit_down:setVisible(true)
            self.btn_sit_down:setPositionX(self.btn_sit_down:getParent():getContentSize().width / 2)
        else
            self.btn_sit_down:setVisible(false)
        end
    end
end

function ControlPlaneOperator:setGuanZhanVisible(flag)
    self.guanZhan_img:setVisible(flag)
end

--准备，（抢庄）（加倍）（摊牌，提示，搓牌）  游戏操作按钮
function ControlPlaneOperator:showControlButtons(stage, flag)
    if g_isWatch == 0 then
        flag = false
    end

    if flag == false then
        self.ready_plane:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        self.out_card_plane:setVisible(false)
        LayerShuffling:removeScene()
        return
    end

    if stage == 1 then --准备阶段
        if isGoldGame == 1 or isGoldGame == 2 then
            self.btn_stand_up:setVisible(false)
            self.btn_ready:setPositionX(self.ready_plane:getContentSize().width / 2)
        end
        self.ready_plane:setVisible(true)

        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        self.out_card_plane:setVisible(false)
    elseif stage == 2 then --抢庄阶段
        self.ready_plane:setVisible(false)
        self.grab_banker_plane:setVisible(true)
        self.bet_plane:setVisible(false)
        self.out_card_plane:setVisible(false)
    elseif stage == 3 then --加注阶段
        self.ready_plane:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(true)
        self.out_card_plane:setVisible(false)
    elseif stage == 4 then
        -- self.btn_fanpai:setPositionX(self.btn_fanpai_oriPositionX)
        self.ready_plane:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        self.out_card_plane:setVisible(true)
        -- self.btn_tip:setVisible(true)
        print("showControlButtons ------------- ", GAME_CONFIG['允许搓牌'])
        dump(g_mainScene.gameConfigTable, "g_mainScene.gameConfigTable == ")
        if GAME_CONFIG['允许搓牌'] == true then
            -- self.btn_cuopai:setVisible(true)
            self.btn_cuopai:setVisible(true)
            -- self:showControlButtons(5)
            -- if g_mainScene.gameConfigTable.gameType ~= 5 and g_mainScene.gameConfigTable.gameType ~= 2 then
            --     GamePlaneOperator:showCuoPai(_, true)
            -- end
        else
            self.btn_cuopai:setVisible(false)
        end
        -- self.btn_cuopai:setVisible(true)
        self.btn_fanpai:setVisible(true)

        self.btn_tip:setVisible(false)
        self.btn_outcard:setVisible(false)
    elseif stage == 5 then --搓牌，翻牌之后
        self.ready_plane:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)

        self.out_card_plane:setVisible(true)

        self.btn_cuopai:setVisible(false)
        self.btn_fanpai:setVisible(false)

        -- self.btn_tip:setTouchEnabled(true)
        -- self.btn_tip:setVisible(true)
        self.btn_outcard:setVisible(false)
        LayerShuffling:removeScene()

        -- self.btn_fanpai:setPositionX(self.outCardPlaneMiddlePositionX)
    end
end

function ControlPlaneOperator:hideCardKindTipButton()
    -- self.btn_tip:setVisible(false)
    self.btn_cuopai:setVisible(false)
    -- self.btn_fanpai:setPositionX(self.outCardPlaneMiddlePositionX)
end

--滑条更多控制
function ControlPlaneOperator:chouma_slider(choumalist)

    local morebase_slider = self._scene:getChildByName('morebase_slider')
    morebase_slider:setVisible(true)
    self.bet_plane = morebase_slider:getChildByName('bet_plane')
    local base_sl = morebase_slider:getChildByName('base_sl')
    local base_tt = nowself.bet_plane:getChildByName('base_tt')
    local sure_bt = morebase_slider:getChildByName('sure_bt')

    local Slider_Sure_bt = sure_bt

    local down_bt = morebase_slider:getChildByName('down_bt')
    local up_bt = morebase_slider:getChildByName('up_bt')

    local split_num = table.nums(choumalist)

    local positionDeviation = positionDeviation or 0
    local maxValue = 100
    local minValue = 0
    local buttonWeight = 0.5
    local beginPositionX = 98
    local endPositionX = 512
    local tipsJianju = (endPositionX - beginPositionX) / (maxValue - minValue)

    -- nowself.bet_plane   --气泡对话框   nowself.bet_plane
    -- base_sl  --滑动条   base_sl
    -- base_tt  --气泡对话框内的 文本框  base_tt
    -- sure_bt   --提交按钮   sure_bt
    -- down_bt   --减少筹码按钮   down_bt
    -- up_bt     --增加筹码按钮     up_bt

    local jianjuamount = (maxValue - minValue) / (split_num - 1) / 2

    choumalist[0] = choumalist[1]
    local amountList = {}
    amountList[0] = minValue

    for i = 1, split_num do
        amountList[i] = (maxValue - minValue) / (split_num - 1) * (i - 1) + minValue
    end

    --------------------------------测试触摸代码--------------------------------

    --   local fixScuccess = false
    --   local silderAccuracy = 0.6

    --   while not fixScuccess do

    --    local positionArray = {}
    --    local testArray = {}

    --    for i=1,split_num + split_num-1 do
    --     if i%2==1 then
    --        positionArray[i] = amountList[(i+1)/2]
    --        elseif i%2==0 then
    --        positionArray[i] = amountList[i/2] + jianjuamount
    --        table.insert(testArray,positionArray[i]-silderAccuracy)
    --        table.insert(testArray,positionArray[i]+silderAccuracy)
    --        end
    --    end

    --    local testCheckArray ={}
    --    for i,v in pairs(testArray) do
    --       testCheckArray[i]= math.floor((v+positionDeviation)/(maxValue/split_num)+buttonWeight)
    --    end

    --    -- dump(positionArray,"触摸控制点")

    --    local positionPercentArray = {}

    --    for i= 1,table.nums(positionArray) do
    --     positionPercentArray[i] = math.floor((positionArray[i]+positionDeviation)/(maxValue/split_num)+buttonWeight)
    --    end

    --    -- dump(positionPercentArray,"触摸控制百分比点")

    --    dump(testCheckArray,"测试触摸数组")

    --    local runTimes = 0
    --    local MaxrunTimes = 200

    --    while not(fixScuccess) and runTimes<MaxrunTimes do
    --        runTimes = runTimes+1
    --     fixScuccess = true
    --        dump(runTimes,"运行次数")
    --     for i,v in pairs(testCheckArray) do
    --      if testCheckArray[1] > 1 then
    --          positionDeviation = positionDeviation -0.01
    --          testCheckArray = false
    --      elseif  testCheckArray[#testCheckArray] ==0 then
    --          positionDeviation = positionDeviation +0.01
    --          fixScuccess = false
    --      elseif  testCheckArray[#testCheckArray] < split_num then
    --          positionDeviation = positionDeviation +0.01
    --          fixScuccess = false
    --      elseif  testCheckArray[#testCheckArray] > split_num then
    --          positionDeviation = positionDeviation -0.01
    --          fixScuccess = false

    --      else

    --         if  i>1 and i<#testCheckArray then

    --              if v == 1 then
    --                  positionDeviation = positionDeviation +0.01
    --                  fixScuccess = false
    --              elseif v == split_num then
    --                  positionDeviation = positionDeviation - 0.01
    --                  fixScuccess = false
    --              elseif testCheckArray[i] < select(i%2+1,i/2+1,(i-1)/2+1)  then  --奇数和偶数
    --                  fixScuccess = false
    --                  positionDeviation = positionDeviation +0.01
    --              elseif testCheckArray[i] > select(i%2+1,i/2+1,(i-1)/2+1) then
    --                  fixScuccess = false
    --                  positionDeviation = positionDeviation -0.01
    --              end

    --          end

    --      end

    --      testCheckArray[i] = math.floor((testArray[i]+positionDeviation)/(maxValue/split_num)+buttonWeight)

    --     end
    -- end

    --     if fixScuccess == true then
    --      dump("纠正成功")
    --      dump(testCheckArray,"触摸测试数组")
    --      dump(positionDeviation,"最终偏差")
    --      dump(silderAccuracy,"最终精度")
    --  else
    --      dump("纠正失败")
    --      silderAccuracy = silderAccuracy+0.1
    --      dump(silderAccuracy,"精度修正")
    --  end

    -- end

    --------------------------------------------------------------------------------------------

    local percentList = {}
    for i, v in pairs(amountList) do
        percentList[v] = i
    end

    local choumaIndex = 1
    local function SliderSetPosition(percent)
        nowself.bet_plane:setPositionX(tipsJianju * (percent - minValue) + beginPositionX)
        base_sl:setPercent(percent)
        base_tt:setString(choumalist[percentList[percent]] .. '倍')
        require(TpackageName .. 'Utils'):playEffect('下注')
    end

    SliderSetPosition(amountList[1])

    local function sliderChanged(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local amount = sender:getPercent()

            choumaIndex = math.floor((amount + positionDeviation) / (maxValue / split_num) + buttonWeight)
            amount = amountList[choumaIndex] or maxValue
            local chouma = choumalist[choumaIndex] or choumalist[split_num]
            base_tt:setString(chouma .. '倍')
            SliderSetPosition(amount)
        end
    end

    base_sl:addEventListener(sliderChanged)

    local touchEvent = function(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if sender == down_bt and choumaIndex > 1 then
                choumaIndex = (choumaIndex or 0) - 1
                local amount = amountList[choumaIndex]
                SliderSetPosition(amount)
            elseif sender == up_bt and choumaIndex < split_num then
                choumaIndex = (choumaIndex or 0) + 1
                local amount = amountList[choumaIndex]
                SliderSetPosition(amount)
            elseif sender == sure_bt then
                SliderSetPosition(amountList[1])

                choumaIndex = choumaIndex or 0
                sure_bt:setVisible(false)
                morebase_slider:setVisible(false)

                NiuNiuSendHandle:addBase(choumalist[choumaIndex]) --给服务器传下多少筹码的函数
            end
        end
    end

    sure_bt:addTouchEventListener(touchEvent)
    up_bt:addTouchEventListener(touchEvent)
    down_bt:addTouchEventListener(touchEvent)

    return sure_bt
end

function ControlPlaneOperator:setUpBankBtnVisible(flag, state)
    if USERS_READY_STATE[USER_INFO['uid']] == 0 or USERS_READY_STATE[USER_INFO['uid']] == nil then
        return
    end

    if flag == nil then
        flag = false
    end
    self.douGongniu_plane:getChildByName('bankOptNode'):setVisible(flag)
    if flag then
        if state == 7 then
            self.btnDownBank:setBright(true)
            self.btnDownBank:setEnabled(true)
            self.btnNotUpBank:setBright(true)
            self.btnNotUpBank:setEnabled(true)
            self.btnUpBank:setBright(true)
            self.btnUpBank:setEnabled(true)
        elseif state == 6 then
            self.btnDownBank:setBright(false)
            self.btnDownBank:setEnabled(false)
            self.btnNotUpBank:setBright(true)
            self.btnNotUpBank:setEnabled(true)
            self.btnUpBank:setBright(true)
            self.btnUpBank:setEnabled(true)
        elseif state == 5 then
            self.btnDownBank:setBright(true)
            self.btnDownBank:setEnabled(true)
            self.btnNotUpBank:setBright(false)
            self.btnNotUpBank:setEnabled(false)
            self.btnUpBank:setBright(true)
            self.btnUpBank:setEnabled(true)
        elseif state == 3 then
            self.btnDownBank:setBright(true)
            self.btnDownBank:setEnabled(true)
            self.btnNotUpBank:setBright(true)
            self.btnNotUpBank:setEnabled(true)
            self.btnUpBank:setBright(false)
            self.btnUpBank:setEnabled(false)
        elseif state == 1 then
            self.btnDownBank:setBright(true)
            self.btnDownBank:setEnabled(true)
            self.btnNotUpBank:setBright(false)
            self.btnNotUpBank:setEnabled(false)
            self.btnUpBank:setBright(false)
            self.btnUpBank:setEnabled(false)
        end
    end
end

function ControlPlaneOperator:setReadyBtnVisible(flag)
    if flag == nil then
        flag = false
    end

    self.douGongniu_plane:getChildByName('readyNode'):setVisible(false)
    --
end

function ControlPlaneOperator:setBetBtnVisible(flag)
    if flag == nil then
        flag = false
    end

    self.dgn_betNode:setVisible(flag)
end

function ControlPlaneOperator:showBetBtnScore()
    if GAME_TYPE == 5 then
        if USER_INFO['uid'] == BANKER_UID then
            return
        end
        self:setBetBtnVisible(true)
        local baseGuodi = g_mainScene.baseGuodi or ((g_mainScene.gameConfigTable.guodi or 50) * BASE_CHIP)
        local curGuodi = g_mainScene.curGuodi or ((g_mainScene.gameConfigTable.guodi or 50) * BASE_CHIP)
        local minScore = 1
        if g_mainScene.bFristBet then
            if g_mainScene.gameConfigTable.firstBetLimit ~= nil then
                minScore = math.floor(baseGuodi * tonumber(g_mainScene.gameConfigTable.firstBetLimit) / 100) or 1
            end
        else
            if g_mainScene.gameConfigTable.afterBetLimit ~= nil then
                minScore = math.floor(baseGuodi * tonumber(g_mainScene.gameConfigTable.afterBetLimit) / 100) or 1
            end
        end
        local _maxScore = math.floor(curGuodi / 3)
        local maxScore = _maxScore < 10 and _maxScore or (math.floor(math.floor(curGuodi / 3) / 10) * 10 or minScore)
        maxScore = maxScore < minScore and minScore or maxScore
        g_mainScene.minBetScore = minScore == 0 and 1 or minScore
        g_mainScene.midBetScore = maxScore == 0 and 1 or maxScore
        g_mainScene.dgnShotScore = math.floor(curGuodi / 3) == 0 and 1 or math.floor(curGuodi / 3)
        g_mainScene.dgnShotScore = g_mainScene.dgnShotScore < maxScore and maxScore or g_mainScene.dgnShotScore
        g_mainScene.sliderScore = g_mainScene.minBetScore
        self.dgn_sliderScore:setString(g_mainScene.sliderScore)
        self.dgn_betSlider:setPercent(0)
        self.btnBetLeft:getChildByName('score'):setString(minScore .. ' 分')
        self.btnBetMid:getChildByName('score'):setString(maxScore .. ' 分')
    end
end

function ControlPlaneOperator:showGuodiNodeVisible()
    self.dgn_guodiNode:setVisible(true)
    self.dgn_clockBg = self.dgn_guodiNode:getChildByName('clockBg')
    self.dgn_clockBg:setVisible(true)
end

function ControlPlaneOperator:setGuodiScore(score)
    self.dgn_guodiNode:setVisible(true)
    local guoScore = self.dgn_guodiNode:getChildByName('guoScore')
    guoScore:setString(score or '0')
end

function ControlPlaneOperator:setGuoJusize(juSize)
    local guoJuSize = self.dgn_guodiNode:getChildByName('guoJuSize')
    guoJuSize:setString(string.format('第%d/%s局', g_mainScene.m_nGuoCount or 1, tostring(juSize or '0')))
end

function ControlPlaneOperator:setRoomRoundVisible(flag)
    if flag == nil then
        flag = false
    end
    g_mainScene._scene:getChildByName('game_plane'):getChildByName('room_info'):getChildByName('round_info'):setVisible(
        flag
    )
end

function ControlPlaneOperator:showOptClock(times)

    if times == nil then
        return
    end

    self.dgn_clockBg:stopAllActions()
    self.timesTxt = self.dgn_guodiNode:getChildByName('clockBg'):getChildByName('timesTxt')
    self.timesTxt:setString(times or '0')
    local showTimerAc =
        cc.CallFunc:create(
        function()
            times = times - 1

            if times > 0 then
                self.timesTxt:setString(times)
            elseif times == nil or times == 0 then
                self.dgn_clockBg:stopAllActions()
            -- self.dgn_guodiNode:getChildByName("clockBg"):setVisible(false)
            end
        end
    )
    local seqAc = cc.Sequence:create(cc.DelayTime:create(1), showTimerAc)
    self.dgn_clockBg:runAction(cc.RepeatForever:create(seqAc))
end

return ControlPlaneOperator
