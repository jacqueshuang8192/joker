local ControlPlaneOperator = class("ControlPlaneOperator")
local LoadCard = require(TpackageName .. ".operator.LoadCard")
local CardPlaneOperator = require(TpackageName .. ".operator.CardPlaneOperator")

local CHILD_NAME_GROUP_TYPE_1 = "txt_v_name"
local CHILD_NAME_GROUP_TYPE_2 = "txt_h_name"

function ControlPlaneOperator:init(panel)
    -------------------------- IP相同提示 -----------------------
    self.ip_panel = panel:getChildByName("ip_panel")
    self.ip_panel:setVisible(false)

    -------------------------- 下注 -----------------------------
    self.tou_panel=panel:getChildByName("dao_panel")
    self.tou_panel:setVisible(false)
    self.call_times_panel = panel:getChildByName("call_times_panel")
    self.call_times_panel:setVisible(false)
    self.txt_dao_title = panel:getChildByName("txt_dao_title")
    self.bg_liang = panel:getChildByName("bg_liang")
    self.txt_dao_title:setVisible(false)
    self.bg_liang:setVisible(false)
    self.btn_times = panel:getChildByName("btn_times")
    -- self.btn_times:setVisible(true)

    -------------------------- 锅 ---------------------------
    img_guo = panel:getChildByName("img_guo")
    self.original_pos=img_guo:getPosition()
    img_guo:setVisible(true)
    -------------------------- 锅分数 -----------------------
    self.txt_guo = img_guo:getChildByName("txt_guo")
    self.txt_guo:setString("0")

    -------------------------- 锅下注 ----------------------------
    self.call_guo_panel = panel:getChildByName("call_guo_panel")
    self.call_guo_panel:setVisible(false)
    -------------------------- 锅选择界面-------------------------
    self.guo_choose_panel = panel:getChildByName("guo_choose_panel")
    self.guo_choose_panel:setVisible(false)
    -------------------------- 切锅按钮 监听事件没写完--------------------------
    local btn_cute = self.guo_choose_panel:getChildByName("btn_cute")
    -- 切锅按钮
    btn_cute:addTouchEventListener(function (sender, event)
        if event == TOUCH_EVENT_ENDED then
            dump("---------- 切锅按钮 ------------")
            SoundUtils:playEffect("click")
            -- 发送切锅协议
            PaiJiuSendHandle:CLIENT_DOWN_BANK_OPT(1)--CLI_GUO_OPTION
        end
    end)
    -- 不切锅按钮
    local btn_no_cute = self.guo_choose_panel:getChildByName("btn_no_cute")
    btn_no_cute:addTouchEventListener(function (sender, event)
        if event == TOUCH_EVENT_ENDED then
            dump("----- 不切锅按钮 -------")
            SoundUtils:playEffect("click")
            PaiJiuSendHandle:CLIENT_DOWN_BANK_OPT(0)--CLI_GUO_OPTION
        end
    end)

    -------------------------- 庄选择界面 -----------------------------
    self.zhuang_panel = panel:getChildByName("zhuang_panel")
    self.zhuang_panel:setVisible(false)
    -- 抢庄按钮
    local btn_qiangZhuang = self.zhuang_panel:getChildByName("btn_get_zhuang")
    btn_qiangZhuang:addTouchEventListener(
    function (sender, event)
        if event == TOUCH_EVENT_ENDED then
            SoundUtils:playEffect("click")
            -- 发送抢庄
            PaiJiuSendHandle:qiang(1)
            self.zhuang_panel:setVisible(false)
        end
    end
    )
    -- 不抢庄按钮
    local btn_noQiangZhuang = self.zhuang_panel:getChildByName("btn_no_get_zhuang")
    btn_noQiangZhuang:addTouchEventListener(
    function (sender, event)
        if event == TOUCH_EVENT_ENDED then
            SoundUtils:playEffect("click")
            -- 发送不抢庄
            PaiJiuSendHandle:qiang(0)
            self.zhuang_panel:setVisible(false)
        end
    end
    )
    
    --------------------- 邀请微信好友按钮：监听事件没写完 -------------------
    self.btn_invite = panel:getChildByName("btn_invite")
    if  isiOSVerify then
        btn_invite:setVisible(false)
    end
    self.btn_invite:addTouchEventListener(
    function(sender, event)
        -- 触摸开始
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
            SoundUtils:playEffect("click")

            local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
            local share_content = ""
            for k, v in pairs(config_arr) do
                if v ~= "" then
                    share_content = share_content .. v .. ","
                end
            end

            share_content = string.sub(share_content, 1, string.len(share_content) - 1)

            local invote_code = USER_INFO["invote_code"] or ""
            require("hall.common.ShareLayer"):showShareLayer(GAME_NAME .. "，房号：" .. invote_code, "", "url", share_content)

        end
    end
    )
    self.btn_invite:setVisible(false)

    --------------------- 复制房号按钮 -------------------
    self.btn_copy = panel:getChildByName("btn_copy")
    if  isiOSVerify then
        btn_copy:setVisible(false)
    end
    self.btn_copy:addTouchEventListener(
    function(sender, event)
        -- 触摸开始
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
            SoundUtils:playEffect("click")
            require("hall.util.GameMenu"):registCopyRoomIdFunc(self.btn_copy, USER_INFO["invote_code"], GAME_NAME) 
        end
    end
    )
    self.btn_copy:setVisible(false)

    --------------------- 设置坐下按钮监听事件 ---------------------
    self.btn_sit=panel:getChildByName("btn_sit")
    self.btn_sit:addTouchEventListener(
    function (sender, event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        elseif event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        elseif event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            SoundUtils:playEffect("click")
            PaiJiuSendHandle:sitDown(-1)
        end
    end
    )
    self.btn_sit:setVisible(false)

    --------------------- 设置站起按钮监听事件 ---------------------
    self.btn_stand=panel:getChildByName("btn_stand")
    self.standpos=self.btn_stand:getPosition()
    self.btn_stand:addTouchEventListener(
    function (sender, event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        elseif event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        elseif event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            SoundUtils:playEffect("click")
            PaiJiuSendHandle:standUp()
            GamePlaneOperator:showchip()
        end
    end
    )
    self.btn_stand:setVisible(false)

    --------------------- 准备按钮：监听事件没写完 ----------------------------
    self.btn_ready = panel:getChildByName("btn_ready")
    self.readypos=self.btn_ready:getPosition()
    self.btn_ready:addTouchEventListener(
    function (sender, event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        elseif event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        elseif event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            SoundUtils:playEffect("click")
            PaiJiuSendHandle:readyNow(1)
            GamePlaneOperator:showchip()
        end
    end
    )
    self.btn_ready:setVisible(false)

    ---------------------- 退出房间按钮：退出函数没有确认 -----------------------
    self.btn_exit_room = panel:getChildByName("btn_exit_room")
    --dump("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
    --dump(GAME_MODE, "-------------------------------")
    if GROUP_MODE == 1 then
        dump(" ------------ game_mode 1 -------------")
        self.btn_exit_room:addTouchEventListener(
        function(sender,event)
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
                SoundUtils:playEffect("click")
                -- 一代退出房间走接口
                cct.createHttRq({
                    url=HttpAddr .. "/exitFreeGameByDbDateAndGame",
                    date= {
                        table_id = USER_INFO["tid"],
                        activityId = USER_INFO["activity_id"],
                        userId = USER_INFO["uid"]
                    },
                    type_="POST",
                    callBack = function(data)
                        dump(data,"data20171031")
                        netData = json.decode(data.netData)
                        if netData.returnCode == "0" then
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
                        else
                            require("hall.GameTips"):showTips("提示", "", 3, "当前状态无法离开房间")
                        end
                    end
                })
            end
        end
        )
    elseif GROUP_MODE == 2 then
        dump(" ------------ game_mode 2 -------------")
        self.btn_exit_room:addTouchEventListener(
        function(sender,event)
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
                SoundUtils:playEffect("click")
                -- 二代退出房间走协议
                local quitRoomAction = function()
                    SCENENOW["scene"]:quitRoom()
                end
                require("hall.GameTips"):showTips("提示", "", 1, "确定退出房间？", nil, quitRoomAction)
            end
        end
        )
    end
    self.btn_exit_room:setVisible(false)

    ---------------------- 提示按钮 ----------------------
    self.btn_prompt = panel:getChildByName("btn_prompt")
    self.btn_prompt:setVisible(false)
    --
    ---------------------- 开牌按钮 ----------------------
    self.btn_open = panel:getChildByName("btn_open")
    self.btn_open:setVisible(false)
    self.btn_open:addTouchEventListener(
    function (sender, event)
        if event == TOUCH_EVENT_ENDED then
            SoundUtils:playEffect("click")
            -- 小牌九
            if GAME_MODE == "小牌九" then
                PJ_CARDS_SELECTED = {}
                PJ_CARDS_SELECTED[1] = PJ_HANDCARDS[1]
                PJ_CARDS_SELECTED[2] = PJ_HANDCARDS[2]
                CardPlaneOperator:setCardToOriginalPos()
            end
            if #PJ_CARDS_SELECTED ~= 2 then
                return
            end
            PaiJiuSendHandle:sendMycards(PJ_CARDS_SELECTED[1], PJ_CARDS_SELECTED[2])
        end
    end
    )

    ---------------------- 水平提醒文字 -------------------
    self.txt_h_name = panel:getChildByName("txt_h_name")
    self.txt_h_name:setVisible(false)

    ---------------------- 垂直提醒文字 -------------------
    self.txt_v_name = panel:getChildByName("txt_v_name")
    self.txt_v_name:setVisible(false)

    ----------------------  快速充值按钮 ----------------------
    self.btn_buyCoin = panel:getChildByName("btn_buyCoin")
    self.btn_buyCoin:addTouchEventListener(function (sender, event)
        --触摸开始
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
            require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
        end
    end)
    self.btn_buyCoin:setVisible(false)
    --[[
        self.btn_start = panel:getChildByName("btn_start")
        self.btn_start:setVisible(false)
        self.btn_start:addTouchEventListener(----显示菜单栏操作
            function(sender,event)
                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                   PaiJiuSendHandle:StartGame()
                   SoundUtils:playEffect("click")
                   self.btn_start:setVisible(false)

                end
            end)

        ---------------抢庄系列
        self.grab_banker_panel = panel:getChildByName("grab_banker_panel")
        self.grab_banker_panel:setVisible(false)

        self.btn_qiang = panel:getChildByName("btn_qiang")
        self.btn_qiang:addTouchEventListener(
            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED
                 then

                    SoundUtils:playEffect("click")
                    PaiJiuSendHandle:qiang(1)
                    self.grab_banker_panel:setVisible(false)

                end
            end)

        self.btn_buqiang = panel:getChildByName("btn_buqiang")
        self.btn_buqiang:addTouchEventListener(
            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    SoundUtils:playEffect("click")
                    PaiJiuSendHandle:qiang(0)
                    self.grab_banker_panel:setVisible(false)

                end
            end)

        self.btn_grab_banker_button = panel:getChildByName("btn_grab_banker_button")

        -----------加倍
        self.bet_panel = panel:getChildByName("bet_panel")
        self.btn_bet = panel:getChildByName("btn_bet")
        -----------出牌
        self.out_card_panel = panel:getChildByName("out_card_panel")
        self.out_card_panel:setVisible(false)

        self.outCardPlaneMiddlePositionX = self.out_card_panel:getContentSize().width/2

        --搓牌
        self.btn_cuopai = self.out_card_panel:getChildByName("btn_cuopai")
        self.btn_cuopai:addTouchEventListener(
            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    self:hideCardKindTipButton()
                    GamePlaneOperator:showCuoPai(_,true)

                end
            end)


        --摊牌（出牌）
        self.btn_liangcards = self.out_card_panel:getChildByName("btn_liangcards")
        self.btn_liangcards_oriPositionX =  self.btn_liangcards:getPositionX()
        self.btn_liangcards:addTouchEventListener(
            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    GamePlaneOperator:hideCardNumCountEffect()

                    local Mychoice = {}
                    for i=1,3 do
                        table.insert(Mychoice,0)
                    end

                    PaiJiuSendHandle:sendMycards(Mychoice)

                end
            end)


        --提示
        self.btn_tip = self.out_card_panel:getChildByName("btn_tip")
        self.btn_tip:setVisible(false)
        self.btn_tip:addTouchEventListener(
            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    GamePlaneOperator:countFanAndShow(CARD_PLAYERTYPE_MY)

                    self:hideCardKindTipButton()

                end
            end)


        self.waiwei_choose_panel = panel:getChildByName("waiwei_choose_panel")
        self.waiwei_choose_panel:setVisible(false)


        for i = 1,4 do
            local bet_chip_bt =  self.waiwei_choose_panel:getChildByName("bet_chip_" .. i)

            if  i == BETCOUNT then
                bet_chip_bt:setColor(cc.c3b(255,255,255))
            else
                bet_chip_bt:setColor(cc.c3b(120,120,120))
            end

            local bet_chip_txt = self.waiwei_choose_panel:getChildByName("bet_chip_txt_" .. i)
            local touchFunc = function(sender,event)

                --触摸结束（检查当前组局状态）
                if  event == TOUCH_EVENT_ENDED then

                    for i = 1,4 do
                        local bet_chip_bt =  self.waiwei_choose_panel:getChildByName("bet_chip_" .. i)
                        bet_chip_bt:setColor(cc.c3b(120,120,120))
                    end

                    bet_chip_bt:setColor(cc.c3b(255,255,255))

                    dump(i,"touchFunc")
                    BETCOUNT = i
                end

            end

            bet_chip_txt:addTouchEventListener(touchFunc)
            bet_chip_bt:addTouchEventListener(touchFunc)

        end
        ]]

end

function ControlPlaneOperator:clearGameDatas(stage)

    if stage == 1 then
        self:showWaiWeiButton(false)
    elseif stage == 2 or stage == nil then
        -- 3个按钮
        GamePlaneOperator:showInviteReadyExitBtn(2)
        -- 准备文本
        --GamePlaneOperator:clearAllReadyStatus()
        -- 抢庄按钮
        self:loadZhuangPanel(false)
        -- 玩家抢庄态度
        --GamePlaneOperator:clearGrabBankerSymbol()
        -- 下注
        self:callGuoPanel(false)
        -- 所有玩家到道数初始化
        --GamePlaneOperator:initPlayerDaoPanel()
        -- 锅选择界面
        self:showGuoChoosePanel(false)
        -- 出牌按钮
        self:showOutCardButtons(false)
        -- 清除牌类型的提示文本
        self:showCardGroups(false)
    end

end

function ControlPlaneOperator:RemaidStartGame(flag)
    self.btn_start:setVisible(flag)
end

function ControlPlaneOperator:showWaiWeiButton(flag)

    self.waiwei_choose_panel:setVisible(flag)

    if  flag == true then
        for i = 1,4 do
            local bet_chip_txt = self.waiwei_choose_panel:getChildByName("bet_chip_txt_" .. i)
            local bet_chip_bt =  self.waiwei_choose_panel:getChildByName("bet_chip_" .. i)

            if  i <= #WAIWEI_BET_CHIPS then
                bet_chip_txt:setString(WAIWEI_BET_CHIPS[i])
            else
                bet_chip_bt:setTouchEnabled(false)
                bet_chip_txt:setTouchEnabled(false)
                bet_chip_txt:setString("???")
            end

        end
    end

end

function ControlPlaneOperator:updateWaiWeiButton()

    for i = 1,4 do
        local bet_chip_bt =  self.waiwei_choose_panel:getChildByName("bet_chip_" .. i)

        if  i == BETCOUNT then
            bet_chip_bt:setColor(cc.c3b(255,255,255))
        else
            bet_chip_bt:setColor(cc.c3b(120,120,120))
        end

    end
end

function ControlPlaneOperator:showCheckResultButton(flag)
    self.btn_check_group_result:setVisible(flag)
    self:showControlButtons(1,false)
end

function ControlPlaneOperator:loadBetButtons(base,canChooseBases,tuiZhuBase)

    -- local base = {5,10,15,20}
    dump(base, "----显示抢分面板-----")

    local canChooseBasesExist = {}
    if canChooseBases then
        for i,times in pairs(canChooseBases) do
            canChooseBasesExist[times] = true
        end
    else
        for i,times in pairs(base) do
            canChooseBasesExist[times] = true
        end
    end

    self.bet_panel:removeAllChildren()
    local bt_num = table.nums(base)

    local middleIndex = (bt_num+1)/2

    local panelMiddlePositionX = self.bet_panel:getContentSize().width/2
    local panelMiddlePositionY = self.bet_panel:getContentSize().height/2

    local buttonInterval = 230
    if bt_num > 0 then

        for i = 1, bt_num do

            local btn_bet = self.btn_bet:clone()
            local bet_times_txt = btn_bet:getChildByName("bet_times_txt")
            local img = btn_bet:getChildByName("img")
            -- local effect_img = btn_bet:getChildByName("effect_img")
            --       effect_img:setVisible(false)

            btn_bet:setPosition( panelMiddlePositionX + buttonInterval*(i-middleIndex),panelMiddlePositionY)

            btn_bet:setVisible(true)
            bet_times_txt:setString(tostring(base[i]))

            if  base[i] < 10 then
                bet_times_txt:setPositionX(103)
                img:setPositionX(118)
            else
                bet_times_txt:setPositionX(128)
                img:setPositionX(125)
            end

            if  tuiZhuBase == base[i] then

                local cross_effect_frame_1 = btn_bet:getChildByName("cross_effect_frame_1")
                local cross_effect_frame_2 = btn_bet:getChildByName("cross_effect_frame_2")

                local tuiZhuBaseEffect = cc.RepeatForever:create(
                cc.Sequence:create(
                cc.CallFunc:create(function()
                    if cross_effect_frame_1:isVisible()  then
                        cross_effect_frame_1:setVisible(false)
                        cross_effect_frame_2:setVisible(true)
                    else
                        cross_effect_frame_1:setVisible(true)
                        cross_effect_frame_2:setVisible(false)
                    end
                end),
                cc.DelayTime:create(0.25)
                )
                )
                btn_bet:runAction(tuiZhuBaseEffect)

            end

            self.bet_panel:addChild(btn_bet)

            if  canChooseBasesExist[base[i]] then

                btn_bet:addTouchEventListener(function(sender,event)

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

                        SoundUtils:playEffect("下注")

                        PaiJiuSendHandle:addBase(base[i])

                        GamePlaneOperator:setBetTimes(CARD_PLAYERTYPE_MY,base[i],true)
                        self.bet_panel:setVisible(false)
                        self.bet_panel:removeAllChildren()

                    end

                end)

            else

                btn_bet:setBright(false) --setColor(cc.c3b(140,140,140))

            end

        end

    end

end

function ControlPlaneOperator:loadZhuangPanel(flag)
    self.zhuang_panel:setVisible(flag)
end

function ControlPlaneOperator:showSitDownButton(flag)

    dump(flag,"开关showSitDownButton")

    if  isGoldGame == 0 then
        self.btn_sit:setVisible(flag)
    end

end

--准备，（抢庄）（加倍）（摊牌，提示，搓牌）  游戏操作按钮
function ControlPlaneOperator:showControlButtons(stage, flag)
    -- pack.user_status 的可能值
    -- 0 //牌局已结束
    -- 1 准备
    -- 2 等待用户抢庄
    -- 3 牌局开始
    -- 4 GRABDEALER
    -- 5 等待用户选择倍数
    -- 6 CALLTIMES
    -- 7 等待出牌
    -- 8 OUTCARD
    -- 9 ISSPECTATOR
    -- GAME_STATUS_WAIT = 0        -- 等待玩家准备
    -- GAME_STATUS_GRAB = 1        -- 等待用户抢庄
    -- GAME_STATUS_TIMES = 2       -- 等待用户选择倍数
    -- GAME_STATUS_OUTCARD = 3     -- 牌局进行中
    -- GAME_STATUS_STOP = 4        -- 牌局结束
    dump(stage,"游戏阶段")
    dump(flag,"显示标记")

    if  flag == false then

        self.chip_panel:setVisible(false)
        self.zhuang_panel:setVisible(false)
        self.btn_invite:setVisible(false)
        self.btn_ready:setVisible(false)
        self.btn_exit_room:setVisible(false)
        -- self.grab_banker_panel:setVisible(false)
        -- self.bet_panel:setVisible(false)
        -- self.out_card_panel:setVisible(false)

        return
    end

    if  stage == GAME_STATUS_WAIT then   --准备阶段

        --[[        if  isGoldGame == 1 then
                    self.btn_stand_up:setVisible(false)
                    self.btn_ready:setPositionX(self.ready_panel:getContentSize().width/2)
                end ]]

        -- self.ready:setVisible(true)

        -- self.grab_banker_panel:setVisible(false)
        -- self.bet_panel:setVisible(false)
        -- self.out_card_panel:setVisible(false)

    elseif  stage == GAME_STATUS_GRAB then  --抢庄阶段
        -- 准备阶段的按钮设置为不可见：邀请好友、退出房间
        self.btn_invite:setVisible(false)
        self.btn_exit_room:setVisible(false)

        -- 抢庄界面
        self.zhuang_panel:setVisible(true)
        --[[        self.grab_banker_panel:setVisible(true)
                self.bet_panel:setVisible(false)
                self.out_card_panel:setVisible(false)]]

    elseif  stage == GAME_STATUS_TIMES then  --加注阶段

        self.ready_panel:setVisible(false)

        self.grab_banker_panel:setVisible(false)
        self.bet_panel:setVisible(true)
        self.out_card_panel:setVisible(false)

    elseif  stage == 4 then

        self.ready_panel:setVisible(false)
        self.grab_banker_panel:setVisible(false)
        self.bet_panel:setVisible(false)

        self.out_card_panel:setVisible(true)
        -- self.btn_tip:setVisible(true)
        if GAME_CONFIG["允许搓牌"] == true then
            self.btn_cuopai:setVisible(true)
        else
            self.btn_cuopai:setVisible(false)
        end

        self.btn_liangcards:setVisible(true)
        -- self.btn_liangcards:setPositionX(self.btn_liangcards_oriPositionX)

    elseif  stage == 5 then  --搓牌，翻牌之后

        self.ready_panel:setVisible(false)
        self.grab_banker_panel:setVisible(false)
        self.bet_panel:setVisible(false)

        self.out_card_panel:setVisible(true)
        -- self.btn_tip:setVisible(false)
        self.btn_cuopai:setVisible(false)
        self.btn_liangcards:setVisible(true)
        -- self.btn_liangcards:setPositionX(self.outCardPlaneMiddlePositionX)
        dump("搓牌之后")
    end

end

function ControlPlaneOperator:hideCardKindTipButton()

    -- self.btn_tip:setVisible(false)
    self.btn_cuopai:setVisible(false)
    -- self.btn_liangcards:setPositionX(self.outCardPlaneMiddlePositionX)

end

--滑条更多控制
function ControlPlaneOperator:chouma_slider(choumalist)

    dump(choumalist, "----choumalist----")

    local   morebase_slider = self._scene:getChildByName("morebase_slider")
    morebase_slider:setVisible(true)
    self.bet_panel = morebase_slider:getChildByName("bet_panel")
    local   base_sl = morebase_slider:getChildByName("base_sl")
    local   base_tt = nowself.bet_panel:getChildByName("base_tt")
    local   sure_bt = morebase_slider:getChildByName("sure_bt")

    local   Slider_Sure_bt = sure_bt

    local   down_bt = morebase_slider:getChildByName("down_bt")
    local   up_bt = morebase_slider:getChildByName("up_bt")

    local   split_num = table.nums(choumalist)

    local   positionDeviation = positionDeviation or  0
    local   maxValue = 100
    local   minValue = 0
    local   buttonWeight = 0.5
    local   beginPositionX = 98
    local   endPositionX = 512
    local   tipsJianju = (endPositionX -beginPositionX)/(maxValue-minValue)

    -- nowself.bet_panel   --气泡对话框   nowself.bet_panel
    -- base_sl  --滑动条   base_sl
    -- base_tt  --气泡对话框内的 文本框  base_tt
    -- sure_bt   --提交按钮   sure_bt
    -- down_bt   --减少筹码按钮   down_bt
    -- up_bt     --增加筹码按钮     up_bt

    local   jianjuamount = (maxValue-minValue)/(split_num-1)/2

    choumalist[0] = choumalist[1]
    local   amountList ={}
    amountList[0] = minValue

    for  i= 1,split_num do
        amountList[i] = (maxValue-minValue)/(split_num-1)*(i-1)+ minValue
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

    local percentList= {}
    for i,v in pairs(amountList) do
        percentList[v] = i
    end

    local choumaIndex  = 1
    local function SliderSetPosition(percent)
        nowself.bet_panel:setPositionX(tipsJianju*(percent-minValue) + beginPositionX)
        base_sl:setPercent(percent)
        base_tt:setString(choumalist[percentList[percent]].."倍")
        require(TpackageName .. "Utils"):playEffect("下注")
    end

    SliderSetPosition(amountList[1])

    local function sliderChanged(sender,eventType)

        if eventType == ccui.SliderEventType.percentChanged then
            local amount = sender:getPercent()

            choumaIndex = math.floor((amount+positionDeviation)/(maxValue/split_num)+buttonWeight)
            amount = amountList[choumaIndex]  or maxValue
            local chouma =  choumalist[choumaIndex] or  choumalist[split_num]
            base_tt:setString(chouma.."倍")
            SliderSetPosition(amount)
        end

    end

    base_sl:addEventListener(sliderChanged)

    local touchEvent = function(sender,event)

        if event == TOUCH_EVENT_ENDED then
            if  sender == down_bt and choumaIndex>1 then
                choumaIndex = (choumaIndex or 0) -1
                local amount = amountList[choumaIndex]
                SliderSetPosition(amount)

            elseif  sender == up_bt and choumaIndex< split_num then
                choumaIndex = (choumaIndex or 0) +1
                local amount = amountList[choumaIndex]
                SliderSetPosition(amount)

            elseif sender == sure_bt then
                SliderSetPosition(amountList[1] )

                choumaIndex = choumaIndex or 0
                sure_bt:setVisible(false)
                morebase_slider:setVisible(false)

                PaiJiuSendHandle:addBase(choumalist[choumaIndex])   --给服务器传下多少筹码的函数

            end
        end

    end

    sure_bt:addTouchEventListener(touchEvent)
    up_bt:addTouchEventListener(touchEvent)
    down_bt:addTouchEventListener(touchEvent)

    return sure_bt
end

--按照传入的分隔符，切割字符串
function LuaSplit(str, split_char)
    if str == "" or str == nil then
        return {};
    end
    local split_len = string.len(split_char)
    local sub_str_tab = {};
    local i = 0;
    local j = 0;
    while true do
        j = string.find(str, split_char,i+split_len);--从目标串str第i+split_len个字符开始搜索指定串
        if string.len(str) == i then
            break;
        end

        if j == nil then
            table.insert(sub_str_tab,string.sub(str,i));
            break;
        end;


        table.insert(sub_str_tab,string.sub(str,i,j-1));
        i = j+split_len;
    end
    return sub_str_tab;
end

function ControlPlaneOperator:showInviteReadyExitBtn(tag, flag)
    -- tag：0-全显示，1-隐藏准备，2-全隐藏，3-只显示准备, 4-只显示退出房间按钮
    -- flag：true-邀请好友按钮不可点击
    -- dump(tag, "showInviteReadyExitBtn----------")
    if flag == true then
        self.btn_invite:setTouchEnabled(false)
        self.btn_copy:setTouchEnabled(false)
    else
        self.btn_invite:setTouchEnabled(true)
        self.btn_copy:setTouchEnabled(true)
    end
    -- if isGoldGame==0 then
    --     self.btn_ready:setPosition(self.readypos)
    --     if tag==3 or tag==0 then
    --         self.btn_stand:setPosition(self.standpos)
    --     else
    --         self.btn_stand:setPosition(cc.p(self.standpos.x+160,self.standpos.y))
    --     end
    -- else
    --     self.btn_ready:setPosition(cc.p(self.readypos.x-160,self.readypos.y))
    -- end

    -- print("show ready ----------------------", tag, debug.traceback())
    if tag == 1 then
        self.btn_invite:setVisible(true)
        self.btn_copy:setVisible(true)
        self.btn_ready:setVisible(false)
        self.btn_stand:setVisible(false)
        self.btn_exit_room:setVisible(false)
    elseif tag == 2 then
        self.btn_invite:setVisible(false)                                       
        self.btn_copy:setVisible(false)
        self.btn_ready:setVisible(false)
        self.btn_exit_room:setVisible(false)
    elseif tag == 3 then
        self.btn_invite:setVisible(false)
        self.btn_copy:setVisible(false)
        self.btn_ready:setVisible(true)
        self.btn_exit_room:setVisible(false)
    elseif tag == 0 then
        self.btn_invite:setVisible(true)
        self.btn_copy:setVisible(true)
        self.btn_ready:setVisible(true)
        self.btn_exit_room:setVisible(false)
    elseif tag == 4 then
        self.btn_invite:setVisible(false)
        self.btn_copy:setVisible(false)
        self.btn_ready:setVisible(false)
        self.btn_exit_room:setVisible(false)
    end
end

function ControlPlaneOperator:showInviteBtnText(flag)
    -- tag：0-邀请好友；1-坐下；2-站起
    if flag == 1 then
        self.btn_invite:setVisible(false)
        self.btn_copy:setVisible(false)
        self.btn_sit:setVisible(true)
        self.btn_stand:setVisible(false)
    elseif flag == 2 then
        self.btn_invite:setVisible(false)
        self.btn_copy:setVisible(false)
        self.btn_sit:setVisible(false)
        self.btn_stand:setVisible(true)
    else
        self.btn_invite:setVisible(true)
        self.btn_copy:setVisible(true)
        self.btn_sit:setVisible(false)
        self.btn_stand:setVisible(false)
    end
end

function ControlPlaneOperator:loadCallTimesPanel(flag, timesCount, timesFenArray)
    if flag == true then
        self.call_times_panel:removeAllChildren()

        function btn_times_click(sender, event)
            if event == TOUCH_EVENT_ENDED then
                SoundUtils:playEffect("click")
                local value = sender:getTag()
                PaiJiuSendHandle:CLI_USER_TIMES(value)
                GamePlaneOperator:loadCallTimesPanel(false)
            end
        end
        self:showCallDaoTitle()
        local btn_times_width = self.btn_times:getContentSize().width
        -- local btn_times_height = btn_times:getContentSize().height

        local call_times_panel_width = self.call_times_panel:getContentSize().width
        local call_times_panel_height = self.call_times_panel:getContentSize().height
        local ori_x = (call_times_panel_width - (timesCount*btn_times_width+(timesCount-1)*20)) / 2 + btn_times_width / 2
        local ori_y = call_times_panel_height - 150
        for i=1, timesCount do
            local new_btn_times = self.btn_times:clone()
            local new_txt_times = new_btn_times:getChildByName("txt_times")
            new_txt_times:setString(tostring(timesFenArray[i]).."分")
            new_btn_times:setTag(timesFenArray[i])
            new_btn_times:setVisible(true)
            self.call_times_panel:addChild(new_btn_times)
            new_btn_times:setPosition(ori_x, ori_y)
            new_btn_times:setTouchEnabled(true)
            new_btn_times:addTouchEventListener(btn_times_click)
            ori_x = ori_x + btn_times_width + 30
        end
        self.call_times_panel:setVisible(true)
        self.txt_dao_title:setVisible(true)
    else
        self.call_times_panel:setVisible(false)
        self.txt_dao_title:setVisible(false)
    end
end

function ControlPlaneOperator:showCardGroups(panel, isShow)
    if not panel then
        --todo
        return
    end

    if not isShow then
        --todo
        self:showCardGroupType(panel, isShow)

        return
    end

    if #PJ_CARDS_SELECTED ~= 2 or #PJ_AVAI_CARD_GROUPS == 0 then
        --todo
        return
    end

    local card1 = PJ_CARDS_SELECTED[1]
    local card2 = PJ_CARDS_SELECTED[2]

    local groups = {}

    local group1 = {}
    for i,v in ipairs(PJ_AVAI_CARD_GROUPS) do
        if #v.cards == 2 then
            --todo
            if (v.cards[1] == card1 and v.cards[2] == card2) or (v.cards[2] == card1 and v.cards[1] == card2) then
                --todo
                group1.type = v.type
                group1.point = v.point
                group1.card1 = card1
                group1.card2 = card2

                table.insert(groups, group1)

                break
            end
        end
    end

    if #PJ_HANDCARDS == 4 then
        --todo
        local otherCards = {}
        local isExist1 = false
        local isExist2 = false
        for i,v in ipairs(PJ_HANDCARDS) do
            if not isExist1 and v == card1 then
                --todo
                isExist1 = true
            else
                if not isExist2 and v == card2 then
                    isExist2 = true
                else
                    table.insert(otherCards, v)
                end
            end
        end

        if #otherCards == 2 then
            --todo
            card1 = otherCards[1]
            card2 = otherCards[2]

            local group2 = {}
            for i,v in ipairs(PJ_AVAI_CARD_GROUPS) do
                if #v.cards == 2 then
                    --todo
                    if (v.cards[1] == card1 and v.cards[2] == card2) or (v.cards[2] == card1 and v.cards[1] == card2) then
                        --todo
                        group2.type = v.type
                        group2.point = v.point
                        group2.card1 = card1
                        group2.card2 = card2

                        table.insert(groups, group2)

                        break
                    end
                end
            end
        end
    end

    dump(groups, "test 0131")
    self:showCardGroupType(panel, isShow, groups)
end

function ControlPlaneOperator:showCardGroupType(panel, isShow, groups)
    local groupType_lb1 = panel:getChildByName(CHILD_NAME_GROUP_TYPE_1)
    local groupType_lb2 = panel:getChildByName(CHILD_NAME_GROUP_TYPE_2)

    if groupType_lb1 and groupType_lb2 then
        --todo
        dump(groups, "test 0131 1")
        if not isShow then
            --todo
            groupType_lb1:setVisible(false)
            groupType_lb2:setVisible(false)

            return
        end

        if #groups == 0 then
            --todo
            return
        end

        groupType_lb1:setVisible(true)

        local group1 = groups[1]
        --groupType_lb1:setString(LoadCard.changeCardsString(group1.card1, group1.card2))

        if group1.type > PJ_GROUP_TYPE_SPE or group1.type == 0 then
            --todo
            local _, count = string.gsub(tostring(PJ_GROUP_TYPE[group1.type]), "[^\128-\193]", "")
            --groupType_lb1:setScaleX(count/2)
            groupType_lb1:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(PJ_GROUP_TYPE[group1.type])]..".png")
        else
            local _, count = string.gsub(tostring(PJ_GROUP_TYPE[group1.type] .. PJ_GROUP_POINT[group1.point]), "[^\128-\193]", "")
            --groupType_lb1:setScaleX(count/2)
            groupType_lb1:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(PJ_GROUP_TYPE[group1.type] .. PJ_GROUP_POINT[group1.point])]..".png")
        end

        if #groups > 1 then
            --todo
            local group2 = groups[2]

            groupType_lb2:setVisible(true)
            --groupType_lb2:setString(LoadCard.changeCardsString(group2.card1, group2.card2))

            if group2.type > PJ_GROUP_TYPE_SPE or group2.type == 0 then
                --todo
                local _, count = string.gsub(tostring(PJ_GROUP_TYPE[group2.type]), "[^\128-\193]", "")
                --groupType_lb2:setScaleX(count/2)
                groupType_lb2:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(PJ_GROUP_TYPE[group2.type])]..".png")
            else
                local _, count = string.gsub(tostring(PJ_GROUP_TYPE[group2.type] .. PJ_GROUP_POINT[group2.point]), "[^\128-\193]", "")
                --groupType_lb2:setScaleX(count/2)
                groupType_lb2:loadTexture(TpackageName .. "/images/cardname/"..PJ_CARD_TYPE[tostring(PJ_GROUP_TYPE[group2.type] .. PJ_GROUP_POINT[group2.point])]..".png")
            end
        end
    end
end

function ControlPlaneOperator:showOutCardButtons(isShow)
    -- 目前屏蔽提示按钮
    self.btn_open:setVisible(isShow)
    if GAME_MODE == "大牌九" then
        self.btn_prompt:setVisible(isShow)
        self.btn_prompt:addTouchEventListener(function (sender, event)
            if event == TOUCH_EVENT_ENDED then
                SoundUtils:playEffect("click")
                --dump("------- 22222 ---------")
                --self:showPromptFunc()
                local playerType = PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]]
                GamePlaneOperator:setCardRecover() --判断是否已经将牌搓开
                GamePlaneOperator:showPromptCards(playerType)
            end
        end)
    end
end

function ControlPlaneOperator:showIpCheck(isShow)
    if not isShow then
        self.ip_panel:setVisible(false)
    else
        local flag = false
        local lv_same_ip = self.ip_panel:getChildByName("lv_same_ip")
        local ly_ip_Item = self.ip_panel:getChildByName("ly_ip_Item")
        local ip_tbl = {}
        for old_uid, old_ip in pairs(PJ_IP_TABLE) do
            if ip_tbl[old_ip] == nil then
                ip_tbl[old_ip] = {}
            end
            table.insert(ip_tbl[old_ip], old_uid)
        end
        dump("------------ xx -------------")
        dump(PAIJIU_USERINFO_TABLE, "------- PAIJIU_USERINFO_TABLE -------")
        lv_same_ip:removeAllChildren()
        for ip, uid_tble in pairs(ip_tbl) do
            if #uid_tble > 1 then
                for _, uid in ipairs(uid_tble) do
                    dump(uid, "-- 相同IP uid ---")
                    dump(ip, "-- 相同IP ip ---")
                    local new_ip_item = ly_ip_Item:clone()
                    local txt_name = new_ip_item:getChildByName("txt_name")
                    local txt_ip = new_ip_item:getChildByName("txt_ip")
                    txt_name:setString(tostring(PAIJIU_USERINFO_TABLE[uid].nick))
                    txt_ip:setString(tostring(ip))
                    new_ip_item:setVisible(true)
                    lv_same_ip:pushBackCustomItem(new_ip_item)
                    dump("--- 有相同IP ----")
                    flag = true
                end
            end
        end

        -- 自己坐下时显示
        -- if PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] ~= nil and flag then
        --     self.ip_panel:setVisible(true)
        --     SCENENOW["scene"]:performWithDelay(function()
        --         self.ip_panel:setVisible(false)
        --     end, 2)
        -- end
    end

end

function ControlPlaneOperator:showGuoChoosePanel(isShow, _type)
    -- type:
    -- 0：不切与续锅
    -- 1：切锅
    dump(_type, "----------- showGuoChoosePanel _type: ")
    if  not isShow then
        self.guo_choose_panel:setVisible(false)
    else
        self.guo_choose_panel:setVisible(true)
        local btn_no_cute = self.guo_choose_panel:getChildByName("btn_no_cute")
        local txt_continue = btn_no_cute:getChildByName("txt_continue")
        local txt_no_cute = btn_no_cute:getChildByName("txt_no_cute")
        if _type then
            --dump("0000000000000000")
            txt_no_cute:setVisible(false)
            txt_continue:setVisible(true)
        else
            --dump("11111111111111111")
            txt_no_cute:setVisible(true)
            txt_continue:setVisible(false)
        end
    end
end

function ControlPlaneOperator:showDownBankBtn(show)
    self.guo_choose_panel:getChildByName("shangzhuang"):setVisible(false)
    self.guo_choose_panel:getChildByName("bushangzhuang"):setVisible(false)
    local positionY = show and 140 or -400
    self.guo_choose_panel:getChildByName("btn_cute"):setVisible(true)
                                                    :setPositionY(positionY)
    self.guo_choose_panel:getChildByName("btn_no_cute"):setVisible(true)
                                                       :setPositionY(positionY)
    self.guo_choose_panel:getChildByName("btn_no_cute"):getChildByName("txt_continue"):setVisible(false)
    self.guo_choose_panel:setVisible(true)
end

function ControlPlaneOperator:callGuoPanel(is_show, guoBetLimit)
    if not is_show then
        self.call_guo_panel:setVisible(false)
        self.txt_dao_title:setVisible(false)
    else
        self.curGuoBetLimit = guoBetLimit or 60
        local txt_slider_number = self.call_guo_panel:getChildByName("txt_slider_number")
        local slider_guo = self.call_guo_panel:getChildByName("slider_guo")

        -- 滑动条显示数字
        self.minSlidernNum = 0
        local guoNum = GUODI_NUMBER

        if guoNum == 200 then
            if CALL_TIMES_COUNT == 1 or CALL_TIMES_COUNT == 2 then
                self.minSlidernNum = 50*BASE_CHIP
            end
        elseif guoNum == 100 then
            if CALL_TIMES_COUNT == 1 or CALL_TIMES_COUNT == 2 then
                self.minSlidernNum = 30*BASE_CHIP
            end
        elseif guoNum == 80 then
            if CALL_TIMES_COUNT == 1 then
                self.minSlidernNum = 30*BASE_CHIP
            elseif CALL_TIMES_COUNT == 2 then
                self.minSlidernNum = 20*BASE_CHIP
            end
        elseif guoNum == 60 then 
            if CALL_TIMES_COUNT == 1 or CALL_TIMES_COUNT == 2 then
                self.minSlidernNum = 20*BASE_CHIP
            end
        end

        slider_guo:setPercent(0)
        txt_slider_number:setString(self.minSlidernNum)
        txt_slider_number:setVisible(true)

        --得到自己此时还剩的筹码
        local isSmallNow = false
        local myGold = PAIJIU_USERINFO_TABLE[USER_INFO["uid"]]["coins"]
        if PAIJIU_USERINFO_TABLE[USER_INFO["uid"]]["daoArray"] and #PAIJIU_USERINFO_TABLE[USER_INFO["uid"]]["daoArray"] > 0 then
            for k,v in pairs(PAIJIU_USERINFO_TABLE[USER_INFO["uid"]]["daoArray"]) do
               myGold = myGold - v
            end
            isSmallNow = myGold <= self.minSlidernNum
        else
            isSmallNow = myGold <= self.minSlidernNum
        end

        if isNewGuo and CALL_TIMES_COUNT == DAO_COUNT then
            slider_guo:setPercent(100)
            txt_slider_number:setString(guoBetLimit)  
        end

        if isSmallNow then
            slider_guo:setPercent(((myGold - myGold%5)/myGold)*100)
            txt_slider_number:setString(myGold - myGold%5)
        end

        -- 滑动条事件
        slider_guo:addEventListener(function (sender, eventType)
            if eventType == ccui.SliderEventType.percentChanged then
                local perValue = sender:getPercent()
                local numNow = math.ceil(perValue * guoBetLimit * 0.01)

                --限制滑动范围写法
                -- if self.minSlidernNum <= numNow then
                --     if CALL_TIMES_COUNT == 1 and perValue == 0 then
                --         txt_slider_number:setString(tostring(1))
                --     else
                --         local now_number = math.ceil(perValue * guoBetLimit * 0.01)
                --         txt_slider_number:setString(tostring(now_number))
                --     end
                -- else
                --     sender:setPercent(self.minSlidernNum/guoBetLimit * 100)
                --     local perValue1 = sender:getPercent()
                --     local now_number1 = math.ceil(perValue1 * guoBetLimit * 0.01)
                --     txt_slider_number:setString(tostring(now_number1))
                -- end

                
                if self.minSlidernNum > guoBetLimit then
                    local now_number = math.ceil(perValue * guoBetLimit * 0.01)
                    txt_slider_number:setString(tostring(now_number))
                else
                    local now_number = math.ceil(perValue * (guoBetLimit-self.minSlidernNum) * 0.01)
                    txt_slider_number:setString(tostring(now_number)+self.minSlidernNum)
                end

                if isNewGuo and CALL_TIMES_COUNT == DAO_COUNT then
                    sender:setPercent(100)
                    txt_slider_number:setString(tostring(guoBetLimit))
                end

                if isSmallNow then
                    sender:setPercent(((myGold - myGold%5)/myGold)*100)
                    txt_slider_number:setString(myGold - myGold%5)
                end


                local temp = tonumber(txt_slider_number:getString())
                if temp%5 ~= 0 then
                    local num = temp -temp%5
                    if num <= myGold then
                        txt_slider_number:setString(tostring(num))
                    end
                end
            end
        end)

        -- 确认按钮
        local btn_slider_sure = self.call_guo_panel:getChildByName("btn_slider_sure")
        btn_slider_sure:addTouchEventListener(function(sender, event)
            if event == TOUCH_EVENT_ENDED then
                SoundUtils:playEffect("click")
                local now_confirm_number = tonumber(txt_slider_number:getString())
                PaiJiuSendHandle:CLI_USER_TIMES(now_confirm_number)
                self:callGuoPanel(false)
            end
        end)

         -- 显示第几道下注
         self:showCallDaoTitle()
         self.call_guo_panel:setVisible(true)

    end
end

function ControlPlaneOperator:showCallDaoTitle()
    -- 显示第几道下注
    local show_str = ""
    if CALL_TIMES_COUNT == 1 then
        show_str = "一"
    elseif CALL_TIMES_COUNT == 2 then
        show_str = "二"
    elseif CALL_TIMES_COUNT == 3 then
        show_str = "三"
    end
    self.txt_dao_title:setString("第"..show_str.."道下注")
    self.txt_dao_title:setVisible(true)
end

function ControlPlaneOperator:addGuoNumber(number)
    local now_guo_number = tonumber(self.txt_guo:getString()) + number
    self.txt_guo:setString(now_guo_number)
end

function ControlPlaneOperator:showGuoDi(number)
    self.txt_guo:setString(tostring(number))
end

function ControlPlaneOperator:showBuyCoinBotton(isShow)
    self.btn_buyCoin:setVisible(isShow)
end

function ControlPlaneOperator:getIntPart(x)
    if x <= 0 then
       return math.ceil(x);
    end
    
    if math.ceil(x) == x then
       x = math.ceil(x);
    else
       x = math.ceil(x) - 1;
    end
    return x;
end

function ControlPlaneOperator:showQieguo()
    local guo_pos=(img_guo:getParent()):convertToWorldSpace(img_guo:getPosition())
    local play_pos=PLAYER_HEADS_POSITION_TABLE[BANKER_UID]
    chips=self.txt_guo:getString()
    local chipCount=self:getIntPart((math.sqrt(chips*chips))/10)
    local chipRemainder=(math.sqrt(chips*chips))%10

    SCENENOW["scene"]:performWithDelay(function()
        local img_chips = img_guo:getParent():getParent():getChildByName("img_chips")
        if chipCount>20 then
            chipCount=20
        end
        guo_pos=img_guo:getParent():getParent():convertToNodeSpace(guo_pos)
        play_pos=img_guo:getParent():getParent():convertToNodeSpace(play_pos)
        for i=0,chipCount+1 do
            if i==chipCount and chipRemainder==0 then
                break;
            end
            local new_img_chips=img_chips:clone()
            if i==chipCount then
                new_img_chips:getChildByName("txt_chip"):setString(chipRemainder)
            else
                if isGoldGame==0 then
                    new_img_chips:getChildByName("txt_chip"):setString("")
                else
                    new_img_chips:getChildByName("txt_chip"):setString(10)
                end
            end
            new_img_chips:setPosition(guo_pos)
            img_guo:getParent():getParent():addChild(new_img_chips)
            local time=(math.sqrt((guo_pos.x-play_pos.x)*(guo_pos.x-play_pos.x)+(guo_pos.y-play_pos.y)*(guo_pos.y-play_pos.y)))/2000
            local ondelayAction = cc.DelayTime:create(0.02*i)
            local moveAction = cc.MoveTo:create(time,play_pos)
            local delayAction = cc.DelayTime:create(0.2)
            local seq = cc.Sequence:create(ondelayAction,moveAction,delayAction,cc.RemoveSelf:create())
            new_img_chips:runAction(seq)
        end
    end,1.7)
end

function ControlPlaneOperator:moveGuo(flag)
    --self.txt_guo:setString("0")
    if flag then
        img_guo:setPosition(self.original_pos)
        return
    end
    local guo_pos=(img_guo:getParent()):convertToWorldSpace(img_guo:getPosition())
    guo_pos=img_guo:getParent():getParent():convertToNodeSpace(guo_pos)
    local time=(math.sqrt((guo_pos.x-self.original_pos.x)*(guo_pos.x-self.original_pos.x)+(guo_pos.y-self.original_pos.y)*(guo_pos.y-self.original_pos.y)))/2000
    local moveAction = cc.MoveTo:create(time,self.original_pos)
    img_guo:runAction(moveAction)
end

return ControlPlaneOperator