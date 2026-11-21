local LayerShuffling = require(TpackageName .. ".LayerShuffling")
local ControlPlaneOperator = class("ControlPlaneOperator")

function ControlPlaneOperator:init()
	--print('---init----',debug.traceback())
    self.btn_ready = SanGongPanel.hall_plane.btn_ready--准备
    self.share_btn = SanGongPanel.hall_plane.share_btn--微信邀请
    self.copy_btn = SanGongPanel.hall_plane.copy_btn--复制房间号
    self.btn_check_group_result = SanGongPanel.hall_plane.btn_check_group_result--查看总结算
    self.bet_plane = SanGongPanel.hall_plane.bet_plane--下注分数
    self.grab_banker_plane = SanGongPanel.hall_plane.grab_banker_plane--抢庄
    self.xiazhu = SanGongPanel.game_plane.xiazhu--下注滑动条
    self.btn_start = SanGongPanel.hall_plane.btn_start--开始游戏
    self.img_dichi = SanGongPanel.hall_plane.img_dichi--底池
    self:initDiChi()

    --下注功能
    self.btn_xiazhu = self.xiazhu.btn_xiazhu
    self.check_bei_txt = self.xiazhu.btn_xiazhu.check_bei_txt
    self.check_bei_txt = self.xiazhu.bei_txt
    self.btn_laman = self.xiazhu.btn_laman
    self.Slider_1 = self.xiazhu.Slider_1
    self.bei_txt = self.xiazhu.bei_txt
    self.bei_txt_max = self.xiazhu.bei_txt_max

    --固定下注
    self.xiazhu_list = SanGongPanel.hall_plane.xiazhu_list
    self.img_xiazhu_list_1 = self.xiazhu_list.img_xiazhu_list_1
    self.txt_xiazhu_list_1 = self.xiazhu_list.img_xiazhu_list_1.txt_xiazhu_list_1
    self.img_xiazhu_list_2 = self.xiazhu_list.img_xiazhu_list_2
    self.txt_xiazhu_list_2 = self.xiazhu_list.img_xiazhu_list_2.txt_xiazhu_list_2
    self.img_xiazhu_list_3 = self.xiazhu_list.img_xiazhu_list_3
    self.txt_xiazhu_list_3 = self.xiazhu_list.img_xiazhu_list_3.txt_xiazhu_list_3
    self.img_xiazhu_list_4 = self.xiazhu_list.img_xiazhu_list_4
    self.txt_xiazhu_list_4 = self.xiazhu_list.img_xiazhu_list_4.txt_xiazhu_list_4
	--self.guanZhan_img = SanGongPanel.hall_plane.guanZhan_img--观战
	
	--self.btn_voice = SanGongPanel.hall_plane.btn_voice
	--self.btn_chat = SanGongPanel.hall_plane.btn_chat

    self.btn_bet = SanGongPanel.hall_plane.btn_bet--抢庄
    self.stage_img = SanGongPanel.hall_plane.stage_img--倒计时
    self.btn_fanpai = SanGongPanel.hall_plane.btn_fanpai--翻牌
    self.btn_outcard = SanGongPanel.hall_plane.btn_outcard--搓牌之后 亮牌

    self.Slider_1:addEventListener(handler(self, self.onClickSlider))
    self.btn_xiazhu:onClick(handler(self, self.onClickXiaZhu), true)
    self.btn_laman:onClick(handler(self, self.onClickLaMan), true)
    self.img_xiazhu_list_1:onClick(handler(self, self.onClickXiaZhu), true)
    self.img_xiazhu_list_2:onClick(handler(self, self.onClickXiaZhu), true)
    self.img_xiazhu_list_3:onClick(handler(self, self.onClickXiaZhu), true)
    self.img_xiazhu_list_4:onClick(handler(self, self.onClickXiaZhu), true)

    self.beilv = 1
    self._xiaZhuNumber = 5
    self._xiaZhuMin = 5
    self.check_bei_txt:setString(0)
    self.bei_txt:setString(0)
    self.bei_txt_max:setString(0)
    self.xiazhu:setVisible(false)
    self.xiazhu_list:setVisible(false)

    self.btn_outcard:onClick(function()
        GamePlaneOperator:hideCardNumCountEffect()
        local Mychoice = {0,0,0}       
        SanGongSendHandle:sendMycards(Mychoice)
    end,true)
    self.btn_fanpai:onClick(function()
        self:showControlButtons(5)
        GamePlaneOperator:turnCards()
    end,true)
    self.btn_start:onClick(function()
        SanGongSendHandle:StartGame()
        -- self.btn_start:setVisible(false)
    end,true)
    self.btn_ready:onClick(function()
        SanGongSendHandle:readyNow(1)
        self.btn_ready:setVisible(false)
    end,true)
    self.btn_check_group_result:onClick(function()
        local GameResult = SCENENOW["scene"]:getChildByName("gameresultScene")
        if  GameResult then
            GameResult:setVisible(true)
        end
    end,true)
   
   
   self:setGuanZhanVisible(false)
end

function ControlPlaneOperator:clearGameDatas(stage)

end

function ControlPlaneOperator:RemaidStartGame(flag)
    if self.btn_start then
		if g_isWatch == 0 then
			flag = false
        end
        self.btn_start:setVisible(flag)
    end
end

--观战
function ControlPlaneOperator:setGuanZhanVisible(flag)
	
    SanGongPanel.hall_plane.guanZhan_img:setVisible(flag)
    flag = not flag
    SanGongPanel.hall_plane.btn_voice:setVisible(flag)
    SanGongPanel.hall_plane.btn_chat:setVisible(flag)
end

function ControlPlaneOperator:showCheckResultButton(flag)
    self.btn_check_group_result:setVisible(flag)
    if  self.btn_return_to_hall then
        self.btn_return_to_hall:setVisible(flag)
    end
    if flag == true then
        LayerShuffling:removeScene()
        self.btn_ready:setVisible(false)
    end
end

function ControlPlaneOperator:loadBetButtons(base,canChooseBases,tuiZhuBase, base_chip)
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
    self.beilv = base_chip or 1
    self._xiaZhuNumber = base[1] / self.beilv
    self._xiaZhuMin = base[1] / self.beilv
    --self.Slider_1:setPercent(self._xiaZhuNumber)
	--修复初始化滑动条显示不对的BUG
	local cfg = GAME_CHIP_CONFIG or {}
	local betCfgNum = table.nums(cfg)
	local maxScore = tonumber(cfg[betCfgNum]) or self._xiaZhuNumber
	local percentValue = math.floor((self._xiaZhuNumber/maxScore)*100)
	self.Slider_1:setPercent(percentValue)
	--print('-----^^^^^^^^^^^^^^^^^^^^^^^^^^^----',self._xiaZhuNumber, percentValue,debug.traceback())
	
	
    self._xiaZhuNumber = self._xiaZhuNumber * self.beilv
    self.bei_txt:setString(self._xiaZhuNumber)
    self.bet_plane:removeAllChildren() 
    local bt_num = table.nums(base)
    local middleIndex = (bt_num+1)/2
    local planeMiddlePositionX = self.bet_plane:getContentSize().width/2
    local planeMiddlePositionY = self.btn_bet:getContentSize().height/2
    self.xiazhu:show()
    local buttonInterval = 230
    if bt_num > 0 then
        for i = 1, bt_num do
            local tempScore = tonumber(base[i]) or 0
            if tempScore < 1 then break end
            local btn_bet = self.btn_bet:clone()
            btn_bet:setVisible(true)
            btn_bet:setPosition(planeMiddlePositionX + buttonInterval*(i-middleIndex),planeMiddlePositionY)
            local bet_times_txt = btn_bet:getChildByName("bet_times_txt")
            tempScore = tempScore
            bet_times_txt:setString(tostring(tempScore).."分")        
            self.bet_plane:addChild(btn_bet)
            if canChooseBasesExist[base[i]] then
                btn_bet:onClick(function()
                    self._xiaZhuNumber = base[i]
                    self:onClickXiaZhu()
                end)
            else
                btn_bet:setBright(false) --setColor(cc.c3b(140,140,140))
            end
       end  
    end
end

function ControlPlaneOperator:loadXiaZhu(base_chip)
    dump(base,"显示下注面板base")
    self.beilv = base_chip or 1

    self._xiaZhuNumber = initialChip
    self._xiaZhuMin = initialChip
    self:initXiazhuNum()
    local maxScore = maxChip

    local percentValue = math.floor((self._xiaZhuNumber/(maxScore-self._xiaZhuMin)))*100

    self.Slider_1:setPercent(percentValue)
    self.check_bei_txt:setString(self._xiaZhuNumber)

    self.bei_txt:setString(self._xiaZhuMin) --最低
    self.bei_txt_max:setString(maxScore) --最高

    self.xiazhu:setVisible(true)
end


--[[
旧设计
function ControlPlaneOperator:onClickSlider(sender,eventType)
    if eventType == ccui.SliderEventType.percentChanged then
        local minInt = self._xiaZhuMin
        local curNum = tonumber(self.bei_txt:getString())
        local amount = sender:getPercent() / minInt
        amount = math.round(amount)
        amount = amount * minInt
        if amount < minInt then
            amount = minInt
        end
        --sender:setPercent(amount)
        
        --self._xiaZhuNumber = amount * self.beilv
        --self.bei_txt:setString(self._xiaZhuNumber)
        
        --处理滑动条不能滑动到最大值的问题
        local cfg = GAME_CHIP_CONFIG or {}
        local betCfgNum = table.nums(cfg)
        local maxScore = tonumber(cfg[betCfgNum]) or amount * self.beilv
        local rateScore = (maxScore-minInt)/100
        local tempScore = math.floor(rateScore*sender:getPercent() + minInt)
        
        self._xiaZhuNumber = tempScore
        self.bei_txt:setString(self._xiaZhuNumber)
        
        --print('--ControlPlaneOperator:onClickSlider--',minInt,curNum,amount,self.beilv,self._xiaZhuNumber)
    end  
end
]]

function ControlPlaneOperator:onClickSlider(sender,eventType)
    if eventType == ccui.SliderEventType.percentChanged then
        local minInt = self._xiaZhuMin
		local maxScore = maxChip
        -- local rateScore = (maxScore-minInt)/100
        local rateScore = maxScore-minInt
        local getPercent = sender:getPercent()
		local tempScore = math.ceil(rateScore*getPercent/100 + minInt)--math.ceil小数点相乘会有小数点导致末位变1
        print(maxScore, minInt, rateScore, getPercent, tempScore, rateScore*getPercent + minInt, "------415")
        if tempScore > maxScore then
            tempScore = maxScore
        end
        self._xiaZhuNumber = tempScore
        self.check_bei_txt:setString(self._xiaZhuNumber)
    end  
end
function ControlPlaneOperator:hideClickXiaZhu()
    self.bet_plane:setVisible(false)
    self.bet_plane:removeAllChildren()
    self.xiazhu:setVisible(false)
    self.xiazhu_list:setVisible(false)
end
function ControlPlaneOperator:onClickXiaZhu(event)
    local sender = event.target
    if sender then
        local name = sender:getName()
        if name == 'img_xiazhu_list_1' then
            SanGongSendHandle:CLIENT_CMD_YA(USER_INFO["uid"], self.txt_xiazhu_list_1:getString()*100)
        elseif name == 'img_xiazhu_list_2' then
            SanGongSendHandle:CLIENT_CMD_YA(USER_INFO["uid"], self.txt_xiazhu_list_2:getString()*100)
        elseif name == 'img_xiazhu_list_3' then
            SanGongSendHandle:CLIENT_CMD_YA(USER_INFO["uid"], self.txt_xiazhu_list_3:getString()*100)
        elseif name == 'img_xiazhu_list_4' then
            SanGongSendHandle:CLIENT_CMD_YA(USER_INFO["uid"], self.txt_xiazhu_list_4:getString()*100)
        elseif name == 'btn_xiazhu' then
            dump(USER_INFO)
            dump(SANGONG_USERINFO_TABLE)
            local score = self._xiaZhuNumber
            local userInfo = SANGONG_USERINFO_TABLE[USER_INFO.uid] or {}
            if userInfo.gold and score > userInfo.gold then
                score = userInfo.gold
            end
            SanGongSendHandle:CLIENT_CMD_YA(USER_INFO["uid"], score*100)
        end
    end

end

function ControlPlaneOperator:onClickLaMan( )
    local score = (maxChip or 1)
    local userInfo = SANGONG_USERINFO_TABLE[USER_INFO.uid] or {}
    if userInfo.gold and score > userInfo.gold then
        score = math.floor(userInfo.gold)
    end
    SanGongSendHandle:CLIENT_CMD_YA(USER_INFO["uid"], score*100)
end

function ControlPlaneOperator:loadGrabBankerButtons(base,canChooseBases)
    -- local base = {5,10,15,20}
    dump(base, "----显示抢庄面板-----")
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
    self.grab_banker_plane:removeAllChildren()   
    local bt_num = table.nums(base)
    local middleIndex = (bt_num+1)/2
    local planeMiddlePositionX = self.grab_banker_plane:getContentSize().width/2
    local planeMiddlePositionY = self.btn_grab_banker_button:getContentSize().height/2
    local buttonInterval = 230
    local effect_imgs = {}
    for i = 1, bt_num do
        if base[i] == 0 then
            local btn_grab_banker_button = self.btn_grab_banker_button:clone():setVisible(true) 
            btn_grab_banker_button:setPosition( planeMiddlePositionX + buttonInterval*(i-middleIndex),planeMiddlePositionY)
            self.grab_banker_plane:addChild(btn_grab_banker_button)
            btn_grab_banker_button:onClick(function(event)
                SanGongSendHandle:qiang(base[i])
                self.grab_banker_plane:setVisible(false)
            end)
        else
            local btn_grab_banker_button = self.btn_bet:clone():setVisible(true)
            btn_grab_banker_button:setPosition( planeMiddlePositionX + buttonInterval*(i-middleIndex),planeMiddlePositionY)
            self.grab_banker_plane:addChild(btn_grab_banker_button)
            local bet_times_txt = self:seekChild(btn_grab_banker_button, "bet_times_txt")
            if  bt_num > 2 then
                bet_times_txt:setVisible(true)
                bet_times_txt:setString(tostring(base[i]).."倍")
            else
                local path = string.format( "%s/csb/GameSceneSector/btn_7.png", TpackageName)
                btn_grab_banker_button:loadTextures(path, "", "", 1) 
                bet_times_txt:setVisible(false)
            end
            if  canChooseBasesExist[base[i]] then
                btn_grab_banker_button:onClick(function(event)
                    SanGongSendHandle:qiang(base[i])
                    self.grab_banker_plane:setVisible(false)
                    GamePlaneOperator:setGrabBankerTimes(CARD_PLAYERTYPE_MY,base[i],true)
                end)
            else
                btn_grab_banker_button:setBright(false)
            end
        end
    end
end

function ControlPlaneOperator:showSitDownButton(index, flag)
    -- dump(flag,"开关showSitDownButton")
    -- self.plane:getChildByName("down_"..index):setVisible(flag)
end

function ControlPlaneOperator:downButtonInit(index, flag)
   
end

--准备，（抢庄）（加倍）（摊牌，提示，搓牌）  游戏操作按钮
function ControlPlaneOperator:showControlButtons(stage,flag, isShowXiaZhu)
    -- GAME_STATUS_STOP = 0,       //牌局已结束
    -- GAME_STATUS_YA,    //押注阶段
    -- GAME_STATUS_SEND_CARD,  //发牌阶段
    -- GAME_STATUS_OUT_CARD,  //出牌阶段
    -- GAME_STATUS_OPEN_CARD,  //开牌阶段
    -- GAME_STATUS_WAIT_STOP,  //等待停止时期
    local traceback = debug.traceback("", 2)
    print(stage,flag,"游戏阶段")
    print(GAME_STATE,"显示标记")
    dump(traceback,"----traceback------")
    if tolua.isnull( self.grab_banker_plane) or HEART_BEAT_TID ==0 then
        return
    end
    if  flag == false then
        self.btn_ready:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        self.xiazhu:setVisible(false)
        self.xiazhu_list:setVisible(false)
        self.btn_outcard:setVisible(false)
        self.btn_fanpai:setVisible(false)
        --self.out_card_plane:setVisible(false)
        LayerShuffling:removeScene()
        return
    end
    if  stage == 1 then   --准备阶段
        dump(GAME_STATE, "GAME_STATE0899=====")
        self.btn_start:setVisible(false)
        if   GAME_STATE  == GAME_STATUS_STOP or  GAME_STATE == GAME_STATUS_WAIT_STOP   then
            self.btn_ready:setVisible(true)
        end

        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        self.xiazhu:setVisible(false)
        self.xiazhu_list:setVisible(false)
        LayerShuffling:removeScene()
    elseif  stage == 2 then  --抢庄阶段
        self.btn_start:setVisible(false)
        self.btn_ready:setVisible(false)
        if  USERS_READY_STATE[USER_INFO["uid"]] and  USERS_READY_STATE[USER_INFO["uid"]] == 1   then
            self.grab_banker_plane:setVisible(true)
        end

        self.bet_plane:setVisible(false)
        self.xiazhu:setVisible(false)
        self.xiazhu_list:setVisible(false)
    elseif  stage == 3 then  --加注阶段
        self.btn_ready:setVisible(false)
        self.btn_start:setVisible(false)
        self.grab_banker_plane:setVisible(false)

        dump(USERS_READY_STATE[USER_INFO["uid"]], "USERS_READY_STATE[USER_INFO[uid]]")
        if  (USERS_READY_STATE[USER_INFO["uid"]] and  USERS_READY_STATE[USER_INFO["uid"]] == 1) or isShowXiaZhu then
            self.xiazhu:setVisible(true)
            self.bet_plane:setVisible(true)
            -- self.xiazhu_list:setVisible(true)
        else
            self.xiazhu:setVisible(false)
            self.xiazhu_list:setVisible(false)
            self.bet_plane:setVisible(false)
        end

        self.btn_fanpai:setVisible(false)
        self.btn_outcard:setVisible(false)
    elseif  stage == 4 then--下注之后
        self.btn_ready:setVisible(false)
        self.btn_start:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        self.xiazhu:setVisible(false)
        self.xiazhu_list:setVisible(false)
        if  USERS_READY_STATE[USER_INFO["uid"]] and  USERS_READY_STATE[USER_INFO["uid"]] == 1 then
            self.btn_fanpai:setVisible(true)
        end
        if g_360.anCard == 1 then
            GamePlaneOperator:showCuoPai()
        end
        self.btn_outcard:setVisible(false)
    elseif  stage == 5 then  --搓牌，翻牌之后
        self.btn_ready:setVisible(false)
        self.btn_start:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        LayerShuffling:removeScene()
        self.xiazhu:setVisible(false)
        self.xiazhu_list:setVisible(false)
        self.btn_fanpai:setVisible(false)
        if  USERS_READY_STATE[USER_INFO["uid"]] and  USERS_READY_STATE[USER_INFO["uid"]] == 1   then
            self.btn_outcard:setVisible(true)
        end
    end

end

function ControlPlaneOperator:hideCardKindTipButton()
end

function ControlPlaneOperator:showDiChi(num)

    local traceback = debug.traceback("", 2)
    print(self.diChiNum,"self.diChiNum")
    dump(traceback,"----traceback------")
    self.diChiNum = self.diChiNum + num
    self.img_dichi.dichiTxt:setString("奖池："..self.diChiNum)
    self.img_dichi:setVisible(true)
end

function ControlPlaneOperator:initDiChi(num)
    self.diChiNum = 0
    self.img_dichi.dichiTxt:setString("奖池："..self.diChiNum)
    self.img_dichi:setVisible(false)
end

function ControlPlaneOperator:initXiazhuNum()

    local minChip = initialChip
    local lefMedChip = math.ceil(maxChip / 4);
    local rigMedChip = math.ceil(maxChip / 2);
    local maxChip = maxChip

    self.txt_xiazhu_list_1:setString(minChip)
    self.txt_xiazhu_list_2:setString(lefMedChip)
    self.txt_xiazhu_list_3:setString(rigMedChip)
    self.txt_xiazhu_list_4:setString(maxChip)
end

return ControlPlaneOperator