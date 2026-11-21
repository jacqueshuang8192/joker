local TablePlaneOperator = class("TablePlaneOperator")

local random_uid_ex = -1

--抢庄特效间隔
local GrabBankerDelay = 0.23

local coin_img_path = TpackageName .. "/images/effect_gold_3.png"

local cacheFrames = cc.SpriteFrameCache:getInstance()

local jubaopen_img_path = { [1] = TpackageName .. "/images/jubaopen_2.png" ,
                            [2] = TpackageName .. "/images/jubaopen_3.png" ,
                            [3] = TpackageName .. "/images/jubaopen_4.png" ,
                            [4] = TpackageName .. "/images/jubaopen_5.png" }

function TablePlaneOperator:init()

    --self.btn_ready = CDSPanel.hall_plane.btn_ready--准备
    self.share_btn = CDSPanel.hall_plane.share_btn--微信邀请
    self.copy_btn = CDSPanel.hall_plane.copy_btn--复制房间号

    ---------------------------下注界面操作逻辑写在这里----------------------------------------

    self.Panel_chouma = CDSPanel.play_plane.Panel_chouma
    self.Panel_txtType = CDSPanel.play_plane.Panel_txt
    --下注类型的图片名（有时间重新命名）
    self.typeImgNameTabs = {"dan","hongdang","fandan","heishuang","hongshuang","shuang"}

    self.Panel_shaiziAnimation = CDSPanel.play_plane.Panel_shaizi
    self.Panel_shaiziAnimation:removeAllChildren()

    --加上资源
    self:addShaiziAnimation()

    self.Panel_shaiziImage = CDSPanel.play_plane.Panel_shaizi_Image
    self.Panel_shaiziImage:setVisible(false)

    --下注桌面按钮
    self.xiazhuImgTabs = {}
    self.selectXiaZhuIndex = 0
    for i=1,6 do
        local image = CDSPanel.play_plane:getChildByName("Image_"..i)
        table.insert(self.xiazhuImgTabs,image)
        
        local btn = image:getChildByName("Button_1")
        btn:setTag(i)
        btn:addTouchEventListener(handler(self,self.onXiazhuBtnClick))
        
        local sum_txt = image:getChildByName("sum_txt")
        sum_txt:setString("0")

        local sum_txt_my = image:getChildByName("sum_txt_my")
        sum_txt_my:setString("已下注："..0)
    end
    
    self.xiazhuMoneyTabs = {20,50,100,500,1000,-1} -- -1表示删除下注
    self.xiazhuBtnTabs = {}
    self.selectXiaZhuMoneyIndex = 0
    --金额按钮
    for i=1,6 do
        local btn = CDSPanel.play_plane:getChildByName("Button_"..i)
        btn:setTag(i)
        local str = self.xiazhuMoneyTabs[i]
        if str == -1 then
            str = "取消下注"
        end
        btn:getTitleRenderer():setString(str)
        table.insert(self.xiazhuBtnTabs,btn)
        btn:getChildByName("Image_1"):getChildByName("Text_1"):setString(str)
        btn:addTouchEventListener(handler(self,self.onXiazhuGoldBtnClick))   
    end
    self:initXiaZhuPanel()


    self.stage_img = CDSPanel.hall_plane.stage_img--倒计时
    self.stage_txt = self.stage_img.stage_txt

    --筹码
    self.moneyImgTabs = {}
    for i=1,5 do
        local img = CDSPanel.play_plane:getChildByName("Image_gold"..i)
        table.insert(self.moneyImgTabs,img)
        img:getChildByName("Text_1"):setString(self.xiazhuMoneyTabs[i])
    end

    -- --加一个 之前只有4个金额
    -- local img = self.moneyImgTabs[4]:clone()
    -- img:getChildByName("Text_1"):setString(self.xiazhuMoneyTabs[5])
    -- img:addTo(self.moneyImgTabs[4]:getParent())
    -- table.insert(self.moneyImgTabs,img)
    
    for playerType = 1,TOTAL_PLAYERNUM do
        self:setSeatGold(playerType,0)
    end

    --显示战绩
    self.Image_zhanji = CDSPanel.game_plane.Image_zhanji
    self.Image_zhanji:getChildByName("Panel_1"):removeAllChildren()


    --记录飞出的金币的位置,特意用这个来精准控制位置
    self.showPanelTab = {}
    for i=1,6 do
        local tempPanel = CDSPanel.play_plane:getChildByName("panel_fei_gold_"..i)
        table.insert(self.showPanelTab,tempPanel)
    end

end

function TablePlaneOperator:addShaiziAnimation()

    --这是加色子的资源
    local effectManage = ccs.ArmatureDataManager:getInstance() 
    local name = "3dyaoshaizi"
    local path = TpackageName .. "/csb/GameSceneSector/3dyaoshaizi/"..name
    for i=0,6 do
        display.addSpriteFrames(path..i..".png", path..i..".plist")
        effectManage:addArmatureFileInfo(path..i..".png", path..i..".plist", path..".ExportJson")
    end

    local size = self.Panel_shaiziAnimation:getContentSize()
    local pos  = cc.p(size.width*0.5,size.height*0.7)

    local name = "3dyaoshaizi"
    self.shaizi_Armature = ccs.Armature:create(name)
    self.shaizi_Armature:setVisible(false)
    self.shaizi_Armature:addTo(self.Panel_shaiziAnimation):setPosition(pos.x,pos.y)

end


function TablePlaneOperator:createChouMa(moneyType,xiazhuType,money)

    if self.moneyImgTabs[moneyType] and self.xiazhuImgTabs[xiazhuType] then
        local imgMoney = self.moneyImgTabs[moneyType]:clone()
        imgMoney:getChildByName("Text_1"):setString(money or 0)
        imgMoney:addTo(self.Panel_chouma) --每一局最后要删掉

        local pos1 = self.xiazhuBtnTabs[moneyType]:getPosition()
        imgMoney:setPosition(pos1.x,pos1.y+50)

        local btnTemp = self.xiazhuImgTabs[xiazhuType]
        local pos2 = btnTemp:getPosition()
        pos2.x = pos2.x + math.random(-50,50)
        pos2.y = pos2.y + math.random(-80,-20)

        imgMoney:runAction(cc.MoveTo:create(0.2,pos2))
    end
end

function TablePlaneOperator:createChouMaByChongLian(moneyType,xiazhuType,money)
    if self.moneyImgTabs[moneyType] and self.xiazhuImgTabs[xiazhuType] then
        local imgMoney = self.moneyImgTabs[moneyType]:clone()
        imgMoney:getChildByName("Text_1"):setString(money or 0)
        imgMoney:addTo(self.Panel_chouma) --每一局最后要删掉

        local pos1 = self.xiazhuBtnTabs[moneyType]:getPosition()
        imgMoney:setPosition(pos1.x,pos1.y+50)

        local btnTemp = self.xiazhuImgTabs[xiazhuType]
        local pos2 = btnTemp:getPosition()
        pos2.x = pos2.x + math.random(-50,50)
        pos2.y = pos2.y + math.random(-80,-20)

        imgMoney:setPosition(pos2)
    end
end

function TablePlaneOperator:initXiaZhuPanel()
    --self.selectXiaZhuMoneyIndex = 0
    self:setXiaZhuImgLiangVisible(0)
    self:setXiaZhuSumTxt()
    self:setXiaZhuMySumTxt()
    self:setXiaZhuBtnClick(self.selectXiaZhuMoneyIndex)
    self.Panel_chouma:removeAllChildren()
end

function TablePlaneOperator:onDeleteChouMa()
    self.Panel_chouma:removeAllChildren()
end

function TablePlaneOperator:setXiaZhuBtnClick(index)
    if index == 0 then
        for i,v in ipairs(self.xiazhuBtnTabs) do
            v:getChildByName("Image_1"):setVisible(false)
            v:setTouchEnabled(true)
        end
    else
        for i,v in ipairs(self.xiazhuBtnTabs) do
            if index == i then
                v:getChildByName("Image_1"):setVisible(true)
                v:setTouchEnabled(false)
            else
                v:getChildByName("Image_1"):setVisible(false)
                v:setTouchEnabled(true)
            end
        end
    end
end

function TablePlaneOperator:onXiazhuBtnClick(sender,event)
    --触摸开始
    --[[if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.9)
    end

    --触摸取消
    if event == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end--]]

    --触摸结束
    if event == TOUCH_EVENT_ENDED then
        --sender:setScale(1.0)
        local tag = sender:getTag()

        if GAME_STATE ~= GAME_STATUS_YA then
            if GAME_STATE == GAME_STATUS_STOP_YA then
                viewMgr:showTip({text = "已封盘"}) 
                return
            end

            viewMgr:showTip({text = "当前不能下注"}) 
            return
        end

        if self.selectXiaZhuMoneyIndex == 0 then
            --提示未选择下注类型
            viewMgr:showTip({text = "请选择筹码金额！"})
            return
        elseif self.selectXiaZhuMoneyIndex == 6 then
            --提示未选择下注类型
            viewMgr:showTip({text = "已经取消下注！"})
            return
        else
            --给服务器下注啦
            SoundUtils:playEffect("click")
            self:setXiaZhuImgLiangVisible(tag)
            local value = self.xiazhuMoneyTabs[self.selectXiaZhuMoneyIndex] or 0
            CDSSendHandle:CLIENT_CMD_YA(value,self.selectXiaZhuIndex-1)

        end
    end
end

function TablePlaneOperator:setXiaZhuImgLiangVisible(index)
    self.selectXiaZhuIndex = index

    for i=1,#self.xiazhuImgTabs do
        local Image_liang = self.xiazhuImgTabs[i]:getChildByName("Image_liang")
        local img_txt = self.Panel_txtType:getChildByName("Image_"..i)
        local pathStr = TpackageName.."/csb/GameSceneSector/cdsImage/"

        if self.selectXiaZhuIndex == i then
            Image_liang:setVisible(true)
            img_txt:loadTexture(pathStr..self.typeImgNameTabs[i].."_h.png")
            img_txt:ignoreContentAdaptWithSize(false)
        else
            Image_liang:setVisible(false)
            img_txt:loadTexture(pathStr..self.typeImgNameTabs[i]..".png")
            img_txt:ignoreContentAdaptWithSize(false)
        end
    end
end

function TablePlaneOperator:setXiaZhuSumTxt(index,sum)
    if not index or not sum then
        for i=1,#self.xiazhuImgTabs do
            local sum_txt = self.xiazhuImgTabs[i]:getChildByName("sum_txt")
            sum_txt:setString(0)
        end
        return
    end

    local sum_txt = self.xiazhuImgTabs[index]:getChildByName("sum_txt")
    sum_txt:setString(sum)
end

function TablePlaneOperator:setXiaZhuMySumTxt(index,sum)
    if not index or not sum then
        for i=1,#self.xiazhuImgTabs do
            local sum_txt_my = self.xiazhuImgTabs[i]:getChildByName("sum_txt_my")
            sum_txt_my:setString("已下注:0")
        end
        return
    end

    local sum_txt_my = self.xiazhuImgTabs[index]:getChildByName("sum_txt_my")
    sum_txt_my:setString("已下注:"..sum)
end

function TablePlaneOperator:onXiazhuGoldBtnClick(sender,event)
    --[[--触摸开始
    if event == TOUCH_EVENT_BEGAN then
        sender:setScale(0.9)
    end

    --触摸取消
    if event == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end--]]

    --触摸结束
    if event == TOUCH_EVENT_ENDED then
        --sender:setScale(1.0)
        local tag = sender:getTag()

        if tag == 6 and GAME_STATE ~= GAME_STATUS_YA then
            viewMgr:showTip({text = "已封盘"}) 
            return
        end

        SoundUtils:playEffect("click")
        self:setXiaZhuBtnClick(tag)

        if tag == 6 then  --取消下注
            CDSSendHandle:CLIENT_CMD_YA(-1,0)
        end

        self.selectXiaZhuMoneyIndex = tag
        
        --[[if GAME_STATE ~= GAME_STATUS_YA then
            viewMgr:showTip({text = "当前还未开始下注"}) 
            return
        end

        if self.selectXiaZhuIndex == 0 then
            --提示未选择下注类型
            viewMgr:showTip({text = "请选择下注范围！"})
            return
        else
            --给服务器下注啦
            dump("给服务器下注啦~~~~")
            local value = self.xiazhuMoneyTabs[tag] or 0
            CDSSendHandle:CLIENT_CMD_YA(value,self.selectXiaZhuIndex-1)
        end--]]
    end
end


function TablePlaneOperator:onClickShare(event)
    USER_INFO["invote_code"] = USER_INFO["invote_code"] or " "
    local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
    local share_content = ""
    for k,v in pairs(config_arr) do
        if v ~= "" then
            share_content = share_content .. v .. ","
        end
    end
    share_content = string.sub(share_content, 1, string.len(share_content) - 1)  
    local paras = {}
    paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
    paras["imagePath"] = "url"
    paras["name"] = "湖南碗碗，房号：" .. USER_INFO["invote_code"]
    paras["showType"] = 2;
    paras["url"] = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW["scene"],9999999)
    end
end

function TablePlaneOperator:setSeatGold(playerType,value)
--    local panel =  self.panel_seat:getChildByName("panel_"..playerType)
--     if panel then
--         local text_gold = panel:getChildByName("text_gold")
--         if text_gold then
--             text_gold:setString(value or 0)
--         end
--     end

end

function TablePlaneOperator:showIsButtonXZ(flag)
    -- self.dow_xiazu:setVisible(flag)
end

function TablePlaneOperator:switchTableImg(typeIndex)

    local background = SCENENOW["scene"]:getChildByName("background")

    if background then
        if  typeIndex == 1 then
            background:loadTexture("")
        elseif typeIndex == 2 then
            background:loadTexture("")
        end
    end

end

function TablePlaneOperator:clearGameDatas(stage)

    if stage == 1 then
        self:hideCardNumCountEffect()
    elseif stage == 2 or stage == nil then
    	RANDOM_BANKER = {}

        -- self.stage_txt:setString("等待开始")
        -- self.stage_img:setVisible(false)
        self:resetCardNumCount()

        -- local hall_plane = CDS_GAME_SCENE:getParent():getChildByName("hall_plane")
        -- local btn_switch_bet_mode = hall_plane:getChildByName("btn_switch_bet_mode")
        -- local bottom_img = btn_switch_bet_mode:getChildByName("bottom_img")

        --       btn_switch_bet_mode:setPosition(cc.p(96,110))
        --       btn_switch_bet_mode:setScale(1)
        --       bottom_img:setColor(cc.c3b(125,125,125))
              -- bottom_img:setContentSize(cc.size(110,102))

    end
    self:stopTimer()
end


function TablePlaneOperator:resetCardNumCount()

    -- local left_txt = self.sangong_cardcount_plane:getChildByName("left_txt")
    -- local middle_txt = self.sangong_cardcount_plane:getChildByName("middle_txt")
    -- local right_txt = self.sangong_cardcount_plane:getChildByName("right_txt")
    -- local result_txt = self.sangong_cardcount_plane:getChildByName("result_txt")

    --       left_txt:setString("")
    --       middle_txt:setString("")
    --       right_txt:setString("")
    --       result_txt:setString("")

end


function TablePlaneOperator:showTaiFeiTips(value)
    --添加扣除台费显示
    local taiFeiTxt
    if  value < 0 then
        taiFeiTxt = "扣除台费"..math.abs(value)
    end

-- sangong/font/arial.ttf

    local lbVersion = cc.Label:createWithTTF(taiFeiTxt, TpackageName .."/font/fzcs.ttf",50)
          CDS_GAME_SCENE:addChild(lbVersion,9999)
          lbVersion:setColor(cc.c3b(255, 40, 40))
          lbVersion:setPosition(cc.p(CDS_GAME_SCENE:getContentSize().width/2,100))
          lbVersion:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() lbVersion:removeFromParent() end)))
end

function TablePlaneOperator:showAutoPlayTip(flag)
    --添加扣除台费显示

    local hall_plane = CDS_GAME_SCENE:getParent():getChildByName("hall_plane")
    local btn_auto_play = hall_plane:getChildByName("btn_auto_play")

    if  flag == true then
        dump("提示自己进入托管状态")
        -- local tipTxt =  "您正处于托管状态..."
        -- local autoPlayTip = cc.Label:createWithTTF(tipTxt,""res/fonts/fzcy.ttf"",45):addTo(CDS_GAME_SCENE,1001)
        -- autoPlayTip:setColor(cc.c3b(0, 0, 0))
        -- autoPlayTip:setPosition(cc.p(CDS_GAME_SCENE:getContentSize().width/2,470))
        -- autoPlayTip:setName("autoPlayTip")
        self.auto_cancel_plane:setVisible(true)    
        btn_auto_play:setBright(false)
    else
        dump("隐藏托管状态")
        -- local autoPlayTip = CDS_GAME_SCENE:getChildByName("autoPlayTip")
        -- if  autoPlayTip then
        --     autoPlayTip:removeFromParent()
        -- end
        self.auto_cancel_plane:setVisible(false)   
        btn_auto_play:setBright(true)
    end


end

function TablePlaneOperator:showNumCount(value,index,flag)
    
    -- self.sangong_cardcount_plane:setVisible(true)

    -- if  value == nil then
    --     return
    -- end

    -- local value = require(TpackageName .. ".cardLogic"):GetCardLogicValue(value) 

    -- local left_txt = self.sangong_cardcount_plane:getChildByName("left_txt")
    -- local middle_txt = self.sangong_cardcount_plane:getChildByName("middle_txt")
    -- local right_txt = self.sangong_cardcount_plane:getChildByName("right_txt")
    -- local result_txt = self.sangong_cardcount_plane:getChildByName("result_txt")
    
    -- if flag == false then
        
    --     if  index == 1 then
    --         left_txt:setString("")
    --     elseif  index == 2 then
    --         middle_txt:setString("")
    --     elseif  index == 3 then
    --         right_txt:setString("")
    --     end

    --     result_txt:setString("") 

    -- else
        
    --     if  index == 1 then
    --         left_txt:setString(value)
    --     elseif  index == 2 then
    --         middle_txt:setString(value)
    --     elseif  index == 3 then
    --         right_txt:setString(value)
    --     end

    --     local  left_num = tonumber(left_txt:getString())
    --     local  middle_num = tonumber(middle_txt:getString())
    --     local  right_num = tonumber(right_txt:getString())

    --     if  left_num and  middle_num and right_num then
    --         result_txt:setString(left_num + middle_num + value)
    --     else
    --         result_txt:setString("")
    --     end

    -- end
end


function TablePlaneOperator:showCardNumCountEffect(arg)

    -- self.sangong_cardcount_plane:setVisible(true)

    -- local left_num = arg.left_num

    -- local middle_num = arg.middle_num

    -- local right_num = arg.right_num
    
    -- local left_txt = self.sangong_cardcount_plane:getChildByName("left_txt")
    -- local middle_txt = self.sangong_cardcount_plane:getChildByName("middle_txt")
    -- local right_txt = self.sangong_cardcount_plane:getChildByName("right_txt")
    -- local result_txt = self.sangong_cardcount_plane:getChildByName("result_txt")
   
    -- local function starEffect()
    -- end
    
    -- left_txt:setString(left_num)

    -- SCENENOW["scene"]:performWithDelay(function() 
    --     middle_txt:setString(middle_num)

    --     SCENENOW["scene"]:performWithDelay(function()
    --         right_txt:setString(right_num)

    --         SCENENOW["scene"]:performWithDelay(function() 
    --             result_txt:setString(left_num + middle_num + right_num)
    --             starEffect()
    --         end,0.2)

    --     end,0.2)

    -- end,0.2)

    -- SCENENOW["scene"]:performWithDelay(function() 
    --     self.sangong_cardcount_plane:setVisible(false)
    -- end,2)

end

function TablePlaneOperator:hideCardNumCountEffect()
    -- self.sangong_cardcount_plane:setVisible(false)
end


--画金币
function TablePlaneOperator:showCoinFlyAnimation_1(bankerUid,tbWin,_type)
     
    --获取庄位置
    dump(bankerUid, "-----庄家UID-----")
    math.randomseed(os.time())
   
    local bankerPlayerType = CDS_PLAYERTYPE_TABLE[bankerUid]
    
    --庄家输赢情况
    local zhuang_win = 0
    local zhuang_lose = 0

    local isZhuanWin = false

    for uid,value in pairs(tbWin) do
        if uid ~= bankerUid and value < 0 then
            isZhuanWin = true
            zhuang_win = zhuang_win - value
        elseif uid ~= bankerUid and value > 0 then
            zhuang_lose = zhuang_lose - value
        end
    end

    --闲家数
    local   playerCount = table.nums(tbWin)

    local coinfly 

    if _type == "bet" then

        coinfly = function(oriPos,targetPos,i)
                
            local frameName = jubaopen_img_path[math.random(4)]
            local coin_sp = cc.Sprite:createWithSpriteFrameName(frameName)
            -- local coin_sp = display.newSprite(jubaopen_img_path[math.random(4)])
            if coin_sp then

                coin_sp:setPosition(oriPos)
                coin_sp:setScale(0.6)
                SCENENOW["scene"]:addChild(coin_sp, 100)

                local random = i

                if  random > 20 then
                    random = 20
                end

                local delaytime = 0.4 + 0.1 * math.random(random)

                local jumpHeight = math.random(20,80)

                local mb = cc.JumpTo:create(delaytime, targetPos, jumpHeight, 1)
                local fo = cc.FadeOut:create(0.5)
                local remove_action = cc.CallFunc:create(function()           
                      coin_sp:removeFromParent()
                end)

                local seq = cc.Sequence:create(mb, fo, remove_action) --cc.DelayTime:create(0.4),
                coin_sp:runAction(seq)

            end

        end

    else

        local sceneNow = SCENENOW["scene"]

        coinfly = function(oriPos,targetPos,i)
           
            local delaytime = i*0.035 + math.random(-2,2)/100

            sceneNow:performWithDelay(function()

                oriPos = cc.pAdd(oriPos,cc.p(math.random(-30,30),0 ) )

                local coin_sp = display.newSprite(coin_img_path):setPosition(oriPos):setScale(0.5)

                sceneNow:addChild(coin_sp, 100)
                targetPos = cc.pAdd(targetPos,cc.p(math.random(-30,30),math.random(-8,8) ) )
                -- local random = i

                -- if  random > 20 then
                --     random = 20
                -- end

                local middleY = (targetPos.y + oriPos.y)/2

                local q1 = cc.p((targetPos.x - oriPos.x)*0.56 + oriPos.x,(targetPos.y - oriPos.y)*0.44 + oriPos.y)
                local q2 = cc.p((targetPos.x - oriPos.x)*0.67 + oriPos.x,(targetPos.y - oriPos.y)*0.8 + oriPos.y)
                local mb = cc.BezierTo:create(0.4,{q1, q2,targetPos})

                local fo = cc.FadeOut:create(0.4)

                local seq = cc.Sequence:create(mb,fo,cc.RemoveSelf:create()) --cc.DelayTime:create(0.4),
                coin_sp:runAction(seq)

            end,delaytime)

        end

    end
    
    
    local ZhuangWinDelay = 2
    --显示更新内容（文字和筹码）
    for uid,value in pairs(tbWin) do
       
        local  playerType = CDS_PLAYERTYPE_TABLE[uid]

        dump(playerType, "-----对应座位-----")
        dump(value, "-----更新筹码数-----")
             
        local pos = PLAYER_HEADS_POSITION_TABLE[uid]

        if  playerType then

            local x = pos.x
            local y = pos.y
            
            --local pos = PLAYER_HEADS_POSITION_TABLE[bankerUid]
            --系统做庄
            local pos = cc.p(display.width*0.5,display.height*0.8)

            local zhuang_x = pos.x
            local zhuang_y = pos.y
           
            --计算生成筹码数

            local coin_count = 20
            --判断当前位置是否为庄
            if playerType == bankerPlayerType then

                if  isZhuanWin == true and playerCount > 2 then
                    GamePlaneOperator:updateCoin(playerType,zhuang_win)

                    SCENENOW["scene"]:performWithDelay(function() 
                        GamePlaneOperator:updateCoin(playerType,zhuang_lose)
                    end, ZhuangWinDelay) 
                else
                    GamePlaneOperator:updateCoin(playerType,tbWin[uid])
                end

            else --当前用户不是庄家

                --添加显示减少的筹码
                if value < 0 then

                    --玩家输，筹码从玩家生成，飞向庄家
                    dump("-----筹码飞动，玩家输，飞向庄家x-----")
                    --金币流数    

                        --添加筹码
                        for i=1,coin_count do
                             
                            local oriPosition = cc.p(x, y)
                            local targetPos = cc.p(zhuang_x, zhuang_y)

                            coinfly(oriPosition,targetPos,i)

                        end


                    SoundUtils:playEffect("coinfly_long",false)

                   	GamePlaneOperator:updateCoin(playerType,tbWin[uid])

                elseif value > 0 then

                    --玩家赢，筹码从庄家生成，飞向玩家
                    dump(x, "-----筹码飞动，玩家赢，飞向玩家x-----")
                    dump(y, "-----筹码飞动，玩家赢，飞向玩家y-----")          

                    --添加筹码

                    if isZhuanWin == true and playerCount > 2 then
                        --庄有赢而且当前玩家数大于2

                        local action = cc.Sequence:create(cc.DelayTime:create(ZhuangWinDelay),cc.CallFunc:create(function()
                         

    	                        for i=1, coin_count do

                                    local oriPosition = cc.p(zhuang_x,zhuang_y)

    	                            --筹码飞动 
    	                            local targetPos = cc.p(x, y)
    	                            coinfly(oriPosition,targetPos,i)

    	                        end
    	                    -- end

    	                    SoundUtils:playEffect("coinfly_long",false)
    	                    
    	                    GamePlaneOperator:updateCoin(playerType,tbWin[uid])

                        end))

                        SCENENOW["scene"]:runAction(action)                 

                    else
                      
                        -- for a=0, coinLiu_count do
                            for i=1, coin_count do

                                -- local randomX = math.random(coin_count)/2
                                -- local randomY = math.random(coin_count)/2

                                local oriPosition = cc.p(zhuang_x, zhuang_y)

                                --筹码飞动
                                local targetPos = cc.p(x, y)
                                coinfly(oriPosition,targetPos,i)
                            end
                        -- end
       
                        SoundUtils:playEffect("coinfly_long",false)
                        GamePlaneOperator:updateCoin(playerType,tbWin[uid])

                    end

                end
            end

        end
        
    end
end

--画金币
function TablePlaneOperator:showCoinFlyAnimation(bankerUid,tbWin,_type,winType)
    math.randomseed(os.time())
    dump(tbWin, "-----输赢分数-----")

    

    local coinfly 
    local sceneNow = SCENENOW["scene"]

    coinfly = function(oriPos,targetPos,i)
        local delaytime = i*0.06 + math.random(-2,2)/100

        sceneNow:performWithDelay(function()
            oriPos = cc.pAdd(oriPos,cc.p(math.random(-30,30),math.random(-30,30) ) )

            local moneyType = math.random(1,4)
            local coin_sp = self.moneyImgTabs[moneyType]:clone()
            coin_sp:getChildByName("Text_1"):setString("")
            coin_sp:setScale(0.8)
            coin_sp:setPosition(oriPos)

            sceneNow:addChild(coin_sp, 100)
            targetPos = cc.pAdd(targetPos,cc.p(math.random(-0,0),math.random(-0,0) ) )

            local middleY = (targetPos.y + oriPos.y)/2
            local tempX = targetPos.x - oriPos.x
            local tempY = targetPos.y - oriPos.y

            local q1 = cc.p(tempX*0.56 + oriPos.x, tempY*0.44 + oriPos.y)
            local q2 = cc.p(tempX*0.67 + oriPos.x, tempY*0.8 + oriPos.y)

            local mb = cc.BezierTo:create(0.4,{q1, q2,targetPos})
            local fo = cc.FadeOut:create(0.4)
            local seq = cc.Sequence:create(mb,fo,cc.RemoveSelf:create()) --cc.DelayTime:create(0.4),
            coin_sp:runAction(seq)
            
        end,delaytime)
    end
    local size = sceneNow:getContentSize()
    local feiPosTab = {}

    if winType == 1 or winType == 2 then
        table.insert(feiPosTab,1)
        table.insert(feiPosTab,winType+1)
    elseif winType == 3 or winType == 4 then
        table.insert(feiPosTab,6)
        table.insert(feiPosTab,winType+1)
    end

    if not MY_TOTAL_XIAZHU_TAB or #MY_TOTAL_XIAZHU_TAB == 0 then
        return
    end
    
    for i,v in ipairs(feiPosTab) do
        if MY_TOTAL_XIAZHU_TAB and MY_TOTAL_XIAZHU_TAB[v] and MY_TOTAL_XIAZHU_TAB[v] > 0 then  --这个表示下中了
            local oriPosition = cc.p(size.width/2,size.height*0.8)  --取消从桌面飞
            --if winType then  --红单
                oriPosition = self.showPanelTab[v]:getParent():convertToWorldSpace(self.showPanelTab[v]:getPosition())
            --end

            --显示更新内容（文字和筹码）
            local  flag = 0
            for uid,value in pairs(tbWin) do
                local playerType = CDS_PLAYERTYPE_TABLE[uid]
                local targetPos = PLAYER_HEADS_POSITION_TABLE[uid]

                --输牌不飞了
                if value > 0 then
                    flag = 1
                    -- if value < 0 then
                    --     local temp = oriPosition
                    --     oriPosition = targetPos
                    --     targetPos = temp
                    -- end

                    if playerType then
                        local coin_count = 20
                        for i=1, coin_count do
                            --筹码飞动 
                            coinfly(oriPosition,targetPos,i)
                        end
                    end
                end
            end

            if flag == 1 then
                SoundUtils:playEffect("coinfly_long",false)
            end    

        end
    end

end


--画金币
function TablePlaneOperator:waiWeiCoinFly(playerType,pos,score,chip,finalPos)

    local  targetPos
    local  oriPos 

    if  finalPos == nil then
        print("waiWeiCoinFly_目标位置为nil")
        return
    end

    if  score > 0 then
        targetPos = pos 
        oriPos = finalPos  -- PLAYER_HEADS_POSITION_TABLE[bankerUid]
    else
        targetPos = finalPos -- PLAYER_HEADS_POSITION_TABLE[bankerUid]  --cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2 + 50)
        oriPos = pos
    end

    local  function coinfly(oriPos,targetPos,i)
            
        local frameName = jubaopen_img_path[math.random(4)]
        local coin_sp = cc.Sprite:createWithSpriteFrameName(frameName)
        -- local coin_sp = display.newSprite(jubaopen_img_path[math.random(4)])
        coin_sp:setPosition(oriPos)
        coin_sp:setScale(0.6)
        SCENENOW["scene"]:addChild(coin_sp, 100)

        local random = i

        if  random > 20 then
            random = 20
        end

        local delaytime = 0.4 + 0.1 * math.random(random)

        local jumpHeight = math.random(20,80)

        local mb = cc.JumpTo:create(delaytime, targetPos, jumpHeight, 1)
        local fo = cc.FadeOut:create(0.5)
        local remove_action = cc.CallFunc:create(function()           
              coin_sp:removeFromParent()
        end)

        local seq = cc.Sequence:create(mb, fo, remove_action) --cc.DelayTime:create(0.4),
        coin_sp:runAction(seq)

    end

    dump(oriPos,"waiWeiCoinFly")
    dump(targetPos,"waiWeiCoinFly")
    local coin_count = 10
    for i = 1,coin_count do 
        coinfly(oriPos,targetPos,coin_count)
    end

    if playerType then
        SCENENOW["scene"]:performWithDelay(function()
            -- GamePlaneOperator:setCoin(playerType,chip)
            GamePlaneOperator:updateCoin(playerType,score,chip)
        end,1)
    end

end


function TablePlaneOperator:stopTimer()
    self.stage_img:stopAllActions()
    self.stage_img:setVisible(false)
end

--设置倒计时时间显示
function TablePlaneOperator:startTimer(time,stage)
    if not (self.stage_img and CDSPanel and SCENENOW["name"] == TpackageName ..".view.CDSRoomScene") then
        return
    end

    self.stage_img:stopAllActions()
    if  time <= 0 then
        self.stage_img:setVisible(false)
        return
    end

    self.timer_value = time
    local  refreshTime = 1
    local func = function ( timer_value )
        if timer_value ~= nil then
            local str = stage or ""
            self.stage_txt:setString(str..":"..string.format( "%02d", timer_value ))
            self.stage_img:setVisible(true)
        end
    end

    func(self.timer_value)

    local showTimerAc = cc.CallFunc:create(function()
            self.timer_value = self.timer_value - 1
            --dump(self.timer_value,stage.."------------------------")
            if  self.timer_value > 0 then
                func(self.timer_value)
            else
                self:stopTimer()
            end
        end)

    local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime),showTimerAc)
    self.stage_img:runAction(cc.RepeatForever:create(seqAc))
end

function TablePlaneOperator:showStageTxt(info)
    self:stopTimer()
end

--显示游戏开始
function TablePlaneOperator:showStartAnimation()
      
	SoundUtils:playEffect("gameStart")

	-- local sangong_start = CDS_GAME_SCENE:getChildByName("sangong_start") --游戏开始
    -- local sangong_start_txt = sangong_start:getChildByName("sangong_start_txt") --游戏开始
    --       sangong_start:loadTexture(TpackageName .. "/images/game_start_01.png")

    -- if sangong_start_txt then
    --     sangong_start_txt:removeFromParent()
    -- end

    -- sangong_start_txt = display.newSprite(TpackageName .. "/images/game_start_02.png")
    -- sangong_start:addChild(sangong_start_txt)
    -- sangong_start_txt:setName("sangong_start_txt")
    -- sangong_start_txt:setPosition(sangong_start:getContentSize().width/2,sangong_start:getContentSize().height/2)
    -- sangong_start:setVisible(true)
    -- sangong_start:setOpacity(255)
    -- sangong_start:setScale(0.5)

    -- local start_fade = cc.FadeOut:create(0.3)
    -- local sangongwei = cc.ScaleTo:create(0.2,1)

	-- local delay= cc.DelayTime:create(0.6)
    -- sangong_start:runAction(cc.Sequence:create(sangongwei,delay,start_fade))


end


--显示游戏结束动画
function TablePlaneOperator:showGameEndAnimation(isWin)
      
    -- local sangong_start = CDS_GAME_SCENE:getChildByName("sangong_start") --游戏开始
    
    -- local sangong_start_txt = sangong_start:getChildByName("sangong_start_txt") --游戏开始
    
    -- if  sangong_start_txt then
    --     sangong_start_txt:removeFromParent()
    -- end
 
    -- if  isWin == true then
    --     sangong_start:loadTexture(TpackageName .. "/images/game_end.png")
    --     sangong_start_txt = display.newSprite(TpackageName .. "/images/win_txt.png")
    --     SoundUtils:playEffect("赢")
    -- else
    --     sangong_start:loadTexture(TpackageName .. "/images/game_end.png")
    --     sangong_start_txt = display.newSprite(TpackageName .. "/images/lose_txt.png")
    --     SoundUtils:playEffect("输")
    -- end
    
    -- sangong_start_txt:setPosition(sangong_start:getContentSize().width/2,sangong_start:getContentSize().height/2)
    
    -- sangong_start:addChild(sangong_start_txt)
    -- sangong_start_txt:setName("sangong_start_txt")
     
    -- sangong_start:setVisible(true)
    -- sangong_start:setOpacity(255)

    -- local start_fade = cc.FadeOut:create(0.8)
    -- local delay= cc.DelayTime:create(1.1)
    -- sangong_start:runAction(cc.Sequence:create(delay,start_fade))


end



function TablePlaneOperator:showRandomBankerChoose(random_banker)
    
    if  next(random_banker) == nil then
        return
    end

    --self.banker_choose_frame:setOpacity(255)
    --self.banker_choose_frame:setVisible(true)
    --self.banker_choose_frame:stopAllActions()

    local  random_banker = random_banker

    local  random_banker_size = #random_banker

    local  callfunc = cc.CallFunc:create(function()

    local  random_uid = random_banker[math.random(1,random_banker_size)] or 0

    if random_banker_size>1 then
    
        while random_uid == random_uid_ex do
            random_uid = random_banker[math.random(1,random_banker_size)] or 0
        end

        SoundUtils:playEffect(8)
    end
    
    --self.banker_choose_frame:setScale(1.2)
    random_uid_ex = random_uid
    --self.banker_choose_frame:setPosition(cc.p(PLAYER_HEADS_POSITION_TABLE[random_uid].x*GLOBAL_SCALE,PLAYER_HEADS_POSITION_TABLE[random_uid].y*GLOBAL_SCALE))  

    end)
   
   local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay)) 
   --self.banker_choose_frame:runAction(cc.RepeatForever:create(seqAc))
end

function TablePlaneOperator:showBankerChoose(uid)
	--self.banker_choose_frame:stopAllActions()
	--self.banker_choose_frame:setPosition(cc.p(PLAYER_HEADS_POSITION_TABLE[uid].x*GLOBAL_SCALE,PLAYER_HEADS_POSITION_TABLE[uid].y*GLOBAL_SCALE))
	--self.banker_choose_frame:runAction(cc.Sequence:create(
        -- cc.ScaleTo:create(0.3,1.3),
        -- cc.Spawn:create(cc.ScaleTo:create(0.5,1),cc.FadeOut:create(1.2)),
        -- cc.CallFunc:create(function()
        --     local playerType = CDS_PLAYERTYPE_TABLE[uid]
        --         GamePlaneOperator:setEffectFrame(playerType,2)
        --     end)
        -- ))
end


function TablePlaneOperator:showRandomBankerChoose(random_banker)
    
    if  next(random_banker) == nil then
        return
    end
    
    --self.banker_choose_frame:stopAllActions()
    math.randomseed(os.time())

    local  random_banker = random_banker

    local  random_banker_size = #random_banker

    local  callfunc = cc.CallFunc:create(function()
        
        if  random_uid_ex ~= -1 then
            local playerType_ex = CDS_PLAYERTYPE_TABLE[random_uid_ex]
            dump(playerType_ex,"showRandomBankerChoose_playerType_ex")
            GamePlaneOperator:setEffectFrame(playerType_ex,1,false)
        end

        local  random_uid = random_banker[math.random(1,random_banker_size)] or 0

        if random_banker_size>1 then

            while random_uid == random_uid_ex do
                random_uid = random_banker[math.random(1,random_banker_size)] or 0
            end

            SoundUtils:playEffect(8)
        end

        random_uid_ex = random_uid

        local  playerType = CDS_PLAYERTYPE_TABLE[random_uid]
        dump(playerType,"showRandomBankerChoose_playerType")
        GamePlaneOperator:setEffectFrame(playerType,1,true)
        
    end)
    
    local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay)) 
    --self.banker_choose_frame:runAction(cc.RepeatForever:create(seqAc))

end


function TablePlaneOperator:showBankerChoose(uid)
   
    --self.banker_choose_frame:stopAllActions()

    local  playerType = CDS_PLAYERTYPE_TABLE[uid]

    local  callfunc = cc.CallFunc:create(function()
        GamePlaneOperator:clearEffectFrame()
        GamePlaneOperator:setEffectFrame(playerType,1,true)
    end)
    
    local  callfunc2 = cc.CallFunc:create(function()
        GamePlaneOperator:setEffectFrame(playerType,2)
    end)

    local seqAc = cc.Sequence:create(callfunc,cc.DelayTime:create(GrabBankerDelay+0.2),callfunc2) 

    --self.banker_choose_frame:runAction(seqAc)
    
    random_uid_ex = -1
end

function TablePlaneOperator:showShaiziAnimation(shaizi_1,shaizi_2,shaziPos)
    if not shaizi_1 then
        shaizi_1 = 1
    end

    if not shaizi_2 then
        shaizi_1 = 1
    end

    local tempPanel = self.Panel_shaiziImage.Img_panzi
    local kouPanel = self.Panel_shaiziImage.Img_kou
    
    kouPanel:setVisible(false)
    tempPanel:setVisible(true)

    local size = tempPanel:getContentSize()

    for i=1,2 do
        local img_card = tempPanel:getChildByName("img_card"..i)
        local temps = shaizi_1
        if i == 2 then
            temps = shaizi_2
        end

        img_card:loadTexture(TpackageName.."/csb/GameSceneSector/cdsImage/card"..temps..".png")

        local tempx = math.random(size.width*0.2,size.width)
        local tempy = math.random(size.height*0.2,size.height)

        if i == 1 then
            tempx = shaziPos[1]
            tempy = shaziPos[2]
        elseif i == 2 then
            tempx = shaziPos[3]
            tempy = shaziPos[4]
        end

        img_card:setPosition(tempx,tempy)
    end

    local showType = 0
    local soundStr = ""
    if shaizi_1 == 1 and shaizi_2 == 2 then    --红单
        showType = 2
        soundStr ="hongdan"
    elseif shaizi_1 == 1 and shaizi_2 == 3 then --双红
        showType = 4
        soundStr ="hongshuang"
    elseif shaizi_1 == 2 and shaizi_2 == 2 then --麻双
        showType = 1
        soundStr ="mashuang"
    elseif shaizi_1 == 2 and shaizi_2 == 3 then --方单
        showType = 3
        soundStr ="fangdan"
    end

    self.shaizi_Armature:setVisible(true)
    local anim = self.shaizi_Armature:getAnimation()
    anim:playWithNames({"yaoshaizi_02"}, 0, false)

    local seq = cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function()
        self.Panel_shaiziImage:setVisible(true)
        SoundUtils:playEffect(soundStr)
    end),
    cc.DelayTime:create(7.0),
    cc.CallFunc:create(function()
        self.Panel_shaiziImage:setVisible(false)
        self.shaizi_Armature:setVisible(false)
        self.Panel_shaiziAnimation:stopAllActions()
    end))

    self.Panel_shaiziAnimation:runAction(seq)

end

function TablePlaneOperator:showYaoShaiziAnimation(isAction)

    self.shaizi_Armature:setVisible(true)
    local anim = self.shaizi_Armature:getAnimation()
    anim:playWithNames({"yaoshaizi_01"}, 1, false)

end

function TablePlaneOperator:showKouPanZi(isShow)
    self.Panel_shaiziImage.Img_kou:setVisible(true)
    self.Panel_shaiziImage.Img_panzi:setVisible(false)
    self.Panel_shaiziImage:setVisible(isShow)
end

--添加战绩
function TablePlaneOperator:initZhanJiPanel(resultData)

    local panel = self.Image_zhanji:getChildByName("Panel_1")
    panel:removeAllChildren()
    
    if not resultData or #resultData ==0 then
        return
    end

    local size = panel:getContentSize()
    local width = size.width/4
    local height = size.height/5

    local txt = self.Image_zhanji:getChildByName("Text_2")
    local txtred = self.Image_zhanji:getChildByName("Text_1")

    for i,v in ipairs(resultData) do

        local temp = i%4

        if temp == 0 then
            temp = 3
        else
            temp = temp - 1
        end

        local x = width * temp  + 0.5*width

        local y = height
        if i>=1 and i<=4 then
            y = size.height - height*0.5
        elseif i>=5 and i<=8 then
            y = size.height - height*0.5 - height
        elseif  i>=9 and i<=12 then
            y = size.height - height*0.5 - height*2
        elseif i>=13 and i<=16 then
            y = size.height - height*0.5 - height*3
        elseif  i>=17 and i<=20 then   
            y = size.height - height*0.5 - height*4
        end 

        local str  ="红双"
        if v == 1 then
            str  ="红单"
        elseif v == 2 then
            str  ="方单"
        elseif v == 3 then
            str  ="麻双"
        elseif v == 4 then
            str  ="红双"
        end

        local txt1 = txt:clone()
        if i == 1 then
            txt1=txtred:clone()
        end
        txt1:setString(str)
        txt1:setPosition(x,y)
        txt1:addTo(panel)
    end

end

return TablePlaneOperator