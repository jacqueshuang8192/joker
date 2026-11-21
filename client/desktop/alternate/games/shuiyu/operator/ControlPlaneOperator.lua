local ControlPlaneOperator = class("ControlPlaneOperator")

function ControlPlaneOperator:init(plane)
     
    local planeWidth = plane:getContentSize().width
    --查看总结算按钮
    self.btn_check_group_result = plane:getChildByName("btn_check_group_result")
    self.btn_check_group_result:setVisible(false)

    self.btn_return_to_hall = plane:getChildByName("btn_return_to_hall")

    if  self.btn_return_to_hall then
        self.btn_return_to_hall:setVisible(false)
    end

    self.btn_sit_down = plane:getChildByName("btn_sit_down")
    self.btn_sit_down:setVisible(false)

    self.ready_plane = plane:getChildByName("ready_plane") 
    self.ready_plane:setVisible(false)
    
    self.btn_stand_up = self.ready_plane:getChildByName("btn_stand_up")
    -------------------
    self.btn_ready = self.ready_plane:getChildByName("btn_ready")

    self.btn_start = plane:getChildByName("btn_start")
    self.btn_start:setVisible(false)
    self.btn_start:setPositionX(planeWidth/2)

    ---------------抢庄系列
    self.grab_banker_plane = plane:getChildByName("grab_banker_plane") 
    self.grab_banker_plane:setVisible(false)

    self.btn_grab_banker_button = plane:getChildByName("btn_grab_banker_button") 

    -----------加倍
    self.bet_plane = plane:getChildByName("bet_plane")
    self.btn_bet = plane:getChildByName("btn_bet")
    -----------出牌
    self.out_card_plane = plane:getChildByName("out_card_plane")
    self.out_card_plane:setVisible(false)

    self.outCardPlaneMiddlePositionX = self.out_card_plane:getContentSize().width/2
    
    self.btn_xianjia = plane:getChildByName("btn_xianjia")
    self.btn_xianjia1 = self.btn_xianjia:getChildByName("btn1")
    self.btn_xianjia2 = self.btn_xianjia:getChildByName("btn2")

    self.btn1_txt = self.btn_xianjia1:getChildByName("btn1_txt")
    self.btn2_txt = self.btn_xianjia2:getChildByName("btn2_txt")
    --搓牌
    self.btn_cuopai = self.out_card_plane:getChildByName("btn_cuopai")

    --翻牌（出牌）
    self.btn_liangcards = self.out_card_plane:getChildByName("btn_liangcards")
    self.btn_liangcards_oriPositionX =  self.btn_liangcards:getPositionX()     

    self.btn_outcard = self.out_card_plane:getChildByName("btn_outcard")
    --提示
    self.btn_tip = self.out_card_plane:getChildByName("btn_tip")
    self.btn_tip:setVisible(false)  

    self.btn_sanpu = plane:getChildByName("btn_sanpu")
    self.btn_xianyu = plane:getChildByName("btn_xianyu")
    self.btn_xianyu1 = self.btn_xianyu:getChildByName("btn1")
    self.btn_xianyu2 = self.btn_xianyu:getChildByName("btn2")
    self.btn_xianyu3 = self.btn_xianyu:getChildByName("btn3")
    self.btn_xianyu4 = self.btn_xianyu:getChildByName("btn4")
    self.btn_jia = plane:getChildByName("btn_jia")
    self.btnjia_1 = self.btn_jia:getChildByName("btnjia_1")
    self.btnjia_2 = self.btn_jia:getChildByName("btnjia_2")
    self.btn_shuiyu = plane:getChildByName("btn_shuiyu")
    self.shuiyu_txt = self.btn_shuiyu:getChildByName("btn1_txt")

    local controlButtonsFunc = function(sender,event)

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
             
            if  sender == self.btn_tip then
                
                -- changed by zzy 去掉提示
                -- self.btn_tip:setTouchEnabled(false)
                -- GamePlaneOperator:countFanAndShow()
                -- changed by zzy end
                
            elseif  sender == self.btn_liangcards then

                self:showControlButtons(5)
                GamePlaneOperator:turnCards()

            elseif  sender == self.btn_outcard then
                --changed by zzy 2019-5-25 begain
                --发送已经选择弃牌的那张牌
                print("===发送已经选择弃牌的那张牌===")
                print("===发送已经选择弃牌的那张牌===")
                print("===发送已经选择弃牌的那张牌===")
                print("===发送已经选择弃牌的那张牌===")
                local uid = USER_INFO["uid"]
                local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
                local tempAllCardNodes = GamePlaneOperator:GetAllNode(playerType)
                local _current_QiPai_Index = 0
                for k,v in pairs(tempAllCardNodes) do
                    if v.font_pai_:getPositionY() > 0 then
                        _current_QiPai_Index = k
                        break
                    end
                end 
                print("===发送已经选择弃牌的那张牌===",_current_QiPai_Index)
                if _current_QiPai_Index > 0 and _current_QiPai_Index < 5 then 
                    local rand_card_value = CARD_DATAS[_current_QiPai_Index]
                    print("==rand_card_value==",rand_card_value)
                    if rand_card_value then
                        NiuNiuSendHandle:sendMycards(rand_card_value)
                        GAME_STATE = GAME_STATUS_STOP
                    end
                else
                    print("请重新选择一张弃牌！！！")
                end

                --changed by zzy 2019-5-25 end


                -- GamePlaneOperator:hideCardNumCountEffect()


                -- --  self:showControlButtons(5)
                -- -- GamePlaneOperator:showCuoPai(_,true)

                -- -- math.randomseed(tostring(os.time()):reverse():sub(1, 7))
                -- -- local rand_num = math.random(1 , #CARD_DATAS)
                -- -- local rand_card = CARD_DATAS[rand_num]

                -- -- NiuNiuSendHandle:sendMycards(rand_card)


                -- local uid = USER_INFO["uid"]
                -- local playerType = NIUNIU_PLAYERTYPE_TABLE[uid]
                -- local card_data = GamePlaneOperator:GetAllNode(playerType)
                -- local card_value = {}
                -- for k , v in pairs(card_data) do 
                --     print (v.cardUint_ , "---前端牌值--")
                --     if tonumber(v.cardUint_) == tonumber(rand_card) then
                --         v:removeSelf()
                --         v = nil
                --     else
                --         table.insert(card_value , v)
                --     end     
                -- end
                -- GamePlaneOperator:SetAllNode(playerType , card_value)


              

            elseif  sender == self.btn_cuopai then

                self:showControlButtons(5)
                GamePlaneOperator:showCuoPai(CARD_DATAS,true)

            elseif  sender == self.btn_start then

                NiuNiuSendHandle:StartGame()
                self.btn_start:setVisible(false)

            elseif  sender == self.btn_stand_up then

                NiuNiuSendHandle:standUp()

            elseif  sender == self.btn_ready then

                -- self.ready_plane:setVisible(false)
                NiuNiuSendHandle:readyNow(1)

            elseif  sender == self.btn_sit_down then

                local seat_id = -1
                NiuNiuSendHandle:sitDown(seat_id)

            elseif  sender == self.btn_return_to_hall then

                require(TpackageName..".NiuNiuUtils"):returnToHall()

            elseif  sender == self.btn_check_group_result then

                local GameResult = SCENENOW["scene"]:getChildByName("gameresultScene")
                if  GameResult then
                    GameResult:setVisible(true)
                end

            elseif sender == self.btn_sanpu or sender == self.btn_xianyu1 then 
                self:SendHeadCard(1)
            elseif sender == self.btn_xianyu2 then 
                self:SendHeadCard(2)
            elseif sender == self.btn_xianyu3 then 
                self:SendHeadCard(3)
            elseif sender == self.btn_xianyu4 then 
                self:SendHeadCard(4)
            elseif sender == self.btn_xianjia1 then
                self:SendZhuang(1)
            elseif sender == self.btn_xianjia2 then 
                self:SendZhuang(2)
            elseif sender == self.btnjia_1 then 
                self:SendXian(1)
            elseif sender == self.btnjia_2 then 
                self:SendXian(2)
            elseif sender == self.btn_shuiyu then 
                self:SendShuiYu()
            end

        end

    end

    self.btn_tip:addTouchEventListener(controlButtonsFunc)
    self.btn_liangcards:addTouchEventListener(controlButtonsFunc)
    self.btn_cuopai:addTouchEventListener(controlButtonsFunc)
    self.btn_start:addTouchEventListener(controlButtonsFunc)
    self.btn_stand_up:addTouchEventListener(controlButtonsFunc)
    self.btn_ready:addTouchEventListener(controlButtonsFunc)
    self.btn_sit_down:addTouchEventListener(controlButtonsFunc)
    self.btn_check_group_result:addTouchEventListener(controlButtonsFunc)
    self.btn_outcard:addTouchEventListener(controlButtonsFunc)
    self.btn_sanpu:addTouchEventListener(controlButtonsFunc)
    self.btn_xianyu1:addTouchEventListener(controlButtonsFunc)
    self.btn_xianyu2:addTouchEventListener(controlButtonsFunc)
    self.btn_xianyu3:addTouchEventListener(controlButtonsFunc)
    self.btn_xianyu4:addTouchEventListener(controlButtonsFunc)
    self.btn_xianjia1:addTouchEventListener(controlButtonsFunc)
    self.btn_xianjia2:addTouchEventListener(controlButtonsFunc)
    self.btnjia_1:addTouchEventListener(controlButtonsFunc)
    self.btnjia_2:addTouchEventListener(controlButtonsFunc)
    self.btn_shuiyu:addTouchEventListener(controlButtonsFunc)

    if  self.btn_return_to_hall then
        self.btn_return_to_hall:addTouchEventListener(controlButtonsFunc)
    end

    self.waiwei_choose_plane = plane:getChildByName("waiwei_choose_plane")
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


end


function ControlPlaneOperator:clearGameDatas(stage)
    
    if stage == 1 then
        self:showWaiWeiButton(false)
    elseif stage == 2 or stage == nil then
        self:showControlButtons(1,false)
    end

end

function ControlPlaneOperator:RemaidStartGame(flag)
    self.btn_start:setVisible(flag)
end


function ControlPlaneOperator:showWaiWeiButton(flag)

    self.waiwei_choose_plane:setVisible(flag)

    if  flag == true then
        for i = 1,4 do
            local bet_chip_txt = self.waiwei_choose_plane:getChildByName("bet_chip_txt_" .. i) 
            local bet_chip_bt =  self.waiwei_choose_plane:getChildByName("bet_chip_" .. i)

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
        local bet_chip_bt =  self.waiwei_choose_plane:getChildByName("bet_chip_" .. i)

        if  i == BETCOUNT then
            bet_chip_bt:setColor(cc.c3b(255,255,255))
        else
            bet_chip_bt:setColor(cc.c3b(120,120,120))
        end

    end
end


function ControlPlaneOperator:showCheckResultButton(flag)
    self.btn_check_group_result:setVisible(flag)

    if  self.btn_return_to_hall then
        self.btn_return_to_hall:setVisible(flag)
    end
    
    self:showControlButtons(1,false)

     if GAME_ROUND == GAME_TOTAL_ROUND and GAME_STATE == GAME_STATUS_STOP then
        self.btn_check_group_result:setVisible(false)
        self.btn_return_to_hall:setVisible(false)
    end
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

    self.bet_plane:removeAllChildren()   
    local bt_num = table.nums(base)
    
    local middleIndex = (bt_num+1)/2

    local planeMiddlePositionX = self.bet_plane:getContentSize().width/2
    local planeMiddlePositionY = self.bet_plane:getContentSize().height/2

    local buttonInterval = 180
    if bt_num > 0 then
    
        for i = 1, bt_num do



            local btn_bet = self.btn_bet:clone()
            local bet_times_txt = btn_bet:getChildByName("bet_times_txt")
            -- local img = btn_bet:getChildByName("img")
            -- local effect_img = btn_bet:getChildByName("effect_img")
            --       effect_img:setVisible(false)
                  
            btn_bet:setPosition(150+ planeMiddlePositionX + buttonInterval*(i-middleIndex),planeMiddlePositionY)
            btn_bet:setScale(0.8)
            btn_bet:setVisible(true)
            if base[i] == 0 then 
                bet_times_txt:setString("不抢")
                btn_bet:setVisible(false)
            else
                bet_times_txt:setString(tostring(base[i]) .. "倍")
            end 
          
             
            -- if  base[i] < 10 then
                -- bet_times_txt:setPositionX(103)
                -- img:setPositionX(118)
            -- else
                -- bet_times_txt:setPositionX(128)
                -- img:setPositionX(125)
            -- end

            -- if  tuiZhuBase == base[i] then

            --     local cross_effect_frame_1 = btn_bet:getChildByName("cross_effect_frame_1")
            --     local cross_effect_frame_2 = btn_bet:getChildByName("cross_effect_frame_2")

            --     local tuiZhuBaseEffect = cc.RepeatForever:create(
            --         cc.Sequence:create(
            --             cc.CallFunc:create(function() 
            --                 if cross_effect_frame_1:isVisible()  then
            --                     cross_effect_frame_1:setVisible(false)
            --                     cross_effect_frame_2:setVisible(true)
            --                 else
            --                     cross_effect_frame_1:setVisible(true)
            --                     cross_effect_frame_2:setVisible(false)                              
            --                 end
            --             end),
            --             cc.DelayTime:create(0.25)
            --         )
            --     )
            --     btn_bet:runAction(tuiZhuBaseEffect)

            -- end

            self.bet_plane:addChild(btn_bet)
           
            -- if  canChooseBasesExist[base[i]] then

                btn_bet:addTouchEventListener(function(sender,event)

                        if event == TOUCH_EVENT_BEGAN then
                            sender:setScale(0.6)
                        end

                        --触摸取消
                        if event == TOUCH_EVENT_CANCELED then
                            sender:setScale(0.8)
                        end

                        --触摸结束
                        if event == TOUCH_EVENT_ENDED then
                            sender:setScale(0.8)

                            NiuNiuSendHandle:addBase(base[i])

                            -- GamePlaneOperator:setBetTimes(CARD_PLAYERTYPE_MY,base[i],true)
                            self.bet_plane:setVisible(false)
                            self.bet_plane:removeAllChildren()   
                                
                        end

                    end)

            -- else

            --     btn_bet:setBright(false) --setColor(cc.c3b(140,140,140))

            -- end

       end
                     
    end
    
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
    local planeMiddlePositionY = self.grab_banker_plane:getContentSize().height/2

    local buttonInterval = 180
    
    local effect_imgs = {}

    for i = 1, bt_num do

        if base[i] == 0 then
            
            local btn_grab_banker_button = self.btn_grab_banker_button:clone():setVisible(true) 

            local bet_times_txt = btn_grab_banker_button:getChildByName("bet_times_txt")
            bet_times_txt:setString("不抢")
            btn_grab_banker_button:setPosition( 100+ planeMiddlePositionX + buttonInterval*(i-middleIndex),planeMiddlePositionY)
            btn_grab_banker_button:setScale(0.8)
            self.grab_banker_plane:addChild(btn_grab_banker_button)

                btn_grab_banker_button:addTouchEventListener(function(sender,event)

                        if  event == TOUCH_EVENT_BEGAN then
                            sender:setScale(0.6)
                        end

                        if  event == TOUCH_EVENT_CANCELED then
                            sender:setScale(0.8)
                        end

                        if  event == TOUCH_EVENT_ENDED then
                            sender:setScale(0.8)

                            SoundUtils:playEffect("click")   
                            NiuNiuSendHandle:qiang(base[i])
                            
                            self.grab_banker_plane:setVisible(false)

                        end

                    end)

        else

            local btn_grab_banker_button = self.btn_bet:clone():setVisible(true)
        
            btn_grab_banker_button:setPosition(100 + planeMiddlePositionX + buttonInterval*(i-middleIndex),planeMiddlePositionY)
            self.grab_banker_plane:addChild(btn_grab_banker_button)

            local bet_times_txt = btn_grab_banker_button:getChildByName("bet_times_txt")
            local effect_img = btn_grab_banker_button:getChildByName("effect_img"):setVisible(false)
            -- table.insert(effect_imgs,effect_img) 

            -- if  bt_num > 2 then
                bet_times_txt:setString(tostring(base[i]).."倍")
            -- else
                -- bet_times_txt:setString("抢庄")
            -- end

            -- if  canChooseBasesExist[base[i]] then
                btn_grab_banker_button:setScale(0.8)
                btn_grab_banker_button:addTouchEventListener(function(sender,event)

                        if  event == TOUCH_EVENT_BEGAN then
                            sender:setScale(0.6)
                        end

                        if  event == TOUCH_EVENT_CANCELED then
                            sender:setScale(0.8)
                        end

                        if  event == TOUCH_EVENT_ENDED then
                            sender:setScale(0.8)

                            SoundUtils:playEffect("click")   
                            NiuNiuSendHandle:qiang(base[i])
                            
                            -- for _,effect_img in pairs(effect_imgs) do
                            --     if not tolua.isnull(effect_img) then
                            --        effect_img:setVisible(false)
                            --     end
                            -- end

                            -- effect_img:setVisible(true)
                            
                            self.grab_banker_plane:setVisible(false)

                            GamePlaneOperator:setGrabBankerTimes(CARD_PLAYERTYPE_MY,base[i],true)

                        end

                    end)

            -- else
            --     btn_grab_banker_button:setBright(false)
            -- end

        end

    end
                     
    
end

function ControlPlaneOperator:showSitDownButton(flag)
    
    dump(flag,"开关showSitDownButton")

    -- if  isGoldGame == 0  then
        if  flag == true and GAME_STATE == GAME_STATUS_STOP then  --游戏停止状态下才能坐下
            self.btn_sit_down:setVisible(true)  
            self.btn_sit_down:setPositionX(self.btn_sit_down:getParent():getContentSize().width/2)
        else
            self.btn_sit_down:setVisible(false)  
        end
    -- end

end

--准备，（抢庄）（加倍）（摊牌，提示，搓牌）  游戏操作按钮
function ControlPlaneOperator:showControlButtons(stage,flag)
    
    
    dump(stage,"游戏阶段")
    dump(flag,"显示标记")

    if  flag == false then
        self.ready_plane:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        self.out_card_plane:setVisible(false)
        return
    end
    
    if  stage == 1 then   --准备阶段

        if  isGoldGame == 1 then
            self.btn_stand_up:setVisible(false)
            self.btn_ready:setPositionX(self.ready_plane:getContentSize().width/2)
        end 
    
        self.ready_plane:setVisible(true)

        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
        self.out_card_plane:setVisible(false)

    elseif  stage == 2 then  --抢庄阶段

        self.ready_plane:setVisible(false)

        self.grab_banker_plane:setVisible(true)
        self.bet_plane:setVisible(false)
        self.out_card_plane:setVisible(false)

    elseif  stage == 3 then  --加注阶段

        self.ready_plane:setVisible(false)

        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(true)
        self.out_card_plane:setVisible(false)

    elseif  stage == 4 then
        print("==========显示搓牌========")
        print("==========显示搓牌========")
        print("==========显示搓牌========")
        print("==========显示搓牌========")
        print("==========显示搓牌========")
        print("==========显示搓牌========")
        print("==========显示搓牌========")
        print("==========显示搓牌========")
        self.ready_plane:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)

        self.out_card_plane:setVisible(true) 
        -- self.btn_tip:setVisible(true) 
        -- if  GAME_CONFIG["允许搓牌"] == true then
        --     self.btn_cuopai:setVisible(true) 
        -- else
        --     self.btn_cuopai:setVisible(false) 
        -- end
        self.btn_cuopai:setVisible(true)

        self.btn_liangcards:setVisible(true)

        self.btn_tip:setVisible(false) 
        self.btn_outcard:setVisible(false)
        -- self.btn_liangcards:setPositionX(self.btn_liangcards_oriPositionX)

    elseif  stage == 5 then  --搓牌，翻牌之后

        self.ready_plane:setVisible(false)
        self.grab_banker_plane:setVisible(false)
        self.bet_plane:setVisible(false)
            
        self.out_card_plane:setVisible(true) 

        self.btn_cuopai:setVisible(false) 
        self.btn_liangcards:setVisible(false)

        self.btn_tip:setTouchEnabled(true)
        -- self.btn_tip:setVisible(true) 
        self.btn_outcard:setVisible(true)

        -- self.btn_liangcards:setPositionX(self.outCardPlaneMiddlePositionX)
        dump("搓牌之后")
    elseif stage == 6 then 
        self.btn_sanpu:setVisible(true)
    elseif stage == 7 then 
        self.btn_xianyu:setVisible(true)
    end

end

function ControlPlaneOperator:SetBtnTxt( card_type )
    -- body
    self.btn_xianjia:setVisible(true)
    self.btn_xianjia2:setVisible(true)
    if 2 == card_type then 
        self.btn1_txt:setString("开")
        self.btn2_txt:setString("认")
    elseif 4 == card_type then 
        self.btn1_txt:setString("盛")
        self.btn_xianjia2:setVisible(false)
    end

end

function ControlPlaneOperator:SetBtnJia()
    -- body
    self.btn_jia:setVisible(true)
    -- self.btnjia_2:setVisible(true)
    -- self.btnjia_1:setVisible(true)
    

end

function ControlPlaneOperator:ShowShuiYuButton( txt , value)
    -- body
    self.btn_shuiyu:setVisible(true)
    self.shuiyu_txt:setString(txt)
    self.shuiyu_value = value
end

function ControlPlaneOperator:ShowShuiYuButtonState( state )
    -- body
    self.btn_shuiyu:setVisible(state)
end

function ControlPlaneOperator:SendShuiYu()
    -- body
    --发送水鱼信息按钮
    if not self.shuiyu_value then return end
    print ("self.shuiyu_value" , self.shuiyu_value)

    NiuNiuSendHandle:CLI_PLAY_CARD(self.shuiyu_value , {1 ,2})
    self.btn_shuiyu:setVisible(false)
    self.shuiyu_txt:setString("水鱼")
    self.shuiyu_value = nil
end

function ControlPlaneOperator:SendZhuang( value )
    -- body
    self.btn_xianjia:setVisible(false)
    NiuNiuSendHandle:CLIENT_ZHUANG_OPT(value)
    GamePlaneOperator:showStageTxt("等待其他玩家操作...")
    self.btn1_txt:setString("杀")
    self.btn2_txt:setString("走")
end

function ControlPlaneOperator:SetLoadValue( value1 , value2 )
    -- body
    self.btn1_txt:setString(value1)
    self.btn2_txt:setString(value2)
end

function ControlPlaneOperator:SendXian( value )
    -- body
    self.btn_jia:setVisible(false)
    NiuNiuSendHandle:CLIENT_XIAN_OPT(value)
    GamePlaneOperator:showStageTxt("等待其他玩家操作...")
end

function ControlPlaneOperator:SetChooseBtn( state )
    -- body
    self.btn_sanpu:setVisible(state)
    self.btn_xianyu:setVisible(state)
end

function ControlPlaneOperator:setVisible( state )
    -- body
    self.btn_sanpu:setVisible(state)
    self.btn_xianyu:setVisible(state)
    self.btn_xianjia:setVisible(state)
    self.btn_jia:setVisible(state)
end

function ControlPlaneOperator:SendHeadCard( sanpu_type )
    -- body
    print ("SendHeadCard"  , sanpu_type)
    if not self.sanpu_value then return end
    dump(self.sanpu_value)
    print ("ControlPlaneOperator_SendHeadCard")
    NiuNiuSendHandle:CLI_PLAY_CARD(sanpu_type , self.sanpu_value)
    -- if self.sanpu_func then 
    --     self.sanpu_func(1 , self.sanpu_value)
    -- end
    self.sanpu_value = nil
    self.btn_sanpu:setVisible(false)
    self.btn_xianyu:setVisible(false)
end

function ControlPlaneOperator:SetHeadValue(value , func)
    -- body
    self.sanpu_value = value
    self.sanpu_func = func
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
            self.bet_plane = morebase_slider:getChildByName("bet_plane")
    local   base_sl = morebase_slider:getChildByName("base_sl")
    local   base_tt = nowself.bet_plane:getChildByName("base_tt")
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

    -- nowself.bet_plane   --气泡对话框   nowself.bet_plane
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
          nowself.bet_plane:setPositionX(tipsJianju*(percent-minValue) + beginPositionX)
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

                    NiuNiuSendHandle:addBase(choumalist[choumaIndex])   --给服务器传下多少筹码的函数

               end
            end

        end
    
    sure_bt:addTouchEventListener(touchEvent)
    up_bt:addTouchEventListener(touchEvent)
    down_bt:addTouchEventListener(touchEvent)
    
    return sure_bt
end



return ControlPlaneOperator